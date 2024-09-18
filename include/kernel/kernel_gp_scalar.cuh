#pragma once
#include "cuda/typedef.cuh"
#include "cuda/cuda_macro.cuh"
#include "solver/gpu_solver.hpp"

/*
 * The Main Compute Kernel is structured using small inlined subkernels. These subkernels define the system components.
 * We branch for the following components in order:
 * Scalar, TE/TM
 * Wavefunction only, Wavefunction and Reservoir
 * Linear (Hamiltonian), Nonlinear, Pulse, Pump, Potential, Stochastic
 * These components are then chosen by a master Kernel, which is called by the main loop.
 * Since all subfunctions are inlined, the resulting Kernel should be a single, inlinable function
*/

namespace PC3::Kernel::Compute {

template <bool tmp_use_tetm, bool tmp_use_reservoir, bool tmp_use_pulse, bool tmp_use_pump, bool tmp_use_potential, bool tmp_use_stochastic>
PULSE_GLOBAL PULSE_COMPILER_SPECIFIC void gp_scalar( int i, Type::uint32 current_halo, Solver::KernelArguments args, Solver::InputOutput io ) {
    GENERATE_SUBGRID_INDEX( i, current_halo );

    // Copy Pointers and mark as restricted
    Type::complex* PULSE_RESTRICT in_wf_plus = io.in_wf_plus;
    Type::complex* PULSE_RESTRICT in_rv_plus = io.in_rv_plus;
    Type::complex* PULSE_RESTRICT out_wf_plus = io.out_wf_plus;
    Type::complex* PULSE_RESTRICT out_rv_plus = io.out_rv_plus;

    //BUFFER_TO_SHARED();

    const Type::complex in_wf = in_wf_plus[i];
    const Type::real in_psi_norm = CUDA::abs2( in_wf );

    Type::complex wf_plus = args.p.minus_i_over_h_bar_s * args.p.m_eff_scaled *
                            ( args.p.m2_over_dx2_p_dy2 * in_wf + 
                            ( in_wf_plus[i + args.p.subgrid_row_offset] + in_wf_plus[i - args.p.subgrid_row_offset] ) * args.p.one_over_dy2 +
                            ( in_wf_plus[i + 1] + in_wf_plus[i - 1] ) * args.p.one_over_dx2 );
    
    wf_plus += (args.p.minus_i_over_h_bar_s * args.p.g_c * in_psi_norm - Type::real( 0.5 ) * args.p.gamma_c ) * in_wf;

    if constexpr ( tmp_use_reservoir ) {
        const Type::complex in_rv = in_rv_plus[i];
        wf_plus += (args.p.minus_i_over_h_bar_s * args.p.g_r * in_rv + Type::real( 0.5 ) * args.p.R * in_rv) * in_wf;
        Type::complex rv_plus = -(args.p.gamma_r + args.p.R * in_psi_norm)*in_rv;

        if constexpr ( tmp_use_pump ) {
            for ( int k = 0; k < args.pump_pointers.n; k++ ) {
                PC3::Type::uint32 offset = args.p.subgrid_N2_with_halo * k;
                rv_plus += args.dev_ptrs.pump_plus[i + offset] * args.pump_pointers.amp[k];
            }
        }

        if constexpr ( tmp_use_stochastic ) {
            rv_plus += args.p.R * in_rv / args.p.dV;
        }

        out_rv_plus[i] = rv_plus;
    }

    if constexpr ( tmp_use_potential ) {
        for ( int k = 0; k < args.potential_pointers.n; k++ ) {
            PC3::Type::uint32 offset = args.p.subgrid_N2_with_halo * k;
            const Type::complex potential = args.dev_ptrs.potential_plus[i + offset] * args.potential_pointers.amp[k];
            wf_plus += args.p.minus_i_over_h_bar_s * potential * in_wf;
        }
    }

    if constexpr ( tmp_use_pulse ) {
        for ( int k = 0; k < args.pulse_pointers.n; k++ ) {
            PC3::Type::uint32 offset = args.p.subgrid_N2_with_halo * k;
            const Type::complex pulse = args.dev_ptrs.pulse_plus[i + offset];
            wf_plus += args.p.minus_i_over_h_bar_s * pulse * args.pulse_pointers.amp[k];
        }
    }

    if constexpr ( tmp_use_stochastic ) {
        wf_plus -= args.p.minus_i_over_h_bar_s * args.p.g_c * in_wf / args.p.dV;
    }

    out_wf_plus[i] = wf_plus;
}

// Instantiate the Scalar Kernel with all possible components, so we 


/**
 * Linear, Nonlinear and Independet parts of the upper Kernel
 * These isolated implementations serve for the Split Step
 * Fourier Method (SSFM)
*/

PULSE_GLOBAL PULSE_COMPILER_SPECIFIC void gp_scalar_linear_fourier( int i, Solver::KernelArguments args, Solver::InputOutput io ) {
    GET_THREAD_INDEX( i, args.p.N2 );

    // We do some weird looking casting to avoid intermediate casts to Type::uint32
    Type::real row = Type::real( Type::uint32( i / args.p.N_c ) );
    Type::real col = Type::real( Type::uint32( i % args.p.N_c ) );

    const Type::real k_x = 2.0 * 3.1415926535 * Type::real( col <= args.p.N_c / 2 ? col : -Type::real( args.p.N_c ) + col ) / args.p.L_x;
    const Type::real k_y = 2.0 * 3.1415926535 * Type::real( row <= args.p.N_r / 2 ? row : -Type::real( args.p.N_r ) + row ) / args.p.L_y;

    Type::real linear = args.p.h_bar_s / 2.0 / args.p.m_eff * ( k_x * k_x + k_y * k_y );
    io.out_wf_plus[i] = io.in_wf_plus[i] / Type::real( args.p.N2 ) * CUDA::exp( args.p.minus_i * linear * args.time[1] / Type::real( 2.0 ) );
}

PULSE_GLOBAL PULSE_COMPILER_SPECIFIC void gp_scalar_nonlinear( int i, Solver::KernelArguments args, Solver::InputOutput io ) {
    GET_THREAD_INDEX( i, args.p.N2 );

    const Type::complex in_wf = io.in_wf_plus[i];
    const Type::complex in_rv = io.in_rv_plus[i];
    const Type::real in_psi_norm = CUDA::abs2( in_wf );

    // MARK: Wavefunction
    Type::complex result = { args.p.g_c * in_psi_norm, -args.p.h_bar_s * Type::real( 0.5 ) * args.p.gamma_c };

    for ( int k = 0; k < args.potential_pointers.n; k++ ) {
        PC3::Type::uint32 offset = args.p.subgrid_N2_with_halo * k;
        const Type::complex potential =
            args.dev_ptrs.potential_plus[i + offset] *
            args.potential_pointers.amp[k];
        result += potential;
    }

    result += args.p.g_r * in_rv;
    result += args.p.i * args.p.h_bar_s * Type::real( 0.5 ) * args.p.R * in_rv;

    // MARK: Stochastic
    if ( args.p.stochastic_amplitude > 0.0 ) {
        const Type::complex dw = args.dev_ptrs.random_number[i] * CUDA::sqrt( ( args.p.R * in_rv + args.p.gamma_c ) / ( Type::real( 4.0 ) * args.p.dV ) );
        result -= args.p.g_c / args.p.dV;
    }

    io.out_wf_plus[i] = in_wf * CUDA::exp( args.p.minus_i_over_h_bar_s * result * args.time[1] );

    // MARK: Reservoir
    result = -args.p.gamma_r * in_rv;
    result -= args.p.R * in_psi_norm * in_rv;
    for ( int k = 0; k < args.pump_pointers.n; k++ ) {
        PC3::Type::uint32 offset = args.p.subgrid_N2_with_halo * k;
        result += args.dev_ptrs.pump_plus[i + offset] *
                  args.pump_pointers.amp[k];
    }
    // MARK: Stochastic-2
    if ( args.p.stochastic_amplitude > 0.0 )
        result += args.p.R * in_rv / args.p.dV;
    io.out_rv_plus[i] = in_rv + result * args.time[1];
}

// This kernel is somewhat special, because the reservoir input holds the old reservoir (before the fullstep)
// and the output reservoir hols the new reservoir. We need to use the old reservoir for calculations and then
// write the new reservoir to the output.
PULSE_GLOBAL PULSE_COMPILER_SPECIFIC void gp_scalar_independent( int i, Solver::KernelArguments args, Solver::InputOutput io ) {
    GET_THREAD_INDEX( i, args.p.N2 );
    Type::complex result = { 0.0, 0.0 };

    // MARK: Pulse
    for ( int k = 0; k < args.pulse_pointers.n; k++ ) {
        PC3::Type::uint32 offset = args.p.subgrid_N2_with_halo * k;
        const Type::complex pulse = args.dev_ptrs.pulse_plus[i + offset];
        result += args.p.minus_i_over_h_bar_s * args.time[1] * pulse *
                  args.pulse_pointers.amp[k];
    }

    // MARK: Stochastic
    if ( args.p.stochastic_amplitude > 0.0 ) {
        const Type::complex in_rv = io.out_rv_plus[i]; // Input Reservoir is in output buffer.
        const Type::complex dw = args.dev_ptrs.random_number[i] * CUDA::sqrt( ( args.p.R * in_rv + args.p.gamma_c ) / ( Type::real( 4.0 ) * args.p.dV ) );
        result += dw;
    }
    io.out_wf_plus[i] = io.in_wf_plus[i] + result;
    // Swap the reservoirs
    io.out_rv_plus[i] = io.in_rv_plus[i];
}

} // namespace PC3::Kernel::Compute
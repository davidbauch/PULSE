#pragma once

#include <iostream>
#include <map>
#include "cuda/cuda_complex.cuh"
#include "cuda/cuda_matrix.cuh"
#include "cuda/cuda_macro.cuh"
#include "kernel/kernel_fft.cuh"
#include "system/system.hpp"
#include "system/filehandler.hpp"
#include "solver/matrix_container.hpp"

namespace PC3 {

#define INSTANCIATE_K( index, twin )                                                                           \
    matrix.k##index##_wavefunction_plus.constructDevice( system.N_x, system.N_y, "matrix.k" #index "_wavefunction_plus" );       \
    matrix.k##index##_reservoir_plus.constructDevice( system.N_x, system.N_y, "matrix.k" #index "_reservoir_plus" );             \
    if ( twin ) {                                                                                              \
        matrix.k##index##_wavefunction_minus.constructDevice( system.N_x, system.N_y, "matrix.k" #index "_wavefunction_minus" ); \
        matrix.k##index##_reservoir_minus.constructDevice( system.N_x, system.N_y, "matrix.k" #index "_reservoir_minus" );       \
    }

/**
 * @brief GPU Solver class providing the interface for the GPU solver.
 * Implements RK4, RK45, FFT calculations.
 *
 */
class Solver {
   public:
    // References to system and filehandler so we dont need to pass them around all the time
    PC3::System& system;
    PC3::FileHandler& filehandler;

    // TODO: Move these into one single float buffer.
    struct Oscillation {
        PC3::CUDAMatrix<real_number> t0;
        PC3::CUDAMatrix<real_number> freq;
        PC3::CUDAMatrix<real_number> sigma;
        std::vector<bool> active;
        unsigned int n;

        struct Pointers {
            real_number* t0;
            real_number* freq;
            real_number* sigma;
            unsigned int n;
        };

        void construct( Envelope& envelope) {
            const auto n = envelope.groupSize();
            t0.construct( n, 1, "oscillation_t0" ).setTo( envelope.t0.data() );
            freq.construct( n, 1, "oscillation_freq" ).setTo( envelope.freq.data() );
            sigma.construct( n, 1, "oscillation_sigma" ).setTo( envelope.sigma.data() );
            this->n = n;
            for (int i = 0; i < n; i++) {
                bool is_active = true;
                if ( envelope.t0.data()[i] == 0.0 && envelope.freq.data()[i] == 0.0 && envelope.sigma.data()[i] > 1E11 ) {
                    is_active = false;
                }
                active.push_back( is_active );
            } 
        }

        Pointers pointers() {
            return Pointers{ t0.getDevicePtr(), freq.getDevicePtr(), sigma.getDevicePtr(), n };
        }
    } dev_pulse_oscillation, dev_pump_oscillation, dev_potential_oscillation;

    // Device Variables
    MatrixContainer matrix;

    // Cache Maps
    std::map<std::string, std::vector<real_number>> cache_map_scalar;
    //std::vector<std::vector<complex_number>> wavefunction_plus_history, wavefunction_minus_history;
    //std::vector<real_number> wavefunction_max_plus, wavefunction_max_minus;
    //std::vector<real_number> times;

    // FFT Plan
    cuda_fft_plan plan;

    Solver( PC3::System& system ) : system( system ), filehandler( system.filehandler ) {
        std::cout << "Creating Solver with TE/TM Splitting: " << static_cast<unsigned int>( system.use_twin_mode ) << std::endl;

        // Finally, initialize the FFT Plan
        CUDA_FFT_CREATE( &plan, system.p.N_x, system.p.N_y );

        // Initialize all host matrices
        initializeHostMatricesFromSystem();
        // Then output all matrices to file. If --output was not passed in argv, this method outputs everything.
        outputInitialMatrices();
        // Copy remaining stuff to Device.
        initializeDeviceMatricesFromHost();

        // Set Pump, Potential and Pulse n to zero if they are not evaluated
        if (not system.evaluate_reservoir_kernel) {
            std::cout << "Reservoir is not evaluated, setting n to zero." << std::endl;
            dev_pump_oscillation.n = 0;
        }
        if (not system.evaluate_potential_kernel) {
            std::cout << "Potential is not evaluated, setting n to zero." << std::endl;
            dev_potential_oscillation.n = 0;
        } 
        if (not system.evaluate_pulse_kernel) {
            std::cout << "Pulse is not evaluated, setting n to zero." << std::endl;
            dev_pulse_oscillation.n = 0;
        }
    }

    ~Solver() {
        CUDA_FFT_DESTROY( plan );
    }

    // Functions the global kernel can do

    /**
     * Initializes the FFT Mask device cache matrices.
     * If twin_system is used, initializes the _plus and _minus components of
     * the mask. If not, only initializes the _plus component.
     * Excepts the system host components to be initialized.
     */
    void initializeHostMatricesFromSystem();               // Evaluates the envelopes and initializes the host matrices
    void initializeDeviceMatricesFromHost();               // Transfers the host matrices to their device equivalents

    // Output (Final) Host Matrices to files
    void outputMatrices( const unsigned int start_x, const unsigned int end_x, const unsigned int start_y, const unsigned int end_y, const unsigned int increment, const std::string& suffix = "", const std::string& prefix = "" );
    // Output Initial Host Matrices to files
    void outputInitialMatrices();

    // Output the history and max caches to files. should be called from finalize()
    void cacheToFiles();

    void finalize();

    void iterateFixedTimestepRungeKutta( dim3 block_size, dim3 grid_size );
    void iterateVariableTimestepRungeKutta( dim3 block_size, dim3 grid_size );
    bool iterateRungeKutta();

    void applyFFTFilter( dim3 block_size, dim3 grid_size, bool apply_mask = true );

    void swapBuffers();

    void cacheValues();
    void cacheMatrices();
};

} // namespace PC3
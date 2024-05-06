#pragma once
#include "cuda/cuda_complex.cuh"
#include "cuda/cuda_matrix.cuh"
#include "cuda/cuda_macro.cuh"

namespace PC3 {

/**
* DEFINE_MATRIX(type, name, size_scaling)
* type: The type of the matrix (real_number, complex_number, etc.)
* name: The name of the matrix
* size_scaling: The scaling factor for the size of the matrix
* 
* The matrices will always be constructed with the size N_x x N_y * size_scaling 
* on the Host only. When the device pointer is used for the first time, the
* Matrix class will handle the initialization of the device memory and the
* copying of the data from the host to the device.
*/

#define MATRIX_LIST \
    DEFINE_MATRIX(complex_number, initial_state_plus, 1) \
    DEFINE_MATRIX(complex_number, initial_state_minus, 1) \
    DEFINE_MATRIX(complex_number, wavefunction_plus, 1) \
    DEFINE_MATRIX(complex_number, wavefunction_minus, 1) \
    DEFINE_MATRIX(complex_number, reservoir_plus, 1) \
    DEFINE_MATRIX(complex_number, reservoir_minus, 1) \
    DEFINE_MATRIX(complex_number, pump_plus, n_pumps) \
    DEFINE_MATRIX(complex_number, pump_minus, n_pumps) \
    DEFINE_MATRIX(complex_number, pulse_plus, n_pulses) \
    DEFINE_MATRIX(complex_number, pulse_minus, n_pulses) \
    DEFINE_MATRIX(complex_number, potential_plus, n_potentials) \
    DEFINE_MATRIX(complex_number, potential_minus, n_potentials) \
    DEFINE_MATRIX(complex_number, buffer_wavefunction_plus, 1) \
    DEFINE_MATRIX(complex_number, buffer_wavefunction_minus, 1) \
    DEFINE_MATRIX(complex_number, buffer_reservoir_plus, 1) \
    DEFINE_MATRIX(complex_number, buffer_reservoir_minus, 1) \
    DEFINE_MATRIX(real_number, fft_mask_plus, 1) \
    DEFINE_MATRIX(real_number, fft_mask_minus, 1) \
    DEFINE_MATRIX(complex_number, fft_plus, 1) \
    DEFINE_MATRIX(complex_number, fft_minus, 1) \
    DEFINE_MATRIX(complex_number, k1_wavefunction_plus, 1) \
    DEFINE_MATRIX(complex_number, k1_wavefunction_minus, 1) \
    DEFINE_MATRIX(complex_number, k1_reservoir_plus, 1) \
    DEFINE_MATRIX(complex_number, k1_reservoir_minus, 1) \
    DEFINE_MATRIX(complex_number, k2_wavefunction_plus, 1) \
    DEFINE_MATRIX(complex_number, k2_wavefunction_minus, 1) \
    DEFINE_MATRIX(complex_number, k2_reservoir_plus, 1) \
    DEFINE_MATRIX(complex_number, k2_reservoir_minus, 1) \
    DEFINE_MATRIX(complex_number, k3_wavefunction_plus, 1) \
    DEFINE_MATRIX(complex_number, k3_wavefunction_minus, 1) \
    DEFINE_MATRIX(complex_number, k3_reservoir_plus, 1) \
    DEFINE_MATRIX(complex_number, k3_reservoir_minus, 1) \
    DEFINE_MATRIX(complex_number, k4_wavefunction_plus, 1) \
    DEFINE_MATRIX(complex_number, k4_wavefunction_minus, 1) \
    DEFINE_MATRIX(complex_number, k4_reservoir_plus, 1) \
    DEFINE_MATRIX(complex_number, k4_reservoir_minus, 1) \
    DEFINE_MATRIX(complex_number, k5_wavefunction_plus, 1) \
    DEFINE_MATRIX(complex_number, k5_wavefunction_minus, 1) \
    DEFINE_MATRIX(complex_number, k5_reservoir_plus, 1) \
    DEFINE_MATRIX(complex_number, k5_reservoir_minus, 1) \
    DEFINE_MATRIX(complex_number, k6_wavefunction_plus, 1) \
    DEFINE_MATRIX(complex_number, k6_wavefunction_minus, 1) \
    DEFINE_MATRIX(complex_number, k6_reservoir_plus, 1) \
    DEFINE_MATRIX(complex_number, k6_reservoir_minus, 1) \
    DEFINE_MATRIX(complex_number, k7_wavefunction_plus, 1) \
    DEFINE_MATRIX(complex_number, k7_wavefunction_minus, 1) \
    DEFINE_MATRIX(complex_number, k7_reservoir_plus, 1) \
    DEFINE_MATRIX(complex_number, k7_reservoir_minus, 1) \
    DEFINE_MATRIX(real_number, rk_error, 1) \
    DEFINE_MATRIX(complex_number, random_number, 1) \
    DEFINE_MATRIX(cuda_random_state, random_state, 1) \
    DEFINE_MATRIX(complex_number, snapshot_wavefunction_plus, 1) \
    DEFINE_MATRIX(complex_number, snapshot_wavefunction_minus, 1) \
    DEFINE_MATRIX(complex_number, snapshot_reservoir_plus, 1) \
    DEFINE_MATRIX(complex_number, snapshot_reservoir_minus, 1) // \ // <-- Don't forget the backslash!
    /////////////////////////////
    // Add your matrices here. //
    // Make sure to end each   //
    // but the last line with  //
    // a backslash!            //
    /////////////////////////////

struct MatrixContainer {
    // Declare all matrices using a macro
    #define DEFINE_MATRIX(type, name, size_scaling) PC3::CUDAMatrix<type> name;
    MATRIX_LIST
    #undef X

    // "History" vectors; TODO: move to map
    std::vector<std::vector<complex_number>> wavefunction_plus_history, wavefunction_minus_history;
    std::vector<real_number> wavefunction_max_plus, wavefunction_max_minus;
    std::vector<real_number> times;

    // Empty Constructor
    MatrixContainer() = default;

    // Construction Chain
    void constructAll( const int N_x, const int N_y, bool use_twin_mode, bool use_rk_45, const int n_pulses, const int n_pumps, const int n_potentials ) {
        #define DEFINE_MATRIX(type, name, size_scaling) \
            name.construct( N_x, N_y * size_scaling, #name);
            MATRIX_LIST
        #undef X
     }

    // TODO: Now, only one line defines the matrix
    // But all matrices are synchronzized to the devie
    // Add macor preprocessing if statement that
    // Only creates the pointer if the matrix is used
    // On the other hand, there were only a few matrices that were
    // explicitely host-only: initial_state_plus and initial_state_minus

    struct Pointers {
        #define DEFINE_MATRIX(type, name, size_scaling) \
            type* name;
        MATRIX_LIST
        #undef X
    };

    Pointers pointers() {
        Pointers ptrs;
        #define DEFINE_MATRIX(type, name, size_scaling) \
                ptrs.name = name.getDevicePtr();
        MATRIX_LIST
        #undef X
        return ptrs;
    }
};

} // namespace PC3


/*
struct MatrixContainer {
    // WaveFunction Matrices and Reservoir Matrices
    PC3::CUDAMatrix<complex_number> initial_state_plus;
    PC3::CUDAMatrix<complex_number> initial_state_minus;
    PC3::CUDAMatrix<complex_number> wavefunction_plus;
    PC3::CUDAMatrix<complex_number> wavefunction_minus;
    PC3::CUDAMatrix<complex_number> reservoir_plus;
    PC3::CUDAMatrix<complex_number> reservoir_minus;
    PC3::CUDAMatrix<complex_number> pump_plus;
    PC3::CUDAMatrix<complex_number> pump_minus;
    PC3::CUDAMatrix<complex_number> pulse_plus;
    PC3::CUDAMatrix<complex_number> pulse_minus;
    PC3::CUDAMatrix<complex_number> potential_plus;
    PC3::CUDAMatrix<complex_number> potential_minus;
    // "Next" versions of the above matrices. These are used to store the next iteration of the wavefunction.
    PC3::CUDAMatrix<complex_number> buffer_wavefunction_plus;
    PC3::CUDAMatrix<complex_number> buffer_wavefunction_minus;
    PC3::CUDAMatrix<complex_number> buffer_reservoir_plus;
    PC3::CUDAMatrix<complex_number> buffer_reservoir_minus;

    // FFT Mask Matrices
    PC3::CUDAMatrix<real_number> fft_mask_plus;
    PC3::CUDAMatrix<real_number> fft_mask_minus;
    PC3::CUDAMatrix<complex_number> fft_plus;
    PC3::CUDAMatrix<complex_number> fft_minus;

    // K Matrices. We need 7 K matrices for RK45 and 4 K matrices for RK4.
    // We define all of them here, and allocate/construct only the ones we need.
    PC3::CUDAMatrix<complex_number> k1_wavefunction_plus;
    PC3::CUDAMatrix<complex_number> k1_wavefunction_minus;
    PC3::CUDAMatrix<complex_number> k1_reservoir_plus;
    PC3::CUDAMatrix<complex_number> k1_reservoir_minus;

    PC3::CUDAMatrix<complex_number> k2_wavefunction_plus;
    PC3::CUDAMatrix<complex_number> k2_wavefunction_minus;
    PC3::CUDAMatrix<complex_number> k2_reservoir_plus;
    PC3::CUDAMatrix<complex_number> k2_reservoir_minus;

    PC3::CUDAMatrix<complex_number> k3_wavefunction_plus;
    PC3::CUDAMatrix<complex_number> k3_wavefunction_minus;
    PC3::CUDAMatrix<complex_number> k3_reservoir_plus;
    PC3::CUDAMatrix<complex_number> k3_reservoir_minus;

    PC3::CUDAMatrix<complex_number> k4_wavefunction_plus;
    PC3::CUDAMatrix<complex_number> k4_wavefunction_minus;
    PC3::CUDAMatrix<complex_number> k4_reservoir_plus;
    PC3::CUDAMatrix<complex_number> k4_reservoir_minus;

    PC3::CUDAMatrix<complex_number> k5_wavefunction_plus;
    PC3::CUDAMatrix<complex_number> k5_wavefunction_minus;
    PC3::CUDAMatrix<complex_number> k5_reservoir_plus;
    PC3::CUDAMatrix<complex_number> k5_reservoir_minus;

    PC3::CUDAMatrix<complex_number> k6_wavefunction_plus;
    PC3::CUDAMatrix<complex_number> k6_wavefunction_minus;
    PC3::CUDAMatrix<complex_number> k6_reservoir_plus;
    PC3::CUDAMatrix<complex_number> k6_reservoir_minus;

    PC3::CUDAMatrix<complex_number> k7_wavefunction_plus;
    PC3::CUDAMatrix<complex_number> k7_wavefunction_minus;
    PC3::CUDAMatrix<complex_number> k7_reservoir_plus;
    PC3::CUDAMatrix<complex_number> k7_reservoir_minus;

    // RK45 Error Matrix
    PC3::CUDAMatrix<real_number> rk_error;

    // Random Number Cache
    PC3::CUDAMatrix<complex_number> random_number;
    PC3::CUDAMatrix<cuda_random_state> random_state;

    // Snapshot Matrices (GUI only)
    PC3::CUDAMatrix<complex_number> snapshot_wavefunction_plus;
    PC3::CUDAMatrix<complex_number> snapshot_wavefunction_minus;
    PC3::CUDAMatrix<complex_number> snapshot_reservoir_plus;
    PC3::CUDAMatrix<complex_number> snapshot_reservoir_minus;

    // "History" vectors; TODO: move to map
    std::vector<std::vector<complex_number>> wavefunction_plus_history, wavefunction_minus_history;
    std::vector<real_number> wavefunction_max_plus, wavefunction_max_minus;
    std::vector<real_number> times;

    //////////////////////////////
    // Custom Matrices go here! //
    // Don't forget to add them //
    // to the construction and  //
    // pointers too!            //
    //////////////////////////////

    // Empty Constructor
    MatrixContainer() = default;

    // Construction Chain
    void constructAll( const int N_x, const int N_y, bool use_twin_mode, bool use_rk_45, const int n_pulses, const int n_pumps, const int n_potentials ) {
        // Construct Random Number Cache
        random_number.constructDevice( N_x, N_y, "random_number" );
        random_state.constructDevice( N_x, N_y, "random_state" );

        // Wavefunction, Reservoir, Pump and FFT Matrices
        initial_state_plus.constructHost( N_x, N_y, "initial_state_plus" );
        wavefunction_plus.construct( N_x, N_y, "wavefunction_plus" );
        reservoir_plus.construct( N_x, N_y, "reservoir_plus" );
        pump_plus.construct( N_x, N_y * n_pumps, "pump_plus" );
        pulse_plus.construct( N_x, N_y * n_pulses, "pulse_plus" );
        potential_plus.construct( N_x, N_y * n_potentials, "potential_plus" );
        buffer_wavefunction_plus.construct( N_x, N_y, "buffer_wavefunction_plus" );
        buffer_reservoir_plus.construct( N_x, N_y, "buffer_reservoir_plus" );
        fft_mask_plus.construct( N_x, N_y, "fft_mask_plus" );
        fft_plus.construct( N_x, N_y, "fft_plus" );

        // RK4(5) Matrices
        k1_wavefunction_plus.constructDevice( N_x, N_y, "k1_wavefunction_plus" );
        k1_reservoir_plus.constructDevice( N_x, N_y, "k1_reservoir_plus" );
        k2_wavefunction_plus.constructDevice( N_x, N_y, "k2_wavefunction_plus" );
        k2_reservoir_plus.constructDevice( N_x, N_y, "k2_reservoir_plus" );
        k3_wavefunction_plus.constructDevice( N_x, N_y, "k3_wavefunction_plus" );
        k3_reservoir_plus.constructDevice( N_x, N_y, "k3_reservoir_plus" );
        k4_wavefunction_plus.constructDevice( N_x, N_y, "k4_wavefunction_plus" );
        k4_reservoir_plus.constructDevice( N_x, N_y, "k4_reservoir_plus" );

        rk_error.constructDevice( N_x, N_y, "rk_error" );

        if ( use_rk_45 ) {
            k5_wavefunction_plus.constructDevice( N_x, N_y, "k5_wavefunction_plus" );
            k5_reservoir_plus.constructDevice( N_x, N_y, "k5_reservoir_plus" );
            k6_wavefunction_plus.constructDevice( N_x, N_y, "k6_wavefunction_plus" );
            k6_reservoir_plus.constructDevice( N_x, N_y, "k6_reservoir_plus" );
            k7_wavefunction_plus.constructDevice( N_x, N_y, "k7_wavefunction_plus" );
            k7_reservoir_plus.constructDevice( N_x, N_y, "k7_reservoir_plus" );
        }

        snapshot_wavefunction_plus.construct( N_x, N_y, "snapshot_wavefunction_plus" );
        snapshot_reservoir_plus.construct( N_x, N_y, "snapshot_reservoir_plus" );

        //////////////////////////////////
        // Construct your matrices here //
        //////////////////////////////////

        // TE/TM Guard
        if ( not use_twin_mode )
            return;

        initial_state_minus.constructHost( N_x, N_y, "initial_state_minus" );
        wavefunction_minus.construct( N_x, N_y, "wavefunction_minus" );
        reservoir_minus.construct( N_x, N_y, "reservoir_minus" );
        pump_minus.construct( N_x, N_y * n_pumps, "pump_minus" );
        pulse_minus.construct( N_x, N_y * n_pulses, "pulse_minus" );
        potential_minus.construct( N_x, N_y * n_potentials, "potential_minus" );
        buffer_wavefunction_minus.construct( N_x, N_y, "buffer_wavefunction_minus" );
        buffer_reservoir_minus.construct( N_x, N_y, "buffer_reservoir_minus" );
        fft_mask_minus.construct( N_x, N_y, "fft_mask_minus" );
        fft_minus.construct( N_x, N_y, "fft_minus" );

        k1_wavefunction_minus.constructDevice( N_x, N_y, "k1_wavefunction_minus" );
        k1_reservoir_minus.constructDevice( N_x, N_y, "k1_reservoir_minus" );
        k2_wavefunction_minus.constructDevice( N_x, N_y, "k2_wavefunction_minus" );
        k2_reservoir_minus.constructDevice( N_x, N_y, "k2_reservoir_minus" );
        k3_wavefunction_minus.constructDevice( N_x, N_y, "k3_wavefunction_minus" );
        k3_reservoir_minus.constructDevice( N_x, N_y, "k3_reservoir_minus" );
        k4_wavefunction_minus.constructDevice( N_x, N_y, "k4_wavefunction_minus" );
        k4_reservoir_minus.constructDevice( N_x, N_y, "k4_reservoir_minus" );
        if ( use_rk_45 ) {
            k5_wavefunction_minus.constructDevice( N_x, N_y, "k5_wavefunction_minus" );
            k5_reservoir_minus.constructDevice( N_x, N_y, "k5_reservoir_minus" );
            k6_wavefunction_minus.constructDevice( N_x, N_y, "k6_wavefunction_minus" );
            k6_reservoir_minus.constructDevice( N_x, N_y, "k6_reservoir_minus" );
            k7_wavefunction_minus.constructDevice( N_x, N_y, "k7_wavefunction_minus" );
            k7_reservoir_minus.constructDevice( N_x, N_y, "k7_reservoir_minus" );
        }

        snapshot_wavefunction_minus.construct( N_x, N_y, "snapshot_wavefunction_minus" );
        snapshot_reservoir_minus.construct( N_x, N_y, "snapshot_reservoir_minus" );
    }

    struct Pointers {
        complex_number* wavefunction_plus;
        complex_number* reservoir_plus;
        complex_number* pump_plus;
        complex_number* pulse_plus;
        complex_number* potential_plus;
        complex_number* buffer_wavefunction_plus;
        complex_number* buffer_reservoir_plus;
        complex_number* k1_wavefunction_plus;
        complex_number* k1_reservoir_plus;
        complex_number* k2_wavefunction_plus;
        complex_number* k2_reservoir_plus;
        complex_number* k3_wavefunction_plus;
        complex_number* k3_reservoir_plus;
        complex_number* k4_wavefunction_plus;
        complex_number* k4_reservoir_plus;
        complex_number* k5_wavefunction_plus;
        complex_number* k5_reservoir_plus;
        complex_number* k6_wavefunction_plus;
        complex_number* k6_reservoir_plus;
        complex_number* k7_wavefunction_plus;
        complex_number* k7_reservoir_plus;

        real_number* rk_error;

        complex_number* wavefunction_minus;
        complex_number* reservoir_minus;
        complex_number* pump_minus;
        complex_number* pulse_minus;
        complex_number* potential_minus;
        complex_number* buffer_wavefunction_minus;
        complex_number* buffer_reservoir_minus;
        complex_number* k1_wavefunction_minus;
        complex_number* k1_reservoir_minus;
        complex_number* k2_wavefunction_minus;
        complex_number* k2_reservoir_minus;
        complex_number* k3_wavefunction_minus;
        complex_number* k3_reservoir_minus;
        complex_number* k4_wavefunction_minus;
        complex_number* k4_reservoir_minus;
        complex_number* k5_wavefunction_minus;
        complex_number* k5_reservoir_minus;
        complex_number* k6_wavefunction_minus;
        complex_number* k6_reservoir_minus;
        complex_number* k7_wavefunction_minus;
        complex_number* k7_reservoir_minus;

        complex_number* random_number;
        cuda_random_state* random_state;

        //////////////////////////////
        // Custom Pointers go here! //
        //////////////////////////////
    };

    Pointers pointers() {
        return Pointers{
            wavefunction_plus.getDevicePtr(),
            reservoir_plus.getDevicePtr(),
            pump_plus.getDevicePtr(),
            pulse_plus.getDevicePtr(),
            potential_plus.getDevicePtr(),
            buffer_wavefunction_plus.getDevicePtr(),
            buffer_reservoir_plus.getDevicePtr(),
            k1_wavefunction_plus.getDevicePtr(),
            k1_reservoir_plus.getDevicePtr(),
            k2_wavefunction_plus.getDevicePtr(),
            k2_reservoir_plus.getDevicePtr(),
            k3_wavefunction_plus.getDevicePtr(),
            k3_reservoir_plus.getDevicePtr(),
            k4_wavefunction_plus.getDevicePtr(),
            k4_reservoir_plus.getDevicePtr(),
            k5_wavefunction_plus.getDevicePtr(),
            k5_reservoir_plus.getDevicePtr(),
            k6_wavefunction_plus.getDevicePtr(),
            k6_reservoir_plus.getDevicePtr(),
            k7_wavefunction_plus.getDevicePtr(),
            k7_reservoir_plus.getDevicePtr(),

            rk_error.getDevicePtr(),

            wavefunction_minus.getDevicePtr(),
            reservoir_minus.getDevicePtr(),
            pump_minus.getDevicePtr(),
            pulse_minus.getDevicePtr(),
            potential_minus.getDevicePtr(),
            buffer_wavefunction_minus.getDevicePtr(),
            buffer_reservoir_minus.getDevicePtr(),
            k1_wavefunction_minus.getDevicePtr(),
            k1_reservoir_minus.getDevicePtr(),
            k2_wavefunction_minus.getDevicePtr(),
            k2_reservoir_minus.getDevicePtr(),
            k3_wavefunction_minus.getDevicePtr(),
            k3_reservoir_minus.getDevicePtr(),
            k4_wavefunction_minus.getDevicePtr(),
            k4_reservoir_minus.getDevicePtr(),
            k5_wavefunction_minus.getDevicePtr(),
            k5_reservoir_minus.getDevicePtr(),
            k6_wavefunction_minus.getDevicePtr(),
            k6_reservoir_minus.getDevicePtr(),
            k7_wavefunction_minus.getDevicePtr(),
            k7_reservoir_minus.getDevicePtr(),

            random_number.getDevicePtr(),
            random_state.getDevicePtr() // , // <-- Comma here if you insert more pointers

            ////////////////////////////////////////////
            // Custom Pointers initializer goes here! //
            ////////////////////////////////////////////

            };
    }
};
} // namespace PC3

*/
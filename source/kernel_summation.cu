#include "kernel_summation.cuh"

/**
 * Summation of the k2 array
 * input_for_k2 = current + b11 * dt * k1
 */
CUDA_GLOBAL void rungeFuncSumToK2( int i, complex_number* __restrict__ out_Psi_Plus, complex_number* __restrict__ out_Psi_Minus, complex_number* __restrict__ out_n_Plus, complex_number* __restrict__ out_n_Minus, complex_number* __restrict__ in_Psi_Plus, complex_number* __restrict__ in_Psi_Minus, complex_number* __restrict__ in_n_Plus, complex_number* __restrict__ in_n_Minus, complex_number* __restrict__ k1_Psi_Plus, complex_number* __restrict__ k1_Psi_Minus, complex_number* __restrict__ k1_n_Plus, complex_number* __restrict__ k1_n_Minus ) {
    // If the GPU is used, overwrite the current index with the gpu thread index.
    #ifndef USECPU
    int blockId = ( gridDim.x * blockIdx.y ) + blockIdx.x;
    i = ( blockId * ( blockDim.x * blockDim.y ) ) + ( threadIdx.y * blockDim.x ) + threadIdx.x;
    #endif
    if ( i < dev_s_N * dev_s_N ) {
        out_Psi_Plus[i] = in_Psi_Plus[i] + RKCoefficients::b11 * dev_s_dt * k1_Psi_Plus[i];
        out_n_Plus[i] = in_n_Plus[i] + RKCoefficients::b11 * dev_s_dt * k1_n_Plus[i];
#ifdef TETMSPLITTING
        out_Psi_Minus[i] = in_Psi_Minus[i] + RKCoefficients::b11 * dev_s_dt * k1_Psi_Minus[i];
        out_n_Minus[i] = in_n_Minus[i] + RKCoefficients::b11 * dev_s_dt * k1_n_Minus[i];
#endif
    }
}
/*
 * Summation of the k3 array
 * input_for_k3 = current + b21 * dt * k1 + b22 * dt * k2
 */
CUDA_GLOBAL void rungeFuncSumToK3( int i, complex_number* __restrict__ out_Psi_Plus, complex_number* __restrict__ out_Psi_Minus, complex_number* __restrict__ out_n_Plus, complex_number* __restrict__ out_n_Minus, complex_number* __restrict__ in_Psi_Plus, complex_number* __restrict__ in_Psi_Minus, complex_number* __restrict__ in_n_Plus, complex_number* __restrict__ in_n_Minus, complex_number* __restrict__ k1_Psi_Plus, complex_number* __restrict__ k1_Psi_Minus, complex_number* __restrict__ k1_n_Plus, complex_number* __restrict__ k1_n_Minus, complex_number* __restrict__ k2_Psi_Plus, complex_number* __restrict__ k2_Psi_Minus, complex_number* __restrict__ k2_n_Plus, complex_number* __restrict__ k2_n_Minus ) {
    // If the GPU is used, overwrite the current index with the gpu thread index.
    #ifndef USECPU
    int blockId = ( gridDim.x * blockIdx.y ) + blockIdx.x;
    i = ( blockId * ( blockDim.x * blockDim.y ) ) + ( threadIdx.y * blockDim.x ) + threadIdx.x;
    #endif
    if ( i < dev_s_N * dev_s_N ) {
        out_Psi_Plus[i] = in_Psi_Plus[i] + RKCoefficients::b21 * dev_s_dt * k1_Psi_Plus[i] + RKCoefficients::b22 * dev_s_dt * k2_Psi_Plus[i];
        out_n_Plus[i] = in_n_Plus[i] + RKCoefficients::b21 * dev_s_dt * k1_n_Plus[i] + RKCoefficients::b22 * dev_s_dt * k2_n_Plus[i];
#ifdef TETMSPLITTING
        out_Psi_Minus[i] = in_Psi_Minus[i] + RKCoefficients::b21 * dev_s_dt * k1_Psi_Minus[i] + RKCoefficients::b22 * dev_s_dt * k2_Psi_Minus[i];
        out_n_Minus[i] = in_n_Minus[i] + RKCoefficients::b21 * dev_s_dt * k1_n_Minus[i] + RKCoefficients::b22 * dev_s_dt * k2_n_Minus[i];
#endif
    }
}
/*
 * Summation of the k4 array
 * input_for_k4 = current + b31 * dt * k1 + b32 * dt * k2 + b33 * dt * k3
 */
CUDA_GLOBAL void rungeFuncSumToK4( int i, complex_number* __restrict__ out_Psi_Plus, complex_number* __restrict__ out_Psi_Minus, complex_number* __restrict__ out_n_Plus, complex_number* __restrict__ out_n_Minus, complex_number* __restrict__ in_Psi_Plus, complex_number* __restrict__ in_Psi_Minus, complex_number* __restrict__ in_n_Plus, complex_number* __restrict__ in_n_Minus, complex_number* __restrict__ k1_Psi_Plus, complex_number* __restrict__ k1_Psi_Minus, complex_number* __restrict__ k1_n_Plus, complex_number* __restrict__ k1_n_Minus, complex_number* __restrict__ k2_Psi_Plus, complex_number* __restrict__ k2_Psi_Minus, complex_number* __restrict__ k2_n_Plus, complex_number* __restrict__ k2_n_Minus, complex_number* __restrict__ k3_Psi_Plus, complex_number* __restrict__ k3_Psi_Minus, complex_number* __restrict__ k3_n_Plus, complex_number* __restrict__ k3_n_Minus ) {
    // If the GPU is used, overwrite the current index with the gpu thread index.
    #ifndef USECPU
    int blockId = ( gridDim.x * blockIdx.y ) + blockIdx.x;
    i = ( blockId * ( blockDim.x * blockDim.y ) ) + ( threadIdx.y * blockDim.x ) + threadIdx.x;
    #endif
    if ( i < dev_s_N * dev_s_N ) {
        out_Psi_Plus[i] = in_Psi_Plus[i] + RKCoefficients::b31 * dev_s_dt * k1_Psi_Plus[i] + RKCoefficients::b32 * dev_s_dt * k2_Psi_Plus[i] + RKCoefficients::b33 * dev_s_dt * k3_Psi_Plus[i];
        out_n_Plus[i] = in_n_Plus[i] + RKCoefficients::b31 * dev_s_dt * k1_n_Plus[i] + RKCoefficients::b32 * dev_s_dt * k2_n_Plus[i] + RKCoefficients::b33 * dev_s_dt * k3_n_Plus[i];
#ifdef TETMSPLITTING
        out_Psi_Minus[i] = in_Psi_Minus[i] + RKCoefficients::b31 * dev_s_dt * k1_Psi_Minus[i] + RKCoefficients::b32 * dev_s_dt * k2_Psi_Minus[i] + RKCoefficients::b33 * dev_s_dt * k3_Psi_Minus[i];
        out_n_Minus[i] = in_n_Minus[i] + RKCoefficients::b31 * dev_s_dt * k1_n_Minus[i] + RKCoefficients::b32 * dev_s_dt * k2_n_Minus[i] + RKCoefficients::b33 * dev_s_dt * k3_n_Minus[i];
#endif
    }
}
/*
 * Summation of the k5 array
 input_for_k5 = current + b41 * dt * k1 + b42 * dt * k2 + b43 * dt * k3
                + b44 * dt * k4
 */
CUDA_GLOBAL void rungeFuncSumToK5( int i, complex_number* __restrict__ out_Psi_Plus, complex_number* __restrict__ out_Psi_Minus, complex_number* __restrict__ out_n_Plus, complex_number* __restrict__ out_n_Minus, complex_number* __restrict__ in_Psi_Plus, complex_number* __restrict__ in_Psi_Minus, complex_number* __restrict__ in_n_Plus, complex_number* __restrict__ in_n_Minus, complex_number* __restrict__ k1_Psi_Plus, complex_number* __restrict__ k1_Psi_Minus, complex_number* __restrict__ k1_n_Plus, complex_number* __restrict__ k1_n_Minus, complex_number* __restrict__ k2_Psi_Plus, complex_number* __restrict__ k2_Psi_Minus, complex_number* __restrict__ k2_n_Plus, complex_number* __restrict__ k2_n_Minus, complex_number* __restrict__ k3_Psi_Plus, complex_number* __restrict__ k3_Psi_Minus, complex_number* __restrict__ k3_n_Plus, complex_number* __restrict__ k3_n_Minus, complex_number* __restrict__ k4_Psi_Plus, complex_number* __restrict__ k4_Psi_Minus, complex_number* __restrict__ k4_n_Plus, complex_number* __restrict__ k4_n_Minus ) {
    // If the GPU is used, overwrite the current index with the gpu thread index.
    #ifndef USECPU
    int blockId = ( gridDim.x * blockIdx.y ) + blockIdx.x;
    i = ( blockId * ( blockDim.x * blockDim.y ) ) + ( threadIdx.y * blockDim.x ) + threadIdx.x;
    #endif
    if ( i < dev_s_N * dev_s_N ) {
        out_Psi_Plus[i] = in_Psi_Plus[i] + RKCoefficients::b41 * dev_s_dt * k1_Psi_Plus[i] + RKCoefficients::b42 * dev_s_dt * k2_Psi_Plus[i] + RKCoefficients::b43 * dev_s_dt * k3_Psi_Plus[i] + RKCoefficients::b44 * dev_s_dt * k4_Psi_Plus[i];
        out_n_Plus[i] = in_n_Plus[i] + RKCoefficients::b41 * dev_s_dt * k1_n_Plus[i] + RKCoefficients::b42 * dev_s_dt * k2_n_Plus[i] + RKCoefficients::b43 * dev_s_dt * k3_n_Plus[i] + RKCoefficients::b44 * dev_s_dt * k4_n_Plus[i];
#ifdef TETMSPLITTING
        out_Psi_Minus[i] = in_Psi_Minus[i] + RKCoefficients::b41 * dev_s_dt * k1_Psi_Minus[i] + RKCoefficients::b42 * dev_s_dt * k2_Psi_Minus[i] + RKCoefficients::b43 * dev_s_dt * k3_Psi_Minus[i] + RKCoefficients::b44 * dev_s_dt * k4_Psi_Minus[i];
        out_n_Minus[i] = in_n_Minus[i] + RKCoefficients::b41 * dev_s_dt * k1_n_Minus[i] + RKCoefficients::b42 * dev_s_dt * k2_n_Minus[i] + RKCoefficients::b43 * dev_s_dt * k3_n_Minus[i] + RKCoefficients::b44 * dev_s_dt * k4_n_Minus[i];
#endif
    }
}
/*
 * Summation of the k6 array
 * input_for_k6 = current + b51 * dt * k1 + b52 * dt * k2 + b53 * dt * k3
                  + b54 * dt * k4 + b55 * dt * k5
 */
CUDA_GLOBAL void rungeFuncSumToK6( int i, complex_number* __restrict__ out_Psi_Plus, complex_number* __restrict__ out_Psi_Minus, complex_number* __restrict__ out_n_Plus, complex_number* __restrict__ out_n_Minus, complex_number* __restrict__ in_Psi_Plus, complex_number* __restrict__ in_Psi_Minus, complex_number* __restrict__ in_n_Plus, complex_number* __restrict__ in_n_Minus, complex_number* __restrict__ k1_Psi_Plus, complex_number* __restrict__ k1_Psi_Minus, complex_number* __restrict__ k1_n_Plus, complex_number* __restrict__ k1_n_Minus, complex_number* __restrict__ k2_Psi_Plus, complex_number* __restrict__ k2_Psi_Minus, complex_number* __restrict__ k2_n_Plus, complex_number* __restrict__ k2_n_Minus, complex_number* __restrict__ k3_Psi_Plus, complex_number* __restrict__ k3_Psi_Minus, complex_number* __restrict__ k3_n_Plus, complex_number* __restrict__ k3_n_Minus, complex_number* __restrict__ k4_Psi_Plus, complex_number* __restrict__ k4_Psi_Minus, complex_number* __restrict__ k4_n_Plus, complex_number* __restrict__ k4_n_Minus, complex_number* __restrict__ k5_Psi_Plus, complex_number* __restrict__ k5_Psi_Minus, complex_number* __restrict__ k5_n_Plus, complex_number* __restrict__ k5_n_Minus ) {
    // If the GPU is used, overwrite the current index with the gpu thread index.
    #ifndef USECPU
    int blockId = ( gridDim.x * blockIdx.y ) + blockIdx.x;
    i = ( blockId * ( blockDim.x * blockDim.y ) ) + ( threadIdx.y * blockDim.x ) + threadIdx.x;
    #endif
    if ( i < dev_s_N * dev_s_N ) {
        out_Psi_Plus[i] = in_Psi_Plus[i] + RKCoefficients::b51 * dev_s_dt * k1_Psi_Plus[i] + RKCoefficients::b52 * dev_s_dt * k2_Psi_Plus[i] + RKCoefficients::b53 * dev_s_dt * k3_Psi_Plus[i] + RKCoefficients::b54 * dev_s_dt * k4_Psi_Plus[i] + RKCoefficients::b55 * dev_s_dt * k5_Psi_Plus[i];
        out_n_Plus[i] = in_n_Plus[i] + RKCoefficients::b51 * dev_s_dt * k1_n_Plus[i] + RKCoefficients::b52 * dev_s_dt * k2_n_Plus[i] + RKCoefficients::b53 * dev_s_dt * k3_n_Plus[i] + RKCoefficients::b54 * dev_s_dt * k4_n_Plus[i] + RKCoefficients::b55 * dev_s_dt * k5_n_Plus[i];
#ifdef TETMSPLITTING
        out_Psi_Minus[i] = in_Psi_Minus[i] + RKCoefficients::b51 * dev_s_dt * k1_Psi_Minus[i] + RKCoefficients::b52 * dev_s_dt * k2_Psi_Minus[i] + RKCoefficients::b53 * dev_s_dt * k3_Psi_Minus[i] + RKCoefficients::b54 * dev_s_dt * k4_Psi_Minus[i] + RKCoefficients::b55 * dev_s_dt * k5_Psi_Minus[i];
        out_n_Minus[i] = in_n_Minus[i] + RKCoefficients::b51 * dev_s_dt * k1_n_Minus[i] + RKCoefficients::b52 * dev_s_dt * k2_n_Minus[i] + RKCoefficients::b53 * dev_s_dt * k3_n_Minus[i] + RKCoefficients::b54 * dev_s_dt * k4_n_Minus[i] + RKCoefficients::b55 * dev_s_dt * k5_n_Minus[i];
#endif
    }
}

/**
 * Final Sum for the next iteration
 * next = current + dt * (b61 * k1 + b63 * k3 + b64 * k4 + b65 * k5 + b66 * k6)
 */
CUDA_GLOBAL void rungeFuncSumToFinal( int i, complex_number* out_Psi_Plus, complex_number* out_Psi_Minus, complex_number* out_n_Plus, complex_number* out_n_Minus, complex_number* in_Psi_Plus, complex_number* in_Psi_Minus, complex_number* in_n_Plus, complex_number* in_n_Minus, complex_number* __restrict__ k1_Psi_Plus, complex_number* __restrict__ k1_Psi_Minus, complex_number* __restrict__ k1_n_Plus, complex_number* __restrict__ k1_n_Minus, complex_number* __restrict__ k3_Psi_Plus, complex_number* __restrict__ k3_Psi_Minus, complex_number* __restrict__ k3_n_Plus, complex_number* __restrict__ k3_n_Minus, complex_number* __restrict__ k4_Psi_Plus, complex_number* __restrict__ k4_Psi_Minus, complex_number* __restrict__ k4_n_Plus, complex_number* __restrict__ k4_n_Minus, complex_number* __restrict__ k5_Psi_Plus, complex_number* __restrict__ k5_Psi_Minus, complex_number* __restrict__ k5_n_Plus, complex_number* __restrict__ k5_n_Minus, complex_number* __restrict__ k6_Psi_Plus, complex_number* __restrict__ k6_Psi_Minus, complex_number* __restrict__ k6_n_Plus, complex_number* __restrict__ k6_n_Minus ) {
    // If the GPU is used, overwrite the current index with the gpu thread index.
    #ifndef USECPU
    int blockId = ( gridDim.x * blockIdx.y ) + blockIdx.x;
    i = ( blockId * ( blockDim.x * blockDim.y ) ) + ( threadIdx.y * blockDim.x ) + threadIdx.x;
    #endif
    if ( i < dev_s_N * dev_s_N ) {
        out_Psi_Plus[i] = in_Psi_Plus[i] + dev_s_dt * ( RKCoefficients::b61 * k1_Psi_Plus[i] + RKCoefficients::b63 * k3_Psi_Plus[i] + RKCoefficients::b64 * k4_Psi_Plus[i] + RKCoefficients::b65 * k5_Psi_Plus[i] + RKCoefficients::b66 * k6_Psi_Plus[i] );
        out_n_Plus[i] = in_n_Plus[i] + dev_s_dt * ( RKCoefficients::b61 * k1_n_Plus[i] + RKCoefficients::b63 * k3_n_Plus[i] + RKCoefficients::b64 * k4_n_Plus[i] + RKCoefficients::b65 * k5_n_Plus[i] + RKCoefficients::b66 * k6_n_Plus[i] );
#ifdef TETMSPLITTING
        out_Psi_Minus[i] = in_Psi_Minus[i] + dev_s_dt * ( RKCoefficients::b61 * k1_Psi_Minus[i] + RKCoefficients::b63 * k3_Psi_Minus[i] + RKCoefficients::b64 * k4_Psi_Minus[i] + RKCoefficients::b65 * k5_Psi_Minus[i] + RKCoefficients::b66 * k6_Psi_Minus[i] );
        out_n_Minus[i] = in_n_Minus[i] + dev_s_dt * ( RKCoefficients::b61 * k1_n_Minus[i] + RKCoefficients::b63 * k3_n_Minus[i] + RKCoefficients::b64 * k4_n_Minus[i] + RKCoefficients::b65 * k5_n_Minus[i] + RKCoefficients::b66 * k6_n_Minus[i] );
#endif
    }
}
/**
 * Calculates the error sum for the RK45 Method
 * The error is calculated as the sum of the absolute values of the k arrays and is not normalized by either the sum of Psi nor the number of cells
 * @param out The output array
 */
CUDA_GLOBAL void rungeFuncFinalError( int i, real_number* out, complex_number* in_Psi_Plus, complex_number* in_Psi_Minus, complex_number* in_n_Plus, complex_number* in_n_Minus, complex_number* __restrict__ k1_Psi_Plus, complex_number* __restrict__ k1_Psi_Minus, complex_number* __restrict__ k1_n_Plus, complex_number* __restrict__ k1_n_Minus, complex_number* __restrict__ k3_Psi_Plus, complex_number* __restrict__ k3_Psi_Minus, complex_number* __restrict__ k3_n_Plus, complex_number* __restrict__ k3_n_Minus, complex_number* __restrict__ k4_Psi_Plus, complex_number* __restrict__ k4_Psi_Minus, complex_number* __restrict__ k4_n_Plus, complex_number* __restrict__ k4_n_Minus, complex_number* __restrict__ k5_Psi_Plus, complex_number* __restrict__ k5_Psi_Minus, complex_number* __restrict__ k5_n_Plus, complex_number* __restrict__ k5_n_Minus, complex_number* __restrict__ k6_Psi_Plus, complex_number* __restrict__ k6_Psi_Minus, complex_number* __restrict__ k6_n_Plus, complex_number* __restrict__ k6_n_Minus, complex_number* __restrict__ k7_Psi_Plus, complex_number* __restrict__ k7_Psi_Minus, complex_number* __restrict__ k7_n_Plus, complex_number* __restrict__ k7_n_Minus ) {
    // If the GPU is used, overwrite the current index with the gpu thread index.
    #ifndef USECPU
    int blockId = ( gridDim.x * blockIdx.y ) + blockIdx.x;
    i = ( blockId * ( blockDim.x * blockDim.y ) ) + ( threadIdx.y * blockDim.x ) + threadIdx.x;
    #endif
    if ( i < dev_s_N * dev_s_N ) {
        out[i] = 0.0;
        out[i] += abs2( dev_s_dt * ( RKCoefficients::e1 * k1_Psi_Plus[i] + RKCoefficients::e3 * k3_Psi_Plus[i] + RKCoefficients::e4 * k4_Psi_Plus[i] + RKCoefficients::e5 * k5_Psi_Plus[i] + RKCoefficients::e6 * k6_Psi_Plus[i] + RKCoefficients::e7 * k7_Psi_Plus[i] ) );
        out[i] += abs2( dev_s_dt * ( RKCoefficients::e1 * k1_n_Plus[i] + RKCoefficients::e3 * k3_n_Plus[i] + RKCoefficients::e4 * k4_n_Plus[i] + RKCoefficients::e5 * k5_n_Plus[i] + RKCoefficients::e6 * k6_n_Plus[i] + RKCoefficients::e7 * k7_n_Plus[i] ) );
#ifdef TETMSPLITTING
        out[i] += abs2( dev_s_dt * ( RKCoefficients::e1 * k1_Psi_Minus[i] + RKCoefficients::e3 * k3_Psi_Minus[i] + RKCoefficients::e4 * k4_Psi_Minus[i] + RKCoefficients::e5 * k5_Psi_Minus[i] + RKCoefficients::e6 * k6_Psi_Minus[i] + RKCoefficients::e7 * k7_Psi_Minus[i] ) );
        out[i] += abs2( dev_s_dt * ( RKCoefficients::e1 * k1_n_Minus[i] + RKCoefficients::e3 * k3_n_Minus[i] + RKCoefficients::e4 * k4_n_Minus[i] + RKCoefficients::e5 * k5_n_Minus[i] + RKCoefficients::e6 * k6_n_Minus[i] + RKCoefficients::e7 * k7_n_Minus[i] ) );
#endif
    }
}

/**
 * Summation of the k2,k3 and k4 array
 * This function is used for the RK4
 */
CUDA_GLOBAL void rungeFuncSum( int i, real_number s_dt, complex_number* __restrict__ out_Psi_Plus, complex_number* __restrict__ out_Psi_Minus, complex_number* __restrict__ out_n_Plus, complex_number* __restrict__ out_n_Minus, complex_number* __restrict__ in_Psi_Plus, complex_number* __restrict__ in_Psi_Minus, complex_number* __restrict__ in_n_Plus, complex_number* __restrict__ in_n_Minus, complex_number* __restrict__ k_Psi_Plus, complex_number* __restrict__ k_Psi_Minus, complex_number* __restrict__ k_n_Plus, complex_number* __restrict__ k_n_Minus ) {
    // If the GPU is used, overwrite the current index with the gpu thread index.
    #ifndef USECPU
    int blockId = ( gridDim.x * blockIdx.y ) + blockIdx.x;
    i = ( blockId * ( blockDim.x * blockDim.y ) ) + ( threadIdx.y * blockDim.x ) + threadIdx.x;
    #endif
    if ( i < dev_s_N * dev_s_N ) {
        out_Psi_Plus[i] = in_Psi_Plus[i] + s_dt * dev_s_dt * k_Psi_Plus[i];
        out_n_Plus[i] = in_n_Plus[i] + s_dt * dev_s_dt * k_n_Plus[i];
#ifdef TETMSPLITTING
        out_Psi_Minus[i] = in_Psi_Minus[i] + s_dt * dev_s_dt * k_Psi_Minus[i];
        out_n_Minus[i] = in_n_Minus[i] + s_dt * dev_s_dt * k_n_Minus[i];
#endif
    }
}

CUDA_GLOBAL void rungeFuncSumToFinalFixed( int i, complex_number* out_Psi_Plus, complex_number* out_Psi_Minus, complex_number* out_n_Plus, complex_number* out_n_Minus, complex_number* in_Psi_Plus, complex_number* in_Psi_Minus, complex_number* in_n_Plus, complex_number* in_n_Minus, complex_number* __restrict__ k1_Psi_Plus, complex_number* __restrict__ k1_Psi_Minus, complex_number* __restrict__ k1_n_Plus, complex_number* __restrict__ k1_n_Minus, complex_number* __restrict__ k2_Psi_Plus, complex_number* __restrict__ k2_Psi_Minus, complex_number* __restrict__ k2_n_Plus, complex_number* __restrict__ k2_n_Minus, complex_number* __restrict__ k3_Psi_Plus, complex_number* __restrict__ k3_Psi_Minus, complex_number* __restrict__ k3_n_Plus, complex_number* __restrict__ k3_n_Minus, complex_number* __restrict__ k4_Psi_Plus, complex_number* __restrict__ k4_Psi_Minus, complex_number* __restrict__ k4_n_Plus, complex_number* __restrict__ k4_n_Minus ) {
    // If the GPU is used, overwrite the current index with the gpu thread index.
    #ifndef USECPU
    int blockId = ( gridDim.x * blockIdx.y ) + blockIdx.x;
    i = ( blockId * ( blockDim.x * blockDim.y ) ) + ( threadIdx.y * blockDim.x ) + threadIdx.x;
    #endif
    if ( i < dev_s_N * dev_s_N ) {
        out_Psi_Plus[i] = in_Psi_Plus[i] + dev_s_dt / 6.0 * ( k1_Psi_Plus[i] + 2.0 * k2_Psi_Plus[i] + 2.0 * k3_Psi_Plus[i] + k4_Psi_Plus[i] );
        out_n_Plus[i] = in_n_Plus[i] + dev_s_dt / 6.0 * ( k1_n_Plus[i] + 2.0 * k2_n_Plus[i] + 2.0 * k3_n_Plus[i] + k4_n_Plus[i] );
#ifdef TETMSPLITTING
        out_Psi_Minus[i] = in_Psi_Minus[i] + dev_s_dt / 6.0 * ( k1_Psi_Minus[i] + 2.0 * k2_Psi_Minus[i] + 2.0 * k3_Psi_Minus[i] + k4_Psi_Minus[i] );
        out_n_Minus[i] = in_n_Minus[i] + dev_s_dt / 6.0 * ( k1_n_Minus[i] + 2.0 * k2_n_Minus[i] + 2.0 * k3_n_Minus[i] + k4_n_Minus[i] );
#endif
    }
}
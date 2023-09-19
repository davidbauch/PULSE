#pragma once
#include "cuda_complex_math.cuh"

CUDA_HOST_DEVICE void kernel_generateRingPhase( int s_N, real_number amp, int n, real_number w1, real_number w2, real_number xPos, real_number yPos, real_number p_xmax, real_number s_dx, bool normalize, complex_number* buffer, bool reset = true );

CUDA_HOST_DEVICE void kernel_generateRingState( int s_N, real_number amp, real_number w1, real_number w2, real_number xPos, real_number yPos, real_number p_xmax, real_number s_dx, bool normalize, complex_number* buffer, bool reset = true );
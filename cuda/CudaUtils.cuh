#pragma once

#define HD __host__ __device__

#include <cuda_runtime.h>
#include <curand_kernel.h>

#include <cuda/cmath>
#include <iostream>
#include <limits>

#define INDX(i, j, ld) ((i) + (j) * (ld))
#define CUDA_CHECK(val) cuda_check((val), #val, __FILE__, __LINE__)

inline void cuda_check(cudaError_t err, const char* call, const char* file,
                       int line) {
    if (err != cudaSuccess) {
        std::cerr << "CUDA error at " << file << ":" << line << " — "
                  << cudaGetErrorString(err) << " (" << call << ")\n";
        std::exit(1);
    }
}

__global__ void init_curand(curandState* states, unsigned long long seed,
                            int width, int height) {
    int x = threadIdx.x + blockDim.x * blockIdx.x;
    int y = threadIdx.y + blockDim.y * blockIdx.y;
    int idx = x + width * y;

    if (x < width && y < height) {
        curand_init(seed, idx, 0, &states[idx]);
    }
}

// return random float in range [0, 1) approximately
HD inline float random_float(curandState* state = NULL) {
#ifdef __CUDA_ARCH__
    return curand_uniform(state);
#else
    return std::rand() / (1.0f + RAND_MAX);
#endif
}

// return random float in range [min, max)
HD inline float random_float(float min, float max, curandState* state = NULL) {
    return min + (max - min) * random_float(state);
}

inline const float Infinity = std::numeric_limits<float>::infinity();
inline const float Pi = 3.1415926535897932385f;
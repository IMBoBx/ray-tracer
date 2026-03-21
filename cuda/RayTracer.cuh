#pragma once

#define HD __host__ __device__

#include <cuda_runtime.h>

#include <cmath>
#include <cstdlib>
#include <cuda/cmath>
#include <iostream>
#include <limits>
#include <memory>

using std::make_shared;
using std::shared_ptr;

const float infinity = std::numeric_limits<float>::infinity();
const float pi = 3.1415926535897932385;

HD inline float degrees_to_radians(float degrees) {
    return degrees * pi / 180.0;
}

// TODO: RNG functions
// inline double random_double() {
//     // return random double in range [0, 1) approximately
//     return std::rand() / (1.0 + RAND_MAX);
// }

// inline double random_double(double min, double max) {
//     // return random double in range [min, max)
//     return min + (max - min) * random_double();
// }

#include "Color.cuh"
#include "HitRecord.cuh"
#include "Interval.cuh"
#include "Material.cuh"
#include "Ray.cuh"
#include "Sphere.cuh"
#include "Vec3.cuh"
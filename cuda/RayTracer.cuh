#pragma once

#include <cmath>
#include <cstdlib>
#include <iostream>
#include <limits>
#include <memory>

#include "Color.cuh"
#include "CudaUtils.cuh"
#include "HitRecord.cuh"
#include "Interval.cuh"
#include "Material.cuh"
#include "Ray.cuh"
#include "Sphere.cuh"
#include "Vec3.cuh"

const float infinity = std::numeric_limits<float>::infinity();
const float pi = 3.1415926535897932385;

HD inline float degrees_to_radians(float degrees) {
    return degrees * pi / 180.0;
}

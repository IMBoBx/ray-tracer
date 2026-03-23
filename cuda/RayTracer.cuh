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
#include "Scatter.cuh"
#include "Sphere.cuh"
#include "Vec3.cuh"

HD inline float degrees_to_radians(float degrees) {
    return degrees * Pi / 180.0;
}

#ifndef RAY_TRACER_H
#define RAY_TRACER_H

#include <cmath>
#include <cstdlib>
#include <iostream>
#include <limits>
#include <memory>

using std::make_shared;
using std::shared_ptr;

const double infinity = std::numeric_limits<double>::infinity();
const double pi = 3.1415926535897932385;

inline double degrees_to_radians(double degrees) {
    return degrees * pi / 180.0;
}

inline double random_double() {
    // return random double in range [0, 1) approximately
    return std::rand() / (1.0 + RAND_MAX);
}

inline double random_double(double min, double max) {
    // return random double in range [min, max)
    return min + (max - min) * random_double();
}

#include "color.h"
#include "interval.h"
#include "ray.h"
#include "vec3.h"

#endif
#pragma once

#include "RayTracer.cuh"

class Interval {
   public:
    float min, max;

    HD Interval() : min(-infinity), max(infinity) {}
    HD Interval(float min, float max) : min(min), max(max) {}

    HD float size() const { return max - min; }

    HD bool contains(float x) const { return x >= min && x <= max; }

    HD bool surrounds(float x) const { return x > min && x < max; }

    HD float clamp(float x) const {
        if (x < min) return min;
        if (x > max) return max;
        return x;
    }

    static const Interval empty, universe;
};

inline const Interval Interval::empty = Interval(+infinity, -infinity);
inline const Interval Interval::universe = Interval(-infinity, +infinity);

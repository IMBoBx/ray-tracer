#pragma once

#include "RayTracer.cuh"

class Ray {
   private:
    Point3 orig;
    Vec3 dir;

   public:
    HD Ray() {}

    HD Ray(const Point3& origin, const Vec3& direction)
        : orig(origin), dir(direction) {}

    HD const Point3& origin() const { return orig; }
    HD const Vec3& direction() const { return dir; }

    HD Point3 at(float t) const { return orig + t * dir; }
};

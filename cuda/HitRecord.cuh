#pragma once

#include "RayTracer.cuh"
#include "Material.cuh"

class HitRecord {
   public:
    Point3 p;
    Vec3 normal;
    Material mat;
    float t;
    bool front_face;  // whether the incident ray is hitting the
                      // "outside"/"front" of the shape

    HD void set_face_normal(const Ray& r, const Vec3& outward_normal) {
        // assumed outward_normal is unit vector

        // goal is to have normal always face against the incident ray. for that
        // we're initially assuming the regular behavior from before -- normal
        // drawn from center to outside -- then if its already against incident
        // ray, keep it same, and if its currently toward the incident ray then
        // flip it.

        front_face = dot(r.direction(), outward_normal) < 0;
        normal = front_face ? outward_normal : -outward_normal;
    }
};

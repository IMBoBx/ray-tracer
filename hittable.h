#ifndef HITTABLE_H
#define HITTABLE_H

#include "ray_tracer.h"

class hit_record {
   public:
    point3 p;
    vec3 normal;
    double t;
    bool front_face;  // whether the incident ray is hitting the
                      // "outside"/"front" of the shape

    void set_face_normal(const ray& r, const vec3& outward_normal) {
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

class hittable {
   public:
    virtual ~hittable() = default;

    virtual bool hit(const ray& r, interval ray_t, hit_record& rec) const = 0;
};

#endif
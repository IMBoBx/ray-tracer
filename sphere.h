#ifndef SPHERE_H
#define SPHERE_H

#include "hittable.h"
#include "vec3.h"

class sphere : public hittable {
   private:
    point3 center;
    double radius;

   public:
    sphere(const point3& center, double radius)
        : center(center), radius(std::fmax(0, radius)) {}

    bool hit(const ray& r, double ray_tmin, double ray_tmax,
             hit_record& rec) const override {
        vec3 oc = center - r.origin();
        vec3 dir = r.direction();

        double a = dir.length_squared();
        // b = -2*dir - oc; use b = -2h;
        double h = dot(dir, oc);
        double c = oc.length_squared() - radius * radius;

        double discriminant = h * h - a * c;  //

        if (discriminant < 0) {
            return false;
        }

        double sqrtd = std::sqrt(discriminant);

        // finding nearest root
        double root = (h - sqrtd) / a;
        if (root < ray_tmin || root > ray_tmax) {
            root = (h + sqrtd) / a;
            if (root < ray_tmin || root > ray_tmax) {
                return false;
            }
        }

        rec.t = root;
        rec.p = r.at(root);
        vec3 outward_normal = (rec.p - center) / radius;
        rec.set_face_normal(r, outward_normal);

        return true;
    }
};

#endif
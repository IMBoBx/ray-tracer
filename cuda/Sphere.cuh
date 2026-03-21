#pragma once

#include "HitRecord.cuh"
#include "Material.cuh"
#include "RayTracer.cuh"

struct Sphere {
    Point3 center;
    float radius;
    Material mat;
};

HD bool hit_sphere(const Sphere& sphere, const Ray& r, Interval ray_t,
                   HitRecord& rec) {
    Point3 center = sphere.center;
    float radius = sphere.radius;

    Vec3 oc = center - r.origin();
    Vec3 dir = r.direction();

    float a = dir.length_squared();
    // b = -2*dir - oc; use b = -2h;
    float h = dot(dir, oc);
    float c = oc.length_squared() - radius * radius;

    float discriminant = h * h - a * c;  //

    if (discriminant < 0) {
        return false;
    }

    float sqrtd = cuda::std::sqrt(discriminant);

    // finding nearest root
    float root = (h - sqrtd) / a;
    if (!ray_t.surrounds(root)) {
        root = (h + sqrtd) / a;
        if (!ray_t.surrounds(root)) {
            return false;
        }
    }

    rec.t = root;
    rec.p = r.at(root);
    Vec3 outward_normal = (rec.p - center) / radius;
    rec.set_face_normal(r, outward_normal);
    rec.mat = sphere.mat;

    return true;
}

HD bool hit_world(const Sphere* world, int num_objects, const Ray& r,
                  Interval ray_t, HitRecord& rec) {
    HitRecord temp_rec;
    bool hit_anything = false;
    float closest_yet = ray_t.max;

    for (int i = 0; i < num_objects; i++) {
        const auto& obj = world[i];
        if (hit_sphere(obj, r, Interval(ray_t.min, closest_yet), temp_rec)) {
            hit_anything = true;
            closest_yet = temp_rec.t;
            rec = temp_rec;
        }
    }

    return hit_anything;
}
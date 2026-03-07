#ifndef HITTABLE_LIST_H
#define HITTABLE_LIST_H

#include <vector>

#include "ray_tracer.h"
#include "hittable.h"

using std::make_shared;
using std::shared_ptr;

class hittable_list : public hittable {
   public:
    std::vector<shared_ptr<hittable>> objects;

    hittable_list() {}
    hittable_list(shared_ptr<hittable> obj) { add(obj); }

    void add(shared_ptr<hittable> obj) { objects.push_back(obj); }

    void clear() { objects.clear(); }

    bool hit(const ray& r, double ray_tmin, double ray_tmax,
             hit_record& rec) const override {
        hit_record temp_rec;
        bool hit_anything = false;
        double closest_yet = ray_tmax;

        for (const auto& obj : objects) {
            if (obj->hit(r, ray_tmin, closest_yet, temp_rec)) {
                hit_anything = true;
                closest_yet = temp_rec.t;
                rec = temp_rec;
            }
        }

        return hit_anything;
    }
};

#endif
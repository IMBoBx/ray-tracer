#pragma once

#include "RayTracer.cuh"

enum class MaterialType : int { Lambertian, Metal, Dielectric };

struct Material {
    MaterialType type;
    Color albedo;
    float fuzz;
    float ri;
};

HD float reflectance(float, float);  // forward declaring

HD bool scatter_lambertian(const Ray& r_in, const HitRecord& rec,
                           Color& attenuation, Ray& scattered) {
    auto scatter_direction = rec.normal + random_unit_vector();

    if (scatter_direction.near_zero()) scatter_direction = rec.normal;

    scattered = Ray(rec.p, scatter_direction);
    attenuation = rec.mat.albedo;
    return true;
}

HD bool scatter_metal(const Ray& r_in, const HitRecord& rec, Color& attenuation,
                      Ray& scattered) {
    auto reflected = reflect(r_in.direction(), rec.normal);
    reflected = unit_vector(reflected) + rec.mat.fuzz * random_unit_vector();

    scattered = Ray(rec.p, reflected);
    attenuation = rec.mat.albedo;
    return (dot(scattered.direction(), rec.normal) > 0);
}

HD bool scatter_dielectric(const Ray& r_in, const HitRecord& rec,
                           Color& attenuation, Ray& scattered) {
    attenuation = Color(1.0, 1.0, 1.0);
    float ri = rec.front_face ? 1.0 / rec.mat.ri : rec.mat.ri;

    Vec3 unit_direction = unit_vector(r_in.direction());
    float cos_theta = std::fmin(dot(-unit_direction, rec.normal), 1.0);
    float sin_theta = std::sqrt(1.0 - cos_theta * cos_theta);

    bool cannot_refract = ri * sin_theta > 1.0;
    Vec3 dir;

    if (cannot_refract || reflectance(cos_theta, ri) > random_float()) {
        dir = reflect(unit_direction, rec.normal);
    } else {
        dir = refract(unit_direction, rec.normal, ri);
    }

    scattered = Ray(rec.p, dir);
    return true;
}

HD bool scatter(const Ray& r_in, const HitRecord& rec, Color& attenuation,
                Ray& scattered) {
    switch (rec.mat.type) {
        case MaterialType::Lambertian:
            return scatter_lambertian(r_in, rec, attenuation, scattered);
            break;
        case MaterialType::Metal:
            return scatter_metal(r_in, rec, attenuation, scattered);
            break;
        case MaterialType::Dielectric:
            return scatter_dielectric(r_in, rec, attenuation, scattered);
            break;
    }
}

HD float reflectance(float cosine, float refractive_index) {
    auto r0 = (1 - refractive_index) / (1 + refractive_index);
    r0 = r0 * r0;
    return r0 + (1 - r0) * std::pow((1 - cosine), 5);
}

// TODO: fix the RNG stuff here too
Vec3 random_unit_vector() { return Vec3(0.5, 0.5, 0.5); }
float random_float() { return 0.5; }
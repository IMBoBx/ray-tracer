#include <vector>

#include "RayTracer.cuh"
#include "Camera.cuh"

int main() {
    std::vector<Sphere> world;

    Material material_ground =
    Material{type : MaterialType::Lambertian, albedo : Color(0.8, 0.8, 0.0)};

    Material material_center =
    Material{type : MaterialType::Lambertian, albedo : Color(0.1, 0.2, 0.5)};

    Material material_left = Material{
        type : MaterialType::Metal,
        albedo : Color(0.8, 0.8, 0.8),
        fuzz : 0.3
    };

    Material material_right =
    Material{type : MaterialType::Dielectric, ri : 1.5};

    Material material_bubble =
    Material{type : MaterialType::Dielectric, ri : 1.0f / 1.5f};

    world.push_back(Sphere(Point3(0, -100.5, -1), 100, material_ground));
    world.push_back(Sphere(Point3(0, 0, -1.2), 0.5, material_center));
    world.push_back(Sphere(Point3(-1.0, 0.0, -1.0), 0.5, material_left));
    world.push_back(Sphere(Point3(1.0, 0.0, -1.0), 0.5, material_right));
    world.push_back(Sphere(Point3(1.0, 0.0, -1.0), 0.25, material_bubble));

    Camera cam;
    cam.aspect_ratio = 16.0 / 9.0;
    cam.image_width = 400;
    cam.samples_per_pixel = 100;
    cam.max_depth = 50;

    cam.vfov = 90;
    cam.lookfrom = Point3(0, 0, 0);
    cam.lookat = Point3(0, 0, -1);
    cam.vup = Vec3(0, 1, 0);

    cam.defocus_angle = 10.0;
    cam.focus_dist = 1;

    cam.render(world.data(), world.size());
}
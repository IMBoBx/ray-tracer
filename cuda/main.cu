#include <vector>

#include "RayTracer.cuh"

// no alphabetical order
#include "Camera.cuh"

int main() {
    // std::vector<Sphere> world;

    // Material material_ground =
    // Material{type : MaterialType::Lambertian, albedo : Color(0.8, 0.8, 0.0)};

    // Material material_center =
    // Material{type : MaterialType::Lambertian, albedo : Color(0.1, 0.2, 0.5)};

    // Material material_left = Material{
    //     type : MaterialType::Metal,
    //     albedo : Color(0.8, 0.8, 0.8),
    //     fuzz : 0.3
    // };

    // Material material_right =
    // Material{type : MaterialType::Dielectric, ri : 1.5};

    // Material material_bubble =
    // Material{type : MaterialType::Dielectric, ri : 1.0f / 1.5f};

    // world.push_back(Sphere(Point3(0, -100.5, -1), 100, material_ground));
    // world.push_back(Sphere(Point3(0, 0, -1.2), 0.5, material_center));
    // world.push_back(Sphere(Point3(-1.0, 0.0, -1.0), 0.5, material_left));
    // world.push_back(Sphere(Point3(1.0, 0.0, -1.0), 0.5, material_right));
    // world.push_back(Sphere(Point3(1.0, 0.0, -1.0), 0.25, material_bubble));

    // Camera cam;
    // cam.aspect_ratio = 16.0 / 9.0;
    // cam.image_width       = 1080;
    // cam.samples_per_pixel = 500;
    // cam.max_depth = 50;

    // cam.vfov = 90;
    // cam.lookfrom = Point3(0, 0, 0);
    // cam.lookat = Point3(0, 0, -1);
    // cam.vup = Vec3(0, 1, 0);

    // cam.defocus_angle = 10.0;
    // cam.focus_dist = 1;

    // cam.render(world.data(), world.size());

    // BIGASS WORLD

    std::vector<Sphere> world;

    auto ground_material =
    Material{type : MaterialType::Lambertian, albedo : Color(0.5f, 0.5f, 0.5f)};
    world.push_back(Sphere(Point3(0, -1000, 0), 1000, ground_material));

    for (int a = -11; a < 11; a++) {
        for (int b = -11; b < 11; b++) {
            auto choose_mat = random_float();
            Point3 center(a + 0.9f * random_float(), 0.2,
                          b + 0.9f * random_float());

            if ((center - Point3(4, 0.2, 0)).length() > 0.9f) {
                Material mat;
                if (choose_mat < 0.8) {
                    // lambertian
                    mat.type = MaterialType::Lambertian;
                    mat.albedo = Color::random() * Color::random();
                } else if (choose_mat < 0.95) {
                    // metal
                    mat.type = MaterialType::Metal;
                    mat.albedo = Color::random(0.5f, 1.0f);
                    mat.fuzz = random_float(0, 0.5f);
                } else {
                    // glass
                    mat.type = MaterialType::Dielectric;
                    mat.ri = 1.5f;
                }

                world.push_back(Sphere(center, 0.2f, mat));
            }
        }
    }

    auto material1 = Material{type : MaterialType::Dielectric, ri : 1.5};
    world.push_back(Sphere(Point3(0, 1, 0), 1.0f, material1));

    auto material2 =
    Material{type : MaterialType::Lambertian, Color(0.4, 0.2, 0.1)};
    world.push_back(Sphere(Point3(-4, 1, 0), 1.0f, material2));

    auto material3 =
    Material{type : MaterialType::Metal, Color(0.7, 0.6, 0.5), 0.0};
    world.push_back(Sphere(Point3(4, 1, 0), 1.0, material3));

    Camera cam;

    cam.aspect_ratio = 16.0f / 9.0f;
    cam.image_width       = 1080;
    cam.samples_per_pixel = 500;
    cam.max_depth = 50;

    cam.vfov = 20;
    cam.lookfrom = Point3(13, 2, 3);
    cam.lookat = Point3(0, 0, 0);
    cam.vup = Vec3(0, 1, 0);

    cam.defocus_angle = 0.6f;
    cam.focus_dist = 10.0f;

    cam.render(world.data(), world.size());
}
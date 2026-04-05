#ifndef CAMERA_H
#define CAMERA_H

#include <chrono>

#include "hittable.h"
#include "material.h"

class camera {
   public:
    double aspect_ratio = 1.0;   // ratio width / height
    int image_width = 100;       // width in no. of pixels
    int samples_per_pixel = 10;  // no. of samples to average for antialiasing
    int max_depth = 10;          // recursion depth for child rays

    double vfov = 90;  // vertical field of view (degrees)
    point3 lookfrom = point3(0, 0, 0);
    point3 lookat = point3(0, 0, -1);
    vec3 vup = vec3(0, 1, 0);  // camera-relative "up" direction

    double defocus_angle = 0;  // variation angle of rays through each pixel
    double focus_dist = 10;  // distance from lookfrom to plane of perfect focus

    void render(const hittable& world) {
        initialize();
        std::cout << "P3\n" << image_width << " " << image_height << "\n255\n";

        auto t_start = std::chrono::high_resolution_clock::now();

        for (int j = 0; j < image_height; j++) {
            std::clog << "\rScanlines remaining: " << (image_height - j) << ' '
                      << std::flush;

            for (int i = 0; i < image_width; i++) {
                color pixel_color = color(0, 0, 0);

                for (int sample = 0; sample < samples_per_pixel; sample++) {
                    ray r = get_ray(i, j);
                    pixel_color += ray_color(r, max_depth, world);
                }

                write_color(std::cout, pixel_samples_scale * pixel_color);
            }
        }

        auto t_end = std::chrono::high_resolution_clock::now();
        double elapsed = std::chrono::duration<double>(t_end - t_start).count();
        std::clog << "\rDone.                 \n";
        std::clog << "Render time: " << elapsed << " s\n";
    }

   private:
    int image_height;            // height of rendered image
    point3 center;               // camera center/origin
    point3 pixel00_loc;          // location of pixel 0,0 (top left)
    vec3 pixel_delta_u;          // offset to pixel right
    vec3 pixel_delta_v;          // offset to pixel below
    double pixel_samples_scale;  // 1 / samples_per_pixel
    vec3 u, v, w;                // camera frame basis vectors
    vec3 defocus_disc_u;         // disc horizontal radius
    vec3 defocus_disc_v;         // disc vertical radius

    void initialize() {
        // calculate and clip image height to at least 1
        image_height = int(image_width / aspect_ratio);
        image_height = (image_height < 1) ? 1 : image_height;

        pixel_samples_scale = 1.0 / samples_per_pixel;

        center = lookfrom;

        // define viewport dimensions
        // auto focal_length = (lookfrom - lookat).length();
        auto theta = degrees_to_radians(vfov);
        auto h = std::tan(theta / 2);

        auto viewport_height = 2 * h * focus_dist;
        auto viewport_width =
            viewport_height * (double(image_width) / image_height);

        // calculate u, v, w
        w = unit_vector(lookfrom - lookat);
        u = unit_vector(cross(vup, w));
        v = cross(w, u);

        // calculate horizontal and vertical viewport vectors along the edges
        auto viewport_u =
            viewport_width * u;  // vector across the viewport horizontally (top
                                 // left to top right)
        auto viewport_v =
            viewport_height * -v;  // vector down the viewport vertically (top
                                   // left to bottom left)

        // calculate pixel delta values (horizontal and vertical)
        pixel_delta_u = viewport_u / image_width;
        pixel_delta_v = viewport_v / image_height;

        // calculate top left pixel of viewport
        auto viewport_upper_left =
            center - (focus_dist * w) - viewport_u / 2 - viewport_v / 2;
        pixel00_loc =
            viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v);

        auto defocus_radius =
            focus_dist * std::tan(degrees_to_radians(defocus_angle / 2));
        defocus_disc_u = u * defocus_radius;
        defocus_disc_v = v * defocus_radius;
    }

    // Construct a camera ray originating from the defocus disk and directed at
    // a randomly sampled point around the pixel location i, j.
    ray get_ray(int i, int j) const {
        auto offset = sample_square();
        auto pixel_sample = pixel00_loc + (i + offset.x()) * pixel_delta_u +
                            (j + offset.y()) * pixel_delta_v;

        auto ray_origin =
            (defocus_angle <= 0)
                ? center
                : defocus_disc_sample();  // camera center not square center --
                                          // square center is pixel00_loc
        auto ray_dir = pixel_sample - ray_origin;

        return ray(ray_origin, ray_dir);
    }

    vec3 sample_square() const {
        // get random point on a unit square (-0.5 to +0.5 range)
        return vec3(random_double() - 0.5, random_double() - 0.5, 0);
    }

    point3 defocus_disc_sample() const {
        auto p = random_in_unit_disc();
        return center + (p[0] * defocus_disc_u) + (p[1] * defocus_disc_v);
    }

    const color ray_color(const ray& r, int depth, const hittable& world) {
        if (depth <= 0) return color(0, 0, 0);

        hit_record rec;

        if (world.hit(r, interval(0.001, infinity), rec)) {
            ray scattered;
            color attenuation;

            if (rec.mat->scatter(r, rec, attenuation, scattered)) {
                return attenuation * ray_color(scattered, depth - 1, world);
            }

            return color(0, 0, 0);

            // auto dir = rec.normal + random_unit_vector();
            // return 0.5 * ray_color(ray(rec.p, dir), depth - 1, world);
        }

        vec3 unit_dir = unit_vector(r.direction());
        auto a = 0.5 * (unit_dir.y() + 1.0);
        return (1 - a) * color(1.0, 1.0, 1.0) + a * color(0.2, 0.4, 1.0);
    }
};

#endif
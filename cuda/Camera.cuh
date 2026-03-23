#pragma once

#include "Color.cuh"
#include "CudaUtils.cuh"
#include "Material.cuh"
#include "Sphere.cuh"

class Camera {
    friend __global__ void render_kernel(curandState*, Color*, const Sphere*,
                                         int, const Camera*);

   public:
    float aspect_ratio = 1.0;    // ratio width / height
    int image_width = 100;       // width in no. of pixels
    int samples_per_pixel = 10;  // no. of samples to average for antialiasing
    int max_depth = 10;          // recursion depth for child rays

    float vfov = 90;  // vertical field of view (degrees)
    Point3 lookfrom = Point3(0, 0, 0);
    Point3 lookat = Point3(0, 0, -1);
    Vec3 vup = Vec3(0, 1, 0);  // camera-relative "up" direction

    float defocus_angle = 0;  // variation angle of rays through each pixel
    float focus_dist = 10;  // distance from lookfrom to plane of perfect focus

    void render(const Sphere* world, int num_objects) {
        initialize();
        std::cout << "P3\n" << image_width << " " << image_height << "\n255\n";

        std::clog << "Rendering...\n" << std::flush;
        Color *h_image, *d_image;
        curandState* states;

        h_image = (Color*)malloc(sizeof(Color) * image_width * image_height);
        cudaMalloc(&d_image, sizeof(Color) * image_width * image_height);
        cudaMalloc(&states, sizeof(curandState) * image_width * image_height);

        Sphere* d_world;
        cudaMalloc(&d_world, sizeof(Sphere) * num_objects);
        cudaMemcpy(d_world, world, sizeof(Sphere) * num_objects,
                   cudaMemcpyHostToDevice);

        Camera* d_cam;
        cudaMalloc(&d_cam, sizeof(Camera));
        cudaMemcpy(d_cam, this, sizeof(Camera), cudaMemcpyHostToDevice);

        dim3 threads(16, 16, 1);
        // dim3 blocks(cuda::ceil_div(image_width, 32),
        //             cuda::ceil_div(image_height, 32), 1);
        dim3 blocks((image_width + 15) / 16, (image_height + 15) / 16, 1);

        init_curand<<<blocks, threads>>>(states, 42, image_width, image_height);
        CUDA_CHECK(cudaGetLastError());
        CUDA_CHECK(cudaDeviceSynchronize());

        render_kernel<<<blocks, threads>>>(states, d_image, d_world,
                                           num_objects, d_cam);
        CUDA_CHECK(cudaGetLastError());
        CUDA_CHECK(cudaDeviceSynchronize());

        cudaDeviceSynchronize();
        cudaMemcpy(h_image, d_image, sizeof(Color) * image_width * image_height,
                   cudaMemcpyDeviceToHost);

        std::clog << "Rendering complete.\n" << std::flush;

        for (int j = 0; j < image_height; j++) {
            std::clog << "\rLines remaining: " << (image_height - j) << "   "
                      << std::flush;
            for (int i = 0; i < image_width; i++) {
                write_color(std::cout, pixel_samples_scale *
                                           h_image[INDX(i, j, image_width)]);
            }
        }
        std::clog << "\rDone.               \n" << std::flush;

        cudaFree(d_cam);
        cudaFree(d_world);
        cudaFree(states);
        cudaFree(d_image);
        free(h_image);
    }

   private:
    int image_height;           // height of rendered image
    Point3 center;              // camera center/origin
    Point3 pixel00_loc;         // location of pixel 0,0 (top left)
    Vec3 pixel_delta_u;         // offset to pixel right
    Vec3 pixel_delta_v;         // offset to pixel below
    float pixel_samples_scale;  // 1 / samples_per_pixel
    Vec3 u, v, w;               // camera frame basis vectors
    Vec3 defocus_disc_u;        // disc horizontal radius
    Vec3 defocus_disc_v;        // disc vertical radius

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
            viewport_height * (float(image_width) / image_height);

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

    // Construct a camera Ray originating from the defocus disk and directed at
    // a randomly sampled point around the pixel location i, j.
    HD Ray get_ray(int i, int j, curandState* state) const {
        auto offset = sample_square(state);
        auto pixel_sample = pixel00_loc + (i + offset.x()) * pixel_delta_u +
                            (j + offset.y()) * pixel_delta_v;

        auto ray_origin = (defocus_angle <= 0)
                              ? center
                              : defocus_disc_sample(
                                    state);  // camera center not square center
                                             // -- square center is pixel00_loc
        auto ray_dir = pixel_sample - ray_origin;

        return Ray(ray_origin, ray_dir);
    }

    HD Vec3 sample_square(curandState* state) const {
        // get random point on a unit square (-0.5 to +0.5 range)
        return Vec3(random_float(state) - 0.5, random_float(state) - 0.5, 0);
    }

    HD Point3 defocus_disc_sample(curandState* state = NULL) const {
        auto p = random_in_unit_disc(state);
        return center + (p[0] * defocus_disc_u) + (p[1] * defocus_disc_v);
    }

    HD Color ray_color(const Ray& r, int depth, const Sphere* world,
                       int num_objects, curandState* state) const {
        Color accumulated = Color(1.0f, 1.0f, 1.0f);
        Ray current_ray = r;

        for (int i = 0; i < depth; i++) {
            HitRecord rec;

            if (hit_world(world, num_objects, current_ray,
                          Interval(0.001f, Infinity), rec)) {
                Ray scattered;
                Color attenuation;

                if (scatter(current_ray, rec, attenuation, scattered, state)) {
                    accumulated = accumulated * attenuation;
                    current_ray = scattered;
                } else {
                    return Color(0, 0, 0);
                }
            } else {
                // background
                Vec3 unit_dir = unit_vector(current_ray.direction());
                float a = 0.5f * (unit_dir.y() + 1.0f);
                Color bg = (1 - a) * Color(1.0f, 1.0f, 1.0f) +
                           a * Color(0.2f, 0.4f, 1.0f);
                return accumulated * bg;
            }
        }

        return Color(0, 0, 0);
    };
};

__global__ void render_kernel(curandState* states, Color* d_image,
                              const Sphere* world, int num_objects,
                              const Camera* cam) {
    int tx = threadIdx.x;
    int ty = threadIdx.y;

    int i = tx + blockIdx.x * blockDim.x;
    int j = ty + blockIdx.y * blockDim.y;

    int image_width = cam->image_width;
    int image_height = cam->image_height;
    int samples_per_pixel = cam->samples_per_pixel;
    int max_depth = cam->max_depth;

    int idx = i + image_width * j;

    if (i >= image_width || j >= image_height) return;

    Color pixel_color = Color(0, 0, 0);

    for (int sample = 0; sample < samples_per_pixel; sample++) {
        Ray r = cam->get_ray(i, j, &states[idx]);
        pixel_color +=
            cam->ray_color(r, max_depth, world, num_objects, &states[idx]);
    }

    d_image[INDX(i, j, image_width)] = pixel_color;
}
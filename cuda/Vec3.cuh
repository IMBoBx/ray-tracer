#ifndef VEC3_CUH
#define VEC3_CUH

#include "RayTracer.cuh"

class Vec3 {
   public:
    float e[3];

    HD Vec3() : e{0, 0, 0} {}
    HD Vec3(float e1, float e2, float e3) : e{e1, e2, e3} {}

    HD float x() const { return e[0]; }
    HD float y() const { return e[1]; }
    HD float z() const { return e[2]; }

    HD Vec3 operator-() const {
        return Vec3(-e[0], -e[1], -e[2]);
    }
    HD float operator[](int i) const { return e[i]; }
    HD float& operator[](int i) { return e[i]; }

    HD Vec3 operator+=(const Vec3& v) {
        e[0] += v[0];
        e[1] += v[1];
        e[2] += v[2];
        return *this;
    }

    HD Vec3 operator*=(float t) {
        e[0] *= t;
        e[1] *= t;
        e[2] *= t;
        return *this;
    }

    HD Vec3 operator/=(float t) { return *this *= 1 / t; }

    HD float length_squared() const {
        return e[0] * e[0] + e[1] * e[1] + e[2] * e[2];
    }

    HD bool near_zero() const {
        auto s = 1e-8;
        return (std::fabs(e[0]) < s) && (std::fabs(e[1]) < s) &&
               (std::fabs(e[2]) < s);
    }

    // TODO: fix RNG functions
    // static Vec3 random() {
    //     return Vec3(random_double(), random_double(), random_double());
    // }

    // static Vec3 random(double min, double max) {
    //     return Vec3(random_double(min, max), random_double(min, max),
    //                 random_double(min, max));
    // }

    HD float length() const {
        return std::sqrt(length_squared());
    }
};

using Point3 = Vec3;

HD inline std::ostream& operator<<(std::ostream& out,
                                                    const Vec3& v) {
    return out << v.e[0] << ' ' << v.e[1] << ' ' << v.e[2];
}

HD inline Vec3 operator+(Vec3 u, const Vec3& v) {
    return Vec3(u.e[0] + v.e[0], u.e[1] + v.e[1], u.e[2] + v.e[2]);
}

HD inline Vec3 operator-(Vec3 u, const Vec3& v) {
    return Vec3(u.e[0] - v.e[0], u.e[1] - v.e[1], u.e[2] - v.e[2]);
}

HD inline Vec3 operator*(Vec3 u, const Vec3& v) {
    return Vec3(u.e[0] * v.e[0], u.e[1] * v.e[1], u.e[2] * v.e[2]);
}

HD inline Vec3 operator*(float t, const Vec3& v) {
    return Vec3(t * v.e[0], t * v.e[1], t * v.e[2]);
}

HD inline Vec3 operator*(const Vec3& v, float t) {
    return t * v;
}

HD inline Vec3 operator/(const Vec3& v, float t) {
    return (1 / t) * v;
}

HD inline Vec3 operator/(Vec3 u, const Vec3& v) {
    return Vec3(u.e[0] / v.e[0], u.e[1] / v.e[1], u.e[2] / v.e[2]);
}

HD inline float dot(const Vec3& u, const Vec3& v) {
    return u.e[0] * v.e[0] + u.e[1] * v.e[1] + u.e[2] * v.e[2];
}

HD inline Vec3 cross(const Vec3& u, const Vec3& v) {
    return Vec3(u.e[1] * v.e[2] - u.e[2] * v.e[1],
                u.e[2] * v.e[0] - u.e[0] * v.e[2],
                u.e[0] * v.e[1] - u.e[1] * v.e[0]);
}

HD inline Vec3 unit_vector(const Vec3& v) {
    return v / v.length();
}

// TODO: add the random utils
// random_unit_vector()
// random_on_hemisphere()
// random_in_unit_disc()

HD inline Vec3 reflect(const Vec3& v, const Vec3& n) {
    return v - 2 * n * dot(v, n);  // ASSUMING N IS UNIT VECTOR. IF NOT, DIVIDE
                                   // BY LENGTH(N).
}

HD inline Vec3 refract(const Vec3& uv, const Vec3& n,
                                        float eta_ratio) {
    auto cos_theta = std::fmin(dot(-uv, n), 1.0);
    Vec3 r_out_perp = eta_ratio * (uv + cos_theta * n);
    Vec3 r_out_parallel =
        -std::sqrt(std::fabs(1.0 - r_out_perp.length_squared())) * n;
    return r_out_perp + r_out_parallel;

#endif
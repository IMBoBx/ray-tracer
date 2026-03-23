#pragma once

#include "Color.cuh"

enum class MaterialType : int { Lambertian, Metal, Dielectric };

struct Material {
    MaterialType type;
    Color albedo;
    float fuzz;
    float ri;
};

package main

import "core:math"
import rand"core:math/rand"
import la"core:math/linalg"

Vec3 :: [3]f32
Point3 :: Vec3

vec3_random :: proc() -> Vec3 {
    return Vec3{rand.float32(), rand.float32(), rand.float32()}
}

vec3_random_range :: proc(min, max: f32) -> Vec3 {
    return Vec3{rand.float32_range(min, max), rand.float32_range(min, max), rand.float32_range(min, max)}
}

vec3_random_unit :: proc() -> Vec3 {
    for {
        v := vec3_random_range(-1, 1)
        lensq := la.vector_length2(v)
        if 1e-160 < lensq && lensq <= 1 {
            return v / math.sqrt(lensq)
        }
    }
}

vec3_random_on_hemisphere :: proc(normal: Vec3) -> Vec3 {
    on_unit_sphere := vec3_random_unit()
    // The dot product of two vectors shows the angle between them
    // If dot > 0 then the angle is less than 90 degrees
    // If dot == 0 then the vectors are perpendicular to each other
    // if dot < 0 then the angle is greater than 90 degrees 
    if la.vector_dot(on_unit_sphere, normal) > 0.0 {
        return on_unit_sphere
    } else {
        return -on_unit_sphere
    }
}

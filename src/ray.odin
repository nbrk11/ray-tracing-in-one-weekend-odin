package main

import "core:math"
import la"core:math/linalg"

Ray :: struct {
    origin : Point3,
    direction : Vec3
}

ray_at :: proc(r: Ray, t: f32) -> Point3 {
    return r.origin + t*r.direction
}


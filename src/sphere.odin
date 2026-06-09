package main

import "core:math"
import la"core:math/linalg"

Sphere :: struct {
    center: Point3,
    radius: f32
}

sphere_hit :: proc(self: ^Sphere, r: Ray, ray_t: Interval, rec: ^HitRecord) -> bool {
    oc := self.center - r.origin   
    a := la.length2(r.direction)
    h := la.vector_dot(r.direction, oc)
    c := la.length2(oc) - self.radius*self.radius
    discriminant := h*h - a*c

    if discriminant < 0.0 {
        return false
    }
    
    sqrtd := math.sqrt_f32(discriminant)
    root := (h - sqrtd) / a
    if !interval_surrounds(ray_t, root) {
        root := (h + sqrtd) / a
        if !interval_surrounds(ray_t, root) {
            return false
        }
    }

    rec.t = root
    rec.p = ray_at(r, rec.t)
    outward_normal := (rec.p - self.center) / self.radius
    set_face_normal(rec, r, outward_normal)

    return true
}

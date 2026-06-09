package main

import la"core:math/linalg"

HitRecord :: struct {
    p: Point3,
    normal: Vec3,
    t: f32,
    front_face: bool
}

Hittable :: union {
    Sphere
}

set_face_normal :: proc(h: ^HitRecord, r: Ray, outward_normal: Vec3) {
    h.front_face = la.vector_dot(r.direction, outward_normal) < 0 
    h.normal = h.front_face ? outward_normal : -outward_normal
}

hittable_array_hit :: proc(world: []Hittable, r: Ray, ray_t: Interval, rec: ^HitRecord) -> bool {
    temp_rec : HitRecord
    hit_anything := false
    closest_so_far := ray_t.max

    for obj in world {
        switch &s in obj {
            case Sphere: 
                if  sphere_hit(&s, r, Interval{ray_t.min, closest_so_far}, &temp_rec) {
                    hit_anything = true
                    closest_so_far = temp_rec.t
                    rec^ = temp_rec
                }
        }
    }

    return hit_anything
}

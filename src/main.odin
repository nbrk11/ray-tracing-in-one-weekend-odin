package main 

import "core:fmt"
import "core:math"
import la"core:math/linalg"

Vec3 :: [3]f32
Point3 :: Vec3
Color :: Vec3

INTERVAL_EMPTY :: Interval{math.INF_F32, math.NEG_INF_F32}
INTERVAL_UNIVERSE :: Interval{math.NEG_INF_F32, math.INF_F32}

Interval :: struct {
    min: f32,
    max: f32
}

interval_size :: proc(i: Interval) -> f32 {
    return i.max - i.min
}

interval_contains :: proc(i: Interval, x: f32) -> bool {
    return i.min <= x && i.max >= x
}

interval_surrounds :: proc(i: Interval, x: f32) -> bool {
    return i.min < x && i.max > x
}

HitRecord :: struct {
    p: Point3,
    normal: Vec3,
    t: f32,
    front_face: bool
}

set_face_normal :: proc(h: ^HitRecord, r: Ray, outward_normal: Vec3) {
    h.front_face = la.vector_dot(r.direction, outward_normal) < 0 
    h.normal = h.front_face ? outward_normal : -outward_normal
}

Hittable :: union {
    Sphere
}

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

//sphere_init :: proc(center: Point3, radius: f32) -> Sphere {
//    hittable := Hittable{sphere_hit}
//    sphere := Sphere{hittable, center, math.max(0.0, radius)}
//    return sphere
//}

Ray :: struct {
    origin : Point3,
    direction : Vec3
}

ray_at :: proc(r: Ray, t: f32) -> Point3 {
    return r.origin + t*r.direction
}

unit_vector :: proc(v: Vec3) -> Vec3 {
    return v/la.vector_length(v)
}

world_hit :: proc(world: []Hittable, r: Ray, ray_t: Interval, rec: ^HitRecord) -> bool {
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

ray_color :: proc(r: Ray, world: []Hittable) -> Color {
    // t := hit_sphere(Point3{0,0,-1}, 0.5, r)
    hit_record : HitRecord
    if world_hit(world, r, Interval{0, math.INF_F32}, &hit_record) {
        return 0.5*(hit_record.normal + Color{1,1,1})
    }
    // if t > 0.0 {
    //     N := unit_vector(ray_at(r, t) - Vec3{0,0,-1})
    //     color := 0.5*(N+1)
    //     return color
    // }

    unit_direction := unit_vector(r.direction)
    a := 0.5*(unit_direction.y + 1.0)
    return (1.0-a)*Color{1.0, 1.0, 1.0} + a*Color{0.5, 0.7, 1.0};
}

write_color :: proc(pixel_color : Color) {
    r := pixel_color.r
    g := pixel_color.g
    b := pixel_color.b

    ir := u8(255.999*r)
    ig := u8(255.999*g)
    ib := u8(255.999*b)

    fmt.printf("{0} {1} {2}\n", ir, ig, ib)
}

hit_sphere :: proc(center : Point3, radius : f32, r: Ray) -> f32 {
    oc := center - r.origin   
    a := la.length2(r.direction)
    h := la.vector_dot(r.direction, oc)
    c := la.length2(oc) - radius*radius
    discriminant := h*h - a*c

    if discriminant < 0.0 {
        return -1.0
    } else {
        return (h - math.sqrt_f32(discriminant)) / a
    }
}

main :: proc() {
    // Image 
    aspect_ratio : f32 = 16.0/9.0
    image_width : int = 400
    image_height := int(f32(image_width) / aspect_ratio)

    // World
    world := []Hittable{
        Sphere{{0,0,-1}, 0.5},
        Sphere{{0,-100.5,-1}, 100},
    }
    

    // Camera
    focal_length : f32 = 1.0
    viewport_height : f32 = 2.0
    vieport_width : f32 = viewport_height * f32(image_width) / f32(image_height)
    camera_center := Point3{ 0, 0, 0 }

    // Calculate vectors across the horizontal and the vertical edges
    viewport_u := Vec3{vieport_width, 0, 0}
    viewport_v := Vec3{0, -viewport_height, 0}

    // Calculate delta vectors between pixels
    pixel_delta_u := viewport_u / f32(image_width)
    pixel_delta_v := viewport_v / f32(image_height)

    // Calculate the location of the upper left pixel
    viewport_upper_left := camera_center - Vec3{0,0,focal_length} - viewport_u/2.0 - viewport_v/2.0
    pixel00_loc := viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v)

    // Render

    fmt.printf("P3\n{0} {1}\n255\n", image_width, image_height)

    for j := 0; j < int(image_height); j += 1 {
        fmt.eprintf("\rScanlines remaining: {0}", int(image_height)-j)
        for i := 0; i < image_width; i += 1 {
            pixel_center := pixel00_loc + (f32(i)*pixel_delta_u) + (f32(j)*pixel_delta_v)
            ray_direction := pixel_center - camera_center
            r := Ray{ camera_center, ray_direction }
            
            pixel_color := ray_color(r, world) // Color{ f32(i) / f32(image_width-1), f32(j) / f32(image_height-1), 0.0 }
            write_color(pixel_color)
        }
    }

    fmt.eprintf("\rDone.                                \n")

    return
}

package main

import "core:fmt"
import "core:math"
import rand"core:math/rand"
import la"core:math/linalg"

Camera :: struct {
    aspect_ratio: f32,
    image_width: i32,
    image_height: i32,
    samples_per_pixel: i32,
    center: Point3,
    pixel00_loc: Point3,
    pixel_delta_u: Vec3,
    pixel_delta_v: Vec3
}

ray_color :: proc(r: Ray, world: []Hittable) -> Color {
    hit_record : HitRecord
    if hittable_array_hit(world, r, Interval{0, math.INF_F32}, &hit_record) {
        direction := vec3_random_on_hemisphere(hit_record.normal)
        return 0.5*ray_color(Ray{r.origin, direction}, world)
        // return 0.5*(hit_record.normal + Color{1,1,1})
    }

    unit_direction := la.vector_normalize(r.direction)
    a := 0.5*(unit_direction.y + 1.0)
    return (1.0-a)*Color{1.0, 1.0, 1.0} + a*Color{0.5, 0.7, 1.0};
}

camera_render :: proc(camera: ^Camera, world: []Hittable) {
    c := camera
    camera_init(c)

    fmt.printf("P3\n{0} {1}\n255\n", c.image_width, c.image_height)

    for j := 0; j < int(c.image_height); j += 1 {
        fmt.eprintf("\rScanlines remaining: {0}", int(c.image_height)-j)
        for i := 0; i < int(c.image_width); i += 1 {
            pixel_color := Color{0,0,0}
            for sample := 0; sample < int(camera.samples_per_pixel); sample += 1 {
                r := camera_get_ray(camera^, i, j)
                pixel_color += ray_color(r, world)
            }
            write_color(camera_get_pixel_samples_scale(camera^) * pixel_color)
        }
    }

    fmt.eprintf("\rDone.                                \n")
}

camera_get_pixel_samples_scale :: proc(camera: Camera) -> f32 {
    return 1.0 / f32(camera.samples_per_pixel)
}

camera_init :: proc(camera: ^Camera) {
    camera.image_height = i32(f32(camera.image_width) / camera.aspect_ratio)

    // Determine viewport dimensions
    focal_length : f32 = 1.0
    viewport_height : f32 = 2.0
    vieport_width : f32 = viewport_height * f32(camera.image_width) / f32(camera.image_height)
    camera.center = Point3{ 0, 0, 0 }

    // Calculate vectors across the horizontal and the vertical edges
    viewport_u := Vec3{vieport_width, 0, 0}
    viewport_v := Vec3{0, -viewport_height, 0}

    // Calculate delta vectors between pixels
    camera.pixel_delta_u = viewport_u / f32(camera.image_width)
    camera.pixel_delta_v = viewport_v / f32(camera.image_height)

    // Calculate the location of the upper left pixel
    viewport_upper_left := camera.center - Vec3{0,0,focal_length} - viewport_u/2.0 - viewport_v/2.0
    camera.pixel00_loc = viewport_upper_left + 0.5 * (camera.pixel_delta_u + camera.pixel_delta_v)
}

camera_get_ray :: proc(camera: Camera, i, j : int) -> Ray {
    // Here we basically shoot a ray in a random space near our initial ray to see average color of pixel of surrounding pixels
    offset := sample_square()
    pixel_sample := camera.pixel00_loc + (f32(i) + offset.x) * camera.pixel_delta_u + (f32(j) + offset.y) * camera.pixel_delta_v
    ray_origin := camera.center
    ray_direction := pixel_sample - ray_origin

    return Ray{ray_origin, ray_direction}
}

sample_square :: proc() -> Vec3 {
    return Vec3{rand.float32() - 0.5, rand.float32() - 0.5, 0}
}

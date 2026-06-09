package main

import "core:fmt"
import la"core:math/linalg"

Vec3 :: [3]f32
Point3 :: Vec3
Color :: Vec3

Ray :: struct {
    origin : Point3,
    direction : Vec3
}

ray_at :: proc(r: Ray, t: f32) -> Point3 {
    return r.origin + t*r.direction
}

ray_color :: proc(r: Ray) -> Color {
    if hit_sphere(Point3{0,0,-1}, 0.5, r) {
        return Color{1,0,0}
    }

    unit_direction := la.vector_normalize(r.direction)
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

hit_sphere :: proc(center : Point3, radius : f32, r: Ray) -> bool {
    oc := center - r.origin   
    a := la.vector_dot(r.direction, r.direction)
    b := -2.0 * la.vector_dot(r.direction, oc)
    c := la.vector_dot(oc, oc) - radius*radius
    discriminant := b*b - 4*a*c

    return discriminant >= 0
}

main :: proc() {
    aspect_ratio : f32 = 16.0/9.0
    image_width : int = 400
    image_height := int(f32(image_width) / aspect_ratio)

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
            
            pixel_color := ray_color(r) // Color{ f32(i) / f32(image_width-1), f32(j) / f32(image_height-1), 0.0 }
            write_color(pixel_color)
        }
    }

    fmt.eprintf("\rDone.                                \n")

    return
}

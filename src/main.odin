package main

import "core:fmt"

Vec3 :: [3]f32
Point3 :: Vec3
Color :: Vec3

write_color :: proc(pixel_color : Color) {
    r := pixel_color.r
    g := pixel_color.g
    b := pixel_color.b

    ir := u8(255.999*r)
    ig := u8(255.999*g)
    ib := u8(255.999*b)

    fmt.printf("{0} {1} {2}\n", ir, ig, ib)
}

main :: proc() {
    IMAGE_WIDTH :: 256
    IMAGE_HEIGHT :: 256

    fmt.printf("P3\n{0} {1}\n255\n", IMAGE_WIDTH, IMAGE_HEIGHT)

    for j := 0; j < IMAGE_HEIGHT; j += 1 {
        fmt.eprintf("\rScanlines remaining: {0}", IMAGE_HEIGHT-j)
        for i := 0; i < IMAGE_WIDTH; i += 1 {
            pixel_color := Color{ f32(i) / (IMAGE_WIDTH-1), f32(j) / (IMAGE_HEIGHT-1), 0.0 }
            write_color(pixel_color)
        }
    }

    fmt.eprintf("\rDone.                                \n")

    return
}

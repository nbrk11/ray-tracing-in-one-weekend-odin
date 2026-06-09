package main

import "core:fmt"

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


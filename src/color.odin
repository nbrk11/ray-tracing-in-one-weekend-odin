package main

import "core:fmt"

Color :: Vec3

write_color :: proc(pixel_color : Color) {
    r := pixel_color.r
    g := pixel_color.g
    b := pixel_color.b

    intensivity := Interval{0.000, 0.999}
    // Clamping is needed here because of anti-aliasing
    // Because we are probing a lot of time the end color might be out of bounds of 1 byte
    // Therefore we need to clamp it to a maximum value of color
    ir := u8(256*interval_clamp(intensivity, r))
    ig := u8(256*interval_clamp(intensivity, g))
    ib := u8(256*interval_clamp(intensivity, b))

    fmt.printf("{0} {1} {2}\n", ir, ig, ib)
}


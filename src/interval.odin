package main

import "core:math"

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

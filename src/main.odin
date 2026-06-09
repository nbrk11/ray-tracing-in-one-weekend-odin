package main 

main :: proc() {
    // World
    world := []Hittable{
        Sphere{{0,0,-1}, 0.5},
        Sphere{{0,-100.5,-1}, 100},
    }

    // Camera
    camera := Camera{}
    camera.aspect_ratio = 16.0/9.0
    camera.image_width = 400
    camera_render(&camera, world)

    return
}

module rounded_cube(x, y, z, radius, center = false) {
    x1 = x - radius * 2;
    y1 = y - radius * 2;
    z1 = z - radius * 2;
    tr = center ? 0 : radius;
    
    /*
    intersection() {
        translate([radius, radius, 0])
            linear_extrude(height = z)
                offset(r = radius) square([x1, y1]);
    
        translate([radius, y, radius]) rotate([90, 0, 0])
            linear_extrude(height = y)
                offset(r = radius) square([x1, z1]);
        
        translate([0, radius, radius])
            rotate([90, 0, 0]) rotate([0, 90, 0])
                linear_extrude(height = x)
                    offset(r = radius) square([y1, z1]);
    }
    */
    
    translate([tr, tr, tr]) minkowski() {
        cube([x1, y1, z1], center = center);
        sphere(radius);
    }
}

//rounded_cube(40, 30, 20, 5);
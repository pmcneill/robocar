bearing_d = 8;
caster_screws = 39.5;
caster_w = 44;
caster_l = 20;

bump_r = 1.25;
cavity_r = bump_r + bearing_d / 2;

cap_screw = 20;

$fn = 15;

angles = [
    [-14, 13, 0],
    [-36.5, 11, 0],
    [-58, 7, 15],
    [-76, 3, 0]
];

module caster_top() {
    difference() {
        translate([0, 0, 2]) {
            minkowski() {
                scale([1, caster_l / caster_w, 1]) cylinder(r1 = caster_w / 2, r2 = 12, h = 3);
                sphere(2);
            }
        }
        
        sphere(cavity_r);

        translate([caster_screws / 2, 0, -5]) {
            cylinder(r = 1.5, h = 20);
            cylinder(r = 4, h = 6);
            translate([0, 0, 7]) cylinder(r = 3, h = 5, $fn = 6);
        }
        
        translate([-caster_screws / 2, 0, -5]) {
            cylinder(r = 1.5, h = 20);
            cylinder(r = 4, h = 6);
            translate([0, 0, 7]) cylinder(r = 3, h = 5, $fn = 6);
        }
        
        translate([-cap_screw / 2, 0, -5]) {
            cylinder(r = 1.4, h = 9);
        }
        translate([cap_screw / 2, 0, -5]) {
            cylinder(r = 1.4, h = 9);
        }
    }
    
    for ( layer = angles ) {
        rotate([0, 0, layer[2]]) {
            for ( a = [ 0 : (360 / layer[1]) : 359 ] ) {
                rotate([0, layer[0], a])
                    translate([cavity_r, 0, 0])
                        sphere(bump_r);
            }
        }
    }
}

module caster_bottom() {
    difference() {
        translate([0, 0, -2.5]) {
            scale([1, 0.7, 1])
                minkowski() {
                    cylinder(r1 = 6.5, r2 = 4 + cap_screw / 2, h = 2.1);
                    sphere(0.5);
                }
        }
        
        sphere(cavity_r);
        
        translate([-cap_screw / 2, 0, -10]) {
            cylinder(r = 1.5, h = 20);
            cylinder(r  = 4, h = 9);
        }

        translate([cap_screw / 2, 0, -10]) {
            cylinder(r = 1.5, h = 20);
            cylinder(r  = 4, h = 9);
        }
    }
    
    for ( a = [ 0 : (360 / angles[0][1]) : 359 ] ) {
        rotate([0, -angles[0][0], a])
            translate([cavity_r, 0, 0])
                sphere(bump_r);
    }
}

//rotate([180, 0, 0]) caster_top();

rotate([180, 0, 0]) caster_bottom();
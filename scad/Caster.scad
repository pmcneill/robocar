bearing_d = 10;
caster_screws = 39.5;
caster_w = 44;
caster_l = 20;

bump_r = 1.25;
cavity_r = bump_r + bearing_d / 2;

cap_screw = 17.5;

$fn = 15;

angles = [
    [-14, 16, 0],
    [-35, 13, 0],
    [-54, 9, 0],
    [-70, 5, 0],
    [-90, 1, 0]
];

module bumps() {
    intersection() {
        sphere(cavity_r + 0.1);
        
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
}

module caster_top() {
    difference() {
        hull() {
            translate([caster_screws / 2 - 1, 0, cavity_r + 1])
                cylinder(r = 5, h = 1);

            translate([-caster_screws / 2 + 1, 0, cavity_r + 1])
                cylinder(r = 5, h = 1);
           
            scale([1.5, 1, 1]) cylinder(r = cavity_r + 1.5, h = 2);
        }

        sphere(cavity_r);

        translate([caster_screws / 2, 0, 0]) {
            cylinder(r = 1.55, h = 20);
            cylinder(r = 4, h = cavity_r + 1);
        }
        
        translate([-caster_screws / 2, 0, 0]) {
            cylinder(r = 1.55, h = 20);
            cylinder(r = 4, h = cavity_r + 1);
        }
        
        translate([-cap_screw / 2, 0, -5]) {
            cylinder(r = 1.4, h = 9);
        }
        translate([cap_screw / 2, 0, -5]) {
            cylinder(r = 1.4, h = 9);
        }
    }
    
    bumps();
}

module caster_bottom() {
    union() {
        difference() {
            translate([0, 0, -2.5]) {
                scale([1.5, 1, 1])
                    minkowski() {
                        cylinder(r1 = 5.5, r2 = cap_screw / 2 - 1.5, h = 2.1);
                        sphere(0.5);
                    }
            }
            
            sphere(cavity_r);
        }
        
        difference() {
            translate([0, 0, -3])
                linear_extrude(height = 1) circle(5.5);
            
            sphere(5.3);
        }
        
        intersection() {
            sphere(cavity_r + 0.1);
    
            for ( a = [ 0 : (360 / angles[0][1]) : 359 ] ) {
                rotate([0, -angles[0][0], a])
                    translate([cavity_r, 0, 0])
                        sphere(bump_r);
            }
        }

        translate([-cap_screw / 2, 0, 0]) {
            cylinder(r1 = 1.1, r2 = 0.75, h = 2);
        }

        translate([cap_screw / 2, 0, 0]) {
            cylinder(r1 = 1.1, r2 = 0.75, h = 2);
        }
    }
}

rotate([180, 0, 0]) caster_top();
%sphere(bearing_d / 2);

//caster_bottom();
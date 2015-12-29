include <Lego Modular.scad>
include <Rounded Cube.scad>

$fn = 25;
epi = 0.1;

thick = 3;

body_w = 112;
body_l = 128;

motor_h = 22.7 + epi;
motor_w = 18.6 + epi;
motor_l = 64;
motor_screw_r = 1.5 + epi;
motor_top_screw_y = motor_h - 2.6;
motor_bot_screw_y = motor_h - 20;
motor_screw_x = 31.3;
motor_axle_x = 12.5;
motor_axle_y = motor_h / 2;
motor_axle_w = 37;
motor_axle_r = 2.8;
motor_nub_r = 2 + epi;
motor_nub_x = 22.7;
motor_nub_y = motor_axle_y;

//battery_w = 66;
battery_w = 3.2 * 26;
battery_h = brick_h * 3 - thick;
battery_l = 100;

wheel_r = 33;
wheel_w = 26;

castor_w = 39.5; // screw hole to hole
castor_l = 33;

module right_motor() {
  translate([-motor_w / 2, 0, 0])
    union() {
        union() {
            cube([motor_w, motor_l, motor_h]);
            
            translate([-(motor_axle_w - motor_w) / 2, motor_axle_x, motor_axle_y])
                rotate([0, 90, 0])
                    cylinder(r = motor_axle_r, motor_axle_w);
            
            translate([-4, motor_nub_x, motor_nub_y])
                rotate([0, 90, 0])
                    cylinder(r = motor_nub_r + 0.3, h = 4.5);
        }
        
        translate([-10, motor_screw_x, motor_top_screw_y])
            rotate([0, 90, 0])
                cylinder(r = motor_screw_r, h = motor_w + 20);

        translate([-10, motor_screw_x, motor_bot_screw_y])
            rotate([0, 90, 0])
                cylinder(r = motor_screw_r, h = motor_w + 20);

        translate([22, motor_screw_x, motor_top_screw_y])
            rotate([0, 90, 0]) rotate([0, 0, 30])
                cylinder(r = 3.5, h = 10, $fn = 6);

        translate([22, motor_screw_x, motor_bot_screw_y])
            rotate([0, 90, 0]) rotate([0, 0, 30])
                cylinder(r = 3.5, h = 10, $fn = 6);
    }
}

module left_motor() {
    mirror([1, 0, 0]) right_motor();
}

module wheel() {
    translate([-wheel_w / 2, 0, 0])
        rotate([0, 90, 0]) cylinder(r = wheel_r, h = wheel_w);
}

module ghost_parts() {
    translate([body_w / 2 + 3, -20, - motor_h / 2 - 0.75]) wheel();
    translate([-body_w / 2 - 3, -20, - motor_h / 2 - 0.75]) wheel();
    
    translate([body_w / 2 - motor_w -5, -20 - motor_axle_x, -motor_h - 0.75]) left_motor();
    translate([-body_w / 2 + motor_w + 5, -20 - motor_axle_x, -motor_h - 0.75]) right_motor();
    
}

module lower_plate() {
    difference() {
        union() {
            translate([-60, -body_l / 2 - 10, 0])
                rounded_cube(120, body_l + 10, thick, 1);
            
            // inner motor mounts
            hull() {
                translate([-22.5, -9, -motor_h - 2])
                    cube([5, 16, motor_h + 3]);
                
                translate([-17, -6, -3])
                    cube([5, 10, 4]);
            }

            hull() {
                translate([17.5, -9, -motor_h - 2])
                    cube([5, 16, motor_h + 3]);
                
                translate([12, -6, -3])
                    cube([5, 10, 4]);
            }
         
            // outer motor mounts
            translate([-body_w / 2 + wheel_w / 2 - 2, -6, -motor_h - 2])
                cube([3, 10, motor_h + 3]);
            translate([-body_w / 2 + wheel_w / 2 - 2, -14, -motor_h / 2 - 1])
                cube([3, 10, motor_h / 2 + 2]);
            
            translate([body_w / 2 - wheel_w / 2 - 1, -6, -motor_h - 2])
                cube([3, 10, motor_h + 3]);
            translate([body_w / 2 - wheel_w / 2 - 1, -14, -motor_h / 2 - 1])
                cube([3, 10, motor_h / 2 + 2]);
            
            // bottom-side bumps
            translate([0, body_l / 2 - unit, 0.75]) rotate([180, 0, 0])
                bumps(14, 2);

            translate([0, -body_l / 2 + unit * 2, 0.75]) rotate([180, 0, 0])
                bumps(8, 2);

            translate([0, -body_l / 2, 0.75]) rotate([180, 0, 0])
                bumps(14, 2);
            
            translate([5 * unit, body_l / 2 - unit * 3, 0.75])
                rotate([180, 0, 0])
                    bumps(4, 2);
            translate([-5 * unit, body_l / 2 - unit * 3, 0.75])
                rotate([180, 0, 0])
                    bumps(4, 2);
        }
        
        translate([-body_w / 2 - 20, -55, -3])
            cube([wheel_w / 2 + 18, 70, 10]);

        translate([body_w / 2 - wheel_w / 2 + 2, -55, -3])
            cube([wheel_w / 2 + 20, 70, 10]);
        
        translate([-12, -35, -3])
            cube([24, 70, 10]);
        
        translate ([0, 0, -3]) {
            translate([0, 44, 0]) {
                for ( x = [-castor_w / 2 : unit : castor_w / 2 + unit] ) {
                    translate([x, 0, 0])
                        cylinder(r = 1.8, h = 10);
                }
            }
            
            for ( x = [-18, 18] ) {
                for ( y = [-unit * 4.5 : unit : 40] ) {
                    if ( y > 10 || y < -10 ) {
                    translate([x, y, 0])
                        cylinder(r = 1.4, h = 10);
                    }
                }
            }
            
            for ( x = [-41, 41] ) {
                for ( y = [-unit * 6.5 : unit : 30] ) {
                    if ( y > 10 || y < -12 ) {
                    translate([x, y, 0])
                        cylinder(r = 1.8, h = 10);
                    }
                }
            }
            
            translate([-49, 28, 0]) cylinder(r = 1.8, h = 10);
            translate([-49, 20, 0]) cylinder(r = 1.8, h = 10);
            translate([49, 28, 0]) cylinder(r = 1.8, h = 10);
            translate([49, 20, 0]) cylinder(r = 1.8, h = 10);
        }
        
        translate([0, 0, thick - 0.8]) {
            translate([-37, -65, 0]) {
                cube([15, 103, 2]);
                cube([10, 120, 2]);
            }
            translate([22, -65, 0]) {
                cube([15, 103, 2]);
                translate([5, 0, 0]) cube([10, 120, 2]);
            }
            translate([-18, -65, 0]) cube([36, 10, 2]);
            translate([-18, -51, 0]) cube([36, 10, 2]);
            
            translate([-23, 49, 0]) cube([46, 6, 2]);
            
            translate([-53, 33, 0]) cube([12, 22, 2]);
            translate([41, 33, 0]) cube([12, 22, 2]);
        }

        ghost_parts();
    }
}
/*
rotate([180, 0, 0])
union() {
    lower_plate();
    
    difference() {
        union() {
            translate([-55, 48, 2])
                cylinder(r = 16, h = 3.35);
            translate([55, 48, 2])
                cylinder(r = 16, h = 3.35);
        }
        cube([14 * unit, 16 * unit, 30], center = true);
    }
    
    difference() {
        union() {
            translate([-43, -48, 2])
                scale([1.5, 1, 1])
                cylinder(r = 16, h = 3.35);
            translate([43, -48, 2])
                scale([1.5, 1, 1])
                cylinder(r = 16, h = 3.35);
        }
        cube([14 * unit - wheel_w + 3, 16 * unit, 30], center = true);
    }

}
*/

//%ghost_parts();


rotate([180, 0, 0]) lower_plate();

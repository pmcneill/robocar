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

module motor_posts() {
    cylinder(r = 1.4, h = 20);
    translate([0, 44, 0]) cylinder(r = 1.4, h = 20);
  //  translate([28, 0, 0]) cylinder(r = 1.4, h = 20);
    translate([15, 44, 0]) cylinder(r = 1.4, h = 20);
}

module upper_plate() {
    difference() {
        union() {
            translate([-60, -body_l / 2 - 10, 0])
                rounded_cube(120, body_l + 10, thick, 1);
            
            // bottom-side bumps
            translate([0, body_l / 2 - unit, 0.75]) rotate([180, 0, 0])
                bumps(14, 2);

            translate([0, -body_l / 2 + unit * 2, 0.75]) rotate([180, 0, 0])
                bumps(9, 2);

            translate([0, -body_l / 2, 0.75]) rotate([180, 0, 0])
                bumps(14, 2);
            
            translate([-3.5 * unit, -unit * 0.5, 0.75]) rotate([180, 0, 0])
                bumps(2, 9);
            
            translate([3.5 * unit, -unit * 0.5, 0.75]) rotate([180, 0, 0])
                bumps(2, 9);

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
                    if ( x == 18 || (y > -30 && y != 4 ) ) {
                        translate([x, y, 0])
                            cylinder(r = 1.4, h = 10);
                    }
                }
            }
            
            
            for ( x = [-41, 41] ) {
                for ( y = [-unit * 6.5 : unit : 30] ) {
                    translate([x, y, 0])
                        cylinder(r = 1.8, h = 10);
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
    }
}

difference() {
rotate([180, 0, 0]) upper_plate();

translate([-16, -5.5, -10]) motor_posts();
}


include <Lego Modular.scad>

$fn = 25;

module switch() {
    difference() {
        cube([20, 15.5, 7]);
        translate([5.5, 7.5, -1]) cylinder(r = 1.5, h = 20);
        translate([14.5, 7.5, -1]) cylinder(r = 1.5, h = 20);
    }
}

module cut_me() {
    difference() {
        lego(5,3,2,true);
        translate([-15, -12.1, 6]) cube([30, 17, 9]);
        translate([10, -9.1, 8]) cylinder(r = 1.5, h = 9);
        
        translate([-10, 0, 9.5]) {
            rotate([-90, 0, 0]) {
                cylinder(r1 = 3, r2 = 1.25, h = 13);
                translate([6.5, 0, 0]) cylinder(r1 = 3, r2 = 1.25, h = 13);
//                translate([13, 0, 0]) cylinder(r1 = 3, r2 = 1.25, h = 13);
            }
        }
    }
    
    translate([-8.5, -6.1, 5]) {
        cylinder(r = 1.05, h = 6);
        translate([9.5, 0, 0]) cylinder(r = 1.05, h = 6);
    }
    
    translate([10, -9.1, 5]) cylinder(r1 = 1, r2 = 0.8, h = 2.2);
}

module splitter(ofs = 0) {
    translate([-100, -100, -1]) cube([200, 200, 15.99]);
    translate([-17.5, -8, 14.5]) cylinder(r = 1.5 - ofs, h = 1.8 - ofs * 1.5);
    translate([-17.5, 8, 14.5]) cylinder(r = 1.5 - ofs, h = 1.8 - ofs * 1.5);
    translate([17.5, -8, 14.5]) cylinder(r = 1.5 - ofs, h = 1.8 - ofs * 1.5);
    translate([17.5, 8, 14.5]) cylinder(r = 1.5 - ofs, h = 1.8 - ofs * 1.5);
}

intersection() {
    cut_me();
    splitter(0.5);
}

translate([0, 40, -14.99]) {
    difference() {
        cut_me();
        splitter();
    }
}

/*
module arm() {
    hull() {
        cube([50, 8, 2]);
        rotate([-90, 0, 0]) cylinder(r = 1.25, h = 8);
    }
    translate([0, -1.35, 0])
        rotate([-90, 0, 0]) cylinder(r = 1.25, h = 10.7);
}

translate([0, -40, 2]) rotate([0, 180, 0]) arm();
*/

arm_h = 8.5;
arm_offset = 6;

module arm() {
    difference() {
        union() {
            hull() {
                cylinder(r = 2, h = arm_h);
                translate([0, 2, 1]) cylinder(r = 2, h = arm_h - 2);
                translate([25, 0, 0]) cylinder(r = 1.4, h = arm_h - 1);
                translate([25, 0.75, 1]) cylinder(r = 1.4, h = arm_h - 2);
            }
            
            translate([25, 0, 0]) rotate([0, 0, -25]) hull() {
                cylinder(r = 1.4, h = arm_h - 1);
                translate([0, 0.75, 1]) cylinder(r = 1.4, h = arm_h - 2);

                translate([25, 0, 0]) cylinder(r = 1.25, h = arm_h - 2);
            }
            
            hull() {
                cylinder(r = 2, h = arm_h);
                translate([2, 0, 0]) cylinder(r = 2, h = arm_h);
                translate([0, -arm_offset, 0]) cylinder(r = 1.8, h = arm_h);
                translate([0, -arm_offset, 1]) cylinder(r = 2.5, h = arm_h - 2);
            }
            
            translate([0, -arm_offset, arm_h - 0.1]) cylinder(r1 = 1, r2 = 0.8, h = 1);
        }
        
        translate([0, -arm_offset, -1]) cylinder(r = 1.4, h = 2);
    }
}

translate([40, 20, 0]) arm();

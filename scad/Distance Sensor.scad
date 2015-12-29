include <Lego Modular.scad>

$fn = 50;

module sensor_mock() {
    rotate([0, -90, 180])
    difference() {
        union() {
            translate([0, -22.5, 0]) cube([20, 45, 1.2]);
            translate([10, -13.5, 0]) cylinder(r = 8, h = 15);
            translate([10, 13.5, 0]) cylinder(r = 8, h = 15);
        }
        
        translate([2.5, 20, -1]) cylinder(r = 1.7, h = 4);
        translate([17.5, -20, -1]) cylinder(r = 1.7, h = 4);
    }
}

module post(height=6) {
    cylinder(h=height, r1 = 5, r2 = 3.5);
}

module screw(height=6) {
    difference() {
        post(height);
        translate([0,0,1]) cylinder(h=height, r=0.8);
    }
}

union() {
    difference() {
        lego(2, 8, shallow_p = 1, height = 4);
        translate([-3, -23.5, 9]) cube([20, 47, 22]);
        translate([-5, -5, 4]) cube([7, 10, 6]);
        translate([-15, -5, 4]) cube([11, 10, 4.5]);
    }
    translate([-3, -20, 12]) rotate([0, 90, 0]) screw(3);
    translate([-3, -20, 27]) rotate([0, 90, 0]) screw(3);
    translate([-3, 20, 12]) rotate([0, 90, 0]) screw(3);
    translate([-3, 20, 27]) rotate([0, 90, 0]) screw(3);
}

//%translate([0, 0, 9.5]) sensor_mock();


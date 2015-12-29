include <Lego Modular.scad>

$fn = 50;

union() {
    translate([0, 0, 1.5]) cube([16, 16, 3], center = true);
    translate([0, 0, 2.25]) bumps(2,2);
    translate([7, -7, -1]) cube([1, 14, 1.1]);
    translate([3, -7, -1]) cube([1, 14, 1.1]);
    translate([-1, -7, -1]) cube([1, 14, 1.1]);
    translate([-5, -7, -1]) cube([1, 14, 1.1]);
    translate([-8, -7, -1]) cube([1, 14, 1.1]);
}

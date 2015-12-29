include <Lego Modular.scad>

$fn = 25;

difference() {
    lego(5,2,1,true);
    
    translate([0, 0, 5.5]) cube([100, 10.5, 4], center = true);
}

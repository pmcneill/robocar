rounded_p = false;

brick_h = 9.6;
unit = 8;
bump_h = 1.8;
bump_r = 2.4;
wall = 1.5;
cyl_wall = 1;
top_depth = 1.5;
cyl_r = (unit * sqrt(2) - 2 * bump_r) / 2;

gap = 0;  // this is wrong -- makes the base gaps smaller, not larger
gaps = 2 * gap;

module brick(bumps_x, bumps_y, height = 1, shallow_p = 0) {
    l = unit * bumps_x - gaps;
    w = unit * bumps_y - gaps;
    h = height * brick_h;
    
    h_offset = ( shallow_p == 0 ) ? -top_depth : (1.2 * bump_h + gaps - h);

    difference() {
        // outside box
        translate([-l / 2, -w / 2 ,0]) {
            cube([l, w, h]);
        }
        
        // inside cut
        translate([
            -(l - gaps - 2 * wall) / 2,
            -(w - gaps - 2 * wall) / 2,
            h_offset
        ]) {
            cube([
                l - gaps - 2 * wall,
                w - gaps - 2 * wall,
                h
            ]);
        }
    }
}

module bumps(bumps_x, bumps_y) {
    translate([(-1 - bumps_x) * unit / 2, (-1 - bumps_y) * unit / 2, 0])
        for (x = [1 : bumps_x], y = [1 : bumps_y]) {
            translate([x * unit, y * unit, 0]) {
                intersection() {
                    cylinder(r = bump_r, h = bump_h + top_depth / 2);
                    if ( rounded_p ) {
                        sphere(bump_h + top_depth);
                    }
                }
            }
        }
}

module base(bumps_x, bumps_y, height = 1, shallow_p = 0) {
    h = shallow_p ? (1.5*bump_h + gaps + cyl_wall) : ((height * brick_h) - top_depth);

   	if (bumps_x > 1 && bumps_y > 1) {
		translate([
			(-bumps_x) * unit / 2,
			(-bumps_y) * unit / 2,
			0
		]) {
			for (x = [1 : bumps_x - 1], y = [1 : bumps_y - 1]) {
				translate([x * unit, y * unit, 0]) {
					difference() {
						cylinder(r = cyl_r, h = h + 0.02);
						translate([0, 0, -1 - cyl_wall]) {
							cylinder(r = cyl_r - cyl_wall, h = h + 1);
						}
					}
				}
			}
		}
	}
}

module lego(bumps_x, bumps_y, height = 1, shallow_p = 0) {
    brick(bumps_x, bumps_y, height, shallow_p);

    translate([0, 0, (brick_h * height) - top_depth / 2	])
        bumps(bumps_x, bumps_y);

    base(bumps_x, bumps_y, height, shallow_p);
}

//lego(6, 2, shallow_p = 0, height = 2);
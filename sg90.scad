include <BOSL2/std.scad>

// SG90 Micro Servo
module sg90(anchor=CENTER, spin=0, orient=TOP) {
  base = [23, 12.6, 22.5];    // Main body
  flange = [32.4, 12.6, 2.4]; // Flange for screw fastening
  gh = 29.2 - 26.7;           // Height of the gear
  th = 26.7 - 22.5;           // Height of the cylinder on the main body
  X = 5;                      // Arbitrary value

  attachable(anchor, spin, orient, size=base) {
    recolor("blue") {
      // Stack main body → Cylindrical top case → Gear
      cuboid(base, rounding=0.5, edges="Z")  // Main body
        attach(TOP, BOTTOM, align=RIGHT) {
          cylinder(h=th, d=base.y)           // Top case
            attach(TOP, BOTTOM)
              color("white") difference() {
                cylinder(h=gh,   d=4.6); // Gear
                cylinder(h=gh+X, d=1.8); // Gear holle
              }
          // The top case has an R=2.5 with a protrusion of 1.9mm.
          left(base.y-5+1.9) cylinder(h=th, d=5);
        }

      // Flange for screw fastening at 15.8mm from the bottom end of
      // the main body.
      up(-base.z/2 + flange.z/2 + 15.8) difference() {
        // Flange
        cuboid(flange, rounding=0.5, edges="Z");

        // Place keyhole-shaped cutouts with a diameter of φ2.1
        // centered at ±27.8/2 from the center.
        for (i=[-1,1])
          translate([i*27.8/2, 0, 0]) rotate([0, 0, -i*90]) union() {
            cylinder(h=X, d=2.1, center=true);
            translate([0, X/2, 0]) cube([1.2, X, X], center=true);
          }
      }
    }
    children();
  }
}

// Demo
$fn = 64;
cuboid([50, 50, 1.6]) attach(TOP,FRONT, align=BACK) sg90();

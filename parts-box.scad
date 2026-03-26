include <BOSL2/std.scad>

// * SOP IC PIN
//
// :     z2      r                         x1
// : <--------><--->                <--------------->
// :
// : +---------.                    +---------------+
// : |            .                 |               |
// : +-------.     |                +===============+  <|
// :          .    |                |               |   |
// :          |    |                |               |   |
// :          |    |                |               |   |
// :          |    |                |               |   |
// :          |    |                |               |   |
// :          |    |                |               |   |
// :          | z1 |                |               |   | y1
// :          +----+                +       +       +   |
// :          |    |                |               |   |
// :          |    |                |               |   |
// :          |    |                |               |   |
// :          |    |                |               |   |
// :          |    |                |               |   |
// :          |    .                +===============|  <|
// :          |     .               |               |
// :          .       ------+       +---------------+
// :           .            |       |               |
// :               ---------+       +---------------+
// :          <---><-------->
// :            r      z3
//
module sop_pin() {
  // Base pin figure
  x1 = 0.4;
  y1 = 0.5;
  z1 = 0.2;
  z2 = 0.2;
  z3 = 0.4;
  r = 0.2;

  color("silver") {
    cube([x1, y1, z1], center=true);

    translate([0, y1/2, 0])
      rotate([0, -90, 0])
        translate([-r, 0, 0])
          rotate_extrude(90)
            translate([r, 0, 0])
              square([z1, x1], center=true);
    translate([0, r+y1/2, -z2/2-r]) cube([x1, z1, z2], center=true);

    translate([0, -y1/2, 0])
      rotate([0, 90, 0])
        translate([-r, 0, 0])
          rotate_extrude(-90)
            translate([r, 0, 0])
              square([z1, x1], center=true);
    translate([0, -(r+y1/2), z3/2+r]) cube([x1, z1, z3], center=true);
  }
}

// * DIP IC PIN
//
// :    z2    r                    x1
// : <-----><--->           <--------------->
// :
// : +------------.         +---------------+
// : |          O  . <|     |       O       |  <|
// : +-------.     |  | r   |- - - - - - - -|   | r
// :          .    | <|     +===============+  <|
// :          |    |        |               |   |
// :          |    |        |               |   |
// :          |    |        |               |   | y1
// :          |    |        |               |   |
// :          |    |        |               |   |
// :          |    |        |               |   |
// :          +----+        +----+     +----+  <|
// :          |    |             |     |        |
// :          |    |             |     |        |
// :          |    |             |     |        |
// :          |    |             |     |        | y2
// :          |    |             |     |        |
// :          |    |             |     |        |
// :          |    |             |     |        |
// :          +----+             +-----+       <|
// :          <--->              <----->
// :            z1                 x2
//
module dip_pin() {
  // Base pin figure
  x1 = 1.52;
  y1 = 1.66;
  z1 = 0.29;
  x2 = 0.46;
  y2 = 3.3;
  z2 = 0.5;
  r = 0.5;

  down(y1/2+r) rotate([90, 0, 0]) color("silver") {
    cube([x1, y1, z1], center=true);
    translate([0, -(y1+y2)/2, 0]) cube([x2, y2, z1], center=true);

    translate([0, y1/2, 0])
      rotate([0, -90, 0])
        translate([-r, 0, 0])
          rotate_extrude(90)
            translate([r, 0, 0])
              square([z1, x1], center=true);

    translate([0, y1/2+r, -z2/2-r]) cube([x1, z1, z2], center=true);
  }
}

// Bottom 6.4x19.75  TOP 5.9x19.25
// https://toshiba.semicon-storage.com/us/semiconductor/design-development/package/dip.html
module dip_body(n=16) {
  // 16, 18, 20
  // pins_to_size = [[19.25, 6.4], [22, 6.4], [24.6, 6.4]];

  // normal: Width: 250mil, Length: 100 mil * N / 2
  // wide: Width: 500mil Length: 100 mil * N / 2
  size1 = [n/2*2.54, 2.5*2.54];
  size2 = size1 + [0.5, 0.5];
  h = 3.5;

  color("#444444") {
    prismoid(size2, size1, h=h/2);
    down(h/2) prismoid(size1, size2, h=h/2);
  }
}

module sop_body(n=16) {
  // width = [150, 208, 300];
  // 16, 18, 20
  // pins_to_size = [[10, 3.84], [22, 6.4], [24.6, 6.4]];
  size1 = [(n/2 - 1) * 1.27 + 1, 150*25.4/1000];
  size2 = size1 + [0.3, 0.3];
  h = 1.45;

  difference() {
    color("#444444") {
      union() {
        prismoid(size2, size1, h=h/2);
        down(h/2) prismoid(size1, size2, h=h/2);
      }
    }
    translate([-size1.x/2 + 0.55, -size1.y/2 + 0.8, h/2 - 0.1])
      color("#666666") cylinder(h=0.5, r=0.3, $fn=20);
  }
}

module sop(n=16) {
  sop_body(n);
  offset = 2.54;
  down(0.45) {
    for (i=[1:n/2]) {
      left(1.27*(i-n/4)-1.27/2) {
        fwd(offset) xrot(90) sop_pin();
        back(offset) zrot(180) xrot(90) sop_pin();
      }
    }
  }
}

module dip(n=16) {
  dip_body(n);
  offset = 2.54*1.5;
  for (i=[1:n/2]) {
    left(2.54*(i-n/4)-1.27) {
      fwd(offset) dip_pin();
      back(offset) zrot(180) dip_pin();
    }
  }
}

// * pcb
module pcb(size, rounding=0, mh_d, mh_inset, color="green",
           anchor=CENTER, spin=0, orient=UP) {

  attachable(anchor, spin, orient, size=size) {
    color(color) difference() {
      cuboid(size, rounding=rounding, edges="Z");
      if (!is_undef(mh_d)) {
        inset = is_undef(mh_inset) ? mh_d : mh_inset;
        dx = size.x/2 - inset;
        dy = size.y/2 - inset;

        for (xs = [-1,1], ys = [-1,1]) {
          translate([dx*xs, dy*ys, -size.z])
            cylinder(size.z * 2, d=mh_d);
        }
      }
    }
    children();
  }
}

// * spacer
//
//   A square-shaped pole with a cylinder-hole.
//
// * Arguments:
//   + size: [w, d, h]
//   + d: diameter of the cylinder
//   + invert: If true, generates a cylinder while bounding-box is same
//     as the pole.
//   + Other arguments conform to attachment.
//
module spacer(size, d=3, invert=false,
              anchor=CENTER, spin=0, orient=UP) {

  attachable(anchor, spin, orient, size=size) {
    if (invert)
      cylinder(h=size.z, d=d, center=true);
    else
      difference() {
        cube(size, center=true);
        cylinder(h=size.z+1, d=d, center=true);
      }
    children();
  }
}

$fn = 64;

CORNERS = [RIGHT+BACK, RIGHT+FRONT, LEFT+BACK, LEFT+FRONT];

// Akizuki universal PCB type-C + 10mm spacer
pcb([72, 47.5, 1.6], mh_d=3, mh_inset=3)
  attach(TOP,BOTTOM, align=CORNERS) spacer([6,6,10], d=3);

up(5) dip(14);
up(1.8) left(20) sop(8);

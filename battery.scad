include <BOSL2/std.scad>

// Lithium coin battery CR250
module cr2450(anchor=CENTER, spin=0, orient=UP) {
  CRxxxx(d=24.5, h=5, d2=22, h2=0.9, anchor=CENTER, spin=0, orient=UP)
    children();
}

// Lithium coin battery CR2032
module cr2032(anchor=CENTER, spin=0, orient=UP) {
  CRxxxx(d=20, h=3.2, d2=16, h2=0.5, anchor=CENTER, spin=0, orient=UP)
    children();
}

module CRxxxx(d, h, d2, h2, anchor, spin, orient) {
  attachable(anchor, spin, orient, d=d, h=h) {
    translate([0,0,-h/2])
      color("silver") {
        cylinder(d=d, h=h-h2);
        translate([0,0,h-h2]) cylinder(d1=d, d2=d2, h=h2);
      }
    children();
  }
}

// AAA battey
module battery_aaa(anchor=CENTER, spin=0, orient=UP) {
  main_d = 10.15;  // 10.5 - 9.8
  main_h = 44;

  top_d = 3.8;
  top_h = 0.8;

  bot_d = 4.3;
  bot_h = 0.1;

  total_h = main_h + top_h + bot_h;
  centroid = [0, 0, (top_h - bot_h)/2];

  attachable(anchor, spin, orient, d=main_d, h=total_h) {
    // XXX centroid is offset
    translate(-centroid) {
      // Main cylinder
      color("gold")
        cylinder(d=main_d, h=main_h, center=true);

      // Top "+" pole
      color("silver")
        translate([0, 0, main_h/2 + top_h/2])
          cylinder(d=top_d, h=top_h, center=true);

      // Bottom "-" pole
      color("silver") translate([0, 0, -main_h/2 - bot_h/2])
        cylinder(d=bot_d, h=bot_h, center=true);
    }
    children();
  }
}

$fn = 128;
left(40) cr2032() show_anchors();
battery_aaa() show_anchors();
right(40) cr2450() show_anchors();

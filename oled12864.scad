include <BOSL2/std.scad>

// Dimensions
//
// :     OLED12864 TOP view
// :
// : <----------- W (X) ---------->
// :
// : +----------------------------+   ^
// : |o                          o|   |
// : +----------------------------+   |
// : |   +--------------------+   |   |
// : |   |                    |   |   |
// : |   |                    |   |   |
// : |   |                    |   |   |
// : |   |                    |   |   D (Y)
// : |   |                    |   |   |
// : |   |                    |   |   |
// : |   +--------------------+   |   |
// : +----------------------------+   |
// : |o   oooooooooooooooooooo   o|   |
// : +----UUUUUUUUUUUUUUUUUUUU----+   v
// :
// :          FRONT
//
// + WDH: 70.1mm, 48.1mm, 6mm
// + H: LCD 3mm + PCB 1mm + BACK bracket 2mm = 6mm
//
// + Land pitch: 2.54mm
// + Mounting Holes: 2.5mm x 4
// + LCD is located at the CENTER of PCB.
//


// https://www.winstar.com.tw/products/oled-module/graphic-oled-display/2_42-oled.html
//
// frame: 60.5 x 37
// screen: 57.01 x 28.91
function oled12864_size()     = [70.1, 48.1, 6];
function oled12864_pcb_size() = [70.1, 48.1, 1];
function oled12864_scr_size() = [57.0, 29.2, 3];

module oled12864(anchor=CENTER, spin=0, orient=UP) {
  // Sizes
  pcb = [70.1, 48.1, 1   ]; // PCB
  frm = [61.5, 39.0, 2.99]; // OLED frame
  scr = [57.0, 29.2, 3   ]; // OLED screen
  bra = [4.0,   0.5, 2   ]; // Back metal bracket
  box = pcb + [0, 0, 5   ]; // Bounding box

  // OLED screen is Y+3.5mm offset from center.
  scr_ofs = [0, 3.5, 0];

  // Rounding and mounting hole diameter
  R = 0.075*INCH; // PCB rounding
  D = 2.9;
  X = 10;

  // We set origin [0, 0, 0] to the TOP of pcb.
  // cp is z-offset from origin to centroid of the bounding box.
  // : <upper> scr.z <origin> pcb.z + bra.z <lower>
  // : cp = (upper - lower) /2
  // cp will work for making attachable.
  // : attachable(..., cp=[0,0,cp])
  cp = [0, 0, (scr.z - pcb.z - bra.z) / 2];

  // Each center positions from origin
  pcb_pos = [0, 0, -pcb.z/2];           // PCB
  scr_pos = [0, 0, +scr.z/2] + scr_ofs; // OLED

  // Indivisual parts for attach_part()
  parts = [
    define_part("PCB", attach_geom(size=pcb),
                T=translate(pcb_pos)),
    define_part("SCREEN", attach_geom(size=scr),
                T=translate(scr_pos)),
  ];

  anchors = [
    named_anchor("SCREEN", scr_pos - [0,0,-scr.z/2], TOP, 0),
  ];

  attachable(anchor, spin, orient, size=box, cp=cp, parts=parts, anchors=anchors) {
    difference() {
      // Base PCB align=TOP to set the TOP of pcb as [0,0,0].
      recolor("green") cuboid(pcb, anchor=TOP, rounding=R, edges="Z") {
        attach(TOP, BOTTOM) {
          // OLED frame at TOP
          color("black") cube(frm);
          // OLED screen
          color("blue") translate(scr_ofs) cube(scr);
        }
        // Back metal bracket
        attach(BOTTOM, TOP)
          grid_copies(spacing=[41, 38.5], n=[2, 2])
            zrot(-30) color("black") cube(bra);
      }
      // Mounting holes are X=2mm, Y=2.25mm inset
      grid_copies(spacing=[pcb.x-2*2, pcb.y-2.25*2], n=[2, 2])
        cylinder(d=D, h=X, center=true);
    }
    let ($pcb_size=pcb, $scr_size=scr) {
      children();
    }
  }
}

////////////////////////////////////////////////////////////////
// DEMO

$fn = 64;
// oled12864() attach_part("PCB") show_anchors();
oled12864() attach_part("SCREEN") attach(TOP, BOTTOM) cuboid([5, 5, 0.5]);

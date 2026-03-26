// pinheader.scad --- Generic pinheader 3D model
//
// Author: Yoshinari Nomura <nom@quickhack.net>
// Created: 2026-01-17
// Version: 0.1.0
// License: MIT
//
// Commentary:
//
// This is a Generic pinheader OpenSCAD 3D model.
//

include <BOSL2/std.scad>

// pinheader(size, n, pl=3.2, pl2=2, pitch=2.54,
//           anchor=CENTER, spin=0, orient=UP)
//
// :          Front View                 Side View
// :
// : <----------- A ----------->           <- B ->
// :   +-+  +-+  +-+  +-+  +-+   <-          ++
// :   | |  | |  | |  | |  | |    |          ||
// :   | |  | |  | |  | |  | |    |          ||
// :   | |  | |  | |  | |  | |    | E        ||
// :   | |  | |  | |  | |  | |    |          ||
// :   | |  | |  | |  | |  | |    |          ||
// : +-+-+--+-+--+-+--+-+--+-+-+ <-        +-++-+ <-
// : |                         |  |        |    |  |
// : |                         |  | C      |    |  | C
// : |                         |  |        |    |  |
// : +-+-+--+-+--+-+--+-+--+-+-+ <-        +-++-+ <-
// :   | |  | |  | |  | |  | |    | D        ||
// :   | |  | |  | |  | |  | |    |          ||
// :   +-+  +-+  +-+  +-+  +-+   <-          ++
//
// + A :: Housing Total Width
// + B :: Housing Depth (Thickness)
// + C :: Housing Height
// + D :: Lead Length (PCB side)
// + E :: Lead Length (Contact side)
//
// * Parameters:
//   + size :: [A, B, C]
//   + n :: number of pins like 10, [10, 2]
//   + pl :: pin length D
//   + pl2 :: pin length E
//   + pitch :: pin pitch
//
// * As attachable:
//   + size (bounding box) is [A, B, C]
//   + Coordinate origin is centroid of housing.
//
// * Examples
//   pin header 1x40 (40P)
//   https://akizukidenshi.com/catalog/g/g100167/
//   (datasheet: https://akizukidenshi.com/goodsaffix/PH-1xXXSG-AD.pdf)
//
//     pinheader(size=[101.60, 2.5, 2.5], n=40, pl=3, pl2=6.1, pitch=2.54)
//
module pinheader(size, n, pl=3, pl2=6.1, pitch=2.54,
                 anchor=CENTER, spin=0, orient=UP) {

  n = is_list(n) ? n : [n, 1];
  bs = [size.x/n[0], size.y/n[1] + (n[1] > 1 ? 0.1 : 0), size.z];
  p1x = (n[0] - 1) * pitch / 2;
  p1y = (n[1] - 1) * pitch / 2;

  // P1-BOT/P1-TOP are bottom/top of the #1 pin.
  anchors = [
    named_anchor("P1-BOT", [-p1x, -p1y, -size.z/2], BOTTOM, 0),
    named_anchor("P1-TOP", [-p1x, -p1y,  size.z/2], TOP, 0),
  ];

  attachable(anchor, spin, orient, size=size, anchors=anchors) {
    grid_copies(spacing=pitch, n=n) {
      pinheader_box(size=bs) {
        attach("PIN-BOT", TOP) pinheader_pin(pl + $pin_inset);
        attach(TOP, TOP) pinheader_pin(pl2);
      }
    }
    children();
  }
}

module pinheader_pin(l, anchor=CENTER, spin=0, orient=UP) {

  // Standard pin size, tip angle and width
  size = [0.5, 0.5, l];
  tip_a = 10;
  tip_w = size.x / 3;

  // Cuter size and central point of tilt
  cs = [size.x, size.y * 1.1, size.z * 1.1];
  cp = [0, 0, -size.z / 2 - tip_w / 2 / tan(tip_a)];

  attachable(anchor, spin, orient, size=size) {
    color("gold") diff("cut")
      cuboid(size)
        tag("cut") {
          yrot(+tip_a, cp=cp) right(+size.x/2) cuboid(cs);
          yrot(-tip_a, cp=cp) right(-size.x/2) cuboid(cs);
        }
    children();
  }
}

module pinheader_box(size, anchor=CENTER, spin=0, orient=UP) {

  // Bottom of housing is cut-out by pin_inset
  pin_inset = 0.2;

  // PIN-BOT is the real bottom for the pin to be attached.
  anchors = [
    named_anchor("PIN-BOT", [0, 0, -size.z/2+pin_inset], BOTTOM, 0),
  ];

  // Top/Bottom cutter sizes
  cs_top = size * 0.4;
  cs_bot = [size.x + 0.1, size.y - 0.5, pin_inset];

  attachable(anchor, spin, orient, size=size, anchors=anchors) {
    recolor("gray") diff("cut")
      cuboid(size, chamfer=0.2, edges="Z")
        tag("cut") {
          attach(BOT, BOT, inside=true, shiftout=0.01) cuboid(cs_bot);
        }

    let ($pin_inset = pin_inset) {
      children();
    }
  }
}

// Demo

// + pin header 1x6 (6P) pitch=2.54mm
//   https://akizukidenshi.com/catalog/g/g100167/
//   (datasheet: https://akizukidenshi.com/goodsaffix/PH-1xXXSG-AD.pdf)
pinheader(size=[15.24, 2.5, 2.5], n=6, pl=3, pl2=6.1, pitch=2.54) {
  attach("P1-TOP", BOTTOM) color("red") cuboid(1);
  attach("P1-BOT", TOP) color("blue") cuboid(1);
}

// + pin header 2x5 (10P) pitch=2.54mm
fwd(20) pinheader(size=[12.7, 5.08, 2.5], n=[5, 2], pl=3, pl2=6.1, pitch=2.54) {
  attach("P1-TOP", BOTTOM) color("red") cuboid(1);
  attach("P1-BOT", TOP) color("blue") cuboid(1);
}

// + pin header 1x20 pitch=2mm
//   https://akizukidenshi.com/catalog/g/g103667/
//   (datasheet: https://akizukidenshi.com/goodsaffix/PH2-1xXXSBG.pdf)
fwd(40) pinheader(size=[40, 2, 2], n=20, pl=2.8, pl2=3.9, pitch=2) {
  attach("P1-TOP", BOTTOM) color("red") cuboid(1);
  attach("P1-BOT", TOP) color("blue") cuboid(1);
}

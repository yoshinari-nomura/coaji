// pinsocket.scad --- Generic pinsocket 3D model
//
// Author: Yoshinari Nomura <nom@quickhack.net>
// Created: 2026-01-17
// Version: 0.1.0
// License: MIT
//
// Commentary:
//
// This is a Generic pinsocket OpenSCAD 3D model.
//

include <BOSL2/std.scad>

// pinsocket(size, n, pl=3.2, pitch=2.54, anchor=CENTER, spin=0, orient=UP)
//
// :          Front View                 Side View
// :
// : <----------- A ----------->           <-B->
// : +-------------------------+ <-        +---+ <-
// : |                         |  |        |   |  |
// : |                         |  | C      |   |  | C
// : |                         |  |        |   |  |
// : +-+-+--+-+--+-+--+-+--+-+-+ <-        ++ ++ <-
// :   | |  | |  | |  | |  | |    |         | |
// :   | |  | |  | |  | |  | |    | D       | |
// :   | |  | |  | |  | |  | |    |         | |
// :   +-+  +-+  +-+  +-+  +-+   <-         +-+
//
// + A :: Housing Total Width
// + B :: Housing Depth (Thickness)
// + C :: Housing Height
// + D :: Lead Length (PCB side)
//
// * Parameters:
//   + size :: [A, B, C]
//   + n :: number of pins like 10, [10, 2]
//   + pl :: pin length D
//   + pitch :: pin pitch
//
// * As attachable:
//   + size (bounding box) is [A, B, C]
//   + Coordinate origin is centroid of housing.
//
// * Examples
///  pin socket 1x4 (4P) 2.54mm pitch:
//   https://akizukidenshi.com/catalog/g/g110099/
//   (datasheet: https://akizukidenshi.com/goodsaffix/FH-1X00SGRH.pdf)
//
//     pinsocket(size=[10.56, 2.5, 8.5], n=4, pl=3.2, pitch=2.54)
//
module pinsocket(size, n, pl=3.2, pitch=2.54,
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
    grid_copies(spacing=pitch, n=n)
      pinsocket_box(size=bs)
        attach("PIN-BOT", TOP) pinsocket_pin(pl + $pin_inset);
    children();
  }
}

module pinsocket_pin(l, anchor=CENTER, spin=0, orient=UP) {

  // Standard pin size, tip angle and width
  size = [0.5, 0.2, l];
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

module pinsocket_box(size, anchor=CENTER, spin=0, orient=UP) {

  // Bottom of housing is cut-out by pin_inset
  pin_inset = 0.5;

  // PIN-BOT is the real bottom for the pin to be attached.
  anchors = [
    named_anchor("PIN-BOT", [0, 0, -size.z/2+pin_inset], BOTTOM, 0),
  ];

  // Top/Bottom cutter sizes
  cs_top = size * 0.4;
  cs_bot = [size.x + 0.1, size.y - 0.5, pin_inset];

  attachable(anchor, spin, orient, size=size, anchors=anchors) {
    recolor("green") diff("cut")
      color_this("black") cuboid(size)
        tag("cut") {
          attach(BOT, BOT, inside=true, shiftout=0.01) cuboid(cs_bot);
          attach(TOP, TOP, inside=true, shiftout=0.01) cuboid(cs_top);
        }

    let ($pin_inset = pin_inset) {
      children();
    }
  }
}

// Demo

// + Pin socket 1x4(4P) 2.54mm pitch
//   https://akizukidenshi.com/catalog/g/g110099/
*pinsocket(size=[10.56, 2.5, 8.5], n=4, pl=3.2) {
  attach("P1-TOP", BOTTOM) color("red") cuboid(1);
  attach("P1-BOT", TOP) color("blue") cuboid(1);
}

// + Pin socket 2x20(40P) 2.54mm pitch
//   https://akizukidenshi.com/catalog/g/g100085/
pinsocket(size=[51.05, 5, 8.5], n=[20, 2], pl=3) {
  attach("P1-TOP", BOTTOM) color("red") cuboid(1);
  attach("P1-BOT", TOP) color("blue") cuboid(1);
}

// + Pin socket 1x20(20P) 2mm pitch
//   https://akizukidenshi.com/catalog/g/g103871/
fwd(40) pinsocket(size=[40.5, 2.4, 4.3], n=20, pitch=2, pl=2.4) {
  attach("P1-TOP", BOTTOM) color("red") cuboid(1);
  attach("P1-BOT", TOP) color("blue") cuboid(1);
}

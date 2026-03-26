// tg12864e.scad --- Graphic Display Module 128x64 TG12864E
//
// Author: Yoshinari Nomura <nom@quickhack.net>
// Created: 2025-01-10
// Version: 0.1.0
// License: MIT
//
// Commentary:
//
// This is a Graphic Display Module 128x64 TG12864E OpenSCAD 3D model.
// https://akizukidenshi.com/catalog/g/g104257/
//

include <BOSL2/std.scad>

$fn = 64;

// Dimensions
//
// :     TG12864E TOP view
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
// + WDH: 54mm, 50mm, 9mm
// + H: LCD 6mm + PCB 1mm + BACK bracket 2mm
//
// + Land pitch: 2mm
// + Mounting Holes: 2.5mm x 4
// + LCD is located at the CENTER of PCB.

function tg12864e_size() = [54, 50, 9];
function tg12864e_pcb_size() = [54, 50, 1];
function tg12864e_lcd_size() = [43.5, 29, 6];

module tg12864e(anchor=CENTER, spin=0, orient=UP) {
  bbox = tg12864e_size();
  ps = tg12864e_pcb_size();  // PCB size
  ls = tg12864e_lcd_size();  // LCD size
  lf = [54, 41.2, 5.99];     // LCD Frame
  bs = [4, 0.5, 2];          // Back metal bracket size

  // This module's own center point (cp) should be the centroid of the
  // bbox, and you must specify both "parts" and "anchors" relative to
  // this [0, 0, 0] origin.
  //
  // However, in some cases it may be more convenient to perform
  // calculations using the PCB surface or its midpoint as the cp.
  //
  // PCB center is initial sea level:
  //   [LCD] + [PCB/2] + (z=0) + [PCB/2] + [Bracket]
  // Let z0 be the offset from the centroid of the bounding box:
  //
  z0 = ((ls.z + ps.z/2) - (ps.z/2 + bs.z)) / 2;

  // Indivisual parts for attach_part()
  parts = [
    define_part("PCB", attach_geom(size=ps),
                T=translate([0, 0, -z0])),
    define_part("LCD", attach_geom(size=ls),
                T=translate([0, 0, -z0+(ps.z + ls.z) / 2])),
  ];

  pin1x = (20 - 1) * 2.0 / 2; // 20pins, 2.0mm pitch.

  anchors = [
    // 47 is from datasheet
    named_anchor("P1-BOT", [-pin1x, -47/2, -z0-ps.z/2], BOTTOM, 0),
    named_anchor("P1-TOP", [-pin1x, -47/2, -z0+ps.z/2], TOP, 0),
  ];

  attachable(anchor, spin, orient, size=bbox, parts=parts, anchors=anchors) {
    down(z0) diff("drill") recolor("green")
      // Base PCB
      cuboid(ps) {

        attach(TOP, BOTTOM) {
          // LCD frame
          color("black") cuboid(lf);
          // LCD screen
          color("blue") cuboid(ls, rounding=3.5/2, edges="Z");
        }

        // M2.5 Mounting holes. 49,45 from datasheet
        attach(TOP, BOTTOM, overlap=1.1)
          grid_copies(spacing=[49, 45], n=[2, 2])
            tag("drill") cyl(d=2.5, h=2);

        // Back metal bracket. 20,38 from measurement
        attach(BOTTOM, TOP)
          grid_copies(spacing=[20, 38], n=[3, 2])
            zrot(-30) color("black") cuboid(bs);

        // Through holes: land=1.5mm, drill=1mm, center is 1.5mm from edge
        attach(TOP, BOTTOM, align=FRONT, inset=1.5, overlap=1.1)
          color("gold") grid_copies(spacing=[2, 0], n=[20, 1]) {
            fwd(1.5/2) cyl(d=1.5, h=1.2);
            fwd(1.5-0.1) cuboid([1.5, 1.4, 1.2]);
            fwd(1/2) down(0.1) tag("drill") cyl(d=1, h=1.4);
          }
      }
    let ($pcb_size=ps, $lcd_size=ls) {
      children();
    }
  }
}

// DEMO

// + 2mm pitch pin-socket 1x20 (20P) H=4.3
//   https://akizukidenshi.com/catalog/g/g103871/
// + 2mm pitch pin-header 1x20 (20P) H=2.0
//   https://akizukidenshi.com/catalog/g/g103867/
//
PCB_CONNECTOR_SIZE = [40.5, 2.4, 4.3+2.0];

tg12864e() {
  attach_part("PCB")
    attach(BOTTOM, BOTTOM, align=FRONT, inset=0.3)
      color("black") cuboid(PCB_CONNECTOR_SIZE);
  color("gold") attach("P1-TOP", BOTTOM) cuboid([0.6, 0.6, 5]);
}

/*

use <../pinheader.scad>
use <../pinsocket.scad>

tg12864e()
  attach("P1-BOT", "P1-BOT")
    pinheader(size=[40, 2, 2], n=20, pl=2.8, pl2=3.9, pitch=2, spin=180)
      attach("P1-TOP", "P1-TOP")
        pinsocket(size=[40.5, 2.4, 4.3], n=20, pitch=2, pl=2.4, spin=180);
*/

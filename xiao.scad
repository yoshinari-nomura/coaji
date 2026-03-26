// xiao.scad --- Seeed Studio XIAO 3D model
//
// Author: Yoshinari Nomura <nom@quickhack.net>
// Created: 2025-01-09
// Version: 0.1.0
// License: MIT
//
// Commentary:
//
// This is a Seeed Studio Xiao series OpenSCAD 3D model. It was
// created as an example of an "attachable" design using the BOSL2
// component.
//
// The dimensions are based on the datasheet specifications for the
// XIAO ESP32S3, but should also work with other models in the XĀIO
// family as well.
//
// https://wiki.seeedstudio.com/SeeedStudio_XIAO_Series_Introduction/
//
// It has two individual parts: "PCB", "USB", and
// one named anchor: "USB-I".
//
//

include <BOSL2/std.scad>

// Dimensions
//
// :   XIAO TOP view
// :
// :  <--- W (X) --->
// :  +-------------+    ^
// :  |             |    |
// :  |             |    |
// :  |             |    |
// : L|     PCB     |R   D (Y)
// :  |             |    |
// :  |    +---+    |    |
// :  |    |USB|    |    |
// :  +----+   +----+    v
// :       +---+
// :
// :       FRONT
//
// H (Z): USB+PCB thikness
//

function xiao_pcb_w() = 17.9; // measured (data sheet: 17.780mm)
function xiao_pcb_d() = 22.2; // measured (data sheet: 21.135mm)
function xiao_pcb_h() = 1.25; // PCB thickness

function xiao_usb_w() = 9.0;
function xiao_usb_d() = 7.4;
function xiao_usb_h() = 3.3;

function xiao_usb_p() = 1.5;    // USB protrusion from PCB

function xiao_size() = [
  xiao_pcb_w(),
  xiao_pcb_d(),
  xiao_pcb_h() + xiao_usb_h(),
];

function xiao_pcb_size() = [
  xiao_pcb_w(),
  xiao_pcb_d(),
  xiao_pcb_h(),
];

function xiao_usb_size() = [
  xiao_usb_w(),
  xiao_usb_d(),
  xiao_usb_h(),
];

// USB connector
module xiao_usb(anchor=CENTER, spin=0, orient=UP) {
  s1 = xiao_usb_size();    // USB Outer metal
  s2 = s1 - [0.4, 0, 0.4]; // Hollowing-out
  s3 = s2 - [  1, 1, 1.5]; // Internal pins

  attachable(anchor, spin, orient, size=s1) {
    union() {
      color("silver") difference() {
        cuboid(s1, rounding=s1.z/2, edges="Y");
        fwd(0.5) cuboid(s2, rounding=s2.z/2, edges="Y");
      }
      color("black") cuboid(s3, rounding=s3.z/2, edges="Y");
    }
    children();
  }
}

// PCB through-hole: land=1.524mm, drill=0.65532mm
module xiao_thruhole(d=1.524, dh=0.655, spacing=2.54, n=7, T=1.2, cu=0.1,
                 invert=false, anchor=CENTER, spin=0, orient=UP) {

  // If invert, take hole sizes otherwise land.
  real_h = invert ? T*2 : T+cu*2;
  real_d = invert ? dh : d;

  // D for attachable is not the real D, becuase we want holes aligned
  // at the same position with lands.
  attachable(anchor, spin, orient, d=d, h=real_h) {
    color("gold") ycopies(spacing=spacing, n=n)
      cylinder(h=real_h, d=real_d, center=true);
    children();
  }
}

// XIAO body
module xiao(anchor=CENTER, spin=0, orient=UP) {
  // sizes
  pcb = xiao_pcb_size();
  usb = xiao_usb_size();
  mcu = [12.5, 10, 1.05];
  xiao = xiao_size();

  // positions
  usb_p = xiao_usb_p(); // USB-protrusion
  usb_pos = [0, (usb.y-pcb.y)/2-usb_p, usb.z/2];
  pcb_pos = [0, 0, -pcb.z/2];
  land_inset = 0.02*INCH; // Land inset from PCB edge

  R = 0.075*INCH; // PCB rounding

  // We set origin [0, 0, 0] to the TOP of pcb.
  // cp is z-offset from origin to centroid of the bounding box.
  // : <upper> usb.z <origin> pcb.z <lower>
  // : cp = (upper - lower) /2
  //
  // cp will work for making attachable.
  // : attachable(..., cp=[0,0,cp])
  cp = (usb.z - pcb.z) / 2;

  // USB-I anchor is located inside by the amount of the
  // USB-protrusion from the USB FRONT.
  anchors = [
    named_anchor("USB-I", [ 0, -pcb.y/2, usb.z/2], FRONT, 0),
  ];

  // Indivisual parts for attach_part()
  parts = [
    define_part("PCB", attach_geom(size=pcb), T=translate(pcb_pos)),
    define_part("USB", attach_geom(size=usb), T=translate(usb_pos)),
  ];

  attachable(anchor, spin, orient, size=xiao, cp=[0,0,cp],
             anchors=anchors, parts=parts) {
    color_this("green")
      difference() {
        // PCB board
        cuboid(pcb, anchor=TOP, rounding=R, edges="Z") {

          // USB connector
          attach(TOP,BOTTOM, align=FRONT, inset=-usb_p) xiao_usb();

          // MCU chip
          attach(TOP,BOTTOM, align=CENTER) color("silver") cuboid(mcu);

          // PCB land
          // Use overlap over inside=true to avoid inplicit "remove" tag
          attach(BOT,BOT, align=[LEFT,RIGHT], inset=land_inset, overlap=1.3)
            xiao_thruhole(); // make lands
        }

        // Kagemusha for attachment.
        hide_this() cuboid(pcb, anchor=TOP)
          attach(TOP,BOTTOM, align=[LEFT,RIGHT],
                 inset=land_inset, overlap=pcb.z+0.5)
            xiao_thruhole(invert=true); // make holes
      }

    let ($pcb_size=pcb, $usb_size=usb) {
      children();
    }
  }
}

////////////////////////////////////////////////////////////////
// Demo

$fn = 64;

left(30) xiao()
  attach("USB-I", TOP)
    cuboid([$pcb_size.x, 8, 0.1]);

xiao() show_anchors(4, std=true, custom=true);

right(30) xiao() {
  #attach_part("PCB") {
    attach([LEFT,RIGHT], RIGHT, spin=90) cuboid([3, 3, $pcb_size.y]);
  }
  #attach_part("USB") {
    attach(FRONT, FRONT) cuboid($usb_size);
  }
}

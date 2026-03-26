// canted_box.scad --- Trapezoidal canted box module
//
// Author: Yoshinari Nomura <nom@quickhack.net>
// Created: 2026-01-17
// Version: 0.1.0
// License: MIT
//
// Commentary:
//
// A trapezoidal canted chassis often used in alarm clocks.
//
// The left and right walls are vertical, and the angles of the
// front, top, and back can be set arbitrarily.

include <BOSL2/std.scad>

// * Trapezoidal canted box
//
// :        >   P              +---------+ P
// :       /   /＼  d2         |         |
// :      /   /   ＼           |         |
// :   h1/   /      ＼Q <-     ........... Q
// :    /   /        |   |     |         |
// :   /   /         |   |h2   |         |
// :  /   /          |   |     |         |
// : >   O-----------R  <-     +--- O ---+
// :     <--- d1 --->          <--- w --->
// :
// :      right (YZ)            front (XZ)
//
//
// * Synopsis:
//
//   canted_box(size=[1,1,1], angles=[90,90,90,0], flip=false, deltas=0,
//               joint_front, joint_back, joint_sides, rounding=0,
//               anchor=FRONT+BOTTOM, spin=0, orient=TOP);
//
// * Description:
//
//   A trapezoidal canted chassis often used in alarm clocks.
//
//   The left and right walls are vertical, and the angles of the
//   front, top, and back can be set arbitrarily.  It generates an
//   attachable with reasonable default anchors and useful named
//   anchors.
//
// * Arguments:
//
//   + size :: [w, d1, h1] if flip == false
//
//   + size :: [w, d2, h2] if flip == true
//
//   + angles :: [O, P, Q, R] clockwise as seen from the right side (YZ).
//     One of O,...,R can be zero.
//
//   + deltas :: [OP, PQ, QR, RO] offset for each edge of the polygon
//     (for shell creation).  It can be either a single integer or an
//     array with 4 elements corresponding to the front, top, back, and
//     bottom edge.
//
//   + joint_front :: joint distance for front roundover.
//     Same as joint_bot of rounded_prism.
//
//   + joint_back :: joint distance for front roundover.
//     Same as joint_top of rounded_prism.
//
//   + joint_sides :: joint distance for front roundover.
//     Same as joint_sides of rounded_prism.
//
//   + rounding :: Same as joint_front=0, joint_back=R, joint_sides=R.
//     This is overridden by other joint_*.
//
module canted_box(size=[1,1,1], angles=[90,90,90,0], flip=false, deltas=0,
                  joint_front, joint_back, joint_sides, rounding=0,
                  anchor=FRONT+BOTTOM, spin=0, orient=TOP) {
  w = size.x;
  pts = quadrilateral([size.y, size.z], angles, flip);
  xpts = offset_each(pts, deltas);
  p = [for (p=xpts) each [[-w/2, p.x, p.y], [w/2, p.x, p.y]]];

  // Now, p has these vertices:
  //
  //     4---------5    FRONT:  0-2-3-1
  //    /         /|    BACK:   7-5-4-6
  //   /         / |    LEFT:   6-4-2-0
  //  2---------3  |    RIGHT:  1-3-5-7
  //  |         |  |    TOP:    2-4-5-3
  //  |  6      |  7    BOTTOM: 1-7-6-0
  //  |         | /
  //  |/        |/
  //  0---------1

  h1 = norm(p[0] - p[2]);
  h2 = norm(p[4] - p[6]);
  d2 = norm(p[2] - p[4]);
  d1 = norm(p[0] - p[6]);

  // Face polygons (clockwise)
  fwd = [p[0],p[2],p[3],p[1]];
  bak = [p[7],p[5],p[4],p[6]];
  lft = [p[6],p[4],p[2],p[0]];
  rgt = [p[1],p[3],p[5],p[7]];
  top = [p[2],p[4],p[5],p[3]];
  bot = [p[1],p[7],p[6],p[0]];

  // Face anchor positions (center points)
  fwd_c = centroid(fwd);
  bak_c = centroid(bak);
  top_c = centroid(top);

  // Face anchor directions (normal vectors)
  fwd_v = polygon_normal(fwd);
  bak_v = polygon_normal(bak);
  lft_v = polygon_normal(lft);
  rgt_v = polygon_normal(rgt);
  top_v = polygon_normal(top);

  // Edge anchor directions (average of face normals)
  fwd_lft_v = unit(fwd_v + lft_v);
  fwd_rgt_v = unit(fwd_v + rgt_v);
  bak_lft_v = unit(bak_v + lft_v);
  bak_rgt_v = unit(bak_v + rgt_v);
  top_lft_v = unit(top_v + lft_v);
  top_rgt_v = unit(top_v + rgt_v);

  // Edge directions for calculating spin of anchors.
  fwd_lft_e = unit(p[2] - p[0]);
  fwd_rgt_e = unit(p[3] - p[1]);
  bak_lft_e = unit(p[4] - p[6]);
  bak_rgt_e = unit(p[5] - p[7]);
  top_lft_e = unit(p[4] - p[2]);
  top_rgt_e = unit(p[5] - p[3]);

  // Calculate spin for edge anchors.
  // + anchor_vec: direction vector of the edge anchor
  // + edge_vec: vector along the edge
  function edge_spin(anchor_vec, edge_vec) = let(
    // Trans matrix to a coordinate with anchor_vec as the Z-axis
    rot_matrix = rot(from=anchor_vec, to=UP),

    // Convert edge_vec to the local coordinate
    edge_local = apply(rot_matrix, edge_vec),

    // Spin angle in the XY plane in the local coordinate
    // Since BOSL spin is Y-axis orient, we need 90 degree adjustment.
    spin = atan2(edge_local.y, edge_local.x) - 90

  ) spin;

  // front-back X-ray projection
  xfwd = polygon_line_intersection(fwd, [bak_c, bak_c + bak_v]);
  xbak = polygon_line_intersection(bak, [fwd_c, fwd_c + fwd_v]);

  named_anchors = [
    named_anchor("XFRONT", xfwd, -bak_v, 0),
    named_anchor("XBACK",  xbak, -fwd_v, 180),
  ];

  // X-shift from the center point
  xs = [size.x/2,0,0];

  anchors = [
    // name        position  direction  spin
    [FRONT,       [fwd_c,    fwd_v,       0]],
    [BACK,        [bak_c,    bak_v,     180]],
    [TOP,         [top_c,    top_v,       0]],
    [FRONT+LEFT,  [fwd_c-xs, fwd_lft_v, edge_spin(fwd_lft_v, fwd_lft_e)]],
    [FRONT+RIGHT, [fwd_c+xs, fwd_rgt_v, edge_spin(fwd_rgt_v, fwd_rgt_e)]],
    [BACK+LEFT,   [bak_c-xs, bak_lft_v, edge_spin(bak_lft_v, bak_lft_e)]],
    [BACK+RIGHT,  [bak_c+xs, bak_rgt_v, edge_spin(bak_rgt_v, bak_rgt_e)]],
    [TOP+LEFT,    [top_c-xs, top_lft_v, edge_spin(top_lft_v, top_lft_e)]],
    [TOP+RIGHT,   [top_c+xs, top_rgt_v, edge_spin(top_rgt_v, top_rgt_e)]],
  ];

  vnf = [
    [
      p[0], p[1], p[7], p[6], // BOTTOM
      p[2], p[3], p[5], p[4], // TOP
    ],
    [
      [0,1,2], [0,2,3], // BOTTOM
      [0,4,5], [0,5,1], // FRONT
      [1,5,6], [1,6,2], // RIGHT
      [2,6,7], [2,7,3], // BACK
      [3,7,4], [3,4,0], // LEFT
      [6,4,7], [6,5,4]  // TOP
    ]
  ];

  // Default joint values
  fj = is_undef(joint_front) ? 0 : joint_front;
  bj = is_undef(joint_back) ? rounding : joint_back;
  sj = is_undef(joint_sides) ? rounding : joint_sides;

  attachable(anchor, spin, orient, vnf=vnf, cp=centroid(vnf),
             override=anchors, anchors=named_anchors) {
    if (fj != 0 || bj != 0 || sj != 0) {
      // Use rounded_prism for shape generation with rounding.
      // FRONT face is laid down as the bottom of rounded_prism,
      // allowing joint_bot=0 to exclude all FRONT edges from rounding.
      //
      // fwd (FRONT face) as bottom, bak (BACK face) as top.
      // reverse(fwd) makes bottom normal point toward top (bak).
      // bak already has matching winding and vertex correspondence.
      rounded_prism(
        reverse(fwd),
        bak,
        joint_bot = fj,
        joint_top = bj,
        joint_sides = sj
      );
    } else {
      vnf_polyhedron(vnf);
    }
    let ($h1=h1, $h2=h2, $d1=d1, $d2=d2) {
      children();
    }
  }
}

// * 2D quadrilateral with specified angles
//
// :        >   P
// :       /   /＼  w2
// :      /   /   ＼
// :   h1/   /      ＼Q <-
// :    /   /        |   |
// :   /   /         |   |h2
// :  /   /          |   |
// : >   O-----------R  <-
// :     <--- w1 --->
// :
// :   X-Y Plane (O = (0, 0))
//
// * Synopsis:
//
//   path = quadrilateral(size=[1,1], angles=[90,90,90,0], flip=false)
//
// * Description:
//
//   Generate a quadrilateral path: [O, P, Q, R] clockwise starting from the
//   origin O. Let the base OR be on the X-axis.
//
// * Arguments:
//
//   + size: [w, d1, h1] if flip == false
//   + size: [w, d2, h2] if flip == true
//   + angles = [O, P, Q, R] (One of O,...,R can be zero)
//
function quadrilateral(size=[1,1], angles=[90,90,90,0], flip=false) = let(
  w = size.x, h = size.y,

  // Flip angles
  angles = [
    flip ? angles[2] : angles[0],
    flip ? angles[3] : angles[1],
    flip ? angles[0] : angles[2],
    flip ? angles[1] : angles[3],
  ],

  sum = angles[0] + angles[1] + angles[2] + angles[3],
  missing = 360 - sum,

  // Fill the missing angle
  o = angles[0] != 0 ? angles[0] : missing,
  p = angles[1] != 0 ? angles[1] : missing,
  q = angles[2] != 0 ? angles[2] : missing,
  r = angles[3] != 0 ? angles[3] : missing,

  O = [0, 0],
  P = [h * cos(o), h * sin(o)],
  R = [w, 0],

  pq_direction = o - (180 - p),
  rq_direction = 180 - r,

  pq_vec = P + [cos(pq_direction), sin(pq_direction)],
  rq_vec = R + [cos(rq_direction), sin(rq_direction)],

  Q = line_intersection([P, pq_vec], [R, rq_vec]),

) flip ? rot(-pq_direction, p=[Q-Q, Q-R, Q-O, Q-P]) : [O, P, Q, R];

// * Takes a 2D closed path (polygon), and returns a path offset by an amount
//
// * Synopsis:
//
//   offset_path = offset_each(path, deltas);
//   offset_path = offset_each(square[10,10], deltas=[-1, -1, 1, -1]);
//   offset_path = offset_each(square[10,10], deltas=1);
//
// * Description:
//
//   For each edge of the polygon, add the offset represented by
//   DELTAS.  DELTAS can be either a single integer or an array with
//   the number of elements corresponding to the number of edges.
//
// * Arguments:
//
//   + path: List of 2D points, should be clockwise
//   + deltas: deltas[i] is the offset of the line [path[i], path[(i+1)%n]
//
function offset_each(path, deltas) = let(
  n = len(path),
  deltas = is_list(deltas) ? deltas : [for(i=[0:n-1]) deltas],
  dummy = assert(len(path) == len(deltas),
                 "The number of elements in path and deltas must match."),

  // Offset lines for each edge.
  lines = [
    for (i = [0:n-1]) let(
      p1 = path[i],
      p2 = path[(i + 1) % n],
      v = p1 - p2, // p1 - p2: clockwise
      normal_v = unit([v.y, -v.x]),
      d = deltas[i]
    ) [p1 + normal_v * d, p2 + normal_v * d]
  ],

  // Calculate the intersections
  new_path = [
    for (i = [0:n-1]) let(
      prv_line = lines[(i + n - 1) % n],
      cur_line = lines[i]
    ) line_intersection(prv_line, cur_line)
  ]
) new_path;

////////////////////////////////////////////////////////////////
// Demo & debug

F_SIZE = [68.9, 20.2, 54.6];
B_SIZE = [56.9, 35, 40];
TILT = 18;

module quadrilateral_debug() {
  p1 = quadrilateral(size=[B_SIZE.y, B_SIZE.z], angles=[90-TILT, 90, 0, 90]);
  p2 = offset_each(p1, deltas=[2, -2, -2, -2] );
  stroke(p1, closed=true, width=1, color="gray");
  stroke(p2, closed=true, width=1, color="red");
}

// Shape like a table clock combining two boxes.
canted_box(size=F_SIZE, angles=[90-TILT, 90, 90, 0], flip=true,
           joint_front=2, joint_sides=2) {
  show_anchors();
  attach(BACK, FRONT, align=BOTTOM)
    color_this("silver")
      canted_box(size=B_SIZE, angles=[90-TILT, 90, 0, 90], rounding=2)
        show_anchors();
}

// right(100) back(50) left(25) quadrilateral_debug();

// Create canted box and hollow it out by opening the front.
right(100) left_half() diff()
  canted_box(size=B_SIZE, angles=[90-TILT, 90, 0, 90], rounding=2)
    attach(BACK, BACK, inside=true, overlap=-2)
      color("white") tag("remove")
        canted_box(size=B_SIZE-[4, 0, 0],
                   angles=[90-TILT, 90, 0, 90],
                   deltas=[2, -2, -2, -2]);

// Standard cuboid for the reference
left(80) cuboid(20, anchor=FRONT+BOTTOM) show_anchors();

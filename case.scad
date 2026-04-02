include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

$fn = 64;
e = 0.01;

// Keyboard parameters

KEYBOARD_PCB_PATH = [
  [16.1, -69.5],
  [4.3, -42.8],
  [4.3, 17.2],
  [23.3, 17.2],
  [23.3, 19.6],
  [42.4, 19.6],
  [42.4, 21.9],
  [61.4, 21.9],
  [61.4, 24.3],
  [81.5, 24.3],
  [81.5, 21.9],
  [100.5, 21.9],
  [100.5, 17.2],
  [138.6, 17.2],
  [138.6, -41.0],
  [81.3, -41.0],
  [71.7, -57.6],
  [33.9, -61.6],
];

KEYBOARD_MOUNTING_HOLES = [
  [42.9, 1.2],
  [42.9, -38.1],
  [119.1, -2.4],
  [119.1, -21.4],
];

KEYBOARD_USB_PORT = [12.3, 17.2];

KEYBOARD_TRRS_PORT = [4.3, -34.7];

KEYBOARD_FEET_LOCATIONS = [
  [8.3, 13.2],
  [71.5, 20.3],
  [134.6, 13.2],
  [134.6, -37.0],
  [69.3, -53.8],
  [16.5, -60.6],
];

KEYBOARD_ROUND_CORNERS_OUTSIDE = [1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1];
KEYBOARD_ROUND_CORNERS_INSIDE = [0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 6, 0, 1];
//KEYBOARD_ROUND_CORNERS_INSIDE = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

// Case parameters
PCB_WIDTH = 1.6;

INSIDE_CLEARANCE = 1.2;

INSIDE_HEIGHT = 12.5;
CASE_WALL_THICKNESS = 3.0;
CASE_BOTTOM_THICKNESS = 2.0;

CHAMFER_OUTSIDE = 1.5;
CHAMFER_INSIDE = 0.25;

FOOT_DIAMETER = 10.6;
FOOT_RECESS = 0.8;

CASE_ROUND_CORNER_OUTSIDE_SIZE = 2.25;
CASE_ROUND_CORNER_INSIDE_SIZE = 0.8;

// case modules

module case_outside() {
  offset_path = offset(
    KEYBOARD_PCB_PATH,
    delta=INSIDE_CLEARANCE + CASE_WALL_THICKNESS,
    closed=true,
    check_valid=false
  );
  rounded_path = round_corners(offset_path, r=KEYBOARD_ROUND_CORNERS_OUTSIDE * CASE_ROUND_CORNER_OUTSIDE_SIZE);
  offset_sweep(
    rounded_path,
    height=INSIDE_HEIGHT + CASE_BOTTOM_THICKNESS,
    bottom=os_chamfer(width=CHAMFER_OUTSIDE, angle=38),
    top=os_chamfer(width=CHAMFER_OUTSIDE, angle=38),
    check_valid=false,
    offset="delta"
  );
}

module case_inside() {
  offset_path = offset(
    KEYBOARD_PCB_PATH,
    delta=INSIDE_CLEARANCE,
    closed=true,
    check_valid=false
  );
  rounded_path = round_corners(offset_path, r=KEYBOARD_ROUND_CORNERS_INSIDE * CASE_ROUND_CORNER_INSIDE_SIZE);
  offset_sweep(
    rounded_path,
    height=INSIDE_HEIGHT + e,
    top=os_chamfer(width=-CHAMFER_INSIDE),
    check_valid=false,
    offset="delta"
  );
}

module case_body() {
  difference() {
    case_outside();
    up(CASE_BOTTOM_THICKNESS) {
      case_inside();
    }
    for (hole_pos = KEYBOARD_MOUNTING_HOLES) {
      translate(hole_pos) moutnting_hole();
    }
    for (foot = KEYBOARD_FEET_LOCATIONS) {
      translate(foot) foot_hole();
    }
    left(INSIDE_CLEARANCE)
      up(CASE_BOTTOM_THICKNESS + 2.5)
        translate(KEYBOARD_TRRS_PORT) trrs_hole();
    back(INSIDE_CLEARANCE)
      up(CASE_BOTTOM_THICKNESS + 2.0)
        translate(KEYBOARD_USB_PORT) usbc_hole();
  }
}

module moutnting_hole() {
  cylinder(h=CASE_BOTTOM_THICKNESS + e, d=2.4);
  down(e) cylinder(h=1.5, d1=4.4, d2=2.4);
}

module usbc_hole() {
  hull()
    xcopies(10.5 - 6)
      fwd(e)
        ycyl(h=CASE_WALL_THICKNESS + 2 * e, d=7.0, chamfer=-0.0, anchor=FWD);
}

module trrs_hole() {
  right(e)
    xcyl(h=CASE_WALL_THICKNESS + 2 * e, d=7.0, chamfer=-0.0, anchor=RIGHT);
}

module foot_hole() {
  down(e) cyl(h=FOOT_RECESS + e, d=FOOT_DIAMETER, anchor=BOTTOM);
}

// visualization modules

module pcb_from_path(path) {
  color("green") linear_sweep(path, h=PCB_WIDTH);
}

//up(CASE_BOTTOM_THICKNESS + 2) pcb_from_path(KEYBOARD_PCB_PATH);
case_body();
//usbc_hole();

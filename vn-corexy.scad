/* Very Narrow CoreXY Printer (vn-corexy)
   Created with goal: use as small space in width dimension as possible.
   (C) 2020-2022 Marek Wodzinski <majek@w7i.pl> https://majek.sh
   
   vn-corexy is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
   You should have received a copy of the license along with this work.
   If not, see <http://creativecommons.org/licenses/by-sa/4.0/>
*/

/* [head position] */
pos_x=0;
pos_y=100;
pos_z=310;
/* [build plate] */
build_plate_w=310; // (X)
build_plate_d=310; // (Y)
build_plate_mount_space=240; // space between mounting screws
/* [build volume] */
build_x=300;
build_y=300;
build_z=310;
/* [hotend] */
hotend_w=50;
hotend_d=70;
hotend_type=1; // [0:with BMG extruder, 1: with Sailfin extruder]
hotend_nozzle=67-hotend_type*17; //distance from gantry to nozzle
/* [frame] */
// extrusions family size
ext=20;
// extrusion type
ext_type=1; // [0:T-SLOT, 1:V-SLOT]
// minimum margin between build plate and frame
x_margin=10;
// X gantry build type
x_gantry_type=1; // [0: V-SLOT + MGN12, 1: Carbon fiber tube + MGN9]
// CF tube size
cf_tube_size=20.20;
// CF tube wall thickness
cf_tube_wall=1.15;
/* [printed parts] */
printed_corners=true; // [false:no, true:yes]
printed_corners_nut=1; // [0:printed nut, 1:rotating t-nut, 2:sliding t-nut]
pp_color=[0.3,0.3,0.3]; // [0:0.1:1]
pp_color2=[0.3,0.3,0.8]; // [0:0.1:1]
printed_t8_clamps=true; // [false:no, true:yes]
bed_coupler=1; // [0:permanent mount, 1:Oldham couplings]


/* [render printable parts] */
render_parts=0; // [1:T-nut M5, 2: Joint 1x1, 3: Joint 2x2, 4: PSU mounts, 5: Power socket mount, 6: Control board mounts, 7: T8 clamp, 8: T8 spacer, 9: T8 side mount, 10: T8 rear mount, 11: Front joint, 12: Z pulley support, 13: Z motor mount, 14: Cable tie mount, 15: Z pulley helper for adjusting, 16: Front Z wheel mount, 17: Rear Z wheel mount, 18: Front bed frame joint and bed support, 19: Back bed support, 20: Side bed frame to T8 mount, 21: Back bed frame to T8 mount, 22: Z endstop mount, 23: Z endstop trigger, 24: MGN12 positioning tool, 25: X motor mount base, 26: X motor mount top, 27: Y motor mount base, 28: Y motor mount top, 29: Front pulley support left down, 30: Front pulley support right down, 31: Pulley spacer 1mm, 32: Pulley spacer 2mm, 33: Front pulley support left up, 34: Front pulley support right up, 35: Oldham T8, 36: Oldham middle, 37: Oldham top sides, 38: Oldham top back, 39: Left gantry joint for CF tube, 40: Left top of gantry joint for CF tube, 41: Right gantry joint for CF tube, 42: Right top of gantry joint for CF tube, 43: MGN9 on CF positioning tool, 44: X/Y endstop trigger, 45: Y motor pulley spacer, 46: Y endstop mount, 47: CF tube M3 nut jig, 48: Extruder carriage for MGN9, 49: V6 hotend shroud, 50: Hotend blower spacer]

/* [tweaks/hacks] */

// increase up to 1 if your printer is perfect :-), decrease when joint doesn't fit into v-slot groove
vslot_groove_scale=0.98;

// 1 for perfect printer, little larger if nut doesn't fit into hole
tnut_nut_scale=1.03;

// make holes printable without supports
bridge_support=true;
// thickness of bridge layer if bridge_support is enabled
bridge_thickness=0.20;

// use upper ball bearings for T8 rods
t8_upper_bearings=true;

// correction for offset on overextrusion or slicer problems impacting on XY dimensions
printer_off=0.10; // [0:0.01:0.2]


// internal stuff starts here
/* [Hidden] */
include <NopSCADlib/lib.scad>

// calculated
base_w=2*ext+max(build_x+hotend_w,build_plate_w+x_margin); // frame width
base_h=ext*2+400+5; //height of frame base
base_d=build_plate_d+hotend_d+2*ext+50; // frame depth
top_d=base_d+50; // top left/right profiles length, 50 is just wild guess to allow some space between X carriage and rear of frame
//y_rail_l=base_d-2*ext; // MGN rails length
y_rail_l=400;
y_rails_from_front=2.5*ext;
y_rail_carriage=MGN12H_carriage;
x_rail_carriage=MGN12H_carriage;
//x_rail_l=base_w-2*ext; // 350
x_rail_l=375;
z_pulley_support=170; //distance from front to Z pulley support
z_belt_h=48; // space from bottom of frame to Z belt
pr20=pulley_pr(GT2x20ob_pulley); // radius of puller for belt calculations
//belt_x_separation=pulley_od(GT2_10x20_toothed_idler);
belt_x_separation=6; // horizontal separation between XY belts
belt_z_separation=15; // vertical distance between XY belts
beltx_shift=34+4; // distance from frame to bottom of X belt pulley
belty_shift=beltx_shift+belt_z_separation; // distance from frame to bottom of Y belt pulley
// gantry
gantry_belt_shift=12.5; // position in Y of belt on gantry relative to center of carriage
gantry_belt_pos=gantry_belt_shift+carriage_length(y_rail_carriage)/2; // belt position relative to front of carriage
// motors
xy_motor_pos=[21+2*ext,base_d+22]; // X motor position, for Y motor is mirrored
x_motor_z=beltx_shift-5; // X motor relative Z position
y_motor_z=belty_shift-5; // Y motor relative Z position
xy_o_pulley_pos=[ext/2,base_d+ext]; // motor outer pulley position
xy_i_pulley_pos=[ext/2+belt_x_separation,base_d]; // motor inner pulley position
elec_support=135; // distance for electronic supports from edge of frame (just guess, should be adjusted for real hardware)
// extrusion joint/corner, set for M5x12
joint_screw_len=12; // length of screw
joint_screw_d=5; // screw diameter
joint_screw_head_d=8.5; // head diameter
joint_screw_washer=10; // washer diameter
joint_screw_head_h=5; // head height
joint_extr_depth=5.5; // depth of screw in extrusion profile, 6 is fine for 2020
joint_in_material=joint_screw_len-joint_extr_depth; // amount of thread in joint
joint_space=joint_screw_len-joint_extr_depth+joint_screw_head_h+joint_screw_head_d/2; // minimum space from corner to allow put two perpendicular screws
t8_frame_dist=2.5; // distance from frame to start of T8 screw
t8_bb_offset=1.5; // space from start of T8 to ball bearing
m5_hole=4.75; // hole for direct M5 screw without tapping
m3_hole=2.75; // hole for direct M3 screw without tapping
m2_hole=1.7; // hole for direct M2 screw without tapping
bed_z=base_h-2*ext-10-pos_z; // bed Z position

// Carbon fiber tube private variables
cf_above_carriage=3.5; // height of cf above carriage
cf_from_front=5; // distance from front of carriage

// oldham coupler
oldham_w=ext*1.3; // width of oldham coupler
oldham_d=ext*1.2; // depth of oldham coupler (without margin)
oldham_lh=10.5; // height of low part
oldham_mh=8; // height of middle part
oldham_margin=2.0; // space between coupler and outer shape of printer
oldham_w_h=5; // wedge height

// FPC board
fpc_z=20+31.5; // FPC connector mount Z relative to top of frame
fpc_x=base_w-42; // X position of PFC connector on Y motor

// optical endstop holes
optical_endstop_holes=[[2.75,5.1],[2.75+19,5.1]];

// handy rails vars
MGN9_holes=[[-8,-7.5],[-8,7.5],[8,-7.5],[8,7.5]];

// Extra stuff not in NopSCADlib
// 688RS ball bearings (8x16x5)
BB688=["688", 8, 16, 5, "black", 1.4, 2.0];
T8_BB=BB688;
// GT2 10mm belt
GT2x10=["GT", 2.0, 10, 1.38, 0.75, 0.254];
// GT2 10mm pulleys
GT2_10x20_toothed_idler2=["GT2_10x20_toothed_idler_14mm", "GT2", 20, 12.22, GT2x10, 10.9, 18, 0, 5, 18.0, 1.55, 0, 0, false, 0];
GT2_10x20_toothed_idler=["GT2_10x20_toothed_idler_13mm", "GT2", 20, 12.22, GT2x10, 10.9, 18, 0, 5, 18.0, 1.05, 0, 0, false, 0];
GT2_10x20_plain_idler=["GT2_10x20_plain_idler_13mm", "GT2", 0, 12.0, GT2x10, 10.9, 18, 0, 5, 18.0, 1.05, 0, 0, false, 0];
GT2_10x20ob_pulley=["GT2_10x20ob_pulley", "GT2OB", 20, 12.22, GT2x10, 10.9, 16, 7.0, 5, 16.0, 1.5, 6, 3.25, M3_grub_screw, 2];
// NEMA 17 23mm (pancake)
NEMA17S23 = ["NEMA17S", 42.3, 23, 53.6/2, 25, 11, 2, 5, 24, 31, [8, 8]];
// V-SLOT
V2020  = [ "V2020", 20, 20,  4.2, 3, 7.8, 6.25, 11.0, 1.8, 1.5, 1 ];
V2040  = [ "V2040", 20, 40,  4.2, 3, 7.8, 6.25, 11.0, 1.8, 1.5, 1 ];
vtr=9.16; // v-slot top tiangle width
// Large rocker switch
large_rocker   = ["large_rocker", "Some large rocker found in drawer", 22, 28, 25, 30.5, 2.10, 21.3, 26, 15.8, 3,  -1, 2.5, small_spades];
// v-slot wheel: [ 0:name, 1:outer dia, 2:hole dia, 3:bearing outer dia, 4:width, 5:roll dia, 6:flat width, 7: edge dia, 8: spacer dia ]
VWHEEL_L = [ "V-wheel large", 24.32, 5, 16, 11.1, 20.50, 5.1, 19.40, 8.5 ];
VWHEEL_S = [ "V-wheel small", 15.25, 5, 11, 8.90, 12.10, 6.1, 12.50, 7.0 ];
VWHEEL = VWHEEL_L;
// blower - Pengda other type
PE4020C = ["PE4020C", "Blower Pengda Technology 4020 - custom", 40, 40, 19.3, 27.5, M3_cap_screw, 22, [21.5, 20], 3.1, [[37.7,2.60],[2.60,37.8],[37.7,37.8]], 29.3, 17,  1.5, 1.2, 1.3, 12.9];
hotend_blower=PE4020C;
/*
$vpt=[ 195, 260, 230 ]; // viewport translate
$vpr=[ 62.70, 0.00, 360*$t ]; // viewport rotation 67.20
$vpd=1770.74; // viewport distance
$vpf=22.50; // viewport fov
*/
module vn_logo(l_h){
  linear_extrude(l_h) import("vn.svg");
}
module vslot_wheel(wheel){
  // derlin part
  side_h=(wheel[4]-wheel[6])/2;
  color("#020202") difference(){
    union(){
      cylinder(d1=wheel[7], h=side_h, d2=wheel[1]);
      translate([0,0,side_h]) cylinder(d=wheel[1], h=wheel[6]);
      translate([0,0,side_h+wheel[6]]) cylinder(d2=wheel[7], h=side_h, d1=wheel[1]);
    }
    cylinder(d=wheel[3], h=wheel[4]);
  }
  // ball bearing
  color("#f0f0f0") difference(){
    cylinder(d=wheel[3], h=wheel[4]);
    cylinder(d=wheel[2], h=wheel[4]);
  }
}
module triangle(a,h){
  translate([0,0,-h/2]) linear_extrude(h) polygon([[0,0], [a,0], [0,a]]);
}
module round_corner(r,h){
  difference(){
    cube([r,r,h]);
    translate([r,r,0]) cylinder(r=r,h=h);
  }
}
module vtriangle(){
    polygon([[-vtr/2,0],[vtr/2,0],[0,vtr/2]]);
}

module vslot_groove(length, depth=1.5){
  scale([vslot_groove_scale,1,1]) linear_extrude(length) intersection(){
    vtriangle();
    translate([-vtr/2,0,0]) square([vtr,depth]);
  }
}

module vslot2020(type, length, center = true, cornerHole = false) {
  //! Draw the specified extrusion
  color(grey(20))
    linear_extrude(length, center = center)
      difference(){
        extrusion_cross_section(type, cornerHole);
        translate([0,-10,0]) vtriangle();
        translate([10,0,0]) rotate([0,0,90]) vtriangle();
        translate([0,10,0]) rotate([0,0,180]) vtriangle();
        translate([-10,0,0]) rotate([0,0,270]) vtriangle();
      }
}
module vslot2040(type, length, center = true, cornerHole = false) {
  //! Draw the specified extrusion
  color(grey(20))
    linear_extrude(length, center = center)
      difference(){
        extrusion_cross_section(type, cornerHole);
        translate([0,-20,0]) vtriangle();
        translate([0,20,0]) rotate([0,0,180]) vtriangle();
        translate([10,10,0]) rotate([0,0,90]) vtriangle();
        translate([10,-10,0]) rotate([0,0,90]) vtriangle();
        translate([-10,10,0]) rotate([0,0,270]) vtriangle();
        translate([-10,-10,0]) rotate([0,0,270]) vtriangle();
      }
}
module ext2020(length){
  if (ext_type==0) {
    translate([-ext/2,ext/2,0]) extrusion(E2020, length, center=false);
    echo("E20",length);
  } else {
    translate([-ext/2,ext/2,0]) vslot2020(V2020, length, center=false);
    echo("V20",length);
  }
}
module ext2040(length){
  if (ext_type==0) {
    translate([-ext/2,ext,0]) extrusion(E2040, length, center=false);
    echo("E40",length);
  } else {
    translate([-ext/2,ext,0]) vslot2040(V2040, length, center=false);
    echo("V40",length);
  }
}
module tnut_m5(){
  t_len=11;
  t_tongue=0;
  difference(){
translate([-t_len/2,-5,0]) rotate([90,0,90]) linear_extrude(t_len) polygon([ [0,0], [2,0], [2,-t_tongue], [8,-t_tongue], [8,0], [10,0], [10,1.9], [8,3.8], [1.9,3.8], [0,1.9] ]);
    
    scale([tnut_nut_scale,tnut_nut_scale,1]) translate([0,0,0.7]) nut(M5_nut);
    translate([0,0,-1]) cylinder(h=5,d=5+2*printer_off);
    
  }
}
module joint_hole(jl=6,screw_l=joint_screw_len,print_upside=false,cut_nut=true){
  union(){
    // hole for thread
    rotate([0,0,0]) cylinder(h=screw_l,d=joint_screw_d+2*printer_off);
    // hole for head
    if (print_upside && bridge_support) {
      translate([0,0,-bridge_thickness]) rotate([180,0,0]) cylinder(h=jl-bridge_thickness,d=joint_screw_washer);
    } else {
      rotate([180,0,0]) cylinder(h=jl,d=joint_screw_washer);
    }
    // hole for hex tool
    translate([0,0,-jl]) rotate([180,0,0]) cylinder(h=40,d=5);
    if (cut_nut) {
      // cut tongue for rotating t-nut
      if (printed_corners_nut==1)
        translate([0,0,screw_l-joint_extr_depth+1]) cylinder(d=9, h=2, center=true);
      // cut tongue for long sliding t-nut
      if (printed_corners_nut==2)
        translate([0,0,screw_l-joint_extr_depth+1]) cube([7,12,2], center=true); // 12 - slide length
    }
  }
}
module joint1x1(){
  j1x1_len=20;
  color(pp_color) difference(){
    union(){
      // main shape
      linear_extrude(ext) polygon([[0,0], [j1x1_len,0], [j1x1_len,joint_screw_len-joint_extr_depth], [joint_screw_len-joint_extr_depth,j1x1_len], [0,j1x1_len]]);
      // positioning groove
      translate([0,0,ext/2]) rotate([180,-90,0]) vslot_groove(j1x1_len);
      translate([0,0,ext/2]) rotate([0,90,90]) vslot_groove(j1x1_len);
    }
    // screw holes
    translate([joint_space,joint_in_material,ext/2]) rotate([90,0,0]) joint_hole(j1x1_len);
    translate([joint_in_material,joint_space,ext/2]) rotate([0,-90,0]) joint_hole(j1x1_len);
  }
  
  echo("J1x1");
}
module joint2x2(){
  j2x2_len=40;
  color(pp_color) difference(){
    union(){
      // main shape
      linear_extrude(ext) polygon([[0,0], [j2x2_len,0], [j2x2_len,joint_screw_len-joint_extr_depth], [joint_screw_len-joint_extr_depth,j2x2_len], [0,j2x2_len]]);
      // positioning groove
      translate([0,0,ext/2]) rotate([180,-90,0]) vslot_groove(j2x2_len);
      translate([0,0,ext/2]) rotate([0,90,90]) vslot_groove(j2x2_len);
    }
    // screw holes
    translate([joint_space,joint_in_material,ext/2]) rotate([90,0,0]) joint_hole(j2x2_len);
    translate([joint_space+20,joint_in_material,ext/2]) rotate([90,0,0]) joint_hole(j2x2_len);
    translate([joint_in_material,joint_space,ext/2]) rotate([0,-90,0]) joint_hole(j2x2_len);
    translate([joint_in_material,joint_space+20,ext/2]) rotate([0,-90,0]) joint_hole(j2x2_len);

  }
  
  echo("J2x2");
}
module joint_bed(){
  jb_x=45;
  jb_y=65;
  slot_l=40;
  slot_w=12.5;
  slot_w2=5.2;
  slot_x=(base_w-build_plate_mount_space)/2-2.5*ext;
  slot_y=15;
  slot_z=5;

  color(pp_color) difference(){
    union(){
      // main shape
      cube([jb_x,jb_y,ext]);
      // positioning groove
      translate([0,0,ext/2]) rotate([180,-90,0]) vslot_groove(jb_x);
      translate([0,0,ext/2]) rotate([0,90,90]) vslot_groove(jb_y);
    }
    // screw holes
    translate([joint_space+4,joint_in_material,ext/2]) rotate([90,0,0]) joint_hole(jb_y);
    translate([jb_x-6.5,joint_in_material,ext/2]) rotate([90,0,0]) joint_hole(jb_y);
    translate([joint_in_material,joint_space,ext/2]) rotate([0,-90,0]) joint_hole(jb_x);
    translate([joint_in_material,slot_l+slot_y,ext/2]) rotate([0,-90,0]) joint_hole(jb_x);

    // slot
    translate([slot_x,slot_y,slot_z]) hull(){
      cylinder(h=ext-slot_z,d=slot_w);
      translate([0,slot_l,0]) cylinder(h=ext-slot_z,d=slot_w);
    }
    translate([slot_x,slot_y,0]) hull(){
      cylinder(h=slot_z,d=slot_w2);
      translate([0,slot_l,0]) cylinder(h=slot_z,d=slot_w2);
    }
  }
}
module bed_support(){
  jb_x=35;
  slot_l=40;
  jb_y=slot_l+20;
  slot_w=12.5;
  slot_w2=5.2;
  slot_x=(base_w-build_plate_mount_space)/2-2.5*ext;
  slot_y=(jb_y-slot_l)/2;
  slot_z=5;
  outer_d=(jb_x-slot_x)*2;

  color(pp_color) difference(){
    union(){
      // main shape
      hull(){
        cube([1,jb_y,ext]);
        translate([jb_x-outer_d/2,outer_d/2,0]) cylinder(h=ext,d=outer_d);
        translate([jb_x-outer_d/2,jb_y-outer_d/2,0]) cylinder(h=ext,d=outer_d);
      }
      // positioning groove
      translate([0,0,ext/2]) rotate([0,90,90]) vslot_groove(jb_y);
    }
    // screw holes
    translate([joint_in_material,13,ext/2]) rotate([0,-90,0]) joint_hole(jb_x);
    translate([joint_in_material,jb_y-13,ext/2]) rotate([0,-90,0]) joint_hole(jb_x);

    // slot
    translate([slot_x,slot_y,slot_z]) hull(){
      cylinder(h=ext-slot_z,d=slot_w);
      translate([0,slot_l,0]) cylinder(h=ext-slot_z,d=slot_w);
    }
    translate([slot_x,slot_y,0]) hull(){
      cylinder(h=slot_z,d=slot_w2);
      translate([0,slot_l,0]) cylinder(h=slot_z,d=slot_w2);
    }
  }
}
module joint_front(){
  jf_h=1*ext;
  jf_l=1.49*ext;
  color(pp_color) difference(){
    union(){
      // main shape
      linear_extrude(ext) polygon([[0,0], [jf_h,0], [jf_h,joint_in_material], [joint_in_material,jf_l], [joint_in_material/2,jf_l], [joint_in_material/2,jf_l-ext], [0,ext/2]]);
      // positioning groove
      translate([0,0,ext/2]) rotate([180,-90,0]) vslot_groove(jf_h);
      translate([0,0,ext/2]) rotate([0,90,90]) vslot_groove(ext/2);
    }
    // screw holes
    translate([joint_space,joint_in_material,ext/2]) rotate([90,0,0]) joint_hole(jf_l);
    //translate([joint_space+20,joint_in_material,ext/2]) rotate([90,0,0]) joint_hole(jf_l);
    translate([joint_in_material,1*ext,ext/2]) rotate([0,-90,0]) joint_hole(jf_h);
  }
  
  echo("JF");
}
module leadnut_cut(){
  color("#ffc81f") difference(){
    union(){
      // plate
      translate([0,0,-3.5]) intersection(){
        cylinder(h=3.5,d=22);
        translate([-6,-11,0]) cube([12,22,3.5]);
      }
      // cylinder
      translate([0,0,-5]) cylinder(h=15,d=10.25);
    }
    // hole for T8
    translate([0,0,-5]) cylinder(h=15,d=8);
    // holes for M3 screws
    translate([0,8,-3.5]) cylinder(h=3.5,d=3.5);
    translate([0,-8,-3.5]) cylinder(h=3.5,d=3.5);
  }
}
module printed_joints(){
  // joints
  // bottom - main frame
  translate([ext,ext,0]) rotate([0,0,0]) joint2x2();
  translate([base_w-ext,ext,0]) rotate([0,0,90]) joint2x2();
  translate([ext,base_d-2*ext,0]) rotate([0,0,-90]) joint2x2();
  translate([base_w-ext,base_d-2*ext,0]) rotate([0,0,180]) joint2x2();
  // bottom - Z pulley support
  translate([ext,z_pulley_support+0.5*ext,0]) rotate([0,0,0]) joint1x1();
  translate([base_w-ext,z_pulley_support+0.5*ext,0]) rotate([0,0,90]) joint1x1();
  //translate([ext,z_pulley_support-0.5*ext,0]) rotate([0,0,-90]) joint1x1();
  translate([base_w-ext,z_pulley_support-0.5*ext,0]) rotate([0,0,180]) joint1x1();
  // front
  translate([ext,ext,2*ext]) rotate([90,0,0]) joint2x2();
  translate([base_w-ext,ext,2*ext]) rotate([90,-90,0]) joint2x2();
  translate([base_w-ext,ext,base_h-2*ext]) rotate([90,180,0]) joint2x2();
  translate([ext,ext,base_h-2*ext]) rotate([90,90,0]) joint2x2();
  // left
  translate([ext,base_d-2*ext,ext]) rotate([90,0,-90]) joint2x2();
  translate([ext,base_d-2*ext,base_h-ext]) rotate([0,90,180]) joint2x2();
  translate([0,base_d,base_h-ext]) rotate([0,90,0]) joint2x2();
  // left - filament support
  translate([ext,base_d/2,ext]) rotate([90,0,-90]) joint1x1();
  translate([ext,base_d/2,base_h-ext]) rotate([0,90,180]) joint1x1();
  translate([ext,base_d/2+ext,ext]) rotate([0,-90,0]) joint1x1();
  translate([0,base_d/2+ext,base_h-ext]) rotate([0,90,0]) joint1x1();
  // right - filament support
  translate([base_w,base_d/2,ext]) rotate([90,0,-90]) joint1x1();
  translate([base_w,base_d/2,base_h-ext]) rotate([0,90,180]) joint1x1();
  translate([base_w,base_d/2+ext,ext]) rotate([0,-90,0]) joint1x1();
  translate([base_w-ext,base_d/2+ext,base_h-ext]) rotate([0,90,0]) joint1x1();
  // right
  translate([base_w,base_d-2*ext,ext]) rotate([90,0,-90]) joint2x2();
  translate([base_w,base_d-2*ext,base_h-ext]) rotate([0,90,180]) joint2x2();
  translate([base_w-ext,base_d,base_h-ext]) rotate([0,90,0]) joint2x2();
  // back
  translate([ext,base_d,ext]) rotate([90,0,0]) joint2x2();
  translate([ext,base_d-ext,base_h-ext]) rotate([-90,0,0]) joint2x2();
  translate([base_w-ext,base_d,base_h-ext]) rotate([90,180,0]) joint2x2();
  translate([base_w-ext,base_d,ext]) rotate([90,-90,0]) joint2x2();
  // back - electronics support
  translate([elec_support,base_d,ext]) rotate([90,0,0]) joint1x1();
  translate([base_w+ext-elec_support,base_d,ext]) rotate([90,0,0]) joint1x1();
  translate([elec_support,base_d-ext,base_h-ext]) rotate([-90,0,0]) joint1x1();
  translate([base_w+ext-elec_support,base_d-ext,base_h-ext]) rotate([-90,0,0]) joint1x1();
  translate([elec_support-ext,base_d,base_h-ext]) rotate([90,180,0]) joint1x1();
  translate([base_w-elec_support,base_d,base_h-ext]) rotate([90,180,0]) joint1x1();
  translate([elec_support-ext,base_d,ext]) rotate([90,-90,0]) joint1x1();
  translate([base_w-elec_support,base_d,ext]) rotate([90,-90,0]) joint1x1();
  // front joints near T8 screws
  translate([ext,2*ext,ext]) rotate([0,-90,0]) joint_front();
  translate([base_w,2*ext,ext]) rotate([0,-90,0]) joint_front();
  translate([0,2*ext,base_h-ext]) rotate([0,90,0]) joint_front();
  translate([base_w-ext,2*ext,base_h-ext]) rotate([0,90,0]) joint_front();
}
module frame(){
  // horizontal
  length_a=base_w-2*ext;
  echo(length_a=length_a);
  // front bottom (profile A)
  translate([ext,ext,0]) rotate([0,90,0]) rotate([0,0,90]) ext2040(length_a);
  // rear bottom (profile A)
  translate([ext,base_d-2*ext,0]) rotate([0,90,0]) ext2040(length_a);
  // rear top (profile A)
  translate([ext,base_d-2*ext,base_h-ext]) rotate([0,90,0]) ext2040(length_a);
  // front top (profile A)
  translate([ext,0,base_h]) rotate([0,90,0]) rotate([0,0,-90]) ext2040(length_a);
  // Z pulley support (profile A)
  translate([ext,z_pulley_support-ext/2,0]) rotate([0,90,0]) ext2020(length_a);

  // vertical
  length_b=base_h-2*ext;
  echo(length_b=length_b);
  // front left (profile B)
  translate([ext,0,ext]) ext2040(length_b);
  // front right (profile B)
  translate([base_w,0,ext]) ext2040(length_b);
  // back left (profile B)
  translate([ext,base_d-2*ext,ext]) ext2040(length_b);
  // back right (profile B)
  translate([base_w,base_d-2*ext,ext]) ext2040(length_b);
  // back support for electronics (profile B)
  translate([elec_support,base_d-ext,ext]) ext2020(length_b);
  translate([base_w+ext-elec_support,base_d-ext,ext]) ext2020(length_b);
  // left/right support for filament spool
  translate([ext,base_d/2,ext]) ext2020(length_b);
  translate([base_w,base_d/2,ext]) ext2020(length_b);

  length_d=base_d;
  echo(length_d=length_d);
  // bottom left (profile D)
  translate([ext,0,ext]) rotate([-90,0,0]) ext2020(length_d);
  // bottom right (profile D)
  translate([base_w,0,ext]) rotate([-90,0,0]) ext2020(length_d);

  length_e=top_d;
  echo(length_e=length_e);
  // top left (profile E)
  translate([ext,0,base_h]) rotate([-90,0,0]) ext2020(length_e);
  // top right (profile E)
  translate([base_w,0,base_h]) rotate([-90,0,0]) ext2020(length_e);

  // printed joints
  if (printed_corners) printed_joints();
}

module bmg_extruder(){
  bmg_color=[0.2, 0.2, 0.2];
  bmg_points=[[0,0],[42,0],[42,53],[19,53],[0,38]];
  translate([-21,-17,-21]) rotate([90,0,0]) color(bmg_color) linear_extrude(height=34, center=true) polygon(bmg_points);
  bmg_side_points=[[0,0],[20,0],[20,26],[16,54],[4,54],[0,26]];
  translate([20,-29,-3]) rotate([95,0,90]) color(bmg_color) linear_extrude(height=5, center=true) polygon(bmg_side_points);
}
module sailfin_extruder(part=0,clr="#00aaff"){
  // Zero at bottom of filament output
  // bounding box: x=-17.7:23.7
  //#translate([-17.7,-14.4,0]) cube([41.4,27.6,47.3]);

  // imported parts
  translate([-4.4,13.2,15]) rotate([0,-90,90]) color(clr){
    if ((part==0)||(part==1)) import("Sailfin-Extruder/STL/Front.stl");
    if ((part==0)||(part==2)) rotate([0,90,90]) import("Sailfin-Extruder/STL/Lever.stl");
    if ((part==0)||(part==3)) import("Sailfin-Extruder/STL/Mid.stl");
    if ((part==0)||(part==4)) import("Sailfin-Extruder/STL/Rear.stl");
  }

  if ($preview) {
    //screws
    // right mount
    translate([19,-2.9,7.1]) rotate([0,0,0]) screw(M3_cap_screw,10);
    //translate([16.1,-13,4.5]) rotate([90,0,0]) screw(M3_cap_screw,35);
    // left mount
    translate([-14,-2.9,7.1]) rotate([0,0,0]) screw(M3_cap_screw,10);
    //translate([-14.3,-6,3.4]) rotate([90,0,0]) screw(M3_cap_screw,30);
    // main gear
    translate([-4.4,10,15.0]) rotate([90,0,0]) color("gray"){
      cylinder(h=3,d=26);
      translate([0,0,-3]) cylinder(h=27,d=7);
    }
  }
}
module extruder_with_bmg(){
  translate([0,-36,-4]) rotate([0,0,90]) hot_end(E3Dv6, 1.75, bowden = false,resistor_wire_rotate = [0,0,0], naked = false);
  translate([-6,-12,8]) {
    rotate([90,0,0])NEMA(NEMA17S23);
    translate([0,-1,0])bmg_extruder();
  }
}
module nema14_round(){
  hole_distance=43.84;
  color("gray") {
    // bottom
    cylinder(h=4.3,d=36.5);
    // top
    difference(){
      union(){
        translate([0,0,16]) cylinder(h=4,d=36.5);
        hull(){
          m=51;
          translate([-hole_distance/2,0,18]) cylinder(h=2,d=m-hole_distance);
          translate([hole_distance/2,0,18]) cylinder(h=2,d=m-hole_distance);
          translate([0,13,18]) cylinder(h=2,d=7);
          translate([0,-13,18]) cylinder(h=2,d=7);
        }
      }
      translate([-hole_distance/2,0,18]) cylinder(h=2,d=2.6);
      translate([hole_distance/2,0,18]) cylinder(h=2,d=2.6);
    }
    // raised part
    translate([0,0,20]) cylinder(h=1.4,d=16);
    // shaft
    translate([0,0,20]) cylinder(d=2.5,h=5.5);
    // gear
    translate([0,0,22]) cylinder(h=4,d=6);
  }
  translate([0,0,4]) color("black") cylinder(h=12,d=34.9);
}
module omerod_sensor(){
  ow=24.2;
  oh=17.6;
  difference(){
    // pcb
    color("green") translate([-ow/2,-oh/2,0]) cube([ow,oh,1.5]);
    // mounting holes
    translate([-9.25,oh/2-2.65,0]) cylinder(h=1.5,d=3);
    translate([9.25,oh/2-2.65,0]) cylinder(h=1.5,d=3);
  }
  // socket
  translate([-2.4,oh/2-2.65,0]) rotate([0,0,0]) pin_header(2p54header, 3, 1);
  // capacitor
  translate([-1.7,-oh/2+3,0]) color("grey") cylinder(d=5.1,h=8.15);
}
module fpc30_pcb(screw_l=8){
  pcb_w=26;
  pcb_d=40;
  translate([-pcb_w/2,-pcb_d/2,0]) {
    difference(){
      color("green") cube([pcb_w,pcb_d,1.5]);

      //holes
      translate([9,2.5,0]) cylinder(h=1.5,d=3.25);
      translate([9,2.5+34.8,0]) cylinder(h=1.5,d=3.25);
    }
    translate([21,pcb_d/2,0]) rotate([0,0,90]) pin_header(2p54header, 15, 2);
    translate([3,pcb_d/2,1.5]) rotate([0,0,90]) flat_flex([[30,1.25], [37,1.5,2.5], [30,4.0,2.5], [36,0,2.5]]);

    // FPC board screws
    translate([9,2.5,1.5]) screw(M3_cap_screw,screw_l);
    translate([9,2.5+34.8,1.5]) screw(M3_cap_screw,screw_l);
  }
}
module blower_spacer(){
  bs_h=blower_depth(hotend_blower)-blower_lug(hotend_blower);
  color(pp_color2) difference(){
    cylinder(d=6,h=bs_h);
    cylinder(d=3+2*printer_off,h=bs_h);
  }
}
module blower_to_v6(blower_type=PE4020C){
  v6_d=22.3;
  v6_h=26;
  shroud_d=40;
  shroud_h=36;
  shroud_z_shift=1;
  color(pp_color) difference(){
    union(){
      // main shape
      hull(){
        // front
        translate([-10.5,-10,-13+7]) rotate([-90,0,0]) cube([21,26+7,0.1]);
        // back
        hull(){
          translate([-shroud_d/2+2.5,13,shroud_h/2-25-2.5+shroud_z_shift]) rotate([90,0,0]) cylinder(h=0.1,d=5);
          translate([-shroud_d/2+2.5,13,-shroud_h/2-25+2.5+shroud_z_shift]) rotate([90,0,0]) cylinder(h=0.1,d=5);
          translate([shroud_d/2-2.5,13,-shroud_h/2-25+2.5+shroud_z_shift]) rotate([90,0,0]) cylinder(h=0.1,d=5);
          translate([shroud_d/2-2.5,13,shroud_h/2-25-2.5+shroud_z_shift]) rotate([90,0,0]) cylinder(h=0.1,d=5);
        }
      }
      // blower mounts
      translate([20,33-13-7,-4]) rotate([-90,0,180])
        for (p=blower_screw_holes(blower_type))
          translate([p.x,p.y,0]) cylinder(h=7,d=6);
      // sensor mount
      translate([-13,0,-34]) rotate([90,0,0]) cylinder(h=20.5,d=4);
      translate([13,0,-34]) rotate([90,0,0]) cylinder(h=20.5,d=4);
    }

    // main air hole from blower
    hull(){
      translate([-v6_d/2,0,-14]) rotate([-90,0,0]) cube([v6_d,v6_h-2,0.1]);
      translate([-1.5,13,-24]) rotate([-90,0,0]) cylinder(d=28,h=0.1);
    }
    // hole for V6
    translate([0,0,-39-6]) cylinder(h=v6_h+0.3+6+printer_off,d=v6_d+2*printer_off);
    translate([0,0,-6-7]) cylinder(d=16+2*printer_off,h=7);
    // bottom hole
    translate([0,12.8-40/2,-39-6]) cylinder(d=40,h=6);
    // screw holes
    translate([20,33-13,-4]) rotate([-90,0,180])
      for (p=blower_screw_holes(blower_type)) {
        // holes for M3
        translate([p.x,p.y,7]) cylinder(h=7,d=3+2*printer_off);
        // holes for head of M3
        translate([p.x,p.y,14]) cylinder(h=10,d=6);
      }
    // air inlet
    translate([-v6_d/2+1,-10.1,-v6_h-13]) cube([v6_d-2,5.1,v6_h]);
    // space for V6 top mount
    translate([-13,-10-0.1,-7.5]) cube([26,22,2]);
    // sensor mount screw holes
    translate([-13,0,-34]) rotate([90,0,0]) cylinder(h=20.5,d=m2_hole);
    translate([13,0,-34]) rotate([90,0,0]) cylinder(h=20.5,d=m2_hole);
  }
}
module extruder_with_sailfin(){
  // coordinates relative to:
  // X: center of X carriage
  // Y: from start of Y carriage
  // Z: from top of Y carriage

  z_zero=cf_above_carriage+cf_tube_size+carriage_height(MGN12H_carriage);
  // hotend position
  hot_y=-43;
  hot_z=-4;
  // E3D
  translate([0,hot_y,hot_z]) rotate([0,0,180]) hot_end(E3Dv6, 1.75, bowden = false,resistor_wire_rotate = [0,0,0], naked = true);
  // hotend cooling fan
  translate([20,hot_y+33-(20-blower_depth(hotend_blower)),hot_z-4.0]) rotate([-90,0,180]) blower(hotend_blower);
  // cooling fan shroud
  translate([0,hot_y,hot_z]) blower_to_v6();
  // part cooling fans
  translate([0,-5,-48]) rotate([90,0,90]) {
    blower(PE4020C);
    translate([40,0,0]) rotate([0,180,0]) blower(PE4020C);
  }
  // fpc socket board
  translate([4,40,fpc_z-carriage_height(MGN12H_carriage)]) rotate([-90,0,0]) fpc30_pcb();
  // X endstop
  translate([3.5,28.5,62]) rotate([-90,0,-90]) optical_endstop(screws=true);
  // omerod sensor
  translate([0,hot_y-19,hot_z-49]) rotate([90,0,0]) omerod_sensor(); // 3.5mm from block
  // Sailfin extruder
  translate([0,hot_y,2]) rotate([0,0,0]) sailfin_extruder(clr=pp_color2);
  // motor
  translate([5.5,hot_y+33,28.5]) rotate([90,50,0]) nema14_round();

  // screws
  // rear fan screw
  translate([17.5-1.5,32,-10]) rotate([0,90,0]) {
    screw(M3_cap_screw,35);
    translate([0,0,-34.5]) nut(M3_nut);
  }
  // front fan screw
  translate([17.5-1.5,32-35.25,-10]) rotate([0,90,0]) {
    screw(M3_cap_screw,35);
    translate([0,0,-34.5]) nut(M3_nut);
  }
  // MGN9 screws
  for (i=[0:3])
    translate([MGN9_holes[i].x,MGN9_holes[i].y+carriage_width(MGN9H_carriage)/2+cf_from_front,carriage_height(MGN9H_carriage)+cf_above_carriage+20+2.5]) screw(M3_cs_cap_screw,6);
  // hotend blower screws and spacers
  for (p=blower_screw_holes(hotend_blower)) {
    translate([20,33-13+hot_y,-4+hot_z]) rotate([-90,0,180]) translate([p.x,p.y,14]) screw(M3_cap_screw,30);
    translate([20,33.3+hot_y,-4+hot_z]) rotate([-90,0,180]) translate([p.x,p.y,14]) blower_spacer();
  }
  // sensor screws to shroud
  translate([-13,-21+hot_y,-34+hot_z]) rotate([90,0,0]) screw(M2_cap_screw,10);
  translate([13,-21+hot_y,-34+hot_z]) rotate([90,0,0]) screw(M2_cap_screw,10);
}
module extruder_mount_base_mgn9(){
  plate_w=36;
  plate_h=67;
  plate_d=gantry_belt_pos-cf_from_front-2.5; // 2.5=2xbelt thickness
  mgn9plate_z=cf_above_carriage+20+carriage_height(MGN9H_carriage);
  color(pp_color2) difference(){
    union(){
      translate([-plate_w/2,cf_from_front,0]){
        // back plate
        translate([0,plate_d-4,-5]) cube([plate_w,4,plate_h]);
        // mgn mount
        translate([0,-1,mgn9plate_z]) cube([plate_w,plate_d,2.5]); // or 4.5
        // bottom plate
        translate([0,-11,-2-3]) cube([plate_w,plate_d+11,3]);
      }
      // reinforcements
      translate([0,plate_d+1,-2]) rotate([90,0,-90]) triangle(h=plate_w,a=3);
      translate([0,plate_d+1,mgn9plate_z+2.5]) rotate([90,0,-90]) triangle(h=plate_w,a=3);
      translate([0,plate_d+1,mgn9plate_z]) rotate([-90,0,-90]) triangle(h=plate_w,a=3);
      // X endstop mount plate
      translate([-1.5,cf_from_front-1,mgn9plate_z+2.5]) cube([3,plate_d,26]);
      translate([1.5,cf_from_front-1,mgn9plate_z+2.5+16]) cube([2,6,10]);
      translate([1.5,cf_from_front+plate_d-10,mgn9plate_z+2.5+16]) cube([2,6,10]);
      //fan back mounts
      hull(){
        translate([13,32,-10]) rotate([0,90,0]) cylinder(h=3,d=7);
        translate([13,30,-4]) rotate([0,90,0]) cylinder(h=3,d=7);
      }
      hull(){
        translate([-13,32,-10]) rotate([0,-90,0]) cylinder(h=3,d=7);
        translate([-13,30,-4]) rotate([0,-90,0]) cylinder(h=3,d=7);
      }
      // fan front mounts
      translate([-13-1.5,-6,-5]) rotate([0,90,0]) triangle(h=3,a=13);
      translate([13+1.5,-6,-5]) rotate([0,90,0]) triangle(h=3,a=13);
      // front bottom mounting
      translate([plate_w/2-3.5,-6,-5+3.5]) rotate([-90,0,0]) cylinder(d=7,h=9);
      translate([-plate_w/2+3.5,-6,-5+3.5]) rotate([-90,0,0]) cylinder(d=7,h=9);
      // belt mount
      translate([-15,gantry_belt_pos-2.5,beltx_shift-22]) cube([30,5,46]);
      // lowet zip tie mount
      translate([-5,gantry_belt_pos-2.5,0]) cube([10,5,16]);
    }
    // HOLES

    // lower cable hole
    translate([0,35,-3]) rotate([45,0,0]) translate([-10,-15,0]) cube([20,30,3]);
    // upper cable hole
    translate([-2,43,58]) rotate([0,0,0]) translate([-10,-15,0]) cube([10,10,2.5]);
    // lowet zip tie hole
    translate([-5,gantry_belt_pos-2.5,4]) cube([10,3,5]);
    // belt mount vertical hole
    translate([-5,gantry_belt_pos-2.5,beltx_shift-15]) cube([10,5,31]);
    // belt mount holes
    translate([-plate_w/2,gantry_belt_pos-2.5,beltx_shift-12]) cube([plate_w,2.5,11]);
    translate([-plate_w/2,gantry_belt_pos-2.5,belty_shift-12]) cube([plate_w,2.5,11]);
     // X endstop screw holes
    for (i=[0:1])
      translate([7,28.5-optical_endstop_holes[i].x,-optical_endstop_holes[i].y+62]) rotate([0,-90,0]) cylinder(h=10,d=m3_hole);
    // zip tie holes behind endstop
    translate([-1.5,25,48]) rotate([0,0,0]) cube([3,3,3]);
    translate([-1.5,25,39]) rotate([0,0,0]) cube([3,3,3]);
    translate([-1.5,15.5,48]) rotate([0,0,0]) cube([3,3,3]);
    translate([-1.5,15.5,39]) rotate([0,0,0]) cube([3,3,3]);
    translate([-1.5,6,48]) rotate([0,0,0]) cube([3,3,3]);
    translate([-1.5,6,39]) rotate([0,0,0]) cube([3,3,3]);
    // holes for MGN9 screwa
    for (i=[0:3])
      translate([MGN9_holes[i].x,MGN9_holes[i].y+carriage_width(MGN9H_carriage)/2+cf_from_front,carriage_height(MGN9H_carriage)+cf_above_carriage+20]) {
        translate([0,0,0.5]) cylinder(d2=6.5,d1=3,h=2);
        cylinder(d=3,h=0.5);
      }
    // FPC holes
    translate([4+9-13,40-2,20+1.5]) rotate([90,0,0]) {
      cylinder(h=10,d=m3_hole);
      translate([0,34.8,0]) cylinder(h=10,d=m3_hole);
    }
  }
}
module extruder(){
  if (hotend_type==0) {
    translate([0,-18,10]) extruder_with_bmg();
  } else
  if (hotend_type==1) {
    extruder_mount_base_mgn9();
    extruder_with_sailfin();
  }
}
module pulley_spacer(h=1) {
  color(pp_color2) difference(){
    cylinder(d=7,h=h);
    cylinder(d=5+2*printer_off,h=h);
  }
}
module pulley_support_front_down(logo=0){
  color(pp_color) difference(){
    union(){
      // front
      cube([4.5*ext,ext,beltx_shift-1]);
      // side
      cube([ext-4,3.5*ext,beltx_shift-1]);
      // v-slot side
      translate([ext/2,0,0]) rotate([-90,0,0]) vslot_groove(y_rails_from_front-1);
      // v-slot front
      translate([ext,ext/2,0]) rotate([-90,0,-90]) vslot_groove(3.5*ext);
      // pulley support
      //translate([ext/2,ext/2,beltx_shift-1]) cylinder(d1=9,d2=7,h=1);
    }
    // logo
    if (logo==1) translate([1.75*ext,1,ext/2]) rotate([90,0,0]) scale([2,2,1]) vn_logo(1);
    // hole for linear rail
    translate([(ext-12)/2-2*printer_off,ext*2.5-1,0]) cube([12+2*printer_off,ext+1,8.10]);
    // pulley screw hole
    translate([ext/2,ext/2,-3]) cylinder(h=belty_shift+3,d=m5_hole);
    // front right hole
    translate([ext*4,ext/2,35-joint_extr_depth]) rotate([180,0,00]) joint_hole(15,35,true);
    // front left hole
    translate([ext*1.5,ext/2,70-joint_extr_depth]) rotate([180,0,00]) joint_hole(15,70,true);
    // left front hole
    translate([ext/2,ext,35-joint_extr_depth]) rotate([180,0,00]) joint_hole(15,35,true);
    // left back hole
    translate([ext/2,ext*2,70-joint_extr_depth]) rotate([180,0,00]) joint_hole(15,70,true);
    // M3 hole
    translate([ext/2,ext*2.5+12.5,-5]) {
      cylinder(d=3,h=35);
      translate([0,0,35+bridge_thickness]) cylinder(d=9.5,h=10);
    }
  }
}
module pulley_support_front_up(){
  belts_h=30;
  belt_w=6;
  fh=belts_h+5+3;
  color(pp_color2) translate([0,0,beltx_shift-1]) difference(){
    union(){
      // front
      hull(){
        cube([3*ext,ext,0.2]);
        translate([0,0,fh-0.2]) cube([2*ext,ext,0.2]);
      }
      // side
      hull(){
        cube([ext-4,3.5*ext,0.2]);
        translate([0,0,fh-0.2]) cube([ext-4,2.3*ext,0.2]);
      }
    }
    
    // hole for pulleys
    translate([ext/2,ext/2,0]) difference(){
      cylinder(d=20,h=belts_h);
      translate([0,0,belts_h-1]) cylinder(d=7,h=1);
    }
    // hole for left belt
    cube([belt_w,3.5*ext,belts_h]);
    // hole for front belt
    cube([3*ext,belt_w,belts_h]);
    // screws
    translate([0,0,-beltx_shift+1]) {
      // front left hole
      translate([ext*1.5,ext/2,70-joint_extr_depth]) rotate([180,0,00]) joint_hole(15,70,true);
      // left front hole
      translate([ext/2,ext,35-joint_extr_depth]) rotate([180,0,00]) joint_hole(8,35,true);
      // left back hole
      translate([ext/2,ext*2,70-joint_extr_depth]) rotate([180,0,00]) joint_hole(15,70,true);
      // pulley hole
      translate([ext/2,ext/2,70]) rotate([180,0,00]) joint_hole(15,50,true);
    }
    // hole for M3 allen key
    translate([ext/2,ext*2.5+12.5,0]) cylinder(h=fh,d=5);
    // rounded corner
    round_corner(r=10,h=fh);
  }
}
module pulley_support_front(side=0,logo=0){
  mirror([side,0,0]) {
    if ($preview) {
      // pulley support
      m5_screw1=50;
      translate([ext/2,ext/2,m5_screw1+20]) screw(M5_cap_screw,m5_screw1);
      // screw for linear rail
      m3_screw1=35;
      translate([ext/2,ext*2.5+12.5,m3_screw1-5]) screw(M3_cap_screw,m3_screw1);
      // left front
      m5_screw4=35;
      translate([ext/2,ext*1,m5_screw4-5]) screw(M5_cap_screw,m5_screw4);
      // left back
      m5_screw5=70;
      translate([ext/2,ext*2,m5_screw5-5]) screw(M5_cap_screw,m5_screw5);
      // front left
      m5_screw2=70;
      translate([ext*1.5,ext/2,m5_screw2-5]) screw(M5_cap_screw,m5_screw2);
      // front right
      m5_screw3=35;
      translate([ext*4,ext/2,m5_screw3-5]) screw(M5_cap_screw,m5_screw3);
    }
    // block body
    pulley_support_front_down(logo);
    pulley_support_front_up();
    // pulley spacers
    translate([ext/2,ext/2,beltx_shift-1]) pulley_spacer(1);
    translate([ext/2,ext/2,beltx_shift+13]) pulley_spacer(2);
  }
}
module motor_support_x_down(){
  yadj=16; // motor position adjust range
  mm_d=top_d-base_d+ext; // motor mount depth
  color(pp_color) difference(){
    union(){
      // left
      translate([0,0,0]) cube([ext,mm_d,x_motor_z]);
      // front
      translate([0,0,0]) cube([5*ext,ext,x_motor_z]);
      // top
      translate([0,0,x_motor_z]) cube([5*ext,mm_d,3]);
      // back
      translate([0,mm_d,0]) rotate([90,0,0]) linear_extrude(5.5) polygon([[0,0],[ext,0],[5*ext,x_motor_z-10],[5*ext,x_motor_z],[0,x_motor_z]]);
      // v-slot left
      translate([ext/2,0,0]) rotate([-90,0,0]) vslot_groove(mm_d);
      // v-slot front
      translate([ext,ext/2,0]) rotate([-90,0,-90]) vslot_groove(4*ext);
      // outer pulley spacer
      translate([xy_o_pulley_pos.x,xy_o_pulley_pos.y-base_d+ext,x_motor_z+3]) cylinder(h=beltx_shift-x_motor_z-3,d2=7,d1=9);
      // inner pulley spacer
      translate([xy_i_pulley_pos.x,xy_i_pulley_pos.y-base_d+ext,x_motor_z+3]) cylinder(h=beltx_shift-x_motor_z-3,d2=7,d1=9);
    }
    // corner screw hole
    translate([ext/2,ext/2,35-joint_extr_depth]) rotate([180,0,00]) joint_hole(10,35);
    // right screw hole
    translate([4.5*ext,ext/2,35-joint_extr_depth]) rotate([180,0,00]) joint_hole(10,35);
    // back screw hole
    translate([ext/2,3*ext,60-joint_extr_depth]) rotate([180,0,00]) joint_hole(10,60);
    // middle front screw hole
    translate([1.5*ext,ext/2,60-joint_extr_depth]) rotate([180,0,00]) joint_hole(10,60);
    // motor mount holes
    translate([xy_motor_pos.x,xy_motor_pos.y-base_d+ext,x_motor_z]){
      // slots for screws
      NEMA_screw_positions(NEMA17M) hull(){
        translate([-yadj/2,0,0]) cylinder(h=3,d=3.2);
        translate([yadj/2,0,0]) cylinder(h=3,d=3.2);
      }
      hull(){
        translate([-yadj/2,0,0]) cylinder(h=3,d=22.5);
        translate([yadj/2,0,0]) cylinder(h=3,d=22.5);
      }
    }
    // outer pulley hole
    translate([xy_o_pulley_pos.x,xy_o_pulley_pos.y-base_d+ext,0]) cylinder(h=beltx_shift,d=m5_hole);
    // inner pulley hole
    translate([xy_i_pulley_pos.x,xy_i_pulley_pos.y-base_d+ext,0]) cylinder(h=beltx_shift,d=m5_hole);
  }
}
module motor_support_x_up(){
  yadj=16; // motos position adjust range
  mm_d=top_d-base_d+ext; // motor mount depth
  h_space=pulley_height(GT2_10x20_plain_idler)+(beltx_shift-x_motor_z-3)+1;
  color(pp_color2) difference(){
    translate([0,0,x_motor_z+3]) union(){
      // main body
      difference(){
        // main body
        linear_extrude(x_motor_z-9) polygon([[ext,0],[0,ext],[0,mm_d],[ext,mm_d],[2*ext,ext],[2*ext,0]]);
  
        //belt path
        hull(){
          translate([xy_o_pulley_pos.x,xy_o_pulley_pos.y-base_d+ext,0]) cylinder(h=h_space,d=22);
          translate([xy_i_pulley_pos.x,xy_i_pulley_pos.y-base_d+ext,0]) cylinder(h=h_space,d=22);
          translate([xy_motor_pos.x,xy_o_pulley_pos.y-base_d+ext,0]) cylinder(h=h_space,d=22);
          translate([ext/2,ext,0]) cylinder(h=h_space,d=22);
        }
      }
      // outer pulley spacer
      translate([xy_o_pulley_pos.x,xy_o_pulley_pos.y-base_d+ext,h_space-1]) cylinder(h=1,d=7);
      // inner pulley spacer
      translate([xy_i_pulley_pos.x,xy_i_pulley_pos.y-base_d+ext,h_space-1]) cylinder(h=1,d=7);
    }

     // back screw hole
    translate([ext/2,3*ext,60-joint_extr_depth]) rotate([180,0,00]) joint_hole(10,60,true);
     // middle front screw hole
    translate([1.5*ext,ext/2,60-joint_extr_depth]) rotate([180,0,00]) joint_hole(10,60,true);
    // outer pulley hole
    translate([xy_o_pulley_pos.x,xy_o_pulley_pos.y-base_d+ext,60-joint_extr_depth]) rotate([180,0,00]) joint_hole(10,60,true);
    // inner pulley hole
    translate([xy_i_pulley_pos.x,xy_i_pulley_pos.y-base_d+ext,60-joint_extr_depth]) rotate([180,0,00]) joint_hole(10,60,true);
    // corner screw hole
    translate([ext/2,ext/2,35-joint_extr_depth]) rotate([180,0,00]) joint_hole(22,35);

  }
}
module motor_support_x(){
  if ($preview) {
    // rear mount
    m5_screw0=60;
    translate([ext/2,base_d+2*ext,base_h+m5_screw0-5]) screw(M5_cap_screw,m5_screw0);
    // pulley support back
    m5_screw1=40;
    translate([xy_o_pulley_pos.x,xy_o_pulley_pos.y,base_h+m5_screw1+15]) screw(M5_cap_screw,m5_screw1);
    // pulley support front
    m5_screw2=40;
    translate([xy_i_pulley_pos.x,xy_i_pulley_pos.y,base_h+m5_screw2+15]) screw(M5_cap_screw,m5_screw2);
    // corner
    m5_screw3=35;
    translate([ext/2,base_d-ext/2,base_h+m5_screw3-5]) screw(M5_cap_screw,m5_screw3);
    // front left
    m5_screw4=60;
    translate([1.5*ext,base_d-ext/2,base_h+m5_screw4-5]) screw(M5_cap_screw,m5_screw4);
    // front right
    m5_screw5=35;
    translate([4.5*ext,base_d-ext/2,base_h+m5_screw5-5]) screw(M5_cap_screw,m5_screw5);
    // motor screws
    translate([xy_motor_pos.x,xy_motor_pos.y,base_h+x_motor_z+3]) NEMA_screw_positions(NEMA17M) screw(M3_cap_screw,8);
  }
  translate([0,base_d-ext,base_h]) motor_support_x_down();
  translate([0,base_d-ext,base_h]) motor_support_x_up();
}
module motor_support_y_up(){
  yadj=16; // motor position adjust range
  mm_d=top_d-base_d+ext; // motor mount depth
  h_space=pulley_height(GT2_10x20_plain_idler)+(belty_shift-y_motor_z-3)+1;
  color(pp_color2) difference(){
    translate([base_w,0,y_motor_z+3]) union(){
      // main body
      mirror([1,0,0]) difference(){
        // main body
        linear_extrude(h_space+8) polygon([[ext,0],[0,ext],[0,mm_d],[ext,mm_d],[2*ext,ext],[2.75*ext,ext/2],[2.75*ext,0]]);
        //belt path
        hull(){
          translate([xy_o_pulley_pos.x,xy_o_pulley_pos.y-base_d+ext,0]) cylinder(h=h_space,d=22);
          translate([xy_motor_pos.x,xy_o_pulley_pos.y-base_d+ext,0]) cylinder(h=h_space,d=22);
          translate([ext/2,ext,0]) cylinder(h=h_space,d=22);
        }
        // hole for inner pulley
        translate([xy_i_pulley_pos.x,xy_i_pulley_pos.y-base_d+ext,0]) cylinder(h=h_space,d=22);
      }
      // outer pulley spacer
      translate([-xy_o_pulley_pos.x,xy_o_pulley_pos.y-base_d+ext,h_space-1]) cylinder(h=1,d=7);
      // inner pulley spacer
      translate([-xy_i_pulley_pos.x,xy_i_pulley_pos.y-base_d+ext,h_space-1]) cylinder(h=1,d=7);
    }

     // back screw hole
    translate([base_w-ext/2,3*ext,70-joint_extr_depth]) rotate([180,0,0]) joint_hole(15,70,true);
     // middle front screw hole
    translate([base_w-1.5*ext,ext/2,70-joint_extr_depth]) rotate([180,0,0]) joint_hole(15,70,true);
    // outer pulley hole
    translate([base_w-xy_o_pulley_pos.x,xy_o_pulley_pos.y-base_d+ext,75-joint_extr_depth]) rotate([180,0,0]) joint_hole(10,60,true);
    // inner pulley hole
    translate([base_w-xy_i_pulley_pos.x,xy_i_pulley_pos.y-base_d+ext,75-joint_extr_depth]) rotate([180,0,0]) joint_hole(10,60,true);
    // corner screw hole
    translate([base_w-ext/2,ext/2,35-joint_extr_depth]) rotate([180,0,00]) joint_hole(37,35);
    // hole for FPC board
    translate([fpc_x-4,0,fpc_z-17.5+34.8]) rotate([-90,0,0]) cylinder(d=m3_hole,h=ext);

  }
}
module motor_support_y_down(){
  yadj=16; // motor position adjust range
  mm_d=top_d-base_d+ext; // motor mount depth
  top_h=3; // thickness of top plate
  color(pp_color) difference(){
    union(){
      // right
      translate([base_w-ext,0,0]) cube([ext,mm_d,y_motor_z+top_h]);
      // front
      translate([base_w-5*ext,0,0]) cube([5*ext,ext,y_motor_z]);
      // top
      translate([base_w-5*ext,0,y_motor_z]) cube([5*ext,mm_d,top_h]);
      // back
      translate([base_w,mm_d-5.5,0]) rotate([90,0,180]) linear_extrude(5.5) polygon([[0,0],[ext,0],[5*ext,y_motor_z-10],[5*ext,y_motor_z],[0,y_motor_z]]);
      // v-slot left
      translate([base_w-ext/2,0,0]) rotate([-90,0,0]) vslot_groove(mm_d);
      // v-slot front
      translate([base_w-ext,ext/2,0]) rotate([-90,0,90]) vslot_groove(4*ext);
    }
    // corner screw hole
    translate([base_w-ext/2,ext/2,50-joint_extr_depth]) rotate([180,0,00]) joint_hole(15,50,print_upside=true);
    // left screw hole
    translate([base_w-4.5*ext,ext/2,45-joint_extr_depth]) rotate([180,0,00]) joint_hole(15,45,print_upside=true);
    // back screw hole
    translate([base_w-ext/2,3*ext,70-joint_extr_depth]) rotate([180,0,00]) joint_hole(10,70,print_upside=true);
    // middle front screw hole
    translate([base_w-1.5*ext,ext/2,70-joint_extr_depth]) rotate([180,0,00]) joint_hole(10,70);
    // motor mount holes
    translate([base_w-xy_motor_pos.x,xy_motor_pos.y-base_d+ext,y_motor_z]){
      // slots for screws
      NEMA_screw_positions(NEMA17M) hull(){
        translate([-yadj/2,0,0]) cylinder(h=3,d=3.2);
        translate([yadj/2,0,0]) cylinder(h=3,d=3.2);
      }
      hull(){
        translate([-yadj/2,0,0]) cylinder(h=3,d=22.5);
        translate([yadj/2,0,0]) cylinder(h=3,d=22.5);
      }
    }
    // outer pulley hole
    translate([base_w-xy_o_pulley_pos.x,xy_o_pulley_pos.y-base_d+ext,-6]) cylinder(h=belty_shift+6,d=m5_hole);
    // inner pulley hole
    translate([base_w-xy_i_pulley_pos.x,xy_i_pulley_pos.y-base_d+ext,0]) cylinder(h=belty_shift,d=m5_hole);
    // mount holes for Y end stop
    translate([base_w-ext-1.5,0,ext]) rotate([-90,0,0]) cylinder(h=ext,d=m3_hole);
    translate([base_w-ext-1.5,0,ext+20]) rotate([-90,0,0]) cylinder(h=ext,d=m3_hole);
    // hole for endstop cable10x6
    translate([base_w-ext-7,0,5]) cube([7,ext,11]);
    // hole for FPC board
    translate([fpc_x-4,0,fpc_z-17.5]) rotate([-90,0,0]) cylinder(d=m3_hole,h=ext);
  }
}
module motor_spacer_y(){
  pulley_spacer(belty_shift-y_motor_z-3);
}
module motor_support_y(){
  if ($preview) {
    // rear mount
    m5_screw0=70;
    translate([base_w-ext/2,base_d+2*ext,base_h+m5_screw0-5]) screw(M5_cap_screw,m5_screw0);
    // pulley support back
    m5_screw1=40;
    translate([base_w-xy_o_pulley_pos.x,xy_o_pulley_pos.y,base_h+m5_screw1+30]) screw(M5_cap_screw,m5_screw1);
    // pulley support front
    m5_screw2=40;
    translate([base_w-xy_i_pulley_pos.x,xy_i_pulley_pos.y,base_h+m5_screw2+30]) screw(M5_cap_screw,m5_screw2);
    // corner
    m5_screw3=50;
    translate([base_w-ext/2,base_d-ext/2,base_h+m5_screw3-5]) screw(M5_cap_screw,m5_screw3);
    // front right
    m5_screw4=70;
    translate([base_w-1.5*ext,base_d-ext/2,base_h+m5_screw4-5]) screw(M5_cap_screw,m5_screw4);
    // front left
    m5_screw5=45;
    translate([base_w-4.5*ext,base_d-ext/2,base_h+m5_screw5-5]) screw(M5_cap_screw,m5_screw5);
    // motor screws
    translate([base_w-xy_motor_pos.x,xy_motor_pos.y,base_h+y_motor_z+3]) NEMA_screw_positions(NEMA17M) screw(M3_cap_screw,8);
  }
  translate([0,base_d-ext,base_h]) motor_support_y_down();
  translate([0,base_d-ext,base_h]) motor_support_y_up();

  // outer pulley spacer
  translate([base_w-xy_o_pulley_pos.x,xy_o_pulley_pos.y,base_h+y_motor_z+3]) motor_spacer_y();
  // inner pulley spacer
  translate([base_w-xy_i_pulley_pos.x,xy_i_pulley_pos.y,base_h+y_motor_z+3]) motor_spacer_y();
}
module motor_support_z(){
  mot_bot=z_belt_h-ext-5.5;
  msl=20; // mount screw length
  color(pp_color) union(){
    difference(){
      union(){
        // main body
        cube([ext+44+2,ext+44,mot_bot+3]);
        // v-slot
        translate([ext/2,0,0]) rotate([-90,0,0]) vslot_groove(ext+44);
        translate([ext,44+ext/2,0]) rotate([-90,0,-90]) vslot_groove(44);
      }
      // motor body
      translate([ext,0,0]) cube([44,44,mot_bot]);
      // motor screw holes
      translate([ext+22,22,mot_bot]) NEMA_screw_positions(NEMA17M) cylinder(h=3,d=3.2);
      // shaft motor hole
      translate([ext+22,22,mot_bot]) cylinder(h=3,d=22.5);
      // side triangle
      translate([ext+44+2,0,mot_bot-5]) rotate([-155,0,180]) cube([2,60,40]);

      // mount screws
      translate([ext/2,ext/2,msl-joint_extr_depth]) rotate([180,0,0]) joint_hole(20,msl,true);
      translate([ext/2,ext/2+44,msl-joint_extr_depth]) rotate([180,0,0]) joint_hole(20,msl,true);
      translate([ext/2+44,ext/2+44,msl-joint_extr_depth]) rotate([180,0,0]) joint_hole(20,msl,true);
    }
  }
}
module cf_m3_mount_jig(){
  a=cf_tube_size-2*cf_tube_wall-2;
  b=16;
  difference(){
    cube([a,a,b]);

    // hole for M6 threaded rod
    translate([a/2,a/2,0]) cylinder(h=b,d=5.2);
    // hole for M3 nut
    translate([a/2-2.82,0,b/2]) cube([5.45+0.2,4,b/2]);
    // hole for washer
    translate([a/2-4,0,b/2-1]) cube([8,1,b/2+1]);
  }
}
module gantry_joint_l_vslot(pulx, puly){
  // screws
  if ($preview) {
    // Y pulley
    m5_screw1=40;
    translate([puly.x,puly.y,puly.z+15]) screw(M5_cap_screw,m5_screw1);
    // X pulley
    m5_screw2=40;
    translate([pulx.x,pulx.y,m5_screw2+3]) screw(M5_cap_screw,m5_screw2);
    // back 2020 mounting
    m5_screw3=25;
    translate([ext/2,carriage_length(y_rail_carriage),ext/2+3]) rotate([-90,0,0]) screw(M5_cap_screw,m5_screw3);
    // front 2020 mounting
    m5_screw4=10;
    translate([ext/2,0,ext/2+3]) rotate([90,0,0]) screw(M5_cap_screw,m5_screw4);
    // carriage inner mount
    m3_screw1=6;
    translate([ext,13,m3_screw1-3]) screw(M3_cs_cap_screw,m3_screw1);
    m3_screw3=20;
    translate([ext,33,m3_screw3-3]) screw(M3_cap_screw,m3_screw3);
    // carriage outer mount
    m3_screw2=25;
    translate([0,13,m3_screw2-3]) screw(M3_cap_screw,m3_screw2);
    translate([0,33,m3_screw2-3]) screw(M3_cap_screw,m3_screw2);
  }

  // box
  rd=5;
  box_h=puly.z;
  translate([-(carriage_width(y_rail_carriage)-ext)/2,0,0]) {
    //#cube([carriage_width(y_rail_carriage),carriage_length(y_rail_carriage),40]);
    // lower part
    difference(){
      hull(){
        translate([rd,rd,0]) cylinder(h=box_h,r=rd);
        translate([rd,carriage_length(y_rail_carriage)-rd,0]) cylinder(h=box_h,r=rd);
        translate([carriage_width(y_rail_carriage)-rd,carriage_length(y_rail_carriage)-rd,0]) cylinder(h=box_h,r=rd);
        translate([carriage_width(y_rail_carriage)-rd+2,25,0]) cylinder(h=box_h,r=rd);
        translate([carriage_width(y_rail_carriage)-1+2,0,0]) cube([1,1,box_h]);
      }
    }
  }

}
module gantry_joint_l_cf(){
  under_screw_pos=2*ext;
  py_x=ext/2; // x of Y pulley
  px_x=py_x+belt_x_separation; // x of X pulley
  px_y=gantry_belt_pos+pr20;
  py_y=gantry_belt_pos-pr20;
  px_z=beltx_shift-carriage_height(y_rail_carriage);
  py_z=belty_shift-carriage_height(y_rail_carriage);
  // screws
  m5_screw1=35; // Y pulley
  m5_screw2=50; // X pulley
  m5_screw3=20; // back
  m5_screw4=10; // front
  m5_screw5=8; // bottom
  m5_screw6=30; // top
  m3_screw1=6; // carriage short
  m3_screw3=20; // carriage inner
  m3_screw2=25; // carriage outer
  m3_1=[20,12.7]; // inner front
  m3_2=[20,32.7]; // inner back
  m3_3=[0,12.7]; // outer front
  m3_4=[0,32.7]; // outer back
  if ($preview) {
    // Y pulley
    translate([py_x,py_y,m5_screw1+22]) screw(M5_cap_screw,m5_screw1);
    // X pulley
    translate([px_x,px_y,m5_screw2+7]) screw(M5_cap_screw,m5_screw2);
    // back cf mounting
    translate([ext/2-3,cf_tube_size+cf_from_front-6+m5_screw3,ext/2+cf_above_carriage]) rotate([-90,0,0]) screw(M5_cap_screw,m5_screw3);
    // front cf mounting
    translate([ext/2,1.2,ext/2+cf_above_carriage]) rotate([90,0,0]) screw(M5_dome_screw,m5_screw4);
    // bottom cf mount
    translate([under_screw_pos,cf_tube_size/2+cf_from_front,cf_above_carriage-1.5]) rotate([180,0,0]) screw(M5_dome_screw,m5_screw5);
    // carriage inner mount
    translate([m3_1.x,m3_1.y,cf_above_carriage]) screw(M3_cs_cap_screw,m3_screw1);
    translate([m3_2.x,m3_2.y,m3_screw3-3]) screw(M3_cap_screw,m3_screw3);
    // carriage outer mount
    translate([m3_3.x,m3_3.y,cf_above_carriage]) screw(M3_cs_cap_screw,m3_screw1);
    translate([m3_4.x,m3_4.y,m3_screw2-3]) screw(M3_cap_screw,m3_screw2);
    // top mount
    translate([py_x+3,5,cf_above_carriage+cf_tube_size+m5_screw6+3]) screw(M5_cap_screw,m5_screw6);
  }

  // mount
  rd=5; // radius of rounding
  box_h=cf_above_carriage+cf_tube_size;
  x_offset=-(carriage_width(y_rail_carriage)-ext)/2; // how much carriage sticks out of frame
  color(pp_color) difference(){
    union(){
      // main shape
      translate([x_offset,0,0]) {
        hull(){
          translate([rd,rd,0]) cylinder(h=box_h,r=rd);
          translate([rd,carriage_length(y_rail_carriage)-rd,0]) cylinder(h=box_h,r=rd);
          translate([carriage_width(y_rail_carriage)-rd,carriage_length(y_rail_carriage)-rd,0]) cylinder(h=box_h,r=rd);
          translate([carriage_width(y_rail_carriage)-rd+2,25,0]) cylinder(h=box_h,r=rd);
          translate([carriage_width(y_rail_carriage)-1+2,0,0]) cube([1,1,box_h]);
        }
        // lower screw mount
        translate([0,cf_from_front,0]) hull(){
          translate([rd,rd,0]) cylinder(h=cf_above_carriage,r=rd);
          translate([under_screw_pos+rd,rd,0]) cylinder(h=cf_above_carriage,r=rd);
          translate([under_screw_pos+rd,cf_tube_size-rd,0]) cylinder(h=cf_above_carriage,r=rd);
          translate([rd,cf_tube_size-rd,0]) cylinder(h=cf_above_carriage,r=rd);
        }
      }
      // upper part
      difference(){
        translate([6,0,box_h]) cube([ext-6-x_offset-2,40,py_z-box_h-1]);
        //translate([py_x-3.5,0,box_h]) rotate([90,0,90]) linear_extrude(12) polygon([ [0,0], [py_y+6,0], [py_y+6,py_z-box_h-1], [py_y-3.5,py_z-box_h-1],[0,6.5] ]);
        // hole for X pulley
        translate([px_x,px_y,px_z-1]) cylinder(h=16,d=20);
        // hole for M3 screw
        translate([m3_2.x,m3_2.y,box_h]) cylinder(h=py_z-box_h-1,d=6);
      }
      //spacer for Y idler
      translate([py_x,py_y,py_z-1]) pulley_spacer();
      //spacer for X idler
      translate([px_x,px_y,px_z-2]) pulley_spacer(2);
    }
    // holes

    // hole for cf tube
    translate([x_offset,cf_from_front-printer_off,cf_above_carriage]) cube([carriage_width(y_rail_carriage)+2,cf_tube_size+2*printer_off,cf_tube_size+0.5]); // 0.5 for hanging bidge or rough surface above supports
    // hole for mgn
    translate([x_offset,cf_from_front+cf_tube_size/2-5,cf_above_carriage+cf_tube_size]) cube([carriage_width(y_rail_carriage),10,7]);
    // hole for X pulley
    translate([px_x,px_y,0]) cylinder(h=px_z,d=m5_hole);
    // hole for Y pulley
    translate([py_x,py_y,0]) cylinder(h=py_z,d=m5_hole);
    // bottom screw
    translate([under_screw_pos,cf_tube_size/2+cf_from_front,cf_above_carriage-1.5]) joint_hole(screw_l=m5_screw5,print_upside=true);
    // front screw
    translate([ext/2,0,ext/2+cf_above_carriage]) rotate([-90,0,0]) {
      cylinder(h=cf_from_front,d=5);
      cylinder(h=1.2,d=10.5);
    }
    // back screw
    translate([ext/2-3,cf_tube_size+cf_from_front-6+m5_screw3,ext/2+cf_above_carriage]) rotate([90,0,0]) joint_hole(10,screw_l=m5_screw3);
    // M3 mouning screw - outer back
    translate([m3_4.x,m3_4.y,0]) {
      cylinder(d=3,h=m3_screw2-3);
      translate([0,0,m3_screw2-3]) cylinder(d=6.5,h=3);
    }
    // M3 mouning screw - inner back
    translate([m3_2.x,m3_2.y,0]) {
      cylinder(d=3,h=m3_screw3-3);
      translate([0,0,m3_screw3-3]) cylinder(d=6.5,h=8);
    }
    // M3 mouning screw - inner front
    translate([m3_1.x,m3_1.y,0]) {
      cylinder(d=3,h=py_z);
      translate([0,0,cf_above_carriage-2]) cylinder(d2=6.5,d1=3,h=2);
    }
    // M3 mouning screw - outer front
    translate([m3_3.x,m3_3.y,0]) {
      cylinder(d=3,h=m3_screw1-3);
      translate([0,0,cf_above_carriage-2]) cylinder(d2=6.5,d1=3,h=2);
    }
    // top M5 screw
    translate([py_x+3,5,cf_above_carriage+cf_tube_size-3]) cylinder(h=m5_screw6,d=m5_hole);
  }
}
module gantry_joint_l_cf_top(){
  py_x=ext/2; // x of Y pulley
  px_x=py_x+belt_x_separation; // x of X pulley
  px_y=gantry_belt_pos+pr20;
  py_y=gantry_belt_pos-pr20;
  px_z=beltx_shift-carriage_height(y_rail_carriage);
  py_z=belty_shift-carriage_height(y_rail_carriage);
  // screws
  m5_screw1=35; // Y pulley
  m5_screw2=50; // X pulley
  m5_screw6=30; // top

  box_h2=13+2+8;
  color(pp_color2) difference(){
    union(){
      difference(){
        hull(){
          translate([py_x,py_y,py_z-1]) cylinder(d=15,h=box_h2);
          translate([px_x,px_y,py_z-1]) cylinder(d=15,h=box_h2);
          translate([py_x+3,5,py_z-1]) cylinder(d=12,h=box_h2);
        }
        // hole for Y idler
        translate([py_x,py_y,py_z-1]) cylinder(d=20,h=15);
        // belt path to gantry
        translate([0,gantry_belt_pos-3,py_z-1]) cube([30,6,15]);
        // side belt path
        translate([0,0,py_z-1]) cube([6,40,15]);
      }
      translate([px_x,px_y,px_z+13]) pulley_spacer();
      translate([py_x,py_y,py_z+13]) pulley_spacer();
    }
    // screw holes
    translate([px_x,px_y,m5_screw2+7]) rotate([180,0,0]) joint_hole(10,screw_l=m5_screw2,print_upside=true);
    translate([py_x,py_y,m5_screw1+22]) rotate([180,0,0]) joint_hole(10,screw_l=m5_screw1,print_upside=true);
    // top M5 screw
    translate([py_x+3,5,cf_above_carriage+cf_tube_size+m5_screw6+3]) rotate([180,0,0]) joint_hole(10,screw_l=m5_screw6+5,cut_nut=false,print_upside=true);
  }
}
module gantry_joint_l(pulx, puly){
  if (x_gantry_type==0) {
    gantry_joint_l_vslot(pulx, puly);
  } else if (x_gantry_type==1) {
    gantry_joint_l_cf();
    gantry_joint_l_cf_top();
  }
}
module gantry_joint_r_vslot(pulx, puly){
  // pulley support //TODO

  // screws
  if ($preview) {
    // X pulley
    m5_screw1=40;
    translate([pulx.x,pulx.y,pulx.z+15]) screw(M5_cap_screw,m5_screw1);
    // Y pulley
    m5_screw2=40;
    translate([puly.x,puly.y,puly.z+15]) screw(M5_cap_screw,m5_screw2);
    m5_screw3=16;
    translate([ext/2,carriage_length(y_rail_carriage),10]) rotate([-90,0,0]) screw(M5_cap_screw,m5_screw3);
    m3_screw1=12;
    translate([0,13,m3_screw1-8]) screw(M3_cap_screw,m3_screw1);
    translate([0,33,m3_screw1-8]) screw(M3_cap_screw,m3_screw1);
    m3_screw2=35;
    translate([ext,13,m3_screw2-8]) screw(M3_cap_screw,m3_screw2);
    translate([ext,33,m3_screw2-8]) screw(M3_cap_screw,m3_screw2);
  }

  translate([-(carriage_width(y_rail_carriage)-ext)/2,0,0]) cube([carriage_width(y_rail_carriage),carriage_length(y_rail_carriage),40]);
}
module gantry_joint_r_cf(){
  under_screw_pos=-ext;
  px_x=ext/2; // x of Y pulley
  py_x=px_x-belt_x_separation; // x of X pulley
  px_y=gantry_belt_pos-pr20;
  py_y=gantry_belt_pos+pr20;
  px_z=beltx_shift-carriage_height(y_rail_carriage);
  py_z=belty_shift-carriage_height(y_rail_carriage);
  // screws
  m5_screw1=35; // Y pulley
  m5_screw2=50; // X pulley
  m5_screw3=20; // back
  m5_screw4=10; // front
  m5_screw5=8; // bottom
  m5_screw6=30; // top
  m3_screw1=6; // carriage short
  m3_screw2=20; // carriage outer
  m3_screw3=20; // carriage inner
  m3_screw4=8; // endstops
  m3_1=[20,12.7]; // inner front
  m3_2=[20,32.7]; // inner back
  m3_3=[0,12.7]; // outer front
  m3_4=[0,32.7]; // outer back
  if ($preview) {
    // Y pulley
    translate([py_x,py_y,m5_screw1+22]) screw(M5_cap_screw,m5_screw1);
    // X pulley
    translate([px_x,px_y,m5_screw2+7]) screw(M5_cap_screw,m5_screw2);
    // back cf mounting
    translate([ext/2-5.5,cf_tube_size+cf_from_front-6+m5_screw3,ext/2+cf_above_carriage]) rotate([-90,0,0]) screw(M5_cap_screw,m5_screw3);
    // front cf mounting
    translate([ext/2,1.2,ext/2+cf_above_carriage]) rotate([90,0,0]) screw(M5_dome_screw,m5_screw4);
    // bottom cf mount
    translate([under_screw_pos,cf_tube_size/2+cf_from_front,cf_above_carriage-1.5]) rotate([180,0,0]) screw(M5_dome_screw,m5_screw5);
    // carriage inner mount
    translate([m3_1.x,m3_1.y,cf_above_carriage]) screw(M3_cs_cap_screw,m3_screw1);
    translate([m3_2.x,m3_2.y,m3_screw3-3]) screw(M3_cap_screw,m3_screw3);
    // carriage outer mount
    translate([m3_3.x,m3_3.y,cf_above_carriage]) screw(M3_cs_cap_screw,m3_screw1);
    translate([m3_4.x,m3_4.y,m3_screw2-3]) screw(M3_cap_screw,m3_screw2);
    // top mount
    translate([px_x-3,5,cf_above_carriage+cf_tube_size+m5_screw6+3]) screw(M5_cap_screw,m5_screw6);
    // Y endstop mount
    translate([ext-4,carriage_length(y_rail_carriage),10]) rotate([-90,0,0]) screw(M3_cs_cap_screw,m3_screw4);
    // X endstop mount
    translate([-2,23,57]) rotate([0,-90,0]) screw(M3_cs_cap_screw,m3_screw4);
  }

  // mount
  rd=5; // radius of rounding
  box_h=cf_above_carriage+cf_tube_size;
  box_h2=py_z-1;
  x_offset=-(carriage_width(y_rail_carriage)-ext)/2; // how much carriage sticks out of frame
  color(pp_color) difference(){
    union(){
      difference(){
        // main shape
        translate([x_offset,0,0]) {
          hull(){
            translate([-2,0,0]) cube([1,1,box_h2]);
            translate([carriage_width(y_rail_carriage)-rd,rd,0]) cylinder(h=box_h2,r=rd);
            translate([carriage_width(y_rail_carriage)-rd,carriage_length(y_rail_carriage)-rd,0]) cylinder(h=box_h2,r=rd);
            translate([rd,carriage_length(y_rail_carriage)-rd,0]) cylinder(h=box_h2,r=rd);
            translate([-2+rd,25,0]) cylinder(h=box_h2,r=rd);
          }
          // lower screw mount
          translate([x_offset,cf_from_front,0]) hull(){
            translate([rd,rd,0]) cylinder(h=cf_above_carriage,r=rd);
            translate([under_screw_pos+rd,rd,0]) cylinder(h=cf_above_carriage,r=rd);
            translate([under_screw_pos+rd,cf_tube_size-rd,0]) cylinder(h=cf_above_carriage,r=rd);
            translate([rd,cf_tube_size-rd,0]) cylinder(h=cf_above_carriage,r=rd);
          }
        }
        // belt main path
        translate([ext-6,0,box_h]) cube([6-x_offset,35,16]);
        // hole for X pulley
        translate([px_x,px_y,px_z-1]) cylinder(d=20,h=16);
        // hole for belt along tube
        translate([-5,gantry_belt_pos-4,px_z-1]) cube([px_x-x_offset,6,16]);
        // space for X carriage
        translate([x_offset-2,0,box_h]) cube([3.9,32,20]);
      }
      //spacer for Y idler
      translate([py_x,py_y,py_z-1]) pulley_spacer();
      //spacer for X idler
      translate([px_x,px_y,px_z-2]) pulley_spacer(2);
    }
    // holes

    // hole for cf tube
    translate([x_offset-2,cf_from_front-printer_off,cf_above_carriage]) cube([carriage_width(y_rail_carriage)+2,cf_tube_size+2*printer_off,cf_tube_size+0.5]); // 0.5 for hanging bidge or rough surface above supports
    // hole for mgn
    translate([x_offset-2,cf_from_front+cf_tube_size/2-5,cf_above_carriage+cf_tube_size]) cube([carriage_width(y_rail_carriage),10,7]);
    // hole for X pulley
    translate([px_x,px_y,0]) cylinder(h=px_z,d=m5_hole);
    // hole for Y pulley
    translate([py_x,py_y,0]) cylinder(h=py_z,d=m5_hole);
    // bottom screw
    translate([under_screw_pos,cf_tube_size/2+cf_from_front,cf_above_carriage-1.5]) joint_hole(screw_l=m5_screw5,print_upside=true);
    // front screw
    translate([ext/2,0,ext/2+cf_above_carriage]) rotate([-90,0,0]) {
      cylinder(h=cf_from_front,d=5);
      cylinder(h=1.2,d=10.5);
    }
    // back screw
    translate([ext/2-5.5,cf_tube_size+cf_from_front-6+m5_screw3,ext/2+cf_above_carriage]) rotate([90,0,0]) joint_hole(10,screw_l=m5_screw3);
    // M3 mouning screw - inner back
    translate([m3_4.x,m3_4.y,0]) {
      cylinder(d=3,h=m3_screw2-3);
      translate([0,0,m3_screw2-3]) cylinder(d=6.5,h=30);
    }
    // M3 mouning screw - outer back
    translate([m3_2.x,m3_2.y,0]) {
      cylinder(d=3,h=m3_screw3-3);
      translate([0,0,m3_screw3-3]) cylinder(d=6.5,h=30);
    }
    // M3 mouning screw - outer front
    translate([m3_1.x,m3_1.y,0]) {
      cylinder(d=3,h=m3_screw1-3);
      translate([0,0,cf_above_carriage-2]) cylinder(d2=6.5,d1=3,h=2);
    }
    // M3 mouning screw - inner front
    translate([m3_3.x,m3_3.y,0]) {
      cylinder(d=3,h=box_h2);
      translate([0,0,cf_above_carriage-2]) cylinder(d2=6.5,d1=3,h=2);
    }
    // top M5 screw
    translate([px_x-3,5,cf_above_carriage+cf_tube_size-3]) cylinder(d=m5_hole,h=m5_screw6);
    // endstop trigger mount
    translate([ext-8-printer_off,carriage_length(y_rail_carriage)-2,5-printer_off]) cube([8+2*printer_off,2,12.6+2*printer_off]);
    // endstop screw mount
    translate([ext-4,carriage_length(y_rail_carriage)-2,10]) rotate([90,0,0]) cylinder(h=10,d=m3_hole);
  }
}

module gantry_joint_r_cf_top(){
  px_x=ext/2; // x of Y pulley
  py_x=px_x-belt_x_separation; // x of X pulley
  px_y=gantry_belt_pos-pr20;
  py_y=gantry_belt_pos+pr20;
  px_z=beltx_shift-carriage_height(y_rail_carriage);
  py_z=belty_shift-carriage_height(y_rail_carriage);
  // screws
  m5_screw1=35; // Y pulley
  m5_screw2=50; // X pulley
  m5_screw6=30; // top

  box_h2=13+2+8;
  color(pp_color2) difference(){
    union(){
      difference(){
        hull(){
          translate([py_x,py_y,py_z-1]) cylinder(d=15,h=box_h2);
          translate([px_x,px_y,py_z-1]) cylinder(d=15,h=box_h2);
          translate([py_x+3,5,py_z-1]) cylinder(d=12,h=box_h2);
        }
        // hole for Y idler
        translate([py_x,py_y,py_z-1]) cylinder(d=20,h=15);
        // belt path to gantry
        translate([-5,gantry_belt_pos-3,py_z-1]) cube([30,7,15]);
        // side belt path
        translate([ext-6,0,py_z-1]) cube([6,40,15]);
      }
      translate([px_x,px_y,px_z+13]) pulley_spacer();
      translate([py_x,py_y,py_z+13]) pulley_spacer();
    }
    // screw holes
    translate([px_x,px_y,m5_screw2+7]) rotate([180,0,0]) joint_hole(10,screw_l=m5_screw2,print_upside=true);
    translate([py_x,py_y,m5_screw1+22]) rotate([180,0,0]) joint_hole(10,screw_l=m5_screw1,print_upside=true);
    // top M5 screw
    translate([px_x-3,5,cf_above_carriage+cf_tube_size+m5_screw6+3]) rotate([180,0,0]) joint_hole(10,screw_l=m5_screw6+5,cut_nut=false,print_upside=true);
    // X endstop trigger mount
    translate([-2,14.5,61-9]) {
      cube([2,14.6,11]);
      translate([2,8.5,4+1]) rotate([0,90,0]) cylinder(h=12,d=m3_hole);
    }
  }
}
module xy_endstop_trigger(){
  color(pp_color2)
    difference(){
      union(){
        // trigger
        translate([0,0,11]) cube([8,14,1.6]);
        // mount
        translate([0,0,0]) cube([8,2,12.6]);
      }
      // screw hole
      translate([4,0,5]) rotate([-90,0,0]) cylinder(d2=6.5,d1=3,h=2);
    }
}
module gantry_joint_r(pulx, puly){
  if (x_gantry_type==0) {
    gantry_joint_r_vslot(pulx, puly);
  } else if (x_gantry_type==1) {
    gantry_joint_r_cf();
    gantry_joint_r_cf_top();
    // Y trigger
    translate([12,carriage_length(y_rail_carriage)-2,5]) xy_endstop_trigger();
    // X trigger
    translate([0,28,53]) rotate([0,-90,90]) xy_endstop_trigger();
  }
}
module gantry(){
  // Y carriage positions
  echo("Side rails lenght",y_rail_l);
  echo("Maximum rails length",base_d-2*ext);
  real_y=pos_y+hotend_d+ext; // position of Y carriage from front of printer
  carriage_pos_x=pos_x-build_x/2; // position of X carriage
  carriage_pos_y=real_y-carriage_travel(y_rail_carriage,y_rail_l)/2-y_rails_from_front; // position of Y carriage on rail relative to center of Y rail
  carriage_y_real=real_y+carriage_length(y_rail_carriage)/2; // position of center Y carriage


  // left linear rail
  translate([ext/2,y_rail_l/2+y_rails_from_front,base_h]) rotate([0,0,90]) rail_assembly(y_rail_carriage,y_rail_l,carriage_pos_y);
  // right linear rail
  translate([base_w-ext/2,y_rail_l/2+y_rails_from_front,base_h]) rotate([0,0,90]) rail_assembly(y_rail_carriage,y_rail_l,carriage_pos_y);

  // X axis
  // X start anchor point
  bx1=[base_w/2-build_x/2+pos_x,carriage_y_real+gantry_belt_shift,base_h+beltx_shift];
  translate(bx1) cube([0.1,12,12]);
  // X idler - gantry left
  bx2=[ext/2+belt_x_separation,carriage_y_real+gantry_belt_shift+pr20,base_h+beltx_shift];
  translate(bx2) pulley(GT2_10x20_plain_idler);
  // X idler - inner rail-motor
  bx3=[ext/2+belt_x_separation,base_d,base_h+beltx_shift];
  translate(bx3) pulley(GT2_10x20_plain_idler);
  // X motor
  bx4=[xy_motor_pos.x,xy_motor_pos.y,base_h+beltx_shift-5];
  translate(bx4) rotate([0,0,-90]) NEMA(NEMA17M);
  translate([bx4.x,bx4.y,bx4.z+25.5]) rotate([0,180,0]) pulley(GT2_10x20ob_pulley);
  // X idler - outer rail-motor
  bx5=[ext/2,base_d+ext,base_h+beltx_shift];
  translate(bx5) pulley(GT2_10x20_toothed_idler);
  // X idler - front left
  bx6=[ext/2,ext/2,base_h+beltx_shift];
  translate(bx6) pulley(GT2_10x20_toothed_idler);
  // X idler - front right
  bx7=[base_w-ext/2,ext/2,base_h+beltx_shift];
  translate(bx7) pulley(GT2_10x20_toothed_idler);
  // X idler - gantry right
  bx8=[base_w-ext/2,carriage_y_real+gantry_belt_shift-pr20,base_h+beltx_shift];
  translate(bx8) pulley(GT2_10x20_toothed_idler);
  
  // X belt
  belt_x_path=[[bx8.x,bx8.y,pr20], [bx7.x,bx7.y,pr20], [bx6.x,bx6.y,pr20], [bx5.x,bx5.y,pr20], [bx4.x,bx4.y,pr20], [bx3.x,bx3.y,-pr20], [bx2.x,bx2.y,-pr20],[bx1.x,bx1.y,0]];
  translate([0,0,base_h+beltx_shift+6.5]) belt(GT2x10,belt_x_path);
  echo("X belt length",belt_length(GT2x10,belt_x_path));

  // Y axis
  // Y start anchor point
  by1=[base_w/2-build_x/2+pos_x,carriage_y_real+gantry_belt_shift,base_h+belty_shift];
  translate(by1) cube([0.1,12,12]);
  // Y idler - gantry right
  by2=[base_w-ext/2-belt_x_separation,carriage_y_real+gantry_belt_shift+pr20,base_h+belty_shift];
  translate(by2) pulley(GT2_10x20_plain_idler);
  // Y idler - inner rail-motor
  by3=[base_w-ext/2-belt_x_separation,base_d,base_h+belty_shift];
  translate(by3) pulley(GT2_10x20_plain_idler);
  // Y motor
  pulley_motor_space=-7.5;
  //by4=[base_w-xy_motor_pos.x,xy_motor_pos.y,base_h+belty_shift];
  by4=[base_w-xy_motor_pos.x,xy_motor_pos.y,base_h+belty_shift-5];
  translate([by4.x,by4.y,base_h+y_motor_z]) rotate([0,0,90]) NEMA(NEMA17M);
  //translate([by4.x,by4.y,by4.z+pulley_motor_space]) pulley(GT2_10x20ob_pulley);
  translate([by4.x,by4.y,by4.z+25.5]) rotate([0,180,0]) pulley(GT2_10x20ob_pulley);
  // Y idler - outer rail-motor
  by5=[base_w-ext/2,base_d+ext,base_h+belty_shift];
  translate(by5) pulley(GT2_10x20_toothed_idler);
  // Y idler - front right
  by6=[base_w-ext/2,ext/2,base_h+belty_shift];
  translate(by6) pulley(GT2_10x20_toothed_idler);
  // Y idler - front left
  by7=[ext/2,ext/2,base_h+belty_shift];
  translate(by7) pulley(GT2_10x20_toothed_idler);
  // Y idler - gantry left
  by8=[ext/2,carriage_y_real+gantry_belt_shift-pr20,base_h+belty_shift];
  translate(by8) pulley(GT2_10x20_toothed_idler);

  // Y belt
  belt_y_path=[[by1.x,by1.y,0], [by2.x,by2.y,-pr20], [by3.x,by3.y,-pr20], [by4.x,by4.y,pr20], [by5.x,by5.y,pr20], [by6.x,by6.y,pr20], [by7.x,by7.y,pr20], [by8.x,by8.y,pr20]];
  translate([0,0,base_h+belty_shift+6.5]) belt(GT2x10,belt_y_path);
  echo("Y belt length",belt_length(GT2x10,belt_y_path));
  
  // X gantry support
  g_shift_z=base_h+carriage_height(y_rail_carriage); // top of Y carriage
  translate([0,real_y,g_shift_z]) {
    echo(base_w=base_w);
    echo("X rail length",x_rail_l);
    if (x_gantry_type==0) {
      // v-slot + MGN12
      translate([ext/4,5,3.5]) rotate([0,90,0]) ext2020(base_w-ext/2);
      translate([base_w/2,ext*0.5+5,ext+3.5]) rotate([0,0,0]) rail_assembly(MGN12H_carriage,x_rail_l,carriage_pos_x);
    } else if (x_gantry_type==1 ) {
      // cf tube + MGN9
      // CF tube
      cf_len=base_w+carriage_width(MGN12H_carriage)-20;
      echo("CF tube length",cf_len);
      translate([(base_w-cf_len)/2,cf_from_front,cf_above_carriage]) color([0.1,0.1,0.1]) difference(){
        cube([cf_len,cf_tube_size,cf_tube_size]);
        translate([0,cf_tube_wall,cf_tube_wall]) cube([cf_len,cf_tube_size-2*cf_tube_wall,cf_tube_size-2*cf_tube_wall]);
      }
      // MGN9 rail
      translate([base_w/2,cf_tube_size/2+cf_from_front,cf_tube_size+cf_above_carriage]) rotate([0,0,0]) rail_assembly(MGN9H_carriage,x_rail_l,carriage_pos_x);
    }
    // gantry joints
    translate([0,0,0]) {
      // left
      gantry_joint_l([bx2.x,bx2.y-real_y,bx2.z-g_shift_z],[by8.x,by8.y-real_y,by8.z-g_shift_z]);
      // right
      translate([base_w-ext,0,0]) gantry_joint_r([bx8.x-(base_w-ext),bx8.y-real_y,bx8.z-g_shift_z],[by2.x-(base_w-ext),by2.y-real_y,by2.z-g_shift_z]);
    }
    // Extruder and mount
    translate([base_w/2-build_x/2+pos_x,0,0]) extruder();
  }

  // front pulley support
  translate([0,0,base_h]) pulley_support_front(side=0,logo=1);
  translate([base_w,0,base_h]) pulley_support_front(side=1,logo=0);
  
  // X motor support
  motor_support_x();
  // Y motor support
  motor_support_y();

}
module build_plate(){
  // build plate
  plate_h=3.2;
  plate_screw_l=40;
  d1=(build_plate_w-build_plate_mount_space)/2;
  d2=d1+build_plate_mount_space;
  difference(){
    color([0,0,0]) cube([build_plate_w,build_plate_d,plate_h]);
    
    // holes for screws
    translate([d1,d1,0]) cylinder(d=4,h=plate_h);
    translate([d1,d2,0]) cylinder(d=4,h=plate_h);
    translate([d2,d1,0]) cylinder(d=4,h=plate_h);
    translate([d2,d2,0]) cylinder(d=4,h=plate_h);
  }
  //screws
  translate([d1,d1,plate_h]) {
    screw(M4_cs_cap_screw,plate_screw_l);
    translate([0,0,-30]) cylinder(h=1,d=12);
  }
  translate([d1,d2,plate_h]) screw(M4_cs_cap_screw,plate_screw_l);
  translate([d2,d1,plate_h]) screw(M4_cs_cap_screw,plate_screw_l);
  translate([d2,d2,plate_h]) screw(M4_cs_cap_screw,plate_screw_l);
  // cork isolation
  translate([0,0,-7]) color([0.6,0.43,0.24]) cube([build_plate_w,build_plate_d,7]);
}
module T8_spacer(){
  color(pp_color) difference(){
    cylinder(h=2,d=10);
    cylinder(h=2,d=8+2*printer_off);
  }
}
module T8_clamp_printed(){
  c_h=11.5; // clamp height
  c_d=19; // clamp outer diameter
  color(pp_color) difference(){
    // clamp cylinder
    cylinder(h=c_h,d=c_d);
    
    // inner hole
    cylinder(h=c_h,d=8+2*printer_off);
    // space for clamping
    translate([-c_d/2,-0.5,0]) cube([c_d/2,1,c_h]);
    // hole for screw
    translate([-5.9,-4,c_h/2]) rotate([90,0,0]) cylinder(h=8,d=5.8);
    translate([-5.9,-4,c_h/2]) rotate([-90,0,0]) cylinder(h=12,d=3.1);
    // slot for M3 nut
    translate([-c_d/2,4,(c_h-6.0)/2]) cube([6.7,2.8,6.0]);
    // cut for printing on side
    translate([c_d/2-2,-c_d/2,0]) cube([2,c_d,c_h]);
  }
}
module T8_clamp_metal(){
  mcl_h=7;
  mcl_d=14;
  color(grey(90)) difference(){
    cylinder(h=mcl_h,d=mcl_d);
    cylinder(h=mcl_h,d=8);
  }
}
module T8_clamp(){
  if (printed_t8_clamps) {
    T8_clamp_printed();
  } else {
    T8_clamp_metal();
  }
}
module bb_support(rear){
  color(pp_color) difference(){
    union(){
      // support
      translate([0,0,joint_in_material/2]) cube([ext,2.8*ext,joint_in_material], center=true);
      // around bb
      cylinder(h=t8_frame_dist+t8_bb_offset+T8_BB[3],d=ext);
    }
    
    //hole for bearing
    translate([0,0,t8_frame_dist+t8_bb_offset]) cylinder(h=T8_BB[3],d=T8_BB[2]+2*printer_off);
    // hole under bearing
    translate([0,0,0]) cylinder(h=t8_frame_dist+t8_bb_offset,d=T8_BB[2]-2);
    
    // holes for screws
    translate([0,ext,joint_in_material]) rotate([180,0,0]) joint_hole(0);
    translate([0,-ext,joint_in_material]) rotate([180,0,0]) joint_hole(0);
    
    // hole for joint
    if (rear==0) {
      translate([-ext/2,-1.5*ext,joint_in_material/2]) cube([ext,ext,joint_in_material/2]);
    }
  }
}
module z_rod(rear){
  // ball bearing support
  translate([0,0,0]) if (printed_corners) {
    bb_support(rear);
  } else {
    bb_support(1);
  }
  // lower ball bearing
  translate([0,0,t8_frame_dist+t8_bb_offset+T8_BB[3]/2]) ball_bearing(T8_BB);
  // lower spacer
  translate([0,0,t8_frame_dist+t8_bb_offset+T8_BB[3]]) T8_spacer();
  // lower clamp
  translate([0,0,t8_frame_dist+t8_bb_offset+T8_BB[3]+2]) T8_clamp();
  // pulley
  translate([0,0,z_belt_h-7]) rotate([180,0,0]) pulley(GT2x20ob_pulley);
  // screw
  translate([0,0,base_h/2-ext]) leadscrew(8, base_h-2*ext-5, 8, 4);
  echo("Leadscrew length",base_h-2*ext-5);
  if (t8_upper_bearings) {
    // upper clamp
    translate([0,0,base_h-2*ext-t8_frame_dist-t8_bb_offset-T8_BB[3]-2]) rotate([180,0,0]) T8_clamp();
    // upper spacer
    translate([0,0,base_h-2*ext-t8_frame_dist-t8_bb_offset-T8_BB[3]-2]) T8_spacer();
    // upper ball bearing
    translate([0,0,base_h-2*ext-t8_frame_dist-t8_bb_offset-T8_BB[3]/2]) ball_bearing(T8_BB);
  }
  translate([0,0,base_h-2*ext]) rotate([0,180,0]) if (printed_corners) {
    bb_support(rear);
  } else {
    bb_support(1);
  }
  // T-nut
  translate([0,0,bed_z-2*ext]) leadnut_cut();
}
module z_pulley_support(){
  block_h=z_belt_h-ext-1.5-1;
  
  // screws
  if ($preview) {
    m5_screw1=20;
    translate([0,0,m5_screw1-5+20]) screw(M5_cap_screw,m5_screw1);
    m5_screw2=12;
    translate([ext,0,m5_screw2-5]) screw(M5_cap_screw,m5_screw2);
    translate([-ext,0,m5_screw2-5]) screw(M5_cap_screw,m5_screw2);
  }
  // body
  color(pp_color) difference(){
    union(){
      // main block
      translate([-ext/2,ext/2,0]) rotate([90,0,0]) linear_extrude(ext) polygon([[-ext,0], [2*ext,0], [2*ext,joint_in_material], [ext/2+4,block_h], [ext/2-4,block_h], [-ext,joint_in_material]]);
      // spacer
      translate([0,0,block_h]) cylinder(h=1,d=7);
      // v-slot insert
      //translate([-ext/2,0,0])rotate([-90,0,-90]) vslot_groove(2*ext);
    }
    // hole for longer screw
    translate([0,0,0]) cylinder(h=block_h+1,d=m5_hole);
    // hole for normal screw
    translate([ext,0,joint_in_material])rotate([180,0,0]) joint_hole(20);
    translate([-ext,0,joint_in_material])rotate([180,0,0]) joint_hole(20);
  }
}
module z_wheel_mount(back=0){
  ro=6;
  color(pp_color) rotate([90,0,0]) difference(){
    union(){
      // main shape
      hull(){
        // side curve
        translate([ext/2,-ro,0]) cylinder(h=ext+back*ext/2,r=ro);
        // wheel mount
        translate([VWHEEL[5]/2,-1.5*ext,0]) cylinder(h=ext,r=ro);
        // flat profile side
        translate([ext/2,-joint_in_material,0]) cube([3*ext,joint_in_material,ext+back*ext/2]);
      }
      // v-slot hump
      translate([ext/2,0,ext/2+back*ext/2]) rotate([0,90,0]) vslot_groove(3*ext);
      // wheel spacer
      translate([VWHEEL[5]/2,-1.5*ext,0]) cylinder(h=1.5*ext-VWHEEL[4]/2,d=VWHEEL[8]);
    }

    // slit
    hull(){
      translate([ext/2,-ro,0]) cylinder(h=ext*1.5,r=ro/2);
      translate([VWHEEL[5]/2-(VWHEEL[5]/2-ext/2)*0.36,-1.5*ext+(1.5*ext-ro)*0.36,0]) cylinder(h=ext*1.5,r=ro/2);
    }

    translate([VWHEEL[5]/2,-1.5*ext,0]) {
      // screw hole
      cylinder(h=1.5*ext,d=m5_hole);
      // around screw
      difference(){
        intersection(){
          cylinder(h=ext*1.5,r=ro*2);
          translate([0,-ro,0]) cube([ro*2,ro*3,ext*1.5]);
        }
        cylinder(h=ext*1.5,r=ro);
      }
      // space for wheel
      if (back==1) {
        translate([0,0,1.5*ext-VWHEEL[4]/2-2]) difference(){
          cylinder(h=ext/2,d=VWHEEL[1]+2);
          cylinder(h=ext/2,d=VWHEEL[8]);
        }
      }
    }
    // holes for screws
    translate([3*ext,-joint_in_material,ext/2+back*ext/2]) rotate([-90,0,0]) joint_hole(1.5*ext);
    translate([1.2*ext,-joint_in_material,ext/2+back*ext/2]) rotate([-90,0,0]) joint_hole(1.5*ext);  }
}
module oldham_wedge(off=0){
  oh=oldham_w_h+off; // height
  ow1=5+4*off; // base
  ow2=7+4*off; // top
  ol=4*ext; // length
  translate([ow1/2,-ol/2,0]) rotate([90,0,180]) linear_extrude(ol) polygon([ [0,0], [ow1,0], [ow1-(ow1-ow2)/2,oh], [(ow1-ow2)/2,oh] ]);
}
module oldham_low(){
  color(pp_color) difference(){
    union(){
      translate([oldham_margin,-oldham_w/2,0]) cube([oldham_d-oldham_margin,oldham_w,oldham_lh]);
      intersection(){
        translate([ext/2,0,oldham_lh]) rotate([0,0,45]) oldham_wedge();
        translate([oldham_margin,-oldham_w/2,oldham_lh]) cube([oldham_d-oldham_margin,oldham_w,oldham_w_h]);
      }
    }
    // hole for leadnut
    translate([ext/2,0,0]) cylinder(d=11,h=oldham_lh+oldham_w_h);
    // holes for leadnut mount screws
    translate([ext/2,-8,0]) cylinder(h=ext,d=m3_hole);
    translate([ext/2,8,0]) cylinder(h=ext,d=m3_hole);
    translate([ext/2+8,0,0]) cylinder(h=ext,d=m3_hole);
  }
}
module oldham_mid(){
  color(pp_color2) difference(){
    // main block
    translate([oldham_margin,-oldham_w/2,oldham_lh]) cube([oldham_d-oldham_margin,oldham_w,oldham_mh]);

    // hole for lower wedge
    translate([ext/2,0,oldham_lh]) rotate([0,0,45]) oldham_wedge(printer_off);
    // hole for upper wedge
    translate([ext/2,0,oldham_lh+oldham_mh]) rotate([180,0,-45]) oldham_wedge(printer_off);
    // hole for leadnut
    translate([ext/2,0,oldham_lh]) cylinder(d=8+oldham_margin*2,h=oldham_mh);
    // corners
    translate([oldham_d,oldham_w/2,oldham_lh]) linear_extrude(oldham_mh) polygon([ [0,0],[-5,0], [0,-5] ]);
    translate([oldham_d,-oldham_w/2,oldham_lh]) linear_extrude(oldham_mh) polygon([ [0,0],[-5,0], [0,5] ]);
  }
}
module oldham_hi(dist){
  ow2=ext*3.5;
  ow=2*dist;
  tri=[ [dist-oldham_margin,0], [dist-oldham_margin,ext], [0,ext] ];
  trw=0.7*ext;
  color(pp_color) difference(){
    union(){
      // top plate
      // -ow/2+(ow-4*ext)/2=-2*ext
      translate([oldham_margin,-2*ext,oldham_lh+oldham_mh]) cube([dist-oldham_margin,max(ow,ow2),3]);
      // wedge
      intersection(){
        translate([ext/2,0,oldham_lh+oldham_mh]) rotate([180,0,-45]) oldham_wedge();
        translate([oldham_margin,-ow/2,oldham_lh+oldham_mh-oldham_w_h]) cube([dist-oldham_margin,ow,oldham_w_h]);
      }
      // left support
      translate([oldham_margin,ow/2,0]) rotate([90,0,0]) linear_extrude(trw) polygon(tri);
      // right support
      translate([oldham_margin,-2*ext+trw,0]) rotate([90,0,0]) linear_extrude(trw) polygon(tri);
      // backplate
      translate([dist-2,-2*ext,0]) cube([2,max(ow,ow2),ext]);
      // v-slot
      translate([dist,-2*ext,ext/2]) rotate([-90,-90,0]) vslot_groove(max(ow,ow2));
    }
    // mount holes
    translate([dist-joint_in_material,ow/2-7,ext/2]) rotate([0,90,0]) joint_hole(dist);
    translate([dist-joint_in_material,-2*ext+7,ext/2]) rotate([0,90,0]) joint_hole(dist);
    // hole for leadnut
    translate([ext/2,0,oldham_lh+3]) cylinder(d=8+oldham_margin*2,h=oldham_mh);
  }
}
module bed_to_t8(dist){
  if (bed_coupler==0) {
    // permanent mount
    bw=2*ext+4; // width of mount
    ln_d=10.4; // diameter of leadnut
    color(pp_color) translate([0,-bw/2,0]) difference(){
      union(){
        // main shape
        translate([4,bw,0]) rotate([90,0,0]) linear_extrude(bw) polygon([[0,0],[dist-4,0],[dist-4,ext],[dist-4-joint_in_material,ext],[0,10]]);
        // v-slot part
        translate([dist,0,ext/2]) rotate([-90,-90,0]) vslot_groove(bw);
      }
      // hole for leadnut
      translate([0,bw/2,0]) hull(){
        translate([ext/2,0,0]) cylinder(h=ext, d=ln_d+1);
        translate([0,-ln_d/2,0]) cube([ln_d/2,ln_d,ext]);
      }
      // holes for frame mount screws
      translate([dist-joint_in_material,6,ext/2]) rotate([0,90,0]) joint_hole(bw);
      translate([dist-joint_in_material,bw-6,ext/2]) rotate([0,90,0]) joint_hole(bw);

      // holes for leadnut mount screws
      translate([ext/2,bw/2-8,0]) cylinder(h=ext,d=m3_hole);
      translate([ext/2,bw/2+8,0]) cylinder(h=ext,d=m3_hole);
    }
  } else {
    // oldham coupling
    oldham_low();
    oldham_mid();
    oldham_hi(dist);
  }
}
module z_endstop_trigger(){
  h=4;
  fd=9;
  color(pp_color) difference(){
    union(){
      // mount
      cube([ext,h,ext]);
      // v-slot positioning
      translate([0,0,ext/2]) rotate([0,-90,180]) vslot_groove(ext);
      // feather
      translate([ext-1.6,0,-0.5*ext]) cube([1.6,fd,1.5*ext]);
    }
    // hole for screw
    translate([0.25*ext,4,ext/2]) rotate([90,0,0]) joint_hole(5,10);
  }
}
module z_bed_frame(){
  // build plate
  translate([(base_w-build_plate_w)/2,hotend_d-hotend_nozzle+ext+10,12]) build_plate();

  // plate frame
  // left
  translate([2.5*ext,2.5*ext,0]) rotate([-90,0,0]) ext2020(base_d-5.5*ext);
  // right
  translate([base_w-1.5*ext,2.5*ext,0]) rotate([-90,0,0]) ext2020(base_d-5.5*ext);
  // front
  translate([1.5*ext,1.5*ext,-ext]) rotate([0,90,0]) ext2020(base_w-3*ext);
  // back
  translate([1.5*ext,base_d-3*ext,-ext]) rotate([0,90,0]) ext2020(base_w-3*ext);

  // joints 2x2
  translate([2.5*ext,base_d-3*ext,-ext]) rotate([0,0,-90]) joint2x2();
  translate([base_w-2.5*ext,base_d-3*ext,-ext]) rotate([0,0,180]) joint2x2();
  // joints/bed mount
  translate([2.5*ext,2.5*ext,-ext]) joint_bed();
  translate([base_w-2.5*ext,2.5*ext,-ext]) mirror([1,0,0]) joint_bed();
  // rear bed support
  translate([2.5*ext,2.75*ext+build_plate_mount_space,-ext]) bed_support();
  translate([base_w-2.5*ext,2.75*ext+build_plate_mount_space,-ext]) mirror([1,0,0]) bed_support();

  // mount frame to T8 screws
  translate([0,4*ext,-ext]) mirror([0,1,0]) bed_to_t8(1.5*ext);
  translate([base_w,4*ext,-ext]) rotate([0,0,180]) bed_to_t8(1.5*ext);
  translate([base_w/2,base_d,-ext]) rotate([0,0,-90]) bed_to_t8(2*ext);

  // front v-wheels
  v_offset=ext+VWHEEL[5]/2;
  v_front_screw_len=30;
  translate([v_offset,1.5*ext+VWHEEL[4]/2,-2.5*ext]) rotate([90,0,0]) {
    vslot_wheel(VWHEEL);
    translate([0,0,VWHEEL[4]]) screw(M5_dome_screw,v_front_screw_len);
  }
  translate([base_w-v_offset,1.5*ext+VWHEEL[4]/2,-2.5*ext]) rotate([90,0,0]) {
    vslot_wheel(VWHEEL);
    translate([0,0,VWHEEL[4]]) screw(M5_dome_screw,v_front_screw_len);
  }
  // left front wheel mount
  translate([ext,3*ext,-ext]) z_wheel_mount(1);
  // left front wheel mount
  translate([base_w-ext,3*ext,-ext]) mirror([1,0,0]) z_wheel_mount(1);

  // back v-wheels
  translate([v_offset,base_d-1.5*ext-VWHEEL[4]/2,-2.5*ext]) rotate([-90,0,0]) {
    vslot_wheel(VWHEEL);
    translate([0,0,VWHEEL[4]]) screw(M5_dome_screw,v_front_screw_len);
  }
  translate([base_w-v_offset,base_d-1.5*ext-VWHEEL[4]/2,-2.5*ext]) rotate([-90,0,0]) {
    vslot_wheel(VWHEEL);
    translate([0,0,VWHEEL[4]]) screw(M5_dome_screw,v_front_screw_len);
  }
  // left back wheel mount
  translate([ext,base_d-3*ext,-ext]) mirror([0,1,0]) z_wheel_mount(0);
  // right back wheel mount
  translate([base_w-ext,base_d-3*ext,-ext]) rotate([0,0,180]) z_wheel_mount(0);

  // Z end-stop
  translate([base_w-elec_support-6.5,base_d-2*ext,-ext]) z_endstop_trigger();
}
module z_axis(){
  // rods and pulleys
  // left rod
  p1=[ext/2, 4*ext, ext];
  translate(p1) z_rod(0);
  // right rod
  p2=[base_w-ext/2, 4*ext, ext];
  translate(p2) z_rod(0);
  // back rod
  p3=[base_w/2, base_d-ext/2, ext];
  translate(p3) rotate([0,0,90]) z_rod(1);

  // Z motor
  p4=[ext+22, z_pulley_support-22-ext/2, z_belt_h-5.5];
  translate(p4) rotate([0,0,0]) union(){
    NEMA(NEMA17M);
    translate([0,0,19]) rotate([0,180,0]) pulley(GT2x20ob_pulley);
  }
  // Z motor mount
  translate([0,z_pulley_support-ext/2-44,ext]) motor_support_z();

  // tension pulley
  p5=[ext/2+92,z_pulley_support,z_belt_h-1.5];
  translate(p5) pulley(GT2x20_plain_idler);
  translate([p5.x,p5.y,ext]) rotate([0,0,180]) z_pulley_support();

  // second tension pulley
  p6=[ext/2+200,z_pulley_support,z_belt_h-1.5];
  translate(p6) pulley(GT2x20_plain_idler);
  translate([p6.x,p6.y,ext]) z_pulley_support();

  // belt
  belt_points=[[p5.x,p5.y,-pr20],[p4.x,p4.y,pr20],[p3.x,p3.y,pr20],[p6.x,p6.y,-pr20],[p2.x,p2.y,pr20],[p1.x,p1.y,pr20]];
  translate([0,0,z_belt_h+3]) belt(GT2x6,belt_points);
  echo("Z belt length",belt_length(GT2x6,belt_points));

  //moving part
  translate([0,0,bed_z]) z_bed_frame();
  
}
module z_pulley_helper(){
  difference(){
    cylinder(h=7.5,d=15);

    cylinder(h=7.6,d=8.3);
    translate([-8.3/2,0,0]) cube([8.3,7.5,7.5]);
  }
}
module mgn12_mount_helper(){
  mgn_x=12;
  mgn_y=8.20;
  wall=5;
  th=ext/2;
  difference(){
    //main body
    cube([ext+2*wall,ext/2+mgn_y+wall,th]);

    // hole for 2020
    translate([wall-printer_off,0,0]) cube([ext+2*printer_off,ext/2,th]);
    // hole for rail
    translate([wall+ext/2-mgn_x/2-printer_off,ext/2,0]) cube([mgn_x+2*printer_off,mgn_y+0.5,th]);
  }
}
module mgn9_mount_helper(){
  mgn_x=9;
  mgn_y=6.5;
  wall=5;
  th=ext/2;
  difference(){
    //main body
    cube([ext+2*wall,ext/2+mgn_y+wall,th]);

    // hole for CF tube
    translate([wall-printer_off,0,0]) cube([cf_tube_size+2*printer_off,ext/2,th]);
    // hole for rail
    translate([wall+cf_tube_size/2-mgn_x/2-printer_off,ext/2,0]) cube([mgn_x+2*printer_off,mgn_y+0.5,th]);
  }
}

module btt_skr_13(mot=0){
  // mot=1 - draw BTT-EXP-MOT module
  color([0.4,0,0]) {
    cube([109.67,84.30,25]);
    if (mot==1) translate([115,0,0]) cube([46.00,84.30,25]);
  }
}
module m4_hole(l){
  union(){
    cylinder(d=4.2,h=l);
    cylinder(d2=4.2,d1=7.4,h=2.5);
  }
}
module psu_mount(h_len, h_h, mirr){
  // h_len - position of hole from front/back
  // h_h - position of hole from bottom
  m_h=h_h*2; // mount height
  color(pp_color) difference(){
    union(){
      // screw mount
      cube([ext,1.5*ext,joint_in_material]);
      // psu mount
      translate([ext/4+mirr*ext/4,ext/2,0]) rotate([90,0,90]) linear_extrude(ext/4) polygon([[0,0],[h_len+m_h/2+ext,0],[h_len+m_h/2+ext,m_h],[ext,m_h]]);
    }
    // frame screw hole
    translate([ext/2,ext/2,joint_in_material])rotate([0,180,0]) joint_hole(joint_in_material);
    // psu screw hole
    translate([ext/4+mirr*ext/2,1.5*ext+h_len,h_h]) rotate([0,90,0]) mirror([0,0,mirr]) m4_hole(ext/4);
    // zip-tie hole
    translate([ext/4+mirr*ext/4,1.0*ext,9]) rotate([-40,0,0]) cube([ext/4,2,4]);
  }
}
module power_socket_mount(){
  color(pp_color)  difference(){
    union(){
      // bottom part
      linear_extrude(ext/4) polygon([[ext/4,0],[ext/4,50],[2*ext,50],[3*ext,0]]);
      // top mount
      translate([ext/4,0,3*ext]) linear_extrude(ext) polygon([[0,0],[0.75*ext,0],[0.75*ext,joint_in_material],[0,ext]]);
      // mount for zip-tie
      translate([ext/2,6,4*ext-2]) intersection(){
        difference(){
          cylinder(h=2,d=ext);
          cylinder(h=2,d=ext-3);
        }
        cube([ext/2,ext/2,2]);
      }
      // bottom mount
      translate([ext/4,joint_in_material,0]) rotate([90,0,0]) linear_extrude(joint_in_material) polygon([[0,0],[2.75*ext,0],[2.75*ext,ext],[0,2*ext],[0,1.5*ext],[1.5*ext,ext],[0,ext/2]]);
      // mount plate
      translate([ext/4,0,0]) cube([ext/4,50,7*ext]);
    }
    // bottom mount hole
    translate([2.2*ext,joint_in_material,ext/2]) rotate([90,0,0]) joint_hole(25);
    // top mount hole
    translate([ext/2+0.1,joint_in_material,3.5*ext]) rotate([90,0,0]) joint_hole(20);
    // PSU mount holes
    translate([ext/4,12.5,4*ext+45]) rotate([0,90,0]) m4_hole(ext/4);
    translate([ext/4,12.5+25,4*ext+45]) rotate([0,90,0]) m4_hole(ext/4);
    // power socket hole
    translate([5+ext/8,25,11+10]) rotate([90,0,-90]) iec_holes(IEC_inlet_atx,h=ext/4);
    // Power switch
    translate([5+ext/8,24,38+10]) rotate([0,-90,0]) rocker_hole(large_rocker,h=ext/4);
    // ventilation holes for Delta PSU
    translate([ext/4,13+17,4*ext+45+5]) cube([ext/4,7,3]);
    translate([ext/4,13+17,4*ext+45-8]) cube([ext/4,7,3]);
    translate([ext/4,13,4*ext+45-8-6]) cube([ext/4,24,3]);
    translate([ext/4,13,4*ext+45-8-12]) cube([ext/4,24,3]);
    translate([ext/4,13,4*ext+45-8-18]) cube([ext/4,24,3]);
  }
}
module slot(d,h,l){
  hull(){
    cylinder(d=d,h=h);
    translate([l,0,0]) cylinder(d=d,h=h);
  }
}
module control_board_mount(orient=0){
  sup_d=8; // diameter of pcb support
  btt_screw_dist=76.2; // distance between screws in BTT SKR 1.3
  d_dist=(elec_support-btt_screw_dist)/2;
  pcb_d=4; // hole dia for mounting pcb
  color(pp_color) difference(){
    union(){
      hull(){
        // frame mount
        cube([ext,joint_in_material,ext]);
        // pcb mounts
        translate([d_dist,0,sup_d/2]) rotate([-90,0,0]) cylinder(h=joint_in_material,d=sup_d);
        translate([d_dist,0,ext-sup_d/2]) rotate([-90,0,0]) cylinder(h=joint_in_material,d=sup_d);
      }
      // v-slot
      translate([ext/2,0,0]) rotate([0,0,180]) vslot_groove(ext);
    }
    // hole for mount screw
    translate([ext/2,joint_in_material,ext/2]) rotate([90,0,0]) joint_hole(0);
    // pcb mount hole
    if (orient==0) {
      // 2 horizontal
      translate([d_dist-4,0,sup_d/2]) rotate([-90,0,0]) slot(pcb_d,joint_in_material,5);
      translate([d_dist-4,0,ext-sup_d/2]) rotate([-90,0,0]) slot(pcb_d,joint_in_material,5);
    } else {
      translate([d_dist,0,sup_d/2]) rotate([-90,-90,0]) slot(pcb_d,joint_in_material,ext-sup_d);
    }
  }
}
module cable_tie(sl=joint_screw_len){
  // sl - screw length
  h=sl-joint_extr_depth;
  arm_w=3;
  arm_space=2;
  union(){
    // plate
    difference(){
      cube([ext,ext,h]);
      translate([ext/2,ext/2,0]) cylinder(h=h,d=joint_screw_d+2*printer_off);
    }
    // arms
    translate([ext/2,arm_space,h]) rotate([-90,0,0]) difference(){
      cylinder(d=ext,h=ext-2*arm_space);
      // zip holes
      translate([-2,-ext/2+2,0]) cube([4,2.5,ext]);
      translate([-ext/2+2,-2.5,0]) cube([4,2.5,ext]);
      translate([ext/2-2-4,-2.5,0]) cube([4,2.5,ext]);

      // cut
      translate([-ext/2,0,0]) cube([ext,ext/2,ext]);
      translate([-ext/2,-ext/2,arm_w]) cube([ext,ext/2,ext-2*arm_w-2*arm_space]);
    }
  }
}
module optical_endstop(screws=false){
  difference(){
    union(){
      // pcb
      color("green") cube([33.3,10.2,1.5]);
      // photo elements
      color("#0f0f0f") translate([0,1.95,1.5]) {
        cube([25.1,6.30,3.20]);
        translate([6.8,0,0]) cube([4.4,6.3,12.10]);
        translate([14,0,0]) cube([4.4,6.3,12.10]);
      }
      // socket
      translate([30,5.1,0]) rotate([180,0,-90]) jst_xh_header(jst_xh_header,3);
    }
    // holes
    for (i=[0:1])
      translate([optical_endstop_holes[i].x,optical_endstop_holes[i].y,0]) cylinder(h=5,d=3.2);
  }
  if (screws)
    for (i=[0:1])
      translate([optical_endstop_holes[i].x,optical_endstop_holes[i].y,1.5+3.20]) screw(M3_cap_screw,8);  
}
module z_endstop_mount(){
  scr_len=10;
  h=scr_len-joint_extr_depth; //4
  color(pp_color) difference(){
    union(){
      cube([25,ext,h]);
      translate([ext/2,0,0]) rotate([-90,0,0]) vslot_groove(ext);
    }
    // hole for pcb elements legs
    translate([6.25,0,2]) cube([12,10.2,2]);

    // holes for M3
    for (i=[0:1])
      translate([optical_endstop_holes[i].x,optical_endstop_holes[i].y,0]) cylinder(h=5,d=m3_hole);
    // hole for mounting screw
    translate([ext/2,0.75*ext,h]) rotate([180,0,0]) joint_hole(10,10);
  }
}
module y_endstop_mount(){
  md=12;
  my=11;
  color(pp_color2) difference(){
    // main shape
    translate([-md,my,-1]) linear_extrude(30) polygon([ [0,0], [md,0], [md,-my], [0,-2] ]);

    // holes for sensor
    for (i=[0:1])
      translate([0,my-optical_endstop_holes[i].y-0.4,optical_endstop_holes[i].x]) rotate([0,-90,0]) cylinder(h=md,d=m3_hole);
    // holes for motor mount
    translate([-1.5-5,my-2,1.5]) rotate([0,-90,-90]){
      slot(d=3+2*printer_off,h=2,l=5);
      translate([0,0,-my+2])slot(d=6.5,h=my-2,l=5);
    }
    translate([-1.5-5,my-2,1.5+19.5]) rotate([0,-90,-90]){
      slot(d=3+2*printer_off,h=2,l=5);
      translate([0,0,-my+2])slot(d=6.5,h=my-2,l=5);
    }
    // hole for pcb elements legs
    translate([-2,0,6.25]) cube([2,my,12]);

  }
}
module electronics(){
  translate([0,base_d,0]){
    // PSU
    psu_mount_h=4*ext;
    translate([psu_width(S_300_12)/2+ext/2,psu_height(S_300_12),psu_length(S_300_12)/2+psu_mount_h]) rotate([180,-90,-90]) psu(S_300_12);
    // PSU mounts
    //translate([ext,0,psu_mount_h-ext*1.5]) rotate([-90,180,0]) psu_mount(45,12.5,1);
    translate([elec_support,0,psu_mount_h-ext*1.5]) rotate([-90,180,0]) psu_mount(45,12.5,0);
    translate([elec_support-ext,0,psu_mount_h+psu_length(S_300_12)+1.5*ext]) rotate([-90,0,0]) psu_mount(35,12.5,1);
    translate([0,0,psu_mount_h+psu_length(S_300_12)+1.5*ext]) rotate([-90,0,0]) psu_mount(35,12.5,0);
    // Power socket
    translate([5,25,11+10]) rotate([90,0,-90]) iec(IEC_inlet_atx);
    // Power switch
    translate([5,24,38+10]) rotate([0,-90,0]) rocker(large_rocker);
    // power socket mount
    translate([0,0,0]) rotate([0,0,0]) power_socket_mount();
    
    // Control board
    cb_h=80;
    translate([base_w-elec_support/2-55+ext/2,joint_in_material,cb_h]) rotate([-90,-90,0]) btt_skr_13(1);
    // mounts for control board
    translate([base_w-elec_support,0,cb_h-12]) control_board_mount(1);
    translate([base_w,0,cb_h-12+ext]) rotate([0,180,0]) control_board_mount(0);
    translate([base_w-elec_support,0,cb_h+110-8]) control_board_mount(1);
    translate([base_w,0,cb_h+110-8+ext]) rotate([0,180,0]) control_board_mount(0);
    translate([base_w-elec_support,0,cb_h+161-8]) control_board_mount(1);
    translate([base_w,0,cb_h+161-8+ext]) rotate([0,180,0]) control_board_mount(0);

    // Z end stop
    translate([base_w-elec_support,-ext,ext*3]) rotate([90,0,0]) {
      translate([0,0,4]) optical_endstop(screws=true);
      z_endstop_mount();
    }
    // Y end stop
    translate([base_w-15,-ext-10,base_h+belty_shift-2-8.5]) {
      translate([0,0,0]) rotate([0,90,0]) optical_endstop(screws=true);
      translate([0,0,-25]) y_endstop_mount();
    }
    // FPC mount
    translate([fpc_x,-20,base_h+fpc_z]) rotate([90,0,0]) fpc30_pcb();
  }
}

module draw_whole_printer(){
  frame();
  gantry();
  z_axis();
  electronics();
}
module draw_printable_parts(){
  if (render_parts==1) translate([0,0,0]) tnut_m5();
  if (render_parts==2) translate([10,0,0]) joint1x1();
  if (render_parts==3) translate([40,0,0]) joint2x2();
  if (render_parts==4) {
    //translate([-30,0,0]) psu_mount(45,12.5,1);
    translate([-55,0,0]) psu_mount(45,12.5,0);
    translate([-80,0,0]) psu_mount(35,12.5,1);
    translate([-105,0,0]) psu_mount(35,12.5,0);
  }
  if (render_parts==5) translate([-30,30,0]) power_socket_mount();
  if (render_parts==6) {
    translate([30,50,0]) rotate([-90,0,0]) control_board_mount(0);
    translate([30,75,0]) rotate([-90,0,0]) control_board_mount(1);
  }
  if (render_parts==7) translate([100,0,0]) T8_clamp();
  if (render_parts==8) translate([120,0,0]) T8_spacer();
  if (render_parts==9) translate([100,50,0]) bb_support(0);
  if (render_parts==10) translate([125,50,0]) bb_support(1);
  if (render_parts==11) translate([140,0,0]) joint_front();
  if (render_parts==12) translate([170,80,0]) z_pulley_support();
  if (render_parts==13) translate([170,00,0]) motor_support_z();
  if (render_parts==14) translate([-30,-25,0]) cable_tie(10);
  if (render_parts==15) translate([100,-20,0]) z_pulley_helper();
  if (render_parts==16) translate([120,-20,0]) z_wheel_mount(0);
  if (render_parts==17) translate([120,-60,0]) z_wheel_mount(1);
  if (render_parts==18) translate([0,-80,0]) joint_bed();
  if (render_parts==19) translate([50,-80,0]) bed_support();
  if (render_parts==20) translate([200,-90,0]) bed_to_t8(1.5*ext);
  if (render_parts==21) translate([200,-40,0]) bed_to_t8(2*ext);
  if (render_parts==22) translate([250,-30,0]) z_endstop_mount();
  if (render_parts==23) translate([250,-60,0]) z_endstop_trigger();
  if (render_parts==24) translate([250,0,0]) mgn12_mount_helper();
  if (render_parts==25) translate([-140,-80,0]) motor_support_x_down();
  if (render_parts==26) translate([-200,-80,-40]) motor_support_x_up();
  if (render_parts==27) translate([-base_w-210,-80,0]) motor_support_y_down();
  if (render_parts==28) translate([-base_w-320,-80,-40]) motor_support_y_up();
  if (render_parts==29) translate([-310,0,0]) pulley_support_front_down(logo=1);
  if (render_parts==30) translate([-110,0,0]) mirror([1,0,0]) pulley_support_front_down(logo=0);
  if (render_parts==31) translate([-140,40,0]) pulley_spacer(1);
  if (render_parts==32) translate([-140,50,0]) pulley_spacer(2);
  if (render_parts==33) translate([-200,60,0]) pulley_support_front_up();
  if (render_parts==34) translate([-210,60,0]) mirror([1,0,0]) pulley_support_front_up();
  if (render_parts==35) translate([0,100,0]) oldham_low();
  if (render_parts==36) translate([-30,100,0]) oldham_mid();
  if (render_parts==37) translate([0,150,0]) oldham_hi(1.5*ext);
  if (render_parts==38) translate([-40,150,0]) oldham_hi(2*ext);
  if (render_parts==39) translate([0,0,0]) gantry_joint_l_cf();
  if (render_parts==40) translate([0,0,0]) gantry_joint_l_cf_top();
  if (render_parts==41) translate([0,0,0]) gantry_joint_r_cf();
  if (render_parts==42) translate([0,0,0]) gantry_joint_r_cf_top();
  if (render_parts==43) translate([0,0,0]) mgn9_mount_helper();
  if (render_parts==44) translate([0,0,0]) xy_endstop_trigger();
  if (render_parts==45) translate([0,0,0]) motor_spacer_y();
  if (render_parts==46) translate([0,0,0]) y_endstop_mount();
  if (render_parts==47) cf_m3_mount_jig();
  if (render_parts==48) extruder_mount_base_mgn9();
  if (render_parts==49) blower_to_v6();
  if (render_parts==50) blower_spacer();
}

if ($preview) {
  $fn=20;
  draw_whole_printer();
} else {
  $fn=90;
  draw_printable_parts();
}

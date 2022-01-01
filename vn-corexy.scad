/* Very Narrow CoreXY Printer (vn-corexy)
   Created with goal: use as small space in width dimension as possible.
   (C) 2020 Marek Wodzinski <majek@w7i.pl> https://majek.sh
   
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
hotend_type=1; // [0:with BMG extruder, 1: bowden type]
hotend_nozzle=67-hotend_type*30; //distance from gantry to nozzle
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
render_parts=0; // [0:All, 1:T-nut M5, 2: Joiner 1x1, 3: Joiner 2x2, 4: PSU mounts, 5: Power socket mount, 6: Control board mounts, 7: T8 clamp, 8: T8 spacer, 9: T8 side mount, 10: T8 rear mount, 11: Front joiner, 12: Z pulley support, 13: Z motor mount, 14: cable tie mount, 15: Z pulley helper for adjusting, 16: Front Z wheel mount, 17: Rear Z wheel mount, 18: Front bed frame joiner and bed support, 19: Back bed support, 20: Side bed frame to T8 mount, 21: Back bed frame to T8 mount, 22: Z endstop mount, 23: Z endstop trigger, 24: Linear rails positioning tool, 25: X motor mount base, 26: X motor mount top, 27: Y motor mount base, 28: Y motor mount top, 29: Front pulley support left down, 30: Front pulley support right down, 31: Pulley spacer 1mm, 32: Pulley spacer 2mm, 33: Front pulley support left up, 34: Front pulley support right up, 35: Oldham T8, 36: Oldham middle, 37: Oldham top sides, 38: Oldham top back, 39: Left gantry join for CF tube]

/* [tweaks/hacks] */

// increase up to 1 if your printer is perfect :-), decrease when joiner doesn't fit into v-slot groove
vslot_groove_scale=0.98;

// 1 for perfect printer, little larger if nut doesn't fit into hole
tnut_nut_scale=1.03;

// make holes printable without supports
bridge_support=true;
// thickness of bridge layer if bridge_support is enabled
bridge_thickness=0.25;

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
belt_x_shift=34+4; // distance from frame to bottom of X belt pulley
belt_y_shift=belt_x_shift+belt_z_separation; // distance from frame to bottom of Y belt pulley
xy_motor_pos=[21+2*ext,base_d+22]; // X motor position, for Y motor is mirrored
x_motor_z=belt_x_shift-5; // X motor relative Z position
y_motor_z=belt_y_shift-12; // Y motor relative Z position
xy_o_pulley_pos=[ext/2,base_d+ext]; // motor outer pulley position
xy_i_pulley_pos=[ext/2+belt_x_separation,base_d]; // motor inner pulley position
elec_support=135; // distance for electronic supports from edge of frame (just guess, should be adjusted for real hardware)
// extrusion joiner/corner, set for M5x12
joiner_screw_len=12; // length of screw
joiner_screw_d=5; // screw diameter
joiner_screw_head_d=8.5; // head diameter
joiner_screw_washer=10; // washer diameter
joiner_screw_head_h=5; // head height
joiner_extr_depth=5.5; // depth of screw in extrusion profile, 6 is fine for 2020
joiner_in_material=joiner_screw_len-joiner_extr_depth; // amount of thread in joiner
joiner_space=joiner_screw_len-joiner_extr_depth+joiner_screw_head_h+joiner_screw_head_d/2; // minimum space from corner to allow put two perpendicular screws
t8_frame_dist=2.5; // distance from frame to start of T8 screw
t8_bb_offset=1.5; // space from start of T8 to ball bearing
m5_hole=4.75; // hole for direct M5 screw without tapping
m3_hole=2.75; // hole for direct M3 screw without tapping
bed_z=base_h-2*ext-10-pos_z; // bed Z position

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
module joiner_hole(jl,screw_l=joiner_screw_len,print_upside=false){
  union(){
    // hole for thread
    rotate([0,0,0]) cylinder(h=screw_l,d=joiner_screw_d+2*printer_off);
    // hole for head
    if (print_upside && bridge_support) {
      translate([0,0,-bridge_thickness]) rotate([180,0,0]) cylinder(h=jl-bridge_thickness,d=joiner_screw_washer);
    } else {
      rotate([180,0,0]) cylinder(h=jl,d=joiner_screw_washer);
    }
    // hole for hex tool
    translate([0,0,-jl]) rotate([180,0,0]) cylinder(h=40,d=5);
    // cut tongue for rotating t-nut
    if (printed_corners_nut==1)
      translate([0,0,screw_l-joiner_extr_depth+1]) cylinder(d=9, h=2, center=true);
    // cut tongue for long sliding t-nut
    if (printed_corners_nut==2)
      translate([0,0,screw_l-joiner_extr_depth+1]) cube([7,12,2], center=true); // 12 - slide length
  }
}
module joiner1x1(){
  j1x1_len=20;
  color(pp_color) difference(){
    union(){
      // main shape
      linear_extrude(ext) polygon([[0,0], [j1x1_len,0], [j1x1_len,joiner_screw_len-joiner_extr_depth], [joiner_screw_len-joiner_extr_depth,j1x1_len], [0,j1x1_len]]);
      // positioning groove
      translate([0,0,ext/2]) rotate([180,-90,0]) vslot_groove(j1x1_len);
      translate([0,0,ext/2]) rotate([0,90,90]) vslot_groove(j1x1_len);
    }
    // screw holes
    translate([joiner_space,joiner_in_material,ext/2]) rotate([90,0,0]) joiner_hole(j1x1_len);
    translate([joiner_in_material,joiner_space,ext/2]) rotate([0,-90,0]) joiner_hole(j1x1_len);
  }
  
  echo("J1x1");
}
module joiner2x2(){
  j2x2_len=40;
  color(pp_color) difference(){
    union(){
      // main shape
      linear_extrude(ext) polygon([[0,0], [j2x2_len,0], [j2x2_len,joiner_screw_len-joiner_extr_depth], [joiner_screw_len-joiner_extr_depth,j2x2_len], [0,j2x2_len]]);
      // positioning groove
      translate([0,0,ext/2]) rotate([180,-90,0]) vslot_groove(j2x2_len);
      translate([0,0,ext/2]) rotate([0,90,90]) vslot_groove(j2x2_len);
    }
    // screw holes
    translate([joiner_space,joiner_in_material,ext/2]) rotate([90,0,0]) joiner_hole(j2x2_len);
    translate([joiner_space+20,joiner_in_material,ext/2]) rotate([90,0,0]) joiner_hole(j2x2_len);
    translate([joiner_in_material,joiner_space,ext/2]) rotate([0,-90,0]) joiner_hole(j2x2_len);
    translate([joiner_in_material,joiner_space+20,ext/2]) rotate([0,-90,0]) joiner_hole(j2x2_len);

  }
  
  echo("J2x2");
}
module joiner_bed(){
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
    translate([joiner_space+4,joiner_in_material,ext/2]) rotate([90,0,0]) joiner_hole(jb_y);
    translate([jb_x-6.5,joiner_in_material,ext/2]) rotate([90,0,0]) joiner_hole(jb_y);
    translate([joiner_in_material,joiner_space,ext/2]) rotate([0,-90,0]) joiner_hole(jb_x);
    translate([joiner_in_material,slot_l+slot_y,ext/2]) rotate([0,-90,0]) joiner_hole(jb_x);

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
    translate([joiner_in_material,13,ext/2]) rotate([0,-90,0]) joiner_hole(jb_x);
    translate([joiner_in_material,jb_y-13,ext/2]) rotate([0,-90,0]) joiner_hole(jb_x);

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
module joiner_front(){
  jf_h=1*ext;
  jf_l=1.49*ext;
  color(pp_color) difference(){
    union(){
      // main shape
      linear_extrude(ext) polygon([[0,0], [jf_h,0], [jf_h,joiner_in_material], [joiner_in_material,jf_l], [joiner_in_material/2,jf_l], [joiner_in_material/2,jf_l-ext], [0,ext/2]]);
      // positioning groove
      translate([0,0,ext/2]) rotate([180,-90,0]) vslot_groove(jf_h);
      translate([0,0,ext/2]) rotate([0,90,90]) vslot_groove(ext/2);
    }
    // screw holes
    translate([joiner_space,joiner_in_material,ext/2]) rotate([90,0,0]) joiner_hole(jf_l);
    //translate([joiner_space+20,joiner_in_material,ext/2]) rotate([90,0,0]) joiner_hole(jf_l);
    translate([joiner_in_material,1*ext,ext/2]) rotate([0,-90,0]) joiner_hole(jf_h);
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
module printed_joiners(){
  // joiners
  // bottom - main frame
  translate([ext,ext,0]) rotate([0,0,0]) joiner2x2();
  translate([base_w-ext,ext,0]) rotate([0,0,90]) joiner2x2();
  translate([ext,base_d-2*ext,0]) rotate([0,0,-90]) joiner2x2();
  translate([base_w-ext,base_d-2*ext,0]) rotate([0,0,180]) joiner2x2();
  // bottom - Z pulley support
  translate([ext,z_pulley_support+0.5*ext,0]) rotate([0,0,0]) joiner1x1();
  translate([base_w-ext,z_pulley_support+0.5*ext,0]) rotate([0,0,90]) joiner1x1();
  //translate([ext,z_pulley_support-0.5*ext,0]) rotate([0,0,-90]) joiner1x1();
  translate([base_w-ext,z_pulley_support-0.5*ext,0]) rotate([0,0,180]) joiner1x1();
  // front
  translate([ext,ext,2*ext]) rotate([90,0,0]) joiner2x2();
  translate([base_w-ext,ext,2*ext]) rotate([90,-90,0]) joiner2x2();
  translate([base_w-ext,ext,base_h-2*ext]) rotate([90,180,0]) joiner2x2();
  translate([ext,ext,base_h-2*ext]) rotate([90,90,0]) joiner2x2();
  // left
  translate([ext,base_d-2*ext,ext]) rotate([90,0,-90]) joiner2x2();
  translate([ext,base_d-2*ext,base_h-ext]) rotate([0,90,180]) joiner2x2();
  translate([0,base_d,base_h-ext]) rotate([0,90,0]) joiner2x2();
  // left - filament support
  translate([ext,base_d/2,ext]) rotate([90,0,-90]) joiner1x1();
  translate([ext,base_d/2,base_h-ext]) rotate([0,90,180]) joiner1x1();
  translate([ext,base_d/2+ext,ext]) rotate([0,-90,0]) joiner1x1();
  translate([0,base_d/2+ext,base_h-ext]) rotate([0,90,0]) joiner1x1();
  // right
  translate([base_w,base_d-2*ext,ext]) rotate([90,0,-90]) joiner2x2();
  translate([base_w,base_d-2*ext,base_h-ext]) rotate([0,90,180]) joiner2x2();
  translate([base_w-ext,base_d,base_h-ext]) rotate([0,90,0]) joiner2x2();
  // back
  translate([ext,base_d,ext]) rotate([90,0,0]) joiner2x2();
  translate([ext,base_d-ext,base_h-ext]) rotate([-90,0,0]) joiner2x2();
  translate([base_w-ext,base_d,base_h-ext]) rotate([90,180,0]) joiner2x2();
  translate([base_w-ext,base_d,ext]) rotate([90,-90,0]) joiner2x2();
  // back - electronics support
  translate([elec_support,base_d,ext]) rotate([90,0,0]) joiner1x1();
  translate([base_w+ext-elec_support,base_d,ext]) rotate([90,0,0]) joiner1x1();
  translate([elec_support,base_d-ext,base_h-ext]) rotate([-90,0,0]) joiner1x1();
  translate([base_w+ext-elec_support,base_d-ext,base_h-ext]) rotate([-90,0,0]) joiner1x1();
  translate([elec_support-ext,base_d,base_h-ext]) rotate([90,180,0]) joiner1x1();
  translate([base_w-elec_support,base_d,base_h-ext]) rotate([90,180,0]) joiner1x1();
  translate([elec_support-ext,base_d,ext]) rotate([90,-90,0]) joiner1x1();
  translate([base_w-elec_support,base_d,ext]) rotate([90,-90,0]) joiner1x1();
  // front joiners near T8 screws
  translate([ext,2*ext,ext]) rotate([0,-90,0]) joiner_front();
  translate([base_w,2*ext,ext]) rotate([0,-90,0]) joiner_front();
  translate([0,2*ext,base_h-ext]) rotate([0,90,0]) joiner_front();
  translate([base_w-ext,2*ext,base_h-ext]) rotate([0,90,0]) joiner_front();
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
  // left support for filament spool
  translate([ext,base_d/2,ext]) ext2020(length_b);

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

  // printed joiners
  if (printed_corners) printed_joiners();
}

module bmg_extruder(){
  bmg_color=[0.2, 0.2, 0.2];
  bmg_points=[[0,0],[42,0],[42,53],[19,53],[0,38]];
  translate([-21,-17,-21]) rotate([90,0,0]) color(bmg_color) linear_extrude(height=34, center=true) polygon(bmg_points);
  bmg_side_points=[[0,0],[20,0],[20,26],[16,54],[4,54],[0,26]];
  translate([20,-29,-3]) rotate([95,0,90]) color(bmg_color) linear_extrude(height=5, center=true) polygon(bmg_side_points);
}
module extruder_with_bmg(){
  translate([0,-36,-4]) rotate([0,0,90]) hot_end(E3Dv6, 1.75, bowden = false,resistor_wire_rotate = [0,0,0], naked = false);
  translate([-6,-12,8]) {
    rotate([90,0,0])NEMA(NEMA17S23);
    translate([0,-1,0])bmg_extruder();
  }
}
module extruder_bowden_type(){
  translate([0,0,-4]) rotate([0,0,-90]) hot_end(E3Dv6, 1.75, bowden = true,resistor_wire_rotate = [0,0,0], naked = false);
}
module extruder(){
  if (hotend_type==0) {
    extruder_with_bmg();
  } else
  if (hotend_type==1) {
    extruder_bowden_type();
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
      cube([4.5*ext,ext,belt_x_shift-1]);
      // side
      cube([ext-4,3.5*ext,belt_x_shift-1]);
      // v-slot side
      translate([ext/2,0,0]) rotate([-90,0,0]) vslot_groove(y_rails_from_front-1);
      // v-slot front
      translate([ext,ext/2,0]) rotate([-90,0,-90]) vslot_groove(3.5*ext);
      // pulley support
      //translate([ext/2,ext/2,belt_x_shift-1]) cylinder(d1=9,d2=7,h=1);
    }
    // logo
    if (logo==1) translate([1.75*ext,1,ext/2]) rotate([90,0,0]) scale([2,2,1]) vn_logo(1);
    // hole for linear rail
    translate([(ext-12)/2-2*printer_off,ext*2.5-1,0]) cube([12+2*printer_off,ext+1,8.10]);
    // pulley screw hole
    translate([ext/2,ext/2,-3]) cylinder(h=belt_y_shift+3,d=m5_hole);
    // front right hole
    translate([ext*4,ext/2,35-joiner_extr_depth]) rotate([180,0,00]) joiner_hole(15,35,true);
    // front left hole
    translate([ext*1.5,ext/2,70-joiner_extr_depth]) rotate([180,0,00]) joiner_hole(15,70,true);
    // left front hole
    translate([ext/2,ext,35-joiner_extr_depth]) rotate([180,0,00]) joiner_hole(15,35,true);
    // left back hole
    translate([ext/2,ext*2,70-joiner_extr_depth]) rotate([180,0,00]) joiner_hole(15,70,true);
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
  color(pp_color2) translate([0,0,belt_x_shift-1]) difference(){
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
    translate([0,0,-belt_x_shift+1]) {
      // front left hole
      translate([ext*1.5,ext/2,70-joiner_extr_depth]) rotate([180,0,00]) joiner_hole(15,70,true);
      // left front hole
      translate([ext/2,ext,35-joiner_extr_depth]) rotate([180,0,00]) joiner_hole(8,35,true);
      // left back hole
      translate([ext/2,ext*2,70-joiner_extr_depth]) rotate([180,0,00]) joiner_hole(15,70,true);
      // pulley hole
      translate([ext/2,ext/2,70]) rotate([180,0,00]) joiner_hole(15,50,true);
    }
    // hole for M3 allen key
    translate([ext/2,ext*2.5+12.5,0]) cylinder(h=fh,d=5);
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
    translate([ext/2,ext/2,belt_x_shift-1]) pulley_spacer(1);
    translate([ext/2,ext/2,belt_x_shift+13]) pulley_spacer(2);
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
      translate([xy_o_pulley_pos.x,xy_o_pulley_pos.y-base_d+ext,x_motor_z+3]) cylinder(h=belt_x_shift-x_motor_z-3,d2=7,d1=9);
      // inner pulley spacer
      translate([xy_i_pulley_pos.x,xy_i_pulley_pos.y-base_d+ext,x_motor_z+3]) cylinder(h=belt_x_shift-x_motor_z-3,d2=7,d1=9);
    }
    // corner screw hole
    translate([ext/2,ext/2,35-joiner_extr_depth]) rotate([180,0,00]) joiner_hole(10,35);
    // right screw hole
    translate([4.5*ext,ext/2,35-joiner_extr_depth]) rotate([180,0,00]) joiner_hole(10,35);
    // back screw hole
    translate([ext/2,3*ext,60-joiner_extr_depth]) rotate([180,0,00]) joiner_hole(10,60);
    // middle front screw hole
    translate([1.5*ext,ext/2,60-joiner_extr_depth]) rotate([180,0,00]) joiner_hole(10,60);
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
    translate([xy_o_pulley_pos.x,xy_o_pulley_pos.y-base_d+ext,0]) cylinder(h=belt_x_shift,d=m5_hole);
    // inner pulley hole
    translate([xy_i_pulley_pos.x,xy_i_pulley_pos.y-base_d+ext,0]) cylinder(h=belt_x_shift,d=m5_hole);
  }
}
module motor_support_x_up(){
  yadj=16; // motos position adjust range
  mm_d=top_d-base_d+ext; // motor mount depth
  h_space=pulley_height(GT2_10x20_plain_idler)+(belt_x_shift-x_motor_z-3)+1;
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
    translate([ext/2,3*ext,60-joiner_extr_depth]) rotate([180,0,00]) joiner_hole(10,60,true);
     // middle front screw hole
    translate([1.5*ext,ext/2,60-joiner_extr_depth]) rotate([180,0,00]) joiner_hole(10,60,true);
    // outer pulley hole
    translate([xy_o_pulley_pos.x,xy_o_pulley_pos.y-base_d+ext,60-joiner_extr_depth]) rotate([180,0,00]) joiner_hole(10,60,true);
    // inner pulley hole
    translate([xy_i_pulley_pos.x,xy_i_pulley_pos.y-base_d+ext,60-joiner_extr_depth]) rotate([180,0,00]) joiner_hole(10,60,true);
    // corner screw hole
    translate([ext/2,ext/2,35-joiner_extr_depth]) rotate([180,0,00]) joiner_hole(22,35);

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
  yadj=16; // motos position adjust range
  mm_d=top_d-base_d+ext; // motor mount depth
  h_space=pulley_height(GT2_10x20_plain_idler)+(belt_y_shift-y_motor_z-3)+1;
  color(pp_color2) difference(){
    translate([base_w,0,y_motor_z+3]) union(){
      // main body
      mirror([1,0,0]) difference(){
        // main body
        linear_extrude(y_motor_z-10) polygon([[ext,0],[0,ext],[0,mm_d],[ext,mm_d],[2*ext,ext],[2*ext,0]]);
  
        //belt path
        hull(){
          translate([xy_o_pulley_pos.x,xy_o_pulley_pos.y-base_d+ext,0]) cylinder(h=h_space,d=22);
          translate([xy_motor_pos.x,xy_o_pulley_pos.y-base_d+ext,0]) cylinder(h=h_space,d=22);
          translate([ext/2,ext,0]) cylinder(h=h_space,d=22);
        }
        translate([xy_i_pulley_pos.x,xy_i_pulley_pos.y-base_d+ext,0]) cylinder(h=h_space,d=22);
      }
      // outer pulley spacer
      translate([-xy_o_pulley_pos.x,xy_o_pulley_pos.y-base_d+ext,h_space-1]) cylinder(h=1,d=7);
      // inner pulley spacer
      translate([-xy_i_pulley_pos.x,xy_i_pulley_pos.y-base_d+ext,h_space-1]) cylinder(h=1,d=7);
    }

     // back screw hole
    translate([base_w-ext/2,3*ext,70-joiner_extr_depth]) rotate([180,0,0]) joiner_hole(15,70,true);
     // middle front screw hole
    translate([base_w-1.5*ext,ext/2,70-joiner_extr_depth]) rotate([180,0,0]) joiner_hole(15,70,true);
    // outer pulley hole
    translate([base_w-xy_o_pulley_pos.x,xy_o_pulley_pos.y-base_d+ext,75-joiner_extr_depth]) rotate([180,0,0]) joiner_hole(10,60,true);
    // inner pulley hole
    translate([base_w-xy_i_pulley_pos.x,xy_i_pulley_pos.y-base_d+ext,75-joiner_extr_depth]) rotate([180,0,0]) joiner_hole(10,60,true);
    // corner screw hole
    translate([base_w-ext/2,ext/2,35-joiner_extr_depth]) rotate([180,0,00]) joiner_hole(37,35);
    // base stair
    translate([base_w-ext-printer_off,0,y_motor_z]) cube([ext+printer_off,3.5*ext,10]);
  }
}
module motor_support_y_down(){
  yadj=16; // motor position adjust range
  mm_d=top_d-base_d+ext; // motor mount depth
  color(pp_color) difference(){
    union(){
      // right
      translate([base_w-ext,0,0]) cube([ext,mm_d,y_motor_z+10]);
      // front
      translate([base_w-5*ext,0,0]) cube([5*ext,ext,y_motor_z]);
      // top
      translate([base_w-5*ext,0,y_motor_z]) cube([5*ext,mm_d,3]);
      // back
      translate([base_w,mm_d-5.5,0]) rotate([90,0,180]) linear_extrude(5.5) polygon([[0,0],[ext,0],[5*ext,y_motor_z-10],[5*ext,y_motor_z],[0,y_motor_z]]);
      // v-slot left
      translate([base_w-ext/2,0,0]) rotate([-90,0,0]) vslot_groove(mm_d);
      // v-slot front
      translate([base_w-ext,ext/2,0]) rotate([-90,0,90]) vslot_groove(4*ext);
      // outer pulley spacer
      translate([base_w-xy_o_pulley_pos.x,xy_o_pulley_pos.y-base_d+ext,y_motor_z+3]) cylinder(h=belt_y_shift-y_motor_z-3,d2=7,d1=20);
      // inner pulley spacer
      translate([base_w-xy_i_pulley_pos.x,xy_i_pulley_pos.y-base_d+ext,y_motor_z+3]) cylinder(h=belt_y_shift-y_motor_z-3,d2=7,d1=20);
    }
    // corner screw hole
    translate([base_w-ext/2,ext/2,50-joiner_extr_depth]) rotate([180,0,00]) joiner_hole(15,50);
    // left screw hole
    translate([base_w-4.5*ext,ext/2,45-joiner_extr_depth]) rotate([180,0,00]) joiner_hole(10,45);
    // back screw hole
    translate([base_w-ext/2,3*ext,70-joiner_extr_depth]) rotate([180,0,00]) joiner_hole(10,70);
    // middle front screw hole
    translate([base_w-1.5*ext,ext/2,70-joiner_extr_depth]) rotate([180,0,00]) joiner_hole(10,70);
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
    translate([base_w-xy_o_pulley_pos.x,xy_o_pulley_pos.y-base_d+ext,0]) cylinder(h=belt_y_shift,d=m5_hole);
    // inner pulley hole
    translate([base_w-xy_i_pulley_pos.x,xy_i_pulley_pos.y-base_d+ext,0]) cylinder(h=belt_y_shift,d=m5_hole);
  }
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
      translate([ext/2,ext/2,msl-joiner_extr_depth]) rotate([180,0,0]) joiner_hole(20,msl,true);
      translate([ext/2,ext/2+44,msl-joiner_extr_depth]) rotate([180,0,0]) joiner_hole(20,msl,true);
      translate([ext/2+44,ext/2+44,msl-joiner_extr_depth]) rotate([180,0,0]) joiner_hole(20,msl,true);
    }
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
// Carbon fiber tube private variables
cf_above_carriage=3.5; // height of cf above carriage
cf_from_front=5; // distance from front of carriage
module gantry_joint_l_cf(pulx, puly){
  under_screw_pos=2*ext;
  // screws
  if ($preview) {
    // Y pulley
    m5_screw1=40;
    translate([puly.x,puly.y,puly.z+17]) screw(M5_cap_screw,m5_screw1);
    // X pulley
    m5_screw2=50;
    translate([pulx.x,pulx.y,m5_screw2+7]) screw(M5_cap_screw,m5_screw2);
    // back cf mounting
    m5_screw3=20;
    translate([ext/2-2,carriage_length(y_rail_carriage)+m5_screw3-cf_from_front-cf_tube_size,ext/2+cf_above_carriage]) rotate([-90,0,0]) screw(M5_cap_screw,m5_screw3);
    // front cf mounting
    m5_screw4=10;
    translate([ext/2,1,ext/2+cf_above_carriage]) rotate([90,0,0]) screw(M5_dome_screw,m5_screw4);
    // bottom cf mount
    m5_screw5=8;
    translate([under_screw_pos,cf_tube_size/2+cf_from_front,cf_above_carriage-1.5]) rotate([180,0,0]) screw(M5_dome_screw,m5_screw5);
    // carriage inner mount
    m3_screw1=6;
    translate([ext,13,m3_screw1-3]) screw(M3_cs_cap_screw,m3_screw1);
    m3_screw3=20;
    translate([ext,33,m3_screw3-3]) screw(M3_cap_screw,m3_screw3);
    // carriage outer mount
    m3_screw2=25;
    translate([0,13,m3_screw1-3]) screw(M3_cs_cap_screw,m3_screw1);
    translate([0,33,m3_screw2-3]) screw(M3_cap_screw,m3_screw2);
  }

  // mount
  rd=5;
  box_h=cf_above_carriage+cf_tube_size;
  x_offset=-(carriage_width(y_rail_carriage)-ext)/2;
  difference(){
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
      translate([puly.x-3.5,0,box_h]) rotate([90,0,90]) linear_extrude(ext-7) polygon([ [0,0], [puly.y+6,0], [puly.y+6,puly.z-box_h-1], [puly.y-3.5,puly.z-box_h-1],[0,6.5] ]);
      //spacer for Y idler
      translate([puly.x,puly.y,puly.z-1]) pulley_spacer();
      //spacer for X idler
      translate([pulx.x,pulx.y,pulx.z-2]) pulley_spacer(2);
    }
    // holes

    // hole for cf tube
    translate([x_offset,cf_from_front-printer_off,cf_above_carriage]) cube([carriage_width(y_rail_carriage)+2,cf_tube_size+2*printer_off,cf_tube_size+0.5]); // 0.5 for hanging bidge or rought surface above supports
    //hole for mgn
    translate([x_offset,cf_from_front+cf_tube_size/2-5,cf_above_carriage+cf_tube_size]) cube([carriage_width(y_rail_carriage),10,7]);
    // hole for X pulley
    translate([pulx.x,pulx.y,pulx.z-1]) cylinder(h=16,d=20);
  }
}
module gantry_joint_l(pulx, puly){
  if (x_gantry_type==0) {
    gantry_joint_l_vslot(pulx, puly);
  } else if (x_gantry_type==1) {
    gantry_joint_l_cf(pulx, puly);
  }
}
module gantry_joint_r(pulx, puly){
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
module gantry(){
  // Y carriage positions
  echo("Side rails lenght",y_rail_l);
  echo("Maximum rails length",base_d-2*ext);
  real_y=pos_y+hotend_d;
  carriage_pos_y=real_y-carriage_travel(y_rail_carriage,y_rail_l)/2-y_rails_from_front+ext;
  carriage_y_real=real_y+ext+carriage_length(y_rail_carriage)/2;
  carriage_pos_x=pos_x-build_x/2;


  // left linear rail
  translate([ext/2,y_rail_l/2+y_rails_from_front,base_h]) rotate([0,0,90]) rail_assembly(y_rail_carriage,y_rail_l,carriage_pos_y);
  // right linear rail
  translate([base_w-ext/2,y_rail_l/2+y_rails_from_front,base_h]) rotate([0,0,90]) rail_assembly(y_rail_carriage,y_rail_l,carriage_pos_y);

  // position in Y of pulleys/belt on gantry
  gantry_belt_shift=6;

  // X axis
  // X start anchor point
  bx1=[base_w/2-build_x/2+pos_x,carriage_y_real+gantry_belt_shift+pr20,base_h+belt_x_shift];
  translate(bx1) cube([0.1,12,12]);
  // X idler - gantry left
  bx2=[ext/2+belt_x_separation,carriage_y_real+gantry_belt_shift+2*pr20,base_h+belt_x_shift];
  translate(bx2) pulley(GT2_10x20_plain_idler);
  // X idler - inner rail-motor
  bx3=[ext/2+belt_x_separation,base_d,base_h+belt_x_shift];
  translate(bx3) pulley(GT2_10x20_plain_idler);
  // X motor
  bx4=[xy_motor_pos.x,xy_motor_pos.y,base_h+belt_x_shift-5];
  translate(bx4) rotate([0,0,-90]) NEMA(NEMA17M);
  translate([bx4.x,bx4.y,bx4.z+25.5]) rotate([0,180,0]) pulley(GT2_10x20ob_pulley);
  // X idler - outer rail-motor
  bx5=[ext/2,base_d+ext,base_h+belt_x_shift];
  translate(bx5) pulley(GT2_10x20_toothed_idler);
  // X idler - front left
  bx6=[ext/2,ext/2,base_h+belt_x_shift];
  translate(bx6) pulley(GT2_10x20_toothed_idler);
  // X idler - front right
  bx7=[base_w-ext/2,ext/2,base_h+belt_x_shift];
  translate(bx7) pulley(GT2_10x20_toothed_idler);
  // X idler - gantry right
  bx8=[base_w-ext/2,carriage_y_real+gantry_belt_shift,base_h+belt_x_shift];
  translate(bx8) pulley(GT2_10x20_toothed_idler);
  
  // X belt
  belt_x_path=[[bx8.x,bx8.y,pr20], [bx7.x,bx7.y,pr20], [bx6.x,bx6.y,pr20], [bx5.x,bx5.y,pr20], [bx4.x,bx4.y,pr20], [bx3.x,bx3.y,-pr20], [bx2.x,bx2.y,-pr20],[bx1.x,bx1.y,0]];
  translate([0,0,base_h+belt_x_shift+6.5]) belt(GT2x10,belt_x_path);
  echo("X belt length",belt_length(GT2x10,belt_x_path));

  // Y axis
  // Y start anchor point
  by1=[base_w/2-build_x/2+pos_x,carriage_y_real+gantry_belt_shift+pr20,base_h+belt_y_shift];
  translate(by1) cube([0.1,12,12]);
  // Y idler - gantry right
  by2=[base_w-ext/2-belt_x_separation,carriage_y_real+gantry_belt_shift+2*pr20,base_h+belt_y_shift];
  translate(by2) pulley(GT2_10x20_plain_idler);
  // Y idler - inner rail-motor
  by3=[base_w-ext/2-belt_x_separation,base_d,base_h+belt_y_shift];
  translate(by3) pulley(GT2_10x20_plain_idler);
  // Y motor
  pulley_motor_space=-7.5;
  by4=[base_w-xy_motor_pos.x,xy_motor_pos.y,base_h+belt_y_shift];
  translate([by4.x,by4.y,base_h+y_motor_z]) rotate([0,0,90]) NEMA(NEMA17M);
  translate([by4.x,by4.y,by4.z+pulley_motor_space]) pulley(GT2_10x20ob_pulley);
  // Y idler - outer rail-motor
  by5=[base_w-ext/2,base_d+ext,base_h+belt_y_shift];
  translate(by5) pulley(GT2_10x20_toothed_idler);
  // Y idler - front right
  by6=[base_w-ext/2,ext/2,base_h+belt_y_shift];
  translate(by6) pulley(GT2_10x20_toothed_idler);
  // Y idler - front left
  by7=[ext/2,ext/2,base_h+belt_y_shift];
  translate(by7) pulley(GT2_10x20_toothed_idler);
  // Y idler - gantry left
  by8=[ext/2,carriage_y_real+gantry_belt_shift,base_h+belt_y_shift];
  translate(by8) pulley(GT2_10x20_toothed_idler);

  // Y belt
  belt_y_path=[[by1.x,by1.y,0], [by2.x,by2.y,-pr20], [by3.x,by3.y,-pr20], [by4.x,by4.y,pr20], [by5.x,by5.y,pr20], [by6.x,by6.y,pr20], [by7.x,by7.y,pr20], [by8.x,by8.y,pr20]];
  translate([0,0,base_h+belt_y_shift+6.5]) belt(GT2x10,belt_y_path);
  echo("Y belt length",belt_length(GT2x10,belt_y_path));
  
  // X gantry support
  g_shift_y=carriage_y_real-ext-3;
  g_shift_z=base_h+carriage_height(y_rail_carriage);
  translate([0,g_shift_y,g_shift_z]) union(){
    echo(base_w=base_w);
    echo("X rail length",x_rail_l);
    if (x_gantry_type==0) {
      // v-slot + MGN12
      translate([ext/4,5,3.5]) rotate([0,90,0]) ext2020(base_w-ext/2);
      translate([base_w/2,ext*0.5+5,ext+3.5]) rotate([0,0,0]) rail_assembly(MGN12H_carriage,x_rail_l,carriage_pos_x);
    } else if (x_gantry_type==1 ) {
      // cf tube + MGN9
      cf_len=base_w+7;
      echo("CF tube length",cf_len);
      translate([(base_w-cf_len)/2,cf_from_front,cf_above_carriage]) color([0.1,0.1,0.1]) difference(){
        cube([cf_len,cf_tube_size,cf_tube_size]);
        translate([0,cf_tube_wall,cf_tube_wall]) cube([cf_len,cf_tube_size-2*cf_tube_wall,cf_tube_size-2*cf_tube_wall]);
      }
      translate([base_w/2,cf_tube_size/2+cf_from_front,cf_tube_size+cf_above_carriage]) rotate([0,0,0]) rail_assembly(MGN9H_carriage,x_rail_l,carriage_pos_x);
    }
    // gantry joints
    translate([0,0,0]) {
      #gantry_joint_l([bx2.x,bx2.y-g_shift_y,bx2.z-g_shift_z],[by8.x,by8.y-g_shift_y,by8.z-g_shift_z]);
      #translate([base_w-ext,0,0]) gantry_joint_r([bx8.x-(base_w-ext),bx8.y-g_shift_y,bx8.z-g_shift_z],[by2.x-(base_w-ext),by2.y-g_shift_y,by2.z-g_shift_z]);
    }
    // Extruder and mount
    translate([base_w/2-build_x/2+pos_x,-18,10]) extruder();
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
      translate([0,0,joiner_in_material/2]) cube([ext,2.8*ext,joiner_in_material], center=true);
      // around bb
      cylinder(h=t8_frame_dist+t8_bb_offset+T8_BB[3],d=ext);
    }
    
    //hole for bearing
    translate([0,0,t8_frame_dist+t8_bb_offset]) cylinder(h=T8_BB[3],d=T8_BB[2]+2*printer_off);
    // hole under bearing
    translate([0,0,0]) cylinder(h=t8_frame_dist+t8_bb_offset,d=T8_BB[2]-2);
    
    // holes for screws
    translate([0,ext,joiner_in_material]) rotate([180,0,0]) joiner_hole(0);
    translate([0,-ext,joiner_in_material]) rotate([180,0,0]) joiner_hole(0);
    
    // hole for joiner
    if (rear==0) {
      translate([-ext/2,-1.5*ext,joiner_in_material/2]) cube([ext,ext,joiner_in_material/2]);
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
      translate([-ext/2,ext/2,0]) rotate([90,0,0]) linear_extrude(ext) polygon([[-ext,0], [2*ext,0], [2*ext,joiner_in_material], [ext/2+4,block_h], [ext/2-4,block_h], [-ext,joiner_in_material]]);
      // spacer
      translate([0,0,block_h]) cylinder(h=1,d=7);
      // v-slot insert
      //translate([-ext/2,0,0])rotate([-90,0,-90]) vslot_groove(2*ext);
    }
    // hole for longer screw
    translate([0,0,0]) cylinder(h=block_h+1,d=m5_hole);
    // hole for normal screw
    translate([ext,0,joiner_in_material])rotate([180,0,0]) joiner_hole(20);
    translate([-ext,0,joiner_in_material])rotate([180,0,0]) joiner_hole(20);
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
        translate([ext/2,-joiner_in_material,0]) cube([3*ext,joiner_in_material,ext+back*ext/2]);
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
    translate([3*ext,-joiner_in_material,ext/2+back*ext/2]) rotate([-90,0,0]) joiner_hole(1.5*ext);
    translate([1.2*ext,-joiner_in_material,ext/2+back*ext/2]) rotate([-90,0,0]) joiner_hole(1.5*ext);  }
}
// oldham coupler
oldham_w=ext*1.3; // width of oldham coupler
oldham_d=ext*1.2; // depth of oldham coupler (without margin)
oldham_lh=10.5; // height of low part
oldham_mh=8; // height of middle part
oldham_margin=2.0; // space between coupler and outer shape of printer
oldham_w_h=5; // wedge height
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
    translate([dist-joiner_in_material,ow/2-7,ext/2]) rotate([0,90,0]) joiner_hole(dist);
    translate([dist-joiner_in_material,-2*ext+7,ext/2]) rotate([0,90,0]) joiner_hole(dist);
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
        translate([4,bw,0]) rotate([90,0,0]) linear_extrude(bw) polygon([[0,0],[dist-4,0],[dist-4,ext],[dist-4-joiner_in_material,ext],[0,10]]);
        // v-slot part
        translate([dist,0,ext/2]) rotate([-90,-90,0]) vslot_groove(bw);
      }
      // hole for leadnut
      translate([0,bw/2,0]) hull(){
        translate([ext/2,0,0]) cylinder(h=ext, d=ln_d+1);
        translate([0,-ln_d/2,0]) cube([ln_d/2,ln_d,ext]);
      }
      // holes for frame mount screws
      translate([dist-joiner_in_material,6,ext/2]) rotate([0,90,0]) joiner_hole(bw);
      translate([dist-joiner_in_material,bw-6,ext/2]) rotate([0,90,0]) joiner_hole(bw);

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
    translate([0.25*ext,4,ext/2]) rotate([90,0,0]) joiner_hole(5,10);
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

  // joiners 2x2
  translate([2.5*ext,base_d-3*ext,-ext]) rotate([0,0,-90]) joiner2x2();
  translate([base_w-2.5*ext,base_d-3*ext,-ext]) rotate([0,0,180]) joiner2x2();
  // joiners/bed mount
  translate([2.5*ext,2.5*ext,-ext]) joiner_bed();
  translate([base_w-2.5*ext,2.5*ext,-ext]) mirror([1,0,0]) joiner_bed();
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
module rail_mount_helper(){
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
    translate([wall+ext/2-mgn_x/2-printer_off,ext/2,0]) cube([mgn_x+2*printer_off,mgn_y+printer_off,th]);
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
      cube([ext,1.5*ext,joiner_in_material]);
      // psu mount
      translate([ext/4+mirr*ext/4,ext/2,0]) rotate([90,0,90]) linear_extrude(ext/4) polygon([[0,0],[h_len+m_h/2+ext,0],[h_len+m_h/2+ext,m_h],[ext,m_h]]);
    }
    // frame screw hole
    translate([ext/2,ext/2,joiner_in_material])rotate([0,180,0]) joiner_hole(joiner_in_material);
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
      translate([ext/4,0,3*ext]) linear_extrude(ext) polygon([[0,0],[0.75*ext,0],[0.75*ext,joiner_in_material],[0,ext]]);
      // mount for zip-tie
      translate([ext/2,6,4*ext-2]) intersection(){
        difference(){
          cylinder(h=2,d=ext);
          cylinder(h=2,d=ext-3);
        }
        cube([ext/2,ext/2,2]);
      }
      // bottom mount
      translate([ext/4,joiner_in_material,0]) rotate([90,0,0]) linear_extrude(joiner_in_material) polygon([[0,0],[2.75*ext,0],[2.75*ext,ext],[0,2*ext],[0,1.5*ext],[1.5*ext,ext],[0,ext/2]]);
      // mount plate
      translate([ext/4,0,0]) cube([ext/4,50,7*ext]);
    }
    // bottom mount hole
    translate([2.2*ext,joiner_in_material,ext/2]) rotate([90,0,0]) joiner_hole(25);
    // top mount hole
    translate([ext/2+0.1,joiner_in_material,3.5*ext]) rotate([90,0,0]) joiner_hole(20);
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
        cube([ext,joiner_in_material,ext]);
        // pcb mounts
        translate([d_dist,0,sup_d/2]) rotate([-90,0,0]) cylinder(h=joiner_in_material,d=sup_d);
        translate([d_dist,0,ext-sup_d/2]) rotate([-90,0,0]) cylinder(h=joiner_in_material,d=sup_d);
      }
      // v-slot
      translate([ext/2,0,0]) rotate([0,0,180]) vslot_groove(ext);
    }
    // hole for mount screw
    translate([ext/2,joiner_in_material,ext/2]) rotate([90,0,0]) joiner_hole(0);
    // pcb mount hole
    if (orient==0) {
      // 2 horizontal
      translate([d_dist-4,0,sup_d/2]) rotate([-90,0,0]) slot(pcb_d,joiner_in_material,5);
      translate([d_dist-4,0,ext-sup_d/2]) rotate([-90,0,0]) slot(pcb_d,joiner_in_material,5);
    } else {
      translate([d_dist,0,sup_d/2]) rotate([-90,-90,0]) slot(pcb_d,joiner_in_material,ext-sup_d);
    }
  }
}
module cable_tie(sl=joiner_screw_len){
  // sl - screw length
  h=sl-joiner_extr_depth;
  arm_w=3;
  arm_space=2;
  union(){
    // plate
    difference(){
      cube([ext,ext,h]);
      translate([ext/2,ext/2,0]) cylinder(h=h,d=joiner_screw_d+2*printer_off);
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
module optical_endstop(){
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
    translate([2.75,5.1,0]) cylinder(h=5,d=3.2);
    translate([2.75+19,5.1,0]) cylinder(h=5,d=3.2);
  }
}
module z_endstop_mount(){
  scr_len=10;
  h=scr_len-joiner_extr_depth; //4
  color(pp_color) difference(){
    union(){
      cube([25,ext,h]);
      translate([ext/2,0,0]) rotate([-90,0,0]) vslot_groove(ext);
    }
    // hole for pcb elements legs
    translate([6.25,0,2]) cube([12,10.2,2]);

    // holes for M3
    translate([2.75,5.1,0]) cylinder(h=5,d=m3_hole);
    translate([2.75+19,5.1,0]) cylinder(h=5,d=m3_hole);
    // hole for mounting screw
    translate([ext/2,0.75*ext,h]) rotate([180,0,0]) joiner_hole(10,10);
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
    translate([base_w-elec_support/2-55+ext/2,joiner_in_material,cb_h]) rotate([-90,-90,0]) btt_skr_13(1);
    // mounts for control board
    translate([base_w-elec_support,0,cb_h-12]) control_board_mount(1);
    translate([base_w,0,cb_h-12+ext]) rotate([0,180,0]) control_board_mount(0);
    translate([base_w-elec_support,0,cb_h+110-8]) control_board_mount(1);
    translate([base_w,0,cb_h+110-8+ext]) rotate([0,180,0]) control_board_mount(0);
    translate([base_w-elec_support,0,cb_h+161-8]) control_board_mount(1);
    translate([base_w,0,cb_h+161-8+ext]) rotate([0,180,0]) control_board_mount(0);

    // Z end stop
    translate([base_w-elec_support,-ext,ext*3]) rotate([90,0,0]) {
      translate([0,0,4]) optical_endstop();
      z_endstop_mount();
    }
  }
}

module draw_whole_printer(){
  frame();
  gantry();
  z_axis();
  electronics();
}
module draw_printable_parts(){
  if (render_parts==0 || render_parts==1) translate([0,0,0]) tnut_m5();
  if (render_parts==0 || render_parts==2) translate([10,0,0]) joiner1x1();
  if (render_parts==0 || render_parts==3) translate([40,0,0]) joiner2x2();
  if (render_parts==0 || render_parts==4) {
    //translate([-30,0,0]) psu_mount(45,12.5,1);
    translate([-55,0,0]) psu_mount(45,12.5,0);
    translate([-80,0,0]) psu_mount(35,12.5,1);
    translate([-105,0,0]) psu_mount(35,12.5,0);
  }
  if (render_parts==0 || render_parts==5) translate([-30,30,0]) power_socket_mount();
  if (render_parts==0 || render_parts==6) {
    translate([30,50,0]) rotate([-90,0,0]) control_board_mount(0);
    translate([30,75,0]) rotate([-90,0,0]) control_board_mount(1);
  }
  if (render_parts==0 || render_parts==7) translate([100,0,0]) T8_clamp();
  if (render_parts==0 || render_parts==8) translate([120,0,0]) T8_spacer();
  if (render_parts==0 || render_parts==9) translate([100,50,0]) bb_support(0);
  if (render_parts==0 || render_parts==10) translate([125,50,0]) bb_support(1);
  if (render_parts==0 || render_parts==11) translate([140,0,0]) joiner_front();
  if (render_parts==0 || render_parts==12) translate([170,80,0]) z_pulley_support();
  if (render_parts==0 || render_parts==13) translate([170,00,0]) motor_support_z();
  if (render_parts==0 || render_parts==14) translate([-30,-25,0]) cable_tie(10);
  if (render_parts==0 || render_parts==15) translate([100,-20,0]) z_pulley_helper();
  if (render_parts==0 || render_parts==16) translate([120,-20,0]) z_wheel_mount(0);
  if (render_parts==0 || render_parts==17) translate([120,-60,0]) z_wheel_mount(1);
  if (render_parts==0 || render_parts==18) translate([0,-80,0]) joiner_bed();
  if (render_parts==0 || render_parts==19) translate([50,-80,0]) bed_support();
  if (render_parts==0 || render_parts==20) translate([200,-90,0]) bed_to_t8(1.5*ext);
  if (render_parts==0 || render_parts==21) translate([200,-40,0]) bed_to_t8(2*ext);
  if (render_parts==0 || render_parts==22) translate([250,-30,0]) z_endstop_mount();
  if (render_parts==0 || render_parts==23) translate([250,-60,0]) z_endstop_trigger();
  if (render_parts==0 || render_parts==24) translate([250,0,0]) rail_mount_helper();
  if (render_parts==0 || render_parts==25) translate([-140,-80,0]) motor_support_x_down();
  if (render_parts==0 || render_parts==26) translate([-200,-80,-40]) motor_support_x_up();
  if (render_parts==0 || render_parts==27) translate([-base_w-210,-80,0]) motor_support_y_down();
  if (render_parts==0 || render_parts==28) translate([-base_w-320,-80,-40]) motor_support_y_up();
  if (render_parts==0 || render_parts==29) translate([-310,0,0]) pulley_support_front_down(logo=1);
  if (render_parts==0 || render_parts==30) translate([-110,0,0]) mirror([1,0,0]) pulley_support_front_down(logo=0);
  if (render_parts==0 || render_parts==31) translate([-140,40,0]) pulley_spacer(1);
  if (render_parts==0 || render_parts==32) translate([-140,50,0]) pulley_spacer(2);
  if (render_parts==0 || render_parts==33) translate([-200,60,0]) pulley_support_front_up();
  if (render_parts==0 || render_parts==34) translate([-210,60,0]) mirror([1,0,0]) pulley_support_front_up();
  if (render_parts==0 || render_parts==35) translate([0,100,0]) oldham_low();
  if (render_parts==0 || render_parts==36) translate([-30,100,0]) oldham_mid();
  if (render_parts==0 || render_parts==37) translate([0,150,0]) oldham_hi(1.5*ext);
  if (render_parts==0 || render_parts==38) translate([-40,150,0]) oldham_hi(2*ext);
  if (ender_parts==39) translate([-40,200,0]) gantry_joint_l_cf();
}

if ($preview) {
  $fn=20;
  draw_whole_printer();
} else {
  $fn=90;
  draw_printable_parts();
}

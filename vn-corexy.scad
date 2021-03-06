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
/* [extrusions family size] */
ext=20;
/* [extrusion type] */
ext_type=1; // [0:T-SLOT, 1:V-SLOT]
/* [minumum margin between build plate and frame] */
x_margin=10;
/* [printed parts] */
printed_corners=true; // [false:no, true:yes]
printed_corners_nut=1; // [0:printed nut, 1:rotating t-nut, 2:sliding t-nut]
pp_color=[0.3,0.3,0.3]; // [0:0.1:1]
printed_t8_clamps=true; // [false:no, true:yes]


/* [render printable parts] */
render_parts=0; // [0:All, 1:T-nut M5, 2: Joiner 1x1, 3: Joiner 2x2, 4: PSU mounts, 5: Power socket mount, 6: Control board mounts, 7: T8 clamp, 8: T8 spacer, 9: T8 side mount, 10: T8 rear mount, 11: Front joiner, 12: Z pulley support, 13: Z motor mount, 14: cable tie mount, 15: Z pulley helper for adjusting, 16: Front Z wheel mount, 17: Rear Z wheel mount, 18: Front bed frame joiner and bed support, 19: Back bed support, 20: Side bed frame to T8 mount, 21: Back bed frame to T8 mount, 22: Z endstop mount, 23: Z endstop trigger, 24: Linear rails positioning tool]

/* [tweaks/hacks] */

// increase up to 1 if your printer is perfect :-), decrease when joiner doesn't fit into v-slot groove
vslot_groove_scale=0.98;

// 1 for perfect printer, little larger if nut doesn't fit into hole
tnut_nut_scale=1.03;

// make holes printable withous supports
bridge_support=true;

// use upper ball bearings for T8 rods
t8_upper_bearings=false;

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
y_rails_from_front=1.5*ext;
z_pulley_support=170; //distance from front to Z pulley support
z_belt_h=48; // space from bottom of frame to Z belt
pr20=pulley_pr(GT2x20ob_pulley); // radius of puller for belt calculations
//belt_separation=pulley_od(GT2_10x20_toothed_idler);
belt_separation=6; // distance between side belts
elec_support=135; // distance for electronic supports from edge of frame (just guess, should be adjusted for real hardware)
// extrusion joiner/corner, set for M5x12
joiner_screw_len=12; // length of screw
joiner_screw_d=5; // screw diameter
joiner_screw_head_d=8.5; // head diameter
joiner_screw_washer=10; // washer diameter
joiner_screw_head_h=5; // head height
joiner_extr_depth=6; // depth of screw in extrusion profile, 6 is fine for 2020
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
GT2_10x20_toothed_idler2=["GT2_10x20_toothed_idler2", "GT2", 20, 12.22, GT2x10, 10.9, 18, 0, 5, 18.0, 1.55, 0, 0, false, 0];
GT2_10x20_toothed_idler=["GT2_10x20_toothed_idler", "GT2", 20, 12.22, GT2x10, 10.9, 18, 0, 5, 18.0, 1.05, 0, 0, false, 0];
GT2_10x20_plain_idler=["GT2_10x20_plain_idler", "GT2", 0, 12.0, GT2x10, 10.9, 18, 0, 5, 18.0, 1.05, 0, 0, false, 0];
GT2_10x20ob_pulley=["GT2_10x20ob_pulley", "GT2OB", 20, 12.22, GT2x10, 10.9, 16, 7.0, 5, 16.0, 1.5, 6, 3.25, M3_grub_screw, 2];
// NEMA 17 23mm (pancake)
NEMA17S23 = ["NEMA17S", 42.3, 23, 53.6/2, 25, 11, 2, 5, 24, 31, [8, 8]];
// V-SLOT
V2020  = [ "V2020", 20, 20,  4.2, 3, 7.8, 6.25, 11.0, 1.8, 1.5, 1 ];
V2040  = [ "V2040", 20, 40,  4.2, 3, 7.8, 6.25, 11.0, 1.8, 1.5, 1 ];
vtr=9.16; // v-slot top tiangle width
// Large rocker
large_rocker   = ["large_rocker", "Some large rocker found in drawer", 22, 28, 25, 30.5, 2.10, 21.3, 26, 15.8, 3,  -1, 2.5, small_spades];
// v-slot wheel: [ 0:name, 1:outer dia, 2:hole dia, 3:bearing outer dia, 4:width, 5:roll dia, 6:flat width, 7: edge dia, 8: spacer dia ]
VWHEEL_L = [ "V-wheel large", 24.32, 5, 16, 11.1, 20.50, 5.1, 19.40, 8.5 ];
VWHEEL_S = [ "V-wheel small", 15.25, 5, 11, 8.90, 12.10, 6.1, 12.50, 7.0 ];
VWHEEL = VWHEEL_L;

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
module joiner_hole(jl,screw_l=joiner_screw_len){
  union(){
    // hole for thread
    rotate([0,0,0]) cylinder(h=screw_l,d=joiner_screw_d+2*printer_off);
    // hole for head
    rotate([180,0,0]) cylinder(h=jl,d=joiner_screw_washer);
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
  
  echo("J2x2");
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
module pulley_support_front(){
  // pulley support
  m5_screw1=80;
  translate([ext/2,ext/2,m5_screw1-5]) screw(M5_cap_screw,m5_screw1);
  // screws for linear rail
  m3_screw1=16;
  translate([ext/2,ext*3,m3_screw1-5]) screw(M3_cap_screw,m3_screw1);
  translate([ext/2,ext*1.5,m3_screw1-5]) screw(M3_cap_screw,m3_screw1);
  // front screws
  m5_screw2=80;
  translate([ext*1.5,ext/2,m5_screw2-5]) screw(M5_cap_screw,m5_screw2);
  m5_screw3=16;
  translate([ext*4,ext/2,m5_screw3-5]) screw(M5_cap_screw,m5_screw3);
  // block body
  union(){
    cube([5*ext,ext,4*ext]);
    cube([ext,4*ext,2*ext]);
  }
}
module motor_support_x(mot,inn,out){
  // pulley support
  m5_screw1=70;
  translate([out.x,out.y,base_h+m5_screw1-5]) screw(M5_cap_screw,m5_screw1);
  m5_screw2=40;
  translate([inn.x,inn.y,inn.z+17]) screw(M5_cap_screw,m5_screw2);
  m5_screw3=40;
  translate([ext/2,base_d-ext/2,base_h+m5_screw3-5]) screw(M5_cap_screw,m5_screw3);
  m5_screw4=50;
  translate([1.5*ext,base_d-ext/2,base_h+m5_screw4-5]) screw(M5_cap_screw,m5_screw4);
  m5_screw5=50;
  translate([4*ext,base_d-ext/2,base_h+m5_screw5-5]) screw(M5_cap_screw,m5_screw5);
}
module motor_support_y(mot,inn,out){
  // pulley support
  m5_screw1=80;
  translate([out.x,out.y,base_h+m5_screw1-5]) screw(M5_cap_screw,m5_screw1);
  m5_screw2=40;
  translate([inn.x,inn.y,inn.z+17]) screw(M5_cap_screw,m5_screw2);
  m5_screw3=50;
  translate([base_w-ext/2,base_d-ext/2,base_h+m5_screw3-5]) screw(M5_cap_screw,m5_screw3);
  m5_screw4=60;
  translate([base_w-1.5*ext,base_d-ext/2,base_h+m5_screw4-5]) screw(M5_cap_screw,m5_screw4);
  m5_screw5=60;
  translate([base_w-4*ext,base_d-ext/2,base_h+m5_screw5-5]) screw(M5_cap_screw,m5_screw5);
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
      translate([ext/2,ext/2,msl-joiner_extr_depth]) rotate([180,0,0]) joiner_hole(20,msl);
      translate([ext/2,ext/2+44,msl-joiner_extr_depth]) rotate([180,0,0]) joiner_hole(20,msl);
      translate([ext/2+44,ext/2+44,msl-joiner_extr_depth]) rotate([180,0,0]) joiner_hole(20,msl);
    }
    // hack for using bridge instead of supports in printing
    if (bridge_support && !$preview){
      translate([ext/2,ext/2,msl-joiner_extr_depth-0.2]) cylinder(h=mot_bot+3-msl+joiner_extr_depth+0.2,d=5+2*printer_off+0.2);
      translate([ext/2,ext/2+44,msl-joiner_extr_depth-0.2]) cylinder(h=mot_bot+3-msl+joiner_extr_depth+0.2,d=5+2*printer_off+0.2);
      translate([ext/2+44,ext/2+44,msl-joiner_extr_depth-0.2]) cylinder(h=mot_bot+3-msl+joiner_extr_depth+0.2,d=5+2*printer_off+0.2);
    }
  }
}
module gantry_joint_l(pulx, puly){
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
    translate([ext/2,carriage_length(MGN12H_carriage),ext/2+3]) rotate([-90,0,0]) screw(M5_cap_screw,m5_screw3);
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
  translate([-(carriage_width(MGN12H_carriage)-ext)/2,0,0]) {
    //#cube([carriage_width(MGN12H_carriage),carriage_length(MGN12H_carriage),40]);
    // lower part
    difference(){
      hull(){
        translate([rd,rd,0]) cylinder(h=box_h,r=rd);
        translate([rd,carriage_length(MGN12H_carriage)-rd,0]) cylinder(h=box_h,r=rd);
        translate([carriage_width(MGN12H_carriage)-rd,carriage_length(MGN12H_carriage)-rd,0]) cylinder(h=box_h,r=rd);
        translate([carriage_width(MGN12H_carriage)-rd+2,25,0]) cylinder(h=box_h,r=rd);
        translate([carriage_width(MGN12H_carriage)-1+2,0,0]) cube([1,1,box_h]);
      }
    }
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
    translate([ext/2,carriage_length(MGN12H_carriage),10]) rotate([-90,0,0]) screw(M5_cap_screw,m5_screw3);
    m3_screw1=12;
    translate([0,13,m3_screw1-8]) screw(M3_cap_screw,m3_screw1);
    translate([0,33,m3_screw1-8]) screw(M3_cap_screw,m3_screw1);
    m3_screw2=35;
    translate([ext,13,m3_screw2-8]) screw(M3_cap_screw,m3_screw2);
    translate([ext,33,m3_screw2-8]) screw(M3_cap_screw,m3_screw2);
  }

  translate([-(carriage_width(MGN12H_carriage)-ext)/2,0,0]) cube([carriage_width(MGN12H_carriage),carriage_length(MGN12H_carriage),40]);
}
module gantry(){
  // Y carriage positions
  echo("Side rails lenght",y_rail_l);
  echo("Maximum rails length",base_d-2*ext);
  real_y=pos_y+hotend_d;
  carriage_pos_y=real_y-carriage_travel(MGN12H_carriage,y_rail_l)/2-y_rails_from_front;
  carriage_y_real=real_y+ext+carriage_length(MGN12H_carriage)/2;
  carriage_pos_x=pos_x-build_x/2;
  motor_y=base_d+21;


  // left linear rail
  translate([ext/2,y_rail_l/2+ext+y_rails_from_front,base_h]) rotate([0,0,90]) rail_assembly(MGN12H_carriage,y_rail_l,carriage_pos_y);
  // right linear rail
  translate([base_w-ext/2,y_rail_l/2+ext+y_rails_from_front,base_h]) rotate([0,0,90]) rail_assembly(MGN12H_carriage,y_rail_l,carriage_pos_y);

  // pulleys
  belt_shift_y=6;
  // X axis
  shift_x=34+4;
  // X start anchor point
  bx1=[base_w/2-build_x/2+pos_x,carriage_y_real+belt_shift_y+pr20,base_h+shift_x];
  translate(bx1) cube([0.1,12,12]);
  // X idler - gantry left
  bx2=[ext/2+belt_separation,carriage_y_real+belt_shift_y+2*pr20,base_h+shift_x];
  translate(bx2) pulley(GT2_10x20_plain_idler);
  // X idler - inner rail-motor
  bx3=[ext/2+belt_separation,motor_y,base_h+shift_x];
  translate(bx3) pulley(GT2_10x20_plain_idler);
  // X motor
  bx4=[21+2*ext,motor_y,base_h+shift_x-4];
  translate(bx4) NEMA(NEMA17M);
  translate([bx4.x,bx4.y,bx4.z+24.5]) rotate([0,180,0]) pulley(GT2_10x20ob_pulley);
  // X idler - outer rail-motor
  bx5=[ext/2,motor_y+ext,base_h+shift_x];
  translate(bx5) pulley(GT2_10x20_toothed_idler);
  // X idler - front left
  bx6=[ext/2,ext/2,base_h+shift_x];
  translate(bx6) pulley(GT2_10x20_toothed_idler);
  // X idler - front right
  bx7=[base_w-ext/2,ext/2,base_h+shift_x];
  translate(bx7) pulley(GT2_10x20_toothed_idler);
  // X idler - gantry right
  bx8=[base_w-ext/2,carriage_y_real+belt_shift_y,base_h+shift_x];
  translate(bx8) pulley(GT2_10x20_toothed_idler);
  
  // X belt
  belt_x_path=[[bx8.x,bx8.y,pr20], [bx7.x,bx7.y,pr20], [bx6.x,bx6.y,pr20], [bx5.x,bx5.y,pr20], [bx4.x,bx4.y,pr20], [bx3.x,bx3.y,-pr20], [bx2.x,bx2.y,-pr20],[bx1.x,bx1.y,0]];
  translate([0,0,base_h+shift_x+6.5]) belt(GT2x10,belt_x_path);
  echo("X belt length",belt_length(belt_x_path));

  // Y axis
  shift_y=shift_x+15;
  // Y start anchor point
  by1=[base_w/2-build_x/2+pos_x,carriage_y_real+belt_shift_y+pr20,base_h+shift_y];
  translate(by1) cube([0.1,12,12]);
  // Y idler - gantry right
  by2=[base_w-ext/2-belt_separation,carriage_y_real+belt_shift_y+2*pr20,base_h+shift_y];
  translate(by2) pulley(GT2_10x20_plain_idler);
  // Y idler - inner rail-motor
  by3=[base_w-ext/2-belt_separation,motor_y,base_h+shift_y];
  translate(by3) pulley(GT2_10x20_plain_idler);
  // Y motor
  pulley_motor_space=3.5;
  by4=[base_w-21-2*ext,motor_y,base_h+shift_y-9-pulley_motor_space];
  translate(by4) NEMA(NEMA17M);
  translate([by4.x,by4.y,by4.z+1.5+pulley_motor_space]) pulley(GT2_10x20ob_pulley);
  // Y idler - outer rail-motor
  by5=[base_w-ext/2,motor_y+ext,base_h+shift_y];
  translate(by5) pulley(GT2_10x20_toothed_idler);
  // Y idler - front right
  by6=[base_w-ext/2,ext/2,base_h+shift_y];
  translate(by6) pulley(GT2_10x20_toothed_idler);
  // Y idler - front left
  by7=[ext/2,ext/2,base_h+shift_y];
  translate(by7) pulley(GT2_10x20_toothed_idler);
  // Y idler - gantry left
  by8=[ext/2,carriage_y_real+belt_shift_y,base_h+shift_y];
  translate(by8) pulley(GT2_10x20_toothed_idler);

  // Y belt
  belt_y_path=[[by1.x,by1.y,0], [by2.x,by2.y,-pr20], [by3.x,by3.y,-pr20], [by4.x,by4.y,pr20], [by5.x,by5.y,pr20], [by6.x,by6.y,pr20], [by7.x,by7.y,pr20], [by8.x,by8.y,pr20]];
  translate([0,0,base_h+shift_y+6.5]) belt(GT2x10,belt_y_path);
  echo("Y belt length",belt_length(belt_y_path));
  
  // X gantry support
  g_shift_y=carriage_y_real-ext-3;
  g_shift_z=base_h+carriage_height(MGN12H_carriage);
  translate([0,g_shift_y,g_shift_z]) union(){
    echo(base_w=base_w);
    translate([ext/4,5,3.5]) rotate([0,90,0]) ext2020(base_w-ext/2);
    echo("X rail length",base_w-2*ext);
    translate([base_w/2,ext*0.5+5,ext+3.5]) rotate([0,0,0]) rail_assembly(MGN12H_carriage,base_w-2*ext,carriage_pos_x);
    // gantry joints
    translate([0,0,0]) {
      #gantry_joint_l([bx2.x,bx2.y-g_shift_y,bx2.z-g_shift_z],[by8.x,by8.y-g_shift_y,by8.z-g_shift_z]);
      #translate([base_w-ext,0,0]) gantry_joint_r([bx8.x-(base_w-ext),bx8.y-g_shift_y,bx8.z-g_shift_z],[by2.x-(base_w-ext),by2.y-g_shift_y,by2.z-g_shift_z]);
    }
    // Extruder and mount
    translate([base_w/2-build_x/2+pos_x,-18,10]) extruder();
  }

  // front pulley support
  #translate([0,0,base_h]) pulley_support_front();
  #translate([base_w,0,base_h]) mirror([1,0,0]) pulley_support_front();
  
  // X motor support
  #motor_support_x(bx4,bx3,bx5);
  // Y motor support
  #motor_support_y(by4,by3,by5);

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

module bed_to_t8(dist){
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
  translate([0,4*ext,-ext]) bed_to_t8(1.5*ext);
  translate([base_w,4*ext,-ext]) mirror([1,0,0]) bed_to_t8(1.5*ext);
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
  echo("Z belt length",belt_length(belt_points));

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
}

if ($preview) {
  $fn=20;
  draw_whole_printer();
} else {
  $fn=90;
  draw_printable_parts();
}

/* Very Narrow CoreXY Printer (vn-corexy)
   Created with goal: use as small space in width dimension as possible.
   (C) 2020 Marek Wodzinski <majek@w7i.pl> https://majek.sh
   
   vn-corexy is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
   You should have received a copy of the license along with this work.
   If not, see <http://creativecommons.org/licenses/by-sa/4.0/>
*/

/* [print position] */
pos_x=0;
pos_y=100;
pos_z=320;
/* [build plate] */
build_plate_w=310; // (X)
build_plate_d=310; // (Y)
build_plate_mount_space=240; // space between mounting screws
/* [build volume] */
build_x=300;
build_y=300;
build_z=320;
/* [hotend size] */
hotend_w=50;
hotend_d=70;
hotend_nozzle=60; //distance from gantry to nozzle
/* [extrusions family size] */
ext=20;
/* [extrusion type] */
ext_type=1; // [0:T-SLOT, 1:V-SLOT]
/* [minumum margin between build plate and frame] */
x_margin=10;
/* [printed corners] */
printed_corners=true; // [false:no, true:yes]
printed_corners_nut=2; // [0:printed nut, 1:rotating t-nut, 2:sliding t-nut]

/* [render printable parts] */
render_parts=0; // [0:All, 1:T-nut M5, 2: Joiner 1x1, 3: Joiner 2x2]

// internal stuff starts here
/* [Hidden] */
include <NopSCADlib/lib.scad>

// calculated
base_w=2*ext+max(build_x+hotend_w,build_plate_w+x_margin); //width
base_h=ext*2+400+5; //height
base_d=build_plate_d+hotend_d+2*ext+50; //depth
top_d=base_d+50; //top left/right profiles length
rail_l=base_d-2*ext; //MGN rails length
z_pulley_support=170; //distance from front to Z pulley support
z_belt_space=26;
pr20=pulley_pr(GT2x20ob_pulley); //radius of puller for belt calculations
//belt_separation=pulley_od(GT2_10x20_toothed_idler);
belt_separation=6;
elec_support=120; //distance for electronic supports from edge of frame
// extrusion joiner
joiner_screw_len=12; // M5x12
joiner_screw_d=5;
joiner_screw_head_d=8.5;
joiner_screw_washer=10;
joiner_screw_head_h=5;
joiner_extr_depth=6;
joiner_in_material=joiner_screw_len-joiner_extr_depth;
joiner_space=joiner_screw_len-joiner_extr_depth+joiner_screw_head_h+joiner_screw_head_d/2; // minimum space from corner to allow put two screws

// Extra stuff not in NopSCADlib
// 688RS ball bearings (8x16x5)
BB688=["688", 8, 16, 5, "black", 1.4, 2.0];
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
vtr=9.16; // v-slot tiangle width


module vtriangle(){
    polygon([[-vtr/2,0],[vtr/2,0],[0,vtr/2]]);
}

module vslot_groove(length, depth=1.5){
  scale([0.98,1,1]) linear_extrude(length) intersection(){
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
    
    scale([1.03,1.03,1]) translate([0,0,0.7]) nut(M5_nut);
    translate([0,0,-1]) cylinder(h=5,d=5.2);
    
  }
}
module joiner_hole(jl){
  union(){
    rotate([0,0,0]) cylinder(h=joiner_screw_len,d=joiner_screw_d);
    rotate([180,0,0]) cylinder(h=jl,d=joiner_screw_washer);
    // cut tongue for rotating t-nut
    if (printed_corners_nut==1)
      translate([0,0,joiner_in_material+1]) cylinder(d=8, h=2, center=true);
    // cut tongue for long sliding t-nut
    if (printed_corners_nut==2)
      translate([0,0,joiner_in_material+1]) cube([7,12,2], center=true); // 12 - slide length
  }
}
module joiner1x1(){
  j1x1_len=20;
  color(grey(30)) difference(){
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
  color(grey(30)) difference(){
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
module leadnut_cut(){
  intersection(){
    leadnut(LSN8x2);
    translate([-6,-15,-20]) cube([12,30,30]);
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
  translate([ext,z_pulley_support-0.5*ext,0]) rotate([0,0,-90]) joiner1x1();
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
}
module frame(){
  length_a=base_w-2*ext;
  echo(length_a=length_a);
  // front bottom (profile A)
  translate([ext,ext,0]) rotate([0,90,0]) rotate([0,0,90]) ext2040(length_a);
  // rear bottom (profile A)
  translate([ext,base_d-2*ext,0]) rotate([0,90,0]) ext2040(length_a);
  // rear top (profile A)
  translate([ext,base_d-ext,base_h-ext]) rotate([0,90,0]) ext2040(length_a);
  // front top (profile A)
  translate([ext,0,base_h]) rotate([0,90,0]) rotate([0,0,-90]) ext2040(length_a);
  // Z pulley support (profile A)
  translate([ext,z_pulley_support-ext/2,0]) rotate([0,90,0]) ext2020(length_a);

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
  bmg_points=[[0,0],[42,0],[42,53],[19,53],[0,38]];
  translate([-21,-17,-21]) rotate([90,0,0]) color([0.1,0.1,0.1]) linear_extrude(height=34, center=true) polygon(bmg_points);
  bmg_side_points=[[0,0],[20,0],[20,26],[16,54],[4,54],[0,26]];
  translate([20,-29,-3]) rotate([95,0,90]) color([0.1,0.1,0.1]) linear_extrude(height=5, center=true) polygon(bmg_side_points);
}
module extruder(){
  translate([0,-36,-4]) rotate([0,0,90]) hot_end(E3Dv6, 1.75, bowden = false,resistor_wire_rotate = [0,0,0], naked = false);
  translate([-6,-12,8]) {
    rotate([90,0,0])NEMA(NEMA17S23);
    translate([0,-1,0])bmg_extruder();
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
module gantry_joint_l(){
  // pulley support //TODO
  m5_screw1=40;
  translate([ext/2,6+ext,m5_screw1-5+7+ext]) screw(M5_cap_screw,m5_screw1);
  m5_screw2=40;
  translate([ext/2+belt_separation,18.5+ext,m5_screw2+3]) screw(M5_cap_screw,m5_screw2);
  m5_screw3=16;
  translate([ext/2,carriage_length(MGN12H_carriage),17]) rotate([-90,0,0]) screw(M5_cap_screw,m5_screw3);
  m3_screw1=12;
  translate([ext,13,m3_screw1-8]) screw(M3_cap_screw,m3_screw1);
  translate([ext,33,m3_screw1-8]) screw(M3_cap_screw,m3_screw1);
  m3_screw2=35;
  translate([0,13,m3_screw2-8]) screw(M3_cap_screw,m3_screw2);
  translate([0,33,m3_screw2-8]) screw(M3_cap_screw,m3_screw2);
  // box
  translate([-(carriage_width(MGN12H_carriage)-ext)/2,0,0]) cube([carriage_width(MGN12H_carriage),carriage_length(MGN12H_carriage),40]);

}
module gantry_joint_r(){
  // pulley support //TODO
  m5_screw1=40;
  translate([ext/2,6+ext,m5_screw1-5+7+ext]) screw(M5_cap_screw,m5_screw1);
  m5_screw2=40;
  translate([ext/2-belt_separation,18.5+ext,m5_screw2+3+20]) screw(M5_cap_screw,m5_screw2);
  m5_screw3=16;
  translate([ext/2,carriage_length(MGN12H_carriage),17]) rotate([-90,0,0]) screw(M5_cap_screw,m5_screw3);
  m3_screw1=12;
  translate([0,13,m3_screw1-8]) screw(M3_cap_screw,m3_screw1);
  translate([0,33,m3_screw1-8]) screw(M3_cap_screw,m3_screw1);
  m3_screw2=35;
  translate([ext,13,m3_screw2-8]) screw(M3_cap_screw,m3_screw2);
  translate([ext,33,m3_screw2-8]) screw(M3_cap_screw,m3_screw2);

  translate([-(carriage_width(MGN12H_carriage)-ext)/2,0,0]) cube([carriage_width(MGN12H_carriage),carriage_length(MGN12H_carriage),40]);
}
module gantry(){
  // Y carriage positions
  echo("Rail lenght",rail_l);
  real_y=pos_y+hotend_d;
  carriage_pos_y=real_y-rail_travel(MGN12H,rail_l)/2;
  carriage_y_real=real_y+ext+carriage_length(MGN12H_carriage)/2;
  carriage_pos_x=pos_x-build_x/2;
  motor_y=base_d+21;


  // left linear rail
  translate([ext/2,rail_l/2+ext,base_h]) rotate([0,0,90]) rail_assembly(MGN12H,rail_l,carriage_pos_y);
  // right linear rail
  translate([base_w-ext/2,rail_l/2+ext,base_h]) rotate([0,0,90]) rail_assembly(MGN12H,rail_l,carriage_pos_y);

  // X gantry support
  translate([0,carriage_y_real-ext/2+3,base_h+13+7]) union(){
    echo(base_w=base_w);
    translate([ext/4,0,0]) rotate([0,90,0]) ext2020(base_w-ext/2);
    translate([base_w/2,0,ext/2]) rotate([90,0,0]) rail_assembly(MGN12H,base_w-ext,carriage_pos_x);
    // gantry joints
    translate([0,ext/2-3-carriage_length(MGN12H_carriage)/2,-7]) {
      #gantry_joint_l();
      #translate([base_w-ext,0,0]) gantry_joint_r();
    }
    
  }
  
  // Extruder and mount
  translate([base_w/2-build_x/2+pos_x,real_y+10,base_h+30]) extruder();
  
  // pulleys
  // X axis
  shift_x=43;
  // X start anchor point
  bx1=[base_w/2-build_x/2+pos_x,carriage_y_real+3+pr20,base_h+shift_x];
  translate(bx1) cube([0.1,12,12]);
  // X idler - gantry left
  bx2=[ext/2+belt_separation,carriage_y_real+3+2*pr20,base_h+shift_x];
  translate(bx2) pulley(GT2_10x20_plain_idler);
  // X idler - inner rail-motor
  bx3=[ext/2+belt_separation,motor_y,base_h+shift_x];
  translate(bx3) pulley(GT2_10x20_plain_idler);
  // X motor
  bx4=[21+2*ext,motor_y,base_h+shift_x-3];
  translate(bx4) NEMA(NEMA17M);
  translate([bx4.x,bx4.y,bx4.z+24]) rotate([0,180,0]) pulley(GT2_10x20ob_pulley);
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
  bx8=[base_w-ext/2,carriage_y_real+3,base_h+shift_x];
  translate(bx8) pulley(GT2_10x20_toothed_idler);
  
  // X belt
  belt_x_path=[[bx8.x,bx8.y,pr20], [bx7.x,bx7.y,pr20], [bx6.x,bx6.y,pr20], [bx5.x,bx5.y,pr20], [bx4.x,bx4.y,pr20], [bx3.x,bx3.y,-pr20], [bx2.x,bx2.y,-pr20],[bx1.x,bx1.y,0]];
  translate([0,0,base_h+shift_x+7]) belt(GT2x10,belt_x_path);
  echo("X belt length",belt_length(belt_x_path));

  // Y axis
  shift_y=43+15;
  // Y start anchor point
  by1=[base_w/2-build_x/2+pos_x,carriage_y_real+3+pr20,base_h+shift_y];
  translate(by1) cube([0.1,12,12]);
  // Y idler - gantry right
  by2=[base_w-ext/2-belt_separation,carriage_y_real+3+2*pr20,base_h+shift_y];
  translate(by2) pulley(GT2_10x20_plain_idler);
  // Y idler - inner rail-motor
  by3=[base_w-ext/2-belt_separation,motor_y,base_h+shift_y];
  translate(by3) pulley(GT2_10x20_plain_idler);
  // Y motor
  pulley_motor_space=3.5;
  by4=[base_w-21-2*ext,motor_y,base_h+shift_y-9-pulley_motor_space];
  translate(by4) NEMA(NEMA17M);
  translate([by4.x,by4.y,by4.z+2+pulley_motor_space]) pulley(GT2_10x20ob_pulley);
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
  by8=[ext/2,carriage_y_real+3,base_h+shift_y];
  translate(by8) pulley(GT2_10x20_plain_idler);

  // Y belt
  belt_y_path=[[by1.x,by1.y,0], [by2.x,by2.y,-pr20], [by3.x,by3.y,-pr20], [by4.x,by4.y,pr20], [by5.x,by5.y,pr20], [by6.x,by6.y,pr20], [by7.x,by7.y,pr20], [by8.x,by8.y,pr20]];
  translate([0,0,base_h+shift_y+7]) belt(GT2x10,belt_y_path);
  echo("Y belt length",belt_length(belt_y_path));
  
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
  plate_screw_l=20;
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
  translate([d1,d1,plate_h]) screw(M4_cs_cap_screw,plate_screw_l);
  translate([d1,d2,plate_h]) screw(M4_cs_cap_screw,plate_screw_l);
  translate([d2,d1,plate_h]) screw(M4_cs_cap_screw,plate_screw_l);
  translate([d2,d2,plate_h]) screw(M4_cs_cap_screw,plate_screw_l);
  // cork isolation
  translate([0,0,-7]) color([0.6,0.43,0.24]) cube([build_plate_w,build_plate_d,7]);
}
module z_rod(){
  union(){
    // lower ball bearing
    translate([0,0,2.5]) ball_bearing(BB688);
    translate([0,0,5.5+15]) rotate([0,180,0]) pulley(GT2x20ob_pulley);
    // screw
    translate([0,0,base_h/2-ext]) leadscrew(8, base_h-2*ext, 8, 4);
    echo("Leadscrew length",base_h-2*ext);
    // upper ball bearing
    translate([0,0,2.5+base_h-2*ext-5]) ball_bearing(["608", 8, 16, 5, "silver", 1.4, 2.0]);
  }
}
module pulley_support_z(){
  // pulley support
  m5_screw1=20;
  translate([0,0,m5_screw1-5]) screw(M5_cap_screw,m5_screw1);
  m5_screw2=12;
  translate([ext,0,m5_screw2-5]) screw(M5_cap_screw,m5_screw2);
  translate([-ext/2,-ext/2,0]) union(){
    cube([2*ext,ext,z_belt_space-ext]);
  }
}
module z_axis(){
  // rods and pulleys
  // left rod
  p1=[ext/2, 4*ext, ext];
  translate(p1) z_rod();
  // right rod
  p2=[base_w-ext/2, 4*ext, ext];
  translate(p2) z_rod();
  // back rod
  p3=[base_w/2, base_d-ext/2, ext];
  translate(p3) z_rod();
  
  // Z motor
  p4=[22, z_pulley_support-22-ext/2, z_belt_space+12];
  translate(p4) rotate([0,180,0]) union(){
    NEMA(NEMA17M);
    translate([0,0,18]) rotate([0,180,0]) pulley(GT2x20ob_pulley);
  }
  // tension pulley
  p5=[ext/2+75,z_pulley_support,z_belt_space];
  translate(p5) pulley(GT2x20_plain_idler);
  translate([p5.x,p5.y,ext]) pulley_support_z();

  // second tension pulley
  p6=[ext/2+200,z_pulley_support,z_belt_space];
  translate(p6) pulley(GT2x20_plain_idler);
  translate([p6.x,p6.y,ext]) pulley_support_z();
  
  // belt
  belt_points=[[p5.x,p5.y,-pr20],[p4.x,p4.y,pr20],[p3.x,p3.y,pr20],[p6.x,p6.y,-pr20],[p2.x,p2.y,pr20],[p1.x,p1.y,pr20]];
  translate([0,0,z_belt_space+4]) belt(GT2x6,belt_points);
  echo("Z belt length",belt_length(belt_points));


  //moving part
  translate([0,0,base_h-2*ext-10-pos_z]) union(){
    // build plate
    translate([(base_w-build_plate_w)/2,hotend_d-hotend_nozzle+ext+10,12]) build_plate();
    
    // plate support
    // left
    translate([ext/2+(base_w-build_plate_mount_space)/2,3*ext,0]) rotate([-90,0,0]) ext2020(base_d-5.5*ext);
    // right
    translate([ext/2+(base_w-build_plate_mount_space)/2+build_plate_mount_space,3*ext,0]) rotate([-90,0,0]) ext2020(base_d-5.5*ext);
    // front
    translate([1.5*ext,2*ext,-ext]) rotate([0,90,0]) ext2020(base_w-3*ext);
    // back
    translate([1.5*ext,base_d-2.5*ext,-ext]) rotate([0,90,0]) ext2020(base_w-3*ext);
    // additional bed support
    translate([base_w/2-build_plate_mount_space/2+ext/2,build_plate_mount_space/4+4*ext,-ext]) rotate([0,90,0]) ext2020(build_plate_mount_space-ext);
    translate([base_w/2-build_plate_mount_space/2+ext/2,build_plate_mount_space*3/4+4*ext,-ext]) rotate([0,90,0]) ext2020(build_plate_mount_space-ext);
    

    // Z drive nuts
    translate([p1.x,p1.y,0]) leadnut_cut();
    translate([p2.x,p2.y,0]) leadnut_cut();
    translate([p3.x,p3.y,0]) rotate([0,0,90]) leadnut_cut();
  }
  
}
module electronics(){
  translate([psu_width(S_300_12)/2,base_d,-psu_length(S_300_12)/2+base_h-3*ext]) rotate([0,-90,-90]) psu(S_300_12);
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
}


if ($preview) {
  $fn=30;
  draw_whole_printer();
} else {
  $fn=90;
  draw_printable_parts();
}

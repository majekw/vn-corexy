/*
  HGX Lite 2.0 extruder OpenSCAD library

  Based on few drawings and real measures.
  (C) 2023 Marek Wodzinski <majek@w7i.pl>

  This library is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
  You should have received a copy of the license along with this work.
  If not, see <http://creativecommons.org/licenses/by-sa/4.0/

  Library are files:
  - HGX-Lite-2.scad (this file)
  - hgx-back.svg (svg files are traced on extruder pictures)
  - hgx-front.svg
  - hgx-lever.svg

  Some basic dimensions:
  - base dimensions: 40.0mm x 20.4mm (16 front+3.6 back+0.8 spacer)
  - filament hole from: front: 7.9mm, right: 20.55mm
  - holes for screws: 3.2mm, head 5.5mm
  - distance from front to motor plate: 20.4mm
  - motor center at filament path, height: 19.60mm
*/

function HGX_holes_bottom() = [ [-11.5,-4,0], // left front
                               [-11.5,5,0], // left rear
                               [17.5,0,0] ]; // right
function HGX_holes_right() = [ [20.55,4.9,3.0], // front (3.2 measured)
                               [20.55,-5.1,3.0] ]; //back
function HGX_holes_front() = [ [-15.65,-7.9,4.1], // left down (motor1)
                               [12.0,-7.9,4.1], // right down (lever)
                               [-9.45,-7.9,16.50], // left filament gear
                               [-8.45,-7.9,30], // reduction gear
                               [5.95,-7.9,37.6], // top screw
                               [15.6,7.9,35] ]; // rear motor2
function HGX_motor_position() = [[0,12.5,19.60],[90,-45.5,0]]; // motor position and rotation
function HGX_tension_screw_position() = [28.4,3.1,31.75];
function HGX_dimensions() = [ -19.45, // left from center
                              20.55, // right from center
                              -7.9, // front
                              12.5 ]; // back

module HGX_lite2_front(){
  difference(){
    translate([-0.3-40+20.55,8.1,0]) rotate([90,0,0]) linear_extrude(16, convexity = 4) import("hgx-front.svg");
    // HOLES

    // filament hole
    //cylinder(h=HGX_w(),d=2); // main hole
    //cylinder(h=6,d=9.6); // M10 hole
    //translate([0,0,HGX_w()-3]) cylinder(h=3,d=4.2); // PTFE hole
    // bottom mount holes
    for ( i=[0:2]) {
      translate(HGX_holes_bottom()[i]) cylinder(h=4,d=3.2);
    }
    // right mount holes
    for ( i=[0:1]) {
      translate(HGX_holes_right()[i]) rotate([0,-90,0]) cylinder(h=5,d=3.2);
    }
    // front mount holes
    for ( i=[0:5]) {
      #translate(HGX_holes_front()[i]) rotate([-90,0,0]) {
        cylinder(h=23,d=3.2);
        //cylinder(h=1.5,d=5.5);
      }
    }
  }
}
module HGX_lite2_back(){
  difference(){
    union(){
      // main shape
      translate([0.15+20.55,8.1,0]) rotate([90,0,180]) linear_extrude(3.6, convexity = 4) import("hgx-back.svg");
      // mount distances
      for ( i=[0,5] ){
        translate([HGX_holes_front()[i].x,12.5,HGX_holes_front()[i].z]) rotate([90,0,0]) cylinder(d=5.5,h=0.8);
      }
    }

    // rear motor hole
    //translate([13.9,22.5-8.5,37.55]) rotate([90,0,0]) cylinder(h=4,d=3.2);
  }
}

module HGX_lite2_filament_gear(){
  difference(){
    union(){
      // plastic gear
      color("#202020") cylinder(d=19.5,h=3);
      // metal gear
      translate([0,0,3]) color("silver") cylinder(d=18,h=4);
      // bearings
      color("silver") cylinder(d=18,h=7);
    }
    // hole
    translate([0,0,-0.01]) cylinder(d=3,h=7.02);
  }
}

module HGX_lite2(){
  union(){
    // body
    color("#604040") HGX_lite2_front();
    // back plate
    color("#604045") HGX_lite2_back();

    // lever
    color("#404040") translate([5.3,8.1,1]) rotate([90,0,0]) linear_extrude(13, convexity = 2) import("hgx-lever.svg");
    // tension screw
    translate(HGX_tension_screw_position()) rotate([0,-90,0]) {
      color("#C00000") cylinder(h=4,d=12); // dial
      color("#808080") cylinder(h=16.5,d=6); // spring
      color("#a0a0a0") cylinder(h=25,d=2.85); // screw
    }
    // filament gears
    translate([HGX_holes_front()[2].x,4.65,HGX_holes_front()[2].z]) rotate([90,0,0]) HGX_lite2_filament_gear();
    translate([HGX_holes_front()[2].x+18.7,4.65,HGX_holes_front()[2].z]) rotate([90,0,0]) HGX_lite2_filament_gear();
    // reduction gear
    translate([HGX_holes_front()[3].x,8,HGX_holes_front()[3].z]) rotate([90,0,0]) {
      translate([0,0,3]) color("silver") cylinder(d=9.6,h=4.2);
      color("#202020") cylinder(d=23,h=3);
    }
  }
}

HGX_lite2();

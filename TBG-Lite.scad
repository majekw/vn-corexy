/*
  TBG-Lite extruder OpenSCAD library
  
  Based on datasheet and measures of TBG-Lite_mockup.STEP
  (C) 2022 Marek Wodzinski <majek@w7i.pl>
  
  This library is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
  You should have received a copy of the license along with this work.
  If not, see <http://creativecommons.org/licenses/by-sa/4.0/
  
  Some basic dimensions:
  - holes for screws: 3.2mm, head 5.5mm
  - corners: 2.5mm from edge
  - distance from front to motor plate: 21mm
  - motor center: [19.9,21.1]
  - base dimensions: 43.50mm x 22.5mm
  - filement hole from front: 8.5mm
  - back plate thickness: 4mm
*/

function TBG_w() = 43.50;
function TBG_holes_bottom() = [[-10.45,2,0], [8.05,4.50,0], [8.05,-4.50,0]];
function TBG_holes_left() = [[-TBG_w()/2,5.25,TBG_w()/2-10.95], [-TBG_w()/2,-2.30,TBG_w()/2+11.42]];
function TBG_holes_front() = [[-TBG_w()/2+5.00,-8.50,5.00], [15.50,-8.50,5.85], [-TBG_w()/2+3.50,-8.50,TBG_w()-3.50]];
function TBG_body() = [[-TBG_w()/2+2.5,0], [TBG_w()/2-2.5,0], [TBG_w()/2,2.5], [TBG_w()/2,10], [TBG_w()/2-8.15,18], [TBG_w()/2-8.15,TBG_w()-2.5], [TBG_w()/2-8.15-2.5,TBG_w()], [-TBG_w()/2+2.5,TBG_w()], [-TBG_w()/2,TBG_w()-2.5], [-TBG_w()/2,2.5]];
function TBG_backplate() = [[-TBG_w()/2+2.5,0], [TBG_w()/2-2.5,0], [TBG_w()/2,2.5], [TBG_w()/2,12], [TBG_w()/2-3,18], [TBG_w()/2-3,TBG_w()-2.5], [TBG_w()/2-3-2.5,TBG_w()], [-TBG_w()/2+2.5,TBG_w()], [-TBG_w()/2,TBG_w()-2.5], [-TBG_w()/2,2.5]];


module TBG_lite(){
  difference(){
    union(){
      // body
      color("#404040") rotate([90,0,0]) translate([0,0,-22.50+8.50]) linear_extrude(22.50) polygon(TBG_body());
      // back plate
      color("#404040") rotate([90,0,0]) translate([0,0,-22.50+8.50]) linear_extrude(4) polygon(TBG_backplate());
      // lever
      color("#404040") translate([-TBG_w()/2+36.65,-8.5+3,0]) cube([4.50,15,55.85]);
      // screw
      translate([53.65-TBG_w()/2,-8.5+3+15/2,39.85]) rotate([0,-90,0]) {
        color("#404040") cylinder(h=4,d=12); // dial
        color("#808080") cylinder(h=16,d=5); // spring
        color("#a0a0a0") cylinder(h=25,d=2.85); // screw
      }
    }

    // HOLES

    // filament hole
    cylinder(h=TBG_w(),d=2); // main hole
    cylinder(h=6,d=9.6); // M10 hole
    translate([0,0,TBG_w()-3]) cylinder(h=3,d=4.2); // PTFE hole
    // bottom mount holes
    for ( i=[0:2]) {
      translate(TBG_holes_bottom()[i]) cylinder(h=4,d=3.2);
    }
    // left mount holes
    for ( i=[0:1]) {
      translate(TBG_holes_left()[i]) rotate([0,90,0]) cylinder(h=5,d=3.2);
    }
    // front mount holes
    for ( i=[0:2]) {
      translate(TBG_holes_front()[i]) rotate([-90,0,0]) {
        cylinder(h=23,d=3.2);
        cylinder(h=1.5,d=5.5);
      }
    }
    // rear motor hole
    translate([13.9,22.5-8.5,37.55]) rotate([90,0,0]) cylinder(h=4,d=3.2);
  }
}

TBG_lite();

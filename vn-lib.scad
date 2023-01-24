/*
   Basic shapes library: vn-lib.scad
   (C) 2023 Marek Wodzinski <majek@w7i.pl> https://majek.sh

   This library is licensed under a Creative Commons
   Attribution-ShareAlike 4.0 International License.
   You should have received a copy of the license along with this work.
   If not, see <http://creativecommons.org/licenses/by-sa/4.0/>
*/

/* diamond
  dim - [x,y,z]
  dim.x - width of diamond
  dim.y - height of diamond
  dim.z - thickness of extruded diamond
*/
module diamond(dim){
  linear_extrude(dim.z) polygon([ [0,dim.y/2], [dim.x/2,0], [dim.x,dim.y/2], [dim.x/2,dim.y] ]);
}

/*
  extruded square triangle
  a - side size
  h - height/lenght of element
*/
module triangle(a,h){
  translate([0,0,-h/2]) linear_extrude(h) polygon([[0,0], [a,0], [0,a]]);
}

/* cube minus quarter of cylinder
  r - size of rectangle
  h - height/lenght of element
  eps - offset for difference to look nice in preview (default=0.01)
*/
module round_corner(r,h,eps=0.01){
  difference(){
    cube([r,r,h]);
    translate([r,r,-eps]) cylinder(r=r,h=h+2*eps);
  }
}

/* hull between 2 cylinders
  d - diameter of cylinders
  h - height of cylinders
  l - space between centers of cylinders
*/
module slot(d,h,l){
  hull(){
    cylinder(d=d,h=h);
    translate([l,0,0]) cylinder(d=d,h=h);
  }
}

/* 'extrude' along path
   parameters - [ step_definition, step_definition, ... ], eps
   step_definition - [ translation, rotation, shape ]
   translation - argument to translate()
   rotation - argument to rotate()
   shape - argument to polygon()
   eps - height of extrude of shape (default=0.01)
*/
module path_extrude(trs,eps=0.01){
  for (cc=[0:len(trs)-2]) {
    hull(){
      translate(trs[cc][0]) rotate(trs[cc][1]) linear_extrude(eps) polygon(trs[cc][2]);
      translate(trs[cc+1][0]) rotate(trs[cc+1][1]) linear_extrude(eps) polygon(trs[cc+1][2]);
    }
  }
}

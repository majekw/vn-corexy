# vn-corexy
Very Narrow CoreXY 3D Printer

![vn-corexy rendering](img/vn-corexy-animated-20230127.gif)

vn-corexy is designed around 300x300 mm build plate with goal to be
as compact as possible with focus on width. Current dimensions are
390(width)x520(depth)x520(height) mm. Only filament could stick above
maximum height, everything else (including cables) are within size limits.

In this repository there is OpenScad source code with 3D printer design.
There are many parameters that can be customized. In Customizer you could
choose which printed parts you want to render and save as STL file.
There are also ECHO messages in console that can be used to prepare BOM,
for example there are messages with all lengths of specific extrusion types,
GT2 belt lengts are also calculated.

**WARNING: While this is almost finished, THIS IS STILL WORK IN PROGRESS**

Forum thread (in Polish): https://reprapy.pl/viewtopic.php?f=10&t=7225

YouTube videos: https://youtube.com/playlist?list=PL_tFeFf-6be2vM2YfxNyLlgO5D3nhVPHG

# Requirements
- OpenScad https://www.openscad.org/
- NopSCADlib library https://github.com/nophead/NopSCADlib (version 21.32.0)
- for Sailfin extruder checkout Sailfin-Extruder/ git submodule
- for Moli extruder checkout Moli-Extruder/ git submodule
- for MRF extruder, download stl files from https://www.thingiverse.com/thing:5149028
  and put them into MRF/ directory

# Supported configuration
Extruders:
- TBG-Lite
- HGX Lite 2.0
Hotend:
- CHC heating block
Bed probes:
- Mini differential IR probe
- BL-Touch
Bed stabilization:
- v-slot wheels

# Known issues
- MGN12 carriage sticks 3.5mm out of frame
- bed frame could be 10mm shorter to use 4 the same wheel supports
- bed frame wheels supports are temporary, will be changed in future (work
  in progress on on MGN7 rails)
- Sailfin, Moli and MRF extruders support is not finished, BMG extruder
  is abandoned.

![vn-corexy carriage rendering](img/carriage-animated-20230127.gif)

# Copyright & license
(C) 2020-2024 Marek Wodzinski <majek@w7i.pl>

This work is licensed under Creative Commons Attribution-ShareAlike 4.0 International License.
You should have received a copy of the license along with this work. 
If not, see http://creativecommons.org/licenses/by-sa/4.0/

BL-Touch model (STL) by @EA3D from: https://www.printables.com/model/301723-bltouch 
is under a Creative Commons (International License) Public Domain
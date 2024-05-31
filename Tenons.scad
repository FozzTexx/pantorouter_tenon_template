/*
  Pantorouter Tenon Template by FozzTexx is marked with CC0 1.0.
  To view a copy of this license, visit https://creativecommons.org/publicdomain/zero/1.0/
*/

INCH_TO_MM = 25.4;

$fa = 1;
$fs = 0.5;

inner_bit = 0.5 * INCH_TO_MM;
inner_bearing = 10;
outer_bit = 0.5 * INCH_TO_MM;
outer_bearing = 10;

tenon_width = 1 * INCH_TO_MM;
tenon_length = floor((5.5 - 1) / 2) * INCH_TO_MM;
tenon_radius = inner_bit / 2;
//tenon_radius = tenon_width / 2;

rows = 1;
columns = 1;
row_gap = 1 * INCH_TO_MM;
column_gap = 1 * INCH_TO_MM;

template_taper = 12;
template_depth = 12;
base_depth = 3.5;
center_diameter = 6;
screw_diameter = 4;
screw_taper = 90;
inner_margin = 2;
center_mark_size = 1.5;

// Print a template and cut the mortise. Measure the actual length.
// shrink_comp = expected / actual
shrink_comp = 51.8 / 49.68;

function as_eighths(val) = [floor(val / INCH_TO_MM), ceil((val / (INCH_TO_MM / 8)) % 8)];
function is_eighth_inch(val) = abs(val * 1000 / (INCH_TO_MM / 8) - floor(val * 1000 / (INCH_TO_MM / 8))) % 1000 < 1;
function is_quarter_inch(val) = is_eighth_inch(val) && !(as_eighths(val)[1] % 2);
function is_half_inch(val) = is_eighth_inch(val) && !(as_eighths(val)[1] % 4);
function is_inch(val) = is_eighth_inch(val) && !as_eighths(val)[1];
function inch_mm_label(val) = is_eighth_inch(val) ?
  (is_inch(val) ? str(floor(val / INCH_TO_MM), "\"")
    : (is_half_inch(val) ? str(as_eighths(val)[0] ? str(as_eighths(val)[0], " ") : "", 
                               as_eighths(val)[1] / 4, "/2\"")
      : (is_quarter_inch(val) ? str(as_eighths(val)[0] ? str(as_eighths(val)[0], " ") : "", 
                               as_eighths(val)[1] / 2, "/4\"")
        : str(as_eighths(val)[0] ? str(as_eighths(val)[0], " ") : "", 
              as_eighths(val)[1], "/8\""))))
  : str(val, "mm");

module rounded_rect(width, length, radius, height=0.01) 
{
  union() {
    //height = 0.01;
    corner_w = width / 2 - radius;
    corner_l = length / 2 - radius;
    cube([width, length - radius * 2, height], center=true);
    cube([width - radius * 2, length, height], center=true);
    translate([-1 * corner_w, -1 * corner_l, 0]) cylinder(height, r=radius, center=true);
    translate([1 * corner_w, -1 * corner_l, 0]) cylinder(height, r=radius, center=true);
    translate([-1 * corner_w, 1 * corner_l, 0]) cylinder(height, r=radius, center=true);
    translate([1 * corner_w, 1 * corner_l, 0]) cylinder(height, r=radius, center=true);
  }
}
  
module screw_hole(diameter, taper) 
{
  length = base_depth + template_depth;
  countersink_diameter = diameter * 2.2;
  countersink_height = (countersink_diameter / 2) / tan(taper / 2);

  union()
  {
    translate([0, 0, -length])
      cylinder(length, d=screw_diameter, center=false);
    translate([0, 0, -countersink_height+0.01])
      cylinder(countersink_height, d1=0, d2=countersink_diameter, center=false);
    translate([0, 0, -0.01])
      cylinder(length, d=countersink_diameter, center=false);
  }
}

module tenon() 
{
  top_offset = template_depth * tan(template_taper) * 2;

  outer_width = (tenon_width + outer_bit) * 2 - outer_bearing;
  outer_length = (tenon_length + outer_bit) * 2 - outer_bearing;
  outer_radius = ((tenon_radius * 2 + outer_bit) * 2 - outer_bearing) / 2;

  inner_width = ((tenon_width - inner_bit) * 2 + inner_bearing) * shrink_comp;
  inner_length = ((tenon_length - inner_bit) * 2 + inner_bearing) * shrink_comp;
  inner_radius = (((tenon_radius * 2 - inner_bit) * 2 + inner_bearing) / 2) * shrink_comp;

  difference()
  {
    hull() 
    {
      rounded_rect(outer_width, outer_length, outer_radius);
      translate([0, 0, template_depth])
        rounded_rect(outer_width - top_offset, outer_length - top_offset, outer_radius - top_offset);
    }
    
    top_edge = (outer_width - top_offset) / 2;
    bot_edge = inner_width / 2;
    t_width = (top_edge - bot_edge) / 2;
    test_val = 3/4 * INCH_TO_MM;
    translate([-(bot_edge + t_width), 0, template_depth - 1])
      rotate([0, 0, 90])
        linear_extrude(1.05)
          text(size=t_width, halign="center", valign="center", str("\u2191", outer_bearing, "mm ", inch_mm_label(outer_bit)));
    translate([bot_edge + t_width, 0, template_depth - 1])
      rotate([0, 0, 90])
        linear_extrude(1.05)
          text(size=t_width, halign="center", valign="center", str("\u2191", inner_bearing, "mm ", inch_mm_label(inner_bit)));


    for (idx = [0:2])
    {
      offset = (template_depth - base_depth) / 3;
      hull()
      {
        translate([0, 0, base_depth + offset * idx])
          rounded_rect(inner_width, inner_length + idx * inner_margin, inner_radius);
        translate([0, 0, template_depth+1])
          rounded_rect(inner_width, inner_length + idx * inner_margin, inner_radius);
      }
    }
    
    itop_edge = inner_width / 2;
    ibot_edge = itop_edge - inner_width / 3;
    it_width = (itop_edge - ibot_edge) / 2;
    translate([-(ibot_edge + it_width), 0, base_depth - 1])
      rotate([0, 0, 90])
        linear_extrude(1.05)
          text(size=it_width, halign="center", valign="center", str(inch_mm_label(tenon_width), " x ", inch_mm_label(tenon_length)));
    
    // centering marks
    if (center_mark_size)
    {
      translate([-outer_width / 2, 0, -1])
        rotate([0, 0, 45])
          cube([center_mark_size, center_mark_size, template_depth + 2]);
      translate([outer_width / 2, 0, -1])
        rotate([0, 0, 45])
          cube([center_mark_size, center_mark_size, template_depth + 2]);
    }
  }
}

on_center_spacing = [(tenon_width + column_gap) * 2, (tenon_length + row_gap) * 2];
tenon_bounds = [(tenon_width + outer_bit) * 2 - outer_bearing, 
                (tenon_length + outer_bit) * 2 - outer_bearing];
total_center = [on_center_spacing[0] * (columns - 1), on_center_spacing[1] * (rows - 1)];

difference()
{
  outer_width = (tenon_width + outer_bit) * 2 - outer_bearing;
  outer_length = (tenon_length + outer_bit) * 2 - outer_bearing;
  spacing = [(tenon_width + column_gap) * 2 - outer_width,
             (tenon_length + row_gap) * 2 - outer_length];
  base_size = [(outer_width + spacing[0]) * columns - spacing[0],
               (outer_length + spacing[1]) * rows - spacing[1], 
               base_depth];
  echo("BASE", base_size[0]/INCH_TO_MM, base_size[1]/INCH_TO_MM);

  union()
  {
    translate([-total_center[0] / 2, -total_center[1] / 2, 0]) 
    {
      for (row = [0:rows-1]) {
        for (column = [0:columns-1]) {
          translate([column * on_center_spacing[0], row * on_center_spacing[1], 0])
            tenon();
        }
      }
    }

    if (rows > 1 || columns > 1)
    {
        translate([0, 0, -base_size[2] / 2])
          rounded_rect(base_size[0], base_size[1], ((tenon_radius * 2 + outer_bit) * 2 - outer_bearing) / 2, base_size[2]);
    }
  }

  cylinder(template_depth * 3, d=center_diameter, center=true);
  
  for (idx = [-rows:rows]) {
    if (idx)
    {
      z_pos = columns % 2 ? base_depth : 0;
      y_pos = idx * base_size[1] / (rows * 2 + 2);
      translate([0, y_pos, z_pos])
        screw_hole(screw_diameter, screw_taper);
    }
  }
}

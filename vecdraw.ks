vecdraw().
set xAxis to VECDRAWARGS( V(0,0,0), V(1,0,0), RGB(1.0,0.5,0.5), "X axis", 5, TRUE ).
set yAxis to VECDRAWARGS( V(0,0,0), V(0,1,0), RGB(0.5,1.0,0.5), "Y axis", 5, TRUE ).
set zAxis to VECDRAWARGS( V(0,0,0), V(0,0,1), RGB(0.5,0.5,1.0), "Z axis", 5, TRUE ).

set xAxisup to ship:up*ship:velocity:surface:x.
set yAxisup to ship:up*ship:velocity:surface:y.
set zAxisup to ship:up*ship:velocity:surface:z.

set xAxisupd to VECDRAWARGS( V(0,0,0), xaxisup, RGB(1.0,0.5,0.5), "X axis up", 5, TRUE ).
set yAxisupd to VECDRAWARGS( V(0,0,0), yAxisup, RGB(0.5,1.0,0.5), "Y axis up", 5, TRUE ).
set zAxisupd to VECDRAWARGS( V(0,0,0), zAxisup, RGB(0.5,0.5,1.0), "Z axis up", 5, TRUE ).

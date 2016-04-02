wait 5.
copy lib_com from 0.
copy boot_test from 0.

run once lib_com.

print "ready".

set coffset to 1.

lock vs to ship:verticalspeed.
wait until ship:control:pilotmainthrottle > 0.75.
set ship:control:pilotmainthrottle to 0.
toggle gear.
lock steering to heading(270,40).
until ship:availablethrust > 0.1 {
	stage.
	wait 0.1.
}
lock throttle to 1.
wait until ship:apoapsis>2500.
lock throttle to 0. sas on. rcs on.
lock steering to -ship:velocity:surface.
wait until eta:apoapsis < 5.
toggle ag1.
wait 0.0001.
set trat to twr().
wait 0.0001.
if trat < 2 { toggle ag1. }
brakes on. sas off.
land(coffset).
brakes off. toggle ag1. rcs off.
unlock steering.
set ship:control:pilotmainthrottle to 0.

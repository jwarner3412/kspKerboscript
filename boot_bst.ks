wait 5.
SET SASMODE TO "STABILITYASSIST".
WAIT UNTIL SHIP:MASS < 60.

PRINT "BRAKES ON".
brakes on.

WAIT 10.
copy lib_com FROM 0.
copy boot_bst from 0.
run once lib_com.
function f9offset {
	local plist is ship:parts.
	local eng is ship:partsdubbed("engine1").
	local vectdist1 is (((plist[0]:position-eng[0]:position):mag)+3.47).
	return vectdist1.
}
function boostback {
	local sampspeed is 0.
	lock traj to -ship:velocity:surface.
	RCS ON. sas off.
	lock steering to traj.
	wait until eta:apoapsis<1.
	set traj to -ship:velocity:surface.
	wait until VANG(traj,SHIP:FACING:FOREVECTOR)<1.
	PRINT "BOOSTING BACK".
	set sampspeed to ship:velocity:surface:mag.
	LOCK THROTTLE TO 1.
	wait until VANG(ship:velocity:surface,SHIP:FACING:FOREVECTOR)<90.
	wait until ship:velocity:surface:mag>1.05*(sampspeed-(ship:velocity:orbit:mag-ship:velocity:surface:mag)).
	LOCK THROTTLE TO 0.
	lock traj to -ship:velocity:surface.
	wait until ship:ALTITUDE < 25000.
	wait until VANG(traj,SHIP:FACING:FOREVECTOR)<1.
	lock throttle to 1.
	wait until ship:velocity:surface:mag<600.
	lock throttle to 0.
	toggle ag1.
	if twr()<2{
		toggle ag1.
	}
}.
set radaroffset to f9offset(). log 0 to ro.ks. delete ro.ks. LOG "global RADAROFFSET is "+radaroffset+"." TO ro.ks.
print "Radar offset is "+radaroffset.
PRINT "OPS104 BOOST BACK PROGRAM LOADED".
wait 1.
boostback().
land(radaroffset).
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
print "end boot".
delete boot_bst.

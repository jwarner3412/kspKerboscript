LOCAL AP IS 1.
LOCAL PE IS 2.
LOCAL NOW IS 3.
LOCAL TALT IS 1.
LOCAL TPERIOD IS 2.
FUNCTION OPS201 { // CIRC
	PARAMETER LOC.
	IF LOC = 1 {
	if KUniverse:ACTIVEVESSEL = ship {
			wait 1.
			WARPTO(TIME:SECONDS+ETA:APOAPSIS-30).
		}
		WAIT UNTIL ETA:APOAPSIS < 20.
		LOCK MYVEC TO SHIP:VELOCITY:ORBIT.
	}
	IF LOC = 2 {
		if KUniverse:ACTIVEVESSEL = ship {
			wait 1.
			WARPTO(TIME:SECONDS+ETA:PERIAPSIS-30).
		}
		WAIT UNTIL ETA:PERIAPSIS < 20.
		LOCK MYVEC TO (-1)*SHIP:VELOCITY:ORBIT.
	}
	RCS ON.
	LOCK STEERING TO MYVEC.
	wait until VANG(MYVEC,SHIP:FACING:FOREVECTOR)< 1.
	IF LOC = 1 {
		if eta:apoapsis > 30*60 {
			print "orbit circular, apoapsis jump".
			LOCK THROTTLE TO 1.
		}
		else {WAIT UNTIL ETA:APOAPSIS<1.}.
	}
	IF LOC = 2 {
		if eta:periapsis > 30*60 {
			print "orbit circular, periapsis jump".
			LOCK THROTTLE TO 1.
		}
		else {WAIT UNTIL ETA:periapsis<1.}.
	}

	PRINT "CIRCULARIZING".
	LOCK THROTTLE TO 1.
	IF LOC = 1 {
		WAIT UNTIL ETA:APOAPSIS<1.
		WAIT UNTIL SHIP:PERIAPSIS>SHIP:APOAPSIS-5000.
	}
	IF LOC = 2 {
		WAIT UNTIL ETA:PERIAPSIS<1.
		WAIT UNTIL SHIP:APOAPSIS<SHIP:PERIAPSIS+5000.
	}

	LOCK THROTTLE TO 0.
	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
	UNLOCK STEERING.UNLOCK MYVEC.RCS OFF.
	PRINT "MANUVEUR COMPLETE".
}.
FUNCTION OPS202{ //PE&AP ALT ADJUSTMENT & CIRC
	PARAMETER LOC. // PE OR AP
	PARAMETER UNIT. // ALTIT OR TPERIOD
	PARAMETER VAL. // ALT OR PERIOD VALUE
	RCS ON.
	IF LOC = 1 {
		if KUniverse:ACTIVEVESSEL = ship {
			wait 1.
			WARPTO(TIME:SECONDS+ETA:APOAPSIS-30).
		}
		IF UNIT = 1{
			IF VAL > SHIP:PERIAPSIS {
				set MYVEC TO SHIP:VELOCITY:ORBIT.
			}
			ELSE {
				set MYVEC TO (-1)*SHIP:VELOCITY:ORBIT.
			}.
			LOCK STEERING TO MYVEC.
			wait until VANG(MYVEC,SHIP:FACING:FOREVECTOR)< 0.15.
			if eta:apoapsis > 30*60 {
				print "orbit circular, apoapsis jump".
				LOCK THROTTLE TO 1.
			}
			else {WAIT UNTIL ETA:APOAPSIS<1.}.
			LOCK THROTTLE TO 1.
			IF VAL > SHIP:PERIAPSIS {
				WAIT UNTIL SHIP:PERIAPSIS>VAL.
			}
			ELSE {
				WAIT UNTIL SHIP:PERIAPSIS<VAL.
			}.
		}
		ELSE { //UNIT 2
			IF VAL > SHIP:ORBIT:PERIOD {
				set MYVEC TO SHIP:VELOCITY:ORBIT.
			}
			ELSE {
				set MYVEC TO (-1)*SHIP:VELOCITY:ORBIT.
			}.
			LOCK STEERING TO MYVEC.
			wait until VANG(MYVEC,SHIP:FACING:FOREVECTOR) < 0.15.
			if eta:apoapsis > 30*60 {
				print "orbit circular, apoapsis jump".
				LOCK THROTTLE TO 1.
			}
			else {WAIT UNTIL ETA:APOAPSIS<1.}.
			LOCK THROTTLE TO 1.
			IF VAL > SHIP:ORBIT:PERIOD {
				WAIT UNTIL SHIP:ORBIT:PERIOD>(VAL-100).
				LOCK THROTTLE TO 0.1.
				WAIT UNTIL SHIP:ORBIT:PERIOD>VAL.
			}
			ELSE {
				WAIT UNTIL SHIP:ORBIT:PERIOD<(VAL+100).
				LOCK THROTTLE TO 0.1.
				WAIT UNTIL SHIP:ORBIT:PERIOD<VAL.
			}.
		}.
	}
	ELSE IF LOC = 2 {
		if KUniverse:ACTIVEVESSEL = ship {
			wait 1.
			WARPTO(TIME:SECONDS+ETA:PERIAPSIS-30).
		}
		WAIT UNTIL ETA:PERIAPSIS<20.
		IF UNIT = 1 {
			IF VAL > SHIP:APOAPSIS {
				set MYVEC TO SHIP:VELOCITY:ORBIT.
			}
			ELSE {
				set MYVEC TO (-1)*SHIP:VELOCITY:ORBIT.
			}.
			LOCK STEERING TO MYVEC.
			wait until VANG(MYVEC,SHIP:FACING:FOREVECTOR) < 0.15.
			if eta:periapsis > 30*60 {
				print "orbit circular, periapsis jump".
				LOCK THROTTLE TO 1.
			}
			else {WAIT UNTIL ETA:periapsis<1.}.
			LOCK THROTTLE TO 1.
			IF VAL > SHIP:APOAPSIS {
				WAIT UNTIL SHIP:APOAPSIS>VAL.
			}
			ELSE {
				WAIT UNTIL SHIP:APOAPSIS<VAL.
			}.
		}
		ELSE {
			IF VAL > SHIP:ORBIT:PERIOD {
				set MYVEC TO SHIP:VELOCITY:ORBIT.
			}
			ELSE {
				set MYVEC TO (-1)*SHIP:VELOCITY:ORBIT.
			}.
			LOCK STEERING TO MYVEC.
			wait until VANG(MYVEC,SHIP:FACING:FOREVECTOR)<0.15.
			if eta:periapsis > 30*60 {
				print "orbit circular, apoapsis jump".
				LOCK THROTTLE TO 1.
			}
			else {WAIT UNTIL ETA:periapsis<1.}.
			LOCK THROTTLE TO 1.
			IF VAL > SHIP:ORBIT:PERIOD {
				WAIT UNTIL SHIP:ORBIT:PERIOD>VAL.
			}
			ELSE {
				WAIT UNTIL SHIP:ORBIT:PERIOD<VAL.
			}.
		}.
	}
	ELSE {
		IF UNIT = 1 {
			IF VAL > SHIP:APOAPSIS {
				SET MYVEC TO SHIP:VELOCITY:ORBIT.
			}
			ELSE IF VAL < SHIP:PERIAPSIS {
				SET MYVEC TO (-1)*SHIP:VELOCITY:ORBIT.
			}
			ELSE {
				RETURN.
				PRINT "CHOOSE ANOTHER MODE".
			}.
			LOCK STEERING TO MYVEC.
			wait until VANG(MYVEC,SHIP:FACING:FOREVECTOR)<0.15.
			LOCK THROTTLE TO 1.
			IF VAL > SHIP:APOAPSIS {
				WAIT UNTIL SHIP:APOAPSIS>VAL.
			}
			ELSE {
				WAIT UNTIL SHIP:PERIAPSIS<VAL.
			}.
		}
		ELSE {
			IF VAL > SHIP:ORBIT:PERIOD {
				set MYVEC TO SHIP:VELOCITY:ORBIT.
			}
			ELSE {
				SET MYVEC TO (-1)*SHIP:VELOCITY:ORBIT.
			}.
			LOCK STEERING TO MYVEC.
			wait until VANG(MYVEC,SHIP:FACING:FOREVECTOR)<0.15.
			LOCK THROTTLE TO 1.
			IF VAL > SHIP:ORBIT:PERIOD {
				WAIT UNTIL SHIP:ORBIT:PERIOD>VAL.
			}
			ELSE {
				WAIT UNTIL SHIP:ORBIT:PERIOD<VAL.
			}.
		}.
	}.
	LOCK THROTTLE TO 0.
	UNLOCK STEERING.UNLOCK MYVEC.RCS OFF.
}.
FUNCTION OPS211 {
	SAS ON.RCS ON.
	WAIT 5.
	UNTIL PAYLOAD = 0 {
		IF PLCOMM = TRUE {
			if KUniverse:ACTIVEVESSEL = ship {
				wait 1.
				WARPTO(TIME:SECONDS+(ETA:PERIAPSIS-10)).
			}
			WAIT UNTIL ETA:PERIAPSIS<1.
		}
		if KUniverse:ACTIVEVESSEL = ship {
			STAGE.
			SET PAYLOAD TO (PAYLOAD)-(1).
			PRINT "PACKAGE AWAY".
			if payload = 0 {wait 10.} else {WAIT 100.}.
		} else {print "payload deploy failed". wait until KUniverse:ACTIVEVESSEL=ship.}.
	}
	PRINT "ALL PAYLOAD RELEASED".
	UNLOCK STEERING.UNLOCK MYVEC.RCS OFF.SAS OFF.
}.
function ops221 {
	set nd to nextnode.
	print "Node in: " + round(nd:eta) + ", DeltaV: " + round(nd:deltav:mag).
	set max_acc to ship:maxthrust/ship:mass.
	set burn_duration to nd:deltav:mag/max_acc.
	print "Estimated burn duration: " + round(burn_duration) + "s".
	wait until nd:eta <= (burn_duration/2 + 60).
	set np to lookdirup(nd:deltav, ship:facing:topvector).
	lock steering to np.
	wait until abs(np:pitch - facing:pitch) < 0.15 and abs(np:yaw - facing:yaw) < 0.15.
	wait until nd:eta <= (burn_duration/2).
	set tset to 0.
	lock throttle to tset.
	set done to False.
	set dv0 to nd:deltav.
	until done {
		set max_acc to ship:maxthrust/ship:mass.
		set tset to min(nd:deltav:mag/max_acc, 1).
		if vdot(dv0, nd:deltav) < 0 {
			print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
			lock throttle to 0.
			break.
		}
		if nd:deltav:mag < 0.1 {
			print "Finalizing burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
			wait until vdot(dv0, nd:deltav) < 0.5.
			lock throttle to 0.
			print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
			set done to True.
		}
	}
	unlock steering.
	unlock throttle.
	wait 1.
	remove nd.
	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
	global runmode is 0.
}.
FUNCTION OPS299 {	//DEORBIT
	PRINT "DEORBIT INITIATED".
	if ship:apoapsis-ship:periapsis < 10000 {
		ops202(now,talt,20000).
	}
	else { OPS202(AP,TALT,20000). }.
	if KUniverse:ACTIVEVESSEL = ship {
		wait 1.
		WARPTO(TIME:SECONDS+ETA:PERIAPSIS).
	}
	WAIT UNTIL SHIP:ALTITUDE<70000.
	PRINT "ATMOSPHERIC INTERFACE".
	lock steering to ship:prograde+r(90,0,0).
	wait 5.
	if KUniverse:ACTIVEVESSEL = ship {
		STAGE.
		PRINT "SERVICE MODULE EJECTED".
	}
	else {
		print "waiting for focus".
		WAIT UNTIL KUniverse:ACTIVEVESSEL=ship.
		WAIT 0.0001.
		stage.
		PRINT "SERVICE MODULE EJECTED".
	}.
	PRINT "REORIENTING FOR BRAKING".
	wait 2.
	lock steering to retrograde.
	global runmode is 300. SAVERUNMODE().
	wait 10.
	UNLOCK STEERING. RCS OFF.
}.
print "OPS200 LOADED".

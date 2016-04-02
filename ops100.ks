@lazyglobal off.
run once lib_com.
function ascenttriggers {
	WHEN Ship:altitude > ATMO1 THEN {
		GLOBAL STARTANG is surfvecpitch().
		GLOBAL STARTALT is ATMO1.
		WHEN Ship:altitude > ATMO3 THEN {
			IF FAIRING {
				if KUniverse:ACTIVEVESSEL = ship {
					STAGE.
					PRINT "FAIRING DEPLOYED".
				}
				else {
					print "waiting for focus".
					when KUniverse:ACTIVEVESSEL=ship then {
						stage.
						PRINT "FAIRING DEPLOYED".
						unset fairing.
					}
				}.
			}
			when ship:altitude > space then {
				global runmode is 103. log 0 to rm.ks. delete rm.ks. log "global runmode is "+runmode+"." to rm.ks.
			}
			WHEN SHIP:APOAPSIS > PARKAP THEN {
				global runmode is 104. log 0 to rm.ks. delete rm.ks. log "global runmode is "+runmode+"." to rm.ks.
			}
		}
	}
	WHEN FTANK[HEAVY]:RESOURCES[0]:AMOUNT < BSTF THEN {
		global runmode is 110. log 0 to rm.ks. delete rm.ks. log "global runmode is "+runmode+"." to rm.ks.
		IF HEAVY{
			WHEN FTANK[0]:RESOURCES[0]:AMOUNT < BSTF+500 THEN {
				global runmode is 110. log 0 to rm.ks. delete rm.ks. log "global runmode is "+runmode+"." to rm.ks.
				set heavy to 0.
			}
		}
	}
	Print "ASCENT STAGING LOGIC ARMED".
}.
FUNCTION OPS101 {
	PRINT "COUNTING DOWN:". FROM {LOCAL COUNTDOWN IS CD.
	}
	UNTIL COUNTDOWN = 0 STEP {
		SET COUNTDOWN TO COUNTDOWN -1.
		if countdown = 1 {LOCK THROTTLE TO 1.0. SAS ON.}
	} DO {PRINT "..." + COUNTDOWN. WAIT 1.}
	smartstage().
	PRINT "LIFTOFF".
	wait until SHIP:ALTITUDE > 1000.
	sas off.
	global runmode is 102. log 0 to rm.ks. delete rm.ks. log "global runmode is "+runmode+"." to rm.ks.
	ascenttriggers().
}.
FUNCTION OPS102 { //ASCENT
	local pit is startang. local pit1 is 0. local pit2 is 0.
	local errpit is 0.
	local np is 0. local vp is 0.
	local apid is pid_init(0.1,0.05,0.01,-15,15).
	local traj is heading(h,(pit+errpit)).
	lock throttle to 1.
	lock steering to traj.
	UNTIL RUNMODE > 102 {
	//	set np to (navpitch()+surfvecpitch())/2.
		set np to navpitch().
		set vp to surfvecpitch().
		set pit to ascpitch(startalt,endalt,startang,endang,0).
		//set errpit to pid_seek(apid,pit,np).
		set pit1 to pid_seek(apid,pit,np).
		set pit2 to pid_seek(apid,pit,vp).
		set errpit to (pit1+pit2)/2.
		set traj to heading(h,(pit+errpit)).
		wait 0.0001.
	}
}.
function OPS103 {
	local traj is ship:prograde.
	local pit1 is 0. local pit2 is 0. local pit is 0.
	local targap is (0.8)*parkap.
	local aptime is eta:apoapsis.
	local aphe is ship:apoapsis.
	local PPIDt is PID_init(0.5,4,8,-25,25).
	local PPIDh is PID_init(0.05,0,8,-25,25).
	local lock aphe to ship:apoapsis.
	local lock aptime to eta:apoapsis.
	local lock traj to ship:prograde+r(0,pit,0).
	lock throttle to 1.
	lock steering to traj.
	until runmode > 103 {
		until ship:PERIAPSIS > -30000 {
			set pit1 to pid_seek(ppidt,60,eta:apoapsis).
			//set pit2 to pid_seek(ppidh,targap,aphe).
			//set pit to (pit1+pit2)/2.
			set pit to pit1.
			wait 0.0001.
		}
		set pit to 0.
		wait 0.0001.
	}
}.
FUNCTION OPS104 {	//COAST TO AP.
	print "coasting to apoapsis".
	LOCK THROTTLE TO 0.
	WAIT 1.
	LOCK STEERING TO PROGRADE.
	UNTIL Ship:altitude > SPACE {
		WAIT 1.
		IF SHIP:APOAPSIS < parkAP {
			LOCK THROTTLE TO 1.
			PRINT "RAISING APOAPSIS".
			WAIT UNTIL SHIP:APOAPSIS > PARKAP.
			LOCK THROTTLE TO 0.
		}
	}
	PRINT "WELCOME TO SPACE, STANDBY FOR BURN".
	UNLOCK STEERING.
	global runmode is 200. log 0 to rm.ks. delete rm.ks. log "global runmode is "+runmode+"." to rm.ks.
}.
FUNCTION OPS110 { //BOOSTER STAGING
	LOCK THROTTLE TO 0.
	release().
	PRINT "MECO".
	sas on.
	wait 2.
	global runmode is 102. log 0 to rm.ks. delete rm.ks. log "global runmode is "+runmode+"." to rm.ks.
	stage.
	WAIT 7.
	PRINT "STAGING".
	smartstage().
	sas off.
	if heavy{
		SET FTANK TO SHIP:PARTSDUBBED("Ghidorah K1-180 Tank").
	}
}.
print "OPS100 LOADED".

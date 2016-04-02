//F = m*a //F = G*M*m/r^2 //a = G*M/r^2
@LAZYGLOBAL off.
function PID_init {
  parameter
    Kp,      // gain of position
    Ki,      // gain of integral
    Kd,      // gain of derivative
    cMin,  // the bottom limit of the control range (to protect against integral windup)
    cMax.  // the the upper limit of the control range (to protect against integral windup)
  local SeekP is 0. // desired value for P (will get set later).
  local p is 0.     // phenomenon P being affected.
  local i is 0.     // crude approximation of Integral of P.
  local d is 0.     // crude approximation of Derivative of P.
  local oldT is -1. // (old time) start value flags the fact that it hasn't been calculated
  local oldInput is 0. // previous return value of PID controller.
  local PID_array is list(Kp, Ki, Kd, cMin, cMax, SeekP, P, I, D, oldT, oldInput).
  return PID_array.
}.
function PID_seek {
  parameter
    PID_array, // array built with PID_init.
    seekVal,   // value we want.
    curVal.    // value we currently have.
  local Kp   is PID_array[0].
  local Ki   is PID_array[1].
  local Kd   is PID_array[2].
  local cMin is PID_array[3].
  local cMax is PID_array[4].
  local oldS   is PID_array[5].
  local oldP   is PID_array[6].
  local oldI   is PID_array[7].
  local oldD   is PID_array[8].
  local oldT   is PID_array[9]. // Old Time
  local oldInput is PID_array[10]. // prev return value, just in case we have to do nothing and return it again.
  local P is seekVal - curVal.
  local D is oldD. // default if we do no work this time.
  local I is oldI. // default if we do no work this time.
  local newInput is oldInput. // default if we do no work this time.
  local t is time:seconds.
  local dT is t - oldT.
  if oldT < 0 {
  } else {
    if dT > 0 { // Do nothing if no physics tick has passed from prev call to now.
     set D to (P - oldP)/dT. // crude fake derivative of P
     local onlyPD is Kp*P + Kd*D.
     if (oldI > 0 or onlyPD > cMin) and (oldI < 0 or onlyPD < cMax) { // only do the I turm when within the control range
      set I to oldI + P*dT. // crude fake integral of P
     }.
     set newInput to onlyPD + Ki*I.
    }.
  }.
  set newInput to max(cMin,min(cMax,newInput)).
  set PID_array[5] to seekVal.
  set PID_array[6] to P.
  set PID_array[7] to I.
  set PID_array[8] to D.
  set PID_array[9] to t.
  set PID_array[10] to newInput.
  return newInput.
}.
function gforcehere {
  local ma is ship:mass.
  local bo is ship:body:mass.
  local valt is ship:altitude.
  local rad is ship:body:radius.
	local gforce is ma*(constant():g*(bo/(valt+rad)^2)).
	return gforce.
}.
function gforcesealvl {
	local gforce is ship:mass * (constant():g *(ship:body:mass/(ship:body:radius)^2)).
	return gforce.
}.
function gaccelhere {
  local ma is ship:mass.
  local bo is ship:body:mass.
  local valt is ship:altitude.
  local rad is ship:body:radius.
	local gaccel is constant():g*(ma/(valt+rad)^2).
	return gaccel.
}.
function gaccelsealvl {
	local gaccel is constant():g *(ship:body:mass/(ship:body:radius)^2).
	return gaccel.
}.
function maxaccel {
  local th is ship:availablethrust.
  local ma is ship:mass.
	local maxa is th/ma.
	return maxa.
}.
function maxaccelfall {
  local th is ship:availablethrust.
  local ma is ship:mass.
  local maf is (th/ma)-gaccelhere().
  return maf.
}.
function twr {
  local thrust is ship:availablethrust.
  local tfg is thrust/gforcehere().
  return tfg.
}.
function brakeson {
  brakes off.
  brakes on.
}.
function suicidedist {
	parameter comdist.
  local vs is ship:verticalspeed.
  local alt1 is alt:radar-comdist.
	local suicide is alt1-(vs*(vs/(maxaccelfall()))).
	return suicide.
}.
function navpitch {
	local np is 90-vang(ship:up:vector, ship:facing:forevector).
	return np.
}.
function surfvecpitch {
	local vp is 90-vang(ship:up:vector, ship:velocity:surface).
	return vp.
}.
function aoa {
	local ang is vang(ship:velocity:surface,ship:facing:forevector).
	return ang.
}.
function ascpitch {
	parameter
	 s_alt,
	 e_alt,
	 s_ang,
	 e_ang,
   comoff.
  local alt2 is alt:radar-comoff.
	local pit is ((( alt2 - S_ALT )*(( E_ANG - S_ANG )/( E_ALT - S_ALT ))) + S_ANG ).
	return pit.
}.
function release {
  lock throttle to 0.
  set ship:control:pilotmainthrottle to 0.
  unlock throttle. unlock steering.
  rcs off. sas off.
}.
function vecframerotate {
  parameter vecinput.
  parameter reference.
  local new_x is reference*vecinput:x.
  local new_y is reference*vecinput:y.
  local new_z is reference*vecinput:z.
  print new_x.
  print new_y.
  print new_z.
  return V(new_x,new_y,new_z).
}.
function land {
  parameter comoff.
  local thrott is 0.
  local alt1 is 999. local sd is 100.
  local trat is 0. local traj is 0.
  local lock traj to -ship:velocity:surface.
  local lock alt1 to alt:radar-comoff.
  local lock sd to suicidedist(comoff).
  local lock trat to twr().
  local sdpid is pid_init(2,4,8,-0.05,0.05).
  function sdburn {
    parameter othrott.
    local seekvs is 5.
    local thrott2 is PID_seek(sdpid,seekvs,sd).
    if othrott < 0.05 AND thrott2 < 0.05 OR othrott > 0.999 AND thrott2 > 0 {wait 0.0001.}
    else {set othrott to othrott+thrott2.}.
    return othrott.
  }.

  local landpid is pid_init(0.1,0.05,0.01,0,1).
  function touchdown {
    local hs is ship:groundspeed.
    local vs is ship:verticalspeed.
    local seekvs is -1.
    if vs < -1 {
      set seekvs to (-1)*abs(ascpitch(1000,0.001,-500,-1,comoff)).
    } else {
      set seekvs to -0.75.
    }.
    local thrott2 is PID_seek(landpid,seekvs,vs).
    return thrott2.
  }.

  lock steering to traj.
  lock throttle to thrott. rcs on.
  wait until sd<5.
  set thrott to 1.
  when alt:radar<150 then {
    toggle gear.
  }
  until alt1 < (2/trat)*maxaccelfall() {
    if ship:groundspeed < 5 {set traj to up.}
    else {set traj to -ship:velocity:surface.}.
    set thrott to sdburn(thrott).
    wait 0.0001.
  }
  until ship:status = "landed" {
    if ship:groundspeed < 5 {set traj to up.}
    else {set traj to -ship:velocity:surface.}.
    set thrott to touchdown().
    IF SHIP:STATUS = "SPLASHED" {BREAK.}
    wait 0.0001.
  }
  print alt1.
  release().
  print "welcome home".
}.
function forthwall {
  parameter dist.
  local lode is dist*1000.
  local unlode is lode-50.
  local pak is lode-1.
  local unpak is lode-100.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:UNLOAD TO unlode.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:LOAD TO lode.
  WAIT 0.001.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:PACK TO pak.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:UNPACK TO unpak.
  WAIT 0.001.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:ORBIT:UNLOAD TO unlode.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:ORBIT:LOAD TO lode.
  WAIT 0.001.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:ORBIT:PACK TO pak.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:ORBIT:UNPACK TO unpak.
  WAIT 0.001.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:SUBORBITAL:UNLOAD TO unlode.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:SUBORBITAL:LOAD TO lode.
  WAIT 0.001.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:SUBORBITAL:PACK TO pak.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:SUBORBITAL:UNPACK TO unpak.
  WAIT 0.001.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:ESCAPING:UNLOAD TO unlode.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:ESCAPING:LOAD TO lode.
  WAIT 0.001.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:ESCAPING:PACK TO pak.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:ESCAPING:UNPACK TO unpak.
  WAIT 0.001.
}.
function forthwalldefault {
  set KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:UNLOAD to 22500.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:LOAD TO 2250.
  wait 0.0001.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:PACK TO 25000.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:FLYING:UNPACK TO 200.
  wait 0.0001.
  set KUNIVERSE:DEFAULTLOADDISTANCE:LANDED:UNLOAD to 2500.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:LANDED:LOAD TO 2250.
  wait 0.0001.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:LANDED:PACK TO 350.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:LANDED:UNPACK TO 200.
  wait 0.0001.
  set KUNIVERSE:DEFAULTLOADDISTANCE:SPLASHED:UNLOAD to 2500.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:SPLASHED:LOAD TO 2250.
  wait 0.0001.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:SPLASHED:PACK TO 350.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:SPLASHED:UNPACK TO 200.
  wait 0.0001.
  set KUNIVERSE:DEFAULTLOADDISTANCE:PRELAUNCH:UNLOAD to 2500.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:PRELAUNCH:LOAD TO 2250.
  wait 0.0001.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:PRELAUNCH:PACK TO 350.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:PRELAUNCH:UNPACK TO 200.
  wait 0.0001.
  set KUNIVERSE:DEFAULTLOADDISTANCE:ORBIT:UNLOAD to 2500.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:ORBIT:LOAD TO 2250.
  wait 0.0001.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:ORBIT:PACK TO 350.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:ORBIT:UNPACK TO 200.
  wait 0.0001.
  set KUNIVERSE:DEFAULTLOADDISTANCE:SUBORBITAL:UNLOAD to 15000.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:SUBORBITAL:LOAD TO 2250.
  wait 0.0001.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:SUBORBITAL:PACK TO 10000.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:SUBORBITAL:UNPACK TO 200.
  wait 0.0001.
  set KUNIVERSE:DEFAULTLOADDISTANCE:ESCAPING:UNLOAD to 2500.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:ESCAPING:LOAD TO 2250.
  wait 0.0001.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:ESCAPING:PACK TO 350.
  SET KUNIVERSE:DEFAULTLOADDISTANCE:ESCAPING:UNPACK TO 200.
  wait 0.0001.
}.
function smartstage {
  until ship:availablethrust > 0.1 {
    stage.
    wait 0.1.
  }
}.
FUNCTION CHECKIN {
	PRINT " ".
	PRINT "MISSION TIME....."+MISSIONTIME.
	PRINT "ALTITUDE....."+ROUND(SHIP:ALTITUDE).
  PRINT " ".
	PRINT "APOAPSIS....."+ROUND(SHIP:APOAPSIS).
  PRINT "PERIAPSIS....."+ROUND(SHIP:PERIAPSIS).
  PRINT " ".
	PRINT "ETA:APOAPSIS....."+ROUND(ETA:APOAPSIS).
	PRINT "ETA:PERIAPSIS....."+ROUND(ETA:PERIAPSIS).
  PRINT " ".
	PRINT "ORBIT PERIOD....."+ROUND(SHIP:ORBIT:PERIOD).
	PRINT "ORBIT INCLINATION....."+ROUND(SHIP:ORBIT:INCLINATION).
	PRINT "LONG OF ASC NODE....."+ROUND(SHIP:ORBIT:LAN).
  PRINT " ".
	PRINT "VERTICAL VELOCITY....."+ROUND(SHIP:VERTICALSPEED).
	PRINT "HORIZONTAL VELOCITY....."+ROUND(SHIP:GROUNDSPEED).
  PRINT " ".
	PRINT "OBT VELOCITY....."+ROUND(SHIP:VELOCITY:ORBIT:MAG).
  PRINT "SRF VELOCITY....."+ROUND(SHIP:VELOCITY:SURFACE:MAG).
	PRINT " ".
  print "NAVPITCH....."+ROUND(NAVPITCH()).
  print "VECPITCH....."+ROUND(surfvecpitch()).
  PRINT " ".
	WAIT 0.01.
}.
FUNCTION SAVERUNMODE {
  log 0 to rm.ks.
  delete rm.ks.
  log "global runmode is "+runmode+"." to rm.ks.
}.
FUNCTION SAVERADAR {
  log 0 to ro.ks.
  delete ro.ks.
  LOG "global RADAROFFSET is "+radaroffset+"." TO ro.ks.
}.

print "TOOLBOX LOADED".

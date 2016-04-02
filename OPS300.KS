FUNCTION OPS301 {
	SET R TO SHIP:BODY:RADIUS.
	SET H1 TO (SHIP:apoapsis+SHIP:PERIAPSIS)/2.
	SET H2 TO (TARGET:APOAPSIS+TARGET:PERIAPSIS)/2.

}
WHEN Ship:altitude > 400 THEN {
	LOCK STEERING TO HEADING(h,85).
	SAS OFF.
	WHEN SHIP:ALTITUDE > 1000 THEN{
		LOCK STEERING TO HEADING(h,startang).
FUNCTION OPS998 { //ASCENT
	LOCK p TO ascpitch(startalt,endalt,startang,endang).
	Lock traj to heading(h,p).

	UNTIL RUNMODE > 102 {
		LOCK STEERING TO TRAJ.
		WAIT 0.01.
	}
	UNLOCK STEERING.
	UNLOCK P.
	UNLock traj.
	WAIT 0.01.
}
function ops999 { // final ascent
	lock traj to ship:prograde.
	until runmode > 103 {
		wait 0.01.
		until ship:PERIAPSIS > -30000 {
			wait 0.01.
			if eta:apoapsis > 40	{
				if eta:apoapsis > 60 {
					lock steering to traj+r(0,-30,0).
				}
				else if eta:apoapsis > 50 {

					lock steering to traj+r(0,-20,0).
				}
				else { lock steering to traj+r(0,-10,0). }.
			}
			else if eta:apoapsis < 30 {
				if eta:apoapsis < 10 {
					lock steering to traj+r(0,30,0).
				}
				else if eta:apoapsis < 20 {
					lock steering to traj+r(0,20,0).
				}
				else { lock steering to traj+r(0,10,0). }.
			}
			else {
				lock steering to traj.
			}.
		}
		lock steering to traj.
	}
	unlock traj.
	unlock steering.
}

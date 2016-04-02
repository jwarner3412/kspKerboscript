SET AP TO 1.
SET PE TO 2.
SET NOW TO 3.
SET TALT TO 1.
SET TPERIOD TO 2.
PARAMETER OPS, loc, unit, val.
run once ops200.
run once lib_com.
run once ro.
WAIT 0.0001.

	IF OPS = 201 {
		OPS201(loc).
	}
	else IF OPS = 202 {
		ops202(loc,unit,val).
	}
	else IF OPS = 221 {
		ops221().
	}
	else if ops = 299 {
		ops299().
		if defined radaroffset {land(radaroffset).}
	}
	else if ops = 300 {
		run once ro.
		land(radaroffset).
	}
	else if ops = 200 {
		checkin().
		wait 10.
	}.

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
RCS OFF.
SAS OFF.
PRINT "RETURNING CONTROL".
PRINT "PROGRAM COMPLETE".

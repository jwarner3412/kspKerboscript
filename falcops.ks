@lazyglobal off.
UNTIL runmode>199 {
	RUN ONCE OPS100.
	IF runmode = 101 {
		PRINT "OPS101".
		OPS101().
	}
	else IF runmode = 102 {
		PRINT "OPS102".
		OPS102().
	}
	IF runmode = 103 {
		PRINT "OPS103".
		OPS103().
	}
	IF runmode = 104 {
		PRINT "OPS104".
		OPS104().
	}
	IF runmode = 110 {
		PRINT "OPS110".
		OPS110().
	}
	if runmode = 0 {
		PRINT "RUNMODE=0".
		SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
		break.
	}
	wait 0.0001.
}
RUN ONCE OPS200.KS.
IF SSP = 1 and runmode = 200 {
	FOR FALC IN FALCPANEL {FALC:GETMODULE("MODULEDEPLOYABLESOLARPANEL"):DOEVENT("EXTEND PANELS").}
	SET SSP TO 0.
	PRINT "PANELS DEPLOYED".
}
until runmode > 299 {
	if runmode = 200{
		PRINT "PARKING ORBIT INJECTION BURN".
		IF PARKPERD > 1 {
			OPS202(AP,TPERIOD,PARKPERD).
		}
		ELSE IF PARKPE > 1 {
			OPS202(AP,TALT,PARKPE).
		}
		ELSE {OPS201(AP).}.
		global runmode is 201. log 0 to rm.ks. delete rm.ks. log "global runmode is "+runmode+"." to rm.ks.
	}
	else if runmode = 201 {
		IF DAP > 1 {
			PRINT "DEPLOYMENT ORBIT TRANSFER BURN".
			OPS202(NOW,TALT,DAP).
		global runmode is 202. log 0 to rm.ks. delete rm.ks. log "global runmode is "+runmode+"." to rm.ks.
		}
		else {global runmode is 211. log 0 to rm.ks. delete rm.ks. log "global runmode is "+runmode+"." to rm.ks.}.
	}
	else if runmode = 202 {
		PRINT "DEPLOYMENT ORBIT INJECTION BURN".
		IF DEPPER > 1 {
			OPS202(AP,TPERIOD,DEPPER).
		}
		ELSE IF DPE > 1 {
			OPS202(AP,TALT,DPE).
		}
		ELSE {OPS201(AP).}.
		global runmode is 211. log 0 to rm.ks. delete rm.ks. log "global runmode is "+runmode+"." to rm.ks.
	}
	else if runmode = 211 {
		OPS211().
		global runmode is 299. log 0 to rm.ks. delete rm.ks. log "global runmode is "+runmode+"." to rm.ks.
	}
	else if runmode = 299 {
		OPS299().
	}
	else if runmode = 0 {
		PRINT "RUNMODE=0".
		SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
		break.
	}.
	wait 0.0001.
}
until runmode > 399 {
	if runmode = 300 {
		if defined radaroffset {
			land(radaroffset).
		}
		else {
			global runmode is 0. log 0 to rm.ks. delete rm.ks. log "global runmode is "+runmode+"." to rm.ks.
		}.
	}
	else if runmode = 0 {
		PRINT "RUNMODE=0".
		SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
		break.
	}.
	wait 0.0001.
}
PRINT "RETURNING CONTROL".
PRINT "PROGRAM COMPLETE".

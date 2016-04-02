WAIT 5.
SET SASMODE TO "STABILITYASSIST".
//MISSION PARAMETERS - ASCENT
SET h to 90. 				// DESIRED LAUNCH HEADING
set endang to 0. 			// G TURN END ANG
SET ENDALT to 75000. 		// G TURN END ALT
set startalt to 1000.		// G TURN START ALT
set startang to 85.			// G TURN START ANG
SET BSTF TO 2300. 			// LIQ FUEL STAGE 1 TRIGGER
SET CD TO 5. 				// COUNTDOWN IN SECONDS
//TARGET PARK ORBIT OPTIONS
set parkap to 200000. 		// PARKING APOAPSIS*
set parkpe to 0. 			// PARKING PERIAPSIS - SET 0 FOR CIRC OR PERIOD
SET PARKPERD TO 0.			// PARK ORBIT PERIOD - SET 0 FOR CIRC OR PERIAPSIS
//TARGET PAYLOAD ORBIT OPTIONS
SET DAP TO 0.			// PAYLOAD DEPLOYMENT APOAPSIS
SET DPE TO 0.				// PAYLOAD DEPLOYMENT PERIAPSIS
SET DEPPER TO 0.				// PAYLOAD ORBIT PERIOD
//SHIP PAYLOAD OPTIONS
SET PAYLOAD TO 1.			// NUMBER OF PAYLOADS
SET PLCOMM TO FALSE.			// FOR PER DEPLOYMENT 1 PER ORBIT
SET FAIRING TO 0.			// ENABLES EXTRA STAGE EVENT
SET SSP TO 0.				// SECOND STAGE PANELS FOR GEO MISSIONS
//PART TAG INFOS
SET FALCPANEL TO SHIP:PARTSTAGGED("FALC_PANEL").
SET HEAVY TO 1.
SET FTANK TO SHIP:PARTSDUBBED("Ghidorah K1-180 Tank").

//ATMOSPHERE HEIGHTS FOR STEERING CORRECTIONS
SET ATMO1 TO 7000.
SET ATMO2 TO 20000.
SET ATMO3 TO 50000.
SET SPACE TO 70000.

SET AP TO 1.
SET PE TO 2.
SET NOW TO 3.
SET TALT TO 1.
SET TPERIOD TO 2.

copy boot_falc from 0.
COPY ops100 FROM 0.
COPY ops200 FROM 0.
copy lib_com FROM 0.
COPY falcops FROM 0.

PRINT "FILES COPIED FROM KSC".
PRINT "FLIGHT PARAMETERS SET".

if ship:status = "PRELAUNCH" {
  PRINT "LAUNCH PROGRAM STANDING BY".
  PRINT "CYCLE THROTTLE FOR COUNTDOWN FROM T-5".
  WAIT UNTIL SHIP:CONTROL:PILOTMAINTHROTTLE > 0.75.
  Print "LAUNCH INITIATED".
  SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
  global runmode is 101. log 0 to rm.ks. delete rm.ks. log "global runmode is "+runmode+"." to rm.ks.
}
else if ship:status = "landed" {
  global runmode is 0. log 0 to rm.ks. delete rm.ks. log "global runmode is "+runmode+"." to rm.ks.
}.
else if ship:status = "splashed" {
  global runmode is 0. log 0 to rm.ks. delete rm.ks. log "global runmode is "+runmode+"." to rm.ks.
}.
run rm.ks.
if defined runmode {RUN FALCOPS.} else { print "nothing to see here".}.
print "end boot".

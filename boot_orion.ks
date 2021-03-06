SET PLMASS TO 12.
SET RUNMODE TO 0.

ON ABORT {
	SET RUNMODE TO 198.
}.
WHEN SHIP:MASS<PLMASS THEN {
	SET RUNMODE TO 199.
}
FUNCTION OPS199 {
	WAIT 5.
	SAS OFF. RCS OFF. lights on.
	PANELS ON.
	SET RCS1 TO SHIP:PARTSDUBBED("LINEARRCS").
	SET COMMAND TO SHIP:PARTSDUBBED("ORION").
	FOR R IN RCS1 { R:GETMODULE("MODULERCS"):DOEVENT("ENABLE RCS PORT").}
	FOR C IN COMMAND { C:GETMODULE("MODULERCS"):DOEVENT("ENABLE RCS PORT").}
	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
}
WAIT UNTIL RUNMODE = 199.
OPS199().
SET RUNMODE TO 0.
PRINT "MISSION COMPLETE".
PRINT RUNMODE.
LOG "copy ops.ks from 0.
copy ops200.ks from 0." TO BOOT.KS.
run boot.ks.
WAIT 1.
DELETE BOOT_ORION.ks.
REBOOT.

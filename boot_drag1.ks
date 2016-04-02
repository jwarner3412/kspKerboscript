WAIT 5.
COPY lib_com FROM 0.
COPY ops200 from 0.
copy ops from 0.
copy boot_drag1 from 0.
run once lib_com.
SET RADAROFFSET TO 1. saveradar().
set vmass to 12.
SET COMMAND TO SHIP:PARTSDUBBED("Dragon").
command[0]:GETMODULE("MODULERCS"):DOEVENT("DISABLE RCS PORT").

run once lib_com.
until ship:mass < vmass {
  CHECKIN().
  WAIT 1.
}

SAS OFF. RCS OFF. lights on. PANELS ON.
FOR C IN COMMAND { C:GETMODULE("MODULERCS"):DOEVENT("ENABLE RCS PORT").}
SET ANTENNA TO SHIP:PARTSDUBBED("COMMUNOTRON 32").
FOR ANT IN ANTENNA {ANT:GETMODULE("MODULERTANTENNA"):DOEVENT("ACTIVATE").}

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
wait 60.
delete boot_drag1.
log "WAIT 1.
  copy lib_com from 0.
  copy ops200 from 0.
  copy ops from 0.
  set ship:control:PILOTMAINTHROTTLE to 0.
  run once lib_com.
  smartstage()." to boot_drag1.ks.
reboot.
PRINT "ENDBOOT".

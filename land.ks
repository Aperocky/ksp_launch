// Setup: Assuming ship is in LKO. The landing script should bring it down. No aim for now.

sas off.
set runmode to 1.

set periapsis_val to 40000.
set engine_present to False.
set drogue_chute to True.

clearscreen.

until runmode=0{

    if runmode=1{ // Aligning retrograde.
        set thrust to 0.
        lock steering to retrograde.
        if vang(ship:retrograde:forevector, ship:facing:forevector) < 0.25{
            set runmode to 2.  
        }
        if not engine_present{
            set runmode to 3.
        }
    }

    else if runmode=2{ // Reducing periapsis
        lock steering to retrograde.
        set max_acc to ship:maxthrust/ship:mass.
        set thrust to min(1, 5/max_acc).
        if ship:periapsis<periapsis_val{
            set thrust to 0.
            wait 1.
            stage.
            set runmode to 3.
        }
    }    

    else if runmode=3{ // Coast to atmosphere
        set thrust to 0.
        unlock steering.
        set warp to 3.
        if ship:altitude<70000{
            set warp to 0.
            wait 0.
            lock steering to retrograde.
            set runmode to 4.
        }
    }

    else if runmode=4{ // Coast to denser atmosphere
        set warp to 3.
        if ship:altitude<50000{
            lock steering to retrograde.
            set warp to 0.
            wait 0.
            set runmode to 5.
        }
    }

    else if runmode=5{ // Down to drogue chute range
        if ship:altitude<20000{
            if drogue_chute{
                stage.
                wait 0.
                set runmode to 6.
            }
            else{
                set runmode to 6.
            }
        }
    }

    else if runmode=6{ // Open main chute.
        if ship:altitude<13500{
            stage. 
            wait 0.
            unlock steering.
            set runmode to 7.
        }
    }

    else if runmode=7{
        set warp to 3.
        if alt:radar<40{
            set warp to 0.
            set runmode to 8.
        }
    }

    else if runmode=8{
        wait 10.
        set runmode to 0.
    }

    lock tval to thrust.
    lock throttle to tval.

    print "RUNMODE:    " + runmode + "      " at (5,4).
    print "ALTITUDE:   " + round(SHIP:ALTITUDE) + "  METERS    " at (5,5).
    print "APOAPSIS:   " + round(SHIP:APOAPSIS) + "  METERS    " at (5,6).
    print "PERIAPSIS:  " + round(SHIP:PERIAPSIS) + "  METERS    " at (5,7).
    print "SINK RATE:  " + round(SHIP:VERTICALSPEED) + "  M/S" at (5,10).
    print "GRND SPEED: " + round(SHIP:GROUNDSPEED*3.6) + "  KPH" at (5,11).

    wait 0.
}
clearscreen.
print "YOU HAVE LANDED, THANKS FOR USING ROCKY SYSTEM OF AUTOMATIC LANDING".

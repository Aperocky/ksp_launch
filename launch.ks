clearscreen.

// Put rocket in stable configuration
sas off.
rcs on.
gear off.
lock steering to up + r(0,0,-180).

// Default start
set runmode to 2.
if alt:radar < 100{
    set runmode to 1.
}
set targetalt to 90000.
set turnpoint to 100.

when stage:solidfuel<1 then {
    stage.
    wait 0.
}

when stage:liquidfuel<1 then {
    stage.
    wait 0.
}
// using runmodes - like apollo did 

until runmode=0 {

    // calculate current thrust and acc ratings
    set max_acc to ship:maxthrust/ship:mass+0.01.

    if runmode=1 { // LAUNCHPAD
        lock steering to up.
        set thrust to min(1, 25/max_acc).
        stage.
        set runmode to 2.
    } 

    else if runmode=2 { // STRAIGHT UP
        lock steering to up.
        set thrust to min(1, 25/max_acc).

        if ship:altitude>turnpoint {
            set runmode to 3.
        }
    }

    else if runmode=3 { // GRAVITY TURN 
        set pitch to max(25, 90*(1 - (ship:altitude-turnpoint)/45000)).
        lock steering to heading(90, pitch).
        set thrust to min(1, 25/max_acc).

        if ship:liquidfuel<0 {
            stage.
            wait 0.
        }
        if ship:apoapsis>targetalt{
            set thrust to 0.
            if ship:altitude>70000{
                set runmode to 5.
            } else {
                set runmode to 4.
            }
        }
    }

    else if runmode=4 { // COAST WITHIN ATMOSPHERE
        lock steering to heading(90, 3).
        set warp to 3.
        if ship:altitude>70000{
            set warp to 0.
            set runmode to 5.
        }
    }

    else if runmode=5 { // SPATIAL COASTING
        set runmode to 0.
    }

    set tval to thrust.
    lock throttle to tval.

    print "RUNMODE:    " + runmode + "      " at (5,4).
    print "ALTITUDE:   " + round(SHIP:ALTITUDE) + "  METERS    " at (5,5).
    print "APOAPSIS:   " + round(SHIP:APOAPSIS) + "  METERS    " at (5,6).
    print "PERIAPSIS:  " + round(SHIP:PERIAPSIS) + "  METERS    " at (5,7).
    print "ETA to AP:  " + round(ETA:APOAPSIS) + "  SECONDS    " at (5,8).
    print "CLIMB RATE: " + round(SHIP:VERTICALSPEED) + "  M/S" at (5,10).
    print "GRND SPEED: " + round(SHIP:GROUNDSPEED*3.6) + "  KPH" at (5,11).

    wait 0.
}

clearscreen.
run once circularize.
wait 1.
run once node_stage.

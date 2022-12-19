// INSTANTANEOUS LAUNCH WINDOW

parameter mode.		// 1-ship, 2-coordinates, 3-body

clearscreen.
local shipLat is ship:latitude.
local shipLng is ship:longitude.
local pLex is readjson("0:/params2.json").
local doIncChange is true.

set tgtOrb to pLex["tgtOrb"].
set tgtInc to pLex["tgtInc"].
set rendBool to pLex["rendBool"].

// CHOOSE MODE HERE
if (mode = 1) {	// FROM GROUND TO ORBIT
	// wait for correct time
	
	if (abs(abs(Azimuth(tgtInc, tgtOrb, true)) - (abs(tgtInc) + 90)) < 0.1) {	// wait when difference is > 0.1
		set doIncChange to false.
	}
	
}
else if (mode = 2) { // FROM ORBIT TO GROUND

	wait 0.
}
else { // FROM GROUND TO OTHER BODY
	
	wait 0.
}

// MAIN LOGIC
if (doIncChange) {
	WarpTmin(mode, 3.5 * 60).
}

function WarpTmin {	// warps to correct time
	parameter mode, adv is 0.	// 1-ship, 2-coordinates, 3-body | advance
	
	if (mode = 1) {
		BetterWarp(TimeToTgtNode(shipLat, shipLng) - adv).
	}
	
}
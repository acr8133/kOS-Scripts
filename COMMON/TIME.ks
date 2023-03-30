// INSTANTANEOUS LAUNCH WINDOW

parameter mode.		// 1-ship, 2-coordinates, 3-aop, 4-body

clearscreen.
local shipLat is ship:latitude.
local shipLng is ship:longitude.
local pLex is readjson("0:/params2.json").
local doIncChange is true.

set tgtOrb to pLex["tgtOrbPE"].
set tgtInc to pLex["tgtInc"].
set tgtLan to pLex["tgtLan"].
set tgtAop to pLex["tgtAop"].

// set rendBool to pLex["rendBool"].

// CHOOSE MODE HERE
if (mode = 1) {	// FROM GROUND TO ORBIT
	// wait for correct time

	if (tgtLan:istype("boolean")) {
		if (tgtLan) { set doIncChange to false. }
	}
}
else if (mode = 2) { // FROM ORBIT TO GROUND

	wait 0.
}
else if (mode = 3) { // FROM ORBIT TO ORBIT

	wait 0.
}
else { // FROM GROUND TO OTHER BODY
	
	wait 0.
}

// MAIN LOGIC
if (doIncChange) {
	WarpTmin(mode, 3.5 * 60).
}
else { missionGUI:hide(). }

function WarpTmin {	// warps to correct time
	parameter mode, adv is 0.	// 1-ship, 2-coordinates, 3-body | advance
	
	if (hasTarget) {
		if (mode = 1) {
			BetterWarp(TimeToTgtNode(shipLat, shipLng)[0] - adv, true).
		}	
	}
	else {
		BetterWarp(TimeToTgtNode(shipLat, shipLng, false, tgtInc, tgtLan)[0] - adv, true).
	}

	missionGUI:hide().
}
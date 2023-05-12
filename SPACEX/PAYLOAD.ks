local shipLat is ship:latitude.
local shipLng is ship:longitude.
local initMass is ship:mass.
local flightSave is lexicon().

set throt to 0.	// invokable error when declared local
lock throttle to throt.
local tgtPitch is 90.
local tgtRotation is 0.
set steeringmanager:rollts to 20.
set steeringmanager:rolltorquefactor to 3.

local fairingDep is false.

runoncepath("0:/SPACEX/GUI_2").	// take out of boot, only for debug
runoncepath("0:/SPACEX/PARAM", 2).
runoncepath("0:/COMMON/GNC").
local pLex is readjson("0:/params2.json").
runoncepath("0:/COMMON/TIME", 1).

local tgtOrbAP is pLex["tgtOrbAP"].
local tgtOrbPE is pLex["tgtOrbPE"].
local tgtAlt is pLex["tgtAlt"].
local tgtInc is pLex["tgtInc"].
local tgtLan is pLex["tgtLan"].
local tgtAop is pLex["tgtAop"].
local pitchGain is pLex["pitchGain"].
local MECOangle is pLex["MECOangle"].
local tanAlt is pLex["tanAlt"].
local landProfile is pLex["landProfile"].
local payloadType is pLex["payloadType"].
local maxPayload is pLex["maxPayload"].
local payloadMass is pLex["payloadMass"].
local fairingSepAlt is pLex["fairingSepAlt"].
local atmHeight is pLex["atmHeight"].
local rndBool is pLex["rndBool"].

local tgtAzimuth is 0.
if (tgtInc > 180 or (tgtInc < 0 and tgtInc > -180)) {

	set tgtAzimuth to Azimuth(-tgtInc, tgtOrbPE, false, true).
	if (tgtLan:istype("scalar") and tgtLan > 180) {
		set tgtAzimuth to Azimuth(tgtInc, tgtOrbPE, false, true).
	}
} 
else {
	set tgtAzimuth to Azimuth(-tgtInc, tgtOrbPE, false, false).
	if (tgtLan:istype("scalar") and tgtLan > 180) {
		set tgtAzimuth to Azimuth(tgtInc, tgtOrbPE, false, true).
	}
}

flightSave:add("tgtAzimuth", tgtAzimuth).
local padPos is ship:position.
flightSave:add("padPos", padPos).

local MECOangleOffset is 0.
local localg is body:mu / body:position:sqrmagnitude.
lock currTWR to ship:availablethrust / (ship:mass * localg).

local skipAscent is false.
local activeEngine is 0.
list engines in engList.
for eng in engList {
	if (eng:ignition) { set activeEngine to eng. }
}
if not (activeEngine = 0) {
	if (activeEngine:visp > 340) { set skipAscent to true. }		// LAZY WAY TO CHECK IF WE'RE IN MVAC	
}
wait 1.
clearscreen.

if not (skipAscent) {
	Liftoff().
	Ascent(0).
	if (landProfile = 4 or landProfile = 5) { BECO(). }
	if (landProfile > 3 and landProfile < 6) { Ascent(1). }
	MECO().
}
BurnToApoapsis().
Circularization().
if (tgtAop:istype("scalar")) { MatchSMA(). }

clearScreen.

// set target to Didymos.
// run sc_gnc.
// SepSeq().

if not (rndBool = "") {
	set target to rndBool.
	
	MatchPlanes().
	Circularization(min(ship:altitude + 50, ship:apoapsis), true).
	RaiseOrbit(1, PhaseTime(), true).
	Circularization(ship:apoapsis - 1, true).	// will break on higher than target orbit
	Docking().
}

set core:bootfilename to "".	// stops the core from waking up on reload

function Liftoff {
	EngSpl(1). wait 0.5. sas off. SafeStage().
}

function Ascent {
	parameter ascentMode.
	local rotateOffset is 0.
	local ApAdd is 0.

	// throttle
	local initTWR is currTWR.
	local angThr is 0.
	if (ascentMode = 1 or landProfile = 6) { set throt to 1. }
	else { 
		lock angThr to 90 - vang(ship:up:vector:normalized, ship:facing:forevector).
		lock throt to 1. wait until ship:verticalspeed > 10.
		local throtPld is (maxPayload - payloadMass) / 35000.
		lock throtLim to ((max(0, (90 - (MECOangle * 0.45)) - angThr) / 90) * (3 + throtPld)).
		lock throtAdd to ((max(0, (90 - (MECOangle * 0.55)) - angThr) / 90) * 3.1).
		lock throt to (1 - throtLim) + throtAdd.
	}

	local baseThrust is ship:availablethrust.
	local currentThrust is baseThrust.
	lock currentThrust to ship:availablethrust.

	// pitch and rotation
	lock steering to lookdirup(
		heading(tgtAzimuth, tgtPitch):vector,
		(heading(180, 0):vector * ((180 + tgtRotation) / 180)) +
		(vcrs(heading(tgtAzimuth, tgtPitch):vector,
			heading(tgtAzimuth, 0):vector) * (abs(tgtRotation) / 180))
	).

	// until false { print throt at (0, 0). print throtLim at (0, 1). }

	if (landProfile > 3) { set rotateOffset to -90. }
	if (ascentMode = 0) {	// first part of ascent
		if (landProfile = 3 or landProfile = 6) {
			until (currentThrust <= (baseThrust * 0.5)) { wait 0.
				set tgtPitch to 
					max(90 * (1 - (ship:altitude / 
						(tgtAlt * (pitchGain / 100))
					)), 0).
				if ((payloadType = 2 or payloadType = 3 or landProfile > 3) and 
					abs(tgtRotation) < (180) and 
					ship:altitude > 1000) { // dragon rotation
					set tgtRotation to tgtRotation - (0.2 * NodeSignEquator()).
				}
			}
		}
		else {
			until (ship:apoapsis > tgtAlt) { wait 0.
				set tgtPitch to 
					max(90 * (1 - (ship:altitude / 
						(tgtAlt * (pitchGain / 100))
					)), MECOangle).
				if ((payloadType = 2 or payloadType = 3 or landProfile > 3) and 
					abs(tgtRotation) < (180) and 
					ship:altitude > 1000) { // dragon rotation
					set tgtRotation to tgtRotation - (0.2 * NodeSignEquator()).
				}
			}
		}
	}
	else { // second part of ascent ( heavy core )
		
		local heavyAlt is ((tgtAlt + ApAdd) * 0.7) + (tgtOrbPE * 0.3).
		if (landProfile = 5) {
			until (currentThrust <= (baseThrust * 0.5)) { wait 0.
				set tgtPitch to 
					min(max(
					(90 * (1 - ship:altitude /
					(((tgtAlt + tgtOrbPE) / 2) * (pitchGain / 200))
					))
					, 1), MECOangle).
			}
		}
		else {
			until (ship:apoapsis > heavyAlt) { wait 0.
				set tgtPitch to 
					min(max(
					(90 * (1 - ship:altitude /
					(((tgtAlt + tgtOrbPE) / 2) * (pitchGain / 200))
					))
					, MECOangle - MECOangleOffset), MECOangle).
			}
		}
	}

	flightSave:add("tgtRotation", tgtRotation).
}

function BECO {
	set MECOangleOffset to 10.
	
	lock steering to lookdirup(
		heading(tgtAzimuth, tgtPitch):vector,
		(heading(180, 0):vector * ((180 + tgtRotation) / 180)) +
		(vcrs(heading(tgtAzimuth, tgtPitch):vector,
			heading(tgtAzimuth, 0):vector) * (abs(tgtRotation) / 180))
	).
		
	EngSpl(0.5).
	toggle AG3.
	writejson(flightSave, "0:/params4.json").
	flightSave:remove("tgtRotation").
	wait 1.5. SafeStage(). wait 1.5.
}

function MECO {
	EngSpl(0).
	if (landProfile = 3 or landProfile > 4) {
		lock steering to lookdirup(
			heading(tgtAzimuth, tgtPitch):vector,
			(heading(180, 0):vector * ((180 + tgtRotation) / 180)) +
			(vcrs(heading(tgtAzimuth, tgtPitch):vector,
				heading(tgtAzimuth, 0):vector) * (abs(tgtRotation) / 180))
		).
	}
	else {
		lock steering to lookdirup(
			heading(tgtAzimuth, tgtPitch):vector,
			(heading(180, 0):vector * ((180 + tgtRotation) / 180)) +
			(vcrs(heading(tgtAzimuth, tgtPitch):vector,
				heading(tgtAzimuth, 0):vector) * (abs(tgtRotation) / 180))
		).
	}

	writejson(flightSave, "0:/params3.json").
	wait 1.5. SafeStage(). 
    core:part:controlfrom(). 
	wait 1.5. rcs on.
}

function BurnToApoapsis {
	EngSpl(0.15, true). rcs on.
	wait 5. EngSpl(1).
	if (landProfile = 4) { set fairingSepAlt to tanAlt. }

	lock throt to min(
        max(0.1, (tgtOrbPE - ship:apoapsis) / (tgtOrbPE - atmHeight)) + 
        max(0, ((30 - eta:apoapsis) * 0.075))
    , 1).

	lock steering to lookdirup(
		heading(tgtAzimuth, tgtPitch):vector,
		(heading(180, 0):vector * ((180 + tgtRotation) / 180)) +
		(vcrs(heading(tgtAzimuth, tgtPitch):vector,
			heading(tgtAzimuth, 0):vector) * (abs(tgtRotation) / 180))
	).
		
	until (ship:apoapsis > tgtOrbPE) {
		local avoidFireDeath is 5 * max(0, ((30 - eta:apoapsis) * 0.075)).
        set tgtPitch to
            min(max(
            (90 * (1 - ship:altitude / tanAlt)), 
            0.1) + avoidFireDeath, (MECOangle)).
			
		if (payloadType = 1 or payloadType > 3) {
			if (ship:altitude > fairingSepAlt and fairingDep = false) {
				SafeStage(). set fairingDep to true.}
		}
	}
	
	EngSpl(0).
	lock steering to lookdirup(
		ship:prograde:vector,
		(heading(180, 0):vector * ((180 + tgtRotation) / 180)) +
		(vcrs(heading(tgtAzimuth, tgtPitch):vector,
			heading(tgtAzimuth, 0):vector) * (abs(tgtRotation) / 180))
	).
	wait until ship:altitude > atmHeight. wait 3. rcs off.
	steeringmanager:resettodefault().
}

function Circularization {
	parameter circHeight is tgtOrbPE, isRCS is false.

	set circNode to VecToNode(Hohmann(1, circHeight), time:seconds + TimeToAltitude(circHeight)).
	add circNode.
	
	if (isRCS) { ExecNode(false, 10, true, 3). }
	else { ExecNode(). }
}

function SepSeq {
	SafeStage(). wait 10.
	
	if (payloadType = 3) {	// left over code for old cargo dragon?
		SafeStage(). wait 3.
		panels on. rcs off.
	} 
	else if (payloadType = 2) {
		lights on. AG4 on. toggle AG5.
		wait 5.
		
		lock steering to lookdirup(     // point panels away from body
			ship:prograde:vector,
			vcrs(ship:prograde:vector, -body:position)).
	}
}

function MatchPlanes {
	local tNode to TimeToNodeTarget().
	local nodeAlt is NodeAltitude(tNode).
	local correctTimeToAlt is 0.
	
	local t1 is TimeToAltitude(nodeAlt - 0.0001, 1).
	local t2 is TimeToAltitude(nodeAlt - 0.0001, 2).
		
	local corTime is 0.
	if (t1 < 0) { set corTime to t2. }
	else if (t2 < 0) { set corTime to t1. }
	else { set corTime to min(t1, t2). }
	
	local planeCircVec is Hohmann(1, nodeAlt) + PlaneMnv().
	
	set matchNode to VecToNode(planeCircVec, time:seconds + corTime).
	add matchNode.
	ExecNode(false, 10, true, 3).
}

function MatchSMA {
	RaiseOrbit(2, TimeToAoP(tgtAop), false, tgtOrbAP, (ship:apoapsis + ship:periapsis) / 2).
}

function RaiseOrbit {
	parameter mode, mnvTime, isRCS is false, APalt is 0, PEalt is 0.

	if (mode = 1) {
		set raiseNode to VecToNode(Hohmann(2, 0, 0, 0, mnvTime), time:seconds + mnvTime).
		add raiseNode.
	}
	else {
		set raiseNode to VecToNode(Hohmann(2, 0, APalt, PEalt, mnvTime), time:seconds + mnvTime).
		add raiseNode.
	}

	if (isRCS) { ExecNode(false, 10, true, 3). }
	else { ExecNode(). }
}

function Docking {

	set ship:control:neutralize to true.
	steeringmanager:resettodefault().
	set steeringmanager:maxstoppingtime to 0.05.
    rcs on. sas off.
	
	until false {
		
		DockGNC(1, 150, 10).
		wait 0.
	}

	lock steering to lookdirup(
		-1 * targetPort:portfacing:vector,
		vcrs(ship:prograde:vector, body:position)).
	CloseIn(1.5, 0.75).    // docking magnet capture
	HaltDock().
	unlock steering.
	sas on. rcs off.
	reboot.
}

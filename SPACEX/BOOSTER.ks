clearscreen.
local padPos is ship:position.
local rotOffset is 0.
local overshootCoords is 0.
local overshootVector is v(0,0,0).
local reduceLateral is v(0,0,0).
local osGain is 1.
local forceThree is false.
local initVec is ship:facing:forevector.
local flipVec is ship:facing:forevector.

WaitForSep().
runoncepath("0:/COMMON/GNC").

local pLex is readjson("0:/params2.json").
local flightSave is lexicon().
if (core:tag = "2" or core:tag = "3") {
	set flightSave to readjson("0:/params4.json").
}
else {
	set flightSave to readjson("0:/params3.json").
}

local landProfile is pLex["landProfile"].
local maxPayload is pLex["maxPayload"].
local MECOangle is pLex["MECOangle"].
local payloadMass is pLex["payloadMass"].
local reentryHeight is pLex["reentryHeight"].
local reentryVelocity is pLex["reentryVelocity"].

local tgtAzimuth is flightSave["tgtAzimuth"].
local tgtRotation is flightSave["tgtRotation"].

local LZ is 0.
if (landProfile = 1 or core:tag = "3") { 
	set LZ to pLex["LZ1"].
}
else if (core:tag = "2") {
	set LZ to pLex["LZ2"].
}
else { set LZ to pLex["LZ0"].  }

set throt to 0.
lock throttle to throt.

if (landProfile = 6) { shutdown. }

PIDsetup().

if (landProfile = 1 or 
	((core:tag = "2" or core:tag = "3") and 
	(landProfile = 4 or landProfile = 5))) {
	Flip1(180, 0.333).
	Boostback().
	Flip2(60, 0.0667).
	Reentry1(60).
}
else {
	Flip1(170, 0.333).
	Boostback(5).
	Flip2(45, 0.075).
	Reentry1(45).
}

AtmGNC().
Land().	

// LANDING FOR HEAVY BOOSTERS ARE BROKEN
AG10 off.
shutdown.
set core:bootfilename to "".	// stops the core from waking up on reload

function WaitForSep {
	local coreList is list().
	list processors in coreList.
	local initCoreCount is coreList:length.
	local currCoreCounts is initCoreCount.

	list engines in engList.
	local currEngCounts is engList:length.

	until (
		(core:tag = "1" and currEngCounts = 2) or
		((core:tag = "2" or core:tag = "3") and currCoreCounts = 1)
	) {
		set initVec to ship:facing:forevector.
		set flipVec to ship:facing:forevector.
		list processors in coreList.
		set currCoreCounts to coreList:length.
		list engines in engList.
		set currEngCounts to engList:length.
		wait 0.1.
	}

	print "here".
	core:part:controlfrom().
	wait 2.
}

function Flip1 {
	parameter finalAttitude, flipPower.
	
	// flip preparation
	kuniverse:timewarp:cancelwarp().
	set steeringmanager:maxstoppingtime to 3. rcs on.
	set steeringmanager:pitchts to (steeringmanager:pitchts * 1.5).
	set steeringmanager:yawts to (steeringmanager:yawts * 1.5).
	set steeringmanager:pitchpid:ki to (steeringmanager:pitchpid:ki * 1.5).
	set steeringmanager:yawpid:ki to (steeringmanager:yawpid:ki * 1.5).
	set steeringmanager:rolltorquefactor to 3.
	set steeringmanager:rollcontrolanglerange to 45.

	lock steering to lookdirup(
		heading(tgtAzimuth, MECOangle):vector,
		(heading(180, 0):vector * ((180 + tgtRotation) / 180)) +
		(vcrs(heading(tgtAzimuth, MECOangle):vector,
			heading(tgtAzimuth, 0):vector) * (abs(tgtRotation) / 180))
	).

	wait 2.
    EngSwitch(0, 1).
    unlock steering.

	// HEAVY BOOSTER ORIENTATION AFTER BECO
	
	// flip sequence
	local rotateOffset is 45.
	local tangentVector is vxcl(up:vector, srfretrograde:vector:normalized):normalized.
	local rotateVector is vcrs(tangentVector, body:position:normalized):normalized.
	local finalVector is (-tangentVector * angleAxis(finalAttitude, rotateVector)):normalized.

	lock steering to lookdirup(flipVec, -rotateVector).

	if (core:tag = "2" or core:tag = "3") {
		local startT is time:seconds.
		local timer is startT + 2.
		wait until (vang(ship:facing:topvector, vxcl(ship:facing:forevector, -rotateVector)) < 1 and time:seconds > timer).
	}
	
	// when (vang(finalVector, flipVec) < MECOangle + 60) then { EngSpl(0.25). }
	// when (vang(finalVector, flipVec) < MECOangle + 30) then { EngSpl(0). }

	until (vang(finalVector, flipVec) < 25) { wait 0.
		if (vang(ship:facing:forevector, flipVec) < 7.5) {
			set flipVec to flipVec * angleAxis(flipPower, rotateVector).
		}
	}
	// EngSpl(0.5).
	
	until (vang(finalVector, flipVec) < 15) { wait 0.
		set flipVec to flipVec * angleAxis(flipPower, rotateVector).
	}
	set rotateOffset to finalAttitude.
	set flipVec to -tangentVector * angleAxis(rotateOffset, rotateVector).
	
	if (core:tag = "2" or core:tag = "3") { toggle AG3. }

	lock steering to lookdirup(flipVec, -rotateVector).

    EngSpl(1).
}

function Boostback {
	parameter rotateOffset is 0.

	if (rotateOffset > 0) { set rotOffset to rotateOffset. }	// pass rotateOffset value to flip function

	steeringmanager:resettodefault().
	set steeringmanager:maxstoppingtime to 15.
	set steeringmanager:rollts to 20.
	
	local tangentVector is vxcl(up:vector, srfretrograde:vector):normalized.
	local rotateVector is vcrs(tangentVector, body:position:normalized):normalized.

    clearscreen. rcs off.
	// print LZVel:mag at (0, 1).
	
	// CANCEL EXCESS RETROGRADE VELOCITY
	if (landProfile = 1 or core:tag = "2" or core:tag = "3") { 
		lock steering to lookdirup(
        	vxcl(up:vector, ship:srfretrograde:vector:normalized):normalized *
			angleAxis(0, ship:facing:topvector), -rotateVector).

		wait until vxcl(up:vector, ship:srfretrograde:vector:normalized):mag <= 0.03.	
	} 
	else {
		lock steering to lookdirup(
        	vxcl(up:vector, ship:srfretrograde:vector:normalized):normalized *
			angleAxis(rotateOffset, ship:facing:topvector), -rotateVector).
	}

	EngSpl(1). rcs on.

	// MANEUVER TOWARDS LZ
	// HUGE CODE SLOW DOWN, FIX!
	if (landProfile = 1 or core:tag = "2" or core:tag = "3") {
		lock throt to min(max(0.125, Impact(1, landProfile, LZ) / 2), 1).
		lock BBvec to vxcl(up:vector, LZ:altitudeposition(ship:altitude)):normalized.
		lock steering to lookdirup(BBvec, ship:facing:topvector).

		local landingOvershoot is 0 * 1000 - ((maxPayload - payloadMass) / 7).
		local impDist is Impact(1, landProfile, LZ).
		local intDist is impDist.
		
		until (impDist < landingOvershoot) {
			local bodPos is body:position.
			local landAngle is vang(bodPos, vxcl(rotateVector, Impact(0, landProfile, LZ):position)).
			local LZAngle is vang(bodPos, vxcl(rotateVector, LZ:position)).
			local isTooFar is landAngle > LZAngle.
			if (isTooFar) { set impDist to -Impact(1, landProfile, LZ). }
			else { set impDist to Impact(1, landProfile, LZ). }
			
			wait 0.
			set throt to max(0.25, impDist / intDist).
		}
	} 
	else {
		local tempLZ is LZ.
		local landingOvershoot is 0 * 750.
		set LZ to body:geopositionof(LZ:position + ((padPos - LZ:position):normalized * -landingOvershoot)).
		local intDist is Impact(1, landProfile, LZ).

		until ((Impact(0, landProfile, LZ):position - padPos):mag < (LZ:position - padPos):mag) { 
			wait 0.
			set throt to max(0.125, (Impact(1, landProfile, LZ) / intDist)).
		}
		set LZ to tempLZ.
		
		lock steering to lookdirup(
        	vxcl(up:vector, ship:srfretrograde:vector:normalized):normalized *
			angleAxis(rotateOffset, ship:facing:topvector), -rotateVector).
	}

    EngSpl(0).
	wait 1.
	
	steeringmanager:resettodefault().
}

function Flip2 {
	parameter finalAttitude, flipPower.
	// parameters x,y,z -  counter at z, stop at y, at power x
	
	// flip preparation
	set steeringmanager:maxstoppingtime to 20.
	set steeringmanager:rollts to 20.
	set steeringmanager:rolltorquefactor to 0.5.

    wait 2. unlock steering.
	
	// flip sequence
	local tangentVector is vxcl(up:vector, srfretrograde:vector:normalized):normalized.
	local initVec is -tangentVector.	// cache the negative tangent vector
	local flipVec is initVec.
	local rotateVector is vcrs(tangentVector, body:position:normalized):normalized.
	local finalVector is (initVec * angleAxis(180 - finalAttitude, rotateVector)):normalized.
	
	if (landProfile = 1 or core:tag = "2" or core:tag = "3") {
		lock steering to lookdirup(flipVec, rotateVector).
		
		when (vang(up:vector, ship:facing:forevector) < 15) then { brakes on. }
		until (vang(finalVector, flipVec) < 1) { wait 0.
			set flipVec to flipVec * angleAxis(flipPower, rotateVector).
		}
		set flipVec to initVec * angleAxis(180 - finalAttitude, rotateVector).

		lock steering to lookdirup(
			heading(tgtAzimuth, finalAttitude):vector,
			heading(90 + tgtAzimuth, 0):vector).
	} 
	else {
		
		set flipVec to flipVec * angleAxis(-rotOffset, rotateVector).
		set flipVec to -flipVec.
		
		lock steering to lookdirup(flipVec, -rotateVector).
		
		until (vang(finalVector, flipVec) < 1) { wait 0.
			set flipVec to flipVec * angleAxis(-flipPower, rotateVector).
		}
		set flipVec to tangentVector * angleAxis(finalAttitude, -rotateVector).

		brakes on.
		lock steering to lookdirup(
			heading(180 + tgtAzimuth, finalAttitude):vector,
			heading(90 + tgtAzimuth, 0):vector).
	}
	
	wait 10.
	steeringmanager:resettodefault().
	sas on.
	unlock steering.
}

function Reentry1 {
	parameter holdAngle.

	local rtrDiff is 90 - vang(ship:up:vector:normalized, ship:srfretrograde:vector:normalized).
	until (rtrDiff >= holdAngle) { wait 0.
		set rtrDiff to 90 - vang(ship:up:vector:normalized, ship:srfretrograde:vector:normalized).
	}
	steeringmanager:resettodefault().
	sas off.
	
	if (landProfile = 4 and core:tag = "1") { 
		set reentryHeight to reentryHeight + 5000.
		set reentryVelocity to reentryVelocity * 1.5.
	}
	
	lock steering to lookdirup(
		ship:srfretrograde:vector:normalized, 
		heading(180, 0):vector).
		
	wait until alt:radar < (reentryHeight + ((maxPayload - payloadMass) / 7)).

	EngSpl(1).
	toggle AG2.
	
	wait until ship:airspeed < (reentryVelocity - ((maxPayload - payloadMass) / 35)).
	EngSpl(0).
}

function AtmGNC {
	// if (landProfile < 3) { EngSwitch(1, 2). }
	// FIX REENTRY DISTANCE-VELOCITY FUEL BALANCE.
	EngSwitch(1, 2).
	
	local downRange is 0.
	lock downRange to Impact(1, landProfile, LZ).
	
	lock LATvector to vxcl(up:vector, (
		latlng(ship:geoposition:lat - 0.01, ship:geoposition:lng):position
		)):normalized.
		
    lock LNGvector to vxcl(up:vector, (
		latlng(ship:geoposition:lat, ship:geoposition:lng + 0.01):position
		)):normalized.
		
	lock RTRvector to ship:srfretrograde:vector:normalized.

	local initAlt is ship:altitude.
	local finalAlt is initAlt - 7500.
	lock lerpToSetpoint to (initAlt - min(initAlt, max(finalAlt, ship:altitude))) / (initAlt - finalAlt).

	AlatPID:reset(). AlngPID:reset().

	lock overshootVector to (LZ:altitudeposition(0) - ship:geoPosition:altitudeposition(0)).

	lock overshootCoords to ship:body:geopositionof(
		LZ:altitudeposition(0) + 
		overshootVector
	).

	lock reduceLateral to vcrs(body:position, vxcl(up:vector, overshootVector:normalized)):normalized.

	lock steering to lookdirup(
		(
			RTRvector +
			((	// STAR
				ship:facing:starvector *
				(ship:facing:starvector *
				((vcrs(RTRvector, LNGvector) * AlatOut * lerpToSetpoint) +
				(vcrs(RTRvector, LATvector) * AlngOut * lerpToSetpoint)))
			)
			+
			(	// TOP
				ship:facing:topvector *
				(ship:facing:topvector *
				((vcrs(RTRvector, LNGvector) * AlatOut * lerpToSetpoint) +
				(vcrs(RTRvector, LATvector) * AlngOut * lerpToSetpoint)))
			))
			-
			(
				0.5 * reduceLateral *
				(reduceLateral *
				((vcrs(RTRvector, LNGvector) * AlatOut * lerpToSetpoint) +
				(vcrs(RTRvector, LATvector) * AlngOut * lerpToSetpoint)))
			)
		),
		LATvector
	).

	rcs on. when (ship:altitude < 11000) then { rcs off. } 
	
	local isCoreBooster is 1.	// for correct engine selection
	if (core:tag = "2" or core:tag = "3") {
		set isCoreBooster to 0.
	}

	// set forceThree to true.
	if (payloadMass > maxPayload or landProfile > 3) { set forceThree to true. }
	local thrustGain is 1.
	if (landProfile > 3 or forceThree) { set thrustGain to 1.5. }

	list engines in engList.
	local eng is engList[isCoreBooster].
	local mFlowRate is eng:availablethrustat(1) / (eng:ispat(1) * constant:g0).
	local timestep is 1.
	local startT is time:seconds.
	local deltaT is 0.
	local bodRad is body:radius.

	until false {
		// set startT to time:seconds.

		local overshootQ is max(0, min(0.5, ship:q - 0.15)).
		local altvelOS is overshootAlt + overshootQ.
		set AlatPID:setpoint to ((1 - altvelOS) * LZ:lat) + (altvelOS * overshootCoords:lat).
		set AlngPID:setpoint to ((1 - altvelOS) * LZ:lng) + (altvelOS * overshootCoords:lng).

		// local futureTime is time:seconds + deltaT.
		// local futureAlt is (body:position - positionAt(ship, futureTime)):mag - bodRad.
		// local futureVel is velocityAt(ship, futureTime):surface:mag.

		if (IntegLand(
			alt:radar, 
			ship:verticalspeed, 
			isCoreBooster,
			mFlowRate,
			eng,
			thrustGain, 
			Impact(1, landProfile, LZ), 
			0.2)
		) { break. }

		// set deltaT to time:seconds - startT.
		// set timestep to deltaT.
	}
}

function Land {

	when (alt:radar < 200) then { gear on. }
	when (ship:verticalspeed > -20) then { set RTRvector to up:vector. }
	
	set throt to 1. rcs on.
	lock steering to lookdirup(
		srfretrograde:vector, 
		LATvector).
	
	local doThreeEngines is false.
	if ((landProfile > 3  or forceThree) and LandThrottle() > 1) { wait 1. EngSwitch(2, 1). set doThreeEngines to true. }
	
	HlatPID:reset(). HlngPID:reset().
	lock steering to lookdirup(
		(
			RTRvector +
			((vcrs(RTRvector, LNGvector) * -HlatOut) +
			(vcrs(RTRvector, LATvector) * -HlngOut)
				* ((throt + max(min((250 - abs(ship:verticalspeed)) / 83.333, 2), 0)) / 3)
			)
		),
		LATvector
	).
	
	if (doThreeEngines) { 
		// wait until LandThrottle() < 0.333.
		wait until ((landProfile > 3 or forceThree) and LandThrottle() < 0.333). 
		EngSwitch(1, 2).
	}
	lock throt to LandThrottle().
	
	wait until ship:verticalspeed > -5.
	lock throt to 1.2 * ((ship:mass * 9.81) / max(ship:availablethrust, 0.001)).

	wait until ship:status = "LANDED".

	local throttleDamper is 1.
	until false { wait 0.
		set throt to throttleDamper * ((ship:mass * 9.81) / max(ship:availablethrust, 0.001)).
		set throttleDamper to throttleDamper - 0.025.

		if (throt < 0.2) { break. }
	}
	
	rcs off. set throt to 0.
	wait until false.
}

function PIDsetup {
	global atmPID is list(45, 1.65, 3.25, tan(10)).
	global hvrPID is list(300, 75, 205, tan(15)).

	set lerpToSetpoint to 0.
	set osGain to 1.667.

	// if (landProfile = 1 or core:tag = "2" or core:tag = "3") {
	lock overshootAlt to max(0, min(0.5, (max(0, alt:radar - 6000) / 100000) ^ 0.38)).
	// } 
	// else {
	// 	lock overshootAlt to max(0.333, min(1, max(0, ship:q - 0.3) * osGain)).
	// }

	set overshootCoords to ship:body:geopositionof(
		LZ:altitudeposition(0) - ship:geoPosition:altitudeposition(0)
	).

	set AlatPID to pidloop(atmPID[0], atmPID[1], atmPID[2], -atmPID[3], atmPID[3]).
	set AlngPID to pidloop(atmPID[0], atmPID[1], atmPID[2], -atmPID[3], atmPID[3]).

	lock AlatOut to AlatPID:update(time:seconds, Impact(0, landProfile, LZ):lat).
	lock AlngOut to AlngPID:update(time:seconds, Impact(0, landProfile, LZ):lng).

	set HlatPID to pidloop(hvrPID[0], hvrPID[1], hvrPID[2], -hvrPID[3], hvrPID[3]).
	set HlatPID:setpoint to LZ:lat.	
	
	set HlngPID to pidloop(hvrPID[0], hvrPID[1], hvrPID[2], -hvrPID[3], hvrPID[3]).
	set HlngPID:setpoint to LZ:lng.

	lock HlatOut to HlatPID:update(time:seconds, 
		((body:geoPositionof(body:position:normalized * ship:altitude):lat * 0.2) + 
		(Impact(0, landProfile, LZ):lat * 0.8))).
	lock HlngOut to HlngPID:update(time:seconds, 
		((body:geoPositionof(body:position:normalized * ship:altitude):lng * 0.2) + 
		(Impact(0, landProfile, LZ):lng * 0.8))).

}

function EngSwitch {
    parameter fromEng, toEng.

    until (fromEng = toEng) {
        set fromEng to fromEng + 1.
        if (fromEng > 2) {
            set fromEng to 0.
        }
        wait 0.
        toggle AG1.
    } 
}

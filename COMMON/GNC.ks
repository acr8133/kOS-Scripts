// This software includes code from KSLib, which is licensed under the MIT license. Copyright (c) 2015-2020 The KSLib team

// ORBIT ANALYTICAL MATHS

function Azimuth {				// azimuth heading for given inclination and target orbit altitude
    parameter tInc, orbitAlt, raw is false, autoSwitch is false.

    local shipLat is ship:latitude.
	local rawHead is 0.		// azimuth without auto switch
    if abs(tInc) < abs(shipLat) { set tInc to shipLat. }
	if (tInc > 180) { set tInc to -360 + tInc. }
	if (tInc < -180) { set tInc to 360 + tInc. }
	if hasTarget { set autoSwitch to true. }

    local head is arcsin(max(min(cos(tInc) / cos(shipLat), 1), -1)).
	set rawHead to head.
	
	if (autoSwitch) {
		if NodeSignTarget() > 0 { set head to 180 - head. }
	}
	else if (tInc < 0) { set head to 180 - head. }

	local eqVel is (2 * constant:pi * body:radius) / body:rotationperiod.
    local vOrbit is sqrt(body:mu / (orbitAlt + body:radius)).
    local vRotX is vOrbit * sin(head) - (eqVel * cos(shipLat)).
    local vRotY is vOrbit * cos(head).
    set head to 90 - arctan2(vRotY, vRotX).
	
	if (raw) { return mod(rawHead + 360, 360). }
	else { return mod(head + 360, 360). }
}

function OrbLAN {				// returns LAN of parameter
	parameter ves is ship.

	if (ves:istype("orbitable")) {
		local spLAN is ves:orbit:lan.
		local bRot is ves:body:rotationangle.
		local bLAN is spLAN - bRot.
		return mod(bLAN, 360).
	}
	else {
		local bLAN is ves - ship:body:rotationangle.
		return mod(bLAN, 360).	// ves in this function returns an orbitable and scalar
	}
}

function GetLNG {				// returns LNG where orbit intersects with latitude
	parameter lat, tInc is 0, tLan is 0.

	if (hasTarget) { 
		set tInc to target:orbit:inclination.
		set tLAN to OrbLAN(target).
	}
	else {
		set tLAN to OrbLAN(tLan).
	}
	
	if (tInc < abs(lat)) {
		if (lat > 0) { set lat to tInc. }
		else { set lat to -tInc. }
	}
	
	local lng0 is arcsin(tan(lat) / tan(tInc)).
	local lngAN is lng0 + tLAN.
	local lngDN is (tLAN - 180) - lng0.
	
	if (lngAN < 0) {
		set lngDN to lngDN + 360.
	}
	
	return list(lngAN, lngDN).
}

function TimeToTgtNode {		// returns time for ship LNG and target node intersection
	parameter lat, lng, tgtSelected is true, tgtInc is 0, tgtLan is 0.
	local rate is body:angularvel:mag * constant:radtodeg.
	local timeAN is 0.
	local timeDN is 0.

	if (tgtSelected) {
		set timeAN to (GetLNG(lat)[0] - lng) / rate.
		set timeDN to (GetLNG(lat)[1] - lng) / rate.
	}
	else {
		set timeAN to (GetLNG(lat, tgtInc, tgtLan)[0] - lng) / rate.
		set timeDN to (GetLNG(lat, tgtInc, tgtLan)[1] - lng) / rate.
	}
	
	if (timeAN < 0) { return list(timeDN, -1). }
	else if (timeDN < timeAN and timeDN > 0) { return list(timeDN, -1). }
	else { return list(timeAN, 1). }
}

function TimeToAltitude {		// returns time to altitude, which ever is closer
    parameter tgtAlt, mode is 0.

    local TA0 is ship:orbit:trueanomaly.
    local ecc is ship:orbit:eccentricity.
	local SMA is ship:orbit:semimajoraxis.

    local ANTA is 0.
    set ANTA to AltToTA(SMA, ecc, ship:body, tgtAlt)[0].
    local DNTA is AltToTA(SMA, ecc, ship:body, tgtAlt)[1].

	// 1 is AN, 2 is DN
	local t0 is time:seconds.
	local MA0 is mod(mod(t0 - ship:orbit:epoch, ship:orbit:period) / ship:orbit:period * 360 + ship:orbit:meananomalyatepoch, 360).

	local EA1 is mod(360 + arctan2(sqrt(1 - ecc^2) * sin(ANTA), ecc + cos(ANTA)), 360).
	local MA1 is EA1 - ecc * constant:radtodeg * sin(EA1).
	local t1 is mod(360 + MA1 - MA0, 360) / sqrt(ship:body:mu / SMA^3) / constant:radtodeg + t0.

	local EA2 is mod(360 + arctan2(sqrt(1 - ecc^2) * sin(DNTA), ecc + cos(DNTA)), 360).
	local MA2 is EA2 - ecc * constant:radtodeg * sin(EA2).
	local t2 is mod(360 + MA2 - MA0, 360) / sqrt(ship:body:mu / SMA^3) / constant:radtodeg + t0.

    if (mode = 0) { return min(t2 - t0, t1 - t0). }
	else if (mode = 1) { return t2 - t0. }
	else { return t1 - t0. }
}

function AltToTA {				// returns true anomalies of the points where the orbit passes the given altitude
	parameter sma, ecc, bodyIn, altIn.
	
	local rad is min(max(ship:orbit:periapsis, altIn), ship:orbit:apoapsis) + bodyIn:radius.
	local TAofAlt is arccos((-sma * ecc^2 + sma - rad) / (ecc * rad)).
	return list(TAofAlt, 360 - TAofAlt). //first true anomaly will be as orbit goes from PE to AP
}

function PhaseTime {			// returns time for correct phase angle

	local transferSMA is (target:orbit:semimajoraxis + ship:orbit:semimajoraxis) / 2.
	local transferTime is (constant:pi * sqrt(transferSMA^3 / ship:body:mu)).
	local transferAng is 180 - ((transferTime / target:orbit:period) * 360).
	
	local phaseAng is PhaseAngle().
	
    local DegPerSec is (360 / ship:orbit:period) - (360 / target:orbit:period).
    local angDiff is transferAng - phaseAng.

    local t is angDiff / DegPerSec.

	return abs(t).
}

function TimeToNodeTarget {			// returns time to reach AN/DN nodes relative to target

    local TA0 is ship:orbit:trueanomaly.

    local ANTA is mod(360 + TA0 + NodeAngleTarget(), 360).
    local DNTA is mod(ANTA + 180, 360).

	// 1 is AN, 2 is DN
	local ecc is ship:orbit:eccentricity.
	local SMA is ship:orbit:semimajoraxis.

	local t0 is time:seconds.
	local MA0 is mod(mod(t0 - ship:orbit:epoch, ship:orbit:period) / ship:orbit:period * 360 + ship:orbit:meananomalyatepoch, 360).

	local EA1 is mod(360 + arctan2(sqrt(1 - ecc^2) * sin(ANTA), ecc + cos(ANTA)), 360).
	local MA1 is EA1 - ecc * constant:radtodeg * sin(EA1).
	local t1 is mod(360 + MA1 - MA0, 360) / sqrt(ship:body:mu / SMA^3) / constant:radtodeg + t0.

	local EA2 is mod(360 + arctan2(sqrt(1 - ecc^2) * sin(DNTA), ecc + cos(DNTA)), 360).
	local MA2 is EA2 - ecc * constant:radtodeg * sin(EA2).
	local t2 is mod(360 + MA2 - MA0, 360) / sqrt(ship:body:mu / SMA^3) / constant:radtodeg + t0.

    return min(t2 - t0, t1 - t0).
}

function TimeToAoP {			// returns time to reach AN/DN nodes relative to target
	parameter tgtAoP.

    local TA0 is ship:orbit:trueanomaly.

    local ANTA is mod(360 + TA0 + AoPAngle(tgtAoP)[2] * AoPSign(tgtAoP), 360).
    local DNTA is mod(ANTA + 180, 360).

	// 1 is AN, 2 is DN
	local ecc is ship:orbit:eccentricity.
	local SMA is ship:orbit:semimajoraxis.

	local t0 is time:seconds.
	local MA0 is mod(mod(t0 - ship:orbit:epoch, ship:orbit:period) / ship:orbit:period * 360 + ship:orbit:meananomalyatepoch, 360).

	local EA1 is mod(360 + arctan2(sqrt(1 - ecc^2) * sin(ANTA), ecc + cos(ANTA)), 360).
	local MA1 is EA1 - ecc * constant:radtodeg * sin(EA1).
	local t1 is mod(360 + MA1 - MA0, 360) / sqrt(ship:body:mu / SMA^3) / constant:radtodeg + t0.

	local EA2 is mod(360 + arctan2(sqrt(1 - ecc^2) * sin(DNTA), ecc + cos(DNTA)), 360).
	local MA2 is EA2 - ecc * constant:radtodeg * sin(EA2).
	local t2 is mod(360 + MA2 - MA0, 360) / sqrt(ship:body:mu / SMA^3) / constant:radtodeg + t0.

	if (AoPSign(tgtAoP) > 0) { return min(t2 - t0, t1 - t0). }
	else { return max(t2 - t0, t1 - t0). }
}

// ORBIT VECTOR MATHS

function OrbitTangent {			// ship velocity
    parameter ves is ship.

    return ves:velocity:orbit:normalized.
}

function OrbitBinormal {		// ship binormal
    parameter ves is ship.

    return vcrs((ves:position - ves:body:position):normalized, OrbitTangent(ves)):normalized.
}

function TargetBinormal {		// target binormal
    parameter ves is target.

    return vcrs((ves:position - ves:body:position):normalized, OrbitTangent(ves)):normalized.
}

function PhaseAngle {			// returns current phase angle between ship and target
	local commonBody is ship:body.
	local vel is ship:velocity:orbit.

    local binormal is vcrs(-commonBody:position:normalized, vel:normalized):normalized.

    local phase is vang(
        -commonBody:position:normalized,
        vxcl(binormal, target:position - commonBody:position):normalized
    ).
    local signVector is vcrs(
        -commonBody:position:normalized,
        (target:position - commonBody:position):normalized
    ).
    local sign is vdot(binormal, signVector).
    if sign < 0 { return 360 - phase. }
    else { return phase. }
}

function PlaneMnv {				// required dv for plane change maneuver
	parameter orbitnrm is OrbitBinormal(), targetnrm is TargetBinormal().

	local relAng is vang(orbitnrm, targetnrm).
	local tgtInc is target:orbit:inclination.
	local tNode is time:seconds + TimeToNodeTarget().
	
	local startVel is velocityAt(ship, tNode):orbit.
	local bodyAtNode is vcrs(OrbitBinormal(), startVel).
	local finalVel is startVel * angleAxis(-NodeSignTarget() * relAng, bodyAtNode).
	
	return (finalVel - startVel).
}

function NodeAltitude {			// altitude at node
	parameter tNode.
	
	local altAtCloserNode is positionat(ship, time:seconds + tNode).
	return (altAtCloserNode - body:position):mag - body:radius.
}

function Hohmann {				// basic hohmann transfer
	parameter burn, orbHeight is ship:apoapsis - 1, APalt is 0, PEalt is 0, mnvTime is 0.
	// subtract to prevent 'pushed nan to stack errors'
	
    if (burn = 1) {
        local velAtAlt is velocityAt(ship, time:seconds + TimeToAltitude(orbHeight)):orbit.
        local bodyAtInt is positionat(ship, time:seconds + TimeToAltitude(orbHeight)) - body:position.

        local targetVelMag is sqrt(ship:body:mu / (ship:orbit:body:radius + orbHeight)).
        local targetVel is vxcl(bodyAtInt, velAtAlt):normalized * targetVelMag.
        
        return (targetVel - velAtAlt). 
    } 
	else {
		if (hasTarget) {
			local targetSMA is ((target:apoapsis + ship:altitude + (ship:body:radius * 2)) / 2).
			local targetVel is sqrt(ship:body:mu * (2 / (ship:body:radius + ship:altitude) - (1 / targetSMA))).
			local currentVel is sqrt(ship:body:mu * (2 / (ship:body:radius + ship:altitude) - (1 / ship:orbit:semimajoraxis))).
		
			return velocityAt(ship, time:seconds + mnvTime):orbit:normalized * (targetVel - currentVel).
		}
		else {
			local targetSMA is ((PEalt + APalt + (ship:body:radius * 2)) / 2).
			local targetVel is sqrt(ship:body:mu * (2 / (ship:body:radius + ship:altitude) - (1 / targetSMA))).
			local currentVel is sqrt(ship:body:mu * (2 / (ship:body:radius + ship:altitude) - (1 / ship:orbit:semimajoraxis))).
		
			return velocityAt(ship, time:seconds + mnvTime):orbit:normalized * (targetVel - currentVel).
		}
    }
}

function NodeAngleTarget {		// angle to node, relative to target
    parameter orbitnrm is OrbitBinormal(), tgtnrm is TargetBinormal().
	
	// no need to calculate DN if not needed
	local ANjoinVec is vcrs(orbitnrm, tgtnrm):normalized.
	local ANang is vang(-body:position:normalized, ANjoinVec).
	if (NodeSignTarget() < 0) { set ANang to ANang * -1. }
	return ANang. 
}

function NodeSignTarget {		// approaching AN or DN
	if (hasTarget) {
		local joinVec is vcrs(OrbitBinormal(), TargetBinormal()):normalized.
		local signVec is vcrs(-body:position:normalized, joinVec):normalized.
		local sign is vdot(OrbitBinormal(), signVec).

		if (sign > 0) { return 1. }
		else { return -1. }
	} 
	else { return 1. }
}

function AoPAngle {				// angle to argument of periapsis
	parameter tgtAoP.

	// no need to calculate DN if not needed
	local ANVec is angleAxis(ship:orbit:lan, ship:body:angularvel:normalized) * solarPrimeVector.
	local ANNormVec is angleAxis(-ship:orbit:inclination, ANVec) * v(0,1,0).
	local tPEjoinVec is angleAxis(-tgtAoP, ANNormVec) * ANVec.
	local AOPang is vang(-body:position:normalized, tPEjoinVec).
	return list(tPEjoinVec, ANNormVec, AOPang). 
}

function AoPSign {				// approaching PE or AP
	parameter tgtAoP.

	local joinVec is AoPAngle(tgtAoP)[0].
	local signVec is vcrs(-body:position:normalized, joinVec):normalized.
	local sign is vdot(AoPAngle(tgtAoP)[1], signVec).

	if (sign > 0) { return -1. }
	else { return 1. }
}

function NodeAngleEquator {		// angle to node, relative to the equator
	// no need to calculate DN if not needed
	local ANjoinVec is angleAxis(ship:orbit:lan, ship:body:angularvel:normalized) * solarPrimeVector.
	local ANang is vang(-body:position:normalized, ANjoinVec).
	if (NodeSignEquator() < 0) { set ANang to ANang * -1. }
	return ANang. 
}

function NodeSignEquator {		// approaching AN or DN
	local joinVec is (angleAxis(ship:orbit:lan, ship:body:angularvel:normalized) * solarPrimeVector):normalized.
	local signVec is vcrs(-body:position:normalized, joinVec):normalized.
	local sign is vdot(OrbitBinormal(), signVec).

	if (sign > 0) { return 1. }
	else { return -1. }
}

// LANDING BURN CALCULATION

function LandThrottle {		// throttle for landing

	local shipAcc is (ship:availableThrust / ship:mass) - (body:mu / body:position:sqrmagnitude).
	local distance is ship:verticalspeed^2 / (2 * shipAcc).

	return (distance / ship:bounds:bottomaltradar).
}

function IntegLand { 		// landing height check through integration
	parameter simHeight, 
		simSpeed, 
		isCoreBooster,
		mFlowRate,
		eng,
		thrustGain is 1,
		dist is 0, 
		timestep is 0.1.

	local simAcc is 0.
	// local gravAcc is 0.
	local atmo is body:atm.
	local atmDensity is 0.
	local atmPres is 0.
	local IGMM is (constant:idealgas / atmo:molarmass) / constant:atmtokpa.
	
	local engineForce is 0.
	local dragForce is 0.
	
	local shipMass is ship:mass.
	local shipACD is 8.
	
	// local bodmu is body:mu.
	// local bodrad is body:radius.
	set simHeight to sqrt(simHeight^2 + dist^2).

	set mFlowRate to mFlowRate * timestep.
	
	until (simSpeed > 0) {
		// current gravity acceleration, testing if a constant would be enough
		// set gravAcc to bodmu / (bodrad + simHeight) ^ 2.
	
		// current atmosphere density
		set atmPres to atmo:altitudepressure(simHeight).
		set atmDensity to atmPres / (IGMM * atmo:alttemp(simHeight)).
		
		// calculate drag force
		set dragForce to 0.5 * atmDensity * simSpeed^2 * shipACD.

		// calculate thrust force
		set engineForce to (eng:availablethrustat(atmPres) * thrustGain).

		// combine all acceleration to single one
		set simAcc to 9.81 - ((dragForce + engineForce) / shipMass).

		// mass flow integration
		set shipMass to shipMass - mFlowRate.

		// physics integration
		set simSpeed to simSpeed - (simAcc * timestep).
		set simHeight to simHeight + (simSpeed * timestep).
	}
	
	print simHeight at (0, 2).
	if (simHeight > 100) { return false. }
	else { return true. }
}

// CALCULATED IMPACT ETA

function ImpactUT {			// returns time for ground track prediction
    parameter minError is 1.
	
	if not (defined impact_UTs_impactHeight) { global impact_UTs_impactHeight is 0. }
	local startTime is time:seconds.
	local craftOrbit is ship:orbit.
	local sma is craftOrbit:semimajoraxis.
	local ecc is craftOrbit:eccentricity.
	local craftTA is craftOrbit:trueanomaly.
	local orbitperiod is craftOrbit:period.
	local ap is craftOrbit:apoapsis.
	local pe is craftOrbit:periapsis.
	local impactUTs is TimeTwoTA(ecc,orbitperiod,craftTA,AltToTA(sma,ecc,ship:body,max(min(impact_UTs_impactHeight,ap - 1),pe + 1))[1]) + startTime.
	local newImpactHeight is max(0, GroundTrack(positionat(ship,impactUTs),impactUTs):terrainheight).
	set impact_UTs_impactHeight TO (impact_UTs_impactHeight + newImpactHeight) / 2.
	
	return lex("time",impactUTs,//the UTs of the ship's impact
		"impactHeight",impact_UTs_impactHeight,//the aprox altitude of the ship's impact
		"converged",((ABS(impact_UTs_impactHeight - newImpactHeight) * 2) < minError)).//will be true when the change in impactHeight between runs is less than the minError
}

function TimeTwoTA {		// returns the difference in time between 2 true anomalies, traveling from taDeg1 to taDeg2
	parameter ecc,periodIn,taDeg1,taDeg2.
	
	local maDeg1 is TrueAToMeanA(ecc,taDeg1).
	local maDeg2 is TrueAToMeanA(ecc,taDeg2).
	
	local timeDiff is periodIn * ((maDeg2 - maDeg1) / 360).
	
	return mod(timeDiff + periodIn, periodIn).
}

function TrueAToMeanA {		// true anomaly to mean anomaly
	parameter ecc,taDeg.
	
	local eaDeg is arctan2(sqrt(1-ecc^2) * sin(taDeg), ecc + cos(taDeg)).
	local maDeg is eaDeg - (ecc * sin(eaDeg) * constant:radtodeg).
	return mod(maDeg + 360, 360).
}

function GroundTrack {		// impact point through orbit prediction
	parameter pos, posTime, localBody is ship:body.
	
	local bodyNorth is v(0,1,0).
	local rotationalDir is vdot(bodyNorth,localBody:angularvel) * constant:radtodeg.
	local posLATLNG is localBody:geopositionof(pos).
	local timeDif is posTime - time:seconds.
	local longitudeShift is rotationalDir * timeDif.
	local newLNG is mod(posLATLNG:lng + longitudeShift,360).
	if (newLNG < - 180) { set newLNG TO newLNG + 360. }
	if (newLNG > 180) { set newLNG TO newLNG - 360. }
	
	return latlng(posLATLNG:lat, newLNG).
}

function Impact {			// ground track and trajectories
    parameter nav, lP, LZ.	// return type, landProfile

    local impData is ImpactUT().
	local impLatLng0 is GroundTrack(positionat(ship,impData["time"]),impData["time"]).
	local impLatLng1 is 0.
	local LZToBody is 0.
	local landToBody is 0.
	local dRange is 0.
	set LZToBody to body:position - LZ:altitudeposition(0).
	
    if (alt:radar > 50) {
        if (lP > 3) {
            if (nav = 1) { return impLatLng0:lat. }
            else if (nav = 2) { return impLatLng0:lng. }
            else if (nav = 3) { return impLatLng0. }
            else { 	
				set landToBody to body:position - impLatLng0:altitudeposition(0).
				set dRange to (vang(landToBody, LZToBody) / 360) * (2 * constant:pi * body:radius).
				return dRange. 
			}
        } 
		else {
            if (addons:tr:hasimpact) { set impLatLng1 to addons:tr:impactpos.}
			else { set impLatLng1 to impLatLng0. }
			
            if (nav = 1) { return impLatLng1:lat. }
            else if (nav = 2) { return impLatLng1:lng. }
            else if (nav = 3) { return impLatLng1. }
			else { 
				set landToBody to body:position - impLatLng1:altitudeposition(0).
				set dRange to (vang(landToBody, LZToBody) / 360) * (2 * constant:pi * body:radius).
				return dRange.  
			}
        }
    } 
	else {
        if (nav = 1) { return impLatLng0:lat. }
        else if (nav = 2) { return impLatLng0:lng. }
        else if (nav = 3) { return impLatLng0. }
        else { 
			set landToBody to body:position - impLatLng0:altitudeposition(0).
			set dRange to (vang(landToBody, LZToBody) / 360) * (2 * constant:pi * body:radius).
			return dRange.  
		}
    }
}

// CRAFT SYSTEMS / UTILITIES

function SafeStage {		// avoid staging when unfocused

	if (ship = kuniverse:activevessel and stage:ready) { stage. }  
}

function EngSpl {			// engine spool function
	parameter tgt, ullage is false.
	
	local startTime is time:seconds.
	
    if (ullage) { 
        rcs on. 
        set ship:control:fore to 0.75.
        
        when (time:seconds > startTime + 2) then { 
            set ship:control:neutralize to true. rcs off. 
        }
    }
	
	if (throt < tgt) {
		if (ullage) { set throt to 0.025. wait 0.5. }	// TEA-TEB
		until (throt >= tgt) {
			set throt to throt + (DeltaTime() * 1.333).
		}
	}
	else {
		until (throt <= tgt) { 
			set throt to throt - (DeltaTime() * 1.333).
		}
	}
	
	set throt to tgt.
}

function DeltaTime {		// returns deltaTime
	local startTime is time:seconds. wait 0.
	return time:seconds - startTime.
}

function LinEq {			// linear equation function
	parameter var, x2, y1, y2, x1 is 0.
	// y = mx + b
	
	return ((y2 - y1) / (x2 - x1)) * var + (((x2 * y1) - (x1 * y2)) / (x2 - x1)).
}

function BetterWarp {		// better warp mode that avoids overshoots
	parameter duration, disp is false.

	local safe_margin is 1.
	
	local startT is time:seconds.
	local endT is startT + duration.
	lock remainT to endT - time:seconds.
	
	set kuniverse:timewarp:mode to "rails".
	
	local minimumT is 	list(0, 10, 100, 1000, 10000, 100000, 1000000, (remainT + 1)).
	local multiplier is list(1, 10, 100, 1000, 10000, 100000, 1000000, 10000000).
	
	local done is false.
	until (remainT <= 10 or done) {

		local warpLevel is 0.
		
		until ((warpLevel >= minimumT:length) or (minimumT[warpLevel + 1] > remainT)) {
			set warpLevel to warpLevel + 1. wait 0.
			set kuniverse:timewarp:warp to warpLevel.
		}
		
		local margin is safe_margin * multiplier[warpLevel].
		if (remainT < margin) { set done to true. }
		until (remainT < margin) {
			if (launchButton:pressed and loadButton:pressed) { 
				set kuniverse:timewarp:warp to 0.
				kuniverse:timewarp:cancelwarp().
				wait until kuniverse:timewarp:issettled.
				set launchButton:text to "SCRUBBED". 
				set launchButton:enabled to false.
				wait 10. reboot. 
				}
			else {
				if (disp) { set launchButton:text to "T: -" + timestamp(remainT):clock. }
			}
		}
	}
	
	set kuniverse:timewarp:warp to 0.
	until (remainT < 0 or remainT = 0) { 
		if (disp) { set launchButton:text to "T: -" + timestamp(remainT):clock. } 
	} .
	kuniverse:timewarp:cancelwarp().
    until kuniverse:timewarp:issettled {
		if (disp) { set launchButton:text to "T: -" + timestamp(remainT):clock. }
	}
}

function SecToDay {			// converts seconds to days
	parameter secVal.
	
	local hpd is kuniverse:hoursperday.
	return (secVal / hpd / 3600).
}

function DayToSec {			// converts days to sec
	parameter dayVal.
	
	local hpd is kuniverse:hoursperday.
	return (dayVal * hpd * 3600).
}

function VecToNode {		// converts vectors to maneuver node
  parameter v1, nodeTime IS time:seconds.

  local compPRO is velocityAt(ship, nodeTime):orbit.
  local compNRM is vcrs(compPRO, positionat(ship, nodeTime)):normalized.
  local compRAD is vcrs(compNRM, compPRO):normalized.
  return node(nodeTime, vdot(v1, compRAD), vdot(v1, compNRM), vdot(v1, compPRO:normalized)).
}

function ExecNode {			// execute maneuver node
	parameter 
        topOffset is false,
        maxT is ship:availablethrust, 
        isRCS is false,
		payloadType is 1.
	kuniverse:forceactive(ship).
	core:part:controlfrom().
	sas off.
	
	if not (hasNode) { return. }
	if (isRCS = true) rcs on.
	else rcs off.

	// maneuver timing and preparation
    steeringmanager:resettodefault().
    // set steeringmanager:maxstoppingtime to 3.5.
	local coastVec is ship:position.
	local normVec is ship:position.
	
	local nd is nextnode.
    local maxAcc is maxT / ship:mass.
    local burnDuration is nd:deltav:mag / (max(maxAcc, 0.001)).
	
	// throt fails on reboot.
	set throt to 0.
	lock throttle to throt.
	if (isRCS) { set steeringmanager:maxstoppingtime to 0.05. }			// slow down turning
	local turnStab is 0.
	
	if (nd:eta - ((burnDuration / 2) + 120)) {
		// persistent warp integration
		if (payloadType = 2 or payloadType = 3) { lock coastVec to ship:retrograde:vector. }
		else { lock coastVec to ship:prograde:vector. }
		if (topOffset) { lock normVec to -body:position. }
		else { lock normVec to NormalVec(coastVec). }
		
		lock steering to lookdirup(
			coastVec,
			NormalVec(coastVec)).
		
		local coreList is list().
		list processors in coreList.
		local perRotCore is core.
		for proc in coreList {
			if (proc:tag = "P-ROT") { set perRotCore to proc. }
		}
		
		if not (core:tag = perRotCore:tag) {
			until (turnStab > 3) {
				wait 0.1.
				if ((vang(coastVec, ship:facing:forevector) < 1) and
					vang(NormalVec(coastVec), ship:facing:topvector) < 1) { 
					set turnStab to turnStab + 0.1. }
			}
			set turnStab to 0.
			
			local sasDir is "prograde".
			if (payloadType = 2 or payloadType = 3) { set sasDir to "retrograde". }
			unlock steering.
			local perRotList is list(0, "orbit", sasDir).
			perRotCore:connection:sendmessage(perRotList).
			wait 1.
			local perRotList is list(payloadType, "orbit", sasDir).
			perRotCore:connection:sendmessage(perRotList).
		}
		BetterWarp(nd:eta - ((burnDuration / 2) + 60)).
	}
	
	sas off.
	lock steering to lookdirup(
        coastVec,
        NormalVec(coastVec)).
    wait until nd:eta <= ((burnDuration / 2) + 45).

    lock nv to nd:deltav:normalized.

	if ((payloadType = 2 or payloadType = 3) and isRCS) {	// use bulkhead thrusters
		lock steering to lookdirup(-nv, NormalVec(-nv)).			// reversed for bulkhead
	} 
	else if ((payloadType = 1) and isRCS) {
		lock steering to lookDirUp(prograde:vector, normVec).	// most likely has an independent gnc script
	} 
	else {
		lock steering to lookdirup(nv, normVec).			// point to the maneuver node vector
	}

    // maneuver execution
    until (nd:eta <= burnDuration + 10) { wait 0. }
	if (isRCS = true) rcs on.
	else rcs off.
    wait until nd:eta <= (burnDuration / 2).

    set burnDone to false.

    until burnDone {
        // wait 0.
		set maxT to max(0.0001, ship:availableThrust).
        set maxAcc to maxT / ship:mass.

        if (isRCS = false) { 
			
			local angleMult is ((5 - vang(ship:facing:forevector, nd:deltav)) / 5).
			local reqThrot is (min(nd:deltav:mag / maxAcc, 1) * angleMult).
			if (reqThrot > 0.25) { set throt to reqThrot. }
			else { set throt to 1. }
		}
        else { 
			RCSTranslate(nv * ship:facing:forevector, 
				nv * ship:facing:starvector, 
				nv * ship:facing:topvector).
		}
		
		if ((throttle > 0) and (ship:availablethrust < 1) and stage:ready and isRCS = false) { 
			wait 3. SafeStage(). wait 3. toggle AG10. }	// stage if fuel is gone, unless we use rcs

        if (nd:deltav:mag < 0.085)
        {
            set ship:control:neutralize to true.
            set throt to 0.
            set burnDone to true.
        }   
    }

    remove nextnode.
    set ship:control:neutralize to true.
    set throt to 0. rcs off.
    set ship:control:pilotmainthrottle to 0.
    lock steering to lookdirup(
        coastVec,
        normVec).
    until (turnStab > 3) {
		wait 0.1.
		if ((vang(coastVec, ship:facing:forevector) < 1) and
			vang(normVec, ship:facing:topvector) < 1) { 
			set turnStab to turnStab + 0.1. }
	}
	steeringmanager:resettodefault().
}

function NormalVec {		// used for orienting ship rotation
	parameter tarVec is ship:prograde:vector.
	
	return vcrs(tarVec, -body:position).
}

function RCSTranslate {		// translate using rcs
    parameter tVecF, tVecS, tVecT.

	local dZ is 0.05.
	local scaleFore is 1.
	local scaleStar is 1.
	local scaleTop is 1.
	local scaleMag is (1 - (dZ * 18)).

	if (abs(tVecF) < dZ) { 
		set scaleFore to 1 + ((scaleMag - dZ) / dZ). }
	if (abs(tVecS) < dZ) { 
		set scaleStar to 1 + ((scaleMag - dZ) / dZ). }
	if (abs(tVecT) < dZ) { 
		set scaleTop to 1 + ((scaleMag - dZ) / dZ). }
		
	if (abs(tVecF) < dZ / 2) { 
		set scaleFore to 1 + ((scaleMag - dZ) / dZ). }
	if (abs(tVecS) < dZ / 2) { 
		set scaleStar to 1 + ((scaleMag - dZ) / dZ). }
	if (abs(tVecT) < dZ / 2) { 
		set scaleTop to 1 + ((scaleMag - dZ) / dZ). }

    set ship:control:fore to tVecF * scaleFore.
    set ship:control:starboard to tVecS * scaleStar.
    set ship:control:top to tVecT * scaleTop.
}

function DockGNC {
	parameter mode, tDist, tSpd, vThreshold is 0.1.

	local rDist is 0.
	lock rDist to target:position + target:velocity:orbit:normalized * max(5, sqrt((tDist^2) / 3)) + 
		up:vector * sqrt((tDist^2) / 3) +
		vcrs(up:vector, velocity:orbit:normalized) * sqrt((tDist^2) / 3).
	
	local relVel is 0.
	lock rVel to ship:velocity:orbit - target:velocity:orbit.
	
	local rDistF is 0.
	local rDistS is 0.
	local rDistT is 0.
		
	local rVelF is 0.
	local rVelS is 0.
	local rVelT is 0.
	
	lock rDistF to rDist * ship:facing:forevector.
	lock rDistS to rDist * ship:facing:starvector.
	lock rDistT to rDist * ship:facing:topvector.
		
	lock rVelF to rVel * ship:facing:forevector.
	lock rVelS to rVel * ship:facing:starvector.
	lock rVelT to rVel * ship:facing:topvector.
	
	local transF is 0.
	local transS is 0.
	local transT is 0.
	
	local rcsAcc is 0.15.
	
	lock transF to max(-tSpd, min(sqrt(2 * rcsAcc * abs(rDistF)), tSpd)).
	lock transS to max(-tSpd, min(sqrt(2 * rcsAcc * abs(rDistS)), tSpd)).
	lock transT to max(-tSpd, min(sqrt(2 * rcsAcc * abs(rDistT)), tSpd)).
	
	local signF is 0.
	local signS is 0.
	local signT is 0.
	lock signF to round(rDistF / max(0.000001, abs(rDistF))).
	lock signS to round(rDistS / max(0.000001, abs(rDistS))).
	lock signT to round(rDistT / max(0.000001, abs(rDistT))).
	
	// acceleration PID
	local dockP is 8.
	local dockI is 0.02.
	local dockD is 0.1.
	
	set dockPIDF to pidloop(dockP, dockI, dockD).
	set dockPIDF:setpoint to signF * transF.
	lock dockOutF to dockPIDF:update(time:seconds, rVelF).
	
	set dockPIDS to pidloop(dockP, dockI, dockD).
	set dockPIDS:setpoint to signS * transS.
	lock dockOutS to dockPIDS:update(time:seconds, rVelS).
	
	set dockPIDT to pidloop(dockP, dockI, dockD).
	set dockPIDT:setpoint to signT * transT.
	lock dockOutT to dockPIDT:update(time:seconds, rVelT).
	
	until false {
	
		if (ag6) { set tDist to 190. }
		else { set tDist to 0.1. }
	
		set dockPIDF:setpoint to signF * transF.
		set dockPIDS:setpoint to signS * transS.
		set dockPIDT:setpoint to signT * transT.
		
		if (abs(dockOutS + dockOutT) < abs(dockOutF)) {
			RCSTranslate(dockOutF / 2, dockOutS / 4, dockOutT / 4).
		} 
		else {
			if (abs(dockOutS) > abs(dockOutT)) {
				RCSTranslate(dockOutF / 4, dockOutS / 2, dockOutT / 4).
			}
			else { RCSTranslate(dockOutF / 4, dockOutS / 4, dockOutT / 2). }
		}	
	}
}

// RSVP SCHEDULER AND EVALUATOR

function FindMnv {
	parameter tgt, mnvMode,
		searchDur is 1,			// years
		maxToF is 2,			// years
		// searchInt is SecToDay(ship:orbit:period).			// days
		searchInt is 10.			// days

	local totalThread is 0.
	local threadNumber is 0.
	local threadList is list().
	local rsvpTime is time:seconds + 120.	// acts as baseline of all rsvp threads

	list processors in rsvpList.
	for rsvpCore in rsvpList {
		if (rsvpCore:bootfilename = "/boot/RSVP_CORE") {
			set totalThread to totalThread + 1.
		}
	}

	for rsvpCore in rsvpList {
		if (rsvpCore:bootfilename = "/boot/RSVP_CORE") {
			threadList:insert(0, threadNumber).
			threadList:insert(1, totalThread).
			threadList:insert(2, tgt).
			threadList:insert(3, mnvMode).
			threadList:insert(4, searchDur).
			threadList:insert(5, maxToF).
			threadList:insert(6, searchInt).
			threadList:insert(7, rsvpTime).
			
			rsvpCore:connection:sendmessage(threadList).
			set threadNumber to threadNumber + 1.
		}
	}
}

function WaitForThreads {
	ship:messages:clear().

	until false { wait 0.
		if (ship:messages:empty) { wait 0. }
		else {
			local received is ship:messages:peek.
			local threadFinished is ship:messages:length.
			local totalThread is received:content["tto"].
			
			if (threadFinished = totalThread) { break. }
		}
	}

	set replyList to list().
	until false { wait 0.
		if (ship:messages:empty) { break. }

		local received is ship:messages:pop.
		replyList:add(received).
	}
}

function EvaluateMnv {

	local successNo is 0.
	local bestThread is 0.
	local bestDV is 2^31.
	local bestT is 0.
	local bestDur is 0.
	local bestToF is 0.
	local bestInt is 0.

	for reply in replyList {
		
		if (reply:content["suc"]) { set successNo to successNo + 1. }
		if (reply:content["dv"] < bestDv) {
			set bestThread to reply:content["tno"].
			set bestDv to reply:content["dv"].
			set bestT to reply:content["t"].
			set bestDur to reply:content["dur"].
			set bestToF to reply:content["tof"].
			set bestInt to reply:content["int"].
		}
	}

	local dataMnv is list(bestDV, bestT, bestDur, bestToF, bestInt).
	return dataMnv.
}

function RSVPMnv {
	runoncepath("0:/rsvp/main").
	local options is lexicon(
			"create_maneuver_nodes", "first", 
			"verbose", true,
			"final_orbit_type", "none"
			,"search_duration", DayToSec(1)
			,"max_time_of_flight", DayToSec(timespan(2,0):days)
			,"search_interval", DayToSec(0.5) // (ship:orbit:period / 360)
		).

	rsvp:goto(target, options).
}

// HILLCLIMBING ALGORITHM

function CreateNode {
	parameter colMnv.
	
	add node(colMnv[0], colMnv[1], colMnv[2], colMnv[3]).
	// wait 0.5.
}

function HillClimb {
	parameter initT, dVIter.
	
	local colMnv is list(time:seconds + initT, 0,0,0).
	
	until false {
		local oldScore is Score(colMnv).

		set colMnv to Improve(colMnv, dVIter).
		if (oldScore <= Score(colMnv)) {
			break.
		}
	}
	
	
	CreateNode(colMnv).
}

function Score {
	parameter mnv is list(time:seconds, 0,0,0).
	
	add	node(mnv[0], mnv[1], mnv[2], mnv[3]).
	local scoreVal is ClosestApproach().
	remove nextnode.
	
	return scoreVal.
}

function Improve {
	parameter mnv, dVIter.
	
	local scoreToBeat is Score(mnv).
	
	local bestCandidate is mnv.
	local candidates is list(
		list(mnv[0], mnv[1] + dVIter, mnv[2], mnv[3]),
		list(mnv[0], mnv[1] - dVIter, mnv[2], mnv[3]),
		list(mnv[0], mnv[1], mnv[2] + dVIter, mnv[3]),
		list(mnv[0], mnv[1], mnv[2] - dVIter, mnv[3])
	).
	
	for candidate in candidates {
		local candidateScore is Score(candidate).
		if (candidateScore < scoreToBeat) {
			set scoreToBeat to candidateScore.
			set bestCandidate to candidate.
		}
	}
	
	return bestCandidate.
}

function ClosestApproach {
	parameter steps is 1000.
	
	wait until hasTarget.
	
	// time until the ship exits SOI, 
	local maxIterVal is eta:transition * 2.501 / 5.
	local currIterVal is 0.
	local minIterVal is 0.
	local lowestIterVal is 0.
	local stepVal is steps.
	local refineRes is 0.	// refine resolution
	local iterOS is 0.		// iteration offset
	
	local last_targetDist is (positionat(target, time:seconds + currIterVal) - positionat(ship, time:seconds + currIterVal)):mag + 1.
	
	// avoid calculating infinity
	until (refineRes >= 10) {
		
		local startT is time:seconds.
		local stepIterVal is (stepVal / 10^refineRes).
		
		until (((currIterVal + minIterVal) >= maxIterVal)) {
			local targetDist is (
				positionat(target, startT + currIterVal + minIterVal) - 
				positionat(ship, startT + currIterVal + minIterVal)):mag.
			
			if (targetDist < last_targetDist) {
				set last_targetDist to targetDist.
				set lowestIterVal to currIterVal + minIterVal.
			}	
			
			set currIterVal to currIterVal + stepIterVal.
		}
		
		set currIterVal to 0.
		set iterOS to stepIterVal.	
		set minIterVal to lowestIterVal - iterOS.
		set maxIterVal to lowestIterVal + iterOS.
		set refineRes to refineRes + 1.
	}
	return last_targetDist.
}
// LAUNCH VEHICLE parameterS
parameter stageNo.

local pLex is readjson("0:/params1.json").
local lLex is lexicon().

// load default unless override file is present
if (exists("0:/coordcfg.json")) {
	set lLex to readjson("0:/coordcfg.json").
	pLex:add("LZ0", latlng(lLex["LZ0"]:lat, lLex["LZ0"]:lng)).
	pLex:add("LZ1", latlng(lLex["LZ1"]:lat, lLex["LZ1"]:lng)).
	pLex:add("LZ2", latlng(lLex["LZ2"]:lat, lLex["LZ2"]:lng)).
}
else {
	pLex:add("LZ0", latlng(-0.11, -70)).
	pLex:add("LZ1", latlng(-0.132287731225158, -74.5494025150112)).
	pLex:add("LZ2", latlng(-0.140425956708956, -74.5495256417959)).
}

missionConstants().
parameterAdd().
writejson(pLex, "0:/params2.json").

function parameterAdd {		// add parameters to params1
	if (pLex["payloadType"] < 4) {
		if (pLex["landProfile"] = 1) { RTLSmode(). }
		if (pLex["landProfile"] = 2) { ASDSmode(). }
		if (pLex["landProfile"] = 3) { EXPENDmode0(). }
		if (pLex["landProfile"] = 4) { HEAVYmode0(). }
		if (pLex["landProfile"] = 5) { HEAVYmode1(). }
		if (pLex["landProfile"] = 6) { EXPENDmode1(). }
	}
	else {
		if (pLex["landProfile"] = 1) { RTLSmode_SS(). }
	}
}

function missionConstants {	// global variables

    pLex:add("fairingSepAlt", 60000).
    pLex:add("atmHeight", body:atm:height).
    if (hasTarget) { 
		if (target:body = ship:body) { 
			set pLex["tgtInc"] to target:orbit:inclination.
		}
	}
    pLex:add("windowOffset", 2.5).
    pLex:add("goForLaunch", false).
    pLex:add("maxQ", 0.155).
}

// FALCON FLIGHT PROFILES

function RTLSmode { // SINGLE CORE RTLS
	pLex:add("maxPayload", 7000).
	pLex:add("tanAlt", body:atm:height).
	pLex:add("MECOangle", 45).
	pLex:add("tgtAlt", 60000).
	pLex:add("pitchGain", 110).
	pLex:add("reentryHeight", 32500).
	pLex:add("reentryVelocity", 600).
}

function ASDSmode { // SINGLE CORE ASDS
	pLex:add("maxPayload", 9000).
	pLex:add("tanAlt", body:atm:height).
	pLex:add("MECOangle", 40).
	pLex:add("tgtAlt", 65000).
	pLex:add("pitchGain", 97).
	pLex:add("reentryHeight", 35000).
	pLex:add("reentryVelocity", 800).
}

function EXPENDmode0 { // SINGLE CORE XPND
    pLex:add("maxPayload", 15000).
    pLex:add("tanAlt", body:atm:height + 5000).
    pLex:add("MECOangle", 10).
	pLex:add("tgtAlt", 70000).
	pLex:add("pitchGain", 72.5).
	pLex:add("reentryHeight", 30000).
	pLex:add("reentryVelocity", 410).
    // recovery parameters are still added to prevent unknown variables errors
}

function HEAVYmode0 { // CORE ASDS, BOOSTER RTLS
	pLex:add("maxPayload", 13500).
	pLex:add("tanAlt", body:atm:height + 10000).
	pLex:add("MECOangle", 45).
	pLex:add("tgtAlt", 75000).
	pLex:add("pitchGain", 105).
	pLex:add("reentryHeight", 32500).
	pLex:add("reentryVelocity", 500).
}

function HEAVYmode1 { // CORE XPND, BOOSTER RTLS
	pLex:add("maxPayload", 13500).
	pLex:add("tanAlt", body:atm:height + 10000).
	pLex:add("MECOangle", 45).
	pLex:add("tgtAlt", 75000).
	pLex:add("pitchGain", 105).
	pLex:add("reentryHeight", 32500).
	pLex:add("reentryVelocity", 500).
}

function EXPENDmode1 { // CORE XPND, BOOSTER XPND
    pLex:add("maxPayload", 15000).
    pLex:add("tanAlt", body:atm:height + 5000).
    pLex:add("MECOangle", 10).
	pLex:add("tgtAlt", 70000).
	pLex:add("pitchGain", 72.5).
	pLex:add("reentryHeight", 30000).
	pLex:add("reentryVelocity", 410).
    // recovery parameters are still added to prevent unknown variables errors
}

// STARSHIP FLIGHT PROFILES

function RTLSmode_SS {
    global maxPayload is 25000.
    global tangentAltitude is body:atm:height + 5000.
    global MECOangle is 30.
    global targetAp is 70000.
    global pitchGain is 0.8. // 1.0815
    global reentryHeight is 30000.
    global reentryVelocity is 500.
}
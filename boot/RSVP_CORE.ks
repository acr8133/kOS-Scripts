clearscreen.

set config:ipu to 2000.
runoncepath("0:/COMMON/GNC.ks").
// core:part:getmodule("kOSProcessor"):doEvent("Open Terminal").
core:messages:clear().

local pLex is lexicon().
local threadNumber is 0.
local totalThread is 0.
local eDep is 0.

until false { wait 0.	// WAIT FOR THREAD ASSIGNMENT
	if (core:messages:empty) { print "CORE EMPTY" at (0, 1). }
	else {
		local received is core:messages:peek.
		set pLex to received:content.		// parameter
		set threadNumber to received:content[0].
		set totalThread to received:content[1].
		clearScreen.
		print "thread: " + threadNumber + "/" + (totalThread - 1) at (0, 1).
		break.
	}
}

local ctr is time:seconds.
until false { wait 0.
	print (pLex[4] / totalThread) at (0, 3).
	set eDep to 
		pLex[7] + 
		(DayToSec(timespan(pLex[4] / totalThread,0):days) * 
		(threadNumber)).
	set lDep to
		pLex[7] + 
		(DayToSec(timespan(pLex[4] / totalThread,0):days) * 
		(threadNumber + 1)).
	print round(eDep) + " to " + round(lDep) at (0, 4).
	print (eDep) at (0, 5).
	RSVPStart(pLex[2], pLex[3], pLex[4] / totalThread, pLex[5], pLex[6]).
	print "took " + round((time:seconds - ctr), 2) + " secs".
	wait until false.
}

function RSVPStart {
	parameter tgt, mnvMode, searchDur, maxToF, searchInt.

	// print "tof: " + DayToSec(timespan(maxToF,0):days) + "     " at (0, 4).
	if (mnvMode = 0) {	// ASTROGATOR
		runoncepath("0:/rsvp/main").
		local options is lexicon(
			"create_maneuver_nodes", "none", 
			"verbose", true,
			"final_orbit_type", "none"
			,"search_duration", DayToSec(timespan(searchDur,0):days)
			,"max_time_of_flight", DayToSec(timespan(maxToF,0):days)
			,"search_interval", DayToSec(searchInt)
			,"earliest_departure", eDep
		).
		local mnvData is rsvp:goto(tgt, options).
		
		if (mnvData["success"]) {
			
			// print mnvData.
			// wait until false.

			// SERIALIZE MANEUVER NODE HERE, SAME START FOR ALL CORES
			local mnvLex is lexicon(
				"tno", threadNumber,
				"tto", totalThread,
				"suc", true,
				"t", mnvData["predicted"]["departure"]["time"],
				"dv", mnvData["predicted"]["departure"]["deltav"],
				"dur", searchDur,
				"tof", maxToF,
				"int", searchInt
			).

			// print mainCore:part:name.
			ship:connection:sendmessage(mnvLex).
		}
		else {
			local mnvLex is lexicon(
				"tno", threadNumber,
				"tto", totalThread,
				"suc", false
			).
		}
	}
	else if (mnvMode = 1) {	// INTERPLANETARY
		runoncepath("0:/rsvp/main").
		
		local mnvData is readjson("transfer_mnv.json").
		
		local options is lexicon(
			"create_maneuver_nodes", "first", 
			"verbose", true
			,"final_orbit_type", "none"
			,"search_duration", ship:orbit:period * 2
			,"max_time_of_flight", mnvData["m"] + DayToSec(1)
			,"search_interval", mnvData["int"]
			,"earliest_departure", mnvData["t"]
		).
		rsvp:goto(tgt, options).
		
		// SAFE CATCH HERE!
		// FORCE PREVENTION OF DOUBLE NEGATIVE T-MINUS!
		if (hasNode) { 
			if (nextnode:eta < 0) {
				set nextnode:eta to nextnode:eta + ship:orbit:period. 
			}
		}
		
	}
	else if (mnvMode = 2) {	// COURSE CORRECTION
		runoncepath("0:/rsvp/main").
		local options is lexicon(
			"create_maneuver_nodes", "first", 
			"final_orbit_type", "none"
			// "search_duration", searchDuration
		).
		rsvp:goto(tgt, options).
	}
}
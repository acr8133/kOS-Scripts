clearscreen.
set config:ipu to 2000.
switch to 0.

// check for tags then run prerequesites
if (core:tag = "CORE" or core:tag = "SIDEA" or core:tag = "SIDEB") {
	// core:doEvent("Open Terminal").
	runpath("0:/SPACEX/BOOSTER").
}
else {
	// core:doEvent("Open Terminal").
	runpath("0:/SPACEX/PAYLOAD").
}

// set avd to vecDraw(ship:position, v(0,0,0), blue, "", 2.0, true).
// set avd:vecupdater to { return v(0,0,0) * 10. }.
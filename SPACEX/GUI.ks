// create mission GUI

local missionGUI is GUI(275).

local box0 is missionGUI:addhlayout().
	local box0_0 is box0:addvbox().
		local lab0_0 is box0_0:addlabel("SpaceX Launch").	// lab = label
		local lab0_1 is box0_0:addlabel("Software v0.1").
		set lab0_0:style:align to "center".
		set lab0_1:style:align to "center".
		set lab0_0:style:fontsize to 15.
		set lab0_1:style:fontsize to 15.
		set lab0_0:style:height to 12.5.
		set lab0_1:style:height to 12.5.
	local ABORTButton is box0:addbutton("ABT").
	set ABORTButton:style:textcolor to rgb(1,0.75,0.75).
	set ABORTButton:style:height to 30.
	local REBOOTButton is box0:addbutton("RBT").
	set REBOOTButton:style:textcolor to rgb(0.75,0.75,1).
	set REBOOTButton:style:height to 30.
	local ADVANCEDButton is box0:addbutton("ADV").
	set ADVANCEDButton:style:textcolor to rgb(0.75,0.75,1).
	set ADVANCEDButton:style:height to 30.
	set ADVANCEDButton:toggle to true.
	// REBOOTButton:hide().

local box1 is missionGUI:addhlayout().
set box1:style:align to "center".
	local box1_0 is box1:addhbox().
		local lab1_0 is box1_0:addlabel("Launch Vehicle and Payload").
		set lab1_0:style:height to 20.
		set lab1_0:style:align to "center".
	
local box2 is missionGUI:addhlayout().
set box2:style:align to "center".
	local box2_0 is box2:addvbox().
		local LVpup is box2_0:addpopupmenu().
		LVpup:addoption("Falcon 9 / Heavy + Fairings").
		LVpup:addoption("Falcon 9 + Dragon V2").
		LVpup:addoption("Falcon 9 + Dragon V1").
		LVpup:addoption("Superheavy + Starship").

local box3 is missionGUI:addhlayout().
set box3:style:align to "center".
	local box3_0 is box3:addvbox().
		local lab3_0 is box3_0:addlabel("   ORBIT   ").
		local lab3_1 is box3_0:addlabel("ALT (km)").
		set lab3_0:style:height to 12.5.
		set lab3_0:style:align to "center".
		set lab3_1:style:height to 12.5.
		set lab3_1:style:align to "center".
		local ALTinp is box3_0:addtextfield().
	local box3_1 is box3:addvbox().
		local lab3_2 is box3_1:addlabel("   ORBIT   ").
		local lab3_3 is box3_1:addlabel("INC (deg)").
		set lab3_2:style:height to 12.5.
		set lab3_2:style:align to "center".
		set lab3_3:style:height to 12.5.
		set lab3_3:style:align to "center".
		local INCinp is box3_1:addtextfield().
	local box3_2 is box3:addvbox().
		local lab3_4 is box3_2:addlabel("PAYLOAD").
		local lab3_5 is box3_2:addlabel("MASS (kg)").
		set lab3_4:style:height to 12.5.
		set lab3_4:style:align to "center".
		set lab3_5:style:height to 12.5.
		set lab3_5:style:align to "center".
		local MASSinp is box3_2:addtextfield().

local box4 is missionGUI:addvlayout().
set box4:style:align to "center".
	local box4_0 is box4:addhbox().
		local lab4_0 is box4_0:addlabel("Orbital Maneuvering").
		set lab4_0:style:height to 20.
		set lab4_0:style:align to "center".

local box5 is missionGUI:addvlayout().
	local box5_0 is box5:addhbox().
		set box5_0:style:height to 30.
			local ORBrad is box5_0:addradiobutton("ORBIT").
			set ORBrad:style:hstretch to true.
			local DCKrad is box5_0:addradiobutton("DOCK ").
			set DCKrad:style:hstretch to true.
		local box5_1 is box5:addhlayout().
		local TGTinp is box5_1:addtextfield.
		TGTinp:hide().

local box6 is missionGUI:addhlayout().
set box6:style:align to "center".
	local box6_0 is box6:addhbox().
		local lab6_0 is box6_0:addlabel("Booster Recovery Mode").
		set lab6_0:style:height to 20.
		set lab6_0:style:align to "center".

local box7 is missionGUI:addhlayout().
set box7:style:align to "center".
	local box7_0 is box7:addvbox().

local coreList is list().
list processors in coreList.
local popupList is list().
local coreIterate is 0.

for core in coreList {			// make sure CORE is always read first
	for core in coreList {

		if (core:tag = "CORE" and coreIterate = 0) {
			set coreIterate to coreIterate + 1.
			popupList:add(box7_0:addpopupmenu()).
			popupList[coreIterate - 1]:addoption("Core - RTLS").
			popupList[coreIterate - 1]:addoption("Core - ASDS").
			popupList[coreIterate - 1]:addoption("Core - XPND").
		}

		if ((core:tag = "SIDEA" or core:tag = "SIDEB") and coreIterate = 1) {
			set popupList[0]:index to 1.
			popupList[0]:options:remove(0).
			set popupList[0]:index to 0.
			
			set coreIterate to coreIterate + 1.
			popupList:add(box7_0:addpopupmenu()).
			popupList[coreIterate - 1]:addoption("Boosters - RTLS").
			popupList[coreIterate - 1]:addoption("Boosters - XPND").
		}
	}
}

local launchButton is missionGUI:addbutton("START NEW MISSION").
	set launchButton:enabled to false.

local loadButton is missionGUI:addbutton("LOAD LAST PARAMETERS").
if (exists("0:/params1.json")) {
	set loadButton:enabled to true.
} 
else {
	set loadButton:enabled to false.
}

// create advanced GUI

local advancedGUI is GUI(275).

local adbox1 is advancedGUI:addhlayout().
set adbox1:style:align to "center".
	local adbox1_0 is adbox1:addhbox().
		local adlab1_0 is adbox1_0:addlabel("Landing Zone 1 (Primary)").
		set adlab1_0:style:height to 20.
		set adlab1_0:style:align to "center".

local adbox2 is advancedGUI:addhlayout().
set adbox2:style:align to "center".
	local adbox2_0 is adbox2:addvbox().
		local adlab2_0 is adbox2_0:addlabel("LATITUDE").
		set adlab2_0:style:height to 12.5.
		set adlab2_0:style:align to "center".
		local LZ1_LATinp is adbox2_0:addtextfield().
	local adbox2_1 is adbox2:addvbox().
		local adlab2_2 is adbox2_1:addlabel("LONGITUDE").
		set adlab2_2:style:height to 12.5.
		set adlab2_2:style:align to "center".
		local LZ1_LNGinp is adbox2_1:addtextfield().

local adbox3 is advancedGUI:addhlayout().
set adbox3:style:align to "center".
	local adbox3_0 is adbox3:addhbox().
		local adlab3_0 is adbox3_0:addlabel("Landing Zone 2 (Secondary)").
		set adlab3_0:style:height to 20.
		set adlab3_0:style:align to "center".

local adbox4 is advancedGUI:addhlayout().
set adbox4:style:align to "center".
	local adbox4_0 is adbox4:addvbox().
		local adlab4_0 is adbox4_0:addlabel("LATITUDE").
		set adlab4_0:style:height to 12.5.
		set adlab4_0:style:align to "center".
		local LZ2_LATinp is adbox4_0:addtextfield().
	local adbox4_1 is adbox4:addvbox().
		local adlab4_4 is adbox4_1:addlabel("LONGITUDE").
		set adlab4_4:style:height to 12.5.
		set adlab4_4:style:align to "center".
		local LZ2_LNGinp is adbox4_1:addtextfield().

local adbox5 is advancedGUI:addhlayout().
set adbox5:style:align to "center".
	local adbox5_0 is adbox5:addhbox().
		local adlab5_0 is adbox5_0:addlabel("Landing Zone 3 (Droneship)").
		set adlab5_0:style:height to 20.
		set adlab5_0:style:align to "center".

local adbox6 is advancedGUI:addhlayout().
set adbox6:style:align to "center".
	local adbox6_0 is adbox6:addvbox().
		local adlab6_0 is adbox6_0:addlabel("LATITUDE").
		set adlab6_0:style:height to 12.5.
		set adlab6_0:style:align to "center".
		local LZ3_LATinp is adbox6_0:addtextfield().
	local adbox6_1 is adbox6:addvbox().
		local adlab6_6 is adbox6_1:addlabel("LONGITUDE").
		set adlab6_6:style:height to 12.5.
		set adlab6_6:style:align to "center".
		local LZ3_LNGinp is adbox6_1:addtextfield().

local adlaunchButton is advancedGUI:addbutton("SAVE COORDINATES").

// GUI handler

local pLex is lexicon().
local lLex is lexicon().
local tgtExists is false.

if (exists("0:/params1.json")) {
	set pLex to readjson("0:/params1.json").

	local tgtList is list().
	list targets in tgtList.
	for tgt in tgtList {
		if (tgt:name = pLex["tgtInp"]) {
			set tgtExists to true.
		}
	}
	
	if (pLex["tgtInp"]:length > 0 and tgtExists) {
		set target to pLex["tgtInp"].
	}
	else {
		set target to "".
	}
} 
else {
	set pLex to lexicon(
		"rocketType", 0,		// 1-GHIDORAH, 2-GOJIRA
		"landProfile", 0,		
		"payloadMass", 0,
		"tgtOrb", 0,
		"tgtInc", 0,
		"payloadType", "",		// 1-FAIRING, 2-CREW, 3-CARGO
		"rendBool", 0,			// (will wait for launch window?)
		"tgtInp", ""			// (target name)
	).
}

if (exists("0:/advcfg.json")) {
	set lLex to readjson("0:/advcfg.json").

	set LZ1_LATinp:text to lLex["LZ1"]:lat:tostring.
	set LZ1_LNGinp:text to lLex["LZ1"]:lng:tostring.

	set LZ2_LATinp:text to lLex["LZ2"]:lat:tostring.
	set LZ2_LNGinp:text to lLex["LZ2"]:lng:tostring.

	set LZ3_LATinp:text to lLex["LZ0"]:lat:tostring.
	set LZ3_LNGinp:text to lLex["LZ0"]:lng:tostring.
}
else {

	// default coordinates
	set lLex to lexicon(
		"LZ0", latlng(-0.11, -70),
		"LZ1", latlng(-0.132287731225158, -74.5494025150112),
		"LZ2", latlng(-0.140425956708956, -74.5495256417959)
	).

	set LZ1_LATinp:text to lLex["LZ1"]:lat:tostring.
	set LZ1_LNGinp:text to lLex["LZ1"]:lng:tostring.

	set LZ2_LATinp:text to lLex["LZ2"]:lat:tostring.
	set LZ2_LNGinp:text to lLex["LZ2"]:lng:tostring.

	set LZ3_LATinp:text to lLex["LZ0"]:lat:tostring.
	set LZ3_LNGinp:text to lLex["LZ0"]:lng:tostring.

	writejson(lLex, "0:/advcfg.json").
}

set ABORTButton:onclick to ABORT_del@.
set REBOOTButton:onclick to REBOOT_del@.
set ADVANCEDButton:ontoggle to ADVANCED_del@.

LV_del(LVpup:value).
set LVpup:onchange to LV_del@.

set ALTinp:onchange to ALT_del@.
set INCinp:onchange to INC_del@.
set MASSinp:onchange to MASS_del@.

set ORBrad:onclick to ORBT_del@.
set DCKrad:onclick to DOCK_del@.
set TGTinp:onchange to TGTN_del@.

set adlaunchButton:onclick to CRDS_del@.

local boosterLookup0 is 0.
local boosterLookup1 is 0.

if (exists("0:/params1.json")) {

	if (coreIterate < 2 or (coreIterate = 2 and pLex["landProfile"] < 4)) {
		set popupList[0]:index to 0.
		set boosterLookup0 to 1.
		boosterRecMode(popupList[0]:value, 0).
		if (coreIterate = 2) { boosterRecMode(popupList[1]:value, 1). }
	}
	else {

		if (pLex["landProfile"] = 1) { 
			set popupList[0]:index to 0.
			set boosterLookup0 to 1.
		}
		if (pLex["landProfile"] = 2) { 
			set popupList[0]:index to 1.
			set boosterLookup0 to 2.
			
		}
		if (pLex["landProfile"] = 3) { 
			set popupList[0]:index to 2.
			set boosterLookup0 to 3.
		}
		if (pLex["landProfile"] = 4) { 
			set popupList[0]:index to 0.
			set popupList[1]:index to 1. 
			set boosterLookup0 to 2.
			set boosterLookup1 to 1.
		}
		if (pLex["landProfile"] = 5) { 
			set popupList[0]:index to 1.
			set popupList[1]:index to 0. 
			set boosterLookup0 to 3.
			set boosterLookup1 to 1.
		}
		if (pLex["landProfile"] = 6) { 
			set popupList[0]:index to 1.
			set popupList[1]:index to 1. 
			set boosterLookup0 to 3.
			set boosterLookup1 to 2.
		}
	}
}
else {
	REC_del0(popupList[0]:value).
	if (popupList:length = 2) {
		REC_del1(popupList[1]:value).
	}
}

set popupList[0]:onclick to { return boosterRecMode(popupList[0]:value, 0). }.
set popupList[0]:onchange to REC_del0@.
if (popupList:length = 2) {
	set popupList[1]:onchange to REC_del1@.
}

local rtypeCHK is true.
local lprofileCHK is true.
local massCHK is false.
local altCHK is false.
local incCHK is false.
local orbCHK is false.
local nameCHK is true.
local voidCHK is true.

function ABORT_del {
	abort on.
	
	local rep is 0.
	until (rep = 10) {
		set ABORTButton:style:textcolor to red.
		wait 0.1 - (rep * 0.005).
		set ABORTButton:style:textcolor to black.
		wait 0.1  - (rep * 0.005).
		set rep to rep + 1.
	}
	
	clearguis().
	// shutdown.
}
function REBOOT_del {
	clearscreen. clearguis().
	reboot.
}
function ADVANCED_del {
	parameter val.

	if (exists("0:/advcfg.json")) {
		set lLex to readjson("0:/advcfg.json").
	}
	if (val) { advancedGUI:show(). }
	else { advancedGUI:hide(). }
}

function LV_del {
	parameter choice.

	if (choice = "Falcon 9 / Heavy + Fairings") { set pLex["rocketType"] to 1. set pLex["payloadType"] to 1. }
	if (choice = "Falcon 9 + Dragon V2") { set pLex["rocketType"] to 1. set pLex["payloadType"] to 2. }
	if (choice = "Falcon 9 + Dragon V1") { set pLex["rocketType"] to 1. set pLex["payloadType"] to 3. }
	if (choice = "Superheavy + Starship") { set pLex["rocketType"] to 2. set pLex["payloadType"] to 1. }
}

function REC_del0 {
	parameter choice.
	boosterRecMode(choice, 0).
}
function REC_del1 {
	parameter choice.
	boosterRecMode(choice, 1).
}
function boosterRecMode {
	parameter choice, popupNo.
	// 1 - RTLS-S, 2 - ASDS-S, 3 - XPND-S,
	// 4 - C_ASDS + B_RTLS
	// 5 - C_XPND + B_RTLS
	// ! - C_ASDS + B_XPND !should be invalid case
	// 6 - C_XPND + B_XPND

	if (choice = "Core - RTLS" and popupNo = 0) { set boosterLookup0 to 1. }
	if (choice = "Core - ASDS" and popupNo = 0) { set boosterLookup0 to 2. }
	if (choice = "Core - XPND" and popupNo = 0) { set boosterLookup0 to 3. }

	if (choice = "Boosters - RTLS" and popupNo = 1) { set boosterLookup1 to 1. }
	if (choice = "Boosters - XPND" and popupNo = 1) { set boosterLookup1 to 2. }

	if (boosterLookup1 > 0) {
		if (boosterLookup0 = 2 and boosterLookup1 = 1) { set pLex["landProfile"] to 4. }
		if (boosterLookup0 = 3 and boosterLookup1 = 1) { set pLex["landProfile"] to 5. }
		if (boosterLookup0 = 2 and boosterLookup1 = 2) { set pLex["landProfile"] to 0. }
		if (boosterLookup0 = 3 and boosterLookup1 = 2) { set pLex["landProfile"] to 6. }
	}
	else {
		if (boosterLookup0 = 1) { set pLex["landProfile"] to 1. }
		if (boosterLookup0 = 2) { set pLex["landProfile"] to 2. }
		if (boosterLookup0 = 3) { set pLex["landProfile"] to 3. }
	}
}

function ALT_del { parameter val.
	if (val:tostring:length > 0) { 
		set pLex["tgtOrb"] to val:tonumber * 1000. 
		set altCHK to true.
	} 
	else {
		set altCHK to false.
	}
}
function INC_del { parameter val.
	if (val:tostring:length > 0) { 
		set pLex["tgtInc"] to val:tonumber.
		set incCHK to true.
	} 
	else {
		set incCHK to false.
	}
}
function MASS_del { parameter val.
	if (val:tostring:length > 0) { 
		set pLex["payloadMass"] to val:tonumber. 
		set massCHK to true.
	} 
	else { set massCHK to false. }
}

function ORBT_del {
	if (ORBrad:pressed) { 
		set pLex["rendBool"] to 0. 
		set pLex["tgtInp"] to "". 
		set target to "".
		TGTinp:hide(). 
	}
}
function DOCK_del {
	if (DCKrad:pressed) { 
		set pLex["rendBool"] to 1.
		TGTinp:show(). 
	}	// rendBool = rendezvous bool
}

function TGTN_del { parameter val.
	if (val:tostring:length > 0) { set pLex["tgtInp"] to val. } 
	else { 
		if (hasTarget) {set pLex["tgtInp"] to target:name. }
		else { set pLex["tgtInp"] to "". }
	}
}

function CRDS_del {

	set lLex["LZ1"] to latlng(LZ1_LATinp:text:tonumber, LZ1_LNGinp:text:tonumber).
	set lLex["LZ2"] to latlng(LZ2_LATinp:text:tonumber, LZ2_LNGinp:text:tonumber).
	set lLex["LZ0"] to latlng(LZ3_LATinp:text:tonumber, LZ3_LNGinp:text:tonumber).

	writejson(lLex, "0:/advcfg.json").
	set ADVANCEDButton:pressed to false.
}

function startMissionChecker {
	if (hasTarget and (pLex["rendBool"] = 1)) { set pLex["tgtInp"] to target:name. }
	if ((pLex["rendBool"] = 1 and pLex["tgtInp"]:tostring:length > 0) or hasTarget) { set nameCHK to true. } 
	else if ((pLex["rendBool"] = 0 and pLex["tgtInp"]:tostring:length = 0) or hasTarget) { set nameCHK to true. }
	else { set nameCHK to false. }
	
	// check if inputs are filled before starting a new mission
	if (massCHK and altCHK and incCHK) {
		if (ORBrad:pressed or DCKrad:pressed) { set orbCHK to true. }
	}
	
	// add check for special case here (ex. heavy SS doesn't exist, therefore shouldn't receive a go)
	if (pLex["rocketType"] = 2 and pLex["landProfile"] > 2) { set voidCHK to false. }
	else {set voidCHK to true.}
	
	if (pLex["rocketType"] > 0 and
		pLex["landProfile"] > 0 and
		massCHK and
		altCHK and
		incCHK and
		pLex["payloadType"] > 0) and
		(nameCHK and rtypeCHK and lprofileCHK and orbCHK and voidCHK)
	{
		set launchButton:enabled to true.
	} 
	else {
		set launchButton:enabled to false.
	}
}

on abort { ABORT_del(). }
if (core:tag = "") { missionGUI:show(). }
startMissionChecker().

// COMMENT LINE BELOW FOR QUICK DEBUG mode
until (launchButton:pressed or loadButton:pressed) { startMissionChecker(). }

local startT is time:seconds.
when (time:seconds > startT + 1.5) then { missionGUI:hide(). }
startMissionChecker().

// serialize lexicons here
if (launchButton:pressed) {
	writejson(pLex, "0:/params1.json").
}


missionGUI:hide().
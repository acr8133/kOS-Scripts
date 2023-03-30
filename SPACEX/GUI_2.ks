rcs off. 
// when rcs then { reboot. }
clearguis(). clearscreen.

// CREATE GUI

local blu_clr is rgb(100/255,110/255,220/255).
local gra_clr is rgb(245/255,245/255,245/255).
local drk_clr is rgb(0/255,16/255,25/255).
local lim_clr is rgb(100/255,230/255,20/255).

global missionGUI is GUI(320).
set missionGUI:style:width to 320.
set missionGUI:style:padding:h to 18.
set missionGUI:style:padding:v to 15.
set missionGUI:style:bg to "ASSET/gui_bg".
set missionGUI:style:border:h to 512/3.
set missionGUI:style:border:v to 512/3.

set missionGUI:skin:popupmenu:active:bg to "ASSET/hover_bg".
set missionGUI:skin:popupmenu:active_on:bg to "ASSET/hover_bg".
set missionGUI:skin:popupmenu:normal:bg to "ASSET/hover_bg".
set missionGUI:skin:popupmenu:normal_on:bg to "ASSET/hover_bg".
set missionGUI:skin:popupmenu:hover:bg to "ASSET/hover_bg".
set missionGUI:skin:popupmenu:hover_on:bg to "ASSET/hover_bg".

set missionGUI:skin:popupwindow:bg to "ASSET/label_bg".

set missionGUI:skin:popupmenuitem:bg to "ASSET/label_bg".
set missionGUI:skin:popupmenuitem:hover:bg to "ASSET/hover_bg".

set missionGUI:skin:popupwindow:textcolor to drk_clr.
set missionGUI:skin:popupmenuitem:textcolor to drk_clr.

set missionGUI:skin:button:active:bg to "ASSET/label_bg".
set missionGUI:skin:button:active_on:bg to "ASSET/hover_bg".
set missionGUI:skin:button:normal:bg to "ASSET/label_bg".
set missionGUI:skin:button:normal_on:bg to "ASSET/hover_bg".
set missionGUI:skin:button:hover:bg to "ASSET/hover_bg".
set missionGUI:skin:button:hover_on:bg to "ASSET/label_bg".

local header_box is missionGUI:addhlayout().
	local title_box is header_box:addvlayout().
		local title_0 is title_box:addlabel("SpaceX Launch").
		set title_0:style:fontsize to 24.
		set title_0:style:textcolor to gra_clr.
		set title_0:style:font to "consolas".
		set title_0:style:margin:bottom to 0.
		set title_0:style:padding:bottom to 0.
		local title_1_div is title_box:addhlayout().
			local title_1_0 is title_1_div:addlabel("Software").
			set title_1_0:style:fontsize to 24.
			set title_1_0:style:textcolor to gra_clr.
			set title_1_0:style:font to "consolas".
			set title_1_0:style:hstretch to false.
			local title_1_1 is title_1_div:addlabel("<b>v0.2</b>").
			set title_1_1:style:fontsize to 24.
			set title_1_1:style:textcolor to blu_clr.
			set title_1_1:style:font to "consolas".

	global loadButton is header_box:addbutton().
	set loadButton:style:width to 38.
	set loadButton:style:height to 38.
	set loadButton:style:margin:top to 10.
	set loadButton:style:margin:right to 5.
	set loadButton:style:padding:right to 5.
	set loadButton:style:bg to "ASSET/empty_bg".
	set loadButton:image to "ASSET/load_ico".

local div_0 is missionGUI:addlabel().
set div_0:style:bg to "ASSET/div".
set div_0:style:align to "center".
set div_0:style:height to 2.

local sect_1 is missionGUI:addhlayout().
set sect_1:style:width to missionGUI:style:width - (missionGUI:style:padding:left + missionGUI:style:padding:right).
	
	local s1_title_0 is sect_1:addlabel("PAYLOAD").
	SubHeaderFormat(s1_title_0, 1).
	
	local s1_title_1 is sect_1:addlabel("<b>TYPE</b>").
	SubHeaderFormat(s1_title_1, 2).

local sect_2 is missionGUI:addhlayout().
set sect_2:style:width to missionGUI:style:width - (missionGUI:style:padding:left + missionGUI:style:padding:right).
set sect_2:style:height to 20.

	sect_2:addspacing(-1).
	local s2_button_0 is sect_2:addbutton("FAIRINGS").
	PayloadTypeFormat(s2_button_0, sect_2).
	set s2_button_0:toggle to true.
	set s2_button_0:exclusive to true.
	sect_2:addspacing(1).

	local s2_button_1 is sect_2:addbutton("DRAGON 2").
	PayloadTypeFormat(s2_button_1, sect_2).
	set s2_button_1:toggle to true.
	set s2_button_1:exclusive to true.
	sect_2:addspacing(1).

	local s2_button_2 is sect_2:addbutton("DRAGON 1").
	PayloadTypeFormat(s2_button_2, sect_2).
	set s2_button_2:toggle to true.
	set s2_button_2:exclusive to true.
	sect_2:addspacing(1).

	local s2_button_3 is sect_2:addbutton("STARSHIP").
	PayloadTypeFormat(s2_button_3, sect_2).
	set s2_button_3:toggle to true.
	set s2_button_3:exclusive to true.
	sect_2:addspacing(-1).

local div_1 is missionGUI:addlabel().
set div_1:style:bg to "ASSET/div".
set div_1:style:align to "center".
set div_1:style:height to 2.
set div_1:style:margin:top to 17.5.

local sect_3 is missionGUI:addhlayout().
set sect_3:style:width to missionGUI:style:width - (missionGUI:style:padding:left + missionGUI:style:padding:right).
	
	local s3_title_0 is sect_3:addlabel("ORBITAL").
	SubHeaderFormat(s3_title_0, 1).
	
	local s3_title_1 is sect_3:addlabel("<b>MANEUVERING</b>").
	SubHeaderFormat(s3_title_1, 2).

local sect_4 is missionGUI:addvbox().
set sect_4:style:width to missionGUI:style:width - (missionGUI:style:padding:left + missionGUI:style:padding:right).
set sect_4:style:bg to "ASSET/empty_bg".

	local s4_row_0 is sect_4:addhlayout().
	set s4_row_0:style:width to sect_4:style:width.
	Zero_MarginPadding(s4_row_0).

		local s4_opt_0 is s4_row_0:addvlayout().
		set s4_opt_0:style:width to s4_row_0:style:width / 3.
		Zero_MarginPadding(s4_opt_0).
			local s4_opt_0_t is s4_opt_0:addlabel("APOAPSIS").
			OrbitParameterFormat(s4_opt_0_t).
			local APOinp is s4_opt_0:addtextfield().
			OrbitParameterTextFieldFormat(APOinp, false).

		local s4_opt_1 is s4_row_0:addvlayout().
		set s4_opt_1:style:width to s4_row_0:style:width / 3.
		Zero_MarginPadding(s4_opt_1).
			local s4_opt_1_t is s4_opt_1:addlabel("PERIAPSIS").
			OrbitParameterFormat(s4_opt_1_t).
			local PERinp is s4_opt_1:addtextfield().
			OrbitParameterTextFieldFormat(PERinp, false).

		local s4_opt_2 is s4_row_0:addvlayout().
		set s4_opt_2:style:width to s4_row_0:style:width / 3.
		Zero_MarginPadding(s4_opt_2).
			local s4_opt_2_t is s4_opt_2:addlabel("INCLINATION").
			OrbitParameterFormat(s4_opt_2_t).
			local INCinp is s4_opt_2:addtextfield().
			OrbitParameterTextFieldFormat(INCinp, false).

	local s4_row_1 is sect_4:addhlayout().
	set s4_row_1:style:width to sect_4:style:width.
	Zero_MarginPadding(s4_row_1).
	set s4_row_1:style:margin:bottom to 10.
	set s4_row_1:style:align to "center".

		local s4_opt_3 is s4_row_1:addvlayout().
		set s4_opt_3:style:width to s4_row_1:style:width / 3.
		Zero_MarginPadding(s4_opt_3).
		set s4_opt_3:style:align to "center".
			local s4_opt_3_t is s4_opt_3:addlabel("LAN").
			OrbitParameterFormat(s4_opt_3_t).
			local LAN_opt is s4_opt_3:addhlayout().
				local LANinp is LAN_opt:addtextfield().
				OrbitParameterTextFieldFormat(LANinp).
				local LANbut is LAN_opt:addbutton("I").
				OrbitParameterButtonFormat(LANbut).

		local s4_opt_4 is s4_row_1:addvlayout().
		set s4_opt_4:style:width to s4_row_1:style:width / 3.
		Zero_MarginPadding(s4_opt_4).
		set s4_opt_4:style:align to "center".
			local s4_opt_4_t is s4_opt_4:addlabel("AOP").
			OrbitParameterFormat(s4_opt_4_t).
			local AOP_opt is s4_opt_4:addhlayout().
				local AOPinp is AOP_opt:addtextfield().
				OrbitParameterTextFieldFormat(AOPinp).
				local AOPbut is AOP_opt:addbutton("C").
				OrbitParameterButtonFormat(AOPbut).

		local s5_opt_5 is s4_row_1:addvlayout().
		set s5_opt_5:style:width to s4_row_1:style:width / 3.
		Zero_MarginPadding(s5_opt_5).
		set s5_opt_5:style:align to "center".
			local s5_opt_5_t is s5_opt_5:addlabel("MASS").
			OrbitParameterFormat(s5_opt_5_t).
			local MASSinp is s5_opt_5:addtextfield().
			OrbitParameterTextFieldFormat(MASSinp, false).

	local s4_row_2 is sect_4:addhlayout().
	set s4_row_2:style:width to sect_4:style:width.
	Zero_MarginPadding(s4_row_2).
	set s4_row_2:style:align to "center".

		local s4_opt_5 is s4_row_2:addbutton("ORBIT").
		OrbitModeFormat(s4_opt_5, s4_row_2, "right").
		set s4_opt_5:toggle to true. 
		set s4_opt_5:exclusive to true. 

		local s4_opt_6 is s4_row_2:addbutton("DOCK").
		OrbitModeFormat(s4_opt_6, s4_row_2, "left").
		set s4_opt_6:toggle to true. 
		set s4_opt_6:exclusive to true. 


local div_2 is missionGUI:addlabel().
set div_2:style:bg to "ASSET/div".
set div_2:style:align to "center".
set div_2:style:height to 2.
set div_2:style:margin:top to 10.

local sect_5 is missionGUI:addhlayout().
set sect_5:style:width to missionGUI:style:width - (missionGUI:style:padding:left + missionGUI:style:padding:right).

	local s5_title_0 is sect_5:addlabel("BOOSTER").
	SubHeaderFormat(s5_title_0, 1).
	
	local s5_title_1 is sect_5:addlabel("<b>RECOVERY</b>").
	SubHeaderFormat(s5_title_1, 2).

local sect_6 is missionGUI:addhlayout().
set sect_6:style:width to missionGUI:style:width - (missionGUI:style:padding:left + missionGUI:style:padding:right).

	local s6_container is sect_6:addvlayout().

	list processors in coreList.
	local popupList is list().
	local coreIterate is 0.

	for core in coreList {
		for core in coreList {
			
			if (core:part:tag = "1" and coreIterate = 0) {
				set coreIterate to coreIterate + 1.
				popupList:add(s6_container:addpopupmenu()).
				popupList[coreIterate - 1]:addoption("Core - RTLS").
				popupList[coreIterate - 1]:addoption("Core - ASDS").
				popupList[coreIterate - 1]:addoption("Core - XPND").
			}

			if ((core:part:tag = "2" or core:part:tag = "3") and coreIterate = 1) {
				set popupList[0]:index to 1.
				popupList[0]:options:remove(0).
				set popupList[0]:index to 0.
				
				set coreIterate to coreIterate + 1.
				popupList:add(s6_container:addpopupmenu()).
				popupList[coreIterate - 1]:addoption("Boosters - RTLS").
				popupList[coreIterate - 1]:addoption("Boosters - XPND").
			}
		}
	}

	if (popupList:length > 0) { PopUpFormat(0). }
	if (popupList:length > 1) { PopUpFormat(1). }

local div_3 is missionGUI:addlabel().
set div_3:style:bg to "ASSET/div".
set div_3:style:align to "center".
set div_3:style:height to 2.
set div_3:style:margin:top to 10.

local sect_7 is missionGUI:addvlayout().
set sect_7:style:width to missionGUI:style:width - (missionGUI:style:padding:left + missionGUI:style:padding:right).

global launchButton is sect_7:addbutton("- START MISSION -").
Zero_MarginPadding(launchButton).
FinalButtonsFormat(launchButton).

missionGUI:show().

// HANDLE GUI

local pLex is lexicon().
local tgtExists is false.

if (exists("0:/params1.json")) {
	set pLex to readjson("0:/params1.json").

	local tgtList is list().
	list targets in tgtList.
	for tgt in tgtList {
		if (tgt:name = pLex["rndBool"]) {
			set tgtExists to true.
		}
	}
	
	if (pLex["rndBool"]:length > 0 and tgtExists) {
		set target to pLex["rndBool"].
	}
	else {
		set target to "".
	}

	set loadButton:enabled to true.
}
else {
	set pLex to lexicon(
		"payloadType", 0,		// 1-F9, 2-D2, 3-D1, 4-SS 
		"tgtOrbAP", 0,
		"tgtOrbPE", 0,
		"tgtInc", 0,
		"tgtLan", 0,
		"tgtAop", 0,
		"payloadMass", 0,
		"rndBool", "",			// tgt name, empty if manual input
		"landProfile", 0
	).

	set loadButton:enabled to false.
}

local pTypeCHK is false.
local altAPCHK is false.
local altPECHK is false.
local incCHK is false.
local lanCHK0 is false.
local lanCHK1 is false.
local aopCHK0 is false.
local aopCHK1 is false.
local massCHK is false.
local orbmdCHK is false.
local voidCHK is true.

set s2_button_0:onclick to PayloadType_del@.
set s2_button_1:onclick to PayloadType_del@.
set s2_button_2:onclick to PayloadType_del@.
set s2_button_3:onclick to PayloadType_del@.
set APOinp:onchange to AP_del@.
set PERinp:onchange to PE_del@.
set INCinp:onchange to INC_del@.
set LANinp:onchange to LAN_del@.
set LANbut:ontoggle to LAN_del@.
set AOPinp:onchange to AOP_del@.
set AOPbut:ontoggle to AOP_del@.
set MASSinp:onchange to MASS_del@.
set s4_opt_5:onclick to OrbitMode_del@.

local boosterLookup0 is 0.
local boosterLookup1 is 0.

if (exists("0:/params1.json")) {

	if (coreIterate < 2 or (coreIterate = 2 and pLex["landProfile"] < 4)) {
		set popupList[0]:index to 0.
		set boosterLookup0 to 1.
		BoosterType_del(popupList[0]:value, 0).
		if (coreIterate = 2) { BoosterType_del(popupList[1]:value, 1). }
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

set popupList[0]:onclick to { return BoosterType_del(popupList[0]:value, 0). }.
set popupList[0]:onchange to REC_del0@.
if (popupList:length = 2) {
	set popupList[1]:onchange to REC_del1@.
}

startMissionChecker().

until (launchButton:pressed or loadButton:pressed) { startMissionChecker(). dbg(). wait 0. }
if (launchButton:pressed) {
	writejson(pLex, "0:/params1.json").
}

if (loadButton:pressed) {
	set launchButton:enabled to true.
}
set launchButton:pressed to false.

// missionGUI:hide().
// DO ALL HANDLING!!

// function Load_del {
// 	reboot.
// }

function PayloadType_del {
	if (s2_button_0:pressed) { set pLex["payloadType"] to 1. }
	if (s2_button_1:pressed) { set pLex["payloadType"] to 2. }
	if (s2_button_2:pressed) { set pLex["payloadType"] to 3. }
	if (s2_button_3:pressed) { set pLex["payloadType"] to 4. }
	set pTypeCHK to true.
	print pLex["payloadType"] at (0, 0).
}

function AP_del { parameter val.
	if (val:tostring:length > 0) { 
		set pLex["tgtOrbAP"] to val:tonumber * 1000. 
		set altAPCHK to true.
	} 
	else { set altAPCHK to false. }
	print pLex["tgtOrbAP"] at (0, 1).
}
function PE_del { parameter val.
	if (val:tostring:length > 0) { 
		set pLex["tgtOrbPE"] to val:tonumber * 1000. 
		set altPECHK to true.
	} 
	else { set altPECHK to false. }
	print pLex["tgtOrbPE"] at (0, 2).

}
function INC_del { parameter val.
	if (val:tostring:length > 0) { 
		set pLex["tgtInc"] to val:tonumber. 
		set incCHK to true.
	} 
	else { set incCHK to false. }
	print pLex["tgtInc"] at (0, 3).
}
function LAN_del { parameter val.
	if (val:typename = "string") {
		if (val:tostring:length > 0) { 
			set pLex["tgtLan"] to val:tonumber. 
			set lanCHK0 to true.
		}
		else { set lanCHK0 to false. }
		set lanCHK1 to false.
		set LANbut:pressed to false.
	}
	else {
		set pLex["tgtLan"] to true.
		set LANinp:text to "".
		if (val) { set lanCHK1 to true.} 
		else { set lanCHK1 to false. }
		set lanCHK0 to false.
	}
	print pLex["tgtLan"] at (0, 4).
}
function AOP_del { parameter val.
	if (val:typename = "string") {
		if (val:tostring:length > 0) { 
			set pLex["tgtAop"] to val:tonumber. 
			set aopCHK0 to true.
		}
		else { set aopCHK0 to false. }
		set aopCHK1 to false.
		set AOPbut:pressed to false.
	}
	else {
		set pLex["tgtAop"] to true.
		set AOPinp:text to "".
		if (val) { set aopCHK1 to true.} 
		else { set aopCHK1 to false. }
		set aopCHK0 to false.
	}
	print pLex["tgtAop"] at (0, 5).
}
function MASS_del { parameter val.
	if (val:tostring:length > 0) { 
		set pLex["payloadMass"] to val:tonumber. 
		set massCHK to true.
	} 
	else { set massCHK to false. }
	print pLex["payloadMass"] at (0, 6).
}

function OrbitMode_del {
	if (s4_opt_5:pressed) { 
		set target to "".
		set pLex["rndBool"] to "".
		s4_row_0:show(). s4_row_1:show().
		set orbmdCHK to true.
	}
	if (s4_opt_6:pressed) {
		if (hasTarget) { 
			set pLex["rndBool"] to target.
			set orbmdCHK to true.
		}
		else {
			set pLex["rndBool"] to "". 
			set orbmdCHK to false.
		}
		s4_row_0:hide(). s4_row_1:hide().
	}
	
	print pLex["rndBool"] at (0, 7).
}

function REC_del0 {
	parameter choice.
	BoosterType_del(choice, 0).
}
function REC_del1 {
	parameter choice.
	BoosterType_del(choice, 1).
}
function BoosterType_del {
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
	print pLex["landProfile"] at (0, 7).
}

function startMissionChecker {

	if ((pLex["payloadType"] = 4 and pLex["landProfile"] > 3) or
		pLex["payloadType"] = 0 or 
		pLex["landProfile"] = 0 or
		(pLex["tgtOrbAP"] < pLex["tgtOrbPE"])) { 
		set voidCHK to false. 
	}
	else { set voidCHK to true. }

	if (pTypeCHK and altAPCHK and altPECHK and incCHK and
		(lanCHK0 or lanCHK1) and (aopCHK0 or aopCHK1) and 
		massCHK and orbmdCHK and voidCHK)
	{
		set launchButton:enabled to true.
	}
	else {
		set launchButton:enabled to false.
	}

}

function dbg {
	local ln_start is 30.
	
	print pTypeCHK at (0, ln_start + 0).
	print altAPCHK at (0, ln_start + 1).
	print altPECHK at (0, ln_start + 2).
	print incCHK at (0, ln_start + 3).
	print (lanCHK0 or lanCHK1) at (0, ln_start + 4).
	print (aopCHK0 or aopCHK1) at (0, ln_start + 5).
	print orbmdCHK at (0, ln_start + 6).
	print voidCHK at (0, ln_start + 7).
}

// FORMAT FUNCTIONS

function Zero_MarginPadding {
	parameter label, side is "s".

	if (side = "s") {
		set label:style:padding:h to 0.
		set label:style:padding:v to 0.
	}
}

function SubHeaderFormat {
	parameter label, mode.
	
	if (mode = 1) {
		set label:style:fontsize to 16.
		set label:style:height to 20.
		set label:style:font to "consolas".
		set label:style:textcolor to gra_clr.
		set label:style:hstretch to false.
	} 
	else {
		set label:style:fontsize to 16.
		set label:style:height to 20.
		set label:style:font to "consolas".
		set label:style:textcolor to blu_clr.
		set label:style:hstretch to false.
		set label:style:richtext to true.
	}
}

function PayloadTypeFormat {
	parameter label, labelParent.
	
	set label:style:bg to "ASSET/label_bg".
	set label:style:margin:left to 1.
	set label:style:margin:right to 1.
	set label:style:width to (labelParent:style:width / 4) - 3.
	set label:style:height to 21.
	set label:style:textcolor to drk_clr.	
	set label:style:fontsize to 12.
	set label:style:font to "consolas".
}

function OrbitParameterFormat {
	parameter label.

	set label:style:fontsize to 13.
	set label:style:height to 13.
	set label:style:align to "center".
	set label:style:font to "consolas".
	set label:style:textcolor to gra_clr.
	set label:style:hstretch to true.
	set label:style:richtext to true.
	set label:style:margin:top to 2.
	set label:style:margin:bottom to 5.
}

function OrbitParameterTextFieldFormat {
	parameter label, adj is true.

	set label:style:height to 20 - 1.
	set label:style:fontsize to 13.
	set label:style:textcolor to gra_clr.
	set label:style:margin:top to 0.
	set label:style:margin:bottom to 3.
	set label:style:padding:top to 2.
	set label:style:padding:bottom to 0.
	if (adj) { set label:style:margin:right to 0. }
}

function OrbitParameterButtonFormat {
	parameter label.

	set label:style:fontsize to 17.
	set label:style:height to 20.
	set label:style:width to 20.
	set label:style:align to "center".
	set label:style:font to "consolas".
	set label:style:textcolor to drk_clr.
	set label:style:hstretch to false.
	set label:style:padding:h to 0.
	set label:style:padding:top to 0.
	set label:style:padding:bottom to 2.
	set label:style:padding:left to 1.
	set label:style:margin:left to 0.
	set label:style:margin:top to 0.
	set label:toggle to true.
}

function PopUpFormat {
	parameter indexNo.

	set popupList[indexNo]:style:bg to "ASSET/label_bg".
	set popupList[indexNo]:style:textcolor to drk_clr.
	set popupList[indexNo]:style:padding:left to 5.
	set popupList[indexNo]:style:padding:right to 0.
	set popupList[indexNo]:style:padding:top to 2.
	set popupList[indexNo]:style:padding:bottom to 2.
	set popupList[indexNo]:style:fontsize to 15.
	set popupList[indexNo]:style:height to 25.
	set popupList[indexNo]:style:font to "consolas".
	set popupList[indexNo]:image to "ASSET/popup_ico".
}

function OrbitModeFormat {
	parameter label, labelParent, side.

	set label:style:width to (labelParent:style:width / 2) - 8.
	set label:style:padding:left to 0.
	set label:style:padding:right to 0.
	set label:style:margin:left to 0.
	set label:style:margin:right to 0.
	set label:style:bg to "ASSET/label_bg".
	set label:style:textcolor to drk_clr.
	set label:style:fontsize to 13.
	set label:style:height to 20.
	set label:style:align to "center".
	set label:style:font to "consolas".

	if (side = "right") { 
		set label:style:margin:right to 8.
		set label:style:margin:left to 4.
	}
	else { set label:style:margin:left to 8. }
}

function FinalButtonsFormat {
	parameter label.

	set label:style:bg to "ASSET/go_bg".
	set label:style:active:bg to "ASSET/go_bg".
	set label:style:active_on:bg to "ASSET/go_bg".
	set label:style:normal:bg to "ASSET/go_bg".
	set label:style:normal_on:bg to "ASSET/go_bg".
	set label:style:hover:bg to "ASSET/go_bg".
	set label:style:hover_on:bg to "ASSET/go_bg".
	set label:style:textcolor to drk_clr.
	set label:style:fontsize to 35.
	set label:style:height to 35.
	set label:style:align to "center".
	set label:style:font to "dotty".
	set label:style:padding:top to 16	.
	set label:style:padding:bottom to 10.
	// set label:style:border:v to 12.
}

// params1.json - user input
// params2.json - params1 + mission constants
// params3.json - pad save data
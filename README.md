
## **Required Mods**
- **Tundra Exploration**
- **Trajectories**
- **kOSForAll**
- **RSVP**
	- _Required library for your interplanetary launches._
- **Rescale 2.5x**
- **MechJeb**
	- _Mechjeb removes engine spool from Tundra engines._
- **Module Manager**
	- _Custom patches are needed for the script to work, paste the **ModuleManagerPatch** into your Gamedata._
- **FMRS**
	- _Not required, script is compatible though._
	- _Set the delay to 3 seconds._
- _and all of these mods' dependencies..._

## Action Groups
- AG1 - Falcon 9 SL Engines > Toggle Engine Mode
- AG2 - Engines, Tanks, Interstage / Nosecones > Toggle Soot
- AG3 - Falcon Heavy Booster Engines > Toggle Engine
- AG4 - Dragon Capsule > toggle | Toggle Side RCS thrusters
- AG5 - Dragon Capsule > Toggle Bulkhead RCS thrusters

## **Setup**
- Place **SX_boot.ks** into the booster's interstage/nosecone and the payload's core.
- Setting of nametags for the boosters was updated to happen automatically. You still have to name your ports **'APAS'**
	
## **Mission GUI**
- **LOAD LAST PARAMETERS (BLUE FILE ICON)**
	- With this button, you don't have to input last time's parameters every time you want to launch. Makes repetitive mission _(ehem.. Starlink)_ less tedious.
- **PAYLOAD TYPE**
	- _Choose the correct configuration for your mission._
- **ORBITAL MANEUVERING**
	- Target AP and PE in **kilometers**
	- Target inclination in **degrees**.
		-  _0 = equatorial_
		- _90 = polar, northbound_
		- _180 = equatorial, retrograde_
		- _270 = polar, southbound_
	- Longitude of Ascending Node (LAN) 'I Button' launches your rocket instantaneously, no windows required.
	- Argument of Periapsis (AOP) 'C Button' circularizes your orbit, overwriting set AP height.
	- Payload's mass in **kilograms**, input can be estimate / not exact.
	- Choose *'ORBIT'* to launch into your set orbital parameters, choosing *'DOCK'* will overwrite everything and the rocket will attempt to dock to a target instead.
- **BOOSTER RECOVERY**
	- Choose your desired recovery mode.
- **START NEW MISSION**
	- Start the mission! Will only be available when all parameters are filled-in.


## ASDS
Watch Quasy's video on how to setup ASDS landings [here](https://youtu.be/nxGF1jf14Lo).

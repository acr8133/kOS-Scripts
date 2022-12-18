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

## **Boot Scripts**
- Place **SX_boot.ks** into the booster's interstage and the payload's core.
	
## **Mission GUI**
- **ABT**
	- _Abort launch button, set through action groups at the VAB._
- **OVW**
	- _Overwrite default LZ coordinates._
- **LAUNCH VEHICLE AND PAYLOAD**
	- _Choose the correct configuration for your mission._
- **ORBIT ALT**
	- _Target altitude in **kilometers**, works as target parking orbit alitude when docking._
- **ORBIT INC**
	- _Target inclination in **degrees**._
	-  _0 = equatorial_
	- _90 = polar, northbound_
	- _180 = equatorial, retrograde_
	- _270 = polar, southbound_
- **PAYLOAD MASS**
	- Payload's mass in **kilograms**, input can be estimate / not exact.
- **ORBITAL MANEUVERING**
	- **ORBIT**
		- Launch into a circular orbit at target parameters.
		- Having a target set will overwrite the **ORBIT INC** input, the rocket will try to match planes with the target ship instead.
	- **DOCK**
		- **Wait** for launch window, **launch** into correct plane, **rendezvous**, and **dock** to the target.
- **BOOSTER RECOVERY MODE**
	- Choose your desired recovery mode.
- **START NEW MISSION**
	- Start the mission! Will only be available when all parameters are filled-in.
- **LOAD LAST PARAMETERS**
	- With this button, you don't have to input last time's parameters every time you want to launch. Makes repetitive mission _(ehem.. Starlink)_ less tedious.


## ASDS
Watch Quasy's video on how to setup ASDS landings [here](https://youtu.be/nxGF1jf14Lo).

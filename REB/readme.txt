REB (Radio-Electronic Warfare) System
========================================

Project Essence
---------------
REB is a modular system for Arma 3 that implements radio-electronic warfare (EW) objects with ACE3 interaction support, flexible parameter configuration, and multiplayer compatibility.

The system allows you to add EW objects (e.g., jammers, suppression stations) to the map, control their state, range, and power, and interact with them via the ACE menu. The logic is built on an object-oriented approach (OOP in SQF), ensuring extensibility and maintainability.

Main Features
-------------
- **Initialization and Registration** (`fn_reb.sqf`, `fn_rebInit.sqf`):
  Creation and setup of REB instances, registration in a global database, synchronization between server and clients.
- **ACE Integration** (`ace_actions/fn_createAceActionsForObjectReb.sqf`, `fn_removeAceActionsForObjectReb.sqf`):
  Adding and removing custom ACE actions for managing REB objects (enable/disable, parameter configuration).
- **Network Calls** (`fn_remoteCall.sqf`):
  Safe execution of functions on the server or clients with result return.
- **Parameter Management** (`fn_setRange.sqf`, `fn_setStrenght.sqf`, `fn_setValueDialog.sqf`):
  Changing range, power, and other parameters of REB objects via dialogs and ACE menu.
- **Placement Management** (`placement/`):
  Scripts for placing, attaching, detaching REB objects, and checking manipulation permissions.

Main Classes
------------
- **OO_OBJECT_REB** (`Classes/OBJECT_REB.sqf`):
  The main REB object class. Contains methods for state management, parameters, and player interaction.
- **OO_OBJECT_REB_DB** (`Classes/OBJECT_REB_DB.sqf`):
  Database of all REB objects in the mission. Allows searching, registering, and removing objects.
- **OO_REB_DB** (`Classes/REB_DB.sqf`):
  Global REB class database, responsible for creating and storing unique classes for different object types.
- **OO_REB** (`Classes/REB.sqf`):
  Base class for REB logic, can be extended for different device types.

Features
--------
- Full multiplayer support (all actions are synchronized via the server).
- Flexible macro and encapsulation system (`includes/defines.h`, `generic.h`, `oop.h`).
- Easily extendable for new REB device types and interactions.
- ACE3 integration for a user-friendly interface.

Usage
-----
To create and initialize a REB object, use the following function call:

    [object, radius, deadzone, strength, isAttachable, canModifyRange, canModifyStrength, isActive] call REB_fnc_reb;

**Parameters:**
- `object` (Object): The game object to attach the REB system to.
- `radius` (Number): The effective radius of the REB effect.
- `deadzone` (Number): The deadzone radius where the effect is inactive.
- `strength` (Number): The strength (power) of the REB effect.
- `isAttachable` (Bool): Whether the REB can be attached/detached by players.
- `canModifyRange` (Bool): Whether the range can be changed via ACE menu.
- `canModifyStrength` (Bool): Whether the strength can be changed via ACE menu.
- `isActive` (Bool): Whether the REB is active on creation.

**Example:**

    [myObject, 100, 30, 0.5, true, true, true, true] call REB_fnc_reb;

This will create a REB instance on `myObject` with a 100m radius, 30m deadzone, 0.5 strength, attachable, with modifiable range and strength, and active by default.

REB is a powerful and extensible framework for creating and managing radio-electronic warfare objects in Arma 3 missions.

// =========================================================================
// RVG Rescue Mission
//
// Flow:
//   1. Green marker at location.
//   2. Survivor + 2 guards spawn in one group with a HOLD waypoint.
//   3. Player walks within 10m → guards deleted, survivor joins player.
//   4. Player escorts survivor to MissionHQ → mission complete.
// =========================================================================

params ["_slot", "_locationName", "_locationPos"];

// ---- Slot cleanup helper ------------------------------------------------
private _fnc_removeSlot = {
    params ["_slot"];
    private _active = missionNamespace getVariable ["RVG_activeMissions", []];
    _active = _active select { (_x select 0) != _slot };
    missionNamespace setVariable ["RVG_activeMissions", _active, true];
};

// ---- Marker -------------------------------------------------------------
private _markerName = format ["RVG_Rescue_%1", _slot];
private _marker = createMarker [_markerName, _locationPos];
_marker setMarkerType  "mil_dot";
_marker setMarkerColor "ColorGreen";
_marker setMarkerText  format ["RESCUE: %1", _locationName];

[_slot, _markerName] call RVG_fnc_registerMissionMarker;

// ---- Survivor position --------------------------------------------------
// Manual safe-position search (avoids BIS_fnc_findSafePos spiral-out bug).
private _spawnPos = [];

for "_attempt" from 1 to 20 do {
    if (!(_spawnPos isEqualTo [])) exitWith {};

    private _bearing  = random 360;
    private _distance = 75 + random 125;

    private _testPos = [
        (_locationPos select 0) + (sin _bearing * _distance),
        (_locationPos select 1) + (cos _bearing * _distance),
        0
    ];

    private _nearBuildings = nearestTerrainObjects [_testPos, ["BUILDING"], 5];

    if (!(surfaceIsWater _testPos) && { _nearBuildings isEqualTo [] }) then {
        _spawnPos = _testPos;
    };
};

if (_spawnPos isEqualTo []) then {
    _spawnPos = _locationPos;
    diag_log "RVG Rescue: Using fallback position (no clear spot in 20 attempts).";
};

// ---- Spawn camp group (survivor + 2 guards) -----------------------------
// All three in ONE group with a HOLD waypoint. Keeps the survivor anchored
// to the guards instead of idling away. When the survivor later joins the
// player, he leaves this group cleanly and the guards can be deleted.
private _campGrp = createGroup [west, true];

// --- Survivor (first unit = group leader) ---
private _survivor = _campGrp createUnit [
    "B_Soldier_F",
    _spawnPos,
    [], 0, "NONE"
];

removeUniform _survivor;
removeVest _survivor;
removeHeadgear _survivor;
removeAllWeapons _survivor;
removeAllItems _survivor;
removeAllAssignedItems _survivor;

_survivor forceAddUniform (selectRandom [
    "CUP_U_C_Citizen_01", "CUP_U_C_Citizen_02", "CUP_U_C_Citizen_03", "CUP_U_C_Citizen_04",
    "CUP_U_C_Villager_01", "CUP_U_C_Villager_02", "CUP_U_C_Villager_03", "CUP_U_C_Villager_04",
    "CUP_U_C_Woodlander_01", "CUP_U_C_Woodlander_02", "CUP_U_C_Woodlander_03", "CUP_U_C_Woodlander_04",
    "CUP_U_C_Rocker_01", "CUP_U_C_Rocker_02", "CUP_U_C_Rocker_03", "CUP_U_C_Rocker_04",
    "U_C_Poloshirt_blue", "U_C_Poloshirt_burgundy", "U_C_Man_casual_1_F", "U_C_Man_casual_2_F"
]);

doStop _survivor;
_survivor setUnitPos "MIDDLE";
_survivor allowDamage true;

_survivor setVariable ["RVG_rescueMission",  _slot, true];
_survivor setVariable ["RVG_rescueSurvivor", true,  true];

[_slot, _survivor] call RVG_fnc_registerMissionEntity;

// --- Guards (same group) ---
private _guards = [];
for "_i" from 0 to 1 do {
    private _guardPos = _spawnPos getPos [5 + (_i * 3), (_i * 180) + random 45];

    private _g = _campGrp createUnit [
        "B_Soldier_F",
        _guardPos,
        [], 0, "NONE"
    ];

    [_g, "rifleman"] call RVG_fnc_applyLoadout;

    _g setUnitPos "AUTO";
    _g allowFleeing 0;
    _g setDir (_g getDir _survivor);

    _guards pushBack _g;

    [_slot, _g] call RVG_fnc_registerMissionEntity;
};

[_slot, _campGrp] call RVG_fnc_registerMissionEntity;

// ---- HOLD waypoint — pins the whole camp in place ----------------------
private _holdWp = _campGrp addWaypoint [_spawnPos, 0];
_holdWp setWaypointType      "HOLD";
_holdWp setWaypointSpeed     "LIMITED";
_holdWp setWaypointBehaviour "AWARE";
_holdWp setWaypointCombatMode "YELLOW";
_holdWp setWaypointFormation "DIAMOND";

_campGrp setFormation  "DIAMOND";
_campGrp setBehaviour  "AWARE";
_campGrp setCombatMode "YELLOW";

diag_log format [
    "RVG Rescue: Survivor + %1 guards spawned for slot %2 at %3",
    count _guards,
    _slot + 1,
    _spawnPos
];

// ---- Announce -----------------------------------------------------------
[format ["RESCUE MISSION: Survivor reported near %1.", _locationName]]
    remoteExec ["systemChat", 0];

// ---- Wait for player to reach survivor ---------------------------------
waitUntil {
    sleep 2;

    if (isNull _survivor || { !alive _survivor }) exitWith { true };

    (allPlayers findIf { alive _x && (_x distance2D _survivor) < 10 }) >= 0
};

// ---- Abort if survivor died on approach --------------------------------
if (isNull _survivor || { !alive _survivor }) exitWith {
    diag_log format ["RVG Rescue: Survivor lost for slot %1.", _slot + 1];
    [format ["RESCUE FAILED: Survivor at %1 was lost.", _locationName]]
        remoteExec ["systemChat", 0];

    { if (!isNull _x) then { deleteVehicle _x; }; } forEach _guards;
    if (!isNull _campGrp) then { deleteGroup _campGrp; };

    deleteMarker _markerName;
    [_slot] call _fnc_removeSlot;
};

// ---- Pickup: attach survivor to player ---------------------------------
[format ["SURVIVOR FOUND: Escort them back to HQ."]]
    remoteExec ["systemChat", 0];

_marker setMarkerText  format ["ESCORT SURVIVOR: %1", _locationName];
_marker setMarkerColor "ColorYellow";

// Find the rescuer.
private _rescuer = objNull;
{
    if (alive _x && { _x distance2D _survivor < 15 }) exitWith {
        _rescuer = _x;
    };
} forEach allPlayers;

if (isNull _rescuer) exitWith {
    diag_log format ["RVG Rescue: No rescuer in range for slot %1 — aborting escort.", _slot + 1];
    deleteMarker _markerName;
    if (!isNull _survivor) then { deleteVehicle _survivor; };
    { if (!isNull _x) then { deleteVehicle _x; }; } forEach _guards;
    if (!isNull _campGrp) then { deleteGroup _campGrp; };
    [_slot] call _fnc_removeSlot;
};

// Tag survivor as off-limits to the roster reconciler, then move him
// out of the camp group and into the player's group.
_survivor setVariable ["RVG_missionUnit", true, true];
[_survivor] joinSilent (group _rescuer);
_survivor doFollow _rescuer;

diag_log format [
    "RVG Rescue: Survivor assigned to %1.",
    name _rescuer
];

// Delete guards now that the survivor is safe. Survivor already left
// the group, so this empties it and it auto-deletes.
[_guards, _campGrp] spawn {
    params ["_guards", "_campGrp"];
    sleep 1.5;
    {
        if (!isNull _x) then { deleteVehicle _x; };
    } forEach _guards;
    if (!isNull _campGrp) then { deleteGroup _campGrp; };
    diag_log "RVG Rescue: Guards removed.";
};

// ---- Marker follows survivor ------------------------------------------
[_survivor, _marker] spawn {
    params ["_survivor", "_marker"];
    while { !isNull _survivor && alive _survivor } do {
        _marker setMarkerPos (getPos _survivor);
        sleep 2;
    };
};

// ---- Fetch HQ ----------------------------------------------------------
private _hq = missionNamespace getVariable ["MissionHQ", objNull];

if (isNull _hq) exitWith {
    diag_log "RVG Rescue: MissionHQ missing — aborting.";
    if (!isNull _survivor) then { deleteVehicle _survivor; };
    deleteMarker _markerName;
    [_slot] call _fnc_removeSlot;
};

// ---- Wait for survivor to reach HQ ------------------------------------
waitUntil {
    sleep 2;
    if (isNull _survivor || { !alive _survivor }) exitWith { true };
    (_survivor distance2D _hq) < 20
};

// ---- Outcome ----------------------------------------------------------
if (isNull _survivor || { !alive _survivor }) then {
    [format ["RESCUE FAILED: Survivor from %1 was lost en route.", _locationName]]
        remoteExec ["systemChat", 0];
} else {
    [format ["RESCUE COMPLETE: %1 survivor recovered.", _locationName]]
        remoteExec ["systemChat", 0];
    deleteVehicle _survivor;
};

deleteMarker _markerName;
[_slot] call _fnc_removeSlot;

diag_log format ["RVG Rescue: Slot %1 closed.", _slot + 1];
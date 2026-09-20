// =========================================================================
// RVG Rescue Mission
//
// Flow:
//   1. Green marker at location.
//   2. Survivor (BLUFOR in civvies) spawns 75-200m off marker,
//      with 2 armed BLUFOR guards nearby.
//   3. Player walks within 10m of survivor → guards are deleted,
//      survivor joins player and marker starts following them.
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

// ---- Survivor position --------------------------------------------------
private _spawnPos = [
    _locationPos,
    75, 200,
    5,
    0, 0.5, 0
] call BIS_fnc_findSafePos;

if (_spawnPos isEqualTo []) then {
    _spawnPos = _locationPos;
};

// ---- Spawn survivor (BLUFOR, civilian appearance) -----------------------
// BLUFOR side means Ravage's infection system won't touch them.
// Civilian uniform makes them read as a non-combatant.
private _survivorGrp = createGroup [west, true];

private _survivor = _survivorGrp createUnit [
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
    "U_C_Poloshirt_blue",
    "U_C_Poloshirt_burgundy",
    "U_C_Poloshirt_salmon",
    "U_C_Poloshirt_stripped",
    "U_C_Man_casual_1_F",
    "U_C_Man_casual_2_F"
]);

_survivor setBehaviour "SAFE";
_survivor setCombatMode "GREEN";
_survivor allowDamage true;

_survivor setVariable ["RVG_rescueMission",  _slot, true];
_survivor setVariable ["RVG_rescueSurvivor", true,  true];

// ---- Spawn 2 armed guards ----------------------------------------------
// Guards are BLUFOR too, so they won't shoot the player on sight.
// They're put in their own group so they don't interfere with the
// survivor's group membership when we later joinSilent the player.
private _guardGrp = createGroup [west, true];

private _guards = [];
for "_i" from 0 to 1 do {
    private _guardPos = _spawnPos getPos [5 + (_i * 3), (_i * 180) + random 45];

    private _g = _guardGrp createUnit [
        "B_Soldier_F",
        _guardPos,
        [], 0, "NONE"
    ];

    [_g, "rifleman"] call RVG_fnc_applyLoadout;

    _g setBehaviour "AWARE";
    _g setCombatMode "YELLOW";
    _g setUnitPos "AUTO";
    _g setDir (_g getDir _survivor);   // face the survivor's direction

    _guards pushBack _g;
};

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

    // Clean up guards too, regardless of state.
    { if (!isNull _x) then { deleteVehicle _x; }; } forEach _guards;
    if (!isNull _guardGrp) then { deleteGroup _guardGrp; };

    deleteMarker _markerName;
    [_slot] call _fnc_removeSlot;
};

// ---- Pickup: delete guards, attach survivor to player ------------------
[format ["SURVIVOR FOUND: Escort them back to HQ."]]
    remoteExec ["systemChat", 0];

_marker setMarkerText  format ["ESCORT SURVIVOR: %1", _locationName];
_marker setMarkerColor "ColorYellow";

// Delete guards now that the survivor is safe. Fire-and-forget, but
// we add a small sleep so it doesn't look instant.
[_guards, _guardGrp] spawn {
    params ["_guards", "_guardGrp"];
    sleep 1.5;
    {
        if (!isNull _x) then { deleteVehicle _x; };
    } forEach _guards;
    if (!isNull _guardGrp) then { deleteGroup _guardGrp; };
    diag_log "RVG Rescue: Guards removed.";
};

// Find the rescuer properly (fixed selection bug).
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
    if (!isNull _guardGrp) then { deleteGroup _guardGrp; };
    [_slot] call _fnc_removeSlot;
};

[_survivor] joinSilent (group _rescuer);
_survivor doFollow _rescuer;

diag_log format [
    "RVG Rescue: Survivor assigned to %1.",
    name _rescuer
];

// ---- Marker follows survivor ------------------------------------------
[_survivor, _marker] spawn {
    params ["_survivor", "_marker"];
    while { !isNull _survivor && alive _survivor } do {
        _marker setMarkerPos (getPos _survivor);
        sleep 2;
    };
};

// ---- Fetch HQ (with abort safety) -------------------------------------
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
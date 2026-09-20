// =========================================================================
// RVG Investigate Mission
//
// Flow:
//   1. Blue marker at location (search phase preserved).
//   2. Survivor camp spawns 75-200m off marker:
//        tent, campfire, crate, props, satellite phone on crate.
//   3. Orange smoke grenade signals the camp on spawn.
//   4. Player finds camp, hold-actions "Inspect Evidence" on the phone.
//   5. Camp despawns, marker moves to HQ, "RETURN TO HQ".
//   6. Any player within 20m of HQ completes.
// =========================================================================

params ["_slot", "_locationName", "_locationPos"];

// ---- Slot cleanup helper ------------------------------------------------
private _fnc_removeSlot = {
    params ["_slot"];
    private _active = missionNamespace getVariable ["RVG_activeMissions", []];
    _active = _active select { (_x select 0) != _slot };
    missionNamespace setVariable ["RVG_activeMissions", _active, true];
};

// ---- Camp cleanup helper -----------------------------------------------
private _fnc_cleanupCamp = {
    params ["_objects"];
    {
        if (!isNull _x) then { deleteVehicle _x; };
    } forEach _objects;
};

// ---- Marker -------------------------------------------------------------
private _markerName = format ["RVG_Investigate_%1", _slot];
private _marker = createMarker [_markerName, _locationPos];
_marker setMarkerType  "mil_dot";
_marker setMarkerColor "ColorBlue";
_marker setMarkerText  format ["INVESTIGATE: %1", _locationName];

// ---- Camp position ------------------------------------------------------
private _objectivePos = [
    _locationPos,
    75, 200,
    5,
    0, 0.5, 0
] call BIS_fnc_findSafePos;

if (_objectivePos isEqualTo []) then {
    _objectivePos = _locationPos;
};

diag_log format [
    "RVG Investigate: Camp %1m from marker for slot %2",
    round (_objectivePos distance2D _locationPos),
    _slot + 1
];

// ---- Build the survivor camp -------------------------------------------
private _camp = [];

// Helper: place a static object at bearing/distance from camp centre.
private _fnc_place = {
    params ["_class", "_dist", "_bearing", "_dirOffset"];
    private _p = _objectivePos getPos [_dist, _bearing];
    private _o = createVehicle [_class, _p, [], 0, "CAN_COLLIDE"];
    _o setDir _dirOffset;
    _camp pushBack _o;
    _o
};

// Tent — the camp's visual anchor.
private _tent = ["Land_TentA_F", 3.5, 45, 225] call _fnc_place;

// Campfire — burning fire + ambient smoke wisp. Lit via inflame so it
// produces fire particles and a light plume from the logs.
private _fire = ["Land_Campfire_F", 1.5, 200, random 360] call _fnc_place;
_fire inflame true;

// Crate — the phone sits on top of this.
private _crate = ["Land_WoodenBox_F", 0, 0, random 360] call _fnc_place;

// Props — small details that sell "someone was here."
["Land_CanisterFuel_F", 2, 130, random 360] call _fnc_place;
["Land_CampingChair_V1_F", 2.5, 270, 90] call _fnc_place;

// ---- Evidence (satellite phone on the crate) ---------------------------
private _cratePos = getPosATL _crate;
private _evidence = createVehicle [
    "Land_SatellitePhone_F",
    [
        _cratePos select 0,
        _cratePos select 1,
        (_cratePos select 2) + 0.20
    ],
    [], 0, "CAN_COLLIDE"
];

_evidence setDir (random 360);
_evidence allowDamage false;
_evidence enableSimulationGlobal true;
_evidence setVariable ["RVG_investigateMission", _slot, true];

// ---- Orange smoke signal -----------------------------------------------
// One-shot grenade as the initial beacon. The campfire gives sustained
// visibility (fire glow + smoke wisp) after the grenade fades.
private _smoke = "SmokeShellOrange" createVehicle _objectivePos;
_smoke setPosATL [_objectivePos select 0, _objectivePos select 1, 0.5];
_camp pushBack _smoke;

// ---- Announce -----------------------------------------------------------
[format ["INVESTIGATE: Search the area around %1 for evidence.", _locationName]]
    remoteExec ["systemChat", 0];

// ---- Hold-action: Inspect Evidence -------------------------------------
[
    _evidence,
    "<t color='#FFAA00'>Inspect Evidence</t>",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa",
    "_this distance _target < 3",
    "_caller distance _target < 3",
    {},
    {},
    {
        params ["_target", "_caller"];
        _target setVariable ["RVG_evidenceInspected", true, true];
    },
    {},
    [],
    3, 0, true, false
] remoteExec ["BIS_fnc_holdActionAdd", 0, _evidence];

// ---- Wait for inspection -----------------------------------------------
waitUntil {
    sleep 1;
    if (isNull _evidence) exitWith { true };
    _evidence getVariable ["RVG_evidenceInspected", false]
};

// ---- Abort if evidence vanished before inspection ----------------------
if (isNull _evidence) exitWith {
    diag_log format ["RVG Investigate: Evidence lost for slot %1.", _slot + 1];
    [format ["INVESTIGATION FAILED: Evidence at %1 was lost.", _locationName]]
        remoteExec ["systemChat", 0];
    [_camp] call _fnc_cleanupCamp;
    deleteMarker _markerName;
    [_slot] call _fnc_removeSlot;
};

// ---- Evidence inspected -------------------------------------------------
["INVESTIGATE: Evidence collected. Return to HQ."]
    remoteExec ["systemChat", 0];

// Delete the whole camp — the site has been processed.
[_camp] call _fnc_cleanupCamp;

// ---- Fetch HQ ----------------------------------------------------------
private _hq = missionNamespace getVariable ["MissionHQ", objNull];

if (isNull _hq) exitWith {
    diag_log "RVG Investigate: MissionHQ missing — aborting.";
    deleteMarker _markerName;
    [_slot] call _fnc_removeSlot;
};

// ---- Repoint marker at HQ ----------------------------------------------
_marker setMarkerPos  (getPos _hq);
_marker setMarkerColor "ColorYellow";
_marker setMarkerText  format ["RETURN TO HQ: %1", _locationName];

// ---- Wait for any player at HQ ----------------------------------------
waitUntil {
    sleep 2;
    (allPlayers findIf { alive _x && (_x distance2D _hq) < 20 }) >= 0
};

// ---- Complete -----------------------------------------------------------
[format ["INVESTIGATION COMPLETE: %1.", _locationName]]
    remoteExec ["systemChat", 0];

deleteMarker _markerName;
[_slot] call _fnc_removeSlot;

diag_log format ["RVG Investigate: Slot %1 completed.", _slot + 1];
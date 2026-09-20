// =========================================================================
// RVG EVENT - HELICOPTER PATROL
// =========================================================================
// Behaviour:
//   - Picks 3-5 nearby towns and flies a looping patrol route through them
//   - Mixes LOITER (circle a town) and SAD (sweep between towns) legs
//   - Altitude 60-100m, speed varies by leg (NORMAL transit / LIMITED on-station)
//   - Spot searchlight attached, tracks the heli
//   - Map marker follows the heli live
//   - No fixed timer — despawns when the player is >3km away for 60s
//     OR when the heli is destroyed
// =========================================================================

diag_log "=== RVG EVENT: Helicopter patrol starting ===";

// ---- 1. Scan map locations ----------------------------------------------
private _locations = nearestLocations [
    [worldSize / 2, worldSize / 2],
    ["NameCityCapital", "NameCity", "NameVillage"],
    worldSize
];

if (_locations isEqualTo []) exitWith {
    diag_log "=== RVG EVENT: ERROR - No map locations found ===";
};

// ---- 2. Convert to [name, pos] data -------------------------------------
private _locationData = [];
{
    private _locationName = text _x;
    private _locationPos  = locationPosition _x;

    if (
        !(_locationName isEqualTo "") &&
        { !(_locationPos isEqualTo [0,0,0]) }
    ) then {
        _locationData pushBack [_locationName, _locationPos];
    };
} forEach _locations;

if (_locationData isEqualTo []) exitWith {
    diag_log "=== RVG EVENT: ERROR - Location scanner returned nothing ===";
};

diag_log format [
    "=== RVG EVENT: Scanner found %1 locations ===",
    count _locationData
];

// ---- 3. Build a patrol route --------------------------------------------
// Pick a random start, then chain the closest N-1 towns into a route.
// N is 3-5 so route length varies each event.
private _routeLength = 3 + floor random 3;
private _startLoc    = selectRandom _locationData;
private _startPos    = _startLoc select 1;

// Sort all locations by distance from the start.
private _sorted = [_locationData, [], { (_x select 1) distance _startPos }, "ASCEND"] call BIS_fnc_sortBy;

private _route = [_startLoc];
{
    if (count _route >= _routeLength) exitWith {};
    if ((_x select 1) distance _startPos > 100) then {
        _route pushBack _x;
    };
} forEach _sorted;

diag_log format [
    "=== RVG EVENT: Patrol route has %1 stops, start = %2 ===",
    count _route,
    _startLoc select 0
];

// ---- 4. Spawn position — 500-800m from first stop -----------------------
private _spawnRadius    = 500 + random 300;
private _spawnDirection = random 360;

private _spawnPos = [
    (_startPos select 0) + (sin _spawnDirection * _spawnRadius),
    (_startPos select 1) + (cos _spawnDirection * _spawnRadius),
    150
];

_spawnPos set [0, (_spawnPos select 0) max 500 min (worldSize - 500)];
_spawnPos set [1, (_spawnPos select 1) max 500 min (worldSize - 500)];

// ---- 5. Spawn helicopter -------------------------------------------------
private _heli = createVehicle ["B_Heli_Light_01_F", _spawnPos, [], 0, "FLY"];

_heli setDir (_spawnPos getDir _startPos);
_heli allowDamage true;
_heli setVehicleLock "UNLOCKED";

// Patrol altitude: 60-100m, decided once and held.
private _patrolAltitude = 60 + random 40;
_heli flyInHeight _patrolAltitude;

// ---- 6. Crew ------------------------------------------------------------
private _group = createVehicleCrew _heli;
private _pilot = driver _heli;

if (!isNull _pilot) then {
    _pilot setSkill 0.7;
};

// Skill the rest of the crew too, so the whole aircraft behaves consistently.
{
    if (_x != _pilot) then { _x setSkill 0.6; };
} forEach (units _group);

// ---- 7. Searchlight -----------------------------------------------------
// Attached to the heli, swept forward-down. Cleaned up with the heli.
private _light = "#lightpoint" createVehicle [0, 0, 0];
_light lightAttachObject [_heli, [0, -2, -0.8]];
_light setLightColor        [1, 1, 0.9];
_light setLightBrightness   3;
_light setLightAmbient      [0.1, 0.1, 0.05];
_light setLightUseFlare     true;
_light setLightFlareSize    4;
_light setLightFlareMaxDistance 500;

// ---- 8. Waypoints: approach first stop ---------------------------------
private _wpApproach = _group addWaypoint [_startPos, 0];
_wpApproach setWaypointType             "MOVE";
_wpApproach setWaypointBehaviour        "COMBAT";
_wpApproach setWaypointCombatMode       "RED";
_wpApproach setWaypointSpeed            "FULL";
_wpApproach setWaypointCompletionRadius 150;
_wpApproach setWaypointStatements [
    "true",
    format ["vehicle this flyInHeight %1;", _patrolAltitude]
];

// ---- 9. Waypoints: patrol legs -----------------------------------------
// Alternate LOITER (circle a town) and SAD (sweep between towns).
for "_i" from 0 to (count _route - 1) do {
    private _stop     = _route select _i;
    private _stopPos  = _stop select 1;
    private _stopName = _stop select 0;

    if (_i % 2 == 0) then {
        // LOITER leg — circle this town for 60-120s.
        private _wp = _group addWaypoint [_stopPos, 0];
        _wp setWaypointType             "LOITER";
        _wp setWaypointBehaviour        "COMBAT";
        _wp setWaypointCombatMode       "RED";
        _wp setWaypointSpeed            "LIMITED";
        _wp setWaypointLoiterRadius     250;
        _wp setWaypointLoiterType       "CIRCLE_L";
        _wp setWaypointTimeout          [60, 90, 120];
        _wp setWaypointStatements [
            "true",
            format ["vehicle this flyInHeight %1;", _patrolAltitude]
        ];

        diag_log format [
            "=== RVG EVENT: LOITER at %1 ===",
            _stopName
        ];
    } else {
        // SAD leg — sweep the area between this stop and the next.
        private _wp = _group addWaypoint [_stopPos, 0];
        _wp setWaypointType             "SAD";
        _wp setWaypointBehaviour        "COMBAT";
        _wp setWaypointCombatMode       "RED";
        _wp setWaypointSpeed            "NORMAL";
        _wp setWaypointCompletionRadius 300;
        _wp setWaypointStatements [
            "true",
            format ["vehicle this flyInHeight %1;", _patrolAltitude]
        ];

        diag_log format [
            "=== RVG EVENT: SAD at %1 ===",
            _stopName
        ];
    };
};

// ---- 10. Close the loop -------------------------------------------------
// CYCLE returns to the first waypoint and repeats forever.
private _wpCycle = _group addWaypoint [_startPos, 0];
_wpCycle setWaypointType "CYCLE";

// ---- 11. Live map marker ------------------------------------------------
private _markerName = format ["RVG_Heli_%1", diag_tickTime];
private _marker = createMarker [_markerName, _startPos];

_marker setMarkerType  "mil_warning";
_marker setMarkerColor "ColorRed";
_marker setMarkerText  "Patrol Helicopter";

// Follow the heli while it's alive.
[_heli, _markerName] spawn {
    params ["_heli", "_markerName"];

    while { !isNull _heli && { alive _heli } } do {
        _markerName setMarkerPos (getPos _heli);
        sleep 3;
    };
};

// ---- 12. Lifecycle cleanup ---------------------------------------------
// Despawn when: heli destroyed OR player >3km away for 60 straight seconds.
[_heli, _group, _markerName, _light, _startPos] spawn {
    params ["_heli", "_group", "_markerName", "_light", "_startPos"];

    private _awayTime = 0;

    waitUntil {
        sleep 5;

        if (isNull _heli || { !alive _heli }) exitWith { true };

        private _dist = if (!isNull player && alive player) then {
            player distance (getPos _heli)
        } else {
            0
        };

        if (_dist > 3000) then {
            _awayTime = _awayTime + 5;
        } else {
            _awayTime = 0;
        };

        _awayTime >= 60
    };

    // Clean up crew first so they don't get left in an orphaned group.
    {
        if (!isNull _x) then { deleteVehicle _x; };
    } forEach (units _group);

    if (!isNull _heli) then { deleteVehicle _heli; };
    if (!isNull _light) then { deleteVehicle _light; };

    deleteMarker _markerName;

    diag_log "=== RVG EVENT: Helicopter patrol despawned ===";
};

// ---- 13. Debug ---------------------------------------------------------
diag_log format [
    "=== RVG EVENT: Helicopter spawned %1m from %2, alt %3, route length %4 ===",
    round (_spawnPos distance2D _startPos),
    _startLoc select 0,
    round _patrolAltitude,
    count _route
];
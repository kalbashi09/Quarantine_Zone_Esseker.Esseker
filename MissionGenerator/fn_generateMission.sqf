// =========================================================================
// RVG Mission Generator - Generate One Mission
//
// Parameters:
//   0: Array - available locations
//   1: Number - mission slot (0, 1, 2)
//
// Mission placement:
//   Location center
//        ↓
//   300–500m random
//        ↓
//   Mission marker
//        ↓
//   75–200m random
//        ↓
//   Actual objective
// =========================================================================

params [
    "_locations",
    "_slot"
];

if (_locations isEqualTo []) exitWith {
    diag_log "RVG MissionGenerator: ERROR - No locations available.";
};

// -------------------------------------------------------------------------
// Find an unused location
// -------------------------------------------------------------------------

private _usedLocations =
    missionNamespace getVariable [
        "RVG_usedMissionLocations",
        []
    ];

private _availableLocations =
    _locations select {
        !(_x select 0 in _usedLocations)
    };

// If every location has been used, reset the pool
if (_availableLocations isEqualTo []) then {

    diag_log "RVG MissionGenerator: Location pool exhausted. Resetting.";

    _usedLocations = [];

    missionNamespace setVariable [
        "RVG_usedMissionLocations",
        []
    ];

    _availableLocations = _locations;
};

private _locationData =
    selectRandom _availableLocations;

private _locationName = _locationData select 0;
private _locationPos  = _locationData select 1;

// -------------------------------------------------------------------------
// Randomize mission marker position around the location
// -------------------------------------------------------------------------

private _missionRadius =
    100 + random 150;

// Random direction
private _direction =
    random 360;

private _missionPos = [
    (_locationPos select 0) +
        (sin _direction * _missionRadius),

    (_locationPos select 1) +
        (cos _direction * _missionRadius),

    0
];

// -------------------------------------------------------------------------
// Mark location as used
// -------------------------------------------------------------------------

_usedLocations pushBack _locationName;

missionNamespace setVariable [
    "RVG_usedMissionLocations",
    _usedLocations
];

// -------------------------------------------------------------------------
// Random mission type
// -------------------------------------------------------------------------

private _missionTypes = [
    "RESCUE",
    "INVESTIGATE",
    "CACHE"
];

private _missionType =
    selectRandom _missionTypes;

// -------------------------------------------------------------------------
// Mission information
//
// Store the randomized mission position, NOT the town center.
// -------------------------------------------------------------------------

private _missionData = [
    _slot,
    _missionType,
    _locationName,
    _missionPos
];

// Add to active mission list
private _activeMissions =
    missionNamespace getVariable [
        "RVG_activeMissions",
        []
    ];

_activeMissions pushBack _missionData;

missionNamespace setVariable [
    "RVG_activeMissions",
    _activeMissions,
    true
];

// -------------------------------------------------------------------------
// Debug
// -------------------------------------------------------------------------

diag_log format [
    "RVG MissionGenerator: Slot %1 = %2 near %3",
    _slot + 1,
    _missionType,
    _locationName
];

diag_log format [
    "RVG MissionGenerator: Marker position %1 | Distance from location %2m",
    _missionPos,
    round (_missionPos distance2D _locationPos)
];

// -------------------------------------------------------------------------
// Start mission
// -------------------------------------------------------------------------

switch (_missionType) do {

    case "RESCUE": {
        [_slot, _locationName, _missionPos]
            spawn RVG_fnc_rescue;
    };

    case "INVESTIGATE": {
        [_slot, _locationName, _missionPos]
            spawn RVG_fnc_investigate;
    };

    case "CACHE": {
        [_slot, _locationName, _missionPos]
            spawn RVG_fnc_cache;
    };
};
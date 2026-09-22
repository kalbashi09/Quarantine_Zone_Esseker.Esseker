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
//   100–250m random search
//        ↓
//   Terrain/object checks
//        ↓
//   Valid mission position
//        ↓
//   Mission marker / mission objects
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
// Find a suitable mission position around the location
// -------------------------------------------------------------------------

private _missionPos = [];

private _maxAttempts = 30;

for "_attempt" from 1 to _maxAttempts do {

    // Keep the existing 100–250m distance from the location
    private _missionRadius =
        100 + random 150;

    private _direction =
        random 360;

    private _candidatePos = [
        (_locationPos select 0) +
            (sin _direction * _missionRadius),

        (_locationPos select 1) +
            (cos _direction * _missionRadius),

        0
    ];

    // Put the candidate onto the actual terrain height
    _candidatePos set [
        2,
        getTerrainHeightASL _candidatePos
    ];

    // ---------------------------------------------------------------------
    // Reject water
    // ---------------------------------------------------------------------

    if (surfaceIsWater _candidatePos) then {
        continue;
    };

    // ---------------------------------------------------------------------
    // Reject steep terrain
    //
    // Z component of surface normal:
    // 1.0  = completely flat
    // 0.90 = moderate slope
    // lower = increasingly steep
    // ---------------------------------------------------------------------

    private _surfaceNormal =
        surfaceNormal _candidatePos;

    if ((_surfaceNormal select 2) < 0.90) then {
        continue;
    };

    // ---------------------------------------------------------------------
    // Reject large nearby objects
    // ---------------------------------------------------------------------

    private _nearbyObjects =
        nearestObjects [
            _candidatePos,
            [],
            8
        ];

    private _blocked = false;

    {
        private _object = _x;

        if (!isNull _object) then {

            // Ignore characters
            if (
                !(_object isKindOf "Man") &&
                !(_object isKindOf "Animal")
            ) then {

                private _box =
                    boundingBoxReal _object;

                private _min =
                    _box select 0;

                private _max =
                    _box select 1;

                private _sizeX =
                    abs ((_max select 0) - (_min select 0));

                private _sizeY =
                    abs ((_max select 1) - (_min select 1));

                // Large object nearby
                if (
                    (_sizeX > 3) ||
                    (_sizeY > 3)
                ) then {
                    _blocked = true;
                };
            };
        };

    } forEach _nearbyObjects;

    if (_blocked) then {
        continue;
    };

    // ---------------------------------------------------------------------
    // Valid position found
    // ---------------------------------------------------------------------

    _missionPos = _candidatePos;

    diag_log format [
        "RVG MissionGenerator: Valid terrain position found on attempt %1.",
        _attempt
    ];

    break;
};

// -------------------------------------------------------------------------
// Fallback
// -------------------------------------------------------------------------

if (_missionPos isEqualTo []) then {

    diag_log "RVG MissionGenerator: WARNING - Could not find ideal terrain position. Using fallback.";

    private _missionRadius =
        100 + random 150;

    private _direction =
        random 360;

    _missionPos = [
        (_locationPos select 0) +
            (sin _direction * _missionRadius),

        (_locationPos select 1) +
            (cos _direction * _missionRadius),

        0
    ];

    _missionPos set [
        2,
        getTerrainHeightASL _missionPos
    ];
};

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
// Create unique runtime mission instance
//
// This is NOT saved.
// It exists only to distinguish the current mission instance
// from an older coroutine that may still be running.
// -------------------------------------------------------------------------

private _missionInstance = format [
    "%1_%2",
    diag_tickTime,
    _slot
];

// -------------------------------------------------------------------------
// Mission information
//
// First 4 fields are persistent mission definition.
// Field 5 is runtime-only.
// -------------------------------------------------------------------------

private _missionData = [
    _slot,
    _missionType,
    _locationName,
    _missionPos,
    _missionInstance
];

// -------------------------------------------------------------------------
// Add to active mission list
// -------------------------------------------------------------------------

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
    "RVG MissionGenerator: Instance %1",
    _missionInstance
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
        [
            _slot,
            _locationName,
            _missionPos,
            _missionInstance
        ] spawn RVG_fnc_rescue;
    };

    case "INVESTIGATE": {
        [
            _slot,
            _locationName,
            _missionPos,
            _missionInstance
        ] spawn RVG_fnc_investigate;
    };

    case "CACHE": {
        [
            _slot,
            _locationName,
            _missionPos,
            _missionInstance
        ] spawn RVG_fnc_cache;
    };
};
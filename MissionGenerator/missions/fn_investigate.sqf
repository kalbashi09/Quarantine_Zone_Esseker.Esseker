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

params [
    "_slot",
    "_locationName",
    "_locationPos",
    ["_missionInstance", ""]
];

// ---- Mission ownership check -------------------------------------------
// Prevents an old mission coroutine from touching a newer mission that
// reused the same slot after a save/load cycle.
private _fnc_isCurrentMission = {

    private _active = missionNamespace getVariable [
        "RVG_activeMissions",
        []
    ];

    private _index = _active findIf {
        (_x select 0) == _slot
    };

    if (_index < 0) exitWith {
        false
    };

    private _current = _active select _index;

    (count _current >= 5) &&
    { (_current select 4) == _missionInstance }
};

// ---- Slot cleanup helper ------------------------------------------------
private _fnc_removeSlot = {

    // Old coroutine no longer owns this slot.
    if !([] call _fnc_isCurrentMission) exitWith {

        diag_log format [
            "RVG Investigate: Slot %1 instance %2 is stale. Cleanup skipped.",
            _slot + 1,
            _missionInstance
        ];
    };

    private _active = missionNamespace getVariable [
        "RVG_activeMissions",
        []
    ];

    _active = _active select {
        (_x select 0) != _slot
    };

    missionNamespace setVariable [
        "RVG_activeMissions",
        _active,
        true
    ];
};

// ---- Camp cleanup helper -----------------------------------------------
private _fnc_cleanupCamp = {
    params ["_objects"];

    {
        if (!isNull _x) then {
            deleteVehicle _x;
        };
    } forEach _objects;
};

// ---- Marker -------------------------------------------------------------
private _markerName = format [
    "RVG_Investigate_%1",
    _slot
];

private _marker = createMarker [
    _markerName,
    _locationPos
];

_marker setMarkerType "mil_dot";
_marker setMarkerColor "ColorBlue";
_marker setMarkerText format [
    "INVESTIGATE: %1",
    _locationName
];

[_slot, _markerName] call RVG_fnc_registerMissionMarker;

// ---- Camp position ------------------------------------------------------
// Find a reasonably flat, clear area with enough room for the entire camp.
// The camp objects are placed up to ~5m from the objective center, so
// we check a larger area rather than only checking the exact center.

private _objectivePos = [];

for "_attempt" from 1 to 40 do {

    if !(_objectivePos isEqualTo []) exitWith {};

    private _bearing  = random 360;
    private _distance = 75 + random 125;

    private _testPos = [
        (_locationPos select 0) +
            (sin _bearing * _distance),

        (_locationPos select 1) +
            (cos _bearing * _distance),

        0
    ];

    // Put position on the actual terrain surface
    _testPos set [
        2,
        getTerrainHeightASL _testPos
    ];

    // -------------------------------------------------------------
    // Basic terrain checks
    // -------------------------------------------------------------

    // No water
    if (surfaceIsWater _testPos) then {
        continue;
    };

    // Avoid steep slopes
    private _normal = surfaceNormal _testPos;

    if ((_normal select 2) < 0.94) then {
        continue;
    };

    // -------------------------------------------------------------
    // Check the entire camp area
    // -------------------------------------------------------------

    private _blocked = false;

    private _nearbyObjects = nearestTerrainObjects [
        _testPos,
        [
            "TREE",
            "SMALL TREE",
            "BUSH",
            "BUILDING",
            "ROCK",
            "ROCKS",
            "FENCE",
            "WALL",
            "HIDE"
        ],
        8
    ];

    if !(_nearbyObjects isEqualTo []) then {
        _blocked = true;
    };

    if (_blocked) then {
        continue;
    };

    // -------------------------------------------------------------
    // Make sure there is actual walkable terrain around the camp.
    // Check several points around the center.
    // -------------------------------------------------------------

    private _checkDistances = [
        [4,   0],
        [4,  90],
        [4, 180],
        [4, 270],
        [7,  45],
        [7, 135],
        [7, 225],
        [7, 315]
    ];

    private _areaGood = true;

    {
        _x params [
            "_checkDistance",
            "_checkDirection"
        ];

        private _checkPos = _testPos getPos [
            _checkDistance,
            _checkDirection
        ];

        _checkPos set [
            2,
            getTerrainHeightASL _checkPos
        ];

        if (surfaceIsWater _checkPos) then {
            _areaGood = false;
        };

        private _checkNormal =
            surfaceNormal _checkPos;

        if ((_checkNormal select 2) < 0.94) then {
            _areaGood = false;
        };

        private _objects = nearestTerrainObjects [
            _checkPos,
            [
                "TREE",
                "SMALL TREE",
                "BUSH",
                "BUILDING",
                "ROCK",
                "ROCKS",
                "FENCE",
                "WALL",
                "HIDE"
            ],
            3
        ];

        if !(_objects isEqualTo []) then {
            _areaGood = false;
        };

    } forEach _checkDistances;

    if (!_areaGood) then {
        continue;
    };

    // -------------------------------------------------------------
    // Good camp area found
    // -------------------------------------------------------------

    _objectivePos = _testPos;

    diag_log format [
        "RVG Investigate: Clear camp area found on attempt %1.",
        _attempt
    ];
};

if (_objectivePos isEqualTo []) then {

    diag_log [
        "RVG Investigate: WARNING - No ideal camp area found.",
        "Using original location as fallback."
    ];

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

    params [
        "_class",
        "_dist",
        "_bearing",
        "_dirOffset"
    ];

    private _p = _objectivePos getPos [
        _dist,
        _bearing
    ];

    private _o = createVehicle [
        _class,
        _p,
        [],
        0,
        "NONE"
    ];

    _o setDir _dirOffset;

    _camp pushBack _o;

    [_slot, _o] call RVG_fnc_registerMissionEntity;

    _o
};

// Tent — the camp's visual anchor.
private _tent = [
    "Land_TentA_F",
    3.5,
    45,
    225
] call _fnc_place;

// Campfire — burning fire + ambient smoke wisp.
private _fire = [
    "Land_Campfire_F",
    4.5,
    200,
    random 360
] call _fnc_place;

_fire inflame true;

// Crate — the phone sits on top of this.
private _crate = [
    "Land_WoodenBox_F",
    0,
    0,
    random 360
] call _fnc_place;

// Props — small details that sell "someone was here."
[
    "Land_CanisterFuel_F",
    2,
    130,
    random 360
] call _fnc_place;

[
    "Land_CampingChair_V1_F",
    2.5,
    270,
    90
] call _fnc_place;

// ---- Evidence (satellite phone on the crate) ---------------------------
private _cratePos = getPosATL _crate;

private _evidence = createVehicle [
    "Land_SatellitePhone_F",
    [
        _cratePos select 0,
        _cratePos select 1,
        (_cratePos select 2) + 0.20
    ],
    [],
    0,
    "CAN_COLLIDE"
];

_evidence setDir (random 360);
_evidence allowDamage false;
_evidence enableSimulationGlobal true;

_evidence setVariable [
    "RVG_investigateMission",
    _slot,
    true
];

[_slot, _evidence] call RVG_fnc_registerMissionEntity;

// ---- Orange smoke signal -----------------------------------------------
// One-shot grenade as the initial beacon.
private _smoke = "SmokeShellOrange" createVehicle _objectivePos;

_smoke setPosATL [
    _objectivePos select 0,
    _objectivePos select 1,
    0.5
];

_camp pushBack _smoke;

[_slot, _smoke] call RVG_fnc_registerMissionEntity;

// ---- Announce -----------------------------------------------------------
[
    format [
        "INVESTIGATE: Search the area around %1 for evidence.",
        _locationName
    ]
] remoteExec ["systemChat", 0];

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
        params [
            "_target",
            "_caller"
        ];

        _target setVariable [
            "RVG_evidenceInspected",
            true,
            true
        ];
    },
    {},
    [],
    3,
    0,
    true,
    false
] remoteExec [
    "BIS_fnc_holdActionAdd",
    0,
    _evidence
];

// ---- Wait for inspection -----------------------------------------------
waitUntil {

    sleep 1;

    // The mission may have been replaced by a restored/new instance.
    if !([] call _fnc_isCurrentMission) exitWith {
        true
    };

    if (isNull _evidence) exitWith {
        true
    };

    _evidence getVariable [
        "RVG_evidenceInspected",
        false
    ]
};

// ---- Stop immediately if this is an old mission ------------------------
if !([] call _fnc_isCurrentMission) exitWith {

    diag_log format [
        "RVG Investigate: Old instance %1 detected for slot %2. Exiting.",
        _missionInstance,
        _slot + 1
    ];
};

// ---- Abort if evidence vanished before inspection ----------------------
if (isNull _evidence) exitWith {

    diag_log format [
        "RVG Investigate: Evidence lost for slot %1.",
        _slot + 1
    ];

    [
        format [
            "INVESTIGATION FAILED: Evidence at %1 was lost.",
            _locationName
        ]
    ] remoteExec ["systemChat", 0];

    [_camp] call _fnc_cleanupCamp;

    deleteMarker _markerName;

    [_slot] call _fnc_removeSlot;
};

// ---- Evidence inspected -------------------------------------------------
[
    "INVESTIGATE: Evidence collected. Return to HQ."
] remoteExec ["systemChat", 0];

// Delete the whole camp — the site has been processed.
[_camp] call _fnc_cleanupCamp;

// ---- Fetch HQ -----------------------------------------------------------
private _hq =
    missionNamespace getVariable [
        "MissionHQ",
        objNull
    ];

if (isNull _hq) exitWith {

    diag_log "RVG Investigate: MissionHQ missing — aborting.";

    deleteMarker _markerName;

    [_slot] call _fnc_removeSlot;
};

// ---- Repoint marker at HQ ----------------------------------------------
_marker setMarkerPos (getPos _hq);
_marker setMarkerColor "ColorYellow";
_marker setMarkerText format [
    "RETURN TO HQ: %1",
    _locationName
];

// ---- Wait for any player at HQ ------------------------------------------
waitUntil {

    sleep 2;

    if !([] call _fnc_isCurrentMission) exitWith {
        true
    };

    (
        allPlayers findIf {
            alive _x &&
            { (_x distance2D _hq) < 80 }
        }
    ) >= 0
};

// ---- Stop if this coroutine became stale -------------------------------
if !([] call _fnc_isCurrentMission) exitWith {

    diag_log format [
        "RVG Investigate: Old instance %1 detected while returning to HQ.",
        _missionInstance
    ];
};

// ---- Complete -----------------------------------------------------------
[
    format [
        "INVESTIGATION COMPLETE: %1.",
        _locationName
    ]
] remoteExec ["systemChat", 0];

deleteMarker _markerName;

[_slot] call _fnc_removeSlot;

diag_log format [
    "RVG Investigate: Slot %1 completed.",
    _slot + 1
];
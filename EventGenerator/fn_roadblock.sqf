// =====================================================
// RVG EVENT - HOSTILE CHECKPOINT
//
// Ravage-style hostile road checkpoint.
//
// Contains:
// - Road barriers
// - Sandbags
// - Supply crate
// - Hostile scavenger AI
// - Defensive checkpoint layout
// - Map marker
// - Automatic cleanup
// =====================================================

diag_log "=== RVG EVENT: Hostile checkpoint starting ===";

// =====================================================
// FIND ROADS
// =====================================================

private _roads = [];

for "_x" from 0 to worldSize step 500 do {

    for "_y" from 0 to worldSize step 500 do {

        private _nearRoads =
            [_x, _y, 0] nearRoads 500;

        {
            if (!(_x in _roads)) then {
                _roads pushBack _x;
            };
        } forEach _nearRoads;
    };
};

if (_roads isEqualTo []) exitWith {

    diag_log "=== RVG EVENT: ERROR - No roads found ===";
};

diag_log format [
    "=== RVG EVENT: Road scanner found %1 roads ===",
    count _roads
];

// =====================================================
// SELECT RANDOM ROAD
// =====================================================

private _road = selectRandom _roads;

private _roadPos =
    getPosATL _road;

private _roadDir =
    getDir _road;

diag_log format [
    "=== RVG EVENT: Selected checkpoint road at %1 ===",
    _roadPos
];

// =====================================================
// OBJECT STORAGE
// =====================================================

private _objects = [];

// =====================================================
// ROAD BARRIERS
// =====================================================

private _barrier1 = createVehicle [
    "Land_CncBarrier_F",
    _roadPos,
    [],
    0,
    "CAN_COLLIDE"
];

_barrier1 setDir _roadDir;
_barrier1 allowDamage false;

_objects pushBack _barrier1;


private _barrier2Pos =
    _roadPos getPos [
        5,
        _roadDir + 90
    ];

private _barrier2 = createVehicle [
    "Land_CncBarrier_F",
    _barrier2Pos,
    [],
    0,
    "CAN_COLLIDE"
];

_barrier2 setDir _roadDir;
_barrier2 allowDamage false;

_objects pushBack _barrier2;

// =====================================================
// SANDBAGS
// =====================================================

private _sandbag1Pos =
    _roadPos getPos [
        6,
        _roadDir + 90
    ];

private _sandbag1 = createVehicle [
    "Land_BagFence_Long_F",
    _sandbag1Pos,
    [],
    0,
    "CAN_COLLIDE"
];

_sandbag1 setDir (_roadDir + 90);

_objects pushBack _sandbag1;


private _sandbag2Pos =
    _roadPos getPos [
        6,
        _roadDir - 90
    ];

private _sandbag2 = createVehicle [
    "Land_BagFence_Long_F",
    _sandbag2Pos,
    [],
    0,
    "CAN_COLLIDE"
];

_sandbag2 setDir (_roadDir + 90);

_objects pushBack _sandbag2;

// =====================================================
// SMALL CHECKPOINT CRATE
// =====================================================

private _cratePos =
    _roadPos getPos [
        8,
        _roadDir + 90
    ];

private _crate = createVehicle [
    "Box_NATO_Equip_F",
    _cratePos,
    [],
    0,
    "NONE"
];

clearWeaponCargoGlobal _crate;
clearMagazineCargoGlobal _crate;
clearItemCargoGlobal _crate;
clearBackpackCargoGlobal _crate;

_crate addItemCargoGlobal [
    "FirstAidKit",
    2
];

_crate addMagazineCargoGlobal [
    "30Rnd_65x39_caseless_mag",
    4
];

_objects pushBack _crate;

// =====================================================
// CHECKPOINT MARKER
// =====================================================

private _markerName =
    format [
        "RVG_Roadblock_%1",
        diag_tickTime
    ];

private _marker =
    createMarker [
        _markerName,
        _roadPos
    ];

_marker setMarkerType "mil_warning";
_marker setMarkerColor "ColorRed";
_marker setMarkerText "HOSTILE CHECKPOINT";

// =====================================================
// CREATE HOSTILE GROUP
// =====================================================

private _group =
    createGroup east;

// =====================================================
// SPAWN CHECKPOINT GUARDS
// =====================================================

private _guardPositions = [

    _roadPos getPos [
        10,
        _roadDir + 90
    ],

    _roadPos getPos [
        10,
        _roadDir - 90
    ],

    _roadPos getPos [
        15,
        _roadDir + 90
    ],

    _roadPos getPos [
        15,
        _roadDir - 90
    ],

    _roadPos getPos [
        5,
        _roadDir + 180
    ]
];

{
    private _unit =
        _group createUnit [
            "O_G_Soldier_F",
            _x,
            [],
            0,
            "FORM"
        ];

    _unit setSkill (0.35 + random 0.20);

    _unit setCombatBehaviour "COMBAT";
    _unit setCombatMode "RED";
    _unit allowFleeing 0;

    _objects pushBack _unit;

} forEach _guardPositions;

// =====================================================
// GIVE ONE GUARD A STRONGER POSITION
// =====================================================

private _leader =
    leader _group;

if (!isNull _leader) then {

    _leader setSkill 0.65;

    _leader setUnitPos "MIDDLE";
};

// =====================================================
// CHECKPOINT DEFENSIVE WAYPOINT
// =====================================================

private _wp =
    _group addWaypoint [
        _roadPos,
        0
    ];

_wp setWaypointType "HOLD";
_wp setWaypointBehaviour "COMBAT";
_wp setWaypointCombatMode "RED";
_wp setWaypointSpeed "LIMITED";

// =====================================================
// EVENT MESSAGE
// =====================================================

[
    "HOSTILE CHECKPOINT DETECTED! Expect armed resistance."
] remoteExec [
    "systemChat",
    0
];

// =====================================================
// LOG
// =====================================================

diag_log format [
    "=== RVG EVENT: Hostile checkpoint created at %1 ===",
    _roadPos
];

diag_log format [
    "=== RVG EVENT: Hostile checkpoint has %1 guards ===",
    count units _group
];

// =====================================================
// CLEANUP AFTER 20 MINUTES
// =====================================================

[
    _objects,
    _group,
    _markerName
] spawn {

    params [
        "_objects",
        "_group",
        "_markerName"
    ];

    sleep 1200;

    {
        if (!isNull _x) then {
            deleteVehicle _x;
        };
    } forEach _objects;

    if (!isNull _group) then {
        deleteGroup _group;
    };

    deleteMarker _markerName;

    diag_log "=== RVG EVENT: Hostile checkpoint expired ===";
};

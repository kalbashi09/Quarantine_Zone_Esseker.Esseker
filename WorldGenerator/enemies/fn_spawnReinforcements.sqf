// =========================================================================
// RVG WorldEnemies — Spawn reactive reinforcements
// =========================================================================
// Triggered when the first garrison unit dies. Spawns a 5-man squad 100-250m
// from the base at a random bearing, then sends them to the base.
//
// These units are NOT tracked in RVG_renegadeGarrison — they don't count
// toward base clear.
// =========================================================================

params ["_basePos"];

// ---- Pick a random approach position -----------------------------------

private _spawnPos = [];
private _spawnBearing = 0;
private _attempts = 0;

while { _attempts < 10 && (_spawnPos isEqualTo []) } do {

    _attempts = _attempts + 1;

    private _bearing  = random 360;
    private _distance = 100 + random 150;

    // Keep the successful/last bearing available outside this scope.
    _spawnBearing = _bearing;

    private _testPos = [
        (_basePos select 0) + (sin _bearing * _distance),
        (_basePos select 1) + (cos _bearing * _distance),
        0
    ];

    // Reject water and any spot inside a building.
    private _nearBuildings =
        nearestTerrainObjects [_testPos, ["BUILDING"], 10];

    if (
        !(surfaceIsWater _testPos) &&
        { _nearBuildings isEqualTo [] }
    ) then {
        _spawnPos = _testPos;
    };
};

// Fallback if no clear spot found.
if (_spawnPos isEqualTo []) then {

    _spawnBearing = random 360;

    _spawnPos = _basePos getPos [
        150,
        _spawnBearing
    ];

    diag_log
        "=== RVG WorldGenerator: Reinforcement spawn — using fallback position ===";
};

// ---- Spawn group -------------------------------------------------------

private _grp = createGroup [east, true];

private _classes = [
    "O_Soldier_F",
    "O_Soldier_lite_F",
    "O_Soldier_AR_F",
    "O_Soldier_M_F",
    "O_Soldier_TL_F"
];

// ---- Local safe spawn helper -------------------------------------------

private _fnc_safeSpawn = {

    params [
        "_grp",
        "_class",
        "_pos",
        ["_tag", ""]
    ];

    private _u =
        _grp createUnit [
            _class,
            _pos,
            [],
            0,
            "NONE"
        ];

    [_u, "bandit"] call RVG_fnc_applyLoadout;

    _u allowDamage false;
    _u setVelocity [0, 0, 0];
    _u enableSimulationGlobal true;
    _u setVariable [
        "RVG_spawnProtected",
        true,
        true
    ];

    _u setUnitPos "AUTO";
    _u setBehaviour "AWARE";
    _u setCombatMode "YELLOW";
    _u setSkill 0.55;

    if (_tag != "") then {
        _u setVariable [
            _tag,
            true,
            true
        ];
    };

    [_u] spawn {

        params ["_u"];

        private _endTime =
            diag_tickTime + 15;

        while {
            diag_tickTime < _endTime
        } do {

            if (isNull _u) exitWith {};
            if (!alive _u) exitWith {};

            _u allowDamage false;
            _u setVelocity [0, 0, 0];
            _u enableSimulationGlobal true;

            sleep 0.3;
        };

        if (isNull _u) exitWith {};

        if (!alive _u) then {

            diag_log format [
                "=== RVG SAFETY: reinforcement %1 DIED during spawn protection at %2 ===",
                typeOf _u,
                getPosATL _u
            ];

        } else {

            _u allowDamage true;

            _u setVariable [
                "RVG_spawnProtected",
                false,
                true
            ];

            _u setVelocity [0, 0, 0];
        };
    };

    _u
};

// ---- Spawn 5 units -----------------------------------------------------

{
    private _offset =
        _spawnPos getPos [
            5 + (_forEachIndex * 1.5),
            (_forEachIndex * 72) + _spawnBearing
        ];

    [
        _grp,
        _x,
        _offset,
        "RVG_reinforcementUnit"
    ] call _fnc_safeSpawn;

} forEach _classes;

// ---- Waypoints — push to base, then engage ----------------------------

private _wpApproach =
    _grp addWaypoint [
        _basePos,
        0
    ];

_wpApproach setWaypointType "MOVE";
_wpApproach setWaypointSpeed "FULL";
_wpApproach setWaypointBehaviour "COMBAT";
_wpApproach setWaypointCombatMode "RED";
_wpApproach setWaypointCompletionRadius 30;

private _wpClear =
    _grp addWaypoint [
        _basePos,
        0
    ];

_wpClear setWaypointType "SAD";
_wpClear setWaypointSpeed "NORMAL";
_wpClear setWaypointBehaviour "COMBAT";
_wpClear setWaypointCombatMode "RED";
_wpClear setWaypointCompletionRadius 100;
_wpClear setWaypointTimeout [
    300,
    600,
    900
];

// ---- Self-terminate after 30 min ---------------------------------------

[_grp] spawn {

    params ["_grp"];

    sleep 1800;

    if (!isNull _grp) then {

        {
            if (!isNull _x) then {
                deleteVehicle _x;
            };
        } forEach (units _grp);

        deleteGroup _grp;

        diag_log
            "=== RVG WorldGenerator: Reinforcements timed out ===";
    };
};

// ---- Debug -------------------------------------------------------------

diag_log format [
    "=== RVG WorldGenerator: Reinforcements spawned at %1, moving to %2 ===",
    _spawnPos,
    _basePos
];

_grp
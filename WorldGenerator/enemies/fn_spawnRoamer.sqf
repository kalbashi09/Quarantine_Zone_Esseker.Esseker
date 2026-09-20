// =========================================================================
// RVG WorldEnemies — Spawn 5-man roamer squad
// =========================================================================
// Bandit loadout, East side. Same layered spawn protection as garrison.
// =========================================================================

params ["_basePos"];

// ---- Pick destination ---------------------------------------------------
private _destPos = [];

private _active = missionNamespace getVariable ["RVG_activeMissions", []];
if (!(_active isEqualTo [])) then {
    private _missionPositions = _active apply { _x select 3 };
    _destPos = selectRandom _missionPositions;
} else {
    private _locs = nearestLocations [
        _basePos,
        ["NameCityCapital", "NameCity", "NameVillage"],
        3000
    ];
    if (!(_locs isEqualTo [])) then {
        _destPos = locationPosition (selectRandom _locs);
    } else {
        _destPos = _basePos getPos [800, random 360];
    };
};

// ---- Spawn group --------------------------------------------------------
private _grp = createGroup [east, true];

private _classes = [
    "O_Soldier_F",
    "O_Soldier_lite_F",
    "O_Soldier_AR_F",
    "O_Soldier_M_F",
    "O_Soldier_exp_F"
];

// ---- Local helper ------------------------------------------------------
private _fnc_safeSpawn = {
    params ["_grp", "_class", "_pos", ["_tag", ""]];

    private _u = _grp createUnit [_class, _pos, [], 0, "NONE"];

    [_u, "bandit"] call RVG_fnc_applyLoadout;

    _u allowDamage false;
    _u setVelocity [0, 0, 0];
    _u enableSimulationGlobal true;
    _u setVariable ["RVG_spawnProtected", true, true];

    _u setUnitPos "AUTO";
    _u setBehaviour "AWARE";
    _u setCombatMode "YELLOW";
    _u setSkill 0.55;
    if (_tag != "") then { _u setVariable [_tag, true, true]; };

    [_u] spawn {
        params ["_u"];
        private _endTime = diag_tickTime + 15;

        while { diag_tickTime < _endTime } do {
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
                "=== RVG SAFETY: roamer %1 DIED during spawn protection at %2 ===",
                typeOf _u,
                getPosATL _u
            ];
        } else {
            _u allowDamage true;
            _u setVariable ["RVG_spawnProtected", false, true];
            _u setVelocity [0, 0, 0];
        };
    };

    _u
};

{
    private _pos = _basePos getPos [8 + (_forEachIndex * 2), (_forEachIndex * 72)];
    [_grp, _x, _pos, "RVG_roamerUnit"] call _fnc_safeSpawn;
} forEach _classes;

// ---- Waypoints ----------------------------------------------------------
private _wpMove = _grp addWaypoint [_destPos, 0];
_wpMove setWaypointType "MOVE";
_wpMove setWaypointSpeed "NORMAL";
_wpMove setWaypointBehaviour "AWARE";
_wpMove setWaypointCombatMode "YELLOW";
_wpMove setWaypointCompletionRadius 100;

private _wpSearch = _grp addWaypoint [_destPos, 0];
_wpSearch setWaypointType "SAD";
_wpSearch setWaypointSpeed "LIMITED";
_wpSearch setWaypointBehaviour "AWARE";
_wpSearch setWaypointCombatMode "YELLOW";
_wpSearch setWaypointCompletionRadius 300;
_wpSearch setWaypointTimeout [300, 600, 900];

private _wpReturn = _grp addWaypoint [_basePos, 0];
_wpReturn setWaypointType "MOVE";
_wpReturn setWaypointSpeed "NORMAL";
_wpReturn setWaypointBehaviour "AWARE";
_wpReturn setWaypointCompletionRadius 50;

private _wpCycle = _grp addWaypoint [_basePos, 0];
_wpCycle setWaypointType "CYCLE";

// ---- Self-terminate after 30 min ---------------------------------------
[_grp] spawn {
    params ["_grp"];
    sleep 1800;

    if (!isNull _grp) then {
        {
            if (!isNull _x) then { deleteVehicle _x; };
        } forEach (units _grp);
        deleteGroup _grp;
        diag_log "=== RVG WorldGenerator: Roamer timed out ===";
    };
};

diag_log format [
    "=== RVG WorldGenerator: Roamer spawned at %1, target %2 ===",
    _basePos,
    _destPos
];

_grp
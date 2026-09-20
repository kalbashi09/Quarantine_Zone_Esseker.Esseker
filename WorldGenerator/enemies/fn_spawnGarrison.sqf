// =========================================================================
// RVG WorldEnemies — Spawn Renegade garrison
// =========================================================================
// 20 bandit units (14 static, 6 patrol) with bandit loadout and layered
// spawn protection.
//
// Reactive: when the first garrison unit dies, dispatches a 5-man
// reinforcement squad from 100-250m out that pushes toward the base.
// =========================================================================

params ["_center"];

private _classes = [
    "O_Soldier_F",
    "O_Soldier_lite_F",
    "O_Soldier_SL_F",
    "O_Soldier_TL_F",
    "O_Soldier_AR_F",
    "O_Soldier_GL_F",
    "O_Soldier_LAT_F",
    "O_Soldier_M_F",
    "O_medic_F",
    "O_Soldier_exp_F"
];

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
    _u setSkill 0.55;                          // ← was 0.5
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
                "=== RVG SAFETY: %1 DIED during spawn protection at %2 ===",
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

private _staticGrp = createGroup [east, true];
private _patrolGrp = createGroup [east, true];

private _staticPosts = [
    [ 18,  45], [ 18, 135], [ 18, 225], [ 18, 315],
    [ 22,   0], [ 22,  90], [ 22, 180], [ 22, 270],
    [  8,   0], [  8, 120], [  8, 240],
    [  5,  45], [  5, 135], [  5, 270]
];

{
    _x params ["_dist", "_bearing"];
    private _class = selectRandom _classes;
    private _pos   = _center getPos [_dist, _bearing];

    private _u = [_staticGrp, _class, _pos, "RVG_renegadeGarrisonUnit"] call _fnc_safeSpawn;

    doStop _u;
} forEach _staticPosts;

for "_i" from 0 to 5 do {
    private _class = selectRandom _classes;
    private _pos   = _center getPos [15, _i * 60];
    [_patrolGrp, _class, _pos, "RVG_renegadeGarrisonUnit"] call _fnc_safeSpawn;
};

private _loopBearings = [45, 135, 225, 315];
{
    private _wp = _patrolGrp addWaypoint [_center getPos [20, _x], 0];
    _wp setWaypointType "MOVE";
    _wp setWaypointSpeed "LIMITED";
    _wp setWaypointBehaviour "AWARE";
    _wp setWaypointCombatMode "YELLOW";
    _wp setWaypointCompletionRadius 5;
} forEach _loopBearings;

private _wpCycle = _patrolGrp addWaypoint [_center getPos [20, 45], 0];
_wpCycle setWaypointType "CYCLE";

// =========================================================================
// Distance-gated sim + reactive reinforcement trigger
// =========================================================================
[_center, [_staticGrp, _patrolGrp]] spawn {
    params ["_center", "_groups"];

    sleep 30;

    private _lastAlive           = 0;
    private _firstRun            = true;
    private _reinforcementsSent  = false;

    while { true } do {
        sleep 10;

        private _currentAlive = 0;
        {
            _currentAlive = _currentAlive + ({ alive _x } count (units _x));
        } forEach _groups;

        if (_currentAlive == 0) exitWith {};

        // ---- Reactive trigger: first actual death --------------------
        // Skip the first iteration — that's just recording the baseline.
        if (!_firstRun && !_reinforcementsSent && _currentAlive < _lastAlive) then {
            _reinforcementsSent = true;
            [_center] spawn RVG_fnc_spawnReinforcements;
            diag_log "=== RVG WorldGenerator: Garrison under attack — reinforcements dispatched ===";
        };

        _firstRun  = false;
        _lastAlive = _currentAlive;

        // ---- Distance gate -------------------------------------------
        private _nearPlayer = false;
        {
            if (alive _x && { (_x distance _center) < 800 }) exitWith {
                _nearPlayer = true;
            };
        } forEach allPlayers;

        {
            {
                if (!isNull _x && { !(_x getVariable ["RVG_spawnProtected", false]) }) then {
                    _x enableSimulationGlobal _nearPlayer;
                };
            } forEach (units _x);
        } forEach _groups;
    };

    diag_log "=== RVG WorldGenerator: Garrison watchdog exited (all dead) ===";
};

[_staticGrp, _patrolGrp]
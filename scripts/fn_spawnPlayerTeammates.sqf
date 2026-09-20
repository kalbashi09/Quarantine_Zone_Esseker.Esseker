// =========================================================================
// Spawn player AI teammates from a persistent roster (Ravage).
// =========================================================================
// Idempotent: safe to call every tick. Only spawns missing roster slots.
// Dead, untagged, or duplicate units in the group are removed each pass.
// =========================================================================

params ["_grp", "_pos"];

private _uid = getPlayerUID player;
private _rosterKey = format ["RVG_teamRoster_%1", _uid];
private _roster = missionNamespace getVariable [_rosterKey, []];

if (_roster isEqualTo []) then {
    private _classPool   = ["B_medic_F", "B_Soldier_AR_F", "B_Soldier_LAT_F"];
    private _namePool    = ["Doc", "Ace", "Smoke"];
    private _facePool    = [
        "WhiteHead_01","WhiteHead_02","WhiteHead_03","WhiteHead_04","WhiteHead_05",
        "WhiteHead_06","WhiteHead_07","WhiteHead_08","WhiteHead_09","WhiteHead_10"
    ];
    private _speakerPool = ["Male01ENG","Male02ENG","Male03ENG","Male04ENG","Male05ENG"];

    {
        _roster pushBack [
            _x,
            _namePool select _forEachIndex,
            selectRandom _facePool,
            selectRandom _speakerPool,
            1.0
        ];
    } forEach _classPool;

    missionNamespace setVariable [_rosterKey, _roster];
};

private _aliveIdx = [];
private _toDelete = [];
{
    if (!isNull _x && { !isPlayer _x }) then {
        private _i = _x getVariable ["RVG_rosterIdx", -1];
        if (alive _x && { _i >= 0 } && { _i < count _roster } && { !(_i in _aliveIdx) }) then {
            _aliveIdx pushBack _i;
        } else {
            _toDelete pushBack _x;
        };
    };
} forEach (units _grp);

{ if (!isNull _x) then { deleteVehicle _x; }; } forEach _toDelete;

// I map the roster class to the loadout kit string once.
private _fnc_kitForClass = {
    params ["_class"];
    switch (_class) do {
        case "B_medic_F":       { "medic" };
        case "B_Soldier_AR_F":  { "ar" };
        case "B_Soldier_LAT_F": { "lat" };
        default                 { "rifleman" };
    };
};

{
    if (!(_forEachIndex in _aliveIdx)) then {
        _x params ["_class", "_name", "_face", "_speaker", "_pitch"];

        private _unitPos = _pos getPos [4 + (_forEachIndex * 2), (_forEachIndex * 120)];
        private _u = _grp createUnit [_class, _unitPos, [], 0, "NONE"];

        // Identity (JIP-safe).
        [_u, _name]    remoteExec ["setName", 0, _u];
        [_u, _face]    remoteExec ["setFace", 0, _u];
        [_u, _speaker] remoteExec ["setSpeaker", 0, _u];
        [_u, _pitch]   remoteExec ["setPitch", 0, _u];

        // Gear — derive kit from class, then apply.
        private _kit = [_class] call _fnc_kitForClass;
        [_u, _kit] call RVG_fnc_applyLoadout;

        // Tags.
        _u setVariable ["RVG_rosterIdx", _forEachIndex, true];
        _u setVariable ["RVG_ownerUID",  _uid,          true];

        // Posture.
        _u setUnitPos "AUTO";
        _u setCombatMode "YELLOW";
        _u setBehaviour "AWARE";
        _u setDir (random 360);
    };
} forEach _roster;

nil
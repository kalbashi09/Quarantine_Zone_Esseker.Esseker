// =========================================================================
// RVG SaveState — LOAD
// =========================================================================

if (!isServer) exitWith {};

params [["_player", objNull]];

if (isNull _player) exitWith {
    diag_log "RVG LOAD ERROR: Player object is null.";
};

private _uid = getPlayerUID _player;

if (_uid == "") exitWith {
    diag_log "RVG LOAD ERROR: Player UID is empty.";
};

private _key = format ["RVG_PersistentSave_%1", _uid];

private _saveData = profileNamespace getVariable [_key, []];

if (_saveData isEqualTo []) exitWith {

    [
        "NO PERSISTENT SAVE FOUND."
    ] remoteExec ["systemChat", owner _player];

    diag_log format [
        "RVG LOAD: No save found for UID %1.",
        _uid
    ];
};

_saveData params [
    "_version",
    "_timestamp",
    "_savedUID",
    "_playerData",
    "_teamData",
    "_arsenalData"
    // "_renegadeBaseData"
];

// -------------------------------------------------------------------------
// Restore player
// -------------------------------------------------------------------------

[_player, _playerData] remoteExec [
    "RVG_fnc_restorePlayer",
    owner _player
];

// -------------------------------------------------------------------------
// Restore arsenal
// -------------------------------------------------------------------------

[_arsenalData] call RVG_fnc_restoreArsenal;

// -------------------------------------------------------------------------
// Restore renegade base
// -------------------------------------------------------------------------

// [_renegadeBaseData] call RVG_fnc_restoreRenegadeBase;

// -------------------------------------------------------------------------
// Restore teammates
// -------------------------------------------------------------------------

private _grp = group _player;

// First make sure the normal roster system creates missing teammates.
[_grp, getPosATL _player] call RVG_fnc_spawnPlayerTeammates;

sleep 1;

{
    _x params [
        "_rosterIdx",
        "_position",
        "_direction",
        "_loadout",
        "_damage"
    ];

    private _unit = objNull;

    {
        if (
            !isPlayer _x &&
            { _x getVariable ["RVG_ownerUID", ""] == _uid } &&
            { (_x getVariable ["RVG_rosterIdx", -1]) == _rosterIdx }
        ) exitWith {
            _unit = _x;
        };
    } forEach units _grp;

    if (!isNull _unit) then {

        _unit setPosATL _position;
        _unit setDir _direction;
        _unit setUnitLoadout _loadout;
        _unit setDamage _damage;
    };

} forEach _teamData;

// -------------------------------------------------------------------------
// Done
// -------------------------------------------------------------------------

diag_log format [
    "=== RVG LOAD COMPLETE: UID %1 | Version %2 ===",
    _uid,
    _version
];

[
    format [
        "PERSISTENT LOAD COMPLETE — %1 teammates restored.",
        count _teamData
    ]
] remoteExec ["systemChat", owner _player];
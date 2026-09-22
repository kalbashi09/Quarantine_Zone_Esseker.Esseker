// =========================================================================
// RVG SaveState — SAVE
// =========================================================================

if (!isServer) exitWith {};

params [["_player", objNull]];

if (isNull _player) exitWith {
    diag_log "RVG SAVE ERROR: Player object is null.";
};

private _uid = getPlayerUID _player;

if (_uid == "") exitWith {
    diag_log "RVG SAVE ERROR: Player UID is empty.";
};

// -------------------------------------------------------------------------
// PLAYER
// -------------------------------------------------------------------------

private _playerData = [_player] call RVG_fnc_collectPlayer;

// -------------------------------------------------------------------------
// ARSENAL
// -------------------------------------------------------------------------

private _arsenalData = call RVG_fnc_collectArsenal;

// -------------------------------------------------------------------------
// RENEGADE BASE
// -------------------------------------------------------------------------

private _renegadeBaseData = call RVG_fnc_collectRenegadeBase;

// -------------------------------------------------------------------------
// MISSIONS
// -------------------------------------------------------------------------

private _missionData = call RVG_fnc_collectMissions;

// -------------------------------------------------------------------------
// TEAMMATES
// -------------------------------------------------------------------------

private _teamData = [];

{
    if (
        !isPlayer _x &&
        { _x getVariable ["RVG_ownerUID", ""] == _uid } &&
        { !(_x getVariable ["RVG_missionUnit", false]) }
    ) then {

        _teamData pushBack [
            _x getVariable ["RVG_rosterIdx", -1],
            getPosATL _x,
            getDir _x,
            getUnitLoadout _x,
            damage _x
        ];
    };

} forEach allUnits;

// -------------------------------------------------------------------------
// COMPLETE SAVE DATA
// -------------------------------------------------------------------------

private _saveData = [
    3, // version
    diag_tickTime,
    _uid,
    _playerData,
    _teamData,
    _arsenalData,
    _renegadeBaseData,
    _missionData
];

// -------------------------------------------------------------------------
// WRITE
// -------------------------------------------------------------------------

private _key = format ["RVG_PersistentSave_%1", _uid];

profileNamespace setVariable [
    _key,
    _saveData
];

saveProfileNamespace;

diag_log format [
    "=== RVG SAVE COMPLETE: UID %1 ===",
    _uid
];

[format [
    "PERSISTENT SAVE COMPLETE — %1 teammates, %2 missions saved.",
    count _teamData,
    count _missionData
]] remoteExec ["systemChat", owner _player];
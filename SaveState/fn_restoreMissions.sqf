// =========================================================================
// RVG SaveState — RESTORE MISSIONS
// =========================================================================

params ["_missionData"];

if (!isServer) exitWith {};

if (_missionData isEqualTo []) exitWith {
    diag_log "RVG LOAD: No saved missions to restore.";
};

missionNamespace setVariable [
    "RVG_missionRestoreInProgress",
    true,
    true
];

// -------------------------------------------------------------------------
// Clear currently active missions
// -------------------------------------------------------------------------

private _activeMissions = missionNamespace getVariable [
    "RVG_activeMissions",
    []
];

{
    private _slot = _x select 0;

    [_slot] call RVG_fnc_clearMissionEntities;

} forEach _activeMissions;

// Reset mission runtime data
missionNamespace setVariable [
    "RVG_activeMissions",
    [],
    true
];

missionNamespace setVariable [
    "RVG_usedMissionLocations",
    []
];

// -------------------------------------------------------------------------
// Recreate saved missions
// -------------------------------------------------------------------------

{
    _x params [
        "_slot",
        "_missionType",
        "_locationName",
        "_missionPos"
    ];

    // -------------------------------------------------------------
    // Create a NEW runtime instance for this restored mission.
    //
    // This is NOT saved.
    // It exists only to identify this particular mission instance.
    // -------------------------------------------------------------

    private _missionInstance = format [
        "RESTORE_%1_%2",
        diag_tickTime,
        _slot
    ];

    private _active = missionNamespace getVariable [
        "RVG_activeMissions",
        []
    ];

    _active pushBack [
        _slot,
        _missionType,
        _locationName,
        _missionPos,
        _missionInstance
    ];

    missionNamespace setVariable [
        "RVG_activeMissions",
        _active,
        true
    ];

    diag_log format [
        "RVG LOAD: Restoring mission Slot %1 = %2 near %3 at %4",
        _slot + 1,
        _missionType,
        _locationName,
        _missionPos
    ];

    diag_log format [
        "RVG LOAD: Runtime instance %1",
        _missionInstance
    ];

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

} forEach _missionData;

missionNamespace setVariable [
    "RVG_missionRestoreInProgress",
    false,
    true
];

diag_log format [
    "RVG LOAD: Restored %1 mission definitions.",
    count _missionData
];
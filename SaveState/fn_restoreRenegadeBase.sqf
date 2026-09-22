// =========================================================================
// RVG SaveState — Restore Renegade Base State
// =========================================================================

params ["_data"];

missionNamespace setVariable [
    "RVG_renegadeBaseRestoreInProgress",
    true,
    true
];

_data params [
    "_active",
    "_basePos",
    "_locationName",
    "_lastCleared",
    "_crateData"
];

diag_log "=== RVG SAVE: Restoring Renegade Base ===";

// -------------------------------------------------------------------------
// Clean up currently existing generated base
// -------------------------------------------------------------------------

private _currentObjects = missionNamespace getVariable [
    "RVG_renegadeBaseObjects",
    []
];

{
    if (!isNull _x) then {
        deleteVehicle _x;
    };
} forEach _currentObjects;

private _currentGarrison = missionNamespace getVariable [
    "RVG_renegadeGarrison",
    []
];

{
    if (!isNull _x) then {
        {
            if (!isNull _x) then {
                deleteVehicle _x;
            };
        } forEach units _x;

        deleteGroup _x;
    };
} forEach _currentGarrison;

private _currentCrate = missionNamespace getVariable [
    "RVG_renegadeCrate",
    objNull
];

if (!isNull _currentCrate) then {
    deleteVehicle _currentCrate;
};

// Reset references
missionNamespace setVariable ["RVG_renegadeBaseObjects", []];
missionNamespace setVariable ["RVG_renegadeGarrison", []];
missionNamespace setVariable ["RVG_renegadeCrate", objNull];

// -------------------------------------------------------------------------
// Restore basic state
// -------------------------------------------------------------------------

missionNamespace setVariable [
    "RVG_renegadeBaseActive",
    _active
];

missionNamespace setVariable [
    "RVG_renegadeBasePos",
    _basePos
];

missionNamespace setVariable [
    "RVG_renegadeLocationName",
    _locationName
];

missionNamespace setVariable [
    "RVG_renegadeLastCleared",
    _lastCleared
];

// -------------------------------------------------------------------------
// If there was no active base when saved, stop here.
// -------------------------------------------------------------------------

if (!_active) exitWith {

    [
        "RESET",
        "",
        [0, 0, 0]
    ] remoteExec [
        "RVG_fnc_baseIntel",
        0
    ];

    missionNamespace setVariable [
        "RVG_renegadeBaseRestoreInProgress",
        false,
        true
    ];

    diag_log "=== RVG SAVE: No active Renegade Base to restore ===";
};

// -------------------------------------------------------------------------
// Rebuild the saved base
//
// Try up to 3 times. The base is considered successfully restored only
// when buildRenegadeBase returns a valid object array and a valid crate.
// -------------------------------------------------------------------------

private _buildSuccess = false;
private _objects = [];
private _crate = objNull;

for "_attempt" from 1 to 3 do {

    diag_log format [
        "=== RVG SAVE: Building Renegade Base — attempt %1/3 ===",
        _attempt
    ];

    // Clean up anything left by a previous failed attempt.
    {
        if (!isNull _x) then {
            deleteVehicle _x;
        };
    } forEach _objects;

    if (!isNull _crate) then {
        deleteVehicle _crate;
    };

    _objects = [];
    _crate = objNull;

    // Build base.
    private _buildResult = [
        _basePos
    ] call RVG_fnc_buildRenegadeBase;

    // Validate returned data.
    if (
        _buildResult isEqualType [] &&
        {count _buildResult >= 2}
    ) then {

        private _candidateObjects = _buildResult select 0;
        private _candidateCrate   = _buildResult select 1;

        if (
            _candidateObjects isEqualType [] &&
            {_candidateCrate isEqualType objNull} &&
            {!isNull _candidateCrate}
        ) then {

            _objects = _candidateObjects;
            _crate   = _candidateCrate;

            _buildSuccess = true;

            diag_log format [
                "=== RVG SAVE: Renegade Base build verified on attempt %1 — %2 objects + crate ===",
                _attempt,
                count _objects
            ];

            break;
        };
    };

    diag_log format [
        "=== RVG SAVE WARNING: Renegade Base build failed verification on attempt %1/3 ===",
        _attempt
    ];

    // Give Arma one frame/second before retrying.
    sleep 1;
};

// -------------------------------------------------------------------------
// Base restoration failed completely
// -------------------------------------------------------------------------

if (!_buildSuccess) exitWith {

    missionNamespace setVariable [
        "RVG_renegadeBaseActive",
        false
    ];

    missionNamespace setVariable [
        "RVG_renegadeBaseObjects",
        []
    ];

    missionNamespace setVariable [
        "RVG_renegadeGarrison",
        []
    ];

    missionNamespace setVariable [
        "RVG_renegadeCrate",
        objNull
    ];

    missionNamespace setVariable [
        "RVG_renegadeBaseRestoreInProgress",
        false,
        true
    ];

    diag_log [
        "=== RVG SAVE ERROR: Renegade Base could not be restored after 3 attempts ==="
    ];
};

// -------------------------------------------------------------------------
// Store verified base references
// -------------------------------------------------------------------------

missionNamespace setVariable [
    "RVG_renegadeBaseObjects",
    _objects
];

missionNamespace setVariable [
    "RVG_renegadeCrate",
    _crate
];

// -------------------------------------------------------------------------
// Restore garrison
// -------------------------------------------------------------------------

private _garrison = [
    _basePos
] call RVG_fnc_spawnGarrison;

if (
    !(_garrison isEqualType []) ||
    {count _garrison == 0}
) then {

    diag_log [
        "=== RVG SAVE WARNING: Renegade Base restored but garrison returned empty ==="
    ];

} else {

    missionNamespace setVariable [
        "RVG_renegadeGarrison",
        _garrison
    ];

    diag_log format [
        "=== RVG SAVE: Renegade garrison restored — %1 groups ===",
        count _garrison
    ];
};

// -------------------------------------------------------------------------
// Restore Field Intel diary
// -------------------------------------------------------------------------

[
    "LOAD",
    _locationName,
    _basePos
] remoteExec [
    "RVG_fnc_baseIntel",
    0
];

// -------------------------------------------------------------------------
// Restore crate state
// -------------------------------------------------------------------------

if (
    !isNull _crate &&
    {!(_crateData isEqualTo [])}
) then {

    _crateData params [
        "_cratePos",
        "_crateDir",
        "_weaponCargo",
        "_itemCargo",
        "_magazineCargo",
        "_backpackCargo"
    ];

    clearWeaponCargoGlobal _crate;
    clearItemCargoGlobal _crate;
    clearMagazineCargoGlobal _crate;
    clearBackpackCargoGlobal _crate;

    _crate setPosATL _cratePos;
    _crate setDir _crateDir;

    // ---------------------------------------------------------------------
    // Weapons
    // ---------------------------------------------------------------------

    private _weaponClasses = _weaponCargo select 0;
    private _weaponCounts  = _weaponCargo select 1;

    for "_i" from 0 to ((count _weaponClasses) - 1) do {

        _crate addWeaponCargoGlobal [
            _weaponClasses select _i,
            _weaponCounts select _i
        ];
    };

    // ---------------------------------------------------------------------
    // Items
    // ---------------------------------------------------------------------

    private _itemClasses = _itemCargo select 0;
    private _itemCounts  = _itemCargo select 1;

    for "_i" from 0 to ((count _itemClasses) - 1) do {

        _crate addItemCargoGlobal [
            _itemClasses select _i,
            _itemCounts select _i
        ];
    };

    // ---------------------------------------------------------------------
    // Magazines
    // ---------------------------------------------------------------------

    private _magClasses = _magazineCargo select 0;
    private _magCounts  = _magazineCargo select 1;

    for "_i" from 0 to ((count _magClasses) - 1) do {

        _crate addMagazineCargoGlobal [
            _magClasses select _i,
            _magCounts select _i
        ];
    };

    // ---------------------------------------------------------------------
    // Backpacks
    // ---------------------------------------------------------------------

    private _backpackClasses = _backpackCargo select 0;
    private _backpackCounts  = _backpackCargo select 1;

    for "_i" from 0 to ((count _backpackClasses) - 1) do {

        _crate addBackpackCargoGlobal [
            _backpackClasses select _i,
            _backpackCounts select _i
        ];
    };

    diag_log "=== RVG SAVE: Renegade crate inventory restored ===";

} else {

    diag_log "=== RVG SAVE: No saved crate inventory to restore ===";
};

// -------------------------------------------------------------------------
// Final confirmation
// -------------------------------------------------------------------------

diag_log format [
    "=== RVG SAVE: Renegade Base restored at %1 (%2) ===",
    _locationName,
    _basePos
];

missionNamespace setVariable [
    "RVG_renegadeBaseRestoreInProgress",
    false,
    true
];
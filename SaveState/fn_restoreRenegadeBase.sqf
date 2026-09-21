// =========================================================================
// RVG SaveState — Restore Renegade Base State
// =========================================================================

params ["_data"];

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
    diag_log "=== RVG SAVE: No active Renegade Base to restore ===";
};

// -------------------------------------------------------------------------
// Rebuild the saved base
// -------------------------------------------------------------------------

private _buildResult = [
    _basePos
] call RVG_fnc_buildRenegadeBase;

private _objects = _buildResult select 0;
private _crate = _buildResult select 1;

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

missionNamespace setVariable [
    "RVG_renegadeGarrison",
    _garrison
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

    // Weapons
    private _weaponClasses = _weaponCargo select 0;
    private _weaponCounts  = _weaponCargo select 1;

    for "_i" from 0 to ((count _weaponClasses) - 1) do {
        _crate addWeaponCargoGlobal [
            _weaponClasses select _i,
            _weaponCounts select _i
        ];
    };

    // Items
    private _itemClasses = _itemCargo select 0;
    private _itemCounts  = _itemCargo select 1;

    for "_i" from 0 to ((count _itemClasses) - 1) do {
        _crate addItemCargoGlobal [
            _itemClasses select _i,
            _itemCounts select _i
        ];
    };

    // Magazines
    private _magClasses = _magazineCargo select 0;
    private _magCounts  = _magazineCargo select 1;

    for "_i" from 0 to ((count _magClasses) - 1) do {
        _crate addMagazineCargoGlobal [
            _magClasses select _i,
            _magCounts select _i
        ];
    };

    // Backpacks
    private _backpackClasses = _backpackCargo select 0;
    private _backpackCounts  = _backpackCargo select 1;

    for "_i" from 0 to ((count _backpackClasses) - 1) do {
        _crate addBackpackCargoGlobal [
            _backpackClasses select _i,
            _backpackCounts select _i
        ];
    };
};

diag_log format [
    "=== RVG SAVE: Renegade Base restored at %1 (%2) ===",
    _locationName,
    _basePos
];
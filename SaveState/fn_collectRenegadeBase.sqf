// =========================================================================
// RVG SaveState — Collect Renegade Base State
// =========================================================================

private _active = missionNamespace getVariable [
    "RVG_renegadeBaseActive",
    false
];

private _basePos = missionNamespace getVariable [
    "RVG_renegadeBasePos",
    [0, 0, 0]
];

private _locationName = missionNamespace getVariable [
    "RVG_renegadeLocationName",
    ""
];

private _lastCleared = missionNamespace getVariable [
    "RVG_renegadeLastCleared",
    -99999
];

private _crate = missionNamespace getVariable [
    "RVG_renegadeCrate",
    objNull
];

private _crateData = [];

if (!isNull _crate) then {
    _crateData = [
        getPosATL _crate,
        getDir _crate,
        getWeaponCargo _crate,
        getItemCargo _crate,
        getMagazineCargo _crate,
        getBackpackCargo _crate
    ];
};

[
    _active,
    _basePos,
    _locationName,
    _lastCleared,
    _crateData
]
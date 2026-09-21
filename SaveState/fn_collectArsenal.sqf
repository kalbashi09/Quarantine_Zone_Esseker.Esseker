// =========================================================================
// RVG SaveState — Collect Arsenal
// =========================================================================

private _containers = [
    BaseArsenalWeapons,
    BaseArsenalEquipments,
    BaseArsenalEssentials,
    BaseArsenalAttachments
];

private _result = [];

{
    private _container = _x;

    _result pushBack [
        getWeaponCargo _container,
        getItemCargo _container,
        getMagazineCargo _container,
        getBackpackCargo _container
    ];

} forEach _containers;

_result
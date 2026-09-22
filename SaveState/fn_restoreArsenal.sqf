// =========================================================================
// RVG SaveState — Restore Arsenal
// =========================================================================

params ["_data"];

private _containers = [
    BaseArsenalWeapons,
    BaseArsenalEquipments,
    BaseArsenalEssentials,
    BaseArsenalAttachments,
    BaseArsenalStorage
];

{
    private _container = _containers select _forEachIndex;
    private _dataSet = _x;

    clearWeaponCargoGlobal _container;
    clearItemCargoGlobal _container;
    clearMagazineCargoGlobal _container;
    clearBackpackCargoGlobal _container;

    // ---------------------------------------------------------
    // Weapons
    // ---------------------------------------------------------

    private _weapons = _dataSet select 0;

    private _weaponClasses = _weapons select 0;
    private _weaponCounts  = _weapons select 1;

    for "_i" from 0 to ((count _weaponClasses) - 1) do {
        _container addWeaponCargoGlobal [
            _weaponClasses select _i,
            _weaponCounts select _i
        ];
    };

    // ---------------------------------------------------------
    // Items
    // ---------------------------------------------------------

    private _items = _dataSet select 1;

    private _itemClasses = _items select 0;
    private _itemCounts  = _items select 1;

    for "_i" from 0 to ((count _itemClasses) - 1) do {
        _container addItemCargoGlobal [
            _itemClasses select _i,
            _itemCounts select _i
        ];
    };

    // ---------------------------------------------------------
    // Magazines
    // ---------------------------------------------------------

    private _magazines = _dataSet select 2;

    private _magClasses = _magazines select 0;
    private _magCounts  = _magazines select 1;

    for "_i" from 0 to ((count _magClasses) - 1) do {
        _container addMagazineCargoGlobal [
            _magClasses select _i,
            _magCounts select _i
        ];
    };

    // ---------------------------------------------------------
    // Backpacks
    // ---------------------------------------------------------

    private _backpacks = _dataSet select 3;

    private _backpackClasses = _backpacks select 0;
    private _backpackCounts  = _backpacks select 1;

    for "_i" from 0 to ((count _backpackClasses) - 1) do {
        _container addBackpackCargoGlobal [
            _backpackClasses select _i,
            _backpackCounts select _i
        ];
    };

} forEach _data;

diag_log "=== RVG SAVE: Arsenal restored ===";
// =========================================================================
// RVG SaveState — Restore Player
// =========================================================================

params ["_unit", "_data"];

_data params [
    "_position",
    "_direction",
    "_loadout",
    "_damage"
];

_unit setPosATL _position;
_unit setDir _direction;

_unit setUnitLoadout _loadout;

_unit setDamage _damage;

diag_log "=== RVG SAVE: Player restored ===";
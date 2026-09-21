// =========================================================================
// RVG SaveState — Collect Player
// =========================================================================

params ["_unit"];

[
    getPosATL _unit,
    getDir _unit,
    getUnitLoadout _unit,
    damage _unit
]
// =========================================================================
// RVG WorldEnemies — Build Renegade base composition
// =========================================================================
// 25m HESCO ring with 4 cardinal gaps. Watchtowers at diagonals, tents
// and crates inside, campfire, lights.
//
// Also spawns and populates a supply crate at the base center. The crate
// is NOT added to the returned objects array, so it survives when the
// garrison is wiped. It becomes the reward for clearing the base.
//
// Returns: [_objects, _crate]
// =========================================================================

params ["_center"];

private _objects = [];

private _fnc_place = {
    params ["_class", "_dist", "_bearing", "_dirOffset"];
    private _p = _center getPos [_dist, _bearing];
    private _o = createVehicle [_class, _p, [], 0, "CAN_COLLIDE"];
    _o setDir _dirOffset;
    _objects pushBack _o;
    _o
};

// ---- HESCO perimeter — 25m ring, 4 gaps --------------------------------
private _r = 25;
{
    ["Land_HBarrier_5_F", _r, _x, _x] call _fnc_place;
} forEach [
    35, 45, 55, 125, 135, 145, 215, 225, 235, 305, 315, 325
];

// ---- Watchtowers -------------------------------------------------------
["Land_Cargo_Patrol_V1_F", 18,  45, 225] call _fnc_place;
["Land_Cargo_Patrol_V1_F", 18, 135, 135] call _fnc_place;
["Land_Cargo_Patrol_V1_F", 18, 225,  45] call _fnc_place;
["Land_Cargo_Patrol_V1_F", 18, 315, 315] call _fnc_place;

// ---- Tents -------------------------------------------------------------
["Land_TentA_F",     15,  90, 270] call _fnc_place;
["Land_TentA_F",     15, 270,  90] call _fnc_place;
["Land_TentDome_F",   8,   0, 180] call _fnc_place;

// ---- Sandbag positions -------------------------------------------------
["Land_BagBunker_Small_F", 12,  20, 200] call _fnc_place;
["Land_BagBunker_Small_F", 12, 160, 340] call _fnc_place;
["Land_BagBunker_Small_F", 12, 340, 160] call _fnc_place;

// ---- Small crates (decorative — not the loot crate) --------------------
["Box_IND_Wps_F",   6,  45, 0] call _fnc_place;
["Box_IND_Ammo_F",  6, 315, 0] call _fnc_place;

// ---- Campfire (moved clear of unit posts) ------------------------------
private _fire = ["Land_Campfire_F", 12, 180, random 360] call _fnc_place;
_fire inflame true;

// ---- Lights ------------------------------------------------------------
["Land_PortableLight_double_F", 20,  90, 0] call _fnc_place;
["Land_PortableLight_double_F", 20, 270, 0] call _fnc_place;

// =========================================================================
// SUPPLY CRATE — reward for clearing the base
// =========================================================================
// Spawned at exact centre. Static posts are all 5m+ away, so no overlap.
// NOT added to _objects — survives the clear.
// =========================================================================

private _cratePos = _center;
private _crate = createVehicle [
    "Box_IND_WpsSpecial_F",
    _cratePos,
    [], 0, "CAN_COLLIDE"
];
_crate setDir (random 360);
_crate allowDamage false;

// Empty anything the class spawns with.
clearWeaponCargoGlobal   _crate;
clearMagazineCargoGlobal _crate;
clearItemCargoGlobal     _crate;
clearBackpackCargoGlobal _crate;

// ---- Populate with randomized loot -------------------------------------

// Weapons — common pool (bandit-plausible)
private _commonWeapons = [
    "arifle_AKM_F",
    "arifle_AKS_F",
    "arifle_Mk20_F",
    "arifle_Mk20C_F",
    "arifle_TRG20_F",
    "arifle_TRG21_F",
    "SMG_01_F",
    "SMG_02_F",
    "sgun_HunterShotgun_01_F"
];

// Weapons — rare pool (worth clearing the base for)
private _rareWeapons = [
    "arifle_MX_F",
    "arifle_MXC_F",
    "arifle_Katiba_F",
    "arifle_Katiba_C_F",
    "CUP_arifle_M4A1"
];

// Magazines — full pool
private _magPool = [
    "30Rnd_762x39_Mag_F",
    "30Rnd_545x39_Mag_F",
    "30Rnd_556x45_Stanag",
    "30Rnd_65x39_caseless_mag",
    "30Rnd_65x39_caseless_green",
    "30Rnd_45ACP_Mag_SMG_01",
    "30Rnd_9x21_Mag_SMG_02",
    "16Rnd_9x21_Mag",
    "9Rnd_45ACP_Mag",
    "6Rnd_45ACP_Cylinder",
    "2Rnd_12Gauge_Pellets",
    "CUP_30Rnd_556x45_Stanag"
];

private _attachments = [
    "optic_Holosight",
    "optic_MRCO",
    "optic_Hamr",
    "optic_ACO_grn",
    "optic_Aco_smg",
    "muzzle_snds_M",
    "muzzle_snds_65_TI_blk_F",
    "muzzle_snds_H",
    "acc_pointer_IR",
    "acc_flashlight"
];

private _backpacks = [
    "B_AssaultPack_rgr",
    "B_AssaultPack_khk",
    "B_AssaultPack_cbr",
    "B_Kitbag_rgr",
    "B_Carryall_oli"
];

// --- Weapons: always 1, likely 2, sometimes rare -----------------------
_crate addWeaponCargoGlobal [selectRandom _commonWeapons, 1];

if (random 1 < 0.75) then {
    _crate addWeaponCargoGlobal [selectRandom _commonWeapons, 1];
};

if (random 1 < 0.50) then {
    _crate addWeaponCargoGlobal [selectRandom [
        "hgun_ACPC2_F","hgun_Rook40_F","hgun_P07_F"
    ], 1];
};

if (random 1 < 0.25) then {
    _crate addWeaponCargoGlobal [selectRandom _rareWeapons, 1];
};

// --- Magazines: 3-5 types, 5-12 count each -----------------------------
private _magTypes = 3 + floor random 3;
private _magPoolCopy = +_magPool;

for "_i" from 1 to _magTypes do {
    if (_magPoolCopy isEqualTo []) exitWith {};
    private _idx = floor random (count _magPoolCopy);
    private _mag = _magPoolCopy select _idx;
    _magPoolCopy deleteAt _idx;

    _crate addMagazineCargoGlobal [_mag, 5 + floor random 8];
};

// --- Medical: always present -------------------------------------------
_crate addItemCargoGlobal ["FirstAidKit", 3 + floor random 3];

if (random 1 < 0.45) then {
    _crate addItemCargoGlobal ["Medikit", 1];
};

// --- Attachments: 60% chance, 1-3 items --------------------------------
if (random 1 < 0.60) then {
    private _count = 1 + floor random 3;
    for "_i" from 1 to _count do {
        _crate addItemCargoGlobal [selectRandom _attachments, 1];
    };
};

// --- Grenades: 55% chance ----------------------------------------------
if (random 1 < 0.55) then {
    _crate addMagazineCargoGlobal ["HandGrenade", 1 + floor random 3];
    _crate addMagazineCargoGlobal ["SmokeShell", 2 + floor random 3];
};

// --- Backpack: 40% chance ----------------------------------------------
if (random 1 < 0.40) then {
    _crate addBackpackCargoGlobal [selectRandom _backpacks, 1];
};

// --- Navigation gear: 30% NVG, 30% binoculars --------------------------
if (random 1 < 0.30) then {
    _crate addItemCargoGlobal ["NVGoggles", 1];
};

if (random 1 < 0.30) then {
    _crate addItemCargoGlobal ["Binocular", 1];
};

// --- Utility: 20% GPS ---------------------------------------------
if (random 1 < 0.20) then {
    _crate addItemCargoGlobal ["ItemGPS", 1];
};

_crate setVariable ["RVG_renegadeLootCrate", true, true];

diag_log format [
    "=== RVG WorldGenerator: Supply crate populated at %1 ===",
    _cratePos
];

[_objects, _crate]
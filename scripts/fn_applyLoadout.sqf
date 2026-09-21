// =========================================================================
// Shared loadout applier — CUP confirmed + vanilla fallback.
// =========================================================================
// Each kit is self-contained: uniform, vest, headgear, backpack, weapon,
// ammo, medical. No shared base gear — otherwise military gear leaks into
// the bandit kit and the slot-occupied check blocks the replacement.
// =========================================================================

params ["_unit", ["_kit", "rifleman"]];

// --- 1. Clear existing gear ---
removeAllWeapons _unit;
removeAllItems _unit;
removeAllAssignedItems _unit;
removeUniform _unit;
removeVest _unit;
removeBackpack _unit;
removeHeadgear _unit;

// --- 2. Kit-specific gear + weapon ---
switch (_kit) do {

    // ---------------------------------------------------------------
    // AUTOMATIC RIFLEMAN
    // ---------------------------------------------------------------
    case "ar": {
        _unit forceAddUniform "U_B_CombatUniform_mcam";
        _unit addVest "V_PlateCarrier1_rgr";
        _unit addHeadgear "H_HelmetB";
        _unit addBackpack "CUP_B_AssaultPack_ACU";

        _unit addWeapon "arifle_MX_SW_F";
        for "_i" from 1 to 3 do { _unit addMagazine "100Rnd_65x39_caseless_mag"; };
    };

    // ---------------------------------------------------------------
    // LIGHT ANTI-TANK
    // ---------------------------------------------------------------
    case "lat": {
        _unit forceAddUniform "U_B_CombatUniform_mcam";
        _unit addVest "V_PlateCarrier1_rgr";
        _unit addHeadgear "H_HelmetB";
        _unit addBackpack "CUP_B_AssaultPack_ACU";

        _unit addWeapon "CUP_arifle_M4A1";
        for "_i" from 1 to 5 do { _unit addMagazine "CUP_30Rnd_556x45_Stanag"; };
        _unit addWeapon "launch_NLAW_F";
        _unit addSecondaryWeaponItem "NLAW_F";
    };

    // ---------------------------------------------------------------
    // MEDIC
    // ---------------------------------------------------------------
    case "medic": {
        _unit forceAddUniform "U_B_CombatUniform_mcam";
        _unit addVest "V_PlateCarrier1_rgr";
        _unit addHeadgear "H_HelmetB";
        _unit addBackpack "CUP_B_AssaultPack_ACU";

        _unit addWeapon "CUP_arifle_M4A1";
        for "_i" from 1 to 6 do { _unit addMagazine "CUP_30Rnd_556x45_Stanag"; };

        for "_i" from 1 to 2 do {
            _unit addItemToBackpack "FirstAidKit";
        };
    };

    // ---------------------------------------------------------------
    // BANDIT — casual clothes, maybe vest/cap, scrap weapon
    // ---------------------------------------------------------------
    case "bandit": {
        _unit forceAddUniform (selectRandom [
            "CUP_U_C_Citizen_01", "CUP_U_C_Citizen_02", "CUP_U_C_Citizen_03", "CUP_U_C_Citizen_04",
            "CUP_U_C_Villager_01", "CUP_U_C_Villager_02", "CUP_U_C_Villager_03", "CUP_U_C_Villager_04",
            "CUP_U_C_Woodlander_01", "CUP_U_C_Woodlander_02", "CUP_U_C_Woodlander_03", "CUP_U_C_Woodlander_04",
            "CUP_U_C_Rocker_01", "CUP_U_C_Rocker_02", "CUP_U_C_Rocker_03", "CUP_U_C_Rocker_04"
        ]);

        if (random 1 < 0.4) then {
            _unit addVest (selectRandom [
                "V_BandollierB_cbr","V_BandollierB_khk","V_BandollierB_oli",
                "V_HarnessO_brn","V_HarnessOGL_brn",
                "V_TacVest_blk","V_TacVest_camo"
            ]);
        };

        if (random 1 < 0.5) then {
            _unit addHeadgear (selectRandom [
                "H_Cap_blk","H_Cap_oli","H_Cap_tan","H_Cap_brn_SPECOPS",
                "H_Bandanna_cbr","H_Bandanna_khk","H_Bandanna_sgg","H_Bandanna_gry",
                "H_Watchcap_blk","H_Watchcap_camo","H_Watchcap_khk"
            ]);
        };

        private _weapons = [
            "CUP_hgun_M9",           // M9 Beretta — full-size, 15 rounds
            "CUP_hgun_Colt1911",     // Colt 1911 — classic, 7 rounds, heavy hitter
            "CUP_hgun_Compact",
            "sgun_HunterShotgun_01_F",
            "rhs_weap_akm",
            "rhs_weap_aks74",
            "SMG_02_F",
            "SMG_01_F"
        ];
        private _weapon = selectRandom _weapons;
        _unit addWeapon _weapon;

        private _magsByWeapon = createHashMapFromArray [
             ["CUP_hgun_M9",       "CUP_15Rnd_9x19_M9"],
            ["CUP_hgun_Colt1911", "CUP_7Rnd_45ACP_1911"],
            ["CUP_hgun_Compact",  "CUP_10Rnd_9x19_Compact"],
            ["sgun_HunterShotgun_01_F","2Rnd_12Gauge_Pellets"],
            ["rhs_weap_akm","rhs_30Rnd_762x39mm"],
            ["rhs_weap_aks74","rhs_30Rnd_545x39_AK"],
            ["SMG_02_F","30Rnd_9x21_Mag_SMG_02"],
            ["SMG_01_F","30Rnd_45ACP_Mag_SMG_01"]
        ];
        private _mag = _magsByWeapon getOrDefault [_weapon, ""];
        if (_mag != "") then {
            for "_i" from 1 to (2 + floor random 3) do {
                _unit addMagazine _mag;
            };
        };

        if (random 1 < 0.3) then {
            private _sidearm = selectRandom ["CUP_hgun_M9","CUP_hgun_Colt1911"];
            _unit addWeapon _sidearm;
            _unit addMagazine (selectRandom ["CUP_15Rnd_9x19_M9","CUP_7Rnd_45ACP_1911"]);
        };

        if (random 1 < 0.5) then {
            _unit addItem "FirstAidKit";
        };
    };

    // ---------------------------------------------------------------
    // DEFAULT (rifleman / player)
    // ---------------------------------------------------------------
    default {
        _unit forceAddUniform "U_B_CombatUniform_mcam";
        _unit addVest "V_PlateCarrier1_rgr";
        _unit addHeadgear "H_HelmetB";
        _unit addBackpack "CUP_B_AssaultPack_ACU";

        _unit addWeapon "CUP_arifle_M4A1";
        for "_i" from 1 to 6 do { _unit addMagazine "CUP_30Rnd_556x45_Stanag"; };

        _unit addItemToBackpack "FirstAidKit";
    };
};

// --- 3. Sidearm for non-bandit kits ---
if (_kit != "bandit") then {
    _unit addWeapon "CUP_hgun_M9";
    _unit addMagazine "CUP_15Rnd_9x19_M9";
    _unit addMagazine "CUP_15Rnd_9x19_M9";
};

// --- 4. Linked items ---
_unit linkItem "ItemMap";
_unit linkItem "ItemCompass";
_unit linkItem "ItemWatch";
_unit linkItem "ItemRadio";

// --- 5. Damage sanity ---
_unit allowDamage true;

nil
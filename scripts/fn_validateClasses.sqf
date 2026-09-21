// =========================================================================
// RVG Classname Validator
// =========================================================================
// Runs once at mission start on the server. Checks every classname the
// mission references against the loaded configs. Missing ones get logged
// to RPT + shown in systemChat so errors surface immediately.
//
// Not gameplay-critical. Delete the call from initServer.sqf to disable.
// =========================================================================

private _fnc_classExists = {
    params ["_class"];
    private _found = false;
    {
        if (isClass (configFile >> _x >> _class)) exitWith { _found = true; };
    } forEach ["CfgWeapons", "CfgMagazines", "CfgVehicles", "CfgGlasses", "CfgAmmo"];
    _found
};

private _checkGroups = [

    ["UNIFORMS", [
		"U_B_CombatUniform_mcam",
		"CUP_U_C_Citizen_01","CUP_U_C_Citizen_02","CUP_U_C_Citizen_03","CUP_U_C_Citizen_04",
		"CUP_U_C_Villager_01","CUP_U_C_Villager_02","CUP_U_C_Villager_03","CUP_U_C_Villager_04",
		"CUP_U_C_Woodlander_01","CUP_U_C_Woodlander_02","CUP_U_C_Woodlander_03","CUP_U_C_Woodlander_04",
		"CUP_U_C_Rocker_01","CUP_U_C_Rocker_02","CUP_U_C_Rocker_03","CUP_U_C_Rocker_04",
		"U_C_Poloshirt_blue","U_C_Poloshirt_burgundy","U_C_Poloshirt_salmon","U_C_Poloshirt_stripped",
		"U_C_Man_casual_1_F","U_C_Man_casual_2_F",
		"U_B_CombatUniform_mcam_vest","U_B_CombatUniform_mcam_tshirt","U_B_CombatUniform_mcam_worn"
	]],

    ["VESTS", [
        "V_PlateCarrier1_rgr","V_PlateCarrier2_rgr","V_PlateCarrierGL_rgr","V_PlateCarrierSpec_rgr",
        "V_BandollierB_cbr","V_BandollierB_khk","V_BandollierB_oli",
        "V_HarnessO_brn","V_HarnessOGL_brn","V_TacVest_blk","V_TacVest_camo"
    ]],

    ["HEADGEAR", [
        "H_HelmetB","H_HelmetB_paint","H_HelmetB_plain_mcamo","H_HelmetB_grass","H_HelmetB_sand","H_HelmetB_desert",
        "H_Cap_blk","H_Cap_oli","H_Cap_tan","H_Cap_brn_SPECOPS",
        "H_Bandanna_cbr","H_Bandanna_khk","H_Bandanna_sgg","H_Bandanna_gry",
        "H_Watchcap_blk","H_Watchcap_camo","H_Watchcap_khk"
    ]],

    ["BACKPACKS", [
        "CUP_B_AssaultPack_ACU",
        "B_AssaultPack_rgr","B_AssaultPack_khk","B_AssaultPack_cbr","B_Kitbag_rgr","B_Carryall_oli"
    ]],

    ["WEAPONS", [
        "arifle_MX_SW_F","CUP_arifle_M4A1","launch_NLAW_F","CUP_hgun_M9",
        "hgun_ACPC2_F","hgun_Rook40_F","hgun_P07_F","sgun_HunterShotgun_01_F",
        "rhs_weap_akm","rhs_weap_aks74","SMG_02_F","SMG_01_F",
        "arifle_MX_F","arifle_MXC_F",
        "arifle_AKM_F","arifle_AKS_F","arifle_Mk20_F","arifle_Mk20C_F",
        "arifle_TRG20_F","arifle_TRG21_F","arifle_Katiba_F","arifle_Katiba_C_F","CUP_arifle_AK74"
    ]],

    ["MAGAZINES", [
        "100Rnd_65x39_caseless_mag","CUP_30Rnd_556x45_Stanag","NLAW_F","CUP_15Rnd_9x19_M9",
        "9Rnd_45ACP_Mag","16Rnd_9x21_Mag","2Rnd_12Gauge_Pellets",
        "rhs_30Rnd_762x39mm","rhs_30Rnd_545x39_AK","30Rnd_9x21_Mag_SMG_02","30Rnd_45ACP_Mag_SMG_01",
        "30Rnd_65x39_caseless_mag","30Rnd_9x21_Mag","30Rnd_762x39_Mag_F","30Rnd_545x39_Mag_F",
        "30Rnd_556x45_Stanag","30Rnd_65x39_caseless_green",
        "6Rnd_45ACP_Cylinder",
        "HandGrenade","SmokeShell","SmokeShellGreen","SmokeShellRed","SmokeShellOrange",
        "CUP_30Rnd_545x39_AK_M"
    ]],

    ["ITEMS", [
        "FirstAidKit","Medikit","ACE_earplugs",
        "ItemMap","ItemCompass","ItemWatch","ItemRadio","ItemGPS","NVGoggles","Binocular"
    ]],

    ["ATTACHMENTS", [
        "optic_Holosight","optic_MRCO","optic_Hamr","optic_ACO_grn","optic_Aco_smg",
        "muzzle_snds_M","muzzle_snds_65_TI_blk_F","muzzle_snds_H",
        "acc_pointer_IR","acc_flashlight"
    ]],

    ["UNITS", [
        "B_medic_F","B_Soldier_AR_F","B_Soldier_LAT_F","B_Soldier_F",
        "O_Soldier_F","O_Soldier_lite_F","O_Soldier_SL_F","O_Soldier_TL_F","O_Soldier_AR_F",
        "O_Soldier_GL_F","O_Soldier_LAT_F","O_Soldier_M_F","O_medic_F","O_Soldier_exp_F",
        "O_G_Soldier_F"
    ]],

    ["VEHICLES", [
        "RHS_CH_47F_cargo",
        "B_Heli_Light_01_F",
        "B_CargoNet_01_ammo_F"
    ]],

    ["STATIC OBJECTS", [
        "Land_HBarrier_5_F","Land_Cargo_Patrol_V1_F",
        "Land_TentA_F","Land_TentDome_F","Land_BagBunker_Small_F",
        "Box_IND_Wps_F","Box_IND_Ammo_F","Box_IND_WpsSpecial_F",
        "Land_Campfire_F","Land_PortableLight_double_F",
        "Land_CncBarrier_F","Land_BagFence_Long_F","Box_NATO_Equip_F",
        "Land_WoodenBox_F","Land_CanisterFuel_F","Land_CampingChair_V1_F",
        "Land_SatellitePhone_F","Land_WaterBottle_01_pack_F",
        "Box_NATO_WpsSpecial_F"
    ]]
];

private _allMissing = [];

{
    _x params ["_groupName", "_classes"];
    private _missing = _classes select { !([_x] call _fnc_classExists) };

    if (count _missing > 0) then {
        diag_log format ["=== RVG VALIDATION: %1 — %2 missing ===", _groupName, count _missing];
        {
            diag_log format ["    MISSING: %1", _x];
            _allMissing pushBack _x;
        } forEach _missing;
    } else {
        diag_log format ["=== RVG VALIDATION: %1 — all %2 OK ===", _groupName, count _classes];
    };
} forEach _checkGroups;

if (count _allMissing > 0) then {
    diag_log "";
    diag_log "=================================================";
    diag_log format ["=== RVG VALIDATION: %1 classnames MISSING ===", count _allMissing];
    diag_log "=================================================";
    diag_log "";

    ["RVG VALIDATION: " + str (count _allMissing) + " classname(s) missing — check RPT"] remoteExec ["systemChat", 0];
} else {
    diag_log "=== RVG VALIDATION: All classnames OK ===";
};
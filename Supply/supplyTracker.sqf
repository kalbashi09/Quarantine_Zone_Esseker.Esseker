// =====================================================
// RVG SUPPLY TRACKER
// Populates the physical BaseArsenal containers
// =====================================================

waitUntil {
    !isNull BaseArsenalWeapons &&
    !isNull BaseArsenalEquipments &&
    !isNull BaseArsenalEssentials &&
    !isNull BaseArsenalAttachments &&
    !isNull BaseArsenalStorage
};

diag_log "=== RVG SUPPLY: Arsenal containers found ===";


// =====================================================
// CLEAR STANDARD ARSENAL CONTAINERS
// =====================================================

{
    clearWeaponCargoGlobal _x;
    clearMagazineCargoGlobal _x;
    clearItemCargoGlobal _x;
    clearBackpackCargoGlobal _x;
} forEach [
    BaseArsenalWeapons,
    BaseArsenalEquipments,
    BaseArsenalEssentials,
    BaseArsenalAttachments
];


// =====================================================
// CLEAR PERSISTENT STORAGE
//
// BaseArsenalStorage is intentionally NOT populated
// with default supplies.
//
// Anything placed here during gameplay is player storage
// and is handled exclusively by SaveState.
// =====================================================

clearWeaponCargoGlobal BaseArsenalStorage;
clearMagazineCargoGlobal BaseArsenalStorage;
clearItemCargoGlobal BaseArsenalStorage;
clearBackpackCargoGlobal BaseArsenalStorage;

diag_log "=== RVG SUPPLY: BaseArsenalStorage cleared ===";


// =====================================================
// WEAPONS
// =====================================================

{
    BaseArsenalWeapons addWeaponCargoGlobal [_x, 10];
} forEach RVG_SupplyWeapons;


// =====================================================
// EQUIPMENT
// =====================================================

// Uniforms
{
    BaseArsenalEquipments addItemCargoGlobal [_x, 10];
} forEach [
    "U_B_CombatUniform_mcam",
    "U_B_CombatUniform_mcam_vest",
    "U_B_CombatUniform_mcam_tshirt",
    "U_B_CombatUniform_mcam_worn"
];

// Vests
{
    BaseArsenalEquipments addItemCargoGlobal [_x, 10];
} forEach [
    "V_PlateCarrier1_rgr",
    "V_PlateCarrier2_rgr",
    "V_PlateCarrierGL_rgr",
    "V_PlateCarrierSpec_rgr"
];

// Headgear
{
    BaseArsenalEquipments addItemCargoGlobal [_x, 10];
} forEach [
    "H_HelmetB",
    "H_HelmetB_paint",
    "H_HelmetB_plain_mcamo",
    "H_HelmetB_grass",
    "H_HelmetB_sand",
    "H_HelmetB_desert"
];

// Backpacks
{
    BaseArsenalEquipments addBackpackCargoGlobal [_x, 10];
} forEach [
    "B_AssaultPack_rgr",
    "B_AssaultPack_khk",
    "B_AssaultPack_cbr",
    "B_Kitbag_rgr",
    "B_Carryall_oli"
];


// =====================================================
// ESSENTIALS
// =====================================================

// Medical
{
    BaseArsenalEssentials addItemCargoGlobal [_x, 40];
} forEach RVG_SupplyItems;

// Maps / tools / navigation
{
    BaseArsenalEssentials addItemCargoGlobal [_x, 15];
} forEach [
    "ItemMap",
    "ItemCompass",
    "ItemWatch",
    "ItemRadio",
    "ItemGPS",
    "NVGoggles",
    "Binocular"
];

// Magazines
{
    BaseArsenalEssentials addMagazineCargoGlobal [_x, 100];
} forEach RVG_SupplyMagazines;

// Grenades
{
    BaseArsenalEssentials addMagazineCargoGlobal [_x, 30];
} forEach RVG_SupplyGrenades;


// =====================================================
// ATTACHMENTS
// =====================================================

{
    BaseArsenalAttachments addItemCargoGlobal [_x, 15];
} forEach RVG_SupplyAttachments;


// =====================================================
// ENABLE NORMAL CARGO INTERACTION
// =====================================================

{
    _x allowDamage false;
    _x enableSimulationGlobal true;

    // Make sure the container is not locked
    _x setVehicleLock "UNLOCKED";

} forEach [
    BaseArsenalWeapons,
    BaseArsenalEquipments,
    BaseArsenalEssentials,
    BaseArsenalAttachments,
    BaseArsenalStorage
];


diag_log "=== RVG SUPPLY: Arsenal storage populated ===";
diag_log "=== RVG SUPPLY: BaseArsenalStorage ready for persistent player storage ===";
diag_log "=== RVG SUPPLY: Cargo interaction enabled ===";
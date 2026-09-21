// =====================================================
// RVG EVENT - SUPPLY DROP
// RHS CH-47 Chinook delivers a physical cargo net
// =====================================================

diag_log "=== RVG EVENT: Supply drop starting ===";

// =====================================================
// SCAN MAP LOCATIONS
// =====================================================

private _locations = nearestLocations [
    [worldSize / 2, worldSize / 2],
    [
        "NameCityCapital",
        "NameCity",
        "NameVillage"
    ],
    worldSize
];

if (_locations isEqualTo []) exitWith {
    diag_log "=== RVG EVENT: ERROR - No map locations found ===";
};

// =====================================================
// CONVERT LOCATIONS TO POSITION DATA
// =====================================================

// Blacklisted locations — excluded from event spawn selection.
private _blacklist = [
    "Gromada",
    "Lower Esseker"
];

private _locationData = [];

{
    private _locationName = text _x;
    private _locationPos = locationPosition _x;

    if (
        !(_locationName isEqualTo "") &&
        !(_locationPos isEqualTo [0,0,0]) &&
        { !(_locationName in _blacklist) }
    ) then {

        _locationData pushBack [
            _locationName,
            _locationPos
        ];
    };

} forEach _locations;

if (_locationData isEqualTo []) exitWith {
    diag_log "=== RVG EVENT: ERROR - Location scanner returned nothing ===";
};

diag_log format [
    "=== RVG EVENT: Event scanner found %1 locations ===",
    count _locationData
];

// =====================================================
// SELECT RANDOM LOCATION
// =====================================================

private _location = selectRandom _locationData;

private _locationName = _location select 0;
private _locationPos  = _location select 1;

diag_log format [
    "=== RVG EVENT: Selected location %1 at %2 ===",
    _locationName,
    _locationPos
];

// =====================================================
// RANDOMIZE DROP POSITION
// 100–250m around selected location
// =====================================================

private _dropRadius =
    100 + random 150;

private _dropDirection =
    random 360;

private _dropPos = [
    (_locationPos select 0) +
        (sin _dropDirection * _dropRadius),

    (_locationPos select 1) +
        (cos _dropDirection * _dropRadius),

    0
];

// =====================================================
// RANDOMIZE HELICOPTER SPAWN POSITION
// 700–1000m from drop location
// =====================================================

private _spawnRadius =
    700 + random 300;

private _spawnDirection =
    _dropDirection + 180;

private _spawnPos = [
    (_dropPos select 0) +
        (sin _spawnDirection * _spawnRadius),

    (_dropPos select 1) +
        (cos _spawnDirection * _spawnRadius),

    150
];

// Keep helicopter inside map

_spawnPos set [
    0,
    (_spawnPos select 0) max 500 min (worldSize - 500)
];

_spawnPos set [
    1,
    (_spawnPos select 1) max 500 min (worldSize - 500)
];

// =====================================================
// CREATE RHS CHINOOK HELICOPTER
// =====================================================

private _heli = createVehicle ["RHS_CH_47F_cargo", _spawnPos, [], 0, "FLY"];

_heli setDir _spawnDirection;
_heli setPosATL _spawnPos;
_heli allowDamage true;

// =====================================================
// CREATE HELICOPTER CREW
// =====================================================

private _group = createVehicleCrew _heli;

{
    _x setSkill 0.7;
} forEach units _group;

// =====================================================
// CREATE PHYSICAL CARGO NET
// =====================================================

private _cargo = createVehicle [
    "B_CargoNet_01_ammo_F",
    [0,0,0],
    [],
    0,
    "NONE"
];

if (isNull _cargo) exitWith {

    diag_log "=== RVG EVENT: ERROR - Cargo net could not be created ===";

    if (!isNull _heli) then {
        deleteVehicle _heli;
    };

    {
        if (!isNull _x) then {
            deleteVehicle _x;
        };
    } forEach units _group;
};

// =====================================================
// CLEAR CARGO
// =====================================================

clearWeaponCargoGlobal _cargo;
clearMagazineCargoGlobal _cargo;
clearItemCargoGlobal _cargo;
clearBackpackCargoGlobal _cargo;

// =====================================================
// ADD SUPPLIES — RANDOMIZED
// =====================================================
// Two layers of randomization:
//   1. Which items from each pool are included (subset pick)
//   2. How many of each item (count roll)
// Medical is always present so a drop is never useless.
// =====================================================

// Helper: pick N unique random entries from a pool.
private _fnc_pickRandom = {
    params ["_pool", "_count"];
    private _copy = +_pool;
    private _picked = [];
    for "_i" from 1 to _count do {
        if (_copy isEqualTo []) exitWith {};
        private _idx = floor random (count _copy);
        _picked pushBack (_copy select _idx);
        _copy deleteAt _idx;
    };
    _picked
};

// ---- ALWAYS PRESENT: medical basics --------------------------------
// Guarantees the drop is never a waste of a trip.
_cargo addItemCargoGlobal ["FirstAidKit",  5 + floor random 6];       // 5-10
_cargo addItemCargoGlobal ["ACE_fieldDressing",  8 + floor random 8]; // 8-15
_cargo addItemCargoGlobal ["ACE_packingBandage", 5 + floor random 6]; // 5-10
_cargo addItemCargoGlobal ["ACE_morphine", 3 + floor random 3];       // 3-5

// ---- ALWAYS PRESENT: 1-2 mags of each type -------------------------
{
    _cargo addMagazineCargoGlobal [_x, 6 + floor random 10];  // 6-15 each
} forEach RVG_SupplyMagazines;

// ---- RANDOM: extra medical supplies --------------------------------
private _medicalExtras = [
    "Medikit",
    "ACE_elasticBandage",
    "ACE_quikclot",
    "ACE_epinephrine",
    "ACE_adenosine",
    "ACE_tourniquet",
    "ACE_splint",
    "ACE_salineIV_500",
    "ACE_salineIV",
    "ACE_bloodIV_500"
];

private _pickedMeds = [_medicalExtras, 2 + floor random 3] call _fnc_pickRandom;  // 2-4 items
{
    _cargo addItemCargoGlobal [_x, 2 + floor random 4];  // 2-5 of each
} forEach _pickedMeds;

// ---- RANDOM: weapons (2-4 of 5) ------------------------------------
private _pickedWeapons = [RVG_SupplyWeapons, 2 + floor random 3] call _fnc_pickRandom;
{
    _cargo addWeaponCargoGlobal [_x, 1 + floor random 2];  // 1-2 of each
} forEach _pickedWeapons;

// ---- RANDOM: attachments (3-6 of 8) --------------------------------
private _pickedAtts = [RVG_SupplyAttachments, 3 + floor random 4] call _fnc_pickRandom;
{
    _cargo addItemCargoGlobal [_x, 1 + floor random 3];  // 1-3 of each
} forEach _pickedAtts;

// ---- RANDOM: grenades (2-4 types, random counts) -------------------
private _pickedGrenades = [RVG_SupplyGrenades, 2 + floor random 3] call _fnc_pickRandom;
{
    _cargo addMagazineCargoGlobal [_x, 2 + floor random 5];  // 2-6 of each
} forEach _pickedGrenades;

// ---- RANDOM: one special item (50% chance) -------------------------
if (random 1 < 0.5) then {
    private _specials = [
        "ACE_surgicalKit",
        "ACE_personalAidKit",
        "ACE_bodyBag",
        "ToolKit",
        "MineDetector",
        "NVGoggles",
        "Binocular"
    ];
    _cargo addItemCargoGlobal [selectRandom _specials, 1];
};

// =====================================================
// ATTACH CARGO TO HELICOPTER
// =====================================================

_cargo attachTo [
    _heli,
    [0, 0, -8]
];

diag_log "=== RVG EVENT: Cargo attached to helicopter ===";

// =====================================================
// APPROACH DROP ZONE
// =====================================================

private _wpApproach = _group addWaypoint [
    _dropPos,
    0
];

_wpApproach setWaypointType "MOVE";
_wpApproach setWaypointBehaviour "CARELESS";
_wpApproach setWaypointCombatMode "BLUE";
_wpApproach setWaypointSpeed "FULL";
_wpApproach setWaypointCompletionRadius 80;

// =====================================================
// DROP CARGO
// =====================================================

[
    _heli,
    _cargo,
    _dropPos
] spawn {

    params [
        "_heli",
        "_cargo",
        "_dropPos"
    ];

    waitUntil {
        sleep 2;

        isNull _heli ||
        (_heli distance2D _dropPos) < 100
    };

    if (
        isNull _heli ||
        isNull _cargo
    ) exitWith {
        diag_log "=== RVG EVENT: Cargo drop aborted ===";
    };

    // Detach cargo
    detach _cargo;

    // Place cargo on ground
    _cargo setPosATL [
        _dropPos select 0,
        _dropPos select 1,
        0
    ];

    _cargo setDir (random 360);

    diag_log format [
        "=== RVG EVENT: SUPPLY CARGO DROPPED at %1 ===",
        _dropPos
    ];
};

// =====================================================
// DEPARTURE POSITION
// =====================================================

private _departureDirection =
    _dropDirection + 180;

private _departureDistance =
    1200;

private _departurePos = [
    (_dropPos select 0) +
        (sin _departureDirection * _departureDistance),

    (_dropPos select 1) +
        (cos _departureDirection * _departureDistance),

    150
];

_departurePos set [
    0,
    (_departurePos select 0) max 500 min (worldSize - 500)
];

_departurePos set [
    1,
    (_departurePos select 1) max 500 min (worldSize - 500)
];

// =====================================================
// DEPARTURE WAYPOINT
// =====================================================

private _wpDeparture = _group addWaypoint [
    _departurePos,
    0
];

_wpDeparture setWaypointType "MOVE";
_wpDeparture setWaypointBehaviour "CARELESS";
_wpDeparture setWaypointCombatMode "BLUE";
_wpDeparture setWaypointSpeed "FULL";
_wpDeparture setWaypointCompletionRadius 150;

// =====================================================
// CREATE DROP MARKER
// =====================================================

private _markerName = format [
    "RVG_SupplyDrop_%1",
    diag_tickTime
];

private _marker = createMarker [
    _markerName,
    _dropPos
];

_marker setMarkerType "mil_box";
_marker setMarkerColor "ColorGreen";
_marker setMarkerText format [
    "Supply Drop - %1",
    _locationName
];

// =====================================================
// CLEANUP HELICOPTER AFTER 10 MINUTES
// =====================================================

[
    _heli,
    _group,
    _markerName
] spawn {

    params [
        "_heli",
        "_group",
        "_markerName"
    ];

    sleep 600;

    if (!isNull _heli) then {
        deleteVehicle _heli;
    };

    {
        if (!isNull _x) then {
            deleteVehicle _x;
        };
    } forEach units _group;

    deleteMarker _markerName;

    diag_log "=== RVG EVENT: Supply helicopter expired ===";
};

// =====================================================
// CLEANUP CARGO AFTER 30 MINUTES
// =====================================================

[
    _cargo
] spawn {

    params [
        "_cargo"
    ];

    sleep 1800;

    if (!isNull _cargo) then {
        deleteVehicle _cargo;
    };

    diag_log "=== RVG EVENT: Supply cargo expired ===";
};

// =====================================================
// DEBUG
// =====================================================

diag_log format [
    "=== RVG EVENT: Supply drop created near %1 ===",
    _locationName
];

diag_log format [
    "=== RVG EVENT: Drop position %1 ===",
    _dropPos
];

diag_log format [
    "=== RVG EVENT: Drop is %1m from location ===",
    round (_dropPos distance2D _locationPos)
];

diag_log format [
    "=== RVG EVENT: Helicopter spawned %1m from drop ===",
    round (_spawnPos distance2D _dropPos)
];
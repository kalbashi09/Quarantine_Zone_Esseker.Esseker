// =====================================================
// RVG EVENT - SUPPLY DROP
// CH-67 Huron delivers a physical cargo net
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

private _locationData = [];

{
    private _locationName = text _x;
    private _locationPos = locationPosition _x;

    if (
        !(_locationName isEqualTo "") &&
        !(_locationPos isEqualTo [0,0,0])
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
// CREATE CH-67 HURON
// =====================================================

private _heli = createVehicle [
    "B_Heli_Transport_03_F",
    _spawnPos,
    [],
    0,
    "FLY"
];

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
// ADD SUPPLIES
// =====================================================

{
    _cargo addWeaponCargoGlobal [_x, 2];
} forEach RVG_SupplyWeapons;

{
    _cargo addMagazineCargoGlobal [_x, 20];
} forEach RVG_SupplyMagazines;

{
    _cargo addItemCargoGlobal [_x, 10];
} forEach RVG_SupplyItems;

{
    _cargo addItemCargoGlobal [_x, 5];
} forEach RVG_SupplyAttachments;

{
    _cargo addMagazineCargoGlobal [_x, 10];
} forEach RVG_SupplyGrenades;

// =====================================================
// ATTACH CARGO TO HELICOPTER
// =====================================================

_cargo attachTo [
    _heli,
    [0, 0, -7]
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
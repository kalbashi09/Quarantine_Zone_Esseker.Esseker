// =========================================================================
// RVG Cache Mission
//
// Find the hidden cache.
// Search the cache.
// Cache disappears.
// Survivor camp remains until the cache is searched.
// A large loot bag containing randomized supplies appears.
// Mission completes immediately.
// =========================================================================

params [
    "_slot",
    "_locationName",
    "_locationPos"
];


// =========================================================================
// Create mission marker
// =========================================================================

private _markerName =
    format ["RVG_Cache_%1", _slot];

private _marker = createMarker [
    _markerName,
    _locationPos
];

_marker setMarkerType "mil_dot";

_marker setMarkerText format [
    "CACHE: %1",
    _locationName
];

_marker setMarkerColor "ColorOrange";


// =========================================================================
// Find hidden cache position
// =========================================================================

private _cachePos =
    [
        _locationPos,
        75,
        250,
        5,
        0,
        0.5,
        0
    ] call BIS_fnc_findSafePos;

if (_cachePos isEqualTo []) then {
    _cachePos = _locationPos;
};


// =========================================================================
// Spawn cache
// =========================================================================

private _cache = createVehicle [
    "Box_NATO_Equip_F",
    _cachePos,
    [],
    0,
    "NONE"
];

_cache setVariable [
    "RVG_cacheMission",
    _slot,
    true
];

_cache setVariable [
    "RVG_cacheSearched",
    false,
    true
];


// =========================================================================
// Empty cache inventory
// =========================================================================

clearWeaponCargoGlobal _cache;
clearMagazineCargoGlobal _cache;
clearItemCargoGlobal _cache;
clearBackpackCargoGlobal _cache;


// =========================================================================
// Add small supplies to cache
// =========================================================================

_cache addItemCargoGlobal [
    "FirstAidKit",
    2 + floor random 4
];

_cache addMagazineCargoGlobal [
    "30Rnd_65x39_caseless_mag",
    2 + floor random 5
];

_cache addMagazineCargoGlobal [
    "16Rnd_9x21_Mag",
    2 + floor random 3
];


// =========================================================================
// Survivor Camp
// =========================================================================

private _campObjects = [];


// -------------------------------------------------------------------------
// Campfire
// -------------------------------------------------------------------------

private _campfirePos = [
    (_cachePos select 0) + 4,
    (_cachePos select 1) + 2,
    0
];

private _campfire = createVehicle [
    "Land_Campfire_F",
    _campfirePos,
    [],
    0,
    "NONE"
];

_campfire inflame true;

_campObjects pushBack _campfire;


// -------------------------------------------------------------------------
// Tent
// -------------------------------------------------------------------------

private _tentPos = [
    (_cachePos select 0) - 4,
    (_cachePos select 1) + 3,
    0
];

private _tent = createVehicle [
    "Land_TentA_F",
    _tentPos,
    [],
    0,
    "NONE"
];

_tent setDir (random 360);

_campObjects pushBack _tent;


// -------------------------------------------------------------------------
// Camping chairs
// -------------------------------------------------------------------------

private _chair1 = createVehicle [
    "Land_CampingChair_V1_F",
    [
        (_cachePos select 0) + 3,
        (_cachePos select 1) - 3,
        0
    ],
    [],
    0,
    "NONE"
];

_chair1 setDir (random 360);

_campObjects pushBack _chair1;


private _chair2 = createVehicle [
    "Land_CampingChair_V1_F",
    [
        (_cachePos select 0) - 2,
        (_cachePos select 1) - 4,
        0
    ],
    [],
    0,
    "NONE"
];

_chair2 setDir (random 360);

_campObjects pushBack _chair2;


private _chair3 = createVehicle [
    "Land_CampingChair_V1_F",
    [
        (_cachePos select 0) + 5,
        (_cachePos select 1) + 1,
        0
    ],
    [],
    0,
    "NONE"
];

_chair3 setDir (random 360);

_campObjects pushBack _chair3;


// -------------------------------------------------------------------------
// Small equipment crate
// -------------------------------------------------------------------------

private _campCrate = createVehicle [
    "Box_NATO_Equip_F",
    [
        (_cachePos select 0) + 5,
        (_cachePos select 1) + 4,
        0
    ],
    [],
    0,
    "NONE"
];

clearWeaponCargoGlobal _campCrate;
clearMagazineCargoGlobal _campCrate;
clearItemCargoGlobal _campCrate;
clearBackpackCargoGlobal _campCrate;

_campCrate addItemCargoGlobal [
    "FirstAidKit",
    1 + floor random 3
];

_campObjects pushBack _campCrate;


// -------------------------------------------------------------------------
// Water container
// -------------------------------------------------------------------------

private _water = createVehicle [
    "Land_WaterBottle_01_pack_F",
    [
        (_cachePos select 0) - 3,
        (_cachePos select 1) - 2,
        0
    ],
    [],
    0,
    "NONE"
];

_campObjects pushBack _water;


// =========================================================================
// Search action
// =========================================================================

_cache addAction [
    "Search Cache",
    {
        params [
            "_target",
            "_caller",
            "_actionId"
        ];

        // Prevent multiple people from searching it
        if (
            _target getVariable [
                "RVG_cacheSearched",
                false
            ]
        ) exitWith {};

        _target setVariable [
            "RVG_cacheSearched",
            true,
            true
        ];

        _target removeAction _actionId;

        [
            "CACHE FOUND! Recovering supplies..."
        ] remoteExec [
            "systemChat",
            0
        ];

        // Tell mission script that cache was found
        _target setVariable [
            "RVG_cacheFound",
            true,
            true
        ];
    },
    nil,
    1.5,
    true,
    true,
    "",
    "alive _target",
    5
];


// =========================================================================
// Mission notification
// =========================================================================

[
    format [
        "CACHE MISSION: Search for a supply cache near %1.",
        _locationName
    ]
] remoteExec [
    "systemChat",
    0
];


// =========================================================================
// Wait until player finds cache
// =========================================================================

waitUntil {

    sleep 1;

    if (isNull _cache) exitWith {
        true
    };

    _cache getVariable [
        "RVG_cacheFound",
        false
    ]
};


if (isNull _cache) exitWith {
    deleteMarker _marker;
};


// =========================================================================
// Cache discovered
// =========================================================================

_marker setMarkerText "CACHE FOUND";

_marker setMarkerColor "ColorYellow";


// Small delay
sleep 2;


// =========================================================================
// CREATE LARGE LOOT BAG
//
// IMPORTANT:
// This is intentionally created BEFORE deleting the cache.
// This preserves the behavior of the old working version.
// =========================================================================

private _lootBag = createVehicle [
    "B_Carryall_oli",
    getPosATL _cache,
    [],
    0,
    "NONE"
];


// =========================================================================
// Empty bag
// =========================================================================

clearWeaponCargoGlobal _lootBag;
clearMagazineCargoGlobal _lootBag;
clearItemCargoGlobal _lootBag;
clearBackpackCargoGlobal _lootBag;


// =========================================================================
// Randomized loot
// =========================================================================

// -------------------------------------------------------------------------
// Medical supplies
// -------------------------------------------------------------------------

_lootBag addItemCargoGlobal [
    "FirstAidKit",
    3 + floor random 5
];


// -------------------------------------------------------------------------
// Rifle ammunition
// -------------------------------------------------------------------------

_lootBag addMagazineCargoGlobal [
    "30Rnd_65x39_caseless_mag",
    4 + floor random 7
];


// -------------------------------------------------------------------------
// Pistol ammunition
// -------------------------------------------------------------------------

_lootBag addMagazineCargoGlobal [
    "16Rnd_9x21_Mag",
    2 + floor random 5
];


// -------------------------------------------------------------------------
// Grenades
// -------------------------------------------------------------------------

_lootBag addMagazineCargoGlobal [
    "HandGrenade",
    1 + floor random 3
];


// -------------------------------------------------------------------------
// Smoke
// -------------------------------------------------------------------------

_lootBag addMagazineCargoGlobal [
    "SmokeShell",
    1 + floor random 4
];


// =========================================================================
// Random chance for extra weapon
// =========================================================================

if ((random 1) < 0.50) then {

    private _weapons = [
        "arifle_MX_F",
        "arifle_MXC_F",
        "arifle_MX_SW_F",
        "arifle_Mk20_F"
    ];

    _lootBag addWeaponCargoGlobal [
        selectRandom _weapons,
        1
    ];
};


// =========================================================================
// Random chance for extra medical supplies
// =========================================================================

if ((random 1) < 0.50) then {

    _lootBag addItemCargoGlobal [
        "Medikit",
        1
    ];
};


// =========================================================================
// Confirm loot bag was created
// =========================================================================

diag_log format [
    "RVG Cache: Loot bag spawned at %1",
    getPosATL _lootBag
];


// =========================================================================
// Tell players the cache was recovered
// =========================================================================

[
    format [
        "CACHE RECOVERED: Supplies found at %1!",
        _locationName
    ]
] remoteExec [
    "systemChat",
    0
];


// =========================================================================
// NOW delete original cache
// =========================================================================

deleteVehicle _cache;


// =========================================================================
// Delete survivor camp
// =========================================================================

{
    if (!isNull _x) then {
        deleteVehicle _x;
    };
} forEach _campObjects;


// =========================================================================
// Mission complete
// =========================================================================

[
    format [
        "CACHE MISSION COMPLETE: Supplies recovered from %1.",
        _locationName
    ]
] remoteExec [
    "systemChat",
    0
];


// Remove marker
deleteMarker _marker;


// =========================================================================
// Remove this mission from active mission list
// =========================================================================

private _active =
    missionNamespace getVariable [
        "RVG_activeMissions",
        []
    ];

_active =
    _active select {
        (_x select 0) != _slot
    };

missionNamespace setVariable [
    "RVG_activeMissions",
    _active,
    true
];


diag_log format [
    "RVG Cache: Slot %1 completed. Loot bag spawned and camp removed.",
    _slot + 1
];

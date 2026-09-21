// =========================================================================
// RVG Mission Generator - Main Controller
// =========================================================================

diag_log "=== RVG MISSION GENERATOR INITIALIZED ===";

if (!isServer) exitWith {
    diag_log "RVG MissionGenerator: Not server, exiting.";
};

diag_log "RVG MissionGenerator: Server confirmed.";

sleep 2;

// -------------------------------------------------------------------------
// Initialize mission variables
// -------------------------------------------------------------------------

missionNamespace setVariable ["RVG_activeMissions", [], true];
missionNamespace setVariable ["RVG_usedMissionLocations", []];

private _locations = [1000] call RVG_fnc_scanLocations;

diag_log format [
    "RVG MissionGenerator: Scanner returned %1 locations.",
    count _locations
];

if (_locations isEqualTo []) exitWith {
    diag_log "RVG MissionGenerator: ERROR - No usable locations found.";
};

missionNamespace setVariable [
    "RVG_missionLocations",
    _locations
];

diag_log "RVG MissionGenerator: Location pool ready.";

private _batchNumber = 0;

// =========================================================================
// Main mission loop
// =========================================================================

while {true} do {

    _batchNumber = _batchNumber + 1;

    diag_log format [
        "================================================="
    ];

    diag_log format [
        "RVG MissionGenerator: GENERATING MISSION BATCH #%1",
        _batchNumber
    ];

    diag_log format [
        "================================================="
    ];

    // ---------------------------------------------------------------------
    // Generate 3 random missions
    // ---------------------------------------------------------------------

    for "_slot" from 0 to 2 do {

        diag_log format [
            "RVG MissionGenerator: Generating slot %1",
            _slot + 1
        ];

        [_locations, _slot] call RVG_fnc_generateMission;

        sleep 1;
    };

    diag_log format [
        "RVG MissionGenerator: Batch #%1 has 3 active missions.",
        _batchNumber
    ];

    // ---------------------------------------------------------------------
    // Wait until all 3 missions are completed
    // ---------------------------------------------------------------------

    waitUntil {

        sleep 2;

        private _active =
            missionNamespace getVariable [
                "RVG_activeMissions",
                []
            ];

        count _active == 0
    };

    diag_log format [
        "RVG MissionGenerator: Batch #%1 completed.",
        _batchNumber
    ];

    // Small delay before next batch
    sleep 5;
};
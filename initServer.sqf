
// =====================================================
// RVG LIMITED ARSENAL
// =====================================================
enableSaving [false, false];

diag_log "=== RVG ARSENAL: Loading configuration ===";

call compile preprocessFileLineNumbers "Supply\supply.sqf";

diag_log "=== RVG SUPPLY: Configuration loaded ===";

[] execVM "Supply\supplyTracker.sqf";

diag_log "=== RVG SUPPLY: Tracker started ===";

// =====================================================
// EVENT GENERATOR
// =====================================================

[] execVM "EventGenerator\fn_init.sqf";

diag_log "=== RVG EVENTS: Generator started ===";

// =========================================================================
// Server-side orphaned-group cleanup.
// =========================================================================
// If a player disconnects, their UID stops appearing in allPlayers. The
// next tick deletes any group whose RVG_ownerUID no longer matches a live
// player and contains no player.
// =========================================================================

[] spawn RVG_fnc_validateClasses;

[] spawn {
    while { true } do {
        sleep 30;

        private _liveUIDs = (allPlayers - entities "HeadlessClient_F") apply { getPlayerUID _x };

        {
            private _g   = _x;
            private _uid = _g getVariable ["RVG_ownerUID", ""];

            if (_uid != "") then {
                if (_uid in _liveUIDs) then { continue };
                if ((units _g) findIf { isPlayer _x } >= 0) then { continue };

                {
                    if (!isNull _x) then { deleteVehicle _x; };
                } forEach (units _g);

                deleteGroup _g;
            };
        } forEach allGroups;
    };
};

// After MissionHQ is set and RVG_missionLocations is populated.
[] spawn RVG_fnc_worldInit;

// =========================================================================
// Mission Generator
// =========================================================================

diag_log "RVG: Starting Mission Generator...";

if (isNil "RVG_fnc_missionInit") then {
    diag_log "RVG ERROR: RVG_fnc_missionInit DOES NOT EXIST!";
} else {
    diag_log "RVG: RVG_fnc_missionInit exists. Starting generator.";
    [] spawn RVG_fnc_missionInit;
};

// =========================================================================
// Save State
// =========================================================================

diag_log "RVG: Starting SaveState...";

if (isNil "RVG_fnc_saveInit") then {
    diag_log "RVG ERROR: RVG_fnc_saveInit DOES NOT EXIST!";
} else {
    diag_log "RVG: RVG_fnc_saveInit exists. Starting SaveState.";
    [] spawn RVG_fnc_saveInit;
};
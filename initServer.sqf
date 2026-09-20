
// =====================================================
// RVG LIMITED ARSENAL
// =====================================================

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
// Mission Generator TEST
// =========================================================================

diag_log "RVG TEST: initServer reached Mission Generator section.";

if (isNil "RVG_fnc_init") then {
    diag_log "RVG TEST ERROR: RVG_fnc_init DOES NOT EXIST!";
} else {
    diag_log "RVG TEST: RVG_fnc_init exists. Starting generator.";
    [] spawn RVG_fnc_init;
};
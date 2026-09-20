// =========================================================================
// RVG WorldGenerator — Renegade base controller
// =========================================================================
// Timeline:
//   - 10 min after server start: pick location, build base, spawn garrison.
//   - Every 20-30 min: 40% chance to dispatch a 5-man roamer squad.
//   - When garrison is wiped: clean up base, wait 25 min, spawn another.
//
// No marker, no BIS task. Only systemChat messages announce base spawn
// and clear.
// =========================================================================

if (!isServer) exitWith {};

diag_log "=== RVG WorldGenerator: Initialized ===";

RVG_renegadeBaseActive   = false;
RVG_renegadeBasePos      = [0, 0, 0];
RVG_renegadeBaseObjects  = [];
RVG_renegadeGarrison     = [];
RVG_renegadeLocationName = "";
RVG_renegadeLastCleared  = -99999;
RVG_renegadeCrate        = objNull;

sleep 600;

[] spawn {

    private _fnc_isAreaClear = {
        params ["_pos", "_radius"];
        private _structures = nearestTerrainObjects [_pos, ["BUILDING"], _radius];

        if (!(_structures isEqualTo [])) exitWith {
            diag_log format [
                "=== RVG WorldGenerator: Spot rejected — %1 structures within %2m ===",
                count _structures, _radius
            ];
            false
        };

        true
    };

    private _fnc_pickLocation = {
        private _locations = missionNamespace getVariable ["RVG_missionLocations", []];
        if (_locations isEqualTo []) exitWith { [] };

        private _hq     = missionNamespace getVariable ["MissionHQ", objNull];
        private _hqPos  = if (isNull _hq) then { [0,0,0] } else { getPosATL _hq };

        private _usedByMissions = missionNamespace getVariable ["RVG_usedMissionLocations", []];
        private _usedByRenegade = missionNamespace getVariable ["RVG_renegadeUsedLocations", []];

        private _candidates = _locations select {
            private _name = _x select 0;
            private _pos  = _x select 1;

            !(_name in _usedByMissions) &&
            { !(_name in _usedByRenegade) } &&
            { _pos distance2D _hqPos >= 1000 }
        };

        if (_candidates isEqualTo []) then {
            _candidates = _locations select {
                (_x select 1) distance2D _hqPos >= 1000
            };
        };

        if (_candidates isEqualTo []) exitWith { [] };

        _candidates = _candidates call BIS_fnc_arrayShuffle;

        private _result = [];

        {
            private _name   = _x select 0;
            private _locPos = _x select 1;
            private _attempts = 0;

            while { _attempts < 20 && (_result isEqualTo []) } do {
                _attempts = _attempts + 1;

                private _bearing  = random 360;
                private _distance = 200 + random 200;

                private _targetPos = [
                    (_locPos select 0) + (sin _bearing * _distance),
                    (_locPos select 1) + (cos _bearing * _distance),
                    0
                ];

                if (
                    !(surfaceIsWater _targetPos) &&
                    { [_targetPos, 40] call _fnc_isAreaClear }
                ) then {
                    _result = [_name, _targetPos];
                    diag_log format [
                        "=== RVG WorldGenerator: Clear spot %1m from %2 at %3 ===",
                        round (_targetPos distance2D _locPos),
                        _name,
                        _targetPos
                    ];
                };
            };

            if (!(_result isEqualTo [])) exitWith {};
        } forEach _candidates;

        if (_result isEqualTo []) then {
            diag_log "=== RVG WorldGenerator: No clear spot found in any candidate town ===";
        };

        _result
    };

    while { true } do {

        // ---- Spawn a base if none is active ----------------------------
        if (!RVG_renegadeBaseActive) then {
            private _cooledDown = (diag_tickTime - RVG_renegadeLastCleared) > 1500;

            if (RVG_renegadeLastCleared < 0 || _cooledDown) then {
                private _loc = call _fnc_pickLocation;

                if (!(_loc isEqualTo [])) then {

                    // Delete any previous loot crate.
                    if (!isNull RVG_renegadeCrate) then {
                        deleteVehicle RVG_renegadeCrate;
                    };
                    RVG_renegadeCrate = objNull;

                    RVG_renegadeLocationName = _loc select 0;
                    RVG_renegadeBasePos      = _loc select 1;

                    private _buildResult = [RVG_renegadeBasePos] call RVG_fnc_buildRenegadeBase;
                    RVG_renegadeBaseObjects = _buildResult select 0;
                    RVG_renegadeCrate       = _buildResult select 1;

                    RVG_renegadeGarrison = [RVG_renegadeBasePos] call RVG_fnc_spawnGarrison;

                    private _used = missionNamespace getVariable ["RVG_renegadeUsedLocations", []];
                    _used pushBack RVG_renegadeLocationName;
                    missionNamespace setVariable ["RVG_renegadeUsedLocations", _used];

                    RVG_renegadeBaseActive = true;

                    diag_log format [
                        "=== RVG WorldGenerator: Base built at %1 (%2) ===",
                        RVG_renegadeLocationName,
                        RVG_renegadeBasePos
                    ];

                    [format ["BANDIT CAMP: Hostiles reported near %1.", RVG_renegadeLocationName]]
                        remoteExec ["systemChat", 0];
                } else {
                    diag_log "=== RVG WorldGenerator: No valid base location available ===";
                };
            };
        };

        // ---- Check if garrison is wiped --------------------------------
        if (RVG_renegadeBaseActive) then {
            private _alive = 0;
            {
                _alive = _alive + ({ alive _x } count (units _x));
            } forEach RVG_renegadeGarrison;

            if (_alive == 0) then {
                RVG_renegadeBaseActive = false;
                RVG_renegadeLastCleared = diag_tickTime;

                diag_log "=== RVG WorldGenerator: Base cleared ===";

                [format ["RENEGADE CAMP CLEARED: %1 is quiet.", RVG_renegadeLocationName]]
                    remoteExec ["systemChat", 0];

                // Clean up base objects — NOT the crate.
                {
                    if (!isNull _x) then { deleteVehicle _x; };
                } forEach RVG_renegadeBaseObjects;

                {
                    if (!isNull _x) then { deleteGroup _x; };
                } forEach RVG_renegadeGarrison;

                RVG_renegadeBaseObjects = [];
                RVG_renegadeGarrison    = [];

                if (!isNull RVG_renegadeCrate && alive RVG_renegadeCrate) then {
                    [format ["SUPPLIES: Cache at %1 is open for the taking.", RVG_renegadeLocationName]]
                        remoteExec ["systemChat", 0];
                };
            };
        };

        sleep 15;
    };
};

// ---- Roamer dispatch loop ----------------------------------------------
[] spawn {
    while { true } do {
        sleep (1200 + random 600);   // 20-30 min

        if (RVG_renegadeBaseActive && { !(RVG_renegadeGarrison isEqualTo []) }) then {
            if (random 1 < 0.4) then {
                [RVG_renegadeBasePos] call RVG_fnc_spawnRoamer;
                diag_log "=== RVG WorldGenerator: Roamer dispatched ===";
            };
        };
    };
};

diag_log "=== RVG WorldGenerator: Loops started ===";
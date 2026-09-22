diag_log "=== RVG teammate system starting ===";

waitUntil { !isNull player && alive player };

sleep 0.5;

// Fresh group for this player, tagged by UID.

private _myGrp = createGroup [west, true];

[player] joinSilent _myGrp;

_myGrp selectLeader player;

_myGrp setVariable ["RVG_ownerUID", getPlayerUID player, true];

// Player loadout.

// [player, "player"] call RVG_fnc_applyLoadout;

// Initial 3-man spawn at the player.

[_myGrp, getPos player] call RVG_fnc_spawnPlayerTeammates;

// Leash + watchdog.

[_myGrp] spawn RVG_fnc_teammateLeash;

[_myGrp] spawn RVG_fnc_teammateWatchdog;

// Survival HUD — hunger, thirst, radiation bars

[] spawn RVG_fnc_survivalHUD;

// Radiation debug watcher
[] spawn {
    private _lastRad = player getVariable ["radiation", 0];

    while {true} do {
        sleep 0.5;

        private _rad = player getVariable ["radiation", 0];

        if (_rad != _lastRad) then {
            diag_log format [
                "RVG RADIATION CHANGE: %1 -> %2 | Pos: %3",
                _lastRad,
                _rad,
                getPosATL player
            ];

            _lastRad = _rad;
        };
    };
};

// =====================================================
// Persistent Save / Load — SaveHere Interaction
// =====================================================

private _addSaveLoadActions = {

    player addAction [
        "<t color='#55FF55'>Save Persistent</t>",
        {
            [player] remoteExec ["RVG_fnc_save", 2];
        },
        nil,
        1.5,
        true,
        true,
        "",
        "alive player && cursorObject isEqualTo SaveHere"
    ];

    player addAction [
        "<t color='#55AAFF'>Load Persistent</t>",
        {
            [player] remoteExec ["RVG_fnc_load", 2];
        },
        nil,
        1.4,
        true,
        true,
        "",
        "alive player && cursorObject isEqualTo SaveHere"
    ];
};

waitUntil { !isNull SaveHere };

call _addSaveLoadActions;

player addEventHandler [
    "Respawn",
    {
        [] spawn {
            waitUntil { !isNull player && alive player };
            
            // Re-add Save/Load actions to the new player
            player addAction [
                "<t color='#55FF55'>Save Persistent</t>",
                {
                    [player] remoteExec ["RVG_fnc_save", 2];
                },
                nil,
                1.5,
                true,
                true,
                "",
                "alive player && cursorObject isEqualTo SaveHere"
            ];

            player addAction [
                "<t color='#55AAFF'>Load Persistent</t>",
                {
                    [player] remoteExec ["RVG_fnc_load", 2];
                },
                nil,
                1.4,
                true,
                true,
                "",
                "alive player && cursorObject isEqualTo SaveHere"
            ];
        };
    }
];
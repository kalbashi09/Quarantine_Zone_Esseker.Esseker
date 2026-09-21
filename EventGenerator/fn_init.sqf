// =========================================================================
// RVG EVENT SCHEDULER
// =========================================================================
// Random event, random interval, forever.
// Never fires the same event twice in a row.
// =========================================================================

diag_log "=== RVG EVENTS: Scheduler starting ===";

[] spawn {
    private _events = [
        "RVG_fnc_heli",
        "RVG_fnc_supplyDrop",
        "RVG_fnc_roadblock"
    ];

    private _lastEvent = "";

    // First event: 3-8 minutes in.
    sleep (180 + random 300);

    while { true } do {
        private _pool = _events select { _x != _lastEvent };

        private _fnc = selectRandom _pool;
        _lastEvent = _fnc;

        diag_log format ["=== RVG EVENT: Triggering %1 ===", _fnc];

        [] spawn (missionNamespace getVariable _fnc);

        // Next event: 8-18 minutes later.
        sleep (480 + random 600);
    };
};

diag_log "=== RVG EVENTS: Scheduler loop started ===";
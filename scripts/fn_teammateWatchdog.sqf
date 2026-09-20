// =========================================================================
// Ravage teammate watchdog — periodic roster reconcile.
// =========================================================================
// Every 20s I re-run the idempotent spawner at the player's position. Dead
// slots come back near the player; living ones are untouched. This is the
// single source of truth — no loadout snapshots, no EntityKilled handler.
// =========================================================================

params ["_grp"];

while { true } do {
    sleep 20;

    if (isNull _grp) exitWith {};
    if (isNull player || { !alive player }) then { continue };

    [_grp, getPos player] call RVG_fnc_spawnPlayerTeammates;
};
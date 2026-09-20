// =========================================================================
// Ravage teammate leash — 200m hard teleport with soft regroup tiers.
// =========================================================================
// Tiers:
//   > 200m : hard teleport (safety net; skipped if in a vehicle)
//   >  80m : force full-speed doMove toward player
//   >  40m : doFollow re-tie
//
// Guards: skips vehicle occupants, skips COMBAT units, skips dead player.
// =========================================================================

params ["_grp"];

while { true } do {
    sleep 5;

    if (isNull _grp) exitWith {};
    if (isNull player || { !alive player }) then { continue };
    if (leader _grp != player) then { continue };

    {
        if (!isPlayer _x && { alive _x }) then {
            private _dist      = _x distance player;
            private _inVehicle = vehicle _x != _x;
            private _inCombat  = behaviour _x == "COMBAT";

            if (_dist > 200 && { !_inVehicle }) then {
                _x setPos (player getPos [8, random 360]);
                _x setDir (random 360);
                _x setVelocity [0, 0, 0];
                systemChat format ["RVG: %1 recalled to your position.", name _x];
            } else {
                if (_dist > 80 && { !_inVehicle } && { !_inCombat }) then {
                    _x setSpeedMode "FULL";
                    _x doMove (getPos player);
                } else {
                    if (_dist > 40 && { !_inVehicle } && { !_inCombat }) then {
                        _x setSpeedMode "NORMAL";
                        _x doFollow (leader _grp);
                    };
                };
            };
        };
    } forEach (units _grp);
};
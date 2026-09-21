waitUntil { !isNull player && alive player };
sleep 0.5;

// Re-home into a private group if sharing with another human.
private _grp = group player;
if ((count (units _grp select { isPlayer _x && _x != player })) > 0) then {
    _grp = createGroup [west, true];
    [player] joinSilent _grp;
    _grp selectLeader player;
};
_grp setVariable ["RVG_ownerUID", getPlayerUID player, true];
if (leader _grp != player) then { _grp selectLeader player; };

// Basic clothing only
removeAllWeapons player;
removeAllItems player;
removeAllAssignedItems player;
removeUniform player;
removeVest player;
removeBackpack player;
removeHeadgear player;

player forceAddUniform "U_B_CombatUniform_mcam";

// Immediate top-up near the new spawn point.
[_grp, getPos player] call RVG_fnc_spawnPlayerTeammates;
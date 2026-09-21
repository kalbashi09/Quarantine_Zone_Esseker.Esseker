// =========================================================================
// RVG Survival HUD
// =========================================================================
// Reads Ravage's hunger/thirst/radiation values and draws three bars.
// Values assumed 0-100. Runs on each player's machine.
// =========================================================================

disableSerialization;

private _display = uiNamespace getVariable ["RVG_SurvivalHUD", displayNull];
if (isNull _display) then {
    private _layer = ["RVG_SurvivalHUD"] call BIS_fnc_rscLayer;
    _layer cutRsc ["RVG_SurvivalHUD", "PLAIN", 0, false];
    _display = uiNamespace getVariable ["RVG_SurvivalHUD", displayNull];
};

if (isNull _display) exitWith {
    diag_log "=== RVG SurvivalHUD: could not create display ===";
};

private _hungerBar = _display displayCtrl 8002;
private _thirstBar = _display displayCtrl 8004;
private _radBar    = _display displayCtrl 8006;

diag_log "=== RVG SurvivalHUD: started ===";

while { true } do {
    sleep 1;

    if (isNull (uiNamespace getVariable ["RVG_SurvivalHUD", displayNull])) exitWith {};
    if (isNull player || { !alive player }) then { continue };

    private _hunger = player getVariable ["hunger",    100];
    private _thirst = player getVariable ["thirst",    100];
    private _rad    = player getVariable ["radiation",   0];

    _hungerBar progressSetPosition ((_hunger / 100) max 0 min 1);
    _thirstBar progressSetPosition ((_thirst / 100) max 0 min 1);
    _radBar    progressSetPosition ((_rad    / 100) max 0 min 1);
};
// =========================================================================
// RVG Base Intel Diary Updater
// =========================================================================
// Adds a diary record under "Field Intel" whenever the Renegade base
// spawns or clears. Called from fn_worldInit.sqf on the server via
// remoteExec so every client sees the same intel.
//
// Params:
//   0: STRING — "SPAWN" or "CLEAR"
//   1: STRING — base location name
//   2: ARRAY  — base position [x,y,z] (kept for future use, not displayed)
// =========================================================================

params ["_status", "_locationName", "_basePos"];

// Create the diary subject on first use, once per client.
if (isNil {player getVariable "RVG_intelSubjectCreated"}) then {
    player createDiarySubject ["RVG_FieldIntel", "Field Intel"];
    player setVariable ["RVG_intelSubjectCreated", true];
};

private _title = "";
private _body  = "";

switch (_status) do {
    case "SPAWN": {
        _title = format ["Renegade Camp — %1", _locationName];
        _body = format [
            "<font color='#FF4444'>STATUS: ACTIVE</font><br/>" +
            "<font color='#FFAA00'>Location:</font> %1<br/><br/>" +
            "Clear the camp for supplies. Reinforcements will arrive if you attack.",
            _locationName
        ];
    };

    case "CLEAR": {
        _title = format ["Renegade Camp — %1 (CLEARED)", _locationName];
        _body = format [
            "<font color='#44FF44'>STATUS: CLEARED</font><br/>" +
            "<font color='#FFAA00'>Location:</font> %1<br/><br/>" +
            "Supplies remain at the site. Wait for the next camp to spawn.",
            _locationName
        ];
    };
};

if (_title != "") then {
    player createDiaryRecord ["RVG_FieldIntel", [_title, _body]];
};
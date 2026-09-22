private _activeMissions = missionNamespace getVariable [
    "RVG_activeMissions",
    []
];

private _missionData = [];

{
    if ((count _x) >= 4) then {
        _missionData pushBack [
            _x select 0, // slot
            _x select 1, // mission type
            _x select 2, // location name
            _x select 3  // mission position
        ];
    };
} forEach _activeMissions;

diag_log format [
    "RVG SAVE: Collected %1 mission definitions.",
    count _missionData
];

_missionData
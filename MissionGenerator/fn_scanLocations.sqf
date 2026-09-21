// =========================================================================
// RVG Mission Generator - Scan Map Locations
//
// Returns:
// [
//     ["Location Name", [x,y,z]],
//     ...
// ]
// =========================================================================

params [
    ["_minHQDistance", 1000]
];

private _hq = missionNamespace getVariable [
    "MissionHQ",
    objNull
];

if (isNull _hq) exitWith {

    diag_log
        "RVG MissionGenerator: ERROR - MissionHQ not found.";

    []
};

private _hqPos = getPosATL _hq;

private _locations = nearestLocations [
    [worldSize / 2, worldSize / 2],
    [
        "NameCityCapital",
        "NameCity",
        "NameVillage"
    ],
    worldSize
];

// Blacklisted locations — terrain or layout makes these unsuitable for
// mission spawns. Add more names as needed (must match `text` exactly).
private _blacklist = [
    "Gromada",
    "Lower Esseker"
];

private _result = [];

{
    private _name = text _x;
    private _pos  = locationPosition _x;

    if (
        _name != "" &&
        { !(_name in _blacklist) } &&
        { _pos distance2D _hqPos >= _minHQDistance }
    ) then {

        private _alreadyAdded =
            _result findIf {
                (_x select 0) isEqualTo _name
            };

        if (_alreadyAdded == -1) then {

            _result pushBack [
                _name,
                _pos
            ];

            diag_log format [
                "RVG MissionGenerator: Found location %1 at %2",
                _name,
                _pos
            ];
        };
    };

} forEach _locations;

diag_log format [
    "RVG MissionGenerator: Found %1 usable map locations.",
    count _result
];

_result
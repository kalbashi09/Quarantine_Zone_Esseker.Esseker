params [
    "_slot",
    "_marker"
];

if (_marker isEqualTo "") exitWith {};

private _registry = missionNamespace getVariable [
    "RVG_missionEntities",
    []
];

while {count _registry <= _slot} do {
    _registry pushBack [
        [], // objects
        [], // groups
        []  // markers
    ];
};

private _missionRegistry = _registry select _slot;

private _markers = _missionRegistry select 2;

if !(_marker in _markers) then {
    _markers pushBack _marker;
};

_missionRegistry set [2, _markers];

_registry set [_slot, _missionRegistry];

missionNamespace setVariable [
    "RVG_missionEntities",
    _registry
];

diag_log format [
    "RVG MissionRegistry: Slot %1 | Marker registered: %2",
    _slot + 1,
    _marker
];
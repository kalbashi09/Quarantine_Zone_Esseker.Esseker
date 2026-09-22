params [
    "_slot",
    "_entity"
];

if (isNull _entity) exitWith {};

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

private _objects = _missionRegistry select 0;
private _groups  = _missionRegistry select 1;

if (_entity isEqualType objNull) then {
    if !(_entity in _objects) then {
        _objects pushBack _entity;
    };
};

if (_entity isEqualType grpNull) then {
    if !(_entity in _groups) then {
        _groups pushBack _entity;
    };
};

_missionRegistry set [0, _objects];
_missionRegistry set [1, _groups];

_registry set [_slot, _missionRegistry];

missionNamespace setVariable [
    "RVG_missionEntities",
    _registry
];

diag_log format [
    "RVG MissionRegistry: Slot %1 | Objects: %2 | Groups: %3",
    _slot + 1,
    count (_missionRegistry select 0),
    count (_missionRegistry select 1)
];
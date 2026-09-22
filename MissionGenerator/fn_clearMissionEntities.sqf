params ["_slot"];

private _registry = missionNamespace getVariable [
    "RVG_missionEntities",
    []
];

if (_slot >= count _registry) exitWith {
    diag_log format [
        "RVG MissionRegistry: Slot %1 has no registry entry.",
        _slot + 1
    ];
};

private _missionRegistry = _registry select _slot;

private _objects = _missionRegistry select 0;
private _groups  = _missionRegistry select 1;
private _markers = _missionRegistry select 2;

{
    if (!isNull _x) then {
        deleteVehicle _x;
    };
} forEach _objects;

{
    if (!isNull _x) then {
        {
            if (!isPlayer _x) then {
                deleteVehicle _x;
            };
        } forEach units _x;

        deleteGroup _x;
    };
} forEach _groups;

{
    if (_x isEqualType "") then {
        if (getMarkerType _x != "") then {
            deleteMarker _x;
        };
    };
} forEach _markers;

_registry set [
    _slot,
    [
        [],
        [],
        []
    ]
];

missionNamespace setVariable [
    "RVG_missionEntities",
    _registry
];

diag_log format [
    "RVG MissionRegistry: Slot %1 cleared — %2 objects, %3 groups, %4 markers.",
    _slot + 1,
    count _objects,
    count _groups,
    count _markers
];
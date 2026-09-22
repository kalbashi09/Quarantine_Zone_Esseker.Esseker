### 🧹 Clear a mission slot

```sqf
[0] call RVG_fnc_clearMissionEntities;
```

Slot numbers are **0-based**:

```sqf
[0] call RVG_fnc_clearMissionEntities;   // Slot 1
[1] call RVG_fnc_clearMissionEntities;   // Slot 2
[2] call RVG_fnc_clearMissionEntities;   // Slot 3
```

---

### 🔍 View the entire mission registry

```sqf
missionNamespace getVariable ["RVG_missionEntities", []]
```

You'll see:

```text
[
    [objects, groups, markers],   // Slot 1
    [objects, groups, markers],   // Slot 2
    [objects, groups, markers]    // Slot 3
]
```

---

### 🔍 View active mission definitions

This is particularly important for Phase 3:

```sqf
missionNamespace getVariable ["RVG_activeMissions", []]
```

Expected format:

```text
[
    [0,"CACHE","Posestra",[7785.01,6695.57,0]],
    [1,"CACHE","Weiss College",[7417.83,5072.66,0]],
    [2,"RESCUE","Plava Vrana Military Complex",[6556.12,4012.8,0]]
]
```

If a mission is currently in a stage and `setMissionStage` has added it, you might see a fifth element:

```text
[0,"RESCUE","Old Esseker",[6978,9410,0],"ESCORT"]
```

That's normal — **our save system intentionally ignores that fifth stage element.**

---

### 💾 Collect exactly what will be saved

```sqf
call RVG_fnc_collectMissions
```

This should return only:

```text
[
    [slot,type,location,position],
    ...
]
```

This is one of the most useful tests because it shows **exactly what Phase 3 is putting into the save**.

---

### 🧪 Check a specific mission's registry

For example, Slot 1:

```sqf
(missionNamespace getVariable ["RVG_missionEntities", []]) select 0
```

Slot 2:

```sqf
(missionNamespace getVariable ["RVG_missionEntities", []]) select 1
```

Slot 3:

```sqf
(missionNamespace getVariable ["RVG_missionEntities", []]) select 2
```

---

### 🧪 Check saved profile data

After saving:

```sqf
profileNamespace getVariable [
    format ["RVG_PersistentSave_%1", getPlayerUID player],
    []
]
```

This lets us inspect the **actual saved array**, including the mission definitions.

---

### 📝 Quick Phase 3 test sequence

When we test the synchronization fix, I'd use:

```sqf
// 1. See current missions
missionNamespace getVariable ["RVG_activeMissions", []]

// 2. See what would be saved
call RVG_fnc_collectMissions

// 3. Save normally through your save system

// 4. Finish one mission

// 5. Load

// 6. Check restored missions
missionNamespace getVariable ["RVG_activeMissions", []]

// 7. Check registry
missionNamespace getVariable ["RVG_missionEntities", []]
```

**Most important three to remember:**

```sqf
[0] call RVG_fnc_clearMissionEntities;
```

```sqf
missionNamespace getVariable ["RVG_activeMissions", []]
```

```sqf
missionNamespace getVariable ["RVG_missionEntities", []]
```

Those three will probably be our main debugging commands from here onward.

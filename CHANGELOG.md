# Quarantine Zone — Esseker

# Changelog

All notable changes to this mission are documented here.

Format: Keep a Changelog (https://keepachangelog.com/en/1.1.0/)
Versioning: Semantic (Major.Minor.Patch)

---

## [1.0.3] - 2026-09-22

# Persistence Update

This release introduces the mission's custom Save State system, allowing players to save and restore important gameplay state directly through the mission.

**Note:** This is a custom in-game Save State system and does not use Arma 3's native save system. **Abort** is still used to exit the mission.

### Added

#### Player Persistence

- Player persistent gear items are now stored in the Base Arsenals.
- Player-owned gear can be recovered from the Base Arsenal after death and respawn.
- Persistent player gear is separated from the standard mission loadout system.
- Base Arsenal persistent items survive player respawns.

#### Mission Persistence

- Added custom in-game persistent Save/Load support.
- Save and Load interactions are available only when looking directly at the designated **Briefing Board**.
- This prevents accidental Save/Load activation while interacting with other objects in the base.
- Active missions are saved using:
  - Mission slot
  - Mission type
  - Location name
  - Mission position
- Saved missions are recreated at their saved locations after loading.
- Mission progress is intentionally **not** persisted.
- Restored missions always begin from their normal initial state.
- Added a mission entity registry for mission-owned:
  - Objects
  - Groups
  - Markers
- Mission entities are cleared before saved missions are recreated.
- Added runtime mission instance IDs to distinguish current missions from old mission scripts.
- Mission generation pauses while saved missions are being restored.

#### Renegade Base

- Renegade Base systems are now compatible with the custom Save State system.
- Base generation and mission restoration are prevented from interfering with each other.
- Renegade Base entities are properly handled during persistence recovery.
- Base-related systems continue operating normally after Save/Load recovery.
- Renegade Base restoration now correctly synchronizes with the World Generator.
- Renegade Base restoration is protected from premature base-clear detection while the base is being rebuilt.
- Renegade Base Field Intel is refreshed during Save/Load recovery.
- Loading a saved active base now replaces stale Field Intel with the restored base information.
- Loading a Save State without an active Renegade Base now clears stale Field Intel entries.

#### Mission Placement

- Added terrain-aware mission placement.
- Mission locations are checked for:
  - Water
  - Steep terrain
  - Rocks
  - Buildings
  - Trees and vegetation
  - Other unsuitable terrain objects
- Rescue survivor and guard spawning now searches for a clear position.
- Investigate camp placement validates the camp footprint.
- Cache camp placement validates the actual positions used by its camp objects.
- Mission objects use collision-aware placement to reduce terrain clipping.

### Changed

- Save/Load interaction is restricted to the designated **Briefing Board**.
- Active mission data now contains a runtime-only mission instance identifier.
- Only mission definitions are written to persistent Save State data.
- Runtime mission state is recreated when a saved mission is restored.
- Mission restoration uses the normal Rescue, Investigate, and Cache mission scripts.
- Mission cleanup is handled through the shared mission entity registry.
- Mission location usage is reset during mission restoration.
- Player gear persistence is integrated with the Base Arsenal system.
- Rescue and Investigate **Return to HQ** completion range is now **80 meters**.
- Arma 3's native Save and Exit system remains disabled; **Abort** is still used to exit the mission.

### Fixed

- Old mission coroutines continuing to execute after their mission entities were deleted during loading.
- Stale mission coroutines interfering with newly restored missions using the same slot.
- Old mission completion/failure handlers affecting newly restored missions.
- Mission batches regenerating while saved missions were being restored.
- Renegade Base systems conflicting with mission restoration.
- Mission objectives spawning on unsuitable terrain.
- Mission objects spawning inside rocks, buildings, trees, or other large terrain objects.
- Investigate camp objects being created with `CAN_COLLIDE`.
- Cache camp validation not matching the actual positions of its camp objects.
- Mission-owned objects, groups, and markers remaining after a mission was cleared.
- Renegade Base being incorrectly detected as cleared while a saved base was still being restored.
- Stale Renegade Base Field Intel remaining after loading a Save State.
- Previous Renegade Base Field Intel entries persisting when the saved state contained no active base.
- Save State restoration and World Generator base detection racing with each other.

### Technical

- Added `RVG_missionEntities` mission registry.
- Added `RVG_missionRestoreInProgress` restoration state.
- Added runtime mission instance tracking.
- Added:
  - `fn_registerMissionEntity.sqf`
  - `fn_registerMissionMarker.sqf`
  - `fn_clearMissionEntities.sqf`
- `fn_collectMissions.sqf` stores only persistent mission-definition data.
- Mission restoration creates fresh runtime instances from saved mission definitions.
- Mission entity cleanup and restoration are performed before the restored mission scripts begin their normal lifecycle.
- Renegade Base restoration uses a dedicated restore-in-progress state to synchronize with the World Generator.
- Field Intel is rebuilt from the restored Renegade Base state during Save/Load recovery.
- Save State operates through mission scripts rather than Arma 3's native save system.

---

## [1.0.2] - 2026-09-21

### CHANGED

- Player loadout is now cleared on initial spawn to prevent loadout exploits.
- Players now spawn with basic clothing only.
- Weapons, magazines, equipment, and medical supplies must be obtained from the Base Arsenal.

### FIXED

- Player death no longer ends the mission.
- Added FOB respawn support with a 10-second respawn delay.
- Respawn is now available after player death.
- Player is re-homed into their private group after respawning.
- Player teammates are restored after respawn.

### TECHNICAL

- Added proper FOB respawn configuration to `description.ext`.
- Respawn now uses the Eden Respawn Position module with a 10-second respawn delay.

---

## [1.0.1] - 2026-09-21

### CHANGED

- Save and Exit was disabled. The mission's live scripts, AI systems, and HUD could not survive a save/load cycle, so saving was turned off to prevent players from resuming into a broken state. Use Abort to exit.

### TECHNICAL

- Added `enableSaving [false, false]` to `initServer.sqf`.

### SAVE STATE - WORK IN PROGRESS

- Initial Save State development began.
- Save/load recovery support was planned for:
  - Mission Generator
  - World Generator
  - Event Scheduler
  - HUD
  - AI systems
- Not ready yet. No ETA.
- For now, use Abort when you want to stop playing.
- Progress resets on the next launch.
- If you have experience with Arma save/load and want to help test, leave a comment.

---

## [1.0.0] - 2026-09-21

### Initial Release

First public version. Everything below is the original release state of the mission.

---

## Core Systems

### Mission Generator

- 3 mission types: **Rescue**, **Investigate**, **Cache**
- Missions spawn in batches of 3, cycling when all are complete
- Location pool of 29 usable towns (Gromada and Lower Esseker blacklisted)
- Manual safe-position search replaces `BIS_fnc_findSafePos` to prevent off-map spawns

### Event Scheduler

- Random event every 8–18 minutes
- No repeats in a row
- Events: **Helicopter Patrol**, **Supply Drop**, **Hostile Roadblock**
- Each event has its own self-cleaning lifecycle

### World Generator

- Renegade base spawns ~10 min after mission start
- Rebuilds 25 min after the previous base is cleared
- 20-unit garrison (14 static, 6 patrol) with distance-gated simulation
- Reactive reinforcements: 5-man squad dispatched on first garrison death
- Roamer squads: 40% chance every 20–30 min
- Base loot crate with randomized weapon / mag / attachment / medical contents

### Teammate System

- Persistent 3-man AI fireteam per player
- Roster survives respawns (same names, faces, classes)
- 200m hard leash, soft regroup tiers at 80m and 40m
- Roster reconciler runs every 20s — idempotent, no double-spawn

### Loadouts

- 5 kits: rifleman (player default), automatic rifleman, light AT, medic, bandit
- Bandit kit uses CUP civilian clothes + RHS AKs
- No Apex or DLC assets in any kit

### Base Arsenal

- 4 categorized crates at base HQ: Weapons, Equipment, Essentials, Attachments
- Populated by supplyTracker at mission start
- Essentials crate includes full ACE medical + Ravage consumables

### Survival HUD

- Custom HUD showing **hunger**, **thirst**, **radiation** as three progress bars
- Top-left of screen, updates every second
- Reads Ravage's native survival variables
- No icons — relies on bar colors (orange / blue / green)

### Validator

- Runs once at mission start
- Checks every classname the mission references against loaded configs
- Logs missing entries to RPT + systemChat
- 11 categories, 126 total classnames

### Diary Intel

- Field Intel diary subject added to every player's map
- Record auto-added when Renegade base spawns
- Record updated when base is cleared
- JIP-safe — late-joining players get the full history

---

## Content Additions Since Original Draft

### Added

- Survival HUD for hunger / thirst / radiation
- Ravage consumables in supply drops:
  - Food
  - Water
  - Can opener
  - Matches
  - Purification tablets
  - Anti-rad pills
  - Gutting knife
- Randomized supply drop contents — 2 layers: subset pick + count roll
- ACE medical items expanded in BaseArsenalEssentials (26 total medical items)
- Classname validator script
- Field Intel diary for Renegade base tracking
- Blacklist for Gromada and Lower Esseker terrain
- Safe-position manual search for all mission and base spawns
- Persistent 3-man AI fireteam roster

### Changed

- Supply drop helicopter: CH-67 Huron → RHS Chinook (`RHS_CH_47F_cargo`)
- Bandit loadout: Apex civilians → CUP civilians (`CUP_U_C_*`)
- Bandit weapons: Apex AKM/AKS → RHS AKM/AKS-74
- Cargo attachment offset: `-7` → `-8` (Chinook fuselage)
- Renegade base location selection now uses shared mission location pool

### Fixed

- `rvg_fnc_init` CfgFunctions collision (removed EventGenerator init class)
- Teammate roster reconciler deleting mission units (added `RVG_missionUnit` tag)
- Survivor wandering away from guards (single camp group + HOLD waypoint)
- Off-map objective spawns from `BIS_fnc_findSafePos` spiral-out bug
- Spurious reinforcement dispatch on first garrison check
- Bandit uniform classname prefix (`CUP_C_*` → `CUP_U_*`)
- Null-object JIP remoteExec warning (added 0.1s delay before setIdentity)
- Rook40 reload failure — removed from bandit sidearm pool
- Event scheduler scope error (`_events` undefined in spawn block)

---

## Known Limitations

- Renegade base not marked on map (intentional)
- AI pathfinding can stall inside Esseker urban buildings (rare)
- Supply drop cargo net is a physical object (don't stand under it)
- HUD bars can shift if the player's resolution changes mid-session

---

## Mod Dependencies

See `README.md` for the current required mod list and Workshop links.

---

## Credits

- Ravage — Haleks
- SCAI - Your Lose
- Lifeline Revive AI - Bendy
- CUP Team
- RHS Team
- ACE Team
- CBA Team
- Esseker (New) - Malcain

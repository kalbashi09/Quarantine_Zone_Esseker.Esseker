# Quarantine Zone — Esseker

# Changelog

All notable changes to this mission are documented here.
Format: Keep a Changelog (https://keepachangelog.com/en/1.1.0/)
Versioning: Semantic (Major.Minor.Patch)

## [1.0.0] - 2026-09-21

### Initial Release

First public version. Everything below is the current state of the mission.

---

## Core Systems

### Mission Generator

- 3 mission types: **Rescue**, **Investigate**, **Cache**
- Missions spawn in batches of 3, cycling when all are complete
- Location pool of 29 usable towns (Gromada and Lower Esseker blacklisted)
- Manual safe-position search replaces BIS_fnc_findSafePos to prevent off-map spawns

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
- Ravage consumables in supply drops: food, water, can opener, matches, purification tablets, anti-rad pills, gutting knife
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
- Bandit uniform classname prefix (`CUP_C_` → `CUP_U_`)
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
- Lifeline Revive AI — Bendy
- CUP Team
- RHS Team
- ACE Team
- CBA Team
- Esseker (New) - Malcain

## v1.0.1

### CHANGED

- Save and Exit is now disabled. The mission's live scripts, AI systems,
  and HUD cannot survive a save/load cycle, so saving is turned off to
  prevent players from resuming into a broken state. Use Abort to exit.

### TECHNICAL

- Added enableSaving [false, false] to initServer.sqf

### SAVE STATE - WORK IN PROGRESS

- Save and load support is being worked on. The plan is to add recovery
  handlers that restart the mission generator, world generator, event
  scheduler, HUD, and AI systems when a saved mission is loaded.
- Not ready yet. No ETA. For now, please use Abort when you want to stop
  playing. Progress resets on next launch.
- If you have experience with Arma save/load and want to help test,
  leave a comment.

## v1.0.2

### CHANGED

- Player loadout is now cleared on initial spawn to prevent loadout exploits.
- Players now spawn with basic clothing only. Weapons, magazines, equipment, and medical supplies must be obtained from the Base Arsenal.

### FIXED

- Player death no longer ends the mission.
- Added FOB respawn support with a 10-second respawn delay.
- Respawn is now available after player death.
- Player is re-homed into their private group after respawning.
- Player teammates are restored after respawn.

### TECHNICAL

- Added proper FOB respawn configuration to description.ext.
- Respawn now uses the Eden Respawn Position module with a 10-second respawn delay.

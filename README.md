# QUARANTINE ZONE - ESSEKER

A survival sandbox mission for Arma 3, built on top of the Ravage mod,

set on the New Esseker map. Dynamic missions, ambient events, a persistent

AI fireteam, persistent player gear, a custom Save State system, and a

hostile Renegade faction that builds, patrols, and reacts.

Play mode: Single Player / Multiplayer Co-op

Recommended players: 1-4 (tested up to 8)

Session length: 1-3 hours per playthrough

---

## QUICK START

1. Subscribe to all required mods on Steam Workshop.
2. Launch Arma 3 with the modset enabled.
3. Eden Editor -> Scenarios -> Multiplayer -> Quarantine Zone - Esseker.
4. Play.

For dedicated servers: copy the .Esseker folder into your server's

mpmissions/ directory. The mission is server-authoritative; clients only

need the modset.

---

## REQUIRED MODS

All mods must be loaded. Steam Workshop prompts for subscriptions

automatically when you launch the mission.

CBA_A3 450814997

ACE3 463939057

CUP Terrains - Core 583496184

CUP Weapons 497660133

CUP Units 497661914

CUP Vehicles 541888371

Ravage 1376636636

SCAI - Smart Combat AI 3677550393

Lifeline Revive AI 3343235386

New Esseker 2712204589

RHS: USAF 843577117

RHS: AFRF 843425103

RHS: GREF 843593391

RHS: SAF 843632231

Optional - Recommended for Quality of Life

EVEN Better Inventory 3739421199

Mission works without EVEN Better Inventory, but its inventory UI is a

big improvement over vanilla.

### Load Order

The Arma 3 Launcher sorts most of this automatically. If you see missing

classnames in-game, order manually as:

1. CBA_A3
2. ACE3
3. RHS: AFRF
4. RHS: USAF
5. RHS: GREF
6. RHS: SAF
7. CUP Terrains - Core
8. CUP Weapons / Units / Vehicles
9. Ravage
10. SCAI
11. Lifeline Revive AI
12. New Esseker
13. EVEN Better Inventory (optional)

---

## FEATURES

### MISSION SYSTEM

- 3 mission types: Rescue, Investigate, Cache
- Spawns in batches of 3 - complete all three, a new batch generates
- 29 usable towns on Esseker (Gromada + Lower Esseker excluded)
- Mission locations use terrain-aware placement
- Mission objectives avoid unsuitable terrain and large terrain objects

### MISSION PERSISTENCE

- Custom in-game Save State system
- Save and Load are accessed through the designated Briefing Board
- Save/Load only appears when directly looking at the Briefing Board
- Active missions are saved by:
  - Mission slot
  - Mission type
  - Location
  - Mission position
- Saved missions are recreated at their saved locations
- Mission progress is intentionally not saved
- Restored missions begin from their normal initial state
- Mission objects, groups, and markers are cleaned up before restoration
- Runtime mission instances prevent old mission scripts from interfering
  with restored missions
- Mission generation pauses while a Save State is being restored

### PLAYER PERSISTENCE

- Persistent player gear is stored through the Base Arsenal system
- Persistent gear can be recovered after death and respawn
- Persistent gear is kept separate from the standard mission loadout
- Player-owned persistent items survive respawns

### SAVE STATE WORKFLOW

The Save State system is custom to this mission and does not use Arma 3's

native save system.

To save or load:

1. Return to the base.
2. Look directly at the designated Briefing Board.
3. Use the Save Persistent or Load Persistent interaction.
4. To leave the mission, use Abort.

The mission's Save State is designed to restore the important persistent

gameplay state when you return to the mission.

### AMBIENT EVENTS

- Helicopter Patrol - hostile Little Bird circles random towns
- Supply Drop - RHS Chinook delivers a physical cargo net with
  randomized supplies
- Hostile Roadblock - bandit checkpoint on a random road
- Random scheduler, no repeats in a row, independent lifecycles

### RENEGADE BASE

- Spawns ~10 min after mission start near a random town
- 20 bandits: 14 static posts, 6 patrol
- 4 watchtowers, HESCO ring, tents, campfire
- Loot crate at center with randomized contents
- Clearable - wipe the garrison, base disappears, crate stays
- Base systems are compatible with the custom Save State system
- Base generation and Save State restoration are synchronized to avoid
  conflicts

### REACTIVE REINFORCEMENTS

- Kill the first garrison unit -> 5-man squad flanks from random
  direction
- NOT counted toward base clear - base can clear while they still live

### ROAMING SQUADS

- Every 20-30 min, 40% chance the base dispatches a 5-man patrol
- Walks toward an active mission marker, then returns
- Self-terminates after 30 min

### PERSISTENT AI FIRETEAM

- Every player gets a personal 3-man AI squad
- Same names, faces, classes every respawn
- 200m hard leash, soft regroup at 80m and 40m
- Roster reconciler prevents double-spawn

### LOADOUT KITS

- Rifleman - CUP M4A1, standard kit
- Automatic Rifleman - MX SW, heavy ammo
- Light AT - CUP M4A1 + NLAW
- Medic - double first aid, extra mags
- Bandit - casual clothes, mismatched weapons (AI only)

### BASE ARSENAL

- 4 crates at HQ: Weapons, Equipment, Essentials, Attachments
- Populated at mission start
- Essentials includes full ACE medical + Ravage consumables
- Supports persistent player-owned gear

### SURVIVAL HUD

- Top-left HUD: hunger, thirst, radiation
- Color-coded bars (orange / blue / green)
- Updates every second

### FIELD INTEL DIARY

- Map -> Field Intel tab
- Logs every Renegade base spawn/clear with town name
- History accumulates over the session

### CLASSNAME VALIDATOR

- Runs once at mission start
- Checks 126 classnames against loaded configs
- Missing classes logged to RPT + systemChat

---

## HOW TO PLAY

### YOUR BASE

Spawn at HQ with a 3-man AI fireteam and standard rifleman kit. Four

Arsenal crates nearby - grab what you need.

Your personal AI teammates are restored after respawn.

Persistent player-owned gear can be recovered from the Base Arsenal.

### SAVING AND LOADING

The mission uses a custom Save State system rather than Arma 3's native

save system.

At the base, find the designated **Briefing Board**.

Look directly at the board to access:

- Save Persistent
- Load Persistent

The interaction is restricted to the Briefing Board to prevent accidental

Save/Load activation while interacting with other objects around the base.

When leaving the mission, use **Abort**.

### MISSIONS

Open map. Colored markers:

Green - Rescue (escort survivor to HQ)

Blue - Investigate (find and inspect a survivor camp)

Orange - Cache (search a hidden supply cache)

Complete all 3 to trigger the next batch.

For Rescue and Investigate, the Return to HQ completion range is now

**80 meters**.

### RENEGADE BASE

Not marked on map. You get a system chat announcing the town name.

Open map -> Field Intel for the log. Travel to the town and look for a

HESCO ring.

The base contains a garrison, patrols, defensive structures, and loot.

### SUPPLY DROPS

Green box marker on map. Cargo net contains:

Always: medical basics, mags, food, water, can opener, matches

Random: weapons, attachments, grenades, additional medical, tools

### SURVIVAL

Hunger and thirst drain over time. Eat and drink from inventory to

replenish. HUD bars top-left show current values. Radiation builds

from hot zones - take anti-rad pills to reduce.

---

## KNOWN LIMITATIONS

- Renegade base is not marked on map. Intentional - you're meant to scout.
- AI pathfinding on Esseker's urban areas can occasionally cause
  defenders to stall inside buildings. Rare, but possible.
- Supply drop cargo net is a physical object. Don't stand directly
  under a falling cargo net - you can be crushed.
- HUD bar positioning can shift if you change resolution mid-session.
- Gromada and Lower Esseker excluded from mission spawns (bad terrain
  and flooded ground).
- Mission progress is not persisted. Restored missions begin from their
  initial state.

---

## TROUBLESHOOTING

### "RVG_fnc_init DOES NOT EXIST"

`description.ext` failed to compile. Check for syntax errors - usually a

missing `};` in a recently-edited block.

### Missing classname warnings in RPT

The validator at mission start logs these. Usually means a mod isn't

loaded, or the mod version changed and a classname moved.

### AI teammates won't follow

Check distance. If >200m away, leash teleports them. If stuck in

combat, leash won't override - wait for the fight to end.

### Renegade base never spawns

Check RPT for `"No valid base location available"`. No clear spot found

in candidate towns. Base will retry on the next 15s poll.

### Supply drop lands in a weird spot

The mission uses terrain-aware placement to avoid water, steep terrain,

buildings, rocks, and other unsuitable locations. Rare placement issues

may still occur due to terrain or object geometry.

### Save/Load does not appear

Make sure you are looking directly at the designated **Briefing Board**.

Save/Load is intentionally unavailable when looking at other objects in

the base.

### Restored missions look different

This is intentional. Mission progress is not saved. The mission definition

is restored, including its slot, type, location, and position, but the

mission itself starts again from its initial state.

---

## CREDITS

### MODS

Ravage - Haleks

SCAI (author)

Lifeline Revive AI Bendy

CUP Community Upgrade Project team

RHS Red Hammer Studios team

ACE3 ACE Team

CBA_A3 CBA Team

New Esseker (map author)

### MISSION

Scripts, systems, design by TERRAble231.

Built over a weekend out of boredom - wanted a Ravage scenario that

wasn't a straight shot from spawn to extraction. Ended up liking how

it played, so here it is.

---

## LICENSE

Free to play, modify, and re-upload for personal use. If you publish

changes, credit the original mod authors and link back to this mission.

Not for commercial use.

---

## CHANGELOG

See CHANGELOG.md in the mission folder.

---

## FEEDBACK

Steam Workshop page:

https://steamcommunity.com/sharedfiles/filedetails/?id=3804990349

Post bugs, suggestions, or issues there. If something breaks on a specific

map location or with a specific mod combination, mention it.

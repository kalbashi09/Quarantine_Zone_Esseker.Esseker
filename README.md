# QUARANTINE ZONE - ESSEKER

A survival sandbox mission for Arma 3, built on top of the Ravage mod and
set on the New Esseker map.

Dynamic missions, ambient events, a persistent AI fireteam, persistent
player gear, a custom Save State system, and a hostile Renegade faction
that builds, patrols, and reacts.

**Play mode:** Single Player / Multiplayer Co-op  
**Recommended players:** 1-4 (tested up to 8)  
**Session length:** 1-3 hours per playthrough

---

## QUICK START

1. Subscribe to all required mods on Steam Workshop.
2. Launch Arma 3 with the modset enabled.
3. Open:
   `Eden Editor -> Scenarios -> Multiplayer -> Quarantine Zone - Esseker`
4. Play.

### Dedicated Servers

Copy the `.Esseker` mission folder into your server's `mpmissions/`
directory.

The mission is server-authoritative. Clients only need the required modset.

---

## REQUIRED MODS

All required mods must be loaded. Steam Workshop will prompt for
subscriptions when launching the mission.

| Mod                    | Workshop ID |
| ---------------------- | ----------: |
| CBA_A3                 |   450814997 |
| ACE3                   |   463939057 |
| CUP Terrains - Core    |   583496184 |
| CUP Weapons            |   497660133 |
| CUP Units              |   497661914 |
| CUP Vehicles           |   541888371 |
| Ravage                 |  1376636636 |
| SCAI - Smart Combat AI |  3677550393 |
| Lifeline Revive AI     |  3343235386 |
| New Esseker            |  2712204589 |
| RHS: USAF              |   843577117 |
| RHS: AFRF              |   843425103 |
| RHS: GREF              |   843593391 |
| RHS: SAF               |   843632231 |

### Optional - Recommended

**EVEN Better Inventory** — `3739421199`

The mission works without it, but its inventory interface provides a
significant improvement over the vanilla inventory UI.

### Load Order

The Arma 3 Launcher normally handles this automatically.

If you encounter missing classnames, use:

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

# FEATURES

## MISSION SYSTEM

- 3 mission types: Rescue, Investigate, and Cache.
- Missions spawn in batches of 3.
- Completing all 3 missions generates the next batch.
- 29 usable towns on Esseker.
- Gromada and Lower Esseker are excluded.
- Mission locations use terrain-aware placement.
- Mission objectives avoid water, steep terrain, buildings, rocks,
  vegetation, and other unsuitable terrain objects.

## MISSION PERSISTENCE

The mission uses a custom Save State system designed specifically for
this scenario.

- Save and Load are accessed through the designated Briefing Board.
- Save/Load only appears when directly looking at the Briefing Board.
- Active missions are saved using:
  - Mission slot
  - Mission type
  - Location name
  - Mission position
- Saved missions are recreated at their saved locations.
- Mission progress is intentionally not saved.
- Restored missions begin from their normal initial state.
- Mission-owned objects, groups, and markers are cleaned up before
  restoration.
- Runtime mission instances prevent old mission scripts from interfering
  with restored missions.
- Mission generation pauses while Save State restoration is in progress.

## PLAYER PERSISTENCE

- Player-owned gear is stored through the Base Arsenal system.
- Persistent gear can be recovered after death and respawn.
- Persistent gear is kept separate from the standard mission loadout.
- Player-owned persistent items survive player respawns.

## SAVE STATE WORKFLOW

The Save State system is custom to this mission and does not use
Arma 3's native save system.

To save or load:

1. Return to HQ.
2. Find the designated **Briefing Board**.
3. Look directly at the board.
4. Select **Save Persistent** or **Load Persistent**.
5. To leave the mission, use **Abort**.

Save State restores the important persistent gameplay state while keeping
mission progress intentionally reset.

---

## AMBIENT EVENTS

Three independent ambient events can occur during a playthrough:

### Helicopter Patrol

A hostile Little Bird patrols around a randomly selected town.

### Supply Drop

An RHS Chinook delivers a physical cargo net containing randomized
supplies.

### Hostile Roadblock

A hostile bandit checkpoint is established on a random road.

The event scheduler uses random selection and prevents the same event from
repeating consecutively.

Each event has its own lifecycle and cleanup.

---

## RENEGADE BASE

A hostile Renegade base dynamically appears during the playthrough.

- Spawns approximately 10 minutes after mission start.
- Appears near a random town.
- 20-man garrison:
  - 14 static defenders
  - 6 patrol units
- 4 watchtowers.
- HESCO defensive ring.
- Tents and campfire.
- Central loot crate with randomized contents.
- Base can be cleared.
- Clearing the garrison removes the base.
- The loot crate remains after the base is cleared.
- Renegade Base state is supported by the custom Save State system.
- Base generation and Save State restoration are synchronized to prevent
  conflicts.
- Field Intel is rebuilt from the restored base state.

---

## REACTIVE REINFORCEMENTS

Attacking the Renegade Base triggers a reaction:

- Killing the first garrison unit dispatches a 5-man flanking squad.
- The squad approaches from a random direction.
- Reinforcements are **not counted toward base clear**.
- The base can therefore be cleared while the reinforcement squad is
  still alive.

---

## ROAMING SQUADS

Renegade bases can dispatch roaming patrols.

- Every 20-30 minutes, there is a 40% chance of a patrol being dispatched.
- Patrols consist of 5 Renegade soldiers.
- The patrol moves toward an active mission marker.
- After reaching the area, it returns.
- Patrols self-terminate after 30 minutes.

---

## PERSISTENT AI FIRETEAM

Every player receives a personal 3-man AI fireteam.

- Same names, faces, and classes after respawn.
- 200m hard leash.
- Soft regroup at 80m and 40m.
- Roster reconciler prevents duplicate teammate spawning.
- AI teammates are restored after player respawn.

---

## LOADOUT KITS

Five loadout configurations are available:

- **Rifleman** - CUP M4A1, standard kit.
- **Automatic Rifleman** - MX SW, heavy ammunition.
- **Light AT** - CUP M4A1 + NLAW.
- **Medic** - Additional medical supplies and ammunition.
- **Bandit** - Casual clothing and mismatched weapons (AI only).

---

## BASE ARSENAL

HQ contains four Arsenal crates:

- Weapons
- Equipment
- Essentials
- Attachments

The Arsenal is populated at mission start.

Essentials include ACE medical supplies and Ravage survival
consumables.

The Base Arsenal also handles persistent player-owned gear.

---

## SURVIVAL HUD

A survival HUD is displayed in the top-left corner.

- Hunger
- Thirst
- Radiation

Values update continuously during gameplay.

---

## FIELD INTEL DIARY

The **Field Intel** diary records Renegade Base activity.

- Renegade base spawns are recorded with their town name.
- Cleared bases are recorded.
- History accumulates during the session.
- Save State restoration rebuilds Field Intel from the restored base state.

---

## CLASSNAME VALIDATOR

A classname validator runs once at mission start.

It checks required classnames against the loaded game configuration.

Missing classes are reported to the RPT and displayed through
`systemChat`.

---

# HOW TO PLAY

## YOUR BASE

You begin at HQ with:

- A 3-man AI fireteam.
- Standard rifleman equipment.
- Access to four Arsenal crates.

Your AI teammates persist through respawns.

Persistent player-owned gear can be recovered through the Base Arsenal.

---

## SAVING AND LOADING

Return to HQ and locate the **Briefing Board**.

Look directly at the board to access:

- **Save Persistent**
- **Load Persistent**

The interaction is restricted to the Briefing Board to prevent accidental
Save/Load activation around other HQ objects.

When leaving the mission, use **Abort**.

---

## MISSIONS

Open the map to view active mission markers.

- **Green** - Rescue
- **Blue** - Investigate
- **Orange** - Cache

### Rescue

Find the survivor and escort them back to HQ.

### Investigate

Locate the survivor camp and investigate the site.

### Cache

Locate and search the hidden supply cache.

Complete all three active missions to trigger the next mission batch.

For Rescue and Investigate, Return to HQ completion requires being within
**80 meters** of HQ.

---

## RENEGADE BASE

Renegade bases are intentionally not marked on the map.

You receive a system chat message announcing the town where the base has
appeared.

Check:

`Map -> Field Intel`

Travel to the indicated town and search for the HESCO defensive ring.

The base contains a garrison, patrols, defensive structures, and loot.

---

## SUPPLY DROPS

Supply drops are marked by a green box marker.

The physical cargo net contains:

**Always:**

- Medical basics
- Magazines
- Food
- Water
- Can opener
- Matches

**Random:**

- Weapons
- Attachments
- Grenades
- Additional medical supplies
- Survival tools
- Special items

Supply contents vary between drops.

---

## SURVIVAL

Hunger and thirst decrease over time.

Use food and drinks from your inventory to replenish them.

Radiation accumulates in contaminated areas. Use anti-rad medication to
reduce radiation.

The survival HUD displays your current values.

---

# KNOWN LIMITATIONS

- The Renegade Base is intentionally not marked on the map.
- AI pathfinding in Esseker's urban areas can occasionally cause defenders
  to stall inside buildings.
- The Supply Drop cargo net is a physical object. Do not stand directly
  underneath a falling cargo net.
- HUD positioning can shift if the display resolution is changed during
  a session.
- Gromada and Lower Esseker are excluded from mission spawning because of
  unsuitable terrain and flooded areas.
- Mission progress is not persisted. Restored missions begin from their
  initial state.

---

# TROUBLESHOOTING

## "RVG_fnc_init DOES NOT EXIST"

`description.ext` failed to compile.

Check for syntax errors, particularly a missing `};` in a recently edited
function or configuration block.

## Missing Classname Warnings in RPT

The classname validator reports missing classes at mission start.

Usually this means:

- A required mod is not loaded.
- A mod has been updated.
- A classname has changed or been removed.

Check the required mod list and the RPT.

## AI Teammates Won't Follow

Check their distance from you.

- Within 40m - normal following.
- Around 80m - regroup behavior.
- Beyond 200m - hard leash activates.

If AI are stuck in combat, the leash may not immediately override their
combat behavior.

## Renegade Base Never Spawns

Check the RPT for:

`No valid base location available`

This means no suitable base location was found during the current search.

The World Generator will retry during its next polling cycle.

## Supply Drop Lands in a Weird Spot

Supply drops use terrain-aware placement to avoid water, steep terrain,
buildings, rocks, and other unsuitable terrain.

Rare placement issues can still occur because of terrain geometry and
object placement.

## Save/Load Does Not Appear

Make sure you are:

1. At HQ.
2. Looking directly at the designated **Briefing Board**.
3. Alive.

Save/Load is intentionally unavailable when looking at other objects.

## Restored Missions Look Different

This is intentional.

Mission progress is not saved.

The Save State restores the mission definition:

- Slot
- Mission type
- Location
- Position

The mission then starts again from its normal initial state.

---

# CREDITS

## MODS

- Ravage - Haleks
- SCAI - Smart Combat AI
- Lifeline Revive AI - Bendy
- CUP - Community Upgrade Project team
- RHS - Red Hammer Studios team
- ACE3 - ACE Team
- CBA_A3 - CBA Team
- New Esseker - Map author

## MISSION

Scripts, systems, design, and integration by **TERRAble231**.

Built over a weekend out of boredom. I wanted a Ravage scenario that
wasn't just a straight shot from spawn to extraction.

It ended up being something I liked playing, so here it is.

---

# LICENSE

Free to play, modify, and re-upload for personal use.

If you publish modified versions, credit the original mod authors and
link back to this mission.

**Not for commercial use.**

---

# CHANGELOG

See `CHANGELOG.md` in the mission folder.

---

# FEEDBACK

Steam Workshop:

https://steamcommunity.com/sharedfiles/filedetails/?id=3804990349

Post bugs, suggestions, or issues there.

If something breaks at a specific map location or with a specific mod
combination, include those details when reporting the issue.

# QUARANTINE ZONE - ESSEKER

A survival sandbox mission for Arma 3, built on top of the Ravage mod,
set on the New Esseker map. Dynamic missions, ambient events, a persistent
AI fireteam, and a hostile Renegade faction that builds, patrols, and reacts.

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

Load Order

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

MISSION SYSTEM

- 3 mission types: Rescue, Investigate, Cache
- Spawns in batches of 3 - complete all three, a new batch generates
- 29 usable towns on Esseker (Gromada + Lower Esseker excluded)

AMBIENT EVENTS

- Helicopter Patrol - hostile Little Bird circles random towns
- Supply Drop - RHS Chinook delivers a physical cargo net with
  randomized supplies
- Hostile Roadblock - bandit checkpoint on a random road
- Random scheduler, no repeats in a row, independent lifecycles

RENEGADE BASE

- Spawns ~10 min after mission start near a random town
- 20 bandits: 14 static posts, 6 patrol
- 4 watchtowers, HESCO ring, tents, campfire
- Loot crate at center with randomized contents
- Clearable - wipe the garrison, base disappears, crate stays

REACTIVE REINFORCEMENTS

- Kill the first garrison unit -> 5-man squad flanks from random
  direction
- NOT counted toward base clear - base can clear while they still live

ROAMING SQUADS

- Every 20-30 min, 40% chance the base dispatches a 5-man patrol
- Walks toward an active mission marker, then returns
- Self-terminates after 30 min

PERSISTENT AI FIRETEAM

- Every player gets a personal 3-man AI squad
- Same names, faces, classes every respawn
- 200m hard leash, soft regroup at 80m and 40m
- Roster reconciler prevents double-spawn

LOADOUT KITS

- Rifleman - CUP M4A1, standard kit
- Automatic Rifleman - MX SW, heavy ammo
- Light AT - CUP M4A1 + NLAW
- Medic - double first aid, extra mags
- Bandit - casual clothes, mismatched weapons (AI only)

BASE ARSENAL

- 4 crates at HQ: Weapons, Equipment, Essentials, Attachments
- Populated at mission start
- Essentials includes full ACE medical + Ravage consumables

SURVIVAL HUD

- Top-left HUD: hunger, thirst, radiation
- Color-coded bars (orange / blue / green)
- Updates every second

FIELD INTEL DIARY

- Map -> Field Intel tab
- Logs every Renegade base spawn/clear with town name
- History accumulates over the session

CLASSNAME VALIDATOR

- Runs once at mission start
- Checks 126 classnames against loaded configs
- Missing classes logged to RPT + systemChat

---

## HOW TO PLAY

YOUR BASE
Spawn at HQ with a 3-man AI fireteam and standard rifleman kit. Four
Arsenal crates nearby - grab what you need. Respawn at HQ; teammates
respawn with you.

MISSIONS
Open map. Colored markers:
Green - Rescue (escort survivor to HQ)
Blue - Investigate (find and inspect a survivor camp)
Orange - Cache (search a hidden supply cache)
Complete all 3 to trigger the next batch.

RENEGADE BASE
Not marked on map. You get a system chat announcing the town name.
Open map -> Field Intel for the log. Travel to the town and look for a
HESCO ring.

SUPPLY DROPS
Green box marker on map. Cargo net contains:
Always: medical basics, mags, food, water, can opener, matches
Random: weapons, attachments, grenades, additional medical, tools

SURVIVAL
Hunger and thirst drain over time. Eat and drink from inventory to
replenish. HUD bars top-left show current values. Radiation builds
from hot zones - take anti-rad pills to reduce.

---

## KNOWN LIMITATIONS

- Renegade base not marked on map. Intentional - you're meant to scout.
- AI pathfinding on Esseker's urban areas can occasionally cause
  defenders to stall inside buildings. Rare, but possible.
- Supply drop cargo net is a physical object. Don't stand directly
  under a falling cargo net - you can be crushed.
- HUD bar positioning can shift if you change resolution mid-session.
- Gromada and Lower Esseker excluded from mission spawns (bad terrain
  and flooded ground).

---

## TROUBLESHOOTING

"RVG_fnc_init DOES NOT EXIST"
description.ext failed to compile. Check for syntax errors - usually a
missing }; in a recently-edited block.

Missing classname warnings in RPT
The validator at mission start logs these. Usually means a mod isn't
loaded, or the mod version changed and a classname moved.

AI teammates won't follow
Check distance. If >200m away, leash teleports them. If stuck in
combat, leash won't override - wait for the fight to end.

Renegade base never spawns
Check RPT for "No valid base location available". No clear spot found
in candidate towns. Base will retry on next 15s poll.

Supply drop lands in a weird spot
Randomizer picks a spot 100-250m from the selected town at a random
bearing. Landing in water or a building is rare but possible.

---

## CREDITS

MODS
Ravage Haleks
SCAI (author)
Lifeline Revive AI Bendy
CUP Community Upgrade Project team
RHS Red Hammer Studios team
ACE3 ACE Team
CBA_A3 CBA Team
New Esseker (map author)

MISSION
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

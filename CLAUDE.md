# CLAUDE.md

Guidance for Claude Code working in this repository.

## Project

**revrb** is a local multiplayer 2D pixel-art arena fighter in LÖVE 11.5 (LuaJIT). Two players fight in a single-screen arena with one-hit kills. Two core mechanics define the game:

- **Gun Game ladder.** Each player holds the weapon for their current tier. A kill advances the killer one tier. A kill with the final tier wins the match. The ladder goes from strong and forgiving to weak and skill-demanding, which rubber-bands the match automatically.
- **Echoes.** Each completed round is recorded. In later rounds, past players replay as hostile ghosts that can kill anyone.

The owner is a CS student comfortable with TypeScript, C++, and backend work, but **new to Lua and game development**. This is a learning project as much as a game.

## How to work with me

**I write the code. You teach, guide, and review.**

- **Do not create or edit files in `src/`, `data/`, `spec/`, `main.lua`, or `conf.lua` unless I explicitly ask you to write or change that code.** "How should I do X?" or "Help me with X" is a request for guidance, not for you to implement it.
- **Example code in the conversation is fine and encouraged.** Show short snippets that illustrate a pattern, an API, or a Lua idiom. Keep them focused on the concept rather than drop-in implementations of a whole feature. If a snippet would be most of the feature, show the shape (signatures, structure, pseudocode) and let me fill it in.
- **Explain the why.** Cover the game-dev and design reasoning: why a fixed timestep, why this state machine shape, why an approach avoids a class of bugs. Point out Lua idioms and gotchas when they come up (1-based indexing, `nil` in tables, `pairs` vs `ipairs`, `local` scoping, metatables).
- **Break work down.** When I start a milestone or feature, propose a sequence of small, runnable steps. I'll implement them one at a time.
- **Review honestly.** When I ask for a review, read the code and point out bugs, determinism violations, layering violations (sim touching `love.graphics`, render mutating state), and anything that will cause problems later. Explain each issue and how to think about fixing it rather than rewriting it.
- **Debug by teaching.** When something's broken, help me find the cause: suggest what to print or inspect, explain what the symptom implies. Name the fix once we've found it, but let me make it.
- **You may write without asking** for mechanical, non-learning files: `.luacheckrc`, `stylua.toml`, `.gitignore`, makelove config, CI workflows, and documentation. Vendoring libraries into `lib/` is also fine.
- **Ask before** suggesting a new dependency or a directory layout change, and don't decide anything listed under "Open questions" for me. Lay out the options and trade-offs.
- **Be direct.** If an approach I take is wrong or will cause problems later, say so and explain why.
- Don't push art, sound, or juice (screenshake, particles, hitstop) before the milestone that calls for it. Gray boxes until M5.

## Commands

```sh
love .              # run
busted              # run tests in spec/
luacheck src        # lint (config in .luacheckrc)
stylua src          # format (config in stylua.toml)
makelove            # package builds into build/
```

When reviewing changes to `src/sim/` or `src/match/`, run `busted` and `luacheck` and include the results in the review.

## Architecture

### Layering (strict)

```
input  →  sim  →  render
           ↑
         match
```

- **`src/sim/`** is the deterministic simulation: players, weapons, projectiles, world collision. It takes input frames and advances state by exactly one tick. It must never call `love.graphics`, `love.audio`, `love.timer`, `love.keyboard`, or `love.joystick`.
- **`src/match/`** owns rounds, the Gun Game ladder, scoring, and echo recording and playback. It drives the sim.
- **`src/input/`** turns hardware state into input frames. It's the only place that touches baton, keyboards, or joysticks.
- **`src/render/`** reads sim state and draws it. It never mutates sim state.
- **`src/scenes/`** handles title, match, and results screens and connects the layers.

Sounds and visual effects are triggered by **events** the sim emits (`{type = "hit", ...}`, `{type = "death", ...}`) and drains each tick. The sim never plays sounds directly.

### Fixed timestep

The simulation runs at a fixed 60 Hz with a constant `DT = 1/60`, using an accumulator in `love.update`. Rendering runs at display rate. Sim code uses **ticks** (integer frame counts) for durations like dash cooldown or attack startup, never seconds and never the variable `dt` from `love.update`.

### Determinism rules

Echoes, tests, and any future LAN or replay support depend on the sim being deterministic. In `src/sim/` and `src/match/`:

- No `love.update`'s `dt`, `os.time`, `os.clock`, or `love.timer` in gameplay logic.
- All randomness goes through the match RNG (`love.math.newRandomGenerator(seed)`), never `math.random`.
- **Never iterate with `pairs()` where order affects gameplay.** Keep entities in arrays and iterate with `ipairs` or numeric `for`. `pairs` order is not stable.
- Entity IDs are monotonically increasing integers assigned by the world.
- Floats are fine for now. Same build on the same machine is deterministic. Cross-machine determinism (needed only for LAN) would require fixed-point math and is out of scope.
- A test in `spec/` should run the sim twice from the same seed with the same input sequence and assert identical state hashes. Keep it passing.

### Input frames

Each tick, each player's input is a small table or bitmask:

```lua
{ left, right, up, down, jump, attack, dash, throw }  -- booleans
```

Plus edge flags for "pressed this tick" where needed (computed in `src/input/` by comparing against the previous frame). The sim only ever sees input frames, which makes recording, tests, and AI dummies trivial.

### Players

- No hardcoded `p1`/`p2`. Players live in an array indexed by slot (`1..n`) and the code must work for `n` in 2..4, even though the MVP ships 1v1.
- Player behavior is a state machine: `idle`, `run`, `jump`, `fall`, `wallslide`, `dash`, `attack`, `dead`. Each state has `enter`, `update`, and `exit` functions and a per-state tick counter.
- Movement uses coyote time and jump buffering. All movement constants live in `data/tuning.lua`.

### Weapons

Weapons are **data-driven**. `data/weapons.lua` defines the ladder as an ordered array of weapon definitions:

```lua
{ id = "shotgun", kind = "projectile", startup = 6, cooldown = 30,
  pellets = 5, spread = 0.35, speed = 260, range = 90, ... }
```

There are a small number of behaviors, chosen by `kind`: `melee`, `projectile`, `hitscan`, `thrown`. Adding a tier should usually mean adding a table entry, not new code.

Each weapon instance has exactly one state: `held`, `thrown`, `stuck`, or `returning` (for boomerangs). Route all state transitions through a single function so ownership bugs are impossible to introduce piecemeal.

Thrown weapons that hit terrain become `stuck` and act as one-way platforms.

### Collision

`bump.lua` handles world collision for players, projectiles, and stuck weapons, using response filters (`slide`, `cross`, one-way checks). Hit detection between attacks and players uses plain AABB overlap checks on hitboxes and hurtboxes, separate from bump.

### Gun Game rules

- Kill with tier N advances the killer to N+1. A kill with the final tier wins the match.
- **Demotion:** being killed by a melee weapon or the final-tier weapon drops the victim one tier (minimum tier 1).
- **Suicide:** dying to a hazard or your own projectile drops you one tier.
- **Stalemate:** if no kill happens for a configurable number of ticks, apply pressure (exact rule is an open question).
- Respawn holding the weapon for your current tier.

### Echoes

At the end of each round, record **per-tick state snapshots** for each player: position, facing, animation state, weapon tier, and attack and throw events. In later rounds, spawn an echo per recorded player that replays those snapshots exactly.

Echoes replay recorded **state**, not recorded **inputs**. Input replay through a world that has changed (new stuck spears, different opponents) would make echoes diverge from their original paths, which looks like a bug. State replay is faithful, simple, and cheap.

Echo attacks are real hitboxes and can kill any live player. Keep at most a configurable number of past rounds as active echoes (start with 3).

Also record the raw input frames for every round. They're not used for echoes, but they enable full-match replay and make determinism bugs reproducible.

### Rendering

- `love.graphics.setDefaultFilter("nearest", "nearest")`
- Draw everything to a 320×180 canvas, then integer-scale to the window with letterboxing.
- Placeholder art is colored rectangles, one color per player slot, with a lighter tint for echoes.
- `F1` draws colliders, hitboxes, and hurtboxes.

## Directory layout

```
main.lua            LÖVE callbacks; delegates to scene manager
conf.lua            window, identity ("revrb"), version 11.5
src/core/           loop (accumulator), rng, utility functions
src/input/          baton config, input frame builder
src/sim/            world, player, player states, weapons, projectiles, hitboxes
src/match/          match state, round flow, ladder, echo recorder/player
src/render/         canvas scaling, camera, draw functions, debug overlay
src/scenes/         scene manager, title, match, results
data/               tuning.lua, weapons.lua, arenas/
lib/                baton.lua, bump.lua, anim8.lua (vendored, unmodified)
assets/             sprites, sfx, fonts (empty until M5)
spec/               busted tests (sim and match only)
```

## Code conventions

- Every module is a file that returns a table. Everything is `local`. No globals except LÖVE's `love` table. `luacheck` enforces this.
- `snake_case` for variables and functions, `PascalCase` for constructor modules (`local Player = require("src.sim.player")`), `UPPER_SNAKE` for constants.
- Plain metatables for objects. No OOP library.
- Gameplay numbers go in `data/tuning.lua` or `data/weapons.lua`, not inline. Tuning hot-reloads on `F5`.
- Vendored libraries in `lib/` stay unmodified. Wrap them if behavior needs changing.
- Comments explain **why**, not what.

## Milestones

Work in this order. Don't start a milestone until the previous one runs.

1. **M0 Skeleton:** `conf.lua`, fixed-timestep loop, canvas scaling, scene manager, input frames from baton for 2+ controllers and keyboard, debug overlay toggle.
2. **M1 Movement:** arena from a simple tile table, bump collision, run, variable jump, coyote time, jump buffer, wall slide and wall jump, dash with cooldown, tuning hot-reload. Iterate until it feels good.
3. **M2 Combat:** three weapons (sword, spear with throw and stick, pistol), hitbox/hurtbox checks, death, respawn, sim events, the determinism test.
4. **M3 Gun Game:** full ladder from `data/weapons.lua`, round flow, win condition, demotion, suicide, stalemate rule, results screen.
5. **M4 Echoes:** recorder, playback entities, echo kills, echo cap.
6. **M5 Playtest and polish:** sprites, sound, screenshake, hitstop, particles. Done when friends voluntarily play 10 rounds.
7. **M6 Ship:** makelove config, itch.io builds.

## Open questions

Ask before deciding these:

- Can echoes be killed, or are they invulnerable hazards?
- Does a death caused by an echo count as a suicide (tier drop) or just a reset?
- Exact stalemate rule: shrink the arena, bump both players up a tier, or something else?
- Final ladder contents and order (draft: shotgun, rifle, bow, spear, boomerang, sword, dagger, frying pan).
- Respawn rules: instant with brief invulnerability, or does a kill end the round?
- Arena format: one handmade arena, or several selected per round?

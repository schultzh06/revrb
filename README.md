# revrb

A local multiplayer 2D pixel-art arena fighter built with [LÖVE](https://love2d.org).

Two players, one arena, one-hit kills. Every kill moves you up a **Gun Game** weapon ladder, from a forgiving shotgun down to a humiliating final weapon. Win by landing a kill with the last tier. Every round leaves an **echo**: your past selves replay their old runs as hostile ghosts that can kill anyone, so each round gets more crowded and more chaotic than the last.

> Status: early development. Placeholder art (colored rectangles) until the core loop is fun.

## Features (planned)

- 1v1 local multiplayer, architected for up to 4 players
- Controller support (Xbox, PlayStation, Switch Pro, and generic pads via SDL mappings), with a keyboard fallback
- Tight platformer movement: variable jump, wall slide and wall jump, dash, coyote time, input buffering
- Gun Game weapon ladder with melee, ranged, and thrown weapons
- Echoes: previous rounds replay as hostile ghosts
- Thrown weapons stick in walls and become platforms
- 320×180 internal resolution, integer-scaled

## Running

Requires [LÖVE 11.5](https://love2d.org).

```sh
# Arch
sudo pacman -S love

git clone https://github.com/schultzh06/revrb.git
cd revrb
love .
```

## Controls

### Gamepad

| Action | Button |
|---|---|
| Move | Left stick / D-pad |
| Jump | A / Cross |
| Attack | X / Square |
| Dash | B / Circle or RB / R1 |
| Throw | Y / Triangle |

### Keyboard fallback

| Action | Player 1 | Player 2 |
|---|---|---|
| Move | WASD | Arrow keys |
| Jump | Space | Right Ctrl |
| Attack | F | `.` |
| Dash | G | `/` |
| Throw | H | `,` |

## Development

```sh
love .              # run the game
busted              # run simulation tests
luacheck src        # lint
stylua src          # format
```

Debug keys (in development builds):

- `F1`: toggle hitbox / collider overlay
- `F2`: frame step (pause and advance one tick per press)
- `F5`: hot-reload `data/tuning.lua`

## Building

Builds are produced with [makelove](https://github.com/pfirsich/makelove):

```sh
pip install makelove
makelove            # builds Windows, macOS, and Linux targets into build/
```

## Project layout

```
main.lua, conf.lua   LÖVE entry points
src/core/            fixed-timestep loop, RNG, utilities
src/input/           controller/keyboard mapping → per-tick input frames
src/sim/             deterministic game simulation (players, weapons, projectiles, world)
src/match/           rounds, Gun Game ladder, echo recording and playback
src/render/          canvas scaling, camera, drawing (reads sim state, never writes it)
src/scenes/          title, match, results
data/                weapon ladder, tuning constants, arenas
lib/                 vendored third-party libraries
assets/              sprites, sounds, fonts
spec/                busted tests
```

## Roadmap

- [ ] **M0 Skeleton:** fixed timestep, canvas scaling, scene switching, input frames
- [ ] **M1 Movement:** collision, run, jump, wall jump, dash, tuning hot-reload
- [ ] **M2 Combat:** three weapons (melee, ranged, thrown), hits, death, respawn
- [ ] **M3 Gun Game:** full ladder, round flow, demotion and stalemate rules
- [ ] **M4 Echoes:** record rounds, replay as hostile ghosts
- [ ] **M5 Playtest:** friends voluntarily play 10 rounds
- [ ] **M6 Polish and ship:** art, sound, juice, itch.io builds

## Credits

- [LÖVE](https://love2d.org) (zlib)
- [baton](https://github.com/tesselode/baton) (MIT)
- [bump.lua](https://github.com/kikito/bump.lua) (MIT)
- [anim8](https://github.com/kikito/anim8) (MIT)

## License

TBD

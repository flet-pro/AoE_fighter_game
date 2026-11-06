# Art of Engineering: tabletop fighting game

Team **ok with anything**: Petewat Chaoha, Cara Cong, Seisen Fu,
Jun Hong Lim, and Ethan Zhang.

A planned two-player arcade game using Godot **3.6.3**, a Raspberry Pi 4,
an Arduino, two joysticks, six buttons, and a 1024 x 600 display.

## Current status

**Learning project, not a complete fighting game.** `game/` contains an
animation-preview scene and a two-fighter test arena. The user-written
`fighter.gd` script implements keyboard movement, jumping, animation selection,
punch animation, and opponent-facing logic. Both fighters use the same Fighter
scene, with different artwork and input settings.

Punches currently animate only: damage, health, rounds, and dodge gameplay are
not implemented. No firmware, input bridge, or startup services have been
created. Raspberry Pi and physical controller behavior remain unverified.

## Download and open

1. Download this repository using **Code -> Download ZIP**, then extract it.
   Alternatively, clone it:

   ```sh
   git clone https://github.com/flet-pro/AoE_fighter_game.git
   ```

2. Install [Godot 3.6.3](https://godotengine.org/download/archive/3.6.3-stable/).
   Use **Godot 3**, not Godot 4.
3. In Godot's Project Manager, click **Import** and select
   `game/project.godot` inside the downloaded folder.
4. Open the project and wait for its images to import.
5. Open `scenes/FighterTest.tscn` and press **F6** to run the test arena.
   On a Mac, **Fn + F6** may be needed. Press **F8** to stop.

**F5 runs AnimationPreview**, which is still the project's main scene.
Run FighterTest rather than Fighter alone: its instances supply the input
actions and opponent references.

### Keyboard controls

| Player | Move left / right | Jump | Punch animation |
| --- | --- | --- | --- |
| Black | A / D | W | E |
| Red | Left / Right arrows | Up arrow | O |

The Godot application, generated import cache, local credentials, exports,
and duplicate original artwork ZIP are not included. The unpacked original
artwork is included under `AoE Animation/`; imported game artwork is under
`game/assets/`. Godot recreates its import cache on first opening.

The source and setup were reviewed for this upload, but a fresh-download GUI
playthrough has not been verified. Existing guide/checklist notes may describe
an earlier learning stage; the scenes and scripts show the current work.
Check the artwork's original license before redistributing or reusing it;
this repository does not add a new artwork license.

The official Godot 3.6.3 macOS build is in ignored `.tools/godot-3.6.3/`.
Its archive checksum and application signature were verified; it was not
installed system-wide. Original uploaded animation files were left unchanged.

**Tutoring preference:** Explain small steps and let the user write the game.
Do not add implementation code unless explicitly asked.

The development process borrows ECC's plan, test, review, and verify principles,
but uses original project-specific guidance rather than copying its web stack,
agent catalog, hooks, or full skill library.

## Guidance

| File or skill | Purpose |
| --- | --- |
| [GAME_BUILD_GUIDE.md](GAME_BUILD_GUIDE.md) | Animation-based beginner guide, progress checklist, and next task |
| [AGENTS.md](AGENTS.md) | Shared project constraints and coding rules |
| [aoe-godot-development](.factory/skills/aoe-godot-development/SKILL.md) | Plan and implement Godot 3.6 gameplay slices |
| [aoe-hardware-input](.factory/skills/aoe-hardware-input/SKILL.md) | Design and validate the controller input boundary |
| [aoe-game-verification](.factory/skills/aoe-game-verification/SKILL.md) | Test, review, and report evidence honestly |

In Droid, ask naturally for the matching task or invoke `/aoe-godot-development`,
`/aoe-hardware-input`, or `/aoe-game-verification`. Check `/skills` for discovery;
start a new session in AOE if the project skills do not appear. These files do
not install Godot, Python packages, Arduino tools, or external services.

## Proposed implementation order

Use [GAME_BUILD_GUIDE.md](GAME_BUILD_GUIDE.md) for the detailed, animation-based
steps and progress checklist. The current learning focus is hurtbox/hitbox
detection, followed by damage and health. Checklist items remain unchecked
until their completion criteria are verified; file creation alone is not
evidence of a working game.

The high-level proposal below is not authorization to implement:

1. Create the project and preview existing animations; verify a minimal scene on the Pi/display early.
2. Build two fighters using the uploaded art, with keyboard movement and jumping.
3. Add a strike, dodge, hit detection, health, and fair simultaneous hits.
4. Complete a round with countdown, timeout, result, and restart.
5. Connect physical controls after identifying the Arduino and wiring.
6. Expand animations and add audio, then verify cabinet reliability.

The proposed software split is input routing, fighter movement, combat, match/UI,
presentation, and hardware integration. Prefer one reusable fighter scene and a
shared player-command interface for keyboard and cabinet controls.

## Decisions to settle before the relevant work

- Arduino model, joystick type, pin assignments, and approved wiring.
- Raspberry Pi OS architecture, Godot runtime/export, and launch method.
- Physical button order and whether joystick vertical movement is used.
- Round length, health, attack timings, dodge rules, ties, and restart behavior.
- Godot 3.6-compatible test runner and project layout.
- Input transport and protocol. USB serial with a Python-to-loopback-UDP bridge
  is proposed, not locked in.

## Run and test

Follow **Download and open** above on another computer. On the original
development machine only, the ignored local Godot download can also be opened
from the AOE directory:

```sh
./.tools/godot-3.6.3/Godot.app/Contents/MacOS/Godot --editor --path ./game
```

In the editor, open `scenes/FighterTest.tscn`. Press **F6** to run that
scene, **F5** to run the project's AnimationPreview scene, and **F8** to stop.
On a Mac, the Fn key may also be needed. The preview now has a user-written
script; its earlier agent-written controller was removed.

### Running your own `.gd` files

Most game scripts extend a node type and must be attached to a compatible node:

1. Select the node in the Scene dock.
2. Click **Attach Script** and create or choose your own GDScript file.
3. Save the script and the scene.
4. Run the scene with **F6** and check the Output/Debugger panels.

A `.gd` file is not normally run directly like a Python file. A special script
extending `SceneTree` or `MainLoop`, such as the retained testing helpers, can
instead run through Godot's `--script` option.

### Retained testing helpers

- `game/tests/test_animation_preview.gd`: reference integration tests for the
  removed controller. Currently expected to fail at its missing interface;
  do not restore the controller automatically to make these tests pass.
- `game/tests/capture_animation_preview.gd`: screenshot helper, not gameplay.
  Its rendering check was interrupted and is not verified. Do not use
  `--no-window` with it because it waits for a rendered frame.

For example, run the reference tests from AOE with:

```sh
./.tools/godot-3.6.3/Godot.app/Contents/MacOS/Godot --no-window --path ./game --script res://tests/test_animation_preview.gd
```

No firmware or Pi checks have been completed. Keep desktop, Pi, and physical
controller validation separate. There are no configured lint or export gates.

## References

- [Godot 3.6 documentation](https://docs.godotengine.org/en/3.6/)
- [Factory project instructions](https://docs.factory.ai/harness/agents-md)
- [Factory skills](https://docs.factory.ai/harness/skills)

# Art of Engineering: tabletop fighting game

Team **ok with anything**: Petewat Chaoha, Cara Cong, Seisen Fu,
Jun Hong Lim, and Ethan Zhang.

A local two-player learning project using **Godot 3.6.3**. Planned hardware:
a Raspberry Pi 4, Arduino, two joysticks, six buttons, and a 1024 x 600 display.

## Current status

The project contains an animation preview and a two-fighter test arena.
Both fighters use the same Fighter scene and script, with different artwork
and keyboard controls. Movement, jumping, punch animation, and opponent-facing
logic are implemented.

**This is not a complete fighting game.** Punches animate but do not cause
damage. Health, rounds, dodge gameplay, and hardware input are not implemented.
Raspberry Pi and physical controller behavior remain unverified.

## Download and run

1. Use **Code -> Download ZIP** on GitHub and extract the download, or clone:

   ```sh
   git clone https://github.com/flet-pro/AoE_fighter_game.git
   ```

2. Install [Godot 3.6.3](https://godotengine.org/download/archive/3.6.3-stable/).
   Use **Godot 3**, not Godot 4.
3. In Godot's Project Manager, click **Import** and select `game/project.godot`.
4. Open the project and wait for its images to import.
5. Open `scenes/FighterTest.tscn` and press **F6** to run the test arena.
   On a Mac, **Fn + F6** may be needed. Press **F8** to stop.

**F5 runs AnimationPreview**, which is still the project's main scene.
Run FighterTest rather than Fighter alone: the test scene supplies each
fighter's input actions and opponent reference.

## Keyboard controls

| Player | Move left / right | Jump | Punch animation |
| --- | --- | --- | --- |
| Black | A / D | W | E |
| Red | Left / Right arrows | Up arrow | O |

## Included files

- `game/project.godot`: Godot project settings and input actions.
- `game/scenes/`: fighter, test arena, animation preview, and game scripts.
- `game/animations/`: black and red SpriteFrames resources.
- `game/assets/`: artwork used by the game, including its import settings.

Godot itself is not bundled. Godot regenerates its import cache when the
project is first opened. Factory skills, learning guides, original unused
artwork, test helpers, credentials, and local downloads are not part of the
current published files.

## Validation and artwork

Published project-resource references were checked. A fresh-download GUI
playthrough, Raspberry Pi behavior, and physical controls have not been
verified.

Check the artwork's original license before redistributing or reusing it;
this repository does not add a new artwork license.

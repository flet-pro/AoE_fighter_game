# AOE game build guide

A beginner-friendly plan for building the tabletop fighting game in
**Godot 3.6.3**, based on the uploaded `AoE Animation/` assets.

## Start here in future sessions

Read this guide and `AGENTS.md` before planning the next implementation task.
This is a plan, not evidence that any game feature has been built.
The asset inventory below was checked against the uploaded files.
Gameplay values, controls, and architecture marked as proposals still need
agreement before the relevant implementation.

**Current status:** A Godot 3.6.3 project exists in `game/`, with an animation
preview scene, matching black/red `SpriteFrames` resources, and 68 copied frames
covering idle, walk, punch, dodge, and knockdown. The uploaded originals were
preserved. The official macOS engine was downloaded into ignored `.tools/`;
its SHA-512 checksum and application signature were verified.
The preview controller was removed at the user's request. Only testing scripts
remain. There is no playable game, firmware, or input bridge.

**Learning mode:** The user writes the game themselves. Give explanations and
small editor exercises, not finished code or unrequested scene implementations.
Existing scene/resource files are learning references, not completed gameplay.

**Next task:** Open `game/project.godot` in Godot 3.6.3, inspect
`scenes/AnimationPreview.tscn`, and run it with F6. Select an `AnimatedSprite`,
inspect its Frames resource, and try changing its Animation and Playing
properties yourself. Then learn to attach your own script to a node.
Do not begin combat or Arduino integration at the same time.

**Testing notes:** `game/tests/test_animation_preview.gd` describes the removed
controller and is expected to fail until a compatible controller is deliberately
implemented. It is reference material, not a requirement to copy that design.
`capture_animation_preview.gd` is a retained screenshot helper; capture was
interrupted and has not been visually verified. It needs a rendering window,
so do not invoke that helper with `--no-window`.
An automated editor `--quit` check previously printed a texture resource-cache
error; that editor-only result is unresolved. Do not claim editor validation,
visual rendering, or Pi testing passed based on the earlier controller tests.

### Progress checklist

Only check a step after its completion criteria have been verified. When work
progresses, update this checklist, the next task above, and the README status.
Record relevant commands, test results, blockers, and unresolved decisions.

- [ ] Step 1: Create and run the Godot 3.6.3 project.
- [ ] Early device check: Run a minimal scene on the actual Raspberry Pi/display.
- [ ] Step 2: Preview the initial black fighter animations.
- [ ] Step 3: Prepare matching black and red animation resources.
- [ ] Step 4: Make one fighter stand on solid ground.
- [ ] Step 5: Add keyboard walking and arena boundaries.
- [ ] Step 6: Add jumping with physics-driven animation selection.
- [ ] Step 7: Add the second independent player.
- [ ] Step 8: Add one correctly timed attack.
- [ ] Step 9: Add health, hit reactions, and fair simultaneous hits.
- [ ] Step 10: Add the agreed dodge behavior.
- [ ] Step 11: Complete round flow, HUD, results, and restart.
- [ ] Step 12: Integrate and test the Arduino controls.
- [ ] Cabinet validation: Check performance and repeated matches on the Pi.

## 1. What the animation folder contains

There is enough animation artwork to make the basic game.

| Folder | Contents | Recommended use |
| --- | --- | --- |
| `AoE Animation/Black Guy/PNGs/black/` | 42 animations, 260 frames | Player 1 |
| `AoE Animation/Red Guy/PNGs/red/` | Same 42 animations, plus one duplicate file | Player 2 |
| Each character's `Sheet for Ref/` | Images showing whole animation sequences | Visual reference |
| `AoE Animation/Testing/` | A different character style with different image dimensions | Leave out initially |

All main fighter frames are **256 x 208 pixels**. The representative sequences
checked during inspection have genuine transparent backgrounds.

The included `AoE Animation/README AoE Animation.docx` suggests starting with idle,
jumping, punching, kicking, blocking, hit reactions, and knockdown.

### Two things to watch

1. **There is a duplicate file.**
   `AoE Animation/Red Guy/PNGs/red/roundhouse_kick/00(1).png` is identical to
   `00.png`. Exclude the duplicate when importing that animation.
   There is no need to delete it.
2. **The image size is not the fighter's body size.**
   The idle character occupies roughly 71 x 105 pixels inside the 256 x 208
   image. Most of the image is transparent padding. Collision shapes should
   surround the body, not the entire image.

**Use individual PNGs for animation.** They are easier for a beginner than
cutting up the reference sheets.

The separate `Testing/` set contains ten images: eight are 355 x 354 and two
are 354 x 354. Do not mix these into the matched fighter animations initially.

## 2. Five Godot terms

| Term | Plain-English meaning | Example |
| --- | --- | --- |
| Node | One building block | An image, collision shape, or timer |
| Scene | A saved group of nodes | A complete fighter |
| Instance | A copy of a scene placed in another scene | Player 1 and Player 2 |
| Script | Code controlling behavior | Walking, jumping, taking damage |
| Resource | Reusable data | A collection of animation frames |

A **signal** is a notification between components:

```text
Fighter loses health -> emits health_changed -> health bar updates
```

It is not necessary to understand every Godot feature before starting.

## 3. Choose a small first version

The art contains 42 moves, but the first game does not need 42 mechanics.

Recommended first playable version:

- Walk left and right.
- Jump.
- One straight punch.
- One dodge.
- Take damage.
- Fall down when defeated.
- Health bars, round timer, winner, and restart.

Proposed physical controls:

| Control | Action |
| --- | --- |
| Joystick horizontally | Walk |
| Button 1 | Jump |
| Button 2 | Dodge |
| Button 3 | Strike |

**Leave kicking and blocking for the next version.** They need additional
control rules. Having animations does not require implementing those mechanics.
A later version could use direction + strike for a kick without another button.

## 4. Connect the animations to gameplay

Use these animations first:

| Game situation | Animation folder | Frames | Playback |
| --- | --- | ---: | --- |
| Standing still | `idle` | 8 | Loop |
| Walking | `step_walk` | 8 | Loop |
| Rising during a jump | `jump_ascent` | 2 | Play, then hold |
| Top of the jump | `jump_apex` | 1 | Hold |
| Falling | `fall_descent` | 2 | Play, then hold |
| Touching the ground | `landing` | 4 | Once |
| Strike | `straight_punch` | 8 | Once |
| Dodge | `dodge` | 5 | Once |
| Being hit | `light_hit_high` | 7 | Once |
| Defeated | `knockdown` | 5 | Once, hold final pose |
| Optional defeated resting pose | `ground_impact_downed` | 3 | Hold final pose |

### Why use separate jump animations?

The complete `neutral_jump` sequence has 13 frames. It is useful for previewing
the artwork, but the game must decide when the character is actually rising,
falling, and landing.

Otherwise, the animation might show a landing while the physical character is
still in the air.

```text
Physics decides movement.
The animation shows the current movement.
```

### What does the dodge look like?

The `dodge` sequence looks like a duck/slip rather than a traveling backstep.
A **short stationary dodge** would match that art for the first version.
The game can provide a brief invulnerability window.

For a defense action that moves backward, `backstep_retreat` is available later.
These are recommendations, not locked gameplay rules.

## 5. The six game components

### A. Input system

**Job:** Turn keyboard or Arduino input into simple player commands.

```text
Player 1:
movement = left
jump pressed = no
dodge pressed = no
strike pressed = yes
```

The fighter receives these commands without knowing where they came from.
This makes keyboard development possible before the cabinet exists.

### B. Fighter

**Job:** Own one character's movement, action, health, and animations.

Track:

- Player identity.
- Position and velocity.
- Facing direction.
- Current action.
- Health.
- Time remaining in an action.
- Whether another action is allowed.

**Build one fighter scene and use it twice.**
Do not create separate red and black gameplay scripts.

### C. Combat

**Job:** Decide whether attacks connect and what happens afterward.

Handle attack timing, reach, hit detection, damage, knockback, invulnerability,
simultaneous attacks, and preventing repeated damage from one punch.

### D. Arena

**Job:** Provide the place where the fight happens.

Start with a background color, ground surface, left/right boundaries, and two
starting positions.

The dark fighter is difficult to see against black. Start with a light or
medium-light background.

### E. Match controller

**Job:** Run the round.

```text
Ready -> Countdown -> Fighting -> Result -> Restart
```

Handle round start, enabling/disabling controls, the round timer, knockout,
timeout, winner/draw, and resetting everything.

### F. HUD

HUD means information displayed over the game:

- Player 1 health.
- Player 2 health.
- Time remaining.
- Countdown.
- Winner message.
- Eventually, controller connection status.

**The HUD displays game state. It does not decide combat rules.**

## 6. The Godot scenes to build

These use **Godot 3.6 node names**, not Godot 4 names.

### Fighter scene

```text
Fighter -- KinematicBody2D
|-- BodyCollision -- CollisionShape2D
|-- Visuals -- Node2D
|   `-- AnimatedSprite
|-- Hurtbox -- Area2D
|   `-- CollisionShape2D
`-- Hitbox -- Area2D
    `-- CollisionShape2D
```

Three different collision concepts:

- **Body collision:** Stops the fighter falling through the floor or walking
  through solid objects.
- **Hurtbox:** The area where the opponent can hit this fighter.
- **Hitbox:** The area where this fighter's attack can hit the opponent.

**A drawn fist does not automatically cause damage.**
The hitbox creates that connection.

### Arena scene

```text
Arena -- Node2D
|-- Background -- Polygon2D
|-- Floor -- StaticBody2D
|   `-- CollisionShape2D
|-- LeftWall -- StaticBody2D
|   `-- CollisionShape2D
|-- RightWall -- StaticBody2D
|   `-- CollisionShape2D
|-- Player1Spawn -- Position2D
`-- Player2Spawn -- Position2D
```

### Match scene

```text
Match -- Node2D
|-- Arena
|-- Player1 -- Fighter instance
|-- Player2 -- Fighter instance
|-- CombatResolver -- Node
|-- MatchController -- Node
`-- HUD -- CanvasLayer
    `-- Interface -- Control
        |-- Player1Health -- ProgressBar
        |-- Player2Health -- ProgressBar
        |-- RoundTimer -- Label
        `-- Announcement -- Label
```

Start here. Character selection and a complicated main menu are unnecessary yet.

## 7. Step-by-step build order

### Step 1: Create the Godot project

**Goal:** Open an empty game successfully.

1. Open Godot **3.6.3**.
2. Create a new project inside a proposed `AOE/game/` directory.
3. Choose **GLES2** as the renderer.
4. Open **Project -> Project Settings**.
5. Under **Display -> Window**, set the base width to `1024` and height to `600`.
6. Use stretch mode `2d` and aspect `keep`.
7. Create a basic scene and run it.

A separate game folder avoids importing the uploaded ZIP and reference
material as game assets. Copy the selected animation PNGs into the game project
when needed; preserve the original upload.

**Done when:** A correctly sized game window opens without errors.

Also try a minimal scene on the actual Pi early. Do not finish the desktop game
before discovering whether deployment works.

### Step 2: Make an animation preview

**Goal:** See the artwork moving before adding gameplay.

Create a temporary scene:

```text
AnimationPreview -- Node2D
`-- AnimatedSprite
```

In the editor:

1. Select `AnimatedSprite`.
2. In the Inspector, find **Frames**.
3. Choose **New SpriteFrames**.
4. Click the new resource to open the animation panel.
5. Rename `default` to `idle`.
6. Add the black fighter's `idle/00.png` through `07.png`, in order.
7. Enable looping.
8. Start at **8 FPS**.
9. Enable **Playing** to preview it.

Then add `step_walk`, `straight_punch`, `dodge`, and `knockdown`.

Suggested preview speeds:

| Animation | Starting speed |
| --- | ---: |
| Idle | 8 FPS |
| Walk | 12 FPS |
| Punch | 16 FPS |
| Dodge | 18 FPS |
| Knockdown | 10 FPS |

These are starting points to adjust by eye, not required values.
Attack, dodge, hit, and knockdown animations should not loop.

**Done when:** Each animation previews in the correct order.

Do not add all 42 animations yet.

### Step 3: Prepare both fighters' animation resources

**Goal:** Use the same animation names for both colors.

Create two saved `SpriteFrames` resources:

```text
black_frames.tres
red_frames.tres
```

Both should contain matching animation names. The fighter script can then
request `straight_punch` without knowing whether its fighter is red or black.

Animation data can be shared, but each fighter needs its own health, velocity,
action timers, and other runtime state.

**Done when:** Changing the frame resource changes appearance without changing
behavior.

### Step 4: Build a fighter standing on the floor

**Goal:** One animated character stands on solid ground.

1. Create `Fighter.tscn` using the fighter tree above.
2. Set the fighter's origin near its feet.
3. Add a simple rectangular body collision.
4. Create the arena floor.
5. Add gravity and floor collision behavior.

#### Aligning this artwork

The idle images have their feet near image Y = `184`.
With a centered 256 x 208 sprite, an initial sprite position around **`(0, -80)`**
places those feet near the fighter's origin.

This is a starting alignment to inspect, not a guarantee for every pose.
Do not crop every frame separately. Consistent canvases prevent animation
frames from shifting the character unexpectedly.

Start at 1x scale. Enlarge visuals later if needed and adjust collision shapes
to match.

**Done when:** The fighter falls onto the floor and stays there, with its feet
visually touching the ground.

### Step 5: Add keyboard movement

**Goal:** Walk before worrying about physical controls.

Under **Project -> Project Settings -> Input Map**, create actions:

| Action | Player 1 key | Player 2 key |
| --- | --- | --- |
| Left | A | J |
| Right | D | L |
| Jump | W | I |
| Dodge | Q | U |
| Strike | E | O |

Use separate action names, such as `p1_left` and `p2_left`.

Implement left/right movement, no movement while neutral, idle while stationary,
walk animation while moving, and arena boundaries.

**Done when:** The fighter walks across the arena without falling through it or
leaving it.

### Step 6: Add jumping

**Goal:** The fighter jumps physically and the animation follows.

1. Jump only when grounded.
2. Apply upward velocity once when jump is pressed.
3. Let gravity pull the fighter down.
4. Select `jump_ascent`, `jump_apex`, or `fall_descent` based on vertical movement.
5. Detect floor contact and play `landing`.
6. Return to idle or walking.

In Godot 2D coordinates, **negative Y is upward**.
Do not move the fighter upward with an animation position track.
Movement belongs to physics.

**Done when:** The fighter jumps while standing or walking, cannot jump
infinitely, and lands consistently.

### Step 7: Add the second player

**Goal:** Two independent fighters share the arena.

1. Instance `Fighter.tscn` twice.
2. Assign player identities.
3. Give one black frames and the other red frames.
4. Place them at different spawn positions.
5. Connect each to its own input actions.
6. Make them face one another.
7. Configure body collision so they do not walk through each other.

Use sprite `flip_h` for visual direction. Attack offsets must follow facing too.

**Done when:** Both players move and jump simultaneously without controlling
each other.

If certain simultaneous key combinations fail, check keyboard ghosting as well
as the game code.

### Step 8: Add one attack

**Goal:** A punch hits the opponent once.

The eight-frame `straight_punch` can initially be divided like this:

| Frames | Phase | Damage possible? |
| --- | --- | --- |
| `00-02` | Wind-up | No |
| `03-04` | Extended punch | Yes |
| `05-07` | Recovery | No |

At 16 FPS, the visual sequence lasts about **0.5 seconds**.
This is a first tuning pass. Define attack windows explicitly in combat logic
and keep visuals aligned with them.

1. A new strike press starts an attack.
2. The fighter cannot start another attack during recovery.
3. Activate the hitbox only during the active window.
4. Register a hit if it overlaps the opponent's hurtbox.
5. Mark that opponent as already hit by this attack.
6. Disable the hitbox when the active window ends.

Holding strike must not create a new punch every physics tick.

**Done when:** One punch causes at most one hit, misses remain misses, and the
fighter cannot hit itself.

### Step 9: Add health and hit reactions

**Goal:** Attacks have consequences.

Implement:

- Maximum and current health.
- Damage.
- `light_hit_high`.
- Brief loss of control after a hit, called **hitstun**.
- Optional small knockback.
- A notification when health changes.

Resolve both players' valid hits for a physics tick before applying outcomes,
so simultaneous attacks can trade fairly.

**Done when:** Both players damage one another, without the outcome unfairly
depending on which fighter updates first.

### Step 10: Add dodge

**Goal:** Give players a defensive action.

For the proposed stationary dodge:

1. A new dodge press starts `dodge`.
2. Prevent attacking during the dodge.
3. Give only the middle part a short invulnerability window.
4. End the action and return to idle.
5. Apply a cooldown so dodge cannot be held forever.

**Invulnerability prevents damage, not floor collision.**

**Done when:** Correctly timed dodges avoid attacks and mistimed dodges can still
be hit.

### Step 11: Add round flow and the HUD

**Goal:** Turn mechanics into a complete game.

```text
Countdown
    |
Players can fight
    |
Knockout or timeout
    |
Show result and stop accepting fight input
    |
Restart
```

Choose and record starting health, round length, timeout winner rule, draw rule,
and simultaneous knockout rule.

When health reaches zero:

- Play `knockdown`.
- Hold the defeated pose.
- Do not automatically play `get_up`.

On restart, reset health, positions, velocity, facing, action state, cooldowns,
active hitboxes, pending button presses, and the round timer.

**Done when:** Several complete rounds can be played without restarting Godot.

### Step 12: Connect the Arduino

**Goal:** Replace the keyboard input source without rewriting the fighter.

Proposed path:

```text
Buttons and joysticks
        |
Arduino
        | USB serial
Python bridge on Pi
        | Local input messages
Godot input router
        |
The same fighter commands used by the keyboard
```

Identify the Arduino model and actual wiring before this work.

Test physical input independently first:

- Display joystick direction.
- Display each button's pressed state.
- Check both players simultaneously.
- Check quick presses and held buttons.
- Unplug and reconnect the Arduino.

Then connect those commands to gameplay.

**Done when:** Both players finish a round using the cabinet, and disconnecting
the controller cannot leave a fighter moving forever.

## 8. Use a simple state machine

A **state machine** means the fighter has one main action state at a time.
One state per animation is unnecessary.

Start with:

```text
IDLE
WALK
AIRBORNE
ATTACK
DODGE
HITSTUN
KO
```

- `AIRBORNE` displays ascent, apex, or descent.
- `ATTACK` can later display a punch or kick.
- `KO` displays knockdown and then holds the downed pose.

This prevents bugs such as a defeated player starting a punch by pressing strike.

**A state decides what is allowed. An animation decides what it looks like.**

## 9. Save the remaining animations for later

| Expansion | Existing assets |
| --- | --- |
| Second attack | `side_kick`, `heavy_cross`, `hook` |
| Blocking | `standing_block`, `crouch_block`, `air_guard` |
| Faster movement | `run`, `dash_forward`, `backstep_retreat` |
| Crouching | `crouch_idle`, `crouch_move` |
| Air attacks | `jumping_attack`, `jumping_kick` |
| Low attacks | `low_punch`, `low_kick`, `sweep` |
| Advanced attacks | `uppercut`, `launcher`, `roundhouse_kick`, `spinning_kick` |
| Knockdown recovery | `knockback`, `heavy_hit_reaction`, `get_up` |

Do not implement complicated combos just because frames exist.

## 10. Suggested five-person split

| Responsibility | Deliverable |
| --- | --- |
| Animation and visuals | Matching frame resources, alignment, readable arena |
| Movement and input | Walking, jumping, facing, keyboard commands |
| Combat | Attack timing, hitboxes, damage, dodge |
| Match and UI | Countdown, health bars, timer, results, restart |
| Hardware and Pi | Arduino input, bridge, deployment, cabinet testing |

Agree on fighter/input interfaces before working independently.

## First practical target

**Only do Steps 1-3 first:** Create the project and preview both characters'
idle, walking, punching, and dodge animations.

This teaches the animation workflow without adding physics, combat, or hardware
at the same time.

## Godot 3.6 references

- [Animating individual PNG frames](https://docs.godotengine.org/en/3.6/tutorials/2d/2d_sprite_animation.html)
- [Movement with KinematicBody2D](https://docs.godotengine.org/en/3.6/tutorials/physics/using_kinematic_body_2d.html)

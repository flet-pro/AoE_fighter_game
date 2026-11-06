# AOE project guidance

## Product and scope

AOE is a two-player tabletop fighting game for team "ok with anything".
Godot **3.6.3** runs graphics and gameplay on a Raspberry Pi 4 Model B.
An Arduino reads two joysticks and six buttons. The display is 1024 x 600.
Each player needs movement, jump, dodge, and strike, with custom animations.

This workspace contains guidance, a Godot animation-preview scene/resources,
and testing helpers. The preview controller was removed at the user's request.
There is no playable fighting game, serial bridge, or cabinet deployment.

## Learning-first policy

The user wants to learn by building the game themselves. Default to tutoring:
explain one small step, its purpose, and how to check it, then let the user do it.
Do not create or edit game scripts, supply complete implementations, or build
additional scenes/resources on their behalf unless explicitly asked to do so.
Existing testing-only scripts may stay. Ask before adding new testing helpers.
Never treat a request for the next learning step as permission to write code.

## Confirmed requirements versus proposals

- Keep Godot 3.6.3; do not migrate to Godot 4 without approval.
- Proposed first slice: one arena, two identical fighters with different colors,
  keyboard input, basic combat, health, a round timer, and restart.
- Proposed cabinet controls: horizontal joystick movement and three buttons per
  player for jump, dodge, and strike.
- Proposed hardware path: Arduino USB serial -> Python bridge -> Godot over
  loopback UDP. Confirm the board and transport before implementation.
- Health, damage, timings, round length, tie rules, dodge behavior, and button
  mapping are design choices, not approved final values. Record agreed choices
  in the README as implementation proceeds.
- No online multiplayer, AI opponent, web backend, accounts, or database unless
  separately requested. Do not add combos before the basic fight works.

## Development workflow

1. Read `GAME_BUILD_GUIDE.md` for the asset-based plan, progress checklist, and
   next task, then read relevant code and load the matching local skill.
   Keep the guide's checklist and next task current after verified progress.
2. For a substantial feature, propose a small vertical slice with acceptance
   criteria, affected files, risks, and validation. Resolve blocking decisions
   before coding; get approval for consequential architecture changes.
3. Check official Godot **3.6** documentation for version-sensitive APIs.
   Prefer existing project patterns and dependencies over new infrastructure.
4. Write focused tests before changing testable gameplay or protocol behavior.
   Verify a new test fails for the expected reason, implement, then refactor.
5. Run the relevant checks and review the diff for correctness and scope.
   Report passed, failed, skipped, and unavailable checks separately.

Do small tasks inline. Delegate only substantial independent work when useful
and supported by the session. Agent profile files do not create callable agents.

## Godot conventions

- Use Godot 3.x APIs: `KinematicBody2D`, `AnimatedSprite`, `PoolByteArray`,
  `export var`, and `onready var`. Do not paste Godot 4 equivalents.
- Prefer typed GDScript where it clarifies contracts. Use snake_case for script
  files, functions, and variables; PascalCase for named types.
- Keep movement/combat in `_physics_process(delta)`, initially at 60 physics
  ticks per second. Separate animation presentation from authoritative rules.
- Reuse one fighter scene for both players, with explicit player identity.
- Keep input acquisition separate from fighter logic and retain keyboard input.
- Use signals for health and match notifications, not UI lookups inside fighters.
- Prefer pure functions for rules and parsing. Mutable node transforms, velocity,
  and timers are normal engine state; do not copy the entire scene each tick to
  satisfy a blanket immutability rule.
- Start with simple 2D visuals and GLES2. Measure on the actual Pi before making
  performance claims. Confirm runtime/export architecture matches the Pi OS.
- Treat `.import/` and export output as generated. Do not hand-edit them.
  Preserve intentional asset import settings and editable source artwork.

## Safety and project boundaries

- Work inside AOE. Do not modify sibling projects, including DockScheduling.
- Never overwrite user changes, commit, push, flash a board, change system
  services, or install dependencies without appropriate user authorization.
- Bound and validate serial/network input; never execute input as code.
- Bind a local input bridge to loopback, not all network interfaces.
- Do not assume a specific Arduino, serial device path, pin layout, voltage,
  USB HID capability, or availability of physical hardware.
- Skill files provide instructions, not installed software or permissions.

## Reusable workflows

- `.factory/skills/aoe-godot-development/SKILL.md`: gameplay and scene changes.
- `.factory/skills/aoe-hardware-input/SKILL.md`: Arduino/Python/input transport.
- `.factory/skills/aoe-game-verification/SKILL.md`: tests, review, and Pi checks.

## Commands and completion evidence

The README documents how to open the local Godot 3.6.3 editor and run the scene.
The engine is stored in ignored `.tools/`, not installed system-wide.
`game/tests/test_animation_preview.gd` is retained as reference testing code for
the removed controller; it currently fails at the missing controller interface.
Do not present that as a regression to fix by restoring code against the user's
wishes. GUI rendering and Raspberry Pi behavior remain unverified.
Do not invent commands or treat an empty test suite as success.
Choose a test runner explicitly compatible with Godot 3.6 before adding tests.
Use pytest for a future Python bridge if adopted; use Arduino tooling only after
the board identifier is known. Do not use browser Playwright tests as evidence
that a native Godot game or physical controls work.

Add regression tests for behavior changes. Aim for strong coverage of combat,
round rules, and parsers, but report a percentage only when measured by an
appropriate tool. Actual Pi and hardware checks remain separate requirements.

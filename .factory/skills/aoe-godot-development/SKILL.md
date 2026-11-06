---
name: aoe-godot-development
description: Plan and implement AOE gameplay, fighter scenes, combat, animations, or match UI in Godot 3.6.3. Use for game development changes, not Arduino transport work or a request for guidance only.
---

# AOE Godot development

## Establish scope

1. Read the project `AGENTS.md`, README, and affected code. Do not assume that
   proposed scenes, values, or tools already exist.
2. State the requested player-visible behavior and acceptance criteria.
3. Resolve gameplay decisions needed for this slice. For larger work, identify
   affected files, interfaces, risks, and validation before implementation.
4. Verify version-sensitive APIs in official Godot 3.6 documentation. Godot 4
   examples are not drop-in replacements. Do not silently upgrade the engine.

## Implement a small vertical slice

- Keep input routing, fighter state, combat resolution, match flow, and HUD
  responsibilities separate. Do not add a backend or generic framework.
- Use one reusable `KinematicBody2D` fighter scene. Give each instance a player
  ID, opponent reference through a clear interface, and its own runtime state.
- Pass normalized player commands into gameplay; never open a serial port from
  a fighter. Keep keyboard input available without connected hardware.
- Put movement and rule timing on the physics tick, not rendered animation FPS.
- Represent action restrictions explicitly: idle/walk, airborne, attack, dodge,
  hitstun, and KO as appropriate. Define priority for simultaneous action inputs.
- Separate body collision, hurtboxes, and active attack hitboxes. Configure
  collision layers/masks deliberately and exclude self-hits.
- Give each attack an identity and track targets hit so overlap cannot deal
  damage every tick. Keep startup, active, and recovery windows explicit.
- Collect valid hits for a tick before applying their outcomes when attacks can
  trade. Test fairness when fighter processing order is reversed.
- Define facing and whether it locks during actions. Reflect visuals/hitbox
  offsets deliberately rather than blindly applying negative scale to physics.
- Dodge invulnerability must not disable floor or wall collision.
- Keep authoritative attack windows independent of artwork frame counts.
- Restrict gameplay to the active round. Restart must clear health, transforms,
  velocities, action state, cooldowns, active hits, and pending input edges.

## Testing and finish

Write failing behavior tests before implementation where practical, using the
adopted Godot 3.6-compatible runner. Keep timing/rule calculations testable
without rendering. Add regression tests for bugs rather than only screenshots.

Use `aoe-game-verification` for the relevant checks. Review the diff for shared
state between fighters, frame-rate dependence, duplicate hits, stale input, and
unrequested features. Do not invent commands if scaffolding is absent.

Report the behavior implemented, files changed, checks actually run, and
remaining decisions or hardware validation. A working desktop scene does not
prove Raspberry Pi performance or cabinet input latency.

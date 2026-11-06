---
name: aoe-game-verification
description: Verify or review AOE Godot 3.6.3 gameplay, Python input bridging, Arduino firmware, and Raspberry Pi readiness. Use after implementation or when testing is requested; keep this workflow read-only unless fixes are authorized.
---

# AOE game verification

## Establish available checks

Read `AGENTS.md`, the README, changed files, and test configuration. Identify the
installed executable versions and documented commands before running checks.
If the workspace still contains guidance only, validate Markdown links and skill
metadata; report game, firmware, and hardware checks as not applicable.

Do not install dependencies, download test frameworks, flash a board, or change
the Pi to make this workflow run without authorization. Missing tools are
blockers or skipped checks, not passing results.

## Run the narrowest relevant checks

| Area | Evidence to collect when implemented |
| --- | --- |
| Godot | Version is 3.6.3; project imports/parses; focused tests pass with a 3.6-compatible runner; changed scene runs |
| Gameplay | Deterministic rule tests plus manual checks for collisions, animations, and two-player interaction |
| Python | Focused pytest tests; Ruff/type checks only if adopted/configured; parser and reconnect tests with synthetic input |
| Arduino | Compilation for the confirmed board; host-side logic tests where feasible; physical input checks separately |
| Raspberry Pi | Correct OS/runtime/export architecture; game on actual 1024 x 600 display; measured frame times and input response |

Browser Playwright tests are not native Godot tests. Engine import, a headless
test run, or compilation alone does not prove visual or physical correctness.
Do not invent a coverage percentage or treat test discovery of zero tests as a pass.

## Gameplay regression checklist

Select relevant items; document skips instead of claiming the whole list passed.

- Both players move independently and simultaneously with the selected controls.
- Gravity, jumping, arena boundaries, and body separation work at the edges.
- Each strike hits the opponent at most once and only during its active window.
- Holding an action button does not repeat a press unless repetition is intended.
- Hitstun/KO/action restrictions work; facing changes do not break hitboxes.
- Dodge blocks damage only during the agreed window, not physical collisions.
- Simultaneous hits can trade fairly; simultaneous KO has the agreed outcome.
- Countdown, active fight, timeout, results, and restart follow the agreed rules.
- Restart clears pending actions, cooldowns, active hitboxes, movement, and health.
- Disconnect neutralizes input and applies the agreed pause/resume policy.

## Pi and cabinet checks

Run only when the device is available and the action is authorized.

- Test the same engine version and intended renderer on the real Pi.
- Measure frame time, physics load, and input responsiveness during a fight.
  State the measurement method and conditions; do not infer latency from FPS.
- Check HUD readability, aspect ratio, and clipping on the actual display.
- Exercise simultaneous controls, quick taps, neutral joystick drift, repeated
  rounds, unplug/reconnect, and loss of the input bridge.
- Check repeated matches for accumulating nodes, timers, or memory growth.
- Validate any approved auto-start separately from launching the game manually.

## Review and report

Inspect the final diff for Godot 4 APIs, self/duplicate hits, physics-order bias,
frame-dependent rules, unbounded queues, stale input, unintended dependencies,
secrets, and changes outside AOE. For review-only requests, report actionable
findings without silently applying fixes.

Finish with:

1. Scope and behavior checked.
2. Exact commands and their outcomes.
3. Manual checks and the machine/device actually used.
4. Failures, unavailable tools, and skipped checks with reasons.
5. Measured coverage/performance only, plus remaining release blockers.

Fix failures only when requested or within an authorized implementation task,
then rerun affected checks. Do not commit, publish, or deploy from this workflow.

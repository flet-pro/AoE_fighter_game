---
name: aoe-hardware-input
description: Design or change AOE Arduino controls, Python serial bridging, input protocols, or Godot hardware input routing. Use for joystick/button integration and disconnect handling, not general gameplay or unapproved hardware changes.
---

# AOE hardware input

## Confirm the boundary first

Read `AGENTS.md`, the README, and any existing input code. Identify the actual
Arduino, joystick type, pin map, serial interface, and Pi OS before selecting
board-specific behavior. Do not assume USB keyboard/gamepad emulation works.
Do not flash firmware, change wiring, or install startup services unless asked.

The proposed path is Arduino USB serial -> Python -> loopback UDP -> Godot.
Preserve an existing approved transport; discuss a change before replacing it.
Game rules belong in Godot, not firmware or the forwarding bridge.

## Specify a contract before coding

Document these choices alongside the implementation:

- Protocol version, field order/types, player IDs, framing, and size limits.
- Horizontal direction range, button mapping, and held versus press semantics.
- Sampling/send frequency, baud rate, and a worst-case message bandwidth check.
- Sequence ordering, wraparound, reconnect/session reset, and stale-input rules.
- Joystick calibration/dead zone and hysteresis; nonblocking button debounce.
- Disconnect timeout and pause/resume behavior, including a neutral-control
  handshake to prevent accidental actions after reconnect.

Prefer complete, bounded snapshots with explicit freshness over ambiguous
movement-only messages. Define how brief presses survive buffering; increasing
send frequency alone does not guarantee that every button edge is preserved.
Do not invent a final protocol or timeout from earlier example values.

## Implementation checks

### Arduino

- Sample both players without blocking `delay()` calls in the input loop.
- Debounce each button independently and normalize hardware-specific readings.
- Send fresh snapshots while idle so disconnect detection remains possible.
- Keep buffers bounded and avoid unnecessary dynamic allocations on small boards.
- Use wrap-safe elapsed-time and counter comparisons.

### Python bridge

- Handle partial serial reads, multiple lines, invalid bytes, malformed fields,
  and oversized messages without blocking forever or growing buffers unbounded.
- Validate field count, version, IDs, ranges, and button masks before forwarding.
- Handle read/open failures and bounded reconnect attempts with useful status.
- Never re-stamp a cached snapshot as fresh after serial input stops.
- Bind/send only on loopback for local input. Do not expose a public listener.
- Keep parsing independently testable with fixture bytes and injected time.

### Godot

- Use Godot 3.6 APIs and nonblocking packet polling, not a blocking wait in a
  frame callback. Validate packets even if the Python bridge also validates.
- Drain queued packets with a bounded policy. Retain valid action edges across
  intermediate snapshots; consume each press once on a physics tick.
- Track held movement separately from jump/dodge/strike press events.
- Keep player identities separate and select input sources explicitly.
- Measure freshness from valid source activity. On timeout, neutralize controls
  and apply the agreed match pause policy. Do not allow stuck movement.
- Define a local bridge session/reset mechanism for sequence tracking; do not
  permanently reject input merely because an Arduino counter restarted.
  Reject queued input from the previous session when reconnecting.

## Evidence

Test parsers and routing with synthetic input before hardware integration.
Cover split/combined messages, invalid/oversized input, duplicates, stale and
out-of-order snapshots, counter restart/wrap, quick taps, held buttons, both
players at once, unplug, reconnect, and neutral resume.

Compile for the identified board when tooling is available. Report compilation,
simulated transport tests, and actual hardware tests separately. Do not claim
debouncing, wiring, or latency has been verified without the physical controls.

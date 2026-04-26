# UI Roadmap — Seismic Shifts

Status: planning. Drawing dated 2026-04-26 — see
[`ui-sketch-2026-04-26.png`](./ui-sketch-2026-04-26.png) in this folder.

This plan captures the four elements introduced in Ravi's hand sketch and
reconciles them with the original
[`seismic-spec.md`](https://github.com/ravivasavan/seismic-shifts) Phase 1 build that
is currently shipping in the repo. None of this is implemented yet —
this is a to-do for Ravi to continue working through, not a fully
specified change.

---

## What the sketch adds beyond Phase 1

The current Phase 1 prototype is a single-line trace, full-screen, no
typography, no scale, no history. The sketch evolves it into four
distinct elements:

1. **Active trace (top, ~70% of screen height).** Shows the last
   **15 minutes** of acoustic energy, scrolling left. Right edge is
   "now." No interactivity — cannot be paused, scrubbed, or zoomed.
2. **Y-axis scale (left).** **0 to 120 dB SPL.** Human-world numbers,
   not digital reference. Full 0–120 range shown as instrument
   provenance; actual readings sit in a narrower band (≈ 30–80 dB)
   depending on the room.
3. **Timestamp (lower-left, near baseline).** Live, real date and
   time. Format: `YYYYMMDD HH:MM:SS:CS` — date with no separators,
   time including centiseconds. The CS field updates every 10 ms.
   Anchors the trace to the present moment as fact.
4. **Compressed history strip (bottom, ~10–15% of screen height).**
   The entire show-so-far, day one to now, compressed into a single
   horizontal strip. An orange viewport indicator marks where the
   active 15-minute window sits within the full timeline. Updates as
   the show progresses; on day one nearly empty, on day fourteen full.
   No interactivity on the strip either — it is a record, not a
   control.

---

## Reconciliation with the original spec

Where this confirms the spec:

- Single trace, no interactivity, no settings, no modes — all
  preserved.
- Cream + near-black palette, instrument typography, scale ticks
  with dB labels — direct continuation of Phase 3.
- Recording (Phase 1.5) becomes a prerequisite, since the history
  strip needs persistent data across launches.

Where this departs from the spec:

| Element | Spec said | Sketch says | Implication |
|---|---|---|---|
| Scroll rate | "1 sample/sec → ~45 min per screen" with options for slower (up to ~7.5 h) | **15 min** per screen | Faster than the spec's preferred direction. Ravi to decide. |
| dB scale | `-60` to `-20` dB FS, internal 0–1 normalisation | **0 to 120 dB SPL** displayed | Requires an FS → SPL calibration offset. iPad mic isn't lab-calibrated; we'll pick a defensible default. |
| Time on screen | Header has running clock at `HH:MM:SS` | **`YYYYMMDD HH:MM:SS:CS`** with centiseconds | Date is now part of the visible UI. CS updates 100×/s — fine on 120 Hz ProMotion but a deliberate choice. |
| History | Spec: "viewer experiences ephemerality" | **History strip is shown to viewer** | Major conceptual shift — the work is now also a record visible inside the work. Worth a sit-down on whether this conflicts with the spec's claim that *the viewer experiences ephemerality, the artist retains the record*. |

The last point in particular is worth pausing on before building. The
spec is emphatic that ephemerality is the viewer's experience and the
recording is the artist's private retention. Putting the show-so-far
on screen makes the record viewer-visible. That may be exactly what
Ravi wants now, or it may be a drift to challenge. Flag it explicitly
when picking this up tomorrow.

---

## To-do

Loosely ordered by what enables what. Pick whichever order makes
sense to work through.

### A. Persistence first (Phase 1.5 from the spec)

The history strip can't exist without continuous, durable per-second
samples that survive launches. Phase 1.5 builds the
`TraceRecorder` that writes one CSV row per second to
`Documents/seismic-recordings/YYYY-MM-DD.csv`.

- [ ] Implement `TraceRecorder` per spec Phase 1.5.
- [ ] Hook it into `TraceBuffer.ingest()` so the recorder writes the
      same averaged float that drives the trace.
- [ ] Verify CSV after 30 min on device — ~1,800 rows, parseable in
      Numbers, accessible via Files app.
- [ ] Set `isExcludedFromBackup = true` on the recordings directory.
- [ ] Decide: are `UIFileSharingEnabled` + `LSSupportsOpeningDocumentsInPlace`
      worth setting? Yes for ease of retrieval; no for zero
      discoverability if Guided Access is exited.

### B. Active trace — 15-minute window

The Phase 1 buffer is sized to screen pixel count with one sample per
second. To show 15 minutes across ~2300 pixels (screen width minus the
y-axis gutter), we either:

- (i) keep one sample per second and let each sample cover ~2.5 px, or
- (ii) accumulate in shorter windows (e.g. 250 ms) so each sample
      covers ~1 px and the line is denser.

Option (ii) gives a smoother-looking trace at the cost of more memory
and a faster scroll feel.

- [ ] Decide sample rate vs pixel rate. Spec leaned slower; sketch
      pulls faster. Pick one and tune.
- [ ] Resize `TraceBuffer.maxSamples` to match the active trace
      width in pixels (not 2732 — subtract gutter for the y-axis).
- [ ] Adjust accumulator window if going with sub-second sampling.
- [ ] Confirm the trace still reads as "breathing not reacting" at
      the 15-minute pace. Sit with it.

### C. Y-axis — 0–120 dB SPL

`AVAudioEngine` returns dB FS (digital full scale): 0 dB FS is a peak
sample at ±1.0, all real signals are negative. dB SPL is sound
pressure level, anchored to a physical reference (20 µPa) and what
people read on sound level meters.

The conversion is `dB SPL = dB FS + offset`, where `offset` is the
mic's sensitivity calibration. iPad mics aren't lab-calibrated, but
public measurements put the iPad Pro built-in mic's offset somewhere
around **+90 to +100 dB SPL** at default input gain (i.e. 0 dB FS ≈
94 dB SPL).

- [ ] Pick a default offset (suggest **94 dB SPL** as a defensible
      starting point — it's the standard 1 Pa reference).
- [ ] Convert in `AudioMonitor`: `dbSPL = dbFS + 94`. Clamp to 0–120
      for display.
- [ ] Push raw `Float` of dB SPL into `TraceBuffer` instead of the
      0–1 normalised value. (TraceView's vertical mapping then becomes
      `(dBSPL - 0) / 120`, with clipping at the edges.)
- [ ] Render scale ticks at e.g. 0, 20, 40, 60, 80, 100, 120 dB on
      the left gutter, mono small caps, 50% ink opacity per Phase 3.
- [ ] If Ravi wants a calibration step (lab-grade), document
      procedure: hold a calibrated SPL meter next to the iPad
      playing pink noise, adjust offset until they agree.

### D. Timestamp `YYYYMMDD HH:MM:SS:CS`

The header currently has nothing. Sketch puts a timestamp at the
lower-left of the active trace area, just above the history strip —
not in the typical header band.

Note "CS" is centiseconds (1/100s). Updating every 10 ms.

- [ ] Add a SwiftUI view `Timestamp` that renders the formatted
      string in IBM Plex Mono / monospace digits to prevent layout
      shift.
- [ ] Drive the centisecond field with a `CADisplayLink` rather
      than `Timer.publish(every: 0.01)` — `CADisplayLink` syncs to
      the display refresh and is much cheaper.
- [ ] Format with manual string composition (DateFormatter doesn't
      give you "no separators in the date part" cleanly), e.g.:
      ```swift
      let cs = Int((date.timeIntervalSince1970 * 100).truncatingRemainder(dividingBy: 100))
      String(format: "%04d%02d%02d %02d:%02d:%02d:%02d", y, m, d, hh, mm, ss, cs)
      ```
- [ ] Place it per the sketch — under the trace, left side, just
      above the history strip's top edge.

### E. Compressed history strip

The largest new component. Renders the entire show as a single
horizontal trace, with a viewport rectangle marking the active
window.

Math:
- Show duration: 14 days = 1,209,600 seconds.
- Strip width: ~2400 px (screen width minus y-axis gutter).
- One pixel column ≈ 504 seconds = 8.4 minutes of room time.
- The 15-minute viewport window therefore corresponds to ~107 px
  on the strip. (Drawn at half opacity / orange rectangle in the
  sketch; pick final colour later — orange is conspicuous in a
  cream/ink piece, may want to soften.)

Rendering strategy:
- [ ] Maintain an in-memory **history buffer** sized to strip width
      in pixels (~2400). Each cell holds the aggregate of its time
      bucket — could be max, mean, or min/max envelope.
- [ ] On launch, populate it by streaming the existing CSV files
      (Phase 1.5) and bucketing into the strip cells.
- [ ] On each new sample (1/s), update the current bucket's
      aggregate.
- [ ] Draw the strip as a polyline (mean) or filled envelope (min
      to max per column), 0.5–1 pt stroke, ink at 70% opacity.
- [ ] Draw the viewport rectangle: position is
      `((now - showStart) / showDuration) * stripWidth - viewportWidth`,
      width is `(15 min / showDuration) * stripWidth`. Stroke only,
      no fill, `~1.5 pt` orange (or reconsidered colour).
- [ ] Decide: how does the app know when "show day 1" started?
      Options:
      - Hardcoded show open date in code.
      - First-ever-launch timestamp persisted to UserDefaults.
      - Date of the earliest CSV file in the recordings directory.
      The spec mentions "PRESENCE — 14 DAYS" as a footer string, so
      hardcoding the open date is consistent with that intent.
- [ ] Decide: viewer-visible record vs spec's ephemerality claim.
      *(Flagged in Reconciliation above.)*

### F. Layout

The screen now has more than one zone. Sketch suggests:
- Top: y-axis labels + active trace, full width minus left gutter
  (~60 px).
- Bottom: full-width history strip at ~10–15% of screen height,
  with a hairline divider above it.
- Timestamp sits in the small band between active trace and
  history strip, lower-left.
- No header band on the active screen (the spec's Phase 3 header
  may now live somewhere else, or be dropped).

- [ ] Draft a `SeismicView` SwiftUI hierarchy: `VStack { TraceArea, Divider, HistoryStrip }`,
      with `TraceArea` itself an `HStack { ScaleView, ZStack(TraceView, Timestamp) }`.
- [ ] Adjust `TraceBuffer` width sizing to subtract the gutter from
      the available pixels (Phase 1 hardcoded 2732).

---

## Open questions for Ravi

These should be answered before building, not during:

1. **Ephemerality vs visible record.** The history strip puts the
   show's data in front of the viewer. Is this the new direction,
   or should the strip exist but be hidden (e.g. only visible when
   a hidden gesture is performed by the artist)? The spec's strong
   claim that "the viewer experiences ephemerality, the artist
   retains the record" stops being true with the strip on screen.
2. **Scroll rate.** Spec leaned glacial (45 min – 7.5 h per screen).
   Sketch is 15 min. Lock in.
3. **dB SPL calibration.** Default offset of +94 dB FS → SPL is
   defensible but not measured. Do we want lab calibration before
   the show, or accept the default with a note in the work's
   accompanying text?
4. **Timestamp prominence.** Centiseconds updating every 10 ms is
   a deliberate "this is live" gesture. Is that the right energy,
   or does it pull focus from the trace?
5. **Strip viewport colour.** Orange in the sketch reads as
   warning/UI. Cream + black palette wants something quieter:
   thin black box, hairline, or a barely-warmer shade of the cream?
6. **Show start time.** Hardcoded date, first-launch persistent
   timestamp, or earliest-CSV-date? Hardcoded is most predictable
   for a known gallery date.

---

## Suggested order to pick up tomorrow

1. **Decide the open questions above.** 30 min on paper; saves
   building twice.
2. **Phase 1.5 — recording layer.** Mechanical, copy-paste from
   spec. Unblocks E.
3. **C — dB SPL conversion + scale ticks.** Small change to
   `AudioMonitor` + new `ScaleView`.
4. **B — 15-minute active trace.** Buffer sizing change + revisit
   sampling cadence.
5. **D — timestamp.** Independent of the rest.
6. **E — history strip.** The biggest piece; build last so the
   data and SPL conversion are stable underneath it.
7. **F — final layout pass.** Once each piece works in isolation.

---

*Draft 2026-04-26. Ravi to revise as the sketch evolves.*

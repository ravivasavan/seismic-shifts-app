# ADR-0006: Cross-piece visual echoes

- **Status:** Superseded by [ADR-0012](./0012-pen-red-instrument-black-trace.md)
- **Date:** 2026-05-06

## Context

The diptych must read as one work, not two unrelated pieces. The
shared cream/ink palette is the obvious link. To deepen the
relationship, two specific motifs are echoed across the two pieces —
each functional in its native context, each resonant in the other.

## Decision

Two motifs travel between the digital trace and the long-arc drawing.

### 1. Orange band — the active span

In the digital piece, a quiet orange (`#DB732E` at low opacity) marks
the **active 15-minute window** on the scrubber and history strip.
It says *here, now, this stretch of time.*

On the long-arc drawing, the same orange bands the **eugenics era**
(1880–1945). Same hue, vastly different time scales. It says *here,
this stretch of time too.*

### 2. Red impact mark — the moment of impact

In the digital piece, a single red dot (pen red, `#C72E1F`) signals
**session start** — a brief impact mark animated on launch with
concentric ripples, the work coming into the room.

On the long arc, the same red marks **1880** — a vertical line
across the chart, a filled red dot, and concentric ripples around it.
The moment that broke the historical line.

## Considered alternatives

- **No echoes.** The two pieces would read as palette-matched but
  unrelated.
- **Many small echoes** — same fonts, same line weights, same
  hairlines everywhere. Risks reading as decorated, tweed.
- **Two strong echoes** (chosen) — orange for *the span we're
  attending to*, red for *the moment of impact*. Both are functional
  in the digital piece and resonant on the arc.

## Hex values

These come from `Seismic/Theme.swift` and are referenced directly in
the SVG so the two pieces stay in sync without a build step.

| Token | Hex | Use |
|---|---|---|
| paper | `#F4EFE6` | background, both pieces |
| ink | `#1A1A1A` | trace, text, both pieces |
| viewport orange | `#DB732E` | active window (digital) / eugenics era (drawing) |
| pen red | `#C72E1F` | session-start dot (digital) / 1880 mark (drawing) |

## Consequences

- The Theme.swift palette is now a shared reference for both pieces.
  Hex values must stay stable; if either piece needs to shift its
  palette, both do.
- New visual elements introduced in either piece should consider
  whether they have a counterpart in the other. Not every element
  needs to echo — only those that carry meaning by repetition.
- A viewer who has seen both pieces should recognise the visual
  vocabulary. Curatorial wall text should mention the echoes for
  viewers who see only one piece.

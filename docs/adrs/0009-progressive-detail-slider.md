# ADR-0009: Progressive detail slider

- **Status:** Accepted
- **Date:** 2026-05-06

## Context

At full detail, the long arc has 50+ text elements: era bands, event
names, italic descriptors, deep-time framings, metadata strip,
baseline subtitle, time-scale honesty caption. This is information-
rich for catalogue or research use, but visually busy for a quick
read of the *shape* of the trace — which is the work's primary
argument.

The viewer needs agency to choose how much story they want to see at
once.

## Decision

A **four-level detail control** progressively reveals or hides
annotation layers. Always-visible elements (the trace, the Milan
ripple, dot+name labels for each event, y-axis terms, x-axis years,
the today marker, the unwritten zone, the deep-time framings — see
[ADR-0005](./0005-long-arc-visual-grammar.md)) render at every level.

| Level | Name | Adds |
|---|---|---|
| 1 | Minimal | (always-visible only) |
| 2 | Context | era band labels, era separators, EUGENICS ERA label, UNWRITTEN label, `?` on time axis |
| 3 | Annotations | italic descriptors per event, Australian assimilation policy range, Nazi/Aktion T4 cluster details, *"the near future, not yet drawn"*, *"not yet at the line it left"* |
| 4 | Full *(default)* | metadata strip, AGB Memoir title text, *"Bell & contemporaries"*, *"~17,000 deaf people sterilised…"*, baseline subtitle, time-scale honesty caption, faint above/below-baseline guides |

### UI

A **draggable slider** with four dot stops along a hairline track and
a 14px filled-ink thumb that snaps to the nearest stop. Each stop has
a **mono-caps tooltip** on hover/focus showing the level name —
*Minimal, Context, Annotations, Full*. Click any stop, drag the
thumb, or use ←/→/↑/↓/Home/End/1–4 keys.

Implementation: a `data-detail` attribute on the SVG drives CSS
`display: none` rules that hide elements classed `from-l2`,
`from-l3`, or `from-l4` based on the current level.

## Considered alternatives

- **Always show everything** — overwhelming for first-read; the trace
  shape gets buried.
- **Single more/less toggle** — too coarse; can't separate "context"
  from "deep annotations".
- **Continuous opacity dial** — clever but dims text rather than
  decluttering it; reading dim text is harder than not reading
  hidden text.
- **A 1–4 button row** — what we had first. Functional but unloved;
  the artist asked for "an actual slider" with tooltips per step.
- **Four-stop draggable slider with tooltips** (chosen) — gives the
  viewer agency in predictable steps; tooltip removes ambiguity
  about what each stop means.

## Consequences

- Every chart element must be classified at addition time: is it
  *always*, *from-l2*, *from-l3*, or *from-l4*?
- Always-visible elements should be lean — they're what a viewer
  sees at minimum.
- New labels added at full detail (`from-l4`) are forgivable; new
  labels added without a class become permanent and crowd the
  minimal view.
- Keyboard shortcuts: `1`, `2`, `3`, `4` jump to that level globally;
  arrow keys move one step when the slider is focused.

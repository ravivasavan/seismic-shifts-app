# ADR-0012: Pen-red instrument, black trace

- **Status:** Accepted
- **Date:** 2026-05-12
- **Supersedes:** [ADR-0006](./0006-cross-piece-visual-echoes.md)

## Context

The hand-drawn long-arc companion piece was executed on warm A0
cartridge paper in red ink with a black needle trace. The digital
piece, drawn from the same metaphor and meant to read as the same
hand, was still on a cooler cream paper with near-black ink across
every mark on the screen — instrument and trace alike.

That mismatch broke the diptych. The drawing is the slow,
authoritative twin; the digital piece is the live one. If the
viewer can't recognise them as the same hand, the diptych falls
apart and reads as two related works rather than two halves of
one.

ADR-0006 codified the earlier "cream paper, near-black ink"
palette and named the only red mark as the **session-start
dot**. With the drawing finished, that rule is now wrong: red is
no longer a moment of impact, it is the **instrument itself**.

## Decision

A two-colour rule, applied to both pieces:

1. **Pen red is the instrument.** Every measuring mark — the dB
   scale, the dashed dB grid lines, the time ticks and labels,
   the live timestamp, the divider hairline, the session-start
   dot — is drawn in pen red. On the long arc, the same red
   carries the chart's measuring marks: axis, gridlines, era
   bands, year ticks.
2. **Black is the line being traced.** The active trace and the
   compressed history-strip mini-trace stay near-black — the
   needle's record of the room. The drawing's central arc is the
   same black: the needle's record of Deaf presence over time.
3. **Orange is preserved as the third colour** for the active
   span on the digital piece and the eugenics-era band on the
   drawing (this echo from ADR-0006 stands).

Background paper is warmed to match the cartridge sheet:
`#F8F1E3` from `#F4EFE6`.

The dB grid lines, which previously read as solid hairlines,
become dashed (`2pt / 2pt`) so they read as instrument rule lines
rather than as quiet structure.

## Hex values

These come from `Seismic/Theme.swift` and are referenced directly
in the long-arc SVG so the two pieces stay in sync without a
build step.

| Token | Hex | Use |
|---|---|---|
| paper | `#F8F1E3` | background, both pieces (was `#F4EFE6`) |
| ink | `#1A1A1A` | active trace + history mini-trace, both pieces |
| pen red | `#C72E1F` | instrument marks: scale, grid, ticks, labels, timestamp, divider, session-start dot |
| penQuiet | `#C72E1F @ 0.55` | instrument text (labels, timestamp at quieter ranks) |
| penFaint | `#C72E1F @ 0.30` | dashed dB grid, tick hairlines, divider |
| viewport orange | `#DB732E` | active window (digital) / eugenics era (drawing) |

## Considered alternatives

- **Keep ADR-0006 verbatim.** Easiest, but the drawing is already
  red-ink-on-warm-cream — the digital piece would diverge from
  the companion it was always meant to twin.
- **Make the trace red too.** Considered. Rejected: the needle's
  record is the *thing being read* — it earns the more sober
  colour. Letting it stay black preserves the seismograph reading
  of "instrument in red, measurement in graphite-black."
- **Move grid lines to a third colour** (e.g. graphite grey).
  Rejected: introduces a colour without earning one. Two-colour
  rule plus the preserved orange echo is the floor.
- **Keep solid grid lines, only swap colour.** Rejected: solid
  red grid lines read as aggressive structure. Dashed rules
  recover the instrument-paper feel.

## Consequences

- `Seismic/Theme.swift` now exports `pen`, `penQuiet`, `penFaint`
  alongside the existing `ink` family. The `ink` family is
  intentionally retained — used only by the two trace surfaces
  and by the artist-only `HistoryView` archive UI.
- ADR-0006's framing — *"ink for the line we are attending to,
  red for the moment of impact"* — is replaced by *"red for the
  instrument, black for the line being traced."* The session-start
  red dot survives as a specific case of the new rule (the dot is
  an instrument mark indicating "now").
- The long-arc SVG must continue to use the same hex values
  listed above so the two pieces remain hand-matched. If either
  piece needs to shift its palette again, both shift together
  and a new ADR supersedes this one.
- The wall label and `docs/app-store-listing.md` description
  copy was updated alongside this ADR to say "warm cream paper,
  red ink, black trace" rather than the older "cream paper,
  near-black ink."
- A re-shot README screenshot is required to reflect the new
  palette; the existing `docs/screenshot.png` is from the
  superseded palette and should not be relied on as a visual
  reference for the current state of the work.

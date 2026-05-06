# ADR-0007: Two-layer label typography

- **Status:** Accepted
- **Date:** 2026-05-06

## Context

The long arc carries many text elements: title, era band labels,
event names, descriptive subtexts, axis labels, deep-time framings,
and a metadata strip. Without a system, each element drifts toward
its own typeface and weight, and the chart reads as visually messy.

An earlier draft used italic Instrument Serif for the Aboriginal
sign languages banner ("a headline-style label"), IBM Plex Mono caps
for event names, and italic serif for descriptive subtexts. This
mixed two registers without a clear rule.

## Decision

The chart uses two layers of text, each with a defined role.

### Layer 1: Labels (instrument output)

**IBM Plex Mono, uppercase, with letter-spacing.** Sized 4.6–6.6
depending on hierarchy.

Used for:
- Era band labels — `DEEP CONTINUITY`, `EARLY DOCUMENTATION`,
  `WESTERN INSTITUTIONAL EMERGENCE`, `SLOW RECOVERY`
- Event names — `1817 — HARTFORD`, `1880 MILAN CONGRESS`,
  `2010 — ICED APOLOGY`, `2022 — BSL ACT`
- Y-axis terms — `CELEBRATED`, `BASELINE`, `SUPPRESSED`
- X-axis years — `65,000 BP`, `1500`, `1880`, `2026`
- Deep-time framings — `ABORIGINAL SIGN LANGUAGES`, `PLAINS INDIAN
  SIGN LANGUAGE — HAND TALK`
- Unwritten zone marker — `UNWRITTEN`
- Section markers — `EUGENICS ERA`, `AUSTRALIAN ASSIMILATION POLICIES`
- Metadata strip — `A0 / 1189 × 841 MM / LANDSCAPE`, etc.

### Layer 2: Annotations (voice)

**Instrument Serif italic, sentence case.** Sized 6.0–11.

Used for:
- Per-event descriptive subtexts — *"first US sterilisation law"*,
  *"ASL shown to be a natural language"*, *"rejection of the 1880
  resolutions"*
- The 1880 Milan resolution description — *"164 hearing delegates
  vote to ban sign languages from deaf education in favour of
  oralism"*
- The today marker subtitle — *"not yet at the line it left"*
- The unwritten zone descriptor — *"the near future, not yet drawn"*
- The AGB Memoir title — *"Memoir Upon the Formation of a Deaf
  Variety…"*
- The Aktion T4 description — *"~17,000 deaf people sterilised;
  thousands murdered"*

## Rule

**Labels are instrument output. Annotations are voice.** The viewer
should be able to tell the chart from the speaker — the one is
machine-stamped, the other is hand-typeset.

## Considered alternatives

- **All italic-serif headlines for the framings** — bookish but
  inconsistent with the seismograph aesthetic.
- **All mono** — too cold; loses the literary quality of the
  annotations.
- **Two-layer system** (chosen) — clean rule, scales to new
  additions, lets the typography do part of the work.

## Consequences

- The Aboriginal banner restyled from italic-serif headline to
  two-line mono caps with mono subtitle.
- Plains Indian Sign Language restyled similarly.
- Any new chart element needs a category at addition time: is it a
  *label* (mono caps) or an *annotation* (italic serif)?
- The arc page's title (`Seismic Shifts`) and subtitle remain
  Instrument Serif — they are not part of the chart, they are
  page-level title-block typography.

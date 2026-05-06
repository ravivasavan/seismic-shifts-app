# ADR-0011: ADA and BSL Act in the timeline

- **Status:** Accepted
- **Date:** 2026-05-06

## Context

The long arc's timeline began with language-recognition events
(Stokoe 1960, Auslan named 1975, Auslan recognised 1995, NZSL 2003,
ICED apology 2010) and language-suppression events (Milan 1880, AGB
Memoir 1883, Indiana sterilisation 1907, Australian assimilation,
Nazi sterilisation law 1933, Aktion T4 1939–45).

Two consequential upticks for Deaf life — one civil-rights, one
language-recognition — were missing.

## Decision

Two events added.

### 1990 — ADA (Americans with Disabilities Act)

Inserted in the timeline between Deaf President Now (1988) and
Auslan recognised (1995). On the trace, a new vertex at `(941, 463)`
between DPN at `(937, 470)` and Auslan-recognised at `(950, 446)` —
a small uptick along the existing rise.

The ADA is meaningful even though it is not specifically a
sign-language law. It mandates access (interpreting services,
captioning, telecommunications relay) and prohibits disability-based
discrimination — transforming Deaf access in US civic, educational,
and workplace life.

Italic descriptor *"Americans with Disabilities Act"* appears at full
detail only.

### 2022 — BSL Act (British Sign Language Act)

Inserted between ICED (2010) and today (2026). On the trace, a new
vertex at `(999, 415)` produces a final uptick before today, lifting
today from `y=425` to `y=415`.

UK Parliament passed the BSL Act in 2022, recognising BSL as a
language of England, Wales, and Scotland. It joins Auslan (1995) and
NZSL (2003) as another national-level legal recognition of a deaf
community's sign language.

Italic descriptor *"BSL recognised in the UK"* appears at annotations
level and above.

## Considered alternatives

- **Skip ADA.** Misses a major civil-rights uptick. ADA is a
  Deaf-life event even though it is not a sign-language law; the
  recovery story is broader than language recognition alone.
- **Skip BSL Act.** Leaves the trace flat from 2010 to 2026, missing
  a real recovery moment.
- **Add only ADA, not BSL Act.** Inconsistent — both are landmark
  national legal events for Deaf communities; including one without
  the other reads as a US-centric framing.
- **Include both** (chosen) — the recovery is broader than language
  recognition alone, and BSL gets parity with Auslan and NZSL.

## Consequences

- Today (2026) sits at y=415, ten units higher than before.
- The trace polyline gains two new vertices.
- The timeline is updated in three places that must stay synchronised:
  - `seismic-shifts-site/arc.html` — SVG trace + event markers
  - `seismic-shifts-site/description.html` — Timeline list
  - `seismic-shifts-app/docs/artwork-description.md` — canonical
    timeline
- The ADA italic is `from-l4` (full detail); the BSL Act italic is
  `from-l3` (annotations) — see
  [ADR-0009](./0009-progressive-detail-slider.md).
- Future timeline additions should be considered as candidates here
  too (e.g. specific national language recognitions, the ADA
  Amendments Act 2008, recent Aboriginal sign-language recognition
  work). Add via a new ADR if they shift the trace meaningfully.

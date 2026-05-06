# Architecture Decision Records — Seismic Shifts

Decisions that shape the work, captured in numbered Markdown files
following the Michael Nygard format. Each ADR has the same shape:
context, decision, considered alternatives, and consequences.

These are decisions about the *work* — its identity, its visual
grammar, its mode of distribution — not about routine implementation
details. They were taken in working sessions with the artist and are
intended to be revisited (and revised) as the work develops.

## Index

| # | Title | Status |
|---|---|---|
| [0001](./0001-diptych-structure.md) | Diptych structure | Accepted |
| [0002](./0002-platform-agnostic-language.md) | Platform-agnostic public language | Accepted |
| [0003](./0003-presence-claim.md) | The presence claim — hear, see, or feel | Accepted |
| [0004](./0004-long-arc-as-web-page.md) | Long arc as a live web page | Accepted |
| [0005](./0005-long-arc-visual-grammar.md) | Long-arc visual grammar | Accepted |
| [0006](./0006-cross-piece-visual-echoes.md) | Cross-piece visual echoes | Accepted |
| [0007](./0007-label-typography.md) | Two-layer label typography | Accepted |
| [0008](./0008-svg-viewbox-zoom.md) | SVG viewBox-based pan & zoom | Accepted |
| [0009](./0009-progressive-detail-slider.md) | Progressive detail slider | Accepted |
| [0010](./0010-floating-pill-nav.md) | Floating pill nav with mobile hamburger | Accepted |
| [0011](./0011-ada-bsl-act-timeline.md) | ADA and BSL Act in the timeline | Accepted |

## Format

Each ADR is structured as:

```markdown
# ADR-NNNN: Title

- **Status:** Accepted / Superseded / Deprecated
- **Date:** YYYY-MM-DD

## Context

What was the situation; why a decision was needed.

## Decision

What was decided.

## Considered alternatives

Other options that were on the table.

## Consequences

What changes — both positive outcomes and trade-offs.
```

If a decision is later revised, write a new ADR that supersedes the
old one rather than editing in place. The old ADR stays as historical
record.

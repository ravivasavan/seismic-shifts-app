# ADR-0005: Long-arc visual grammar

- **Status:** Accepted
- **Date:** 2026-05-06

## Context

The long arc spans 65,000 years. The action — the 1880 Milan
Congress, the eugenics era, slow recovery, ADA, BSL Act — is
concentrated in the last 250 years. Linear time would compress all
the action to invisibility. The deep past needs to read as
continuous, not as empty space. The future needs to read as open,
not as forecast.

A single decision space governs the long arc; this ADR collects four
related rules that shape its grammar.

## Decision

### 1. Non-uniform time scale

The deep past is compressed; the modern era is expanded. Each era on
the chart gets enough horizontal space for its named events to
breathe.

| Era | Years | Width |
|---|---|---|
| 65,000 BP – 10,000 BP | 55,000 yr | 198 mm |
| 10,000 BP – 1500 CE | ~11,500 yr | 252 mm |
| 1500 – 1750 | 250 yr | 126 mm |
| 1750 – 1880 | 130 yr | 126 mm |
| 1880 – 1945 | 65 yr | 77 mm |
| 1945 – 2026 | 81 yr | 147 mm |

A quiet honesty caption sits at the bottom of the chart at full
detail: *"TIME SCALE NON-UNIFORM — DEEP PAST COMPRESSED, MODERN ERA
EXPANDED."*

### 2. Unwritten future zone

The right ~10% of the page is intentionally left blank. The trace
ends at *today* (2026) at the 90% mark. The unwritten zone is marked
with a faint background tint, a dashed vertical line at *today*, an
"UNWRITTEN" label (context level), an italic *"the near future, not
yet drawn"* (annotations level), and a `?` on the time axis.

### 3. Baseline as historical norm

The y-axis baseline is the deep historical norm of continuous
signed-language presence in human community. The trace runs
at-baseline through the deep past; it rises modestly through the
Western institutional period; it plummets at 1880 and stays deep
below baseline through the eugenics era; it climbs back slowly but
has not, at 2026, returned to the baseline.

Y-axis labels (always visible): **CELEBRATED · BASELINE ·
SUPPRESSED**.

### 4. Deep-time framings always visible

The Aboriginal sign languages banner (Warlpiri, Yolngu, Arandic,
Pitjantjatjara, Ngada, Western Desert) and the Plains Indian Sign
Language note are foundational to the work, not optional detail. They
render at every detail level (1 through 4) — see
[ADR-0009](./0009-progressive-detail-slider.md) for what *level* means.

## Considered alternatives

- **Linear time scale.** Modern action becomes visually invisible.
- **Trace extending to the page edge.** Implies the future is
  determined; reads as forecast.
- **Y-axis labelled "RECOGNISED / BASELINE / SUPPRESSED."**
  *Recognised* understates the historical state — the deep past was
  not merely *recognised*, it was *celebrated*. The artist's
  preferred term.
- **Deep-time content as full-detail-only.** When the slider is
  dragged left to *minimal*, the conceptual anchor disappears. Tested
  this and reversed: the deep-time framings now ignore detail level.

## Consequences

- The future is framed as choice, not forecast.
- The deep-time foundation is always present, regardless of detail
  level.
- The y-axis emphasises agency (celebrated) and harm (suppressed),
  not bureaucratic recognition.
- The non-uniform scale must be honoured by future timeline additions
  — see the era widths above.

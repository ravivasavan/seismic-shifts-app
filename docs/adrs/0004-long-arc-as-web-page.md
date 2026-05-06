# ADR-0004: Long arc as a live web page

- **Status:** Accepted
- **Date:** 2026-05-06

## Context

The hand-drawn long-arc companion is destined for ink on A0 paper
beside the digital screen. Before drawing it on paper, the
composition needed a digital draft for previewing, sharing, and
iterating on placement, sizing, label hierarchy, and the time scale.

A static SVG file in the repo would be a dead-end — viewers can't
explore it; iteration is slow.

## Decision

The long arc lives as a dedicated page on the existing
`seismic-shifts-site` GitHub Pages repo at `/arc.html`. The page is a
fullscreen, immersive canvas — pannable, zoomable, with a progressive
detail control. The textual content (timeline, "what it shows"
interpretation) sits on the Description page so the arc page is
purely the visualisation.

## Considered alternatives

- **Static SVG checked into the app repo.** Useful as a planning
  artifact but not interactive. Iterating composition becomes a manual
  loop of edit → reload → eyeball.
- **A separate new repo for the long arc.** Overkill — the existing
  site is already the public surface for the work, and visitors of
  one piece are likely visitors of the other.
- **Dedicated `/arc.html` on the existing site** (chosen). The long
  arc becomes a sibling of the live trace in the site's nav: Work ·
  Description · Arc · Privacy · Support.

## Consequences

- The arc has a public URL that can be shared with curators,
  collaborators, and reviewers without circulating files.
- The composition can be tested against actual viewers — at desktop
  width, on a tablet, on a phone — before committing it to ink.
- Implementation decisions follow:
  [ADR-0008](./0008-svg-viewbox-zoom.md) for crisp pan/zoom,
  [ADR-0009](./0009-progressive-detail-slider.md) for the detail
  slider.
- The arc page itself is fullscreen — no header/main/footer shell, no
  body scroll, no in-page text. The rest of the site retains the
  standard column layout and floating nav.
- The eventual hand-drawn ink companion remains the artwork; the web
  page is its preview and a public form of the same composition.

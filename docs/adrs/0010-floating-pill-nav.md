# ADR-0010: Floating pill nav with mobile hamburger

- **Status:** Accepted
- **Date:** 2026-05-06

## Context

The arc page introduced a **floating cream-on-cream pill nav**: a
title pill on the top-left and a nav pill on the top-right, both
translucent with a hairline border and backdrop blur. It read as
quietly current and didn't break the immersive canvas underneath.

The other site pages (Work, Description, Privacy, Support) were still
using the original underlined-link site header. The artist liked the
arc nav and asked for it across the whole site.

A mobile fallback was needed — a row of five pill links does not fit
on a phone. Earlier the nav pill was simply `display: none` below
720px, leaving mobile users with only the title pill (and only the
home link). That removed navigation entirely on phones; the user
flagged this and asked to retain the menu via a hamburger.

## Decision

The floating pill nav becomes **site-wide**. Every page has the same
`header.site` fixed at the top of the viewport:

- **Title pill** (top-left): app icon (22×22, rounded 5px, from
  `apple-touch-icon.png`) + "Seismic Shifts" link to home
- **Nav pill** (top-right): Work · Description · Arc · Privacy ·
  Support, with `aria-current="page"` on the active link

Both pills share styling: `rgba(244, 239, 230, 0.86)` background,
10px `backdrop-filter: blur`, hairline border, 4px radius, IBM Plex
Mono small caps with `letter-spacing: 0.18em`.

### Mobile (≤ 720px): hamburger toggle

The nav pill collapses to a square 48×48 pill containing only a
**hamburger icon** (Phosphor `list`, inlined as SVG). Tapping the
hamburger expands a vertical drawer below the toggle, hairline-
divided from the toggle row, containing all five links right-aligned.

The toggle icon swaps to a Phosphor `x` when expanded. The drawer
auto-closes on:

- Escape keypress
- Click on any link
- Window resize past 720px

A shared `nav.js` (defer-loaded on every page) handles the toggle.

## Considered alternatives

- **Keep the original underlined-link header** on non-arc pages —
  felt dated next to the floating pill on /arc.html.
- **Floating pill on all pages without mobile fallback** (the
  intermediate state) — left phones with no navigation other than
  *home*, blocking visitors from reaching Description, Privacy,
  Support.
- **A drawer that overlays full-screen** (typical SPA hamburger) —
  too heavy for a small-scope artistic site; loses the cream-on-cream
  quietness.
- **Floating pill with an in-place expanding hamburger drawer**
  (chosen) — same pill container, expands downward; preserves the
  visual identity at every viewport size.

## Consequences

- Body padding-top adjusted to 96px (80px on phones) to clear the
  fixed header.
- `arc.html` keeps a `body.arc-body` class that overrides body
  padding to 0 for the fullscreen canvas.
- New pages added later must use the same header structure: a
  `<header class="site">` containing a `.site-title` div and a
  `<nav class="site-nav">` with the toggle button + `.site-nav-menu`.
- Phosphor icons are inlined as SVG, not loaded from a CDN — the
  icons render even when the network is offline or slow.
- The mobile drawer is intentionally simple; if the nav grows beyond
  ~7 items, revisit the pattern.

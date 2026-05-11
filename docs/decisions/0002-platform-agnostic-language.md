# ADR-0002: Platform-agnostic public language

- **Status:** Accepted
- **Date:** 2026-05-06

## Context

Early descriptions of Seismic Shifts led with "an iPad app" or "a
native iPadOS app." As the conceptual frame matured, the platform
increasingly read as a means to an end — the work is about listening
to a room, not about the iPad as a medium. The artist explicitly
flagged this: *"iPad and iOS is just a means to an end."*

The App Store listing, the README, and every site page mentioned
iPad/iOS in their primary descriptive copy.

## Decision

Public-facing copy describes Seismic Shifts as **a digital and
interactive work that listens to the room it is in and its
surrounds.** All references to iPad, iPadOS, and iOS are removed
from public artistic copy. The materials line uses *screen* rather
than *iPad*.

## Out of scope

The following deliberately retain platform references because they
describe implementation, not identity:

- `Seismic/` source code (Swift, AVAudioEngine, etc.)
- `docs/app-store-listing.md` — submission metadata for App Store
  Connect, which Apple requires platform language for
- `docs/ui-roadmap.md` — internal planning that talks about the
  iPad's microphone calibration
- The README's *Build & run* and *Configuration* sections — developer
  instructions for the actual implementation

## Considered alternatives

- **Lead with "iPad app"** — reads as product copy, not artwork
  description; pins identity to a platform that is the means, not
  the end.
- **Lead with "screen-based work"** — accurate but cold; loses the
  living, listening quality.
- **Lead with "a digital and interactive work that listens to the
  room…"** (chosen) — keeps presence and listening as the primary
  identity, names the work by what it does rather than the device
  it does it on.

## Consequences

- Site copy across `index.html`, `privacy.html`, `support.html`, and
  the site README is reframed.
- Privacy/support copy uses generic *device* and *device's privacy
  settings* rather than iOS-specific paths.
- The work's identity is now portable: if it later runs on other
  platforms, the public description does not need rewriting.
- The App Store listing and ui-roadmap remain platform-specific by
  necessity; reviewing them again is worth it before the next
  TestFlight or App Store push.

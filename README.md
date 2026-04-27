# Seismic Shifts

![Seismic Shifts running on iPad — a clap captured at 14:01:32 as a brief peak on a near-black trace over cream paper, with a 0–120 dB SPL scale on the left, time markers below, a centisecond timestamp, and a compressed history strip with an orange viewport rectangle along the bottom.](docs/screenshot.png)

A native iPadOS app that listens to a gallery space and renders the
room's acoustic energy as a single, slowly scrolling horizontal trace.

The work is for both Deaf and hearing audiences. Its claim is that
what is recorded is real — a room has presence, with or without
anyone to hear it. One mic, one line, one slow scroll. Cream paper,
near-black ink. No interaction, no settings, no modes.

**Critical distinction:** only the visualisation data — one float per
second representing acoustic energy — is recorded. **No audio is
captured, stored, or recoverable.** The recording cannot be used to
reconstruct conversations or identify speakers; it is equivalent to
a barometer recording air pressure.

## Links

- **Site / privacy / support:** [seismic-shifts-site](https://ravivasavan.github.io/seismic-shifts-site/)
- **Site repo:** [ravivasavan/seismic-shifts-site](https://github.com/ravivasavan/seismic-shifts-site)
- **App Store listing copy:** [`docs/app-store-listing.md`](./docs/app-store-listing.md)
- **UI roadmap (in progress):** [`docs/ui-roadmap.md`](./docs/ui-roadmap.md)

## Status

| Phase | Description | State |
|---|---|---|
| 1 | Working prototype — audio → trace, end to end | ✅ Built |
| 1.5 | Persistence layer — per-session CSV recording | ✅ Built |
| 2 | Pacing and feel — A-weighting, smoothing, dB SPL conversion | ✅ Built |
| 3 | Typography and layout — scale ticks, time markers, timestamp, history strip | ✅ Built |
| 4 | Hardening — interruption handling, route-change, 5s watchdog | ✅ Built |
| 5 | Frame and physical install | Out of code scope |

The current build is **v0.1**, ready to archive and submit to
TestFlight (and eventually the App Store as a free download).

### What's on screen

- **Active trace.** A 15-minute window of dB SPL values, scrolling
  left at ~3 px/s on a 12.9-inch iPad. Pinch to zoom between 1 and
  60 minutes (no UI affordance — silent gesture).
- **Y-axis scale.** 0–120 dB SPL with major ticks every 20 dB and
  minor ticks every 5 dB. Sits in the left gutter.
- **X-axis time markers.** Tick spacing adapts to the active
  window: every 15 s at 1-min zoom, up to every 10 min at 60-min
  zoom.
- **Live timestamp.** `YYYYMMDD HH:MM:SS:CS` — the centisecond
  field updates synced to the display refresh.
- **Compressed history strip.** The whole current session in a
  single horizontal strip at the bottom, with a quiet orange
  viewport rectangle marking where the active window sits within
  the session.

### Hidden gestures (no UI clue, intentional)

- **Pinch** on the trace area changes the active window between 1
  and 60 minutes.
- **Three consecutive long-presses** (≥0.6 s each, within ~2 s)
  reveal the **History view** — an artist-only archive of past
  sessions, grouped by day, each rendered as a horizontal strip
  with its start time and duration. Three more long-presses inside
  the History view dismiss it back to the live trace.

## Architecture

| Layer | Files | Role |
|---|---|---|
| Audio | `AudioMonitor.swift`, `AWeightingFilter.swift` | Mic tap, A-weighting biquad cascade, vDSP RMS, dB FS → dB SPL conversion at +94 dB offset, audio-session resilience (interruption / route change / 5 s watchdog). |
| Session | `SessionStore.swift` | Owns per-second dB SPL stream from launch to termination. Light EMA smoothing. Single source of truth for every view. |
| Persistence | `TraceRecorder.swift` | Writes one CSV row per second to `Documents/seismic-recordings/session-YYYYMMDDTHHMMSSZ.csv`. New file per launch, never appends to a prior session. Excluded from iCloud backup. |
| Render | `SeismicView.swift`, `ActiveTraceView.swift`, `ScaleView.swift`, `TimeAxisView.swift`, `TimestampView.swift`, `HistoryStripView.swift`, `HistoryView.swift` | SwiftUI `Canvas` for traces, `TimelineView`-driven re-renders for the scrolling components. |
| Theme + utilities | `Theme.swift`, `DateFormatting.swift` | Palette constants, custom timestamp/filename formatters. |
| App entry | `SeismicApp.swift` | Hosts `SeismicView`, locks landscape, hides system UI, disables idle timer. |

The app is **session-based**. Each launch starts the trace empty
and creates a fresh CSV file in `Documents/seismic-recordings/`
named for the session-start timestamp. One float per second is
appended for the lifetime of the session; the file is sealed when
the app terminates. Past sessions remain on disk for the artist,
are excluded from iCloud backup, and are never surfaced inside the
app except via the hidden History gesture. Audio itself is never
stored.

## Build & run

Requires Xcode 26+ and an Apple Developer Program membership for
device runs.

```bash
open Seismic/Seismic.xcodeproj
```

In Xcode:

1. Select your team under Signing & Capabilities (already set to
   `QMSUBPG3D5` in the pbxproj).
2. Choose a destination — iPad simulator for quick checks, or a
   real iPad for the proper acoustic test.
3. Press **⌘R**.

On first launch on a real device, accept the microphone permission
prompt. The trace should respond to clapping near the device.

## Distribution

For TestFlight or App Store distribution, see
[`docs/app-store-listing.md`](./docs/app-store-listing.md) for all
the metadata fields ready to paste into App Store Connect:
description, subtitle, promo text, keywords, URLs, category,
review notes, and privacy nutrition answers.

The privacy manifest (`PrivacyInfo.xcprivacy`) declares zero
collection, zero tracking, zero required-reason API usage.

## Configuration that's already locked in

- iPad-only target (`TARGETED_DEVICE_FAMILY = 2`)
- Not available as Designed-for-iPad on Mac, not on visionOS
- Landscape orientation only
- Idle timer disabled at runtime
- Persistent system overlays hidden
- App icon: 1024×1024 light/dark/tinted variants
- Encryption-compliance flag (`ITSAppUsesNonExemptEncryption = NO`)
- Microphone usage description set
- Display name: **Seismic Shifts**
- Bundle ID: `me.ravivasavan.Seismic`

## License

Not yet specified. The artwork and code are © 2026 Ravi Vasavan;
contact [ravivasavan@gmail.com](mailto:ravivasavan@gmail.com) for
exhibition or collaboration enquiries.

## Contact

For everything: [ravivasavan@gmail.com](mailto:ravivasavan@gmail.com)

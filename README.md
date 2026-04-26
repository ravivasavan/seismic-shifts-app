# Seismic Shifts

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
| 1.5 | Persistence layer — per-day CSV recording | Planned |
| 2 | Pacing and feel — dB range, smoothing, scroll rate, A-weighting | Planned |
| 3 | Typography and layout — header, scale ticks, dividers | Planned |
| 4 | Hardening — interruption handling, watchdog, soak testing | Planned |
| 5 | Frame and physical install | Out of code scope |

The current build is **v0.1**, ready to archive and submit to
TestFlight (and eventually the App Store as a free download).

## Architecture

Four clean layers:

- **Audio layer** (`AudioMonitor.swift`) — `AVAudioEngine` taps the
  mic, vDSP computes RMS over 100 ms windows, dB-FS is normalised
  and exponentially smoothed. Output: one Float per ~100 ms.
- **Buffer layer** (`TraceBuffer.swift`) — accumulates 10 audio
  readings into one visual sample per second; bounded ring sized to
  screen width in pixels.
- **Render layer** (`TraceView.swift`) — SwiftUI `Canvas` draws the
  trace from the buffer; cream background, near-black trace.
- **App entry** (`SeismicApp.swift`) — wires the layers, locks
  landscape, hides system UI, disables the idle timer.

Persistence (Phase 1.5, planned): each visual sample is also
appended to `Documents/seismic-recordings/YYYY-MM-DD.csv`. Audio is
never stored. Files survive launches and are excluded from iCloud
backup.

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

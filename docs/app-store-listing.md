# App Store Listing — Seismic Shifts

Drafts ready to paste into App Store Connect. All character counts checked
against Apple's published limits.

## Name (30 char limit)

```
Seismic Shifts
```

## Subtitle (30 char limit)

```
A seismograph for rooms
```

(Alternates: "Listening to rooms" / "An iPad seismograph")

## Promotional Text (170 char limit, editable without resubmission)

```
Listens to the room around you and draws its acoustic energy as a single, slowly scrolling line. Cream paper, near-black ink. For Deaf and hearing audiences.
```

## Description (4000 char limit)

```
SEISMIC SHIFTS

A native iPad app that listens to the room around it and renders the room's acoustic energy as a single, slowly scrolling horizontal trace.

The work is for both Deaf and hearing audiences. Its claim is that what is recorded is real — a room has presence, with or without anyone to hear it. The trace fills the screen over the course of an afternoon and disappears off the left edge. There is no interaction. There are no settings. One mic, one line, one slow scroll.

Cream paper. Near-black ink. Quiet typography. The piece reads as instrument output rather than as audio visualisation — closer to a seismograph than to an equaliser.

WHAT IT MEASURES

The microphone captures the room. From that, the app computes a single number per second representing the current acoustic energy, with perceptual weighting to de-emphasise low-frequency rumble and very high frequencies. That number drives the trace. That is the entire mechanism.

WHAT IT DOES NOT DO

No audio is recorded, stored, or recoverable. Only the visualisation data — one float per second — is held in memory and optionally written to a local file on the device. The recording cannot be used to reconstruct conversations or identify speakers; it is equivalent to a barometer recording air pressure.

The app does not connect to the internet. It contains no analytics, no advertising frameworks, no telemetry, no third-party SDKs. It does not phone home in any sense.

INSTALLING IN A SPACE

Seismic Shifts is intended as an installation work. To run it as one: plug the iPad into power, lock the orientation to landscape, disable Auto-Lock, and use Guided Access to prevent accidental exit. The app handles audio interruptions and recovers automatically.

It also works perfectly well held in your hands, sat on a desk, or left running in the corner of a quiet room.

PRIVACY

The app accesses the microphone for live processing only. No audio leaves the device because no audio is ever stored. Full policy: https://ravivasavan.github.io/seismic-site/privacy.html

REQUIREMENTS

— iPad running iPadOS 18 or later
— Microphone permission

Made carefully, in small scope, for both Deaf and hearing audiences.
```

## Keywords (100 char limit, comma-separated, no spaces after commas)

```
seismograph,ambient,sound,art,installation,trace,listening,gallery,presence,deaf,visualizer
```

(91 chars. Apple ignores spaces after commas — using none gives more keyword
budget.)

## URLs

- **Marketing URL** (optional): `https://ravivasavan.github.io/seismic-site/`
- **Support URL** (required): `https://ravivasavan.github.io/seismic-site/support.html`
- **Privacy Policy URL** (required): `https://ravivasavan.github.io/seismic-site/privacy.html`

## Category

- **Primary:** Entertainment
- **Secondary:** Music

(No "Art" category exists. Entertainment + Music is the closest honest fit
for an ambient sound work.)

## Age rating

- All questions: **No** → result: **4+**

## Privacy nutrition label

In App Store Connect → App Privacy:

- **Data Types Collected:** none. Toggle "Data Not Collected" — *yes*.
- This matches the privacy manifest already shipped in the binary.

## App Review Notes (App Information → App Review Information)

```
Seismic Shifts is an ambient art installation work. The trace responds to ambient sound — clap or speak near the iPad to verify a response. There is no user interaction beyond observing.

The app requests microphone permission once on first launch; both accept and deny paths behave correctly (declining simply leaves the trace flat).

No audio is recorded. Only an aggregate energy value — one floating-point number per second — drives the visualisation. The app may also write those same numbers to a per-day CSV file in its Documents directory; this file is accessible via the Files app for the user's own records.

The app has no network access. It contains no third-party SDKs, analytics, advertising frameworks, or telemetry. No login, no demo account required.
```

## App Information → Demo account

Not applicable. Leave blank.

## Build → Encryption documentation

The `ITSAppUsesNonExemptEncryption` flag is set to `NO` in the binary, so
App Store Connect should skip this step automatically. If asked anyway:
*"Uses standard system HTTPS only; no proprietary cryptographic
implementations."*

## Localizations

Submit English only for v0.1.

## What's New (versions after v0.1)

```
First public release.
```

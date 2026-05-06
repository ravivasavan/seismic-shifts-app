# ADR-0008: SVG viewBox-based pan & zoom

- **Status:** Accepted
- **Date:** 2026-05-06

## Context

The fullscreen arc page needs pan and zoom interactions. The original
implementation wrapped the SVG in a div and applied
`transform: translate() scale()` to that div, with JS computing the
new transform on each wheel/drag/pinch event.

This produced visible **pixelation at zoom levels above ~2×**.
Browsers rasterise CSS-transformed layers at the unscaled size and
then bitmap-scale up. SVG is vector — but the wrapper-transform
strategy treats it as a bitmap.

For an artwork that must read crisply at every scale, this was a
material defect, not just a polish issue.

## Decision

Pan and zoom **manipulate the SVG's `viewBox` attribute directly**.
Each interaction computes new viewBox coordinates and writes them to
the element; the browser re-tessellates vector paths and re-rasterises
text glyphs at the new scale, keeping strokes and labels crisp at any
zoom level.

### Implementation sketch

```js
var vb = { x: 0, y: 0, w: 1189, h: 841 };

function applyVB() {
    svg.setAttribute('viewBox', vb.x + ' ' + vb.y + ' ' + vb.w + ' ' + vb.h);
}

// Zoom around a viewport point (cx, cy) in screen pixels.
function zoomAt(factor, cx, cy) {
    var newW = vb.w / factor, newH = vb.h / factor;
    // Compute the SVG-space point under (cx, cy) before the zoom.
    // After the zoom, shift vb.x / vb.y so the same point stays under (cx, cy).
    // (Aspect ratio is preserved by preserveAspectRatio="xMidYMid meet")
    ...
    vb.w = newW; vb.h = newH;
    applyVB();
}
```

Zoom range: **0.4× to 16×** of the original viewBox. Cursor-anchored
zoom on wheel; pinch-anchored zoom on touch; centre-anchored zoom on
the +/− buttons.

## Considered alternatives

- **CSS `transform: scale()`** on a wrapper div — simple, but
  rasterises and pixelates above ~2× zoom.
- **Re-render to HTML `<canvas>` on each frame** — would require
  porting the entire SVG composition to imperative draw calls; lots
  of code, no benefit for static art.
- **A library** (svg-pan-zoom, panzoom, etc.) — adds a dependency
  for behaviour we can express in ~80 lines.
- **SVG viewBox manipulation** (chosen) — purpose-built for vector
  graphics, no dependency, vector-crisp at any scale.

## Consequences

- Strokes thicken proportionally with zoom — which is the natural
  behaviour for scaled paper. A `1.6` stroke at 4× zoom becomes
  visually `6.4`. This is *correct* for the seismograph metaphor.
- The `data-detail` attribute lives on the SVG element itself.
  CSS visibility selectors target `svg[data-detail="N"] .from-lN`.
- Touch pinch and mouse wheel share the same `zoomAt(factor, cx, cy)`
  math; only the input source differs.
- If the chart ever needs strokes that *do not* scale with zoom (e.g.
  hairlines that should stay 1px on screen at any zoom), use SVG's
  `vector-effect="non-scaling-stroke"` on those elements. Currently
  no such requirement.

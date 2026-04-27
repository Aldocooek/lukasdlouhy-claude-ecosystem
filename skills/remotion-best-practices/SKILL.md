---
name: remotion-best-practices
description: |
  Dense operational knowledge for building Remotion video compositions.
  Use when working on Remotion projects, video rendering, React video components,
  audio sync, captions, 3D integration, or render pipeline optimization.
model: sonnet
triggers:
  - Remotion
  - video composition
  - React video
  - remotion render
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
last-updated: 2026-04-27
version: 1.0.0
---

# Remotion Best Practices

Validated against remotion.dev/docs (2026-04-26). Do not fabricate API shapes — check
the docs if a prop is not listed here.

---

## Composition Anatomy

### registerRoot + Composition

Every Remotion project registers compositions in a root file:

```tsx
// src/Root.tsx
import { Composition } from 'remotion'
import { MyVideo } from './MyVideo'

export const RemotionRoot = () => (
  <>
    <Composition
      id="MyVideo"
      component={MyVideo}
      durationInFrames={300}
      fps={30}
      width={1920}
      height={1080}
      defaultProps={{ title: 'Hello' }}
    />
  </>
)
```

`id` is used as the composition name in CLI renders. `defaultProps` must match the
component's props schema exactly — mismatches cause hydration errors in the studio.

### AbsoluteFill

`AbsoluteFill` is a `div` with `position: absolute; top: 0; left: 0; width: 100%; height: 100%`.
The parent composition root already sets `position: relative`. Use `AbsoluteFill` for
any layer that should fill the frame. Do not set `position: fixed` — it breaks in the renderer.

### Sequence

`Sequence` shifts frame time for children. Children calling `useCurrentFrame()` receive
a value relative to the sequence's `from`, not the absolute composition frame.

```tsx
// Child at frame 0 of Sequence renders when composition is at frame 60
<Sequence from={60} durationInFrames={90}>
  <Title />
</Sequence>
```

Key props:
- `from` — absolute frame offset (default 0, optional since v3.2.36)
- `durationInFrames` — children unmount after this many frames (default Infinity)
- `layout` — `"absolute-fill"` (default) wraps in AbsoluteFill; `"none"` skips the wrapper
- `premountFor` / `postmountFor` — preload frames before/after sequence window
- `name` — label shown in Remotion Studio timeline

Nested sequences cascade: a sequence at `from={30}` containing a sequence at `from={60}`
means the inner sequence starts at composition frame 90.

### Series

`Series` is a convenience wrapper that auto-calculates `from` offsets from sequential
`Series.Sequence` children. Each child starts immediately after the previous one ends:

```tsx
<Series>
  <Series.Sequence durationInFrames={60}><Intro /></Series.Sequence>
  <Series.Sequence durationInFrames={120}><Main /></Series.Sequence>
  <Series.Sequence durationInFrames={30}><Outro /></Series.Sequence>
</Series>
```

Use `Series` when scenes play back-to-back with no overlap. Use multiple `Sequence`
components for overlapping or parallel elements.

---

## useCurrentFrame and interpolate

`useCurrentFrame()` returns the current frame number (0-indexed). Combine with
`interpolate()` for smooth animations:

```tsx
import { useCurrentFrame, interpolate } from 'remotion'

const frame = useCurrentFrame()
const opacity = interpolate(frame, [0, 30], [0, 1], {
  extrapolateLeft: 'clamp',
  extrapolateRight: 'clamp',
})
```

`extrapolateLeft: 'clamp'` and `extrapolateRight: 'clamp'` are almost always correct.
Without clamp, values extrapolate linearly outside the input range and produce
unexpected results (opacity > 1, negative scales).

`interpolate` supports custom easing via `easing` option from `remotion` or `@remotion/easing`.

---

## Audio

### Audio component

```tsx
import { Audio } from 'remotion'
import { staticFile } from 'remotion'

<Audio src={staticFile('voiceover.mp3')} />
```

Audio files must be in the `public/` directory. Reference via `staticFile()` — do not
use relative paths.

Key props:
- `volume` — 0 to 1, or frame-callback `(f) => interpolate(f, [0, 10], [0, 1])`
- `trimBefore` / `trimAfter` — trim audio in frames
- `playbackRate` — 0.0625 to 16; reverse playback not supported
- `muted` — silences without unmounting; safe to toggle per frame
- `loop` — loops the audio track
- `startFrom` — equivalent shorthand for `trimBefore`
- `endAt` — equivalent shorthand for `trimAfter`
- `acceptableTimeShiftInSeconds` — seek correction threshold (default 0.45s); increase if
  Studio playback shows audio jumping
- `toneFrequency` — pitch adjustment (render-only, 0.01-2)
- `loopVolumeCurveBehavior` — `"repeat"` restarts frame count per loop; `"extend"` treats
  the track as one continuous timeline. Use `"extend"` for volume ramps that should not
  reset on loop.

### Syncing audio to frame

Compute audio offsets from `useCurrentFrame()` rather than CSS `animation-delay`:

```tsx
const frame = useCurrentFrame()
const { fps } = useVideoConfig()
// Start audio at 1.5 seconds into the composition
const audioStartFrame = Math.round(1.5 * fps)

return (
  <Sequence from={audioStartFrame}>
    <Audio src={staticFile('beat.mp3')} />
  </Sequence>
)
```

Never use `setTimeout` or wall-clock timing inside components — they break rendering.

### Premounting audio

Browsers defer audio decode until playback begins, which causes a gap at sequence start.
Use `premountFor` on the containing sequence to pre-decode:

```tsx
<Sequence from={90} premountFor={30}>
  <Audio src={staticFile('fx.wav')} />
</Sequence>
```

This renders the audio component 30 frames before the sequence becomes visible.

### Audio drift

Drift accumulates when `playbackRate` is non-1 or when multiple audio tracks have
different sample rates. Symptoms: lip sync drifts over time, or tracks that are in sync
at frame 0 are 200ms apart at frame 900.

Prevention:
- Normalize all audio to 44100 Hz or 48000 Hz before import.
- Prefer one master audio track + `trimBefore`/`trimAfter` over multiple overlapping tracks.
- If drift is unavoidable, use `acceptableTimeShiftInSeconds: 0` to force strict sync
  during Studio review, then revert before production render.

---

## Captions and Kinetic Typography

### Font loading

Load custom fonts before rendering starts using `delayRender` / `continueRender`:

```tsx
import { delayRender, continueRender } from 'remotion'

const handle = delayRender('Loading font')

const font = new FontFace('MyFont', 'url(/fonts/MyFont.woff2)')
document.fonts.add(font)
font.load().then(() => continueRender(handle))
```

Do this in `registerRoot` or in a top-level component, not inside the sequence.
Forgetting `continueRender` hangs the render indefinitely with no error.

### Frame-by-frame text

Drive text content from frame number via a word/segment map:

```tsx
const WORDS = [
  { start: 0, end: 20, text: 'Hello' },
  { start: 20, end: 40, text: 'world' },
]

const frame = useCurrentFrame()
const active = WORDS.find(w => frame >= w.start && frame < w.end)
```

For caption tracks, generate the segment array from an SRT/VTT file at build time
and import as JSON. Do not parse SRT at render time — the parser runs on every frame.

### Kinetic text pattern

```tsx
const frame = useCurrentFrame()
const progress = interpolate(frame, [wordStart, wordStart + 10], [0, 1], {
  extrapolateLeft: 'clamp',
  extrapolateRight: 'clamp',
})
const scale = interpolate(progress, [0, 0.5, 1], [0.8, 1.1, 1])
const opacity = interpolate(progress, [0, 0.3], [0, 1], {
  extrapolateRight: 'clamp',
})

return (
  <span style={{ transform: `scale(${scale})`, opacity, display: 'inline-block' }}>
    {word}
  </span>
)
```

`display: inline-block` is required for `transform` to apply to inline text elements.

---

## 3D with ThreeCanvas / R3F

```tsx
import { ThreeCanvas } from '@remotion/three'
import { useCurrentFrame, useVideoConfig } from 'remotion'

export const Scene = () => {
  const { width, height } = useVideoConfig()
  const frame = useCurrentFrame()

  return (
    <ThreeCanvas width={width} height={height}>
      <ambientLight />
      <mesh rotation={[0, frame / 50, 0]}>
        <boxGeometry />
        <meshStandardMaterial color="hotpink" />
      </mesh>
    </ThreeCanvas>
  )
}
```

Performance budget for 3D:
- Keep polygon count under 100k for smooth preview. Complex scenes slow the studio.
- Avoid `useFrame` from R3F inside Remotion — it fires on animation loop, not on render frame.
  Drive all animation from `useCurrentFrame()` via props passed to the Three scene.
- Do not share WebGL contexts between `ThreeCanvas` instances. Each needs its own.
- Textures loaded via `useTexture` or `TextureLoader` must be inside a `delayRender`
  guard or they will render as black on the first frame.

---

## Performance

### Lazy components

Wrap heavy components in `React.lazy` + `Suspense`. Remotion handles suspense boundaries
during rendering — components that suspend cause the frame to be re-attempted:

```tsx
const HeavyScene = React.lazy(() => import('./HeavyScene'))

<Suspense fallback={null}>
  <HeavyScene />
</Suspense>
```

### Prefetching assets

Use `prefetch` to pre-download media before a sequence starts:

```tsx
import { prefetch } from 'remotion'

useEffect(() => {
  const { free } = prefetch(staticFile('hero.mp4'), { method: 'blob-url' })
  return free
}, [])
```

Call `prefetch` in a parent component, not inside the sequence that uses the asset.

### Parallel renders

CLI concurrency scales linearly with available CPU cores. A rule of thumb: set
`--concurrency` to `(CPU cores - 1)` to leave one core for the OS. On an M2 Pro (10 cores),
`--concurrency=9` is safe. Beyond available cores, concurrency causes memory contention
and reduces throughput.

### Frame caching

The Remotion Studio caches rendered frames. If you change a non-visual prop (e.g., a `name`
on a Sequence), the frame cache does not invalidate. Force re-render with `r` in the studio
or restart the dev server.

---

## Common Bugs

### Hydration mismatch
**Symptom:** Studio shows component but CLI render fails with "Element type is invalid."
**Cause:** Dynamic `require()` or conditional imports that differ between Node and browser.
**Fix:** Use static imports at the top of the file. Never `require` inside a component.

### Frame off-by-one
**Symptom:** Animation appears one frame early or late vs. expected.
**Cause:** `from` is inclusive, `durationInFrames` is exclusive at the end.
A sequence `from={0} durationInFrames={30}` renders frames 0 through 29, not 30.
**Fix:** When computing end frame: `end = start + duration - 1` for inclusive ranges.

### Audio not playing in Studio
**Cause:** Browser autoplay policy blocks audio until user interaction.
**Fix:** Click the play button in the Studio player. Audio will play after first interaction.
This does not affect CLI renders.

### delayRender timeout
**Symptom:** Render hangs forever, no error output.
**Cause:** `continueRender(handle)` was never called (usually because a promise rejected
silently or a font failed to load).
**Fix:** Always wrap `delayRender` usage in try/catch and call `continueRender` in the
catch block too. Set `delayRenderTimeoutInMilliseconds` to a reasonable bound (5000ms).

### useCurrentFrame outside Remotion context
**Symptom:** "useCurrentFrame can only be used inside a Remotion composition" error.
**Cause:** Component is mounted outside a Remotion composition (e.g., in a test or Storybook).
**Fix:** Wrap test renders with `<Internals.RemotionContextProvider>` or mock the hook.

---

## Render CLI Flags

```bash
npx remotion render <composition-id> <output-file> [flags]
```

| Flag | Effect |
|------|--------|
| `--concurrency=N` | Parallel renderer threads. Default: half of CPU cores. |
| `--crf=N` | Constant Rate Factor for H.264/H.265. Lower = higher quality, larger file. H.264 default: 18. |
| `--pixel-format=yuv420p` | Required for maximum browser/device compatibility. Use `yuv444p` for lossless color. |
| `--codec=h264` | Output codec: `h264`, `h265`, `vp8`, `vp9`, `av1`, `prores`, `mp3`, `aac`, `wav`. |
| `--jpeg-quality=N` | JPEG frame quality 0-100. Only applies when codec is JPEG. |
| `--scale=N` | Upscale output (0 < N ≤ 16). Use for Retina export. |
| `--frames=start-end` | Render only a frame range, e.g., `--frames=60-120`. |
| `--every-nth-frame=N` | Render every Nth frame. Useful for GIF previews. |
| `--hardware-acceleration=if-possible` | Enable GPU encode where available. |

For web delivery: `--codec=h264 --crf=18 --pixel-format=yuv420p` is the safe default.

---

## HyperFrames Comparison

HyperFrames (sister tool, OSS) takes static HTML templates and renders them to video via
a headless browser pipeline. Remotion renders React components to video via a Node.js
renderer.

| | Remotion | HyperFrames |
|--|----------|-------------|
| Source format | React TSX components | HTML/CSS templates |
| Animation model | `useCurrentFrame()` + `interpolate()` | CSS animations + JS timeline |
| Asset pipeline | `staticFile()` + `prefetch()` | Template variables + file paths |
| Render target | Lambda, Cloud Run, or local CLI | Local CLI (headless Chrome) |
| Debug workflow | Remotion Studio dev server | Browser preview mode |
| Best for | Programmatic, data-driven video | Designer-authored HTML templates |

If a task involves Remotion and HyperFrames in the same pipeline, use the `hyperframes-debug`
skill for HyperFrames-specific issues and this skill for Remotion-specific issues.

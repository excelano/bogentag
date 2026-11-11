# Bogentag — Spec

Bogentag is the Apple Watch and iPhone app that displays **Bogenzeit (BZ)**. The time standard itself is defined in `bogenzeit-spec.md` in excelano/bogenzeit; Bogentag only decides how it looks. Because the standard is fixed, Bogentag can offer more than one dial. The two dials are named Spans and Kiloseconds, for what the Sun's angle measures on each; Spans is the default. `design/mockups/` holds the drawings they were built to.

---

## 1. Platforms

| Platform | Form | Notes |
|---|---|---|
| Apple Watch | App + complications, which also appear in the Smart Stack | Apple does not allow third-party watch faces, so the app's screen is the dial. |
| iPhone and iPad | App + Home Screen and Lock Screen widgets | The same dial larger, the tour (§5), settings, timer and stopwatch. On an iPhone it offers an Apple face preset that carries the Bogentag complications. |

All Bogenzeit calculation runs on the device showing it, offline; the watch needs neither the phone nor a network.

---

## 2. Interaction

- **Default view: Bogenzeit.**
- **Tap → civil time.** Tapping the face (or opening the app) switches to a civil view: UTC first, since it is the reference and the one time the device shows nowhere else, then local time with its zone and UTC offset, date, and today's sunrise and sunset in local time. Tap again to return. This replaces the day-length view of Apple's Solar Dial, which is less useful.
- The dial stays visible, dimmed, behind the civil readout, so the switch doesn't lose context.

---

## 3. Shared elements (all variants)

- **Anchors:** ☉ at top (solar noon), ○ at bottom (solar midnight), and where the horizon meets the ring of anchors △ standing on it at sunrise and ▽ hanging from it at sunset, absent on a polar day or night. All four are drawn as vector shapes from one definition (BZ spec §3.1 matching rule).
- **Sky:** day above the horizon, then civil, nautical and astronomical twilight bands, then night.
- **Sun marker:** travels a fixed inner track.
- **Eighth ticks:** at the 50-span points (the boundaries of Afterrise/Forenoon/Afternoon/Foreset and Afterset/Foremid/Aftermid/Forerise), and the current eighth's stretch of the outer ring lit in the Sun's color.
- **Center readout:** date; the position in the dial's own unit with its glyph, spans on the Span dial (`17.3 ☉`) and the offset on the Kilosecond dial (`3.43 ks ☉`), never both, the decimals smaller than the whole part and the unit smaller still; eighth name. For the first step after sunrise or sunset the span position is △ or ▽ alone (BZ spec §3.2). A polar day has no spans, so both dials show the offset. Complications and widgets show the unit of the chosen dial.
- **Precision:** one setting, Low, Medium or High, for whichever unit the dial shows: whole spans, one or two decimals; one, two or three decimals of ks (BZ spec §5.2). Medium by default. The readout drops to Low while the watch screen is dimmed, and complications always show Low, as neither refreshes often enough for a finer step.
- **Arc lengths:** on the Kilosecond dial where the screen has room, `DAY ARC 39.6 ks` above the center readout in the sky and `NIGHT ARC 46.7 ks` below it in the night, the English terms on screen and the German ones in the standard. The Span dial has none, since every arc is 200 spans; the watch carries both lengths on its day page.
- **No hour numerals, no civil hands** in the Bogenzeit view.

---

## 4. Variants

### 4.1 Span dial

- Angle tracks spans: each half-arc = 90°, each eighth = 45°. Sunrise is always at 9 o'clock, sunset at 3 o'clock, horizon always level. The dial looks the same every day.
- Outer ring: span ticks, one every 10 spans, the eighth boundaries long, so the ring is in the unit the angle measures.
- The season shows instead in the **twilight bands**, whose depth below the horizon changes with the season.

### 4.2 Kilosecond dial

- Angle tracks real elapsed time: one turn = 86.4 ks, ☉ at top.
- The horizon is a horizontal chord that moves up and down with the seasons; day length is visible as the size of the blue area.
- Outer ring: uniform ks ticks (minor every 1 ks, major every 5 ks from ☉).
- Eighths occupy uneven angles (day eighths smaller in winter).

---

## 5. Onboarding and explanation (iPhone and iPad app)

The app explains Bogenzeit to someone with no context in a paged tour, one page per topic:

1. Time as position on the Sun's arc (Tagbogen and Nachtbogen).
2. ☉ and ○: solar noon and solar midnight, and why they differ from 12:00 and 00:00.
3. Spans: 100 per half-arc, stretching with the seasons.
4. Kiloseconds: the fixed-length counterpart.
5. Reading the notation: number left of the glyph = before, right = after.
6. The four quarters: morning, afternoon, evening, night.
7. The eight eighths, Afterrise to Forerise.
8. Why the date changes at ○.
9. Tap for civil time.

---

## 6. Timer and stopwatch

- **Span timer.** Set in the dial's unit, spans or ks: − and + move 0.1 span or 0.1 ks, presets offer 1, 2, 5 and 10 spans or 0.2, 0.5, 1 and 2 ks, and a tap on the phone's amount types one in, to 0.01 span or 1 s. On the watch they stay hidden until a tap on the amount, which puts − and + above it, the presets below and Done in place of Start. A span timer ends when the clock has moved that many spans on from the moment it starts, carrying past ○ into the next day (BZ spec §3.8), so it lasts longer when its spans are longer: 20 spans started ten spans before sunset take ten day spans and ten night spans. The end is fixed at start for the place in use then, and a local notification announces it.
- **Pause.** A paused span timer keeps the spans it has left, not the seconds, so they take whatever time they take once it runs again.
- **Polar day or night.** No spans, so the timer is set in ks only, and a span timer cannot run across one.
- **Stopwatch.** Counts what passes while it runs, in the dial's unit, with laps.
- **Readouts.** One unit, the dial's, or ks on a polar day or night; a running timer keeps the unit it was set in. At high precision whatever the setting, low while the watch is dimmed. Remaining amounts are rounded up, so the 0 shows only at the end; elapsed amounts are floored like every readout.
- **On the dial.** While a timer runs, an arc in the Sun's color runs along the Sun's track from the Sun to where the timer ends; a running stopwatch draws its arc behind the Sun. On the Span dial a timer's arc is always the same angle for the same spans; on the Kilosecond dial it grows or shrinks with the time the spans take.
- **Where.** Pages of their own on the watch; on the phone, Timer and Stopwatch open as half-height sheets under the dial. Each device keeps its own.

---

## 7. Complications and widgets

Each shows the unit of the chosen dial at Low precision (§3).

- **Reading:** the position beside its glyph.
- **Eighth:** the position and the eighth it falls in.
- **Dial:** the sky and the Sun on its arc; on the watch, without words.
- **Gauge:** how far along its arc the Sun is, with the position inside.
- **Next:** the next anchor or horizon event and how far away it is.
- **Corner** (watch only): the position and its glyph, filling the corner.

The watch offers them in the circular, corner, rectangular and inline families its faces have room for. The iPhone offers Dial on the Home Screen and the Lock Screen, and the others on the Lock Screen.

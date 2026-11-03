# Tagbogen — Spec (draft 0.1)

Tagbogen is the watch face and app family that displays **Bogenzeit (BZ)**. The time standard itself is defined in `bogenzeit-spec.md`; Tagbogen only decides how it looks. Because the standard is fixed, Tagbogen can offer **several dial variants**.

Status: draft. Mockups of variants 1 and 2 are on the Tagbogen design canvas. The variants are named Spans and Kiloseconds, for what the Sun's angle measures on each; Spans is the default.

---

## 1. Platforms

| Platform | Form | Notes |
|---|---|---|
| Wear OS | Full watch face (Watch Face Format) + app | Custom faces are allowed; this is where the full Tagbogen face lives. |
| Apple Watch | App + widgets (Smart Stack) + complications | Apple does not allow third-party watch faces. |
| Phone (both) | Companion app | Explains Bogenzeit; settings; larger dial views. |

All Bogenzeit calculation runs on the watch, offline (no phone or network needed).

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
- **Quarter ticks:** at the 50-span points (the boundaries of Afterrise/Forenoon/Afternoon/Foreset and Afterset/Foremid/Aftermid/Forerise), and the current quarter's stretch of the outer ring lit in the Sun's colour.
- **Center readout:** date; the position in the dial's own unit with its glyph, spans on the Span dial (`17.3 ☉`) and the offset on the Kilosecond dial (`3.43 ks ☉`), never both, the decimals smaller than the whole part and the unit smaller still; quarter name. For the first step after sunrise or sunset the span position is △ or ▽ alone (BZ spec §3.2). A polar day has no spans, so both dials show the offset. Complications and widgets show the unit of the chosen dial.
- **Precision:** one setting, Low, Medium or High, for whichever unit the dial shows: whole spans, one or two decimals; one, two or three decimals of ks (BZ spec §5.2). Medium by default. The readout drops to Low while the watch screen is dimmed, and complications always show Low, as neither refreshes often enough for a finer step.
- **Arc lengths:** on the Kilosecond dial where the screen has room, `DAY ARC 39.6 ks` above the center readout in the sky and `NIGHT ARC 46.7 ks` below it in the night, the English terms on screen and the German ones in the standard. The Span dial has none, since every arc is 200 spans; the watch carries both lengths on its day page.
- **No hour numerals, no civil hands** in the Bogenzeit view.

---

## 4. Variants

### 4.1 Span dial

- Angle tracks spans: each half-arc = 90°, each quarter = 45°. Sunrise is always at 9 o'clock, sunset at 3 o'clock, horizon always level. The dial looks the same every day.
- Outer ring: span ticks, one every 10 spans, the quarter boundaries long, so the ring is in the unit the angle measures.
- The season shows instead in the **twilight bands**, whose depth below the horizon changes with the season.

### 4.2 Kilosecond dial

- Angle tracks real elapsed time: one turn = 86.4 ks, ☉ at top.
- The horizon is a horizontal chord that moves up and down with the seasons; day length is visible as the size of the blue area.
- Outer ring: uniform ks ticks (minor every 1 ks, major every 5 ks from ☉).
- Quarters occupy uneven angles (day quarters smaller in winter).

### 4.3 Further variants (to explore)

To be added later, e.g. a minimal digital face, a complication-only layout, a high-latitude/polar-safe face.

---

## 5. Onboarding and explanation (app)

The app explains Bogenzeit to someone with no context. Planned topics:

1. Time as position on the Sun's arc (Tagbogen and Nachtbogen).
2. ☉ and ○: solar noon and solar midnight, and why they differ from 12:00 and 00:00.
3. Spans: 100 per half-arc, stretching with the seasons.
4. Kiloseconds: the fixed-length counterpart.
5. Reading the notation: number left of the glyph = before, right = after.
6. The eight quarters.
7. Why the date changes at ○.
8. Tap for civil time.

---

## 6. Open decisions

1. Variant names.
2. Watch sizes and shapes to target first (round Wear OS vs rectangular Apple Watch app screens).
3. Always-on (ambient) versions of each variant.
4. Apple Watch widget and complication set.
5. Onboarding format (paged tour, glossary, or both).

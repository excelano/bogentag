# Tagbogen — Spec (draft 0.1)

Tagbogen is the watch face and app family that displays **Bogenzeit (BZ)**. The time standard itself is defined in `bogenzeit-spec.md`; Tagbogen only decides how it looks. Because the standard is fixed, Tagbogen can offer **several dial variants**.

Status: draft. Mockups of variants 1 and 2 are on the Tagbogen design canvas.

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

- **Anchors:** ☉ at top (solar noon), ○ at bottom (solar midnight), drawn as vector shapes from one circle definition (BZ spec §3.1 matching rule).
- **Sky:** day above the horizon, then civil, nautical and astronomical twilight bands, then night.
- **Sun marker:** travels a fixed inner track.
- **Quarter ticks:** at the 50-span points (the boundaries of Afterrise/Forenoon/Afternoon/Foreset and Afterset/Foremid/Aftermid/Forerise).
- **Center readout:** date; large span position with glyph (`18 ☉`); offset `[3.43 ks]`; quarter name.
- **No hour numerals, no civil hands** in the Bogenzeit view.

---

## 4. Variants

### 4.1 Fixed-time dial

- Angle tracks real elapsed time: one turn = 86.4 ks, ☉ at top.
- The horizon is a horizontal chord that moves up and down with the seasons; day length is visible as the size of the blue area.
- Outer ring: uniform ks ticks (minor every 1 ks, major every 5 ks from ☉).
- Quarters occupy uneven angles (day quarters smaller in winter).

### 4.2 Span dial

- Angle tracks spans: each half-arc = 90°, each quarter = 45°. Sunrise is always at 9 o'clock, sunset at 3 o'clock, horizon always level. The dial looks the same every day.
- The season shows instead in:
  - the **outer ks ring**, whose tick spacing differs between day and night (denser where the arc is longer), and
  - the **twilight bands**, whose depth below the horizon changes with the season,
  - plus day and night arc lengths as text (`TAGBOGEN 39.7 ks`, `NACHTBOGEN 46.7 ks`).

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

# Bogenzeit

Bogenzeit (BZ) reads time as position on the Sun's arc instead of as a count of
hours. Solar noon (☉) and solar midnight (○) are the anchors; the readout is in
spans, a hundred per half-arc so that they stretch with the season, and in
kiloseconds, which do not. `18 [3.5 ks] ☉` is eighteen spans and 3.5 ks before
solar noon. The standard is defined in `docs/bogenzeit-spec.md`, and that file
is normative: an implementation that disagrees with it is wrong, and a change to
a definition is a change to the spec first.

Tagbogen is the watch face and app family that displays Bogenzeit, specified in
`docs/tagbogen-spec.md` with mockups in `design/mockups/`.

## What is here

`core/` is the engine and the `bz` command in Rust, with no dependencies. It
computes a reading from a UTC instant and coordinates, offline, using the NOAA
solar position series that every Bogenzeit port implements step for step.

`apple/` holds the Swift engine, a package passing the same vectors, and the
Tagbogen Xcode project: an iPhone app, the Apple Watch app it embeds, and the
watch's complications. The watch app's screen is the dial, since Apple Watch
takes no third-party faces; a tap shows civil time.

`reference/bz_reference.py` is the prototype that defines the algorithm, and the
only thing that writes `vectors/bz_vectors.json`. Every port, in whatever
language, passes those vectors: event times within a second, displayed values
exact. Add a vector by adding a case to the reference and regenerating the file.

## Install and run

    cargo install --path core

    bz now --lat 29.76 --lon -95.37
    bz at 2026-11-01T17:08:00Z --lat 29.76 --lon -95.37
    bz day 2026-11-01 --lat 29.76 --lon -95.37

`now` and `at` print the full timestamp, the quarter, the span length today and
the day's events; `day` prints the day's table of anchors, quarter boundaries,
sunrise, sunset and twilights in time order. `--json` gives either as an object;
`bz --help` has the rest.

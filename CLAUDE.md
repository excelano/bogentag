# CLAUDE.md

Bogenzeit is a time standard and Tagbogen is the watch face that shows it. `docs/bogenzeit-spec.md`
is normative and no definition in it changes without David. `core/` is the Rust engine (crate
`bogenzeit`, imported as `bz`) and the `bz` command; `reference/bz_reference.py` defines the
algorithm and is the only writer of `vectors/bz_vectors.json`, which every port must pass.
`apple/` is the Apple side: the Swift engine as the package `apple/Bogenzeit`, and
`apple/Tagbogen.xcodeproj` with an iPhone app, the watch app it embeds, and the watch app's widgets,
all drawing from `apple/Shared`. HANDOFF.md is the brief the work started from.

## Commands

    cd core
    cargo build
    cargo test                                  # unit tests, the vectors, the boundary steps
    cargo clippy --all-targets -- -D warnings   # must be silent
    cargo fmt --check
    cargo run -- at 2026-11-01T17:08:00Z --lat 29.76 --lon -95.37
    python3 ../reference/bz_reference.py --vectors > ../vectors/bz_vectors.json   # after adding a case

The build directory is the shared one in `~/.cargo/config.toml`, not `target/`.

    cd apple/Bogenzeit && swift test               # the Swift engine against the vectors, on this box
    xcremote build                                  # from the repo root: the iPhone scheme, watch app embedded
    xcremote install                                # onto David's iPhone and watch, as ~/notes/shipping.md says
    xcodebuild test -scheme "Tagbogen Watch App"    # on the Mac, on a watch simulator; reboot the simulator after

A Debug build launched with `--demo` shows Houston on the spec's worked day; `--page span` (or `day`) and
`--civil` pick the page, and `packaging/ios/shots.sh` takes the store screenshots from them.
Releases: the apps in excelano/shipping, run from this directory.

## Rules

A port reproduces the reference step for step, including the declination being taken at solar
noon's UTC hour and minute with the seconds dropped; a port that is "more accurate" fails the
vectors. Displayed spans and kiloseconds are the floor of the signed value, so an anchor or event
shows only once it has been reached. Position replaces sign: number left of the glyph is before,
right is after, no `+` or `−`. The Bogenzeit date changes at solar midnight. Quarter boundaries are
start inclusive. ☉ and ○ in any rendered face are drawn from one circle definition, never from a
font. No hours or minutes anywhere in a Bogenzeit readout. The engine depends on nothing and runs
offline. In the apps every Swift file is Tagbogen's own: only the project scaffolding was copied from a
sibling, and the store text is written for Tagbogen alone, because App Review groups look-alike
submissions as spam. Don't commit, push or publish to any store unless David asks.

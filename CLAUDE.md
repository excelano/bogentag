# CLAUDE.md

Tagbogen is the Apple Watch and iPhone app for Bogenzeit, the time standard whose spec, reference
and vectors are in excelano/bogenzeit; the spec there is normative and no definition in it changes
without David. `Bogenzeit/` is the Swift engine package; `vectors/bz_vectors.json` is a copy of the
standard's file, replaced when the standard regenerates it. `Tagbogen.xcodeproj` builds the iPhone
app, the watch app it embeds and the widgets, all from `Shared/`. `docs/tagbogen-spec.md` is the face
spec and `design/mockups/` the drawings.

## Commands

    cd Bogenzeit && swift test                      # the engine against the vectors, on this box
    xcremote build                                  # the iPhone scheme, watch app embedded
    xcremote install                                # onto David's iPhone and watch, as ~/notes/shipping.md says
    xcodebuild test -scheme "Tagbogen Watch App"    # on the Mac, on a watch simulator; reboot the simulator after

A Debug build launched with `--demo` shows Houston on the spec's worked day; `--page spans` (or `kiloseconds`, `day`,
`settings`, `tour`) and `--civil` pick the page, `--decimals` the offset's decimals, and
`packaging/ios/shots.sh` takes the store screenshots from them. Releases: the apps in
excelano/shipping, run from this directory.

## Rules

The engine reproduces the reference step for step, including the declination being taken at solar
noon's UTC hour and minute with the seconds dropped; an engine that is "more accurate" fails the
vectors. Displayed spans and kiloseconds are the floor of the signed value, so an anchor or event
shows only once it has been reached. Position replaces sign: number left of the glyph is before,
right is after, no `+` or `−`. ☉ and ○ in anything rendered are drawn from one circle definition,
never from a font, in running text included. No hours or minutes in a Bogenzeit readout; the clock
watchOS draws in the corner is Apple's. Every Swift file is Tagbogen's own: only the project
scaffolding was copied from a sibling, and the store text is written for Tagbogen alone, because App
Review groups look-alike submissions as spam. Don't commit, push or publish to any store unless David
asks.

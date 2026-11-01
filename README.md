# Tagbogen

Tagbogen is the Apple Watch and iPhone app that shows Bogenzeit, time read as
position on the Sun's arc: spans from solar noon (☉) or solar midnight (○), a
hundred per half-arc, with kiloseconds as the fixed scale beside them. The
standard, its reference implementation and the test vectors every port passes
live at https://github.com/excelano/bogenzeit; this repository is the face.

Apple Watch takes no third-party faces, so the watch app's screen is the dial:
a sky with its horizon and twilight bands, the Sun on its track, the two anchors
drawn as shapes, and the reading in the centre. A tap shows the civil clock.
Complications put the reading on an Apple face, and the iPhone app shows the
same dial larger with a short tour of the system. `docs/tagbogen-spec.md`
describes the face and `design/mockups/` holds the drawings it was built to.

## What is here

`Bogenzeit/` is the engine as a Swift package, passing the vectors in
`vectors/`, a copy of the standard's file. `Tagbogen.xcodeproj` builds the
iPhone app, the watch app it embeds and the watch app's complications, all from
`Shared/`. `packaging/` holds the store listing, the release notes, the privacy
entry and the screenshot recipes the release apps read.

## Building

    cd Bogenzeit && swift test

The package tests run anywhere Swift does. The apps build with Xcode from the
project at the root; a Debug build launched with `--demo` shows Houston on the
spec's worked day.

# Security Policy

## Reporting a vulnerability

Please report suspected vulnerabilities privately through GitHub Security Advisories at https://github.com/excelano/bogentag/security/advisories/new. If you would rather not use GitHub, email david.anderson@excelano.com instead. I aim to respond within seven days.

Please do not open public issues for security problems.

## Supported versions

The latest release receives fixes. A security fix ships through `main` in a new release on GitHub and, where the app is listed on the App Store, through it; there are no maintained release branches.

## Security model

**Bogentag has no network surface.** The apps make no network request, open no socket and link no networking or analytics code.

**Location is read only with permission, only on the device running the app, and only while the app is on screen.** A new position replaces the one in use only after a move of more than about ten kilometres. The iPhone app and the watch app do not exchange it.

**What it keeps stays on your devices.** The coordinates in use and the display settings are kept in the app's own preferences on each device; on the watch the coordinates are also in a container shared only with the app's own complications. Removing the app from a device removes them from it.

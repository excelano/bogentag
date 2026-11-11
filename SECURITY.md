# Security Policy

## Reporting a vulnerability

Please report suspected vulnerabilities privately, using the **Report a vulnerability** button on the Security tab of this repository. If that button is not there, or you would rather not go through GitHub, email david.anderson@excelano.com instead. I aim to respond within seven days.

Please do not open public issues for security problems.

## Supported versions

The latest release receives security fixes. Older versions are not supported. A fix ships in a new App Store release.

## What Bogentag can access

Bogentag makes no network request, opens no socket and links no networking or analytics code.

It reads location only with permission, only on the device running the app, and only while the app is on screen. A new position replaces the one in use only after a move of more than about ten kilometers. The iPhone app and the watch app do not exchange it. Starting a timer asks for permission to post notifications, and the only one posted is the local notification that announces the timer's end.

## What Bogentag stores

On each device, the coordinates in use and the chosen dial are kept in a container shared only between the app and its own widgets or complications. The precision setting, whether the tour has been seen, and a running timer or stopwatch are kept in the app's own preferences. Removing the app from a device removes all of it from that device.

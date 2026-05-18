# ``WindowKitAppKit``

AppKit and Accessibility implementations plus AX-specific window role metadata.

## Overview

Use WindowKitAppKit when a macOS host app needs live window information or control through AppKit
and Accessibility APIs.

The package provides concrete implementations for WindowKit protocols:

- AppKit-backed factories on `WindowSnapshotQuery` and `WindowHitTester`.
- ``AXWindowFrameController`` for reading and setting window frames.
- ``AXWindowCommandController`` for changing minimized state, full-screen state, and window
  ordering.
- ``AXWindowStateProvider`` for reading live window state through Accessibility.
- ``AXWindowRoleProvider`` and ``WindowRoleProviding`` for reading Accessibility role metadata.
- ``WindowPlacer`` for placing live windows using `WindowPlacement` values.

``WindowRole`` is a classification value for host-app decisions. It does not define placement
rules, presets, automation policy, or app workflows.

``WindowPlacer`` uses forgiving screen selection by default. Pass `allowsScreenFallback: false` to
``WindowPlacer/place(_:for:screen:area:inset:allowsScreenFallback:)`` or
``WindowPlacer/moveToAdjacentScreen(_:for:preservingRelativePosition:allowsScreenFallback:)`` to
throw ``WindowPlacerError/screenNotFound(_:)`` when a requested or current screen cannot be
resolved.

Unsupported Accessibility actions throw ``AXWindowError/unsupportedAction(_:)``. Target-specific
resolution failures include the unresolved `WindowTarget`. Other underlying Accessibility failures
are preserved as ``AXWindowError/underlyingAccessibilityError(_:)``.

Host apps remain responsible for permission onboarding, user-facing prompts, shortcut handling,
automation policy, persistence, telemetry, and privacy disclosures.

WindowKitAppKit does not request permissions, collect analytics, transmit data, or persist window
data by itself. Metadata availability and permission prompts are controlled by macOS and the host
application.

## Topics

### Running Applications

- ``NSRunningApplicationBundleIdentifierProvider``

### Accessibility Implementations

- ``AXWindowFrameController``
- ``AXWindowCommandController``
- ``AXWindowStateProvider``
- ``AXWindowError``

### Placement

- ``WindowPlacer``
- ``WindowPlacerError``

### Roles

- ``WindowRole``
- ``WindowRoleProviding``
- ``AXWindowRoleProvider``

### Screens

- ``NSScreenProvider``

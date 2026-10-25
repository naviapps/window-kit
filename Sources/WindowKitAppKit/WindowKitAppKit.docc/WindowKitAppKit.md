# ``WindowKitAppKit``

AppKit and Accessibility implementations plus AX-specific window role metadata.

## Overview

Use WindowKitAppKit when a macOS host app needs live window information or placement through AppKit
and Accessibility-backed facades.

The package provides live Core Graphics, AppKit, and Accessibility-backed facades and concrete
implementations for WindowKit protocols:

- ``WindowSnapshotQuery`` for Core Graphics window-list snapshots.
- ``WindowHitTester`` for Core Graphics window-list hit testing.
- ``WindowPlacer`` for placing live windows using `WindowPlacement` values.
- Accessibility-backed ``AXWindowController`` for frame, state, command, and role protocols.
- ``WindowRole`` and ``WindowRoleProviding`` for app-facing role metadata.

Host apps should prefer `WindowKit` protocols at their own boundaries and construct
`WindowKitAppKit` concrete adapters where live AppKit or Accessibility access is needed.
``WindowRole`` is role metadata for host decisions; it does not define placement rules, presets,
automation policy, or app workflows.

Use the AppKit-backed query and hit tester when a host app needs current window snapshots:

```swift
import WindowKit
import WindowKitAppKit

let query = WindowSnapshotQuery()
let snapshots = try query.snapshots()
let hitTester = WindowHitTester()
let topmost = hitTester.topmost(at: .zero)
```

The default `WindowPlacer()` converts AppKit screen geometry to Accessibility coordinates, whose
origin is the primary display's top-left corner. Y increases downward, so grid row zero is the top
row and displays above the primary display have negative y coordinates. `AXWindowController`
and Core Graphics window snapshots use that space. `NSScreenProvider` retains AppKit's bottom-left
origin; caller-supplied frame/screen providers and point targets must already agree on coordinates.

When ``AXWindowController`` resolves a known window identifier, it skips elements
invalidated after the application's window list was read. A closed sibling therefore
does not prevent finding the target. If no live element matches, resolution reports
the target as unavailable. Other lookup failures propagate without a retry or a
fallback to the focused window.

## Responsibility Boundary

WindowKitAppKit owns AppKit-backed querying and hit-testing initializers,
Accessibility-backed live window placement helpers, and role metadata.

Host apps remain responsible for permission onboarding, user-facing prompts,
shortcut handling, automation policy, persistence, telemetry, analytics, and
privacy disclosures.

WindowKitAppKit does not request permissions, collect analytics, transmit data, or persist window
data by itself. Metadata availability and permission prompts are controlled by macOS and the host
application.

## Topics

### Querying and Hit Testing

- ``WindowSnapshotQuery``
- ``WindowSnapshotQuery/init(ownerBundleIdentifierProvider:filter:limit:)``
- ``WindowSnapshotQuery/snapshots()``
- ``WindowSnapshotQuery/snapshot(for:)``
- ``WindowSnapshotQueryLimit``
- ``WindowSnapshotQueryError``
- ``WindowHitTester``
- ``WindowHitTester/init(pointTransform:filter:)``
- ``WindowOwnerBundleIdentifierProviding``
- ``WindowOwnerBundleIdentifierProviding/bundleIdentifier(forProcessIdentifier:)``
- ``NSRunningApplicationBundleIdentifierProvider``
- ``NSRunningApplicationBundleIdentifierProvider/init()``
- ``NSRunningApplicationBundleIdentifierProvider/bundleIdentifier(forProcessIdentifier:)``

### Placement

- ``WindowPlacer``
- ``WindowPlacer/init()``
- ``WindowPlacer/init(frameController:screenProvider:)``
- ``WindowPlacer/place(_:for:screen:area:inset:screenFallback:)``
- ``WindowPlacer/moveToAdjacentScreen(_:for:preservingRelativePosition:screenFallback:)``
- ``WindowPlacerError``
- ``NSScreenProvider``
- ``NSScreenProvider/init()``
- ``NSScreenProvider/screens()``

### Accessibility Access

- ``WindowAccessibilityError``
- ``WindowAccessibilityOperation``
- ``WindowAccessibilityOperationFailure``
- ``AXWindowController``
- ``AXWindowController/init()``
- ``AXWindowController/frame(for:)``
- ``AXWindowController/setFrame(_:for:)``
- ``AXWindowController/state(for:)``
- ``AXWindowController/setMinimized(_:isMinimized:)``
- ``AXWindowController/setFullScreen(_:isFullScreen:)``
- ``AXWindowController/raise(_:)``
- ``AXWindowController/lower(_:)``
- ``AXWindowController/role(for:)``

### Roles

- ``WindowRole``
- ``WindowRoleProviding``
- ``WindowRoleProviding/role(for:)``

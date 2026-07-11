# ``WindowKit``

Value models, protocols, hit-testing contracts, and placement geometry for describing macOS
windows.

## Overview

Use WindowKit when you want reusable window value and geometry primitives:

- ``WindowSnapshot`` and ``WindowSnapshotFilter`` for window metadata and filtering contracts.
- ``WindowHitTesting`` and its result models for provider-backed point selection.
- ``WindowPlacement`` and ``WindowPlacementCalculator`` for deterministic geometry.
- ``WindowScreenSelector`` for deterministic screen ordering and target resolution.
- ``WindowScreenMovement`` for deterministic screen-to-screen movement geometry.
- ``WindowTarget`` and control/provider protocols for host-app or platform-specific implementations.
- ``WindowSnapshotProviding``, ``WindowSnapshotResolving``, and ``WindowHitTesting`` for host-app
  window services.

Live query implementations live in `WindowKitAppKit`. WindowKit keeps the reusable value models,
provider protocols, and deterministic geometry helpers platform-neutral.

Create snapshots in tests or host-owned providers without retaining live system objects:

```swift
import CoreGraphics
import WindowKit

let snapshot = WindowSnapshot(
  ownerProcessIdentifier: 42,
  windowIdentifier: 1001,
  ownerName: "Editor",
  ownerBundleIdentifier: "com.example.editor",
  title: "Document",
  frame: CGRect(x: 120, y: 80, width: 900, height: 640)
)
```

## Responsibility Boundary

WindowKit owns window snapshots, query filters, hit-testing protocols and models, placement
geometry, screen-selection primitives, and control/provider protocols.

WindowKit does not request permissions, install event monitors, persist rules,
run shortcuts, own user interface, collect analytics, transmit data, or store
window history. Those responsibilities stay in the host app.

## Topics

### Querying

- ``WindowSnapshotProviding``
- ``WindowSnapshotResolving``
- ``WindowSnapshotFilter``
- ``WindowSnapshotFilter/init(includedOwnerBundleIdentifiers:includedOwnerProcessIdentifiers:includedWindowIdentifiers:excludedOwnerBundleIdentifiers:excludedOwnerProcessIdentifiers:excludedWindowIdentifiers:)``
- ``WindowSnapshotFilter/includes(_:)``
- ``WindowSnapshot``
- ``WindowSnapshot/init(ownerProcessIdentifier:windowIdentifier:ownerName:ownerBundleIdentifier:title:frame:)``

### Hit Testing

- ``WindowHitTesting``
- ``WindowHitTesting/hitTest(at:)``
- ``WindowHitTesting/topmost(at:)``
- ``WindowHitTestResult``
- ``WindowHitTestResult/snapshot``
- ``WindowHitTestResult/missReason``
- ``WindowHitTestMissReason``

### Placement

- ``WindowPlacement``
- ``WindowPlacementCalculator``
- ``WindowPlacementCalculator/frame(for:in:inset:)``

### Screens

- ``WindowScreen``
- ``WindowScreen/init(displayIdentifier:frame:visibleFrame:isMain:)``
- ``WindowScreen/frame(for:)``
- ``WindowScreenProviding``
- ``WindowScreenProviding/screens()``
- ``WindowScreenSelector``
- ``WindowScreenSelector/orderedScreens(from:)``
- ``WindowScreenSelector/screen(for:windowFrame:in:fallback:)``
- ``WindowScreenSelector/index(containing:in:)``
- ``WindowScreenSelector/adjacentIndex(from:direction:screenCount:)``
- ``WindowScreenMovement``
- ``WindowScreenMovement/centerPreservingSize(windowFrame:in:)``
- ``WindowScreenMovement/preservingRelativePosition(windowFrame:from:to:)``
- ``WindowScreenTarget``
- ``WindowScreenArea``
- ``WindowScreenFallback``
- ``WindowScreenCycleDirection``

### Control and Provider Protocols

- ``WindowTarget``
- ``WindowControlling``
- ``WindowFrameProviding``
- ``WindowFrameProviding/frame(for:)``
- ``WindowFrameControlling``
- ``WindowFrameControlling/setFrame(_:for:)``
- ``WindowCommandControlling``
- ``WindowCommandControlling/setMinimized(_:isMinimized:)``
- ``WindowCommandControlling/setFullScreen(_:isFullScreen:)``
- ``WindowCommandControlling/raise(_:)``
- ``WindowCommandControlling/lower(_:)``
- ``WindowState``
- ``WindowState/init(isMinimized:isFullScreen:)``
- ``WindowStateProviding``
- ``WindowStateProviding/state(for:)``

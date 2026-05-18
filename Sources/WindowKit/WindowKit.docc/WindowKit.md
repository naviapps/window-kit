# ``WindowKit``

Core Graphics-backed window-list querying and value models for hit-testing, placement, and
describing macOS windows.

## Overview

Use WindowKit when you want reusable window-list and geometry primitives:

- ``WindowSnapshot`` and ``WindowSnapshotQuery`` for window metadata.
- ``WindowHitTester`` for point-based selection.
- ``WindowPlacement`` and ``WindowPlacementCalculator`` for deterministic geometry.
- ``WindowScreenSelector`` for deterministic screen ordering and target resolution.
- ``WindowScreenMovement`` for deterministic screen-to-screen movement geometry.
- ``WindowTarget`` and control/provider protocols for host-app or platform-specific implementations.
- ``WindowSnapshotProviding`` and ``WindowHitTesting`` for testable host-app services.

Window snapshots are immutable app-facing models for filtering, hit-testing, placement decisions,
and deterministic tests without holding live system references. Snapshots include minimized
metadata when macOS provides it.
``WindowSnapshotQuery/snapshots()`` throws ``WindowSnapshotQueryError/listUnavailable`` when macOS
does not return a readable window list.
``WindowSnapshotQuery/snapshot(for:)`` reads a single known Core Graphics window identifier and
still applies the query filter.

``WindowSnapshotFilter`` include sets act as allow-lists when non-empty. Exclude sets are applied
after include sets. ``WindowSnapshotQuery`` can also keep the first matching entry in the order
returned by the macOS window list.

``WindowPlacementCalculator`` clamps insets to the available area. Grid placements clamp invalid
columns, rows, and spans into the available grid. Grid columns start from the left, and rows start
from the bottom in the selected screen-area coordinate space. Centered placements clamp width and
height ratios to `0...1`.

``WindowScreenTarget/containingWindow`` selects the screen containing the target window center.
WindowKit screen-selection primitives support forgiving fallback semantics so host apps can decide
whether a missing screen is recoverable or exceptional at their integration boundary.

WindowKit does not request permissions, install event monitors, persist rules, run shortcuts, or own
user interface.
Those responsibilities stay in the host app.

## Topics

### Querying

- ``WindowSnapshotQuery``
- ``WindowSnapshotProviding``
- ``WindowSnapshotQueryError``
- ``WindowSnapshotFilter``
- ``WindowSnapshot``
- ``WindowOwnerBundleIdentifierProviding``
- ``NullWindowOwnerBundleIdentifierProvider``

### Hit Testing

- ``WindowHitTester``
- ``WindowHitTesting``
- ``WindowHitTestResult``
- ``WindowHitTestMissReason``

### Placement

- ``WindowPlacement``
- ``WindowPlacementCalculator``

### Screens

- ``WindowScreen``
- ``WindowScreenProviding``
- ``WindowScreenSelector``
- ``WindowScreenMovement``
- ``WindowScreenTarget``
- ``WindowScreenArea``
- ``WindowScreenCycleDirection``

### Control and Provider Protocols

- ``WindowTarget``
- ``WindowFrameProviding``
- ``WindowFrameControlling``
- ``WindowCommandControlling``
- ``WindowState``
- ``WindowStateProviding``

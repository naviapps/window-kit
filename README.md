# WindowKit

[![CI](https://github.com/naviapps/window-kit/actions/workflows/ci.yml/badge.svg)](https://github.com/naviapps/window-kit/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Swift versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fnaviapps%2Fwindow-kit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/naviapps/window-kit)
[![Supported platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fnaviapps%2Fwindow-kit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/naviapps/window-kit)

WindowKit is a Swift package for macOS window models, hit-testing contracts, placement geometry,
live window discovery, and live window control.
It is a foundation library for building window managers, tiling tools, automation utilities, and
productivity apps.

It focuses on reusable window primitives rather than app workflows. Host apps are responsible for
permissions onboarding, gesture recognition, persistence, shortcuts, UI, and automation policy.

The package is split into two libraries:

- `WindowKit`: window snapshots, filters, hit-testing contracts, screen models, placement values, and
  control/provider protocols.
- `WindowKitAppKit`: live Core Graphics, AppKit, and Accessibility-backed facades for querying,
  hit-testing, and placement.

## Why WindowKit?

- Clean separation between reusable window value/geometry contracts and live Core Graphics,
  AppKit, or Accessibility integrations.
- Explicit host-app responsibility boundaries for permissions, shortcuts, persistence, UI, and
  automation policy.
- Protocol-based window abstractions for host apps that need deterministic geometry checks.
- Point-based hit-testing for cursor-based window discovery.
- Reusable placement and screen-movement primitives for deterministic window geometry.

## Use Cases

WindowKit can serve as the window systems layer beneath:

- tiling window managers and keyboard-driven layout tools
- cursor-based window pickers and snap tools
- launcher extensions that need focused-window or point-based window actions
- automation utilities that need deterministic geometry and Accessibility-backed control

## Architecture

```text
Host App
  |
  v
WindowKit
  models, filters, hit-testing contracts, placement, control/provider protocols
  |
  | contracts
  v
WindowKitAppKit
  Core Graphics queries, AppKit screens, running applications, AX controllers, role metadata
  |
  v
macOS AppKit / Accessibility APIs
```

## Requirements

- macOS 14 or later
- Swift 6.0 or later

## Installation

Add this package to your Swift Package dependencies:

```swift
.package(url: "https://github.com/naviapps/window-kit.git", from: "2.0.0")
```

Then add the product that matches your use case. Use `WindowKit` by itself for models, protocols,
hit-testing abstractions, and geometry. Add both products when you use live Core Graphics, AppKit,
or Accessibility integration:

```swift
.product(name: "WindowKit", package: "window-kit"),
.product(name: "WindowKitAppKit", package: "window-kit"),
```

## Documentation

- [WindowKit API reference](https://swiftpackageindex.com/naviapps/window-kit/documentation/windowkit)
- [WindowKitAppKit API reference](https://swiftpackageindex.com/naviapps/window-kit/documentation/windowkitappkit)

## Basic Usage

Use `WindowKit` when you need window models, protocols, and geometry:

```swift
import CoreGraphics
import WindowKit

let screen = WindowScreen(
  frame: CGRect(x: 0, y: 0, width: 1440, height: 900),
  visibleFrame: CGRect(x: 0, y: 44, width: 1440, height: 812)
)
let frame = WindowPlacementCalculator.frame(
  for: .grid(columns: 2, rows: 1, column: 0, row: 0, columnSpan: 1, rowSpan: 1),
  in: screen.visibleFrame,
  inset: 8
)
```

Use `WindowKitAppKit` when you want live macOS integration:

```swift
import CoreGraphics
import WindowKit
import WindowKitAppKit

@MainActor
func placeFocusedWindow() throws -> (selected: WindowSnapshot?, topmost: WindowSnapshot?) {
  let query = WindowSnapshotQuery()

  let snapshots = try query.snapshots()
  let firstWindowIdentifier = snapshots.first?.windowIdentifier
  let selectedSnapshot = try firstWindowIdentifier.flatMap { try query.snapshot(for: $0) }
  let hitTester = WindowHitTester()
  let mouseLocation = CGPoint(x: 120, y: 80)
  let topmost = hitTester.topmost(at: mouseLocation)

  let placer = WindowPlacer()
  try placer.place(
    .grid(columns: 2, rows: 1, column: 1, row: 0, columnSpan: 1, rowSpan: 1),
    for: .focused
  )
  return (selectedSnapshot, topmost)
}
```

Window snapshots are immutable app-facing models for filtering, hit-testing, placement decisions,
and deterministic tests without holding live system references.
Snapshots include the process identifier, Core Graphics window identifier, owner metadata, title,
and a finite standardized frame.
In `WindowKitAppKit`, `WindowSnapshotQuery.snapshots()` throws
`WindowSnapshotQueryError.windowListUnavailable` when macOS does not return a readable window list.
`WindowSnapshotQuery.snapshot(for:)` reads a single known Core Graphics window identifier and still
applies the query filter.
Use `WindowSnapshotProviding` when host-app services should depend on a mockable snapshot source
instead of a concrete query, and `WindowSnapshotResolving` when they only resolve a known window.

`WindowSnapshotFilter` supports both include and exclude sets for owner bundle identifiers, owner
process identifiers, and window identifiers. Include sets are allow-lists when non-empty; exclude
sets are applied after include sets. The AppKit query can also limit snapshots to the first matching
entry in the order returned by the macOS window list. Use `WindowSnapshotFilter.includes(_:)` when
host-owned providers need the same deterministic filtering semantics without depending on
`WindowKitAppKit`.

Hit-testing is available through the same small app-facing facade shown above. Use
`WindowHitTesting` when host-app services should depend on a mockable hit-testing source instead of a
concrete hit tester.

## Responsibility Boundary

WindowKit owns platform-neutral window values, placement calculations, screen selection, and
protocol contracts. WindowKitAppKit owns AppKit and Accessibility-backed live adapters.

WindowKit intentionally does not own:

- permission request or onboarding UI
- gesture recognition or input monitoring
- window rule engines, presets, or user preference persistence
- application activation policy
- animation history or app-specific workflow coordination

Those concerns should live in the host app or a package with that direct responsibility.

## Placement and Screens

`WindowPlacementCalculator` clamps insets to the available area. Grid placements clamp invalid
columns, rows, and spans into the available grid. Grid columns start from the left, and rows start
from the bottom in the selected screen-area coordinate space. Centered placements clamp width and
height ratios to `0...1`.

`WindowScreen` standardizes full and visible frames at construction.
`WindowScreenTarget.containingWindow` selects the screen containing the target window center.
WindowKit screen-selection primitives support forgiving fallback semantics so host apps can decide
whether a missing screen is recoverable or exceptional.
Use `WindowScreenSelector` when custom host-app controllers need the same deterministic screen
ordering and target resolution as `WindowPlacer`; selector APIs order input screen lists before
applying ordered-index and fallback selection.
Use `WindowScreenMovement` when custom host-app controllers need the same finite, deterministic
screen-to-screen movement geometry without using live Accessibility control.

In `WindowKitAppKit`, `WindowPlacer` uses forgiving screen selection by default. When screens exist
but a requested point, display identifier, ordered index, or current window screen cannot be
matched, placement and screen moves fall back instead of throwing. An empty screen list always
throws. Pass `screenFallback: .none` to
`WindowPlacer.place` or `WindowPlacer.moveToAdjacentScreen` when a missing screen should throw
`WindowPlacerError.screenNotFound`.

## Accessibility

`WindowKitAppKit` uses macOS Accessibility APIs for live window control. Host apps are responsible
for declaring and guiding the required permissions, handling denied access, and choosing when to
prompt users.

Window discovery, querying, and hit-testing read window metadata returned by macOS, including
process identifiers, app names, bundle identifiers, window titles, and frames for standard-layer
windows. Host apps are responsible for their own privacy disclosures,
logging choices, and any Screen Recording or Accessibility permission flows needed by their
product.

Raw AX resolver details are implementation details. The public Accessibility-backed
`AXWindowController` surfaces app-facing failures through `WindowAccessibilityError`, with
application and window resolution failures preserving the `WindowTarget` that could not be
resolved. Each failure includes a `WindowAccessibilityOperation`; underlying failures are further
classified by `WindowAccessibilityOperationFailure` instead of raw AX error values.
Unrecognized future AXError values are surfaced as
`WindowAccessibilityOperationFailure.unrecognizedAXError`.
AX success reported through a failure path is surfaced as
`WindowAccessibilityOperationFailure.unexpectedSuccess` instead of exposing success as a failure.
Unmatched window role metadata is represented as
`WindowRole.unclassified(accessibilityRole:accessibilitySubrole:)` so host apps can inspect the raw
Accessibility role labels without treating them as a known classification.
Role-unavailable values are not classified from subrole metadata alone.
Host apps should depend on the `WindowKit` protocols and construct the public `WindowKitAppKit`
adapters only at their live system boundary.

The package does not request permissions, collect analytics, transmit data, or persist window data
by itself.

## Development

Run the package check with:

```sh
make check
```

GitHub Actions runs the same check on pull requests and pushes to `main`.

`WindowKit` models, protocols, hit-testing abstractions, and geometry primitives are designed to be
tested without live Core Graphics, AppKit, or Accessibility dependencies. `WindowKitAppKit` keeps
live system behavior behind small controllers and providers so host apps can substitute their own
implementations in tests.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Release notes are in [CHANGELOG.md](CHANGELOG.md).

## Security

Report vulnerabilities privately. See [SECURITY.md](SECURITY.md).

## License

WindowKit is released under the MIT License. See [LICENSE](LICENSE).

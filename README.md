# WindowKit

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![CI](https://github.com/naviapps/window-kit/actions/workflows/ci.yml/badge.svg)](https://github.com/naviapps/window-kit/actions/workflows/ci.yml)
[![Swift versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fnaviapps%2Fwindow-kit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/naviapps/window-kit)
[![Supported platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fnaviapps%2Fwindow-kit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/naviapps/window-kit)

WindowKit is a Swift package for macOS window discovery, querying, hit-testing, placement, and
live window control.
It is a foundation library for building window managers, tiling tools, automation utilities, and
productivity apps.

It focuses on reusable window primitives rather than app workflows. Host apps are responsible for
permissions onboarding, gesture recognition, persistence, shortcuts, UI, and automation policy.

The package is split into two libraries:

- `WindowKit`: window snapshots, querying, hit-testing, screen models, placement values, and
  control/provider protocols.
- `WindowKitAppKit`: live AppKit and Accessibility implementations plus AX-specific window role
  metadata.

## Why WindowKit?

- Clean separation between Core Graphics-backed window-list primitives and live AppKit or
  Accessibility integrations.
- Explicit host-app responsibility boundaries for permissions, shortcuts, persistence, UI, and
  automation policy.
- Testable window abstractions for host apps that need mocks or deterministic geometry checks.
- Point-based hit-testing for cursor-based window discovery.
- Reusable placement and screen-movement primitives for deterministic window geometry.

## Architecture

```text
Host App
  |
  v
WindowKit
  window-list queries, models, hit-testing, placement, control/provider protocols
  |
  | contracts
  v
WindowKitAppKit
  AppKit screens, running applications, AX window controllers, role metadata
  |
  v
macOS AppKit / Accessibility APIs
```

## Requirements

- macOS 12 or later
- Swift 5.10 or later

## Installation

Once published, add this package to your Swift Package dependencies:

```swift
.package(url: "https://github.com/naviapps/window-kit.git", from: "0.1.0")
```

Then add the product that matches your use case. Use `WindowKit` by itself for window-list
querying, models, hit-testing, and geometry. Add both products when you use live AppKit or
Accessibility integration:

```swift
.product(name: "WindowKit", package: "window-kit"),
.product(name: "WindowKitAppKit", package: "window-kit"),
```

## Basic Usage

Use `WindowKit` when you need window-list querying, window models, and geometry:

```swift
import WindowKit

let calculator = WindowPlacementCalculator()
let frame = calculator.frame(
  for: .leftHalf,
  in: screen.visibleFrame,
  inset: 8
)
```

Use `WindowKitAppKit` when you want live macOS integration:

```swift
import WindowKit
import WindowKitAppKit

let query = WindowSnapshotQuery.appKit(
  filter: WindowSnapshotFilter(excludesMinimizedWindows: true)
)

let snapshots = try query.snapshots()
let snapshot = try query.snapshot(for: windowIdentifier)
let placer = WindowPlacer()
try placer.place(.rightHalf, for: .focused)
let state = try AXWindowStateProvider().state(for: .focused)
```

Window snapshots are immutable app-facing models for filtering, hit-testing, placement decisions,
and deterministic tests without holding live system references.
Snapshots include the process identifier, Core Graphics window identifier, owner metadata, title,
frame, layer, and minimized metadata when macOS provides it.
`WindowSnapshotQuery.snapshots()` throws `WindowSnapshotQueryError.listUnavailable` when macOS
does not return a readable window list.
`WindowSnapshotQuery.snapshot(for:)` reads a single known Core Graphics window identifier and still
applies the query filter.
Use `WindowSnapshotProviding` when host-app services should depend on a mockable snapshot source
instead of a concrete query.

`WindowSnapshotFilter` supports both include and exclude sets for owner bundle identifiers, owner
process identifiers, and window identifiers. Include sets are allow-lists when non-empty; exclude
sets are applied after include sets. `WindowSnapshotQuery` can also limit snapshots to the first
matching entry in the order returned by the macOS window list.

Hit-testing is available through a small app-facing facade:

```swift
let hitTester = WindowHitTester.appKit()
let snapshot = hitTester.topmost(at: mouseLocation)
```

Use `WindowHitTesting` when host-app services should depend on a mockable hit-testing source instead
of a concrete hit tester.

## Responsibility Boundary

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

`WindowScreenTarget.containingWindow` selects the screen containing the target window center.
WindowKit screen-selection primitives support forgiving fallback semantics so host apps can decide
whether a missing screen is recoverable or exceptional.
Use `WindowScreenSelector` when custom host-app controllers need the same deterministic screen
ordering and target resolution as `WindowPlacer`.
Use `WindowScreenMovement` when custom host-app controllers need the same deterministic
screen-to-screen movement geometry without using live Accessibility control.

In `WindowKitAppKit`, `WindowPlacer` uses forgiving screen selection by default. When a requested
point, display identifier, ordered index, or current window screen cannot be matched, placement and
screen moves fall back instead of throwing. Pass `allowsScreenFallback: false` to
`WindowPlacer.place` or `WindowPlacer.moveToAdjacentScreen` when a missing screen should throw
`WindowPlacerError.screenNotFound`.

## Accessibility

`WindowKitAppKit` uses macOS Accessibility APIs for live window control. Host apps are responsible
for declaring and guiding the required permissions, handling denied access, and choosing when to
prompt users.

AX window operations throw `AXWindowError` for permission failures, missing windows, invalid
Accessibility values, and underlying AX errors.
Target-specific resolution failures include the `WindowTarget` that could not be resolved.

Window discovery, querying, and hit-testing read window metadata returned by macOS, including
process identifiers, app names, bundle identifiers, window titles, frames, and layers when the
system makes those fields available. Host apps are responsible for their own privacy disclosures,
logging choices, and any Screen Recording or Accessibility permission flows needed by their
product.

The package does not request permissions, collect analytics, transmit data, or persist window data
by itself.

## Development

Local development commands use `just`.

Run all local checks:

```sh
just check
```

`WindowKit` querying, hit-testing, and geometry primitives are designed to be tested without live
AppKit or Accessibility dependencies. `WindowKitAppKit` keeps AppKit and Accessibility behavior
behind small controllers and providers so host apps can substitute their own implementations in
tests.

For focused local work, run `just lint` or `just test`. The GitHub Actions CI runs the same checks
as `just check` on pull requests and pushes to `main`.

## License

WindowKit is released under the MIT License. See [LICENSE](LICENSE).

# Changelog

All notable user-facing changes to WindowKit will be documented in this file.

Released versions follow semantic versioning.

## [Unreleased]

No changes yet.

## [2.0.0] - 2026-07-12

### Breaking

- Moved live Core Graphics window-list querying from `WindowKit` to `WindowKitAppKit`.
  Consumers that construct `WindowSnapshotQuery` or use `WindowSnapshotQueryError` must import
  `WindowKitAppKit`.
- Replaced `WindowSnapshotQuery` Boolean topmost limiting with the typed
  `WindowSnapshotQueryLimit` contract.
- Moved the concrete `WindowHitTester` from `WindowKit` to `WindowKitAppKit`; `WindowKit` now keeps
  only the platform-neutral `WindowHitTesting` contract and result models.
- Replaced screen-selection Boolean fallback parameters with the typed `WindowScreenFallback`
  contract.
- Removed fixed `WindowPlacement` convenience cases such as `leftHalf`, `rightHalf`, and thirds/quarters.
  Use `WindowPlacement.grid(columns:rows:column:row:columnSpan:rowSpan:)` for fixed regions and
  `WindowPlacement.centered(widthRatio:heightRatio:)` for centered sizing so placement has one
  canonical representation instead of duplicated public cases.
- Removed the redundant `WindowSnapshotQuery.appKit(...)` factory. Use `WindowSnapshotQuery(...)`
  directly from `WindowKitAppKit`.
- Collapsed `WindowSnapshotQuery` public initializer overloads into one initializer with default
  system dependencies.
- Moved `WindowOwnerBundleIdentifierProviding` from `WindowKit` to `WindowKitAppKit` because owner
  bundle identifier lookup is an AppKit-backed process metadata concern, not a core snapshot model.
- Renamed the public Accessibility failure surface to `WindowAccessibilityError`.
- Replaced action-only Accessibility error context with the typed `WindowAccessibilityOperation`
  contract for frame, state, command, and role operations.
- Changed `WindowAccessibilityError.accessibilityOperationFailed` to preserve both the operation and
  its typed `WindowAccessibilityOperationFailure` classification.
- Renamed `WindowAccessibilityOperationFailure.unknown` to `unrecognizedAXError` to make
  future/unsupported AXError mapping explicit.
- Renamed `WindowAccessibilityOperationFailure.success` to `unexpectedSuccess` so the public
  failure classification does not expose success as a failure case.
- Replaced the ambiguous `WindowAccessibilityError.targetWindowUnavailable` case with
  `applicationUnavailable(WindowTarget)` and `windowUnavailable(WindowTarget)` so public errors keep
  the target context that failed.
- Renamed `WindowRole.unknown(role:subrole:)` to
  `unclassified(accessibilityRole:accessibilitySubrole:)` so unmatched role metadata keeps explicit
  Accessibility labels instead of a vague unknown case.
- Stopped classifying role-unavailable windows from subrole metadata alone; those partial
  Accessibility values now remain `WindowRole.unclassified(accessibilityRole:accessibilitySubrole:)`.
- Removed `UnavailableWindowOwnerBundleIdentifierProvider`. Hosts that intentionally omit bundle
  identifiers should provide their own `WindowOwnerBundleIdentifierProviding` implementation.
- Split single-window resolution from `WindowSnapshotProviding` into
  `WindowSnapshotResolving`, so consumers depend only on the query capability they use.
- Removed snapshot layer and minimized-state fields that the standard-layer Core Graphics query did
  not meaningfully expose; live minimized state remains available through `WindowStateProviding`.
- Replaced separate public AX frame, state, command, and role adapters with one
  `AXWindowController` conforming to the narrow protocols and the composed `WindowControlling` API.

### Changed

- Updated installation guidance to use the 2.0.0 release line.
- Raised the package requirements to macOS 14 and Swift 6.0.
- Expanded DocC documentation and public API tests for WindowKit and WindowKitAppKit.
- Refined snapshot filtering around included and excluded owner, process, and window identifiers.
- Added `WindowSnapshotFilter.includes(_:)` so host-owned providers and AppKit adapters share the
  same pure snapshot-filtering contract.
- Added zero-argument `WindowState()` construction for unknown live state values.
- Made `WindowScreenSelector` order input screen lists before applying ordered-index and fallback
  selection, so callers do not need to pre-sort screens for deterministic selection.
- Made `WindowPlacementCalculator` a stateless static API.
- Made missing screen lists fail explicitly instead of reporting successful placement without a
  mutation.
- Consolidated AppKit window-list hit testing into the public `WindowHitTester` implementation.
- Consolidated Accessibility client and resolver assembly into an internal `AXWindowAccess` boundary
  so live adapters share one system setup path.
- Matched Accessibility window-id resolution against the returned Core Graphics window identifier
  before using owner process metadata.
- Tightened Accessibility window-id attribute decoding so non-number, fractional, negative, and
  out-of-range values fail instead of being rounded into a `UInt32`.
- Rejected non-finite Accessibility frame coordinates and dimensions before creating AX values.
- Built Accessibility frame position and size values before writing either attribute, so conversion
  failures do not partially update a live window frame.
- Preserved unknown Accessibility role metadata even when a known subrole label is present, so
  app-facing role classification does not narrow future role kinds prematurely.
- Added focused-window placement coverage for WindowPlacer.
- Exposed `NSScreenProvider` as the AppKit-backed `WindowScreenProviding` adapter.
- Exposed `AXWindowController` as the AppKit-backed window control and role adapter.
- Expanded generated-output exclusions for local tool state.
- Added README links to release notes.
- Clarified that security updates target the latest released version.

## [1.0.0] - 2026-05-19

### Added

- Initial public release.
- Included window discovery, querying, hit-testing, placement, screen movement, and live
  AppKit/Accessibility integrations.

## [0.1.0] - 2026-05-19

### Added

- Initial public package release.

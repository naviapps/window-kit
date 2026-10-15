# AGENTS.md

## Scope and sources of truth

- This repository owns WindowKit, WindowKitAppKit. Keep reusable mechanism here and product policy in the host app.
- Read [README.md](README.md) for integration contracts and the repository map.
- `Package.swift` defines products, targets, platform requirements, and dependency resolution. `Makefile` and `.github/workflows` define the checks.
- Read the relevant local API catalog before changing a public contract:
  - [WindowKit](Sources/WindowKit/WindowKit.docc/WindowKit.md)
  - [WindowKitAppKit](Sources/WindowKitAppKit/WindowKitAppKit.docc/WindowKitAppKit.md)
- Read [SECURITY.md](SECURITY.md) before changing sensitive-data or live-system boundaries.

## Contracts to preserve

- Keep live queries and AX operations in WindowKitAppKit; host policy depends on WindowKit protocols.
- Preserve coordinate conventions, finite geometry normalization, screen ordering, and explicit fallback policy.
- Keep window-query failures and target-specific Accessibility failures typed; do not turn unavailable metadata into successful results.
- Permission onboarding, application activation, presets and workflow coordination belong in the host.

## Change and validation

- Keep README examples and DocC symbols aligned with the implementation. Historical CHANGELOG entries describe released behavior; do not rewrite them to match a newer API.
- Use `make check` before a PR; it covers formatting, Debug/Release builds and strict-concurrency tests.
- Use injected providers and fixtures for effects. Report live OS/provider checks separately from deterministic tests.
- Do not hand-edit `.build`, generated projects/DocC output, dependency caches, or local secret files.

# Contributing

Thank you for your interest in improving WindowKit.

## Scope

WindowKit focuses on macOS window discovery, querying, hit-testing, screen selection, placement
geometry, and live AppKit or Accessibility window control.
Host-app workflows such as permissions onboarding, shortcuts, persistence, UI, and automation
policy should stay outside this package.

Please keep changes focused. Avoid bundling unrelated refactors, formatting-only rewrites, and
behavior changes in the same pull request.

## Development

Local development commands use `just`.

Run the full local check before opening a pull request:

```sh
just check
```

For focused local work, you can run the formatter check or test suite separately:

```sh
just lint
just test
```

## Pull Requests

Before submitting a pull request:

- Keep the public API surface minimal and documented.
- Add or update tests for behavior changes.
- Update documentation or `CHANGELOG.md` when needed.
- Do not commit generated build output or local tool state such as `.build/`, `.swiftpm/`, or
  `.serena/`.
- Do not include secrets, tokens, private keys, local paths, window titles from real users, or
  app-specific internal references.

## Security

Do not report vulnerabilities in public issues or pull requests. Follow
[SECURITY.md](SECURITY.md) instead.

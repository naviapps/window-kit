---
name: Bug report
about: Report a reproducible WindowKit bug
title: "[Bug]: "
labels: bug
assignees: ""
---

## Summary

Describe the issue in one or two sentences.

Do not include vulnerability details or sensitive data in public issues. Follow `SECURITY.md` for
security reports.

## Environment

- WindowKit version or commit:
- macOS version:
- Swift or Xcode version:
- Affected area: WindowKit / WindowKitAppKit / documentation / not sure
- Reproducibility: always / sometimes / once

Optional, if relevant:

- Installation method: Swift Package Manager / other
- Mac architecture: Apple silicon / Intel
- Sandboxed app: yes/no
- Display setup: single display / multiple displays / scaled display / external display

## Reproduction

Provide the smallest code sample or test case that reproduces the issue.
Use placeholders instead of private app names, bundle identifiers, process identifiers, window
titles, logs, secrets, tokens, or personal data.

1.
2.
3.

## Expected Behavior

Describe the window snapshot, hit-test result, placement frame, screen selection, window state,
role metadata, or thrown error you expected.

## Actual Behavior

Include the exact error, thrown error type, failing assertion, or relevant public API result.
Redact sensitive values.

## Additional Context

Optional: Add any other public, non-sensitive context that helps explain the issue.
If useful, mention whether it reproduces with `WindowKit` only, `WindowKitAppKit`, Accessibility
permission granted or denied, a focused-window target, or a specific Core Graphics window
identifier.

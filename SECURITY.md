# Security Policy

## Supported Versions

Security updates are provided for the latest released version.

## Reporting a Vulnerability

Report security issues through GitHub private vulnerability reporting for this repository.

Do not open a public issue, pull request, or discussion for vulnerabilities, suspected credential
exposure, privacy-sensitive behavior, or issues that could expose private user data.

If private vulnerability reporting is unavailable, open a public issue asking for a private
security contact channel. Do not include vulnerability details, exploit steps, logs, secrets,
tokens, private keys, personal data, local paths, private app metadata, or app-specific internal
references.

For private reports, include:

- Affected package version or commit
- Affected dependency versions if relevant
- A clear description of the behavior
- Reproduction steps or a minimal proof of concept
- Expected impact
- Affected public API, target, or subsystem

Use placeholders instead of secrets, tokens, private keys, personal data, local paths, private app
metadata, or app-specific internal references.

We will acknowledge valid reports as soon as practical and coordinate fixes before public
disclosure.

## Scope

Security-sensitive areas include:

- Live Accessibility window control
- Window metadata returned by macOS APIs
- Hit-testing and focused-window selection
- Window placement and screen-selection behavior
- Window metadata exposed to host apps, such as titles, app names, bundle identifiers, or process
  identifiers

WindowKit does not collect, transmit, or persist window data by itself. Host applications are
responsible for permission onboarding, logging, telemetry, privacy disclosures, and any Screen
Recording or Accessibility permission flows. Window metadata availability and permission prompts
are controlled by macOS and the host application, not by this package.

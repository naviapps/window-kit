# Security Policy

## Supported Versions

Before the first public release, security fixes target the default branch. After the first public
release, security updates are provided for the latest released version of WindowKit.

## Reporting a Vulnerability

Please report security issues through GitHub's private vulnerability reporting for this repository.

Do not open a public GitHub issue or pull request for vulnerabilities, suspected credential
exposure, privacy-sensitive behavior, or local window data exposure.

If private vulnerability reporting is not enabled, open a public issue asking for a private security
contact channel, but do not include vulnerability details, exploit steps, logs, secrets, tokens,
private app names, bundle identifiers, process identifiers, window titles, or personal data.

When reporting an issue, include:

- Affected package version or commit
- A clear description of the behavior
- Reproduction steps or a minimal proof of concept
- Expected impact and affected window, screen, hit-testing, or Accessibility behavior

We will acknowledge valid reports as soon as practical and coordinate fixes before public
disclosure.

For non-security bugs, use the public bug report template.

## Scope

Security-sensitive areas include:

- Live Accessibility window control
- Window metadata returned by macOS APIs
- Hit-testing and focused-window selection
- Window metadata exposed to host apps, such as titles, app names, bundle identifiers, or process
  identifiers

WindowKit does not collect, transmit, or persist window data by itself. Host applications are
responsible for their own permission onboarding, logging, telemetry, and privacy policies.
Window metadata availability and permission prompts are controlled by macOS and the host
application, not by this package.

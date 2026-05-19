# Diary App

A Flutter-based personal diary app for writing, reviewing, and reflecting on entries.

[![Flutter CI](https://github.com/Shir0o/diary/actions/workflows/flutter.yml/badge.svg)](https://github.com/Shir0o/diary/actions/workflows/flutter.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Features

- **Diary Timeline:** Chronological view of diary entries with mood indicators and location tags.

## Development

### Environment

Create a local `.env` file before running the app:

```bash
cp .env.example .env
```

Fill in the Google OAuth client IDs for the platforms you are testing. The
local `.env` file is intentionally gitignored.

### Standards
This project follows strict Test-Driven Design (TDD) and documentation standards as defined in [GEMINI.md](GEMINI.md).

### Running Tests

To run the full local test suite (unit, widget, and golden tests):
```bash
flutter test
```

CI runs the same tests _except_ the golden suite — see [Continuous Integration](#continuous-integration) below.

### Visual Validation

To run integration tests and perform visual validation (requires an emulator/device):
```bash
flutter test integration_test/app_test.dart
```

### Continuous Integration

The [`Flutter CI`](.github/workflows/flutter.yml) workflow runs on every push to `main` and on pull requests targeting `main`. It performs:
- `dart format --output=none --set-exit-if-changed .` — formatting check
- `flutter analyze` — static analysis (fails on errors, warnings, and infos)
- `flutter test --exclude-tags golden` — runs every test except those tagged `golden`; goldens are skipped in CI because they require platform-specific font rendering

Golden test files are tagged with `@Tags(['golden'])` at the library level so the runner can exclude them.

### Code Ownership

[`.github/CODEOWNERS`](.github/CODEOWNERS) assigns ownership of the entire repository to [@Shir0o](https://github.com/Shir0o), who is automatically requested for review on every pull request.

## UI Design
The UI is based on the "Diary" project from Stitch.
- **Primary Color:** #6751a4
- **Typography:** Inter (via Google Fonts)
- **Shapes:** Rounded corners (8px/12px)

## Contributing

Contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup, local checks, and PR conventions. Participation is governed by the [Code of Conduct](CODE_OF_CONDUCT.md).

## Security

To report a vulnerability, please follow the process in [SECURITY.md](SECURITY.md). Do not file public issues for security reports.

## License

Released under the [MIT License](LICENSE).

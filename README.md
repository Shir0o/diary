# Diary App

A Flutter-based personal diary application.

## Features

- **Diary Timeline:** Chronological view of diary entries with mood indicators and location tags.

## Development

### Standards
This project follows strict Test-Driven Design (TDD) and documentation standards as defined in [GEMINI.md](GEMINI.md).

### Running Tests

To run all unit and widget tests:
```bash
flutter test
```

### Visual Validation

To run integration tests and perform visual validation (requires an emulator/device):
```bash
flutter test integration_test/app_test.dart
```

### Continuous Integration

The [`Flutter CI`](.github/workflows/flutter.yml) workflow runs on every push to `main` and on pull requests targeting `main`. It performs:
- `dart format --output=none --set-exit-if-changed .` — formatting check
- `flutter analyze --no-fatal-warnings --no-fatal-infos` — static analysis (errors only)
- `flutter test` for every `*_test.dart` outside of `*_golden_test.dart` — goldens are skipped in CI because they require platform-specific font rendering

### Code Ownership

[`.github/CODEOWNERS`](.github/CODEOWNERS) assigns ownership of the entire repository to [@Shir0o](https://github.com/Shir0o), who is automatically requested for review on every pull request.

## UI Design
The UI is based on the "Diary" project from Stitch.
- **Primary Color:** #6751a4
- **Typography:** Inter (via Google Fonts)
- **Shapes:** Rounded corners (8px/12px)

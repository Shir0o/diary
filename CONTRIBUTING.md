# Contributing

Thanks for your interest in contributing to Diary. This guide covers the basics for getting set up and shipping a change.

## Development setup

Requirements: Flutter SDK matching the constraint in [pubspec.yaml](pubspec.yaml) (Dart `^3.11.5`).

```bash
flutter pub get
cp .env.example .env   # fill in Google OAuth client IDs for the platforms you test
```

The local `.env` file is gitignored — never commit it.

## Running checks locally

CI runs the same three commands ([.github/workflows/flutter.yml](.github/workflows/flutter.yml)). Run them before pushing:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --exclude-tags golden
```

To run the full suite including golden tests locally:

```bash
flutter test
```

Golden tests are excluded in CI because they require platform-specific font rendering. Update goldens with `flutter test --update-goldens` and review the diffs before committing.

Integration tests (require a device or emulator):

```bash
flutter test integration_test/app_test.dart
```

## Pull requests

- Keep PRs small and focused — one logical change per PR.
- Ensure CI is green before requesting review.
- [@Shir0o](https://github.com/Shir0o) is auto-requested as reviewer via [.github/CODEOWNERS](.github/CODEOWNERS).
- For UI changes, include before/after screenshots in the PR description.
- Follow the existing code style; `dart format` enforces formatting.

## Reporting bugs and requesting features

Use the issue templates at [github.com/Shir0o/diary/issues/new/choose](https://github.com/Shir0o/diary/issues/new/choose).

For security issues, see [SECURITY.md](SECURITY.md) — please do not open public issues for vulnerabilities.

## Code of conduct

Participation is governed by the [Code of Conduct](CODE_OF_CONDUCT.md).

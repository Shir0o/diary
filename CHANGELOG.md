# Changelog

All notable changes to this project will be documented in this file.

## [v0.6.0] - 2026-05-26

### Added
- Created development workflow guidelines in `docs/DEVELOPMENT.md` and documentation index in `docs/INDEX.md`.
- Ignored local agent instructions (`GEMINI.md`) in `.gitignore`.
- Initialized `CHANGELOG.md` and `release.md` templates.

## [v0.5.0] - 2026-05-23

### Added
- Implemented native speech dictation support on Android and iOS using the device speech-to-text service.
- Implemented auto-restart on speech silence timeout for continuous voice dictation.
- Configured builtInKotlin and newDsl flags in `gradle.properties` for Android build optimization.

## [v0.4.0] - 2026-05-22

### Added
- Added advanced search filter functionality on the timeline and entries lists.
- Integrated calendar indicators to show dots on days with active entries.
- Added date range filters on the Analytics screen.
- Added support for multiple image attachments on diary entries.
- Implemented empty state placeholder graphic for the timeline.
- Resolved Nominatim location service 403 blocks and stabilized location bottom sheet bouncing issues.
- Prevented loss of unsaved changes in `NewEntryScreen` by showing a confirmation prompt on back navigation.

## [v0.3.0] - 2026-05-20

### Added
- Implemented skeleton page loaders for improved screen transitions and loading states.
- Added smooth page transitions and intercepted system back gestures for a native feel.
- Updated Help and About screens with privacy declarations.
- Split Archive and Trash into distinct layouts and screens.

## [v0.2.0] - 2026-05-19

### Added
- Implemented centralized design system with dynamic theming and app theme opacity tokens.
- Modernized the biometric lock screen with glassmorphism overlays and custom unlock animations.
- Implemented per-entry merge synchronization using Google Drive.
- Optimized Google Drive sync performance (handling SQLite connection lifecycle and adding progress indicators).
- Integrated device location tracking and manual address suggestions for diary entries.
- Added support for diary entry tags (creating, adding, and filtering by tag).

## [v0.1.0] - 2026-05-12

### Added
- Initial project setup with SQLite persistence (`sqflite`).
- Created core screens: Timeline (TDD), New Entry, Settings & Backup with bottom navigation, Calendar screen, and Analytics/Stats screen.
- Added side navigation drawer.
- Configured CI validation workflows (analyze, formatting check, goldens selection).
- Set up custom application launcher icons for iOS and Android.

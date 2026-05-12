# Implementation Plan: Settings Screen

## Objective
Implement a first-release settings screen that accurately describes supported privacy and appearance behavior without exposing placeholder backup, biometric, or encryption controls.

## Design Specifications
- **Theme Color:** Purple (#6751A4)
- **Background:** Light Purple (#FEF7FF)
- **Font:** IBM Plex Sans (fallback to Inter)
- **Top Bar:** Menu button, Screen Title ("Settings"), centered.
- **Sections:**
    - **Data & Privacy**:
        - Local storage
        - Device privacy guidance
    - **Appearance**:
        - Theme selector with System default, Light mode, and Dark mode options
- **Footer**: Version info ("Version 0.1.0").
- **Navigation**: Accessed via the "Settings" tab in the `bottomNavigationBar`.

## TDD Strategy

### 1. Widget Tests (`test/screens/settings_screen_test.dart`)
- Verify sections "DATA & PRIVACY" and "APPEARANCE" are present.
- Verify presence of local storage messaging.
- Verify presence of Theme setting.
- Verify placeholder switches and Google Drive backup text are absent.
- Verify version information.

### 2. Golden Tests (`test/screens/settings_screen_golden_test.dart`)
- Capture baseline for the Settings screen.

### 3. Integration Tests (`integration_test/app_test.dart`)
- Test navigation from `TimelineScreen` (Bottom Bar) to `SettingsScreen`.
- Verify the screen is displayed correctly when switching tabs.

## Implementation Steps

1. **Scaffold `SettingsScreen` Widget**:
    - Create `lib/screens/settings_screen.dart`.
    - Implement basic layout with `Scaffold`, `AppBar`, and a scrollable body.
2. **Implement Sections**:
    - Build reusable section header and list item widgets or use `ListTile`.
    - Implement "Data & Privacy" section.
    - Implement "Appearance" section.
3. **Implement Footer**:
    - Add version info at the bottom.
4. **Update Main Navigation**:
    - Modify `lib/main.dart` or `lib/screens/timeline_screen.dart` to handle tab switching between `TimelineScreen` and `SettingsScreen`.
5. **Verify and Refine**:
    - Run all tests and ensure visual alignment.

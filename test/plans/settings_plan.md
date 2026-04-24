# Implementation Plan: Settings & Backup Screen

## Objective
Implement the "Settings & Backup" screen as per the Stitch design specifications (ID: `ef30d0344a424feab31fc6cbf85546c3`). This screen should provide options for biometric lock, theme selection, and cloud backup (specifically Google Drive).

## Design Specifications
- **Theme Color:** Purple (#6751A4)
- **Background:** Light Purple (#FEF7FF)
- **Font:** IBM Plex Sans (fallback to Inter)
- **Top Bar:** Menu button, Screen Title ("Settings"), centered.
- **Sections:**
    - **Security & Appearance**:
        - Biometric Lock (with Switch)
        - Theme (with text "System Default" and chevron)
    - **Cloud Backup**:
        - Auto-backup (with Switch and description)
        - Last backup info
        - "Backup to Google Drive" button (with Google logo)
- **Footer**: Version info ("Version 2.4.0") and "Your data is encrypted locally".
- **Navigation**: Accessed via the "Settings" tab in the `bottomNavigationBar`.

## TDD Strategy

### 1. Widget Tests (`test/screens/settings_screen_test.dart`)
- Verify sections "SECURITY & APPEARANCE" and "CLOUD BACKUP" are present.
- Verify presence of Biometric Lock switch.
- Verify presence of Theme setting.
- Verify presence of Auto-backup switch.
- Verify presence of "Backup to Google Drive" button.
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
    - Implement "Security & Appearance" section.
    - Implement "Cloud Backup" section with the custom Google Drive button.
3. **Implement Footer**:
    - Add version and encryption info at the bottom.
4. **Update Main Navigation**:
    - Modify `lib/main.dart` or `lib/screens/timeline_screen.dart` to handle tab switching between `TimelineScreen` and `SettingsScreen`.
5. **Verify and Refine**:
    - Run all tests and ensure visual alignment.

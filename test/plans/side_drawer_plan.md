# Side Navigation Drawer Implementation Plan

## Objective
Implement a Material 3 Side Navigation Drawer for the Diary app using TDD. The drawer should provide access to various app sections and reflect the app's visual style.

## Design Details
- **Component**: `NavigationDrawer` (Material 3).
- **Primary Color**: #6751a4.
- **Font**: Inter (via `safeGoogleFont`).
- **Items**:
    - Header with app name/logo.
    - Navigation items: Timeline, Calendar, Media (placeholder), Analytics (new), Settings.
    - Separator.
    - Secondary items: Help, About.

## Implementation Steps

### 1. Research & Preparation
- [ ] Review existing `MainScreen` and navigation logic.
- [ ] Confirm layout requirements for a standard Material 3 drawer.

### 2. TDD - Widget Tests
- [ ] Create `test/widgets/side_drawer_test.dart`.
- [ ] Test: Drawer renders with header and expected items.
- [ ] Test: Tapping items triggers callbacks (e.g., closing drawer or navigating).

### 3. Implementation - SideDrawer Widget
- [ ] Create `lib/widgets/side_drawer.dart`.
- [ ] Implement `SideDrawer` widget using `NavigationDrawer`.
- [ ] Apply styling (colors, fonts) consistent with the project.

### 4. TDD - Golden Tests
- [ ] Create `test/widgets/side_drawer_golden_test.dart`.
- [ ] Generate and verify golden image for the drawer.

### 5. Integration
- [ ] Update `lib/main.dart` to add the `drawer` property to the `Scaffold` in `MainScreen`.
- [ ] Add an `AppBar` to `MainScreen` to provide a toggle button for the drawer (standard Material 3 pattern).
- [ ] Ensure navigation from the drawer works correctly.

### 6. Verification
- [ ] Run all tests (`flutter test`).
- [ ] Manual verification if possible.

### 7. Documentation
- [ ] Update `GEMINI.md` Progress Tracker.

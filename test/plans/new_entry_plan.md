# Implementation Plan: New Entry Screen

## Objective
Implement the "New Entry" screen as per the Stitch design specifications (ID: `12085b396125489f9acc90449a4772d1`). The screen should allow users to write a new diary entry, select a mood, tag, location, and potentially add images.

## Design Specifications
- **Theme Color:** Purple (#6750A4)
- **Background:** Light Purple (#FEF7FF)
- **Font:** Inter (via Google Fonts)
- **Top Bar:** Back button, Screen Title ("New Entry"), Save button.
- **Content:**
    - Large Date & Time header (e.g., "Oct 26, 2023", "8:30 PM • Thursday").
    - Full-screen multiline text input with placeholder "Write your heart out...".
- **Bottom Toolbar:**
    - Icons for: Image, Tag, Mood, Location.
    - Status indicator ("Stored locally").

## TDD Strategy

### 1. Unit Tests (`test/models/diary_entry_test.dart`)
- (Already exists) Verify `DiaryEntry` model can handle the data from this screen.

### 2. Widget Tests (`test/screens/new_entry_screen_test.dart`)
- Verify all UI elements are present:
    - Back button
    - Title "New Entry"
    - Save button
    - Date and time header
    - Text area for content
    - Toolbar buttons (Image, Tag, Mood, Location)
- Verify text input updates the state.

### 3. Golden Tests (`test/screens/new_entry_screen_golden_test.dart`)
- Capture a baseline of the "New Entry" screen.
- Verify appearance in light and dark modes (if applicable).

### 4. Integration Tests (`integration_test/app_test.dart`)
- Test navigation from `TimelineScreen` (FAB) to `NewEntryScreen`.
- Test entering text and clicking "Save".
- Verify navigation back to `TimelineScreen` after saving.

## Implementation Steps

1. **Scaffold `NewEntryScreen` Widget**:
    - Create `lib/screens/new_entry_screen.dart`.
    - Implement the basic layout with `Scaffold`, `AppBar`, and `Column`.
2. **Implement Header and Input**:
    - Add the date/time header.
    - Add the `TextField` with `maxLines: null` for multiline input.
3. **Implement Bottom Toolbar**:
    - Use `BottomAppBar` or a custom `Container` at the bottom.
    - Add the icons and status text.
4. **Wire up the FAB**:
    - Update `lib/screens/timeline_screen.dart` to navigate to `NewEntryScreen`.
5. **Logic for Saving**:
    - For now, just print the result or pop back. We'll add persistent storage later if requested.

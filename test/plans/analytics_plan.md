# Analytics/Stats Screen Implementation Plan

## Objective
Implement a statistics dashboard for the Diary app using TDD. The screen should provide insights into entry frequency, mood trends, and overall activity.

## Design Details
- **Primary Color**: #6751a4.
- **Font**: Inter (via `safeGoogleFont`).
- **Components**:
    - **Overview Cards**: Total Entries, Streak, Most Common Mood.
    - **Mood Distribution**: A chart or list showing frequency of each mood.
    - **Activity Chart**: A bar or line chart showing entries over the last 7 days.
    - **Insights Section**: Placeholder for AI-generated or simple text insights.

## Implementation Steps

### 1. Research & Preparation
- [ ] Review `DiaryEntry` model and identify relevant fields for stats (date, mood).
- [ ] Determine chart library usage (e.g., standard Flutter containers or a simple custom painter to avoid adding heavy dependencies if not needed, or use a common package like `fl_chart` if already present). Let's check `pubspec.yaml`.

### 2. TDD - Unit Tests (Logic)
- [ ] Create `test/helpers/analytics_helper_test.dart`.
- [ ] Test: Calculate total entries.
- [ ] Test: Calculate current streak.
- [ ] Test: Calculate mood distribution map.
- [ ] Test: Format data for the weekly activity chart.

### 3. Implementation - Analytics Helper
- [ ] Create `lib/helpers/analytics_helper.dart`.
- [ ] Implement the logic tested in step 2.

### 4. TDD - Widget Tests
- [ ] Create `test/screens/analytics_screen_test.dart`.
- [ ] Test: Screen renders overview cards with correct data.
- [ ] Test: Mood distribution section is visible.
- [ ] Test: Empty state handling (no entries).

### 5. Implementation - AnalyticsScreen Widget
- [ ] Create `lib/screens/analytics_screen.dart`.
- [ ] Use `MainScreen`'s provided entries (mocked for now, matching other screens).
- [ ] Build UI with Material 3 Cards and custom widgets for charts.

### 6. TDD - Golden Tests
- [ ] Create `test/screens/analytics_screen_golden_test.dart`.
- [ ] Generate and verify golden image for the analytics dashboard.

### 7. Integration
- [ ] Update `lib/main.dart` to include `AnalyticsScreen` in the `_screens` list (replacing the "Media" placeholder or adding as a new index).
- [ ] Update `SideDrawer` to ensure the "Analytics" item navigates correctly.

### 8. Verification
- [ ] Run all tests (`flutter test`).

### 9. Documentation
- [ ] Update `GEMINI.md` Progress Tracker.

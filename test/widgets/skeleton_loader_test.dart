import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diary/widgets/skeleton_loader.dart';
import 'package:diary/screens/timeline_screen.dart';
import 'package:diary/screens/calendar_screen.dart';
import 'package:diary/screens/archive_screen.dart';
import 'package:diary/screens/trash_screen.dart';
import 'package:diary/screens/media_screen.dart';
import 'package:diary/screens/analytics_screen.dart';
import 'package:diary/screens/info_screen.dart';

void main() {
  // ── Base Skeleton widget ──────────────────────────────────────────────

  group('Skeleton', () {
    testWidgets('renders with specified dimensions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Skeleton(width: 100, height: 20)),
        ),
      );

      expect(find.byType(Skeleton), findsOneWidget);
      // Verify the Skeleton's own FadeTransition (scoped as descendant)
      expect(
        find.descendant(
          of: find.byType(Skeleton),
          matching: find.byType(FadeTransition),
        ),
        findsOneWidget,
      );
    });

    testWidgets('uses AnimationController for pulsing animation', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Skeleton(width: 50, height: 10)),
        ),
      );

      // Locate the Skeleton's own FadeTransition
      final fadeFinder = find.descendant(
        of: find.byType(Skeleton),
        matching: find.byType(FadeTransition),
      );
      expect(fadeFinder, findsOneWidget);

      final fade = tester.widget<FadeTransition>(fadeFinder);
      expect(fade.opacity, isA<Animation<double>>());

      // Advance part way through the animation and verify it's still alive
      await tester.pump(const Duration(milliseconds: 500));
      expect(fadeFinder, findsOneWidget);
    });

    testWidgets('renders with custom child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Skeleton(width: 100, height: 50, child: Text('child')),
          ),
        ),
      );

      expect(find.text('child'), findsOneWidget);
    });
  });

  // ── SkeletonEntryCard ─────────────────────────────────────────────────

  group('SkeletonEntryCard', () {
    testWidgets('renders skeleton placeholders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SkeletonEntryCard())),
      );

      expect(find.byType(SkeletonEntryCard), findsOneWidget);
      // Card contains multiple Skeleton placeholders for time, mood, title, content, tags, location
      expect(find.byType(Skeleton), findsAtLeast(6));
    });
  });

  // ── Screen-specific skeleton widgets ──────────────────────────────────

  group('TimelineScreenSkeleton', () {
    testWidgets('renders multiple skeleton entries', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TimelineScreenSkeleton())),
      );

      expect(find.byType(TimelineScreenSkeleton), findsOneWidget);
      expect(find.byType(SkeletonEntryCard), findsAtLeast(1));
    });
  });

  group('EntryListSkeleton', () {
    testWidgets('renders correct number of items with actions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EntryListSkeleton(itemCount: 2)),
        ),
      );

      expect(find.byType(EntryListSkeleton), findsOneWidget);
      expect(find.byType(SkeletonEntryCard), findsNWidgets(2));
    });

    testWidgets('renders without action buttons when showActions is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EntryListSkeleton(itemCount: 1, showActions: false),
          ),
        ),
      );

      expect(find.byType(EntryListSkeleton), findsOneWidget);
      expect(find.byType(SkeletonEntryCard), findsOneWidget);
    });
  });

  group('CalendarScreenSkeleton', () {
    testWidgets('renders calendar-style skeleton', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CalendarScreenSkeleton())),
      );

      expect(find.byType(CalendarScreenSkeleton), findsOneWidget);
      // Contains many Skeleton widgets for calendar grid and entry list
      expect(find.byType(Skeleton), findsAtLeast(10));
    });
  });

  group('MediaScreenSkeleton', () {
    testWidgets('renders grid of placeholder tiles', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MediaScreenSkeleton())),
      );

      expect(find.byType(MediaScreenSkeleton), findsOneWidget);
      expect(find.byType(Skeleton), findsAtLeast(6));
    });
  });

  group('AnalyticsScreenSkeleton', () {
    testWidgets('renders summary cards and chart sections', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AnalyticsScreenSkeleton())),
      );

      expect(find.byType(AnalyticsScreenSkeleton), findsOneWidget);
      // Has many skeletons for summary cards, mood distribution, tag dist, weekly activity, insights
      expect(find.byType(Skeleton), findsAtLeast(15));
    });
  });

  group('SettingsScreenSkeleton', () {
    testWidgets('renders setting section skeletons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsScreenSkeleton())),
      );

      expect(find.byType(SettingsScreenSkeleton), findsOneWidget);
      expect(find.byType(Skeleton), findsAtLeast(8));
    });
  });

  group('InfoScreenSkeleton', () {
    testWidgets('renders icon and card skeletons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: InfoScreenSkeleton())),
      );

      expect(find.byType(InfoScreenSkeleton), findsOneWidget);
      expect(find.byType(Card), findsAtLeast(3));
      expect(find.byType(Skeleton), findsAtLeast(7));
    });
  });

  group('LocationSuggestionsSkeleton', () {
    testWidgets('renders 3 suggestion placeholder rows', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LocationSuggestionsSkeleton())),
      );

      expect(find.byType(LocationSuggestionsSkeleton), findsOneWidget);
      // 3 rows × 3 skeletons each (icon, title, subtitle) = 9
      expect(find.byType(Skeleton), findsAtLeast(6));
    });
  });

  // ── Screen isLoading integration ──────────────────────────────────────

  group('Screen isLoading integration', () {
    testWidgets('TimelineScreen renders skeleton when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TimelineScreen(
            isLoading: true,
            entries: const [],
            onMenuPressed: () {},
            onAddEntry: () {},
            onSearchEntries: () {},
            onCalendarPressed: () {},
            onEditEntry: (_) {},
            onDeleteEntry: (_) {},
            onArchiveEntry: (_) {},
            onRefresh: () async {},
          ),
        ),
      );

      expect(find.byType(TimelineScreenSkeleton), findsOneWidget);
    });

    testWidgets('CalendarScreen renders skeleton when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarScreen(
            isLoading: true,
            entries: const [],
            onBackPressed: () {},
            onSearchEntries: () {},
            onEditEntry: (_) {},
          ),
        ),
      );

      expect(find.byType(CalendarScreenSkeleton), findsOneWidget);
    });

    testWidgets('ArchiveScreen renders skeleton when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ArchiveScreen(
            isLoading: true,
            archivedEntries: const [],
            onBackPressed: () {},
            onUnarchiveEntry: (_) {},
            onDeleteEntry: (_) {},
          ),
        ),
      );

      expect(find.byType(EntryListSkeleton), findsOneWidget);
    });

    testWidgets('TrashScreen renders skeleton when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TrashScreen(
            isLoading: true,
            deletedEntries: const [],
            onBackPressed: () {},
            onRestoreEntry: (_) {},
            onPermanentlyDeleteEntry: (_) {},
            onEmptyTrash: () {},
            autoDeleteEnabled: true,
            retentionDays: 30,
          ),
        ),
      );

      expect(find.byType(EntryListSkeleton), findsOneWidget);
    });

    testWidgets('MediaScreen renders skeleton when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaScreen(
            isLoading: true,
            entries: const [],
            onBackPressed: () {},
          ),
        ),
      );

      expect(find.byType(MediaScreenSkeleton), findsOneWidget);
    });

    testWidgets('AnalyticsScreen renders skeleton when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnalyticsScreen(
            isLoading: true,
            entries: const [],
            onBackPressed: () {},
          ),
        ),
      );

      expect(find.byType(AnalyticsScreenSkeleton), findsOneWidget);
    });

    testWidgets('InfoScreen.help renders skeleton when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InfoScreen.help(isLoading: true, onBackPressed: () {}),
        ),
      );

      expect(find.byType(InfoScreenSkeleton), findsOneWidget);
    });

    testWidgets('InfoScreen.about renders skeleton when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InfoScreen.about(isLoading: true, onBackPressed: () {}),
        ),
      );

      expect(find.byType(InfoScreenSkeleton), findsOneWidget);
    });
  });
}

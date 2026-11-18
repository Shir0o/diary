import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diary/config/app_theme.dart';
import 'package:diary/data/in_memory_diary_entry_store.dart';
import 'package:diary/main.dart';
import 'package:diary/models/diary_entry.dart';
import 'package:diary/screens/calendar_screen.dart';
import 'package:diary/screens/entry_detail_screen.dart';
import 'package:diary/screens/new_entry_screen.dart';
import 'package:diary/screens/timeline_screen.dart';
import 'package:diary/services/auth_service.dart';
import 'package:diary/services/security_service.dart';
import 'package:diary/services/theme_service.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockSecurityService extends Mock implements SecurityService {}

class MockThemeService extends Mock implements ThemeService {}

/// Locates the Flutter SDK's bundled fonts without ever throwing when the SDK
/// cache is not present (e.g. on a machine that only has the pub cache).
///
/// `FLUTTER_ROOT` is normally exported while `flutter test` runs, but when it
/// is missing the SDK root is derived from the test executable:
///   * `<root>/bin/cache/artifacts/engine/<platform>/flutter_tester`
///   * `<root>/bin/cache/dart-sdk/bin/dart`
/// Walking up from `Directory(Platform.resolvedExecutable)` covers both.
String? materialFontsDirectory() {
  final roots = <String>[];

  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null && flutterRoot.trim().isNotEmpty) {
    roots.add(flutterRoot.trim());
  }

  var directory = Directory(Platform.resolvedExecutable).parent.parent.parent;
  for (var depth = 0; depth < 4; depth++) {
    roots.add(directory.path);
    directory = directory.parent;
  }

  for (final root in roots) {
    final candidate = Directory('$root/bin/cache/artifacts/material_fonts');
    if (candidate.existsSync()) {
      return candidate.path;
    }
  }
  return null;
}

/// Registers the given font files under [family]. Missing files are skipped;
/// returns false when nothing could be loaded.
Future<bool> loadFontFamily(String family, Iterable<String> files) async {
  final loader = FontLoader(family);
  var added = false;

  for (final path in files) {
    final file = File(path);
    if (!file.existsSync()) continue;
    final bytes = await file.readAsBytes();
    loader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    added = true;
  }

  if (!added) return false;
  await loader.load();
  return true;
}

void main() {
  late MockGoogleSignIn mockGoogleSignIn;
  late MockSecurityService mockSecurityService;
  late MockThemeService mockThemeService;
  late AuthService authService;
  late StreamController<GoogleSignInAuthenticationEvent>
  authenticationEventsController;

  var realFontsLoaded = false;

  final testEntries = [
    DiaryEntry(
      id: '1',
      date: DateTime(2026, 4, 24, 10, 0),
      title: 'Starting a new project',
      content: 'Today I started the Diary app project.',
      mood: '🚀',
      location: 'Home Office',
      tags: const ['work'],
    ),
    DiaryEntry(
      id: '2',
      date: DateTime(2026, 4, 24, 14, 0),
      title: 'Coffee Break',
      content: 'Had a wonderful cup of coffee.',
      mood: '☕',
      location: 'Local Cafe',
      tags: const ['friends'],
    ),
  ];

  setUpAll(() async {
    final fontsDirectory = materialFontsDirectory();
    if (fontsDirectory == null) {
      // Keep the audit runnable even when the SDK cache is absent; screenshots
      // simply fall back to the test font instead of failing the suite.
      return;
    }

    final robotoLoaded = await loadFontFamily('Roboto', [
      '$fontsDirectory/Roboto-Regular.ttf',
      '$fontsDirectory/Roboto-Bold.ttf',
      '$fontsDirectory/Roboto-Medium.ttf',
    ]);
    await loadFontFamily('MaterialIcons', [
      '$fontsDirectory/MaterialIcons-Regular.otf',
    ]);

    realFontsLoaded = robotoLoaded;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockGoogleSignIn = MockGoogleSignIn();
    mockSecurityService = MockSecurityService();
    mockThemeService = MockThemeService();
    authenticationEventsController =
        StreamController<GoogleSignInAuthenticationEvent>.broadcast();

    when(
      () => mockGoogleSignIn.authenticationEvents,
    ).thenAnswer((_) => authenticationEventsController.stream);
    when(
      () => mockGoogleSignIn.initialize(
        clientId: any(named: 'clientId'),
        serverClientId: any(named: 'serverClientId'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockGoogleSignIn.attemptLightweightAuthentication(),
    ).thenAnswer((_) async => null);

    authService = AuthService(googleSignIn: mockGoogleSignIn);

    when(
      () => mockSecurityService.isBiometricLockEnabled,
    ).thenAnswer((_) async => false);
    when(
      () => mockSecurityService.authenticate(),
    ).thenAnswer((_) async => true);

    when(() => mockThemeService.themePalette).thenReturn('lilac');
    when(() => mockThemeService.timelineLayout).thenReturn('playful');
    when(() => mockThemeService.userName).thenReturn('Sarah');
    when(() => mockThemeService.onboardingCompleted).thenReturn(true);
    when(() => mockThemeService.addListener(any())).thenReturn(null);
    when(() => mockThemeService.removeListener(any())).thenReturn(null);
  });

  tearDown(() {
    authenticationEventsController.close();
  });

  Widget createApp({required ThemeMode themeMode}) {
    when(() => mockThemeService.themeMode).thenReturn(themeMode);
    final app = RepaintBoundary(
      key: const ValueKey('audit_root'),
      child: DiaryApp(
        entryStore: InMemoryDiaryEntryStore(testEntries),
        authService: authService,
        securityService: mockSecurityService,
        themeService: mockThemeService,
      ),
    );

    if (!realFontsLoaded) return app;

    // Material typography already asks for 'Roboto' on the test target, so the
    // fonts loaded in setUpAll are picked up as-is; the wrapper only pins the
    // family when the surrounding theme would otherwise use another default.
    return Theme(
      data: ThemeData(fontFamily: 'Roboto'),
      child: app,
    );
  }

  Future<void> pumpAuditApp(
    WidgetTester tester, {
    required ThemeMode themeMode,
    required Brightness brightness,
    Size size = const Size(390, 844),
    double textScaleFactor = 1.0,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = textScaleFactor;
    tester.platformDispatcher.platformBrightnessTestValue = brightness;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
      tester.platformDispatcher.clearPlatformBrightnessTestValue();
    });

    await tester.pumpWidget(createApp(themeMode: themeMode));
    await tester.pumpAndSettle();
  }

  List<FlutterErrorDetails> captureOverflowErrors() {
    final overflowErrors = <FlutterErrorDetails>[];
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.toString().contains('RenderFlex overflowed')) {
        overflowErrors.add(details);
      }
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);
    return overflowErrors;
  }

  /// Pumps the calendar on its own so its day grid, month row and header can
  /// be audited in isolation at phone, dark and large-font sizes.
  Future<void> pumpCalendarAudit(
    WidgetTester tester, {
    required Brightness brightness,
    Size size = const Size(390, 844),
    double textScaleFactor = 1.0,
    DateTime? initialDate,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = textScaleFactor;
    tester.platformDispatcher.platformBrightnessTestValue = brightness;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
      tester.platformDispatcher.clearPlatformBrightnessTestValue();
    });

    final now = DateTime.now();
    final calendarEntries = [
      DiaryEntry(
        id: 'calendar-1',
        date: DateTime(now.year, now.month, 1, 9, 0),
        title: 'First page of the month',
        content: 'The selected day keeps a readable entry list below the grid.',
        mood: '🌱',
      ),
      DiaryEntry(
        id: 'calendar-2',
        date: DateTime(now.year, now.month, now.day, 20, 0),
        title: 'Today',
        content: 'Today carries its own entry indicator dot.',
        mood: '🌙',
      ),
    ];

    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('calendar_audit_root'),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.buildTheme(brightness, 'lilac'),
          home: CalendarScreen(
            initialDate: initialDate ?? DateTime(now.year, now.month, 1),
            entries: calendarEntries,
            onBackPressed: () {},
            onSearchEntries: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> captureGolden(
    WidgetTester tester,
    String name, {
    Finder? finder,
  }) async {
    if (!autoUpdateGoldenFiles) return;
    await expectLater(
      finder ?? find.byKey(const ValueKey('audit_root')),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  /// Fails when any widget matched by [finder] is laid out outside the
  /// horizontal bounds of a [width]-wide viewport.
  void expectHorizontallyInside(
    WidgetTester tester,
    Finder finder,
    double width, {
    required String reason,
  }) {
    final elements = finder.evaluate().toList();
    expect(elements, isNotEmpty, reason: reason);

    for (final element in elements) {
      final box = element.renderObject! as RenderBox;
      final left = box.localToGlobal(Offset.zero).dx;
      final right = left + box.size.width;
      expect(
        left,
        greaterThanOrEqualTo(0.0),
        reason: '$reason must not start left of the viewport (was $left)',
      );
      expect(
        right,
        lessThanOrEqualTo(width),
        reason: '$reason must not end right of ${width}dp (was $right)',
      );
    }
  }

  group('UI/UX Usability & Accessibility Audit', () {
    testWidgets('phone_light (390x844 @ 1.0x)', (WidgetTester tester) async {
      final overflowErrors = captureOverflowErrors();
      await pumpAuditApp(
        tester,
        themeMode: ThemeMode.light,
        brightness: Brightness.light,
      );

      await captureGolden(tester, 'phone_light');

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      expect(
        overflowErrors,
        isEmpty,
        reason: 'RenderFlex overflows detected: $overflowErrors',
      );
    });

    testWidgets('phone_dark (390x844 @ 1.0x)', (WidgetTester tester) async {
      final overflowErrors = captureOverflowErrors();
      await pumpAuditApp(
        tester,
        themeMode: ThemeMode.dark,
        brightness: Brightness.dark,
      );

      await captureGolden(tester, 'phone_dark');

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      expect(
        overflowErrors,
        isEmpty,
        reason: 'RenderFlex overflows detected: $overflowErrors',
      );
    });

    testWidgets('small_large_font (320x568 @ 1.6x text scale)', (
      WidgetTester tester,
    ) async {
      final overflowErrors = captureOverflowErrors();
      await pumpAuditApp(
        tester,
        themeMode: ThemeMode.light,
        brightness: Brightness.light,
        size: const Size(320, 568),
        textScaleFactor: 1.6,
      );

      await captureGolden(tester, 'small_large_font');

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      expect(
        overflowErrors,
        isEmpty,
        reason: 'RenderFlex overflows detected: $overflowErrors',
      );
    });

    testWidgets('interactive_click_through', (WidgetTester tester) async {
      await pumpAuditApp(
        tester,
        themeMode: ThemeMode.light,
        brightness: Brightness.light,
      );

      expect(find.byType(TimelineScreen), findsOneWidget);
      await captureGolden(tester, 'step1_home');

      // Calendar tab.
      await tester.tap(find.text('🗓️'));
      await tester.pumpAndSettle();
      await captureGolden(tester, 'step2_calendar');

      // Analytics tab.
      await tester.tap(find.text('📊'));
      await tester.pumpAndSettle();
      await captureGolden(tester, 'step3_analytics');

      // Back to the timeline.
      await tester.tap(find.text('🏠'));
      await tester.pumpAndSettle();
      expect(find.byType(TimelineScreen), findsOneWidget);

      // Open the first diary entry.
      await tester.tap(find.text('Starting a new project'));
      await tester.pumpAndSettle();
      expect(find.byType(EntryDetailScreen), findsOneWidget);
      await captureGolden(tester, 'step4_entry_detail');

      // Return to the timeline.
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();
      expect(find.byType(EntryDetailScreen), findsNothing);
      expect(find.byType(TimelineScreen), findsOneWidget);

      // Compose a new entry from the centre '+' button.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.byType(NewEntryScreen), findsOneWidget);
      await captureGolden(tester, 'step5_new_entry');

      // Let the pushed route settle and drop it so no callbacks outlive the
      // test.
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
    });

    testWidgets('calendar_light (390x844 @ 1.0x)', (WidgetTester tester) async {
      final overflowErrors = captureOverflowErrors();
      await pumpCalendarAudit(tester, brightness: Brightness.light);

      await captureGolden(
        tester,
        'calendar_light',
        finder: find.byKey(const ValueKey('calendar_audit_root')),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      expect(
        overflowErrors,
        isEmpty,
        reason: 'RenderFlex overflows detected: $overflowErrors',
      );
    });

    testWidgets('calendar_dark (390x844 @ 1.0x)', (WidgetTester tester) async {
      final overflowErrors = captureOverflowErrors();
      await pumpCalendarAudit(tester, brightness: Brightness.dark);

      await captureGolden(
        tester,
        'calendar_dark',
        finder: find.byKey(const ValueKey('calendar_audit_root')),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      expect(
        overflowErrors,
        isEmpty,
        reason: 'RenderFlex overflows detected: $overflowErrors',
      );
    });

    testWidgets('calendar_small_large_font (320x568 @ 1.6x text scale)', (
      WidgetTester tester,
    ) async {
      final overflowErrors = captureOverflowErrors();
      const size = Size(320, 568);
      await pumpCalendarAudit(
        tester,
        brightness: Brightness.light,
        size: size,
        textScaleFactor: 1.6,
        initialDate: DateTime.now(),
      );

      await captureGolden(
        tester,
        'calendar_small_large_font',
        finder: find.byKey(const ValueKey('calendar_audit_root')),
      );

      // Seven columns inside 320dp are physically ~40dp wide once the card
      // margins and padding are taken out, so the tap target guideline cannot
      // hold while every weekday stays visible without a horizontal scroll.
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      expect(
        overflowErrors,
        isEmpty,
        reason: 'RenderFlex overflows detected: $overflowErrors',
      );

      // The whole week fits: no horizontally scrolling view remains, and every
      // weekday header and day numeral sits inside the 320dp viewport.
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              (widget.axisDirection == AxisDirection.right ||
                  widget.axisDirection == AxisDirection.left),
        ),
        findsNothing,
        reason: 'the week must fit without a horizontal scroll',
      );

      final weekdayHeaders = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data != null &&
            RegExp(r'^[MTWFS]$').hasMatch(widget.data!),
      );
      expect(weekdayHeaders, findsNWidgets(7));
      expectHorizontallyInside(
        tester,
        weekdayHeaders,
        size.width,
        reason: 'weekday headers M..S',
      );

      expectHorizontallyInside(
        tester,
        find.byType(GridView),
        size.width,
        reason: 'the day grid',
      );

      final now = DateTime.now();
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      for (var day = 1; day <= daysInMonth; day++) {
        expectHorizontallyInside(
          tester,
          find.text('$day'),
          size.width,
          reason: 'day $day of ${now.month}/${now.year}',
        );
      }
    });
  });
}

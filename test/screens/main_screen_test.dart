import 'dart:async';
import 'package:diary/data/in_memory_diary_entry_store.dart';
import 'package:diary/main.dart';
import 'package:diary/models/diary_entry.dart';
import 'package:diary/services/auth_service.dart';
import 'package:diary/services/security_service.dart';
import 'package:diary/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockSecurityService extends Mock implements SecurityService {}

class MockThemeService extends Mock implements ThemeService {}

void main() {
  late MockGoogleSignIn mockGoogleSignIn;
  late MockSecurityService mockSecurityService;
  late MockThemeService mockThemeService;
  late AuthService authService;
  late StreamController<GoogleSignInAuthenticationEvent>
  authenticationEventsController;

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
    when(() => mockGoogleSignIn.initialize()).thenAnswer((_) async {});
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

    when(() => mockThemeService.themeMode).thenReturn(ThemeMode.system);
    when(() => mockThemeService.addListener(any())).thenReturn(null);
    when(() => mockThemeService.removeListener(any())).thenReturn(null);
  });

  tearDown(() {
    authenticationEventsController.close();
  });

  final testEntries = [
    DiaryEntry(
      id: '1',
      date: DateTime(2026, 4, 24, 10, 0),
      title: 'Starting a new project',
      content: 'Today I started the Diary app project.',
      mood: '🚀',
      location: 'Home Office',
    ),
    DiaryEntry(
      id: '2',
      date: DateTime(2026, 4, 24, 14, 0),
      title: 'Coffee Break',
      content: 'Had a wonderful cup of coffee.',
      mood: '☕',
      location: 'Local Cafe',
    ),
  ];

  Widget createApp() {
    return DiaryApp(
      entryStore: InMemoryDiaryEntryStore(testEntries),
      authService: authService,
      securityService: mockSecurityService,
      themeService: mockThemeService,
    );
  }

  testWidgets('menu button opens the main drawer', (tester) async {
    await tester.pumpWidget(createApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Diary App'), findsOneWidget);
    expect(find.text('Timeline'), findsWidgets);
    expect(find.text('Calendar'), findsWidgets);
    expect(find.text('Analytics'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('drawer destinations navigate to existing screens', (
    tester,
  ) async {
    await tester.pumpWidget(createApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calendar').last);
    await tester.pumpAndSettle();

    expect(find.text('Calendar'), findsWidgets);
    expect(find.byType(CalendarDatePicker), findsOneWidget);

    // Tap back arrow to return to Timeline, then navigate to Analytics via drawer
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Analytics').last);
    await tester.pumpAndSettle();

    expect(find.text('Analytics'), findsWidgets);
    expect(find.text('Total Entries'), findsOneWidget);
  });

  testWidgets(
    'pause during biometric auth does not re-lock or re-prompt on resume',
    (tester) async {
      when(
        () => mockSecurityService.isBiometricLockEnabled,
      ).thenAnswer((_) async => true);

      final authCompleter = Completer<bool>();
      when(
        () => mockSecurityService.authenticate(),
      ).thenAnswer((_) => authCompleter.future);

      await tester.pumpWidget(createApp());
      await tester.pump();

      expect(find.text('Diary is Locked'), findsOneWidget);

      // Simulate the OS biometric prompt backgrounding the app, then resuming
      // once the user has authenticated. Before the pause guard, the resumed
      // state would observe _isAuthenticated=false and call authenticate() a
      // second time.
      final binding = tester.binding;
      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      authCompleter.complete(true);
      await tester.pumpAndSettle();

      expect(find.text('Diary is Locked'), findsNothing);
      verify(() => mockSecurityService.authenticate()).called(1);
    },
  );

  testWidgets('system back button on non-timeline screen returns to timeline', (
    tester,
  ) async {
    await tester.pumpWidget(createApp());
    await tester.pumpAndSettle();

    // Navigate to Calendar
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calendar').last);
    await tester.pumpAndSettle();
    expect(find.text('Calendar'), findsWidgets);

    // Simulate system back button
    final dynamic widgetsBinding = tester.binding;
    await widgetsBinding.handlePopRoute();
    await tester.pumpAndSettle();

    // Verify back on Timeline
    expect(find.text('Diary'), findsOneWidget);
  });

  testWidgets('tapping back arrow on non-timeline screen returns to timeline', (
    tester,
  ) async {
    await tester.pumpWidget(createApp());
    await tester.pumpAndSettle();

    // Navigate to Settings
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);

    // Tap back arrow
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Verify back on Timeline
    expect(find.text('Diary'), findsOneWidget);
  });
}

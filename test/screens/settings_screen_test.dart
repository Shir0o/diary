import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:diary/screens/settings_screen.dart';
import 'package:diary/services/auth_service.dart';
import 'package:diary/services/security_service.dart';
import 'package:diary/services/theme_service.dart';
import 'package:diary/config/app_theme.dart';
import 'package:diary/data/diary_entry_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockSecurityService extends Mock implements SecurityService {}

class MockThemeService extends Mock implements ThemeService {}

class MockDiaryEntryStore extends Mock implements DiaryEntryStore {}

void main() {
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockAccount;
  late MockSecurityService mockSecurityService;
  late MockThemeService mockThemeService;
  late MockDiaryEntryStore mockEntryStore;
  late AuthService authService;
  late StreamController<GoogleSignInAccount?> currentUserController;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockGoogleSignIn = MockGoogleSignIn();
    mockAccount = MockGoogleSignInAccount();
    mockSecurityService = MockSecurityService();
    mockThemeService = MockThemeService();
    mockEntryStore = MockDiaryEntryStore();
    currentUserController = StreamController<GoogleSignInAccount?>.broadcast();

    authService = AuthService(googleSignIn: mockGoogleSignIn);

    when(
      () => mockGoogleSignIn.onCurrentUserChanged,
    ).thenAnswer((_) => currentUserController.stream);
    when(() => mockAccount.email).thenReturn('bob@example.com');
    when(() => mockAccount.displayName).thenReturn('Bob');
    when(() => mockAccount.photoUrl).thenReturn('');

    when(
      () => mockSecurityService.isBiometricLockEnabled,
    ).thenAnswer((_) async => false);
    when(
      () => mockSecurityService.canAuthenticate(),
    ).thenAnswer((_) async => true);
    when(
      () => mockSecurityService.authenticate(),
    ).thenAnswer((_) async => true);
    when(
      () => mockSecurityService.setBiometricLockEnabled(any()),
    ).thenAnswer((_) async => {});

    when(() => mockThemeService.themeMode).thenReturn(ThemeMode.system);
    when(() => mockThemeService.addListener(any())).thenReturn(null);
    when(() => mockThemeService.removeListener(any())).thenReturn(null);
    when(() => mockEntryStore.close()).thenAnswer((_) async => {});
  });

  tearDown(() {
    currentUserController.close();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: SettingsScreen(
        authService: authService,
        securityService: mockSecurityService,
        themeService: mockThemeService,
        entryStore: mockEntryStore,
      ),
    );
  }

  testWidgets('SettingsScreen should display all required sections and items', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    when(() => mockGoogleSignIn.currentUser).thenReturn(null);

    await tester.pumpWidget(createWidgetUnderTest());

    // Top App Bar
    expect(find.text('Settings'), findsOneWidget);

    // Section Headers
    expect(find.text('ACCOUNT'), findsOneWidget);
    expect(find.text('SECURITY & APPEARANCE'), findsOneWidget);
    expect(find.text('TRASH & ARCHIVE'), findsOneWidget);
    expect(find.text('CLOUD SYNC'), findsOneWidget);

    // Account Section
    expect(find.text('Sign in with Google'), findsOneWidget);

    // Trash & Archive Items
    expect(find.text('Auto-delete Trash'), findsOneWidget);
    expect(find.text('Retention Period'), findsOneWidget);

    // Cloud Sync Items
    expect(find.text('Auto-sync'), findsOneWidget);
    expect(find.text('Sync now'), findsOneWidget);
  });

  testWidgets('SettingsScreen shows user info when signed in', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    when(() => mockGoogleSignIn.currentUser).thenReturn(mockAccount);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('bob@example.com'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsNothing);
  });

  testWidgets('Toggling switches and dropdown should update state (UI check)', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    when(() => mockGoogleSignIn.currentUser).thenReturn(mockAccount);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final switches = find.byType(Switch);
    expect(switches, findsNWidgets(3));

    // Toggle biometric lock
    await tester.tap(switches.at(0));
    await tester.pump();

    // Toggle auto-delete trash
    expect(find.text('Retention Period'), findsOneWidget);
    await tester.tap(switches.at(1));
    await tester.pumpAndSettle();
    expect(find.text('Retention Period'), findsNothing);

    // Toggle auto-backup
    final switchesAfterHide = find.byType(Switch);
    await tester.tap(switchesAfterHide.at(2));
    await tester.pump();

    // Check for Theme dropdown
    expect(find.byType(DropdownButton<ThemeModeOption>), findsOneWidget);
    // Check for Retention Period dropdown is hidden now
    expect(find.byType(DropdownButton<int>), findsNothing);
  });
}

@Tags(['golden'])
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:diary/screens/settings_screen.dart';
import 'package:diary/services/auth_service.dart';
import 'package:diary/services/security_service.dart';
import 'package:diary/services/theme_service.dart';
import 'package:diary/data/diary_entry_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockSecurityService extends Mock implements SecurityService {}

class MockThemeService extends Mock implements ThemeService {}

class MockDiaryEntryStore extends Mock implements DiaryEntryStore {}

void main() {
  late MockGoogleSignIn mockGoogleSignIn;
  late MockSecurityService mockSecurityService;
  late MockThemeService mockThemeService;
  late MockDiaryEntryStore mockEntryStore;
  late AuthService authService;
  late StreamController<GoogleSignInAuthenticationEvent>
  authenticationEventsController;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockGoogleSignIn = MockGoogleSignIn();
    mockSecurityService = MockSecurityService();
    mockThemeService = MockThemeService();
    mockEntryStore = MockDiaryEntryStore();
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

    authService = AuthService(googleSignIn: mockGoogleSignIn);

    when(
      () => mockSecurityService.isBiometricLockEnabled,
    ).thenAnswer((_) async => false);

    when(() => mockThemeService.themeMode).thenReturn(ThemeMode.system);
    when(() => mockThemeService.addListener(any())).thenReturn(null);
    when(() => mockThemeService.removeListener(any())).thenReturn(null);
    when(() => mockEntryStore.close()).thenAnswer((_) async => {});
  });

  tearDown(() {
    authenticationEventsController.close();
  });

  testGoldens('SettingsScreen - appearance', (tester) async {
    await tester.pumpWidgetBuilder(
      SettingsScreen(
        onBackPressed: () {},
        authService: authService,
        securityService: mockSecurityService,
        themeService: mockThemeService,
        entryStore: mockEntryStore,
      ),
      wrapper: (child) =>
          MaterialApp(debugShowCheckedModeBanner: false, home: child),
      surfaceSize: const Size(390, 844), // iPhone 13/14 size
    );

    await screenMatchesGolden(tester, 'settings_screen_appearance');
  });
}

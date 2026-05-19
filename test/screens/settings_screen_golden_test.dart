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

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockSecurityService extends Mock implements SecurityService {}

class MockThemeService extends Mock implements ThemeService {}

void main() {
  late MockGoogleSignIn mockGoogleSignIn;
  late MockSecurityService mockSecurityService;
  late MockThemeService mockThemeService;
  late AuthService authService;
  late StreamController<GoogleSignInAccount?> currentUserController;

  setUp(() {
    mockGoogleSignIn = MockGoogleSignIn();
    mockSecurityService = MockSecurityService();
    mockThemeService = MockThemeService();
    currentUserController = StreamController<GoogleSignInAccount?>.broadcast();
    authService = AuthService(googleSignIn: mockGoogleSignIn);

    when(
      () => mockGoogleSignIn.onCurrentUserChanged,
    ).thenAnswer((_) => currentUserController.stream);
    when(() => mockGoogleSignIn.currentUser).thenReturn(null);

    when(
      () => mockSecurityService.isBiometricLockEnabled,
    ).thenAnswer((_) async => false);

    when(() => mockThemeService.themeMode).thenReturn(ThemeMode.system);
    when(() => mockThemeService.addListener(any())).thenReturn(null);
    when(() => mockThemeService.removeListener(any())).thenReturn(null);
  });

  tearDown(() {
    currentUserController.close();
  });

  testGoldens('SettingsScreen - appearance', (tester) async {
    await tester.pumpWidgetBuilder(
      SettingsScreen(
        authService: authService,
        securityService: mockSecurityService,
        themeService: mockThemeService,
      ),
      wrapper: (child) =>
          MaterialApp(debugShowCheckedModeBanner: false, home: child),
      surfaceSize: const Size(390, 844), // iPhone 13/14 size
    );

    await screenMatchesGolden(tester, 'settings_screen_appearance');
  });
}

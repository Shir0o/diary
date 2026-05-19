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

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

void main() {
  late MockGoogleSignIn mockGoogleSignIn;
  late AuthService authService;
  late StreamController<GoogleSignInAccount?> currentUserController;

  setUp(() {
    mockGoogleSignIn = MockGoogleSignIn();
    currentUserController = StreamController<GoogleSignInAccount?>.broadcast();
    authService = AuthService(
      googleSignIn: mockGoogleSignIn,
    );

    when(() => mockGoogleSignIn.onCurrentUserChanged)
        .thenAnswer((_) => currentUserController.stream);
    when(() => mockGoogleSignIn.currentUser).thenReturn(null);
  });

  tearDown(() {
    currentUserController.close();
  });

  testGoldens('SettingsScreen - appearance', (tester) async {
    await tester.pumpWidgetBuilder(
      SettingsScreen(authService: authService),
      wrapper: (child) =>
          MaterialApp(debugShowCheckedModeBanner: false, home: child),
      surfaceSize: const Size(390, 844), // iPhone 13/14 size
    );

    await screenMatchesGolden(tester, 'settings_screen_appearance');
  });
}

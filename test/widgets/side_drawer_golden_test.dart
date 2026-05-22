@Tags(['golden'])
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:diary/widgets/side_drawer.dart';
import 'package:diary/services/auth_service.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

void main() {
  late MockGoogleSignIn mockGoogleSignIn;
  late AuthService authService;
  late StreamController<GoogleSignInAuthenticationEvent>
  authenticationEventsController;

  setUp(() {
    mockGoogleSignIn = MockGoogleSignIn();
    authenticationEventsController =
        StreamController<GoogleSignInAuthenticationEvent>.broadcast();

    when(
      () => mockGoogleSignIn.authenticationEvents,
    ).thenAnswer((_) => authenticationEventsController.stream);
    when(() => mockGoogleSignIn.initialize()).thenAnswer((_) async {});

    authService = AuthService(googleSignIn: mockGoogleSignIn);
  });

  tearDown(() {
    authenticationEventsController.close();
  });

  group('SideDrawer Golden Tests', () {
    testGoldens('SideDrawer - appearance', (WidgetTester tester) async {
      final builder = GoldenBuilder.column()
        ..addScenario(
          'SideDrawer Opened',
          SizedBox(
            height: 844,
            width: 390,
            child: Scaffold(
              drawer: SideDrawer(
                onItemSelected: (_) {},
                selectedIndex: 0,
                authService: authService,
              ),
              body: const Center(child: Text('Body')),
            ),
          ),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        surfaceSize: const Size(600, 1000),
      );

      // Open the drawer manually in the test
      final ScaffoldState state = tester.firstState(find.byType(Scaffold));
      state.openDrawer();
      await tester.pumpAndSettle();

      await screenMatchesGolden(tester, 'side_drawer_appearance');
    });
  });
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:diary/services/auth_service.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

void main() {
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockAccount;
  late AuthService authService;
  late StreamController<GoogleSignInAuthenticationEvent>
  authenticationEventsController;

  setUp(() {
    mockGoogleSignIn = MockGoogleSignIn();
    mockAccount = MockGoogleSignInAccount();
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

    when(() => mockAccount.email).thenReturn('test@example.com');
    when(() => mockAccount.displayName).thenReturn('Test User');
    when(
      () => mockAccount.photoUrl,
    ).thenReturn('https://example.com/photo.png');
  });

  tearDown(() {
    authenticationEventsController.close();
  });

  group('AuthService', () {
    test('signIn signs in successfully', () async {
      when(
        () => mockGoogleSignIn.authenticate(),
      ).thenAnswer((_) async => mockAccount);

      final user = await authService.signIn();

      expect(user, isNotNull);
      expect(user?.email, 'test@example.com');
      verify(() => mockGoogleSignIn.authenticate()).called(1);
    });

    test('signOut signs out successfully', () async {
      when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async {});

      await authService.signOut();

      verify(() => mockGoogleSignIn.signOut()).called(1);
    });

    test('silentSignIn signs in if possible', () async {
      when(
        () => mockGoogleSignIn.attemptLightweightAuthentication(),
      ).thenAnswer((_) async => mockAccount);

      final user = await authService.silentSignIn();

      expect(user, isNotNull);
      expect(user?.email, 'test@example.com');
      verify(
        () => mockGoogleSignIn.attemptLightweightAuthentication(),
      ).called(1);
    });

    test('onCurrentUserChanged emits user changes', () async {
      expect(
        authService.onCurrentUserChanged,
        emitsInOrder([mockAccount, null]),
      );

      authenticationEventsController.add(
        GoogleSignInAuthenticationEventSignIn(user: mockAccount),
      );
      authenticationEventsController.add(
        GoogleSignInAuthenticationEventSignOut(),
      );
    });

    test(
      'initialize configures GoogleSignIn with client IDs from dotenv',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        addTearDown(() {
          debugDefaultTargetPlatformOverride = null;
        });

        await authService.initialize();

        verify(
          () => mockGoogleSignIn.initialize(
            clientId: 'test-android-client-id',
            serverClientId: 'test-web-client-id',
          ),
        ).called(1);
      },
    );
  });
}

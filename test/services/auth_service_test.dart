import 'dart:async';
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
  late StreamController<GoogleSignInAccount?> currentUserController;

  setUp(() {
    mockGoogleSignIn = MockGoogleSignIn();
    mockAccount = MockGoogleSignInAccount();
    currentUserController = StreamController<GoogleSignInAccount?>.broadcast();

    authService = AuthService(googleSignIn: mockGoogleSignIn);

    when(
      () => mockGoogleSignIn.onCurrentUserChanged,
    ).thenAnswer((_) => currentUserController.stream);
    when(() => mockAccount.email).thenReturn('test@example.com');
    when(() => mockAccount.displayName).thenReturn('Test User');
    when(
      () => mockAccount.photoUrl,
    ).thenReturn('https://example.com/photo.png');
  });

  tearDown(() {
    currentUserController.close();
  });

  group('AuthService', () {
    test('signIn signs in successfully', () async {
      when(
        () => mockGoogleSignIn.signIn(),
      ).thenAnswer((_) async => mockAccount);
      when(() => mockGoogleSignIn.currentUser).thenReturn(mockAccount);

      final user = await authService.signIn();

      expect(user, isNotNull);
      expect(user?.email, 'test@example.com');
      verify(() => mockGoogleSignIn.signIn()).called(1);
    });

    test('signOut signs out successfully', () async {
      when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

      await authService.signOut();

      verify(() => mockGoogleSignIn.signOut()).called(1);
    });

    test('silentSignIn signs in if possible', () async {
      when(
        () => mockGoogleSignIn.signInSilently(),
      ).thenAnswer((_) async => mockAccount);

      final user = await authService.silentSignIn();

      expect(user, isNotNull);
      expect(user?.email, 'test@example.com');
      verify(() => mockGoogleSignIn.signInSilently()).called(1);
    });

    test('onCurrentUserChanged emits user changes', () async {
      expect(
        authService.onCurrentUserChanged,
        emitsInOrder([mockAccount, null]),
      );

      currentUserController.add(mockAccount);
      currentUserController.add(null);
    });
  });
}

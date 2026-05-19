import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:diary/widgets/side_drawer.dart';
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
    
    authService = AuthService(
      googleSignIn: mockGoogleSignIn,
    );

    when(() => mockGoogleSignIn.onCurrentUserChanged)
        .thenAnswer((_) => currentUserController.stream);
    when(() => mockAccount.email).thenReturn('bob@example.com');
    when(() => mockAccount.displayName).thenReturn('Bob');
    when(() => mockAccount.photoUrl).thenReturn('');
  });

  tearDown(() {
    currentUserController.close();
  });

  Widget createWidgetUnderTest({
    required Function(int) onItemSelected,
    int selectedIndex = 0,
    required AuthService authService,
  }) {
    return MaterialApp(
      home: Scaffold(
        drawer: SideDrawer(
          onItemSelected: onItemSelected,
          selectedIndex: selectedIndex,
          authService: authService,
        ),
        body: const Center(child: Text('Body')),
      ),
    );
  }

  testWidgets('SideDrawer renders header and navigation items', (
    WidgetTester tester,
  ) async {
    when(() => mockGoogleSignIn.currentUser).thenReturn(null);

    await tester.pumpWidget(createWidgetUnderTest(
      onItemSelected: (_) {},
      authService: authService,
    ));

    // Open the drawer
    final ScaffoldState state = tester.firstState(find.byType(Scaffold));
    state.openDrawer();
    await tester.pumpAndSettle();

    expect(find.text('Diary App'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
  });
}

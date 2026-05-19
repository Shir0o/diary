import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diary/screens/biometric_lock_screen.dart';

void main() {
  testWidgets('renders all initial UI elements on BiometricLockScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BiometricLockScreen(
          onUnlock: () {},
          isAuthenticating: false,
          animate: false,
        ),
      ),
    );

    // Verify Title and subtitle
    expect(find.text('Diary is Locked'), findsOneWidget);
    expect(
      find.text('Securely locked to keep your personal entries private.'),
      findsOneWidget,
    );

    // Verify fingerprint icon button
    expect(find.byIcon(Icons.fingerprint_rounded), findsOneWidget);

    // Verify Unlock button
    expect(find.text('Unlock with Biometrics'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('tapping fingerprint icon or button triggers onUnlock callback', (
    WidgetTester tester,
  ) async {
    var unlockCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: BiometricLockScreen(
          onUnlock: () => unlockCalls++,
          isAuthenticating: false,
          animate: false,
        ),
      ),
    );

    // Tap fingerprint icon
    await tester.tap(find.byIcon(Icons.fingerprint_rounded));
    await tester.pump();
    expect(unlockCalls, 1);

    // Tap elevated button
    await tester.tap(find.text('Unlock with Biometrics'));
    await tester.pump();
    expect(unlockCalls, 2);
  });

  testWidgets('shows loading state when isAuthenticating is true', (
    WidgetTester tester,
  ) async {
    var unlockCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: BiometricLockScreen(
          onUnlock: () => unlockCalls++,
          isAuthenticating: true,
          animate: false,
        ),
      ),
    );

    // Verify progress indicator is shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Unlock with Biometrics'), findsNothing);

    // Tapping fingerprint icon should do nothing
    await tester.tap(find.byIcon(Icons.fingerprint_rounded));
    await tester.pump();
    expect(unlockCalls, 0);
  });

  testWidgets('displays error message when authentication fails', (
    WidgetTester tester,
  ) async {
    var unlockCalls = 0;

    // Start with authenticating state
    await tester.pumpWidget(
      MaterialApp(
        home: BiometricLockScreen(
          onUnlock: () => unlockCalls++,
          isAuthenticating: true,
          animate: false,
        ),
      ),
    );

    expect(find.textContaining('Authentication failed'), findsNothing);

    // Update to non-authenticating state while still locked (signaling failure)
    await tester.pumpWidget(
      MaterialApp(
        home: BiometricLockScreen(
          onUnlock: () => unlockCalls++,
          isAuthenticating: false,
          animate: false,
        ),
      ),
    );
    await tester.pump();

    // Verify error message is shown
    expect(
      find.text('Authentication failed. Please try again.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);

    // Tapping unlock again clears error (visually)
    await tester.tap(find.text('Unlock with Biometrics'));
    await tester.pump();
    expect(unlockCalls, 1);
  });
}

@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:diary/screens/biometric_lock_screen.dart';
import 'package:diary/config/app_theme.dart';

void main() {
  testGoldens('BiometricLockScreen - light theme appearance', (tester) async {
    await tester.pumpWidgetBuilder(
      BiometricLockScreen(
        onUnlock: () {},
        isAuthenticating: false,
        animate: false,
      ),
      wrapper: (child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: child,
      ),
      surfaceSize: const Size(390, 844), // iPhone 13/14 size
    );

    await screenMatchesGolden(tester, 'biometric_lock_screen_light');
  });

  testGoldens('BiometricLockScreen - dark theme appearance', (tester) async {
    await tester.pumpWidgetBuilder(
      BiometricLockScreen(
        onUnlock: () {},
        isAuthenticating: false,
        animate: false,
      ),
      wrapper: (child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: child,
      ),
      surfaceSize: const Size(390, 844),
    );

    await screenMatchesGolden(tester, 'biometric_lock_screen_dark');
  });
}

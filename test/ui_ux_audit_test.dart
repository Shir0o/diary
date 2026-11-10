import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diary/data/in_memory_diary_entry_store.dart';
import 'package:diary/main.dart';
import 'package:diary/models/diary_entry.dart';
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
  late StreamController<GoogleSignInAuthenticationEvent>
  authenticationEventsController;

  final testEntries = [
    DiaryEntry(
      id: '1',
      date: DateTime(2026, 4, 24, 10, 0),
      title: 'Starting a new project',
      content: 'Today I started the Diary app project.',
      mood: '🚀',
      location: 'Home Office',
      tags: const ['work'],
    ),
    DiaryEntry(
      id: '2',
      date: DateTime(2026, 4, 24, 14, 0),
      title: 'Coffee Break',
      content: 'Had a wonderful cup of coffee.',
      mood: '☕',
      location: 'Local Cafe',
      tags: const ['friends'],
    ),
  ];

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockGoogleSignIn = MockGoogleSignIn();
    mockSecurityService = MockSecurityService();
    mockThemeService = MockThemeService();
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
    when(
      () => mockGoogleSignIn.attemptLightweightAuthentication(),
    ).thenAnswer((_) async => null);

    authService = AuthService(googleSignIn: mockGoogleSignIn);

    when(
      () => mockSecurityService.isBiometricLockEnabled,
    ).thenAnswer((_) async => false);
    when(
      () => mockSecurityService.authenticate(),
    ).thenAnswer((_) async => true);

    when(() => mockThemeService.themePalette).thenReturn('lilac');
    when(() => mockThemeService.timelineLayout).thenReturn('playful');
    when(() => mockThemeService.userName).thenReturn('Sarah');
    when(() => mockThemeService.onboardingCompleted).thenReturn(true);
    when(() => mockThemeService.addListener(any())).thenReturn(null);
    when(() => mockThemeService.removeListener(any())).thenReturn(null);
  });

  tearDown(() {
    authenticationEventsController.close();
  });

  Widget createApp({required ThemeMode themeMode}) {
    when(() => mockThemeService.themeMode).thenReturn(themeMode);
    return RepaintBoundary(
      key: const ValueKey('audit_root'),
      child: DiaryApp(
        entryStore: InMemoryDiaryEntryStore(testEntries),
        authService: authService,
        securityService: mockSecurityService,
        themeService: mockThemeService,
      ),
    );
  }

  group('UI/UX Usability & Accessibility Audit', () {
    testWidgets('phone_light (390x844 @ 1.0x)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.textScaleFactorTestValue = 1.0;
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
        tester.platformDispatcher.clearPlatformBrightnessTestValue();
      });

      final List<FlutterErrorDetails> overflowErrors = [];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.toString().contains('RenderFlex overflowed')) {
          overflowErrors.add(details);
        }
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      await tester.pumpWidget(createApp(themeMode: ThemeMode.light));
      await tester.pumpAndSettle();

      if (autoUpdateGoldenFiles) {
        await expectLater(
          find.byKey(const ValueKey('audit_root')),
          matchesGoldenFile('goldens/phone_light.png'),
        );
      }

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      expect(
        overflowErrors,
        isEmpty,
        reason: 'RenderFlex overflows detected: $overflowErrors',
      );
    });

    testWidgets('phone_dark (390x844 @ 1.0x)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.textScaleFactorTestValue = 1.0;
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
        tester.platformDispatcher.clearPlatformBrightnessTestValue();
      });

      final List<FlutterErrorDetails> overflowErrors = [];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.toString().contains('RenderFlex overflowed')) {
          overflowErrors.add(details);
        }
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      await tester.pumpWidget(createApp(themeMode: ThemeMode.dark));
      await tester.pumpAndSettle();

      if (autoUpdateGoldenFiles) {
        await expectLater(
          find.byKey(const ValueKey('audit_root')),
          matchesGoldenFile('goldens/phone_dark.png'),
        );
      }

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      expect(
        overflowErrors,
        isEmpty,
        reason: 'RenderFlex overflows detected: $overflowErrors',
      );
    });

    testWidgets('small_large_font (320x568 @ 1.6x text scale)', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
        tester.platformDispatcher.clearPlatformBrightnessTestValue();
      });

      final List<FlutterErrorDetails> overflowErrors = [];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.toString().contains('RenderFlex overflowed')) {
          overflowErrors.add(details);
        }
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      await tester.pumpWidget(createApp(themeMode: ThemeMode.light));
      await tester.pumpAndSettle();

      if (autoUpdateGoldenFiles) {
        await expectLater(
          find.byKey(const ValueKey('audit_root')),
          matchesGoldenFile('goldens/small_large_font.png'),
        );
      }

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      expect(
        overflowErrors,
        isEmpty,
        reason: 'RenderFlex overflows detected: $overflowErrors',
      );
    });
  });
}

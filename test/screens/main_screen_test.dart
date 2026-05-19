import 'dart:async';
import 'package:diary/data/in_memory_diary_entry_store.dart';
import 'package:diary/main.dart';
import 'package:diary/models/diary_entry.dart';
import 'package:diary/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {}
class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

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
    when(() => mockGoogleSignIn.signInSilently())
        .thenAnswer((_) async => null);
  });

  tearDown(() {
    currentUserController.close();
  });

  final testEntries = [
    DiaryEntry(
      id: '1',
      date: DateTime(2026, 4, 24, 10, 0),
      title: 'Starting a new project',
      content: 'Today I started the Diary app project.',
      mood: '🚀',
      location: 'Home Office',
    ),
    DiaryEntry(
      id: '2',
      date: DateTime(2026, 4, 24, 14, 0),
      title: 'Coffee Break',
      content: 'Had a wonderful cup of coffee.',
      mood: '☕',
      location: 'Local Cafe',
    ),
  ];

  Widget createApp() {
    return DiaryApp(
      entryStore: InMemoryDiaryEntryStore(testEntries),
      authService: authService,
    );
  }

  testWidgets('menu button opens the main drawer', (tester) async {
    await tester.pumpWidget(createApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Diary App'), findsOneWidget);
    expect(find.text('Timeline'), findsWidgets);
    expect(find.text('Calendar'), findsWidgets);
    expect(find.text('Analytics'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('drawer destinations navigate to existing screens', (
    tester,
  ) async {
    await tester.pumpWidget(createApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calendar').last);
    await tester.pumpAndSettle();

    expect(find.text('Calendar'), findsWidgets);
    expect(find.byType(CalendarDatePicker), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Analytics').last);
    await tester.pumpAndSettle();

    expect(find.text('Analytics'), findsWidgets);
    expect(find.text('Total Entries'), findsOneWidget);
  });
}

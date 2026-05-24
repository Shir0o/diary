import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:diary/models/diary_entry.dart';
import 'package:diary/screens/new_entry_screen.dart';
import 'package:diary/services/location_service.dart';
import 'package:diary/services/speech_service.dart';

class MockLocationService extends Mock implements LocationService {}

class MockSpeechService extends Mock implements SpeechService {}

void main() {
  testWidgets('NewEntryScreen should display all required UI elements', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: NewEntryScreen()));

    // Top App Bar elements
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.text('New Entry'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    // Date & Time header (partial match as it might contain current date)
    expect(find.byType(Text), findsAtLeastNWidgets(2)); // Date and time

    // Main Text Input
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Write your heart out...'), findsOneWidget);

    // Bottom Toolbar icons
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    expect(find.byIcon(Icons.label_outlined), findsOneWidget);
    expect(find.byIcon(Icons.mood_outlined), findsOneWidget);
    expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);

    // Status indicator
    expect(find.text('Saved locally'), findsOneWidget);
  });

  testWidgets('Entering text should update the TextField', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: NewEntryScreen()));

    const testText = 'My secret diary entry';
    await tester.enterText(find.byType(TextField), testText);
    expect(find.text(testText), findsOneWidget);
  });

  testWidgets('Save returns a diary entry with entered content', (
    WidgetTester tester,
  ) async {
    DiaryEntry? savedEntry;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                savedEntry = await Navigator.of(
                  context,
                ).push<DiaryEntry>(NewEntryScreen.route());
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Saved entry body');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(savedEntry, isNotNull);
    expect(savedEntry!.title, 'Saved entry body');
    expect(savedEntry!.content, 'Saved entry body');
  });

  testWidgets('Editing pre-fills content and returns the same entry id', (
    WidgetTester tester,
  ) async {
    final existingEntry = DiaryEntry(
      id: 'entry-1',
      date: DateTime(2026, 4, 24, 10),
      title: 'Original title',
      content: 'Original body',
      mood: '🚀',
    );
    DiaryEntry? savedEntry;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                savedEntry = await Navigator.of(
                  context,
                ).push<DiaryEntry>(NewEntryScreen.route(entry: existingEntry));
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Original body'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Updated body');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(savedEntry, isNotNull);
    expect(savedEntry!.id, 'entry-1');
    expect(savedEntry!.content, 'Updated body');
  });

  testWidgets('Delete icon is not present', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: NewEntryScreen()));
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });

  testWidgets('Editing screen title is empty', (WidgetTester tester) async {
    final existingEntry = DiaryEntry(
      id: 'entry-1',
      date: DateTime(2026, 4, 24, 10),
      title: 'Original title',
      content: 'Original body',
      mood: '🚀',
    );
    await tester.pumpWidget(
      MaterialApp(home: NewEntryScreen(entry: existingEntry)),
    );
    expect(find.text('Edit Entry'), findsNothing);
  });

  testWidgets('Clearing content while editing returns untitled entry', (
    WidgetTester tester,
  ) async {
    final existingEntry = DiaryEntry(
      id: 'entry-1',
      date: DateTime(2026, 4, 24, 10),
      title: 'Original title',
      content: 'Original body',
      mood: '🚀',
    );
    DiaryEntry? savedEntry;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                savedEntry = await Navigator.of(
                  context,
                ).push<DiaryEntry>(NewEntryScreen.route(entry: existingEntry));
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(savedEntry, isNotNull);
    expect(savedEntry!.title, 'Untitled Entry');
    expect(savedEntry!.content, isEmpty);
  });

  testWidgets('Adding tags via bottom sheet updates screen state', (
    WidgetTester tester,
  ) async {
    DiaryEntry? savedEntry;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                savedEntry = await Navigator.of(context).push<DiaryEntry>(
                  NewEntryScreen.route(
                    existingTags: const ['work', 'personal'],
                  ),
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Tap label/tags icon
    await tester.tap(find.byIcon(Icons.label_outlined));
    await tester.pumpAndSettle();

    // Should open bottom sheet.
    expect(find.text('Add Tags'), findsOneWidget);
    expect(find.text('Suggested Tags'), findsOneWidget);
    expect(find.text('work'), findsOneWidget);
    expect(find.text('personal'), findsOneWidget);

    // Enter a new tag in the bottom sheet TextField.
    final tagTextField = find.byType(TextField).last;
    await tester.enterText(tagTextField, 'ideas');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Tap a suggested tag 'work'
    await tester.tap(find.text('work'));
    await tester.pumpAndSettle();

    // Tap 'Done' button to close bottom sheet
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Bottom sheet is closed
    expect(find.text('Add Tags'), findsNothing);

    // Verify chips are shown on screen
    expect(find.text('ideas'), findsOneWidget);
    expect(find.text('work'), findsOneWidget);

    // Enter content and save
    await tester.enterText(find.byType(TextField), 'Tag entry test');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(savedEntry, isNotNull);
    expect(savedEntry!.tags, containsAll(['ideas', 'work']));
  });

  testWidgets(
    'Selecting location from bottom sheet updates the location field',
    (WidgetTester tester) async {
      final mockLocationService = MockLocationService();
      when(
        () => mockLocationService.getAddressSuggestions(any()),
      ).thenAnswer((_) async => []);

      DiaryEntry? savedEntry;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  savedEntry = await Navigator.of(context).push<DiaryEntry>(
                    NewEntryScreen.route(locationService: mockLocationService),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // The entry location pin icon is in the bottom toolbar
      await tester.tap(find.byIcon(Icons.location_on_outlined).last);
      await tester.pumpAndSettle();

      // Verify the bottom sheet opened
      expect(find.text('Add Location'), findsOneWidget);

      // Enter some address manually
      await tester.enterText(find.byType(TextField).last, 'My Custom Address');
      await tester.tap(find.text('Save').last);
      await tester.pumpAndSettle();

      // The location should be displayed inline on the screen
      expect(find.text('My Custom Address'), findsOneWidget);

      // Save the entire entry
      await tester.enterText(find.byType(TextField).first, 'Body content');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedEntry, isNotNull);
      expect(savedEntry!.location, 'My Custom Address');
    },
  );

  testWidgets('Clearing location from bottom sheet removes location field', (
    WidgetTester tester,
  ) async {
    final mockLocationService = MockLocationService();
    when(
      () => mockLocationService.getAddressSuggestions(any()),
    ).thenAnswer((_) async => []);

    final existingEntry = DiaryEntry(
      id: 'entry-1',
      date: DateTime(2026, 4, 24, 10),
      title: 'Title',
      content: 'Body',
      mood: '🚀',
      location: 'Initial Location',
    );
    DiaryEntry? savedEntry;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                savedEntry = await Navigator.of(context).push<DiaryEntry>(
                  NewEntryScreen.route(
                    entry: existingEntry,
                    locationService: mockLocationService,
                  ),
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Initial Location'), findsOneWidget);

    // Tap location icon to open sheet
    await tester.tap(find.byIcon(Icons.location_on_outlined).last);
    await tester.pumpAndSettle();

    // Tap Clear in the sheet
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    // The location should be removed from the screen
    expect(find.text('Initial Location'), findsNothing);

    // Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(savedEntry, isNotNull);
    expect(savedEntry!.location, isNull);
  });

  testWidgets('Unsaved Changes Dialog - Empty new entry pops without warning', (
    WidgetTester tester,
  ) async {
    bool popped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                await Navigator.of(context).push(NewEntryScreen.route());
                popped = true;
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Find back arrow and tap it
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Should pop immediately without showing dialog
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(NewEntryScreen), findsNothing);
    expect(popped, isTrue);
  });

  testWidgets(
    'Unsaved Changes Dialog - New entry with content shows warning, keeps editing, or discards',
    (WidgetTester tester) async {
      bool popped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  await Navigator.of(context).push(NewEntryScreen.route());
                  popped = true;
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Enter content
      await tester.enterText(find.byType(TextField), 'Some content');
      await tester.pumpAndSettle();

      // Tap back arrow
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Unsaved Changes'), findsOneWidget);

      // Tap Keep Editing
      await tester.tap(find.text('Keep Editing'));
      await tester.pumpAndSettle();

      // Dialog should be gone, screen remains
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(NewEntryScreen), findsOneWidget);
      expect(popped, isFalse);

      // Tap back arrow again
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Dialog appears again
      expect(find.byType(AlertDialog), findsOneWidget);

      // Tap Discard
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      // Dialog and screen both popped
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(NewEntryScreen), findsNothing);
      expect(popped, isTrue);
    },
  );

  testWidgets(
    'Unsaved Changes Dialog - Editing existing entry without changes pops without warning',
    (WidgetTester tester) async {
      final existingEntry = DiaryEntry(
        id: 'entry-1',
        date: DateTime(2026, 4, 24, 10),
        title: 'Original title',
        content: 'Original body',
        mood: '🚀',
      );
      bool popped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  await Navigator.of(
                    context,
                  ).push(NewEntryScreen.route(entry: existingEntry));
                  popped = true;
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap back arrow without making changes
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should pop immediately without warning
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(NewEntryScreen), findsNothing);
      expect(popped, isTrue);
    },
  );

  testWidgets(
    'Unsaved Changes Dialog - Editing existing entry with changes shows warning, and reverts',
    (WidgetTester tester) async {
      final existingEntry = DiaryEntry(
        id: 'entry-1',
        date: DateTime(2026, 4, 24, 10),
        title: 'Original title',
        content: 'Original body',
        mood: '🚀',
      );
      bool popped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  await Navigator.of(
                    context,
                  ).push(NewEntryScreen.route(entry: existingEntry));
                  popped = true;
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Make a change
      await tester.enterText(find.byType(TextField), 'Modified body');
      await tester.pumpAndSettle();

      // Tap back arrow
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Warning should show
      expect(find.byType(AlertDialog), findsOneWidget);

      // Tap Keep Editing
      await tester.tap(find.text('Keep Editing'));
      await tester.pumpAndSettle();

      // Revert the changes back to original body
      await tester.enterText(find.byType(TextField), 'Original body');
      await tester.pumpAndSettle();

      // Tap back arrow again
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should pop immediately because changes were manually reverted
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(NewEntryScreen), findsNothing);
      expect(popped, isTrue);
    },
  );

  testWidgets(
    'Unsaved Changes Dialog - Tapping Save pops without showing dialog',
    (WidgetTester tester) async {
      DiaryEntry? savedEntry;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  savedEntry = await Navigator.of(
                    context,
                  ).push<DiaryEntry>(NewEntryScreen.route());
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Enter content (unsaved changes exist)
      await tester.enterText(find.byType(TextField), 'Some content');
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify dialog never appeared, and screen popped with the entry
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(NewEntryScreen), findsNothing);
      expect(savedEntry, isNotNull);
      expect(savedEntry!.content, 'Some content');
    },
  );

  testWidgets(
    'Unsaved Changes Dialog - DateTime difference in milliseconds is ignored',
    (WidgetTester tester) async {
      final initialDate = DateTime(2026, 5, 22, 10, 15, 30, 456);
      bool popped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          NewEntryScreen(initialDate: initialDate),
                    ),
                  );
                  popped = true;
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap back arrow without changes, should pop immediately
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(NewEntryScreen), findsNothing);
      expect(popped, isTrue);
    },
  );

  testWidgets(
    'Dictation button should toggle listening state and show listening panel',
    (WidgetTester tester) async {
      final mockSpeechService = MockSpeechService();
      when(() => mockSpeechService.isListening).thenReturn(false);
      when(() => mockSpeechService.isAvailable).thenReturn(true);
      when(() => mockSpeechService.initialize()).thenAnswer((_) async => true);
      when(() => mockSpeechService.stopListening()).thenAnswer((_) async {});

      bool startCalled = false;
      when(
        () => mockSpeechService.startListening(
          onResult: any(named: 'onResult'),
          onError: any(named: 'onError'),
          onStatusChange: any(named: 'onStatusChange'),
          onSoundLevelChange: any(named: 'onSoundLevelChange'),
        ),
      ).thenAnswer((invocation) async {
        startCalled = true;
        final onStatusChange =
            invocation.namedArguments[#onStatusChange] as Function(bool);
        onStatusChange(true);
      });

      await tester.pumpWidget(
        MaterialApp(home: NewEntryScreen(speechService: mockSpeechService)),
      );

      final dictationBtn = find.byKey(const ValueKey('dictation-button'));
      expect(dictationBtn, findsOneWidget);
      expect(find.text('Listening...'), findsNothing);

      await tester.tap(dictationBtn);
      await tester.pump();

      expect(startCalled, isTrue);
      expect(find.text('Listening...'), findsOneWidget);
      expect(find.text('Speak now to dictate your entry'), findsOneWidget);
      expect(find.text('Stop'), findsOneWidget);
    },
  );

  testWidgets(
    'Dictation should insert speech results at current cursor position',
    (WidgetTester tester) async {
      final mockSpeechService = MockSpeechService();
      when(() => mockSpeechService.isListening).thenReturn(false);
      when(() => mockSpeechService.isAvailable).thenReturn(true);
      when(() => mockSpeechService.initialize()).thenAnswer((_) async => true);
      when(() => mockSpeechService.stopListening()).thenAnswer((_) async {});

      Function(String)? resultCallback;
      Function(bool)? statusCallback;

      when(
        () => mockSpeechService.startListening(
          onResult: any(named: 'onResult'),
          onError: any(named: 'onError'),
          onStatusChange: any(named: 'onStatusChange'),
          onSoundLevelChange: any(named: 'onSoundLevelChange'),
        ),
      ).thenAnswer((invocation) async {
        resultCallback =
            invocation.namedArguments[#onResult] as Function(String);
        statusCallback =
            invocation.namedArguments[#onStatusChange] as Function(bool);
        statusCallback!(true);
      });

      await tester.pumpWidget(
        MaterialApp(home: NewEntryScreen(speechService: mockSpeechService)),
      );

      final textFieldFinder = find.byType(TextField).first;
      await tester.enterText(textFieldFinder, 'Hello !');
      await tester.pump();

      final TextField textFieldWidget = tester.widget<TextField>(
        textFieldFinder,
      );
      final controller = textFieldWidget.controller!;
      controller.selection = const TextSelection.collapsed(offset: 6);

      await tester.tap(find.byKey(const ValueKey('dictation-button')));
      await tester.pump();

      expect(resultCallback, isNotNull);

      resultCallback!('world');
      await tester.pump();

      expect(controller.text, 'Hello world!');
      expect(controller.selection.baseOffset, 11);

      resultCallback!('world of coding');
      await tester.pump();

      expect(controller.text, 'Hello world of coding!');
      expect(controller.selection.baseOffset, 21);

      await tester.tap(find.text('Stop'));
      await tester.pump();

      expect(find.text('Listening...'), findsNothing);
      expect(controller.text, 'Hello world of coding!');
    },
  );
}

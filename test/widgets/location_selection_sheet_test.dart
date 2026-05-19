import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:diary/services/location_service.dart';
import 'package:diary/widgets/location_selection_sheet.dart';

class MockLocationService extends Mock implements LocationService {}

void main() {
  late MockLocationService mockLocationService;

  setUp(() {
    mockLocationService = MockLocationService();
    when(() => mockLocationService.getAddressSuggestions(any())).thenAnswer((_) async => []);
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  testWidgets('renders all initial UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        LocationSelectionSheet(
          locationService: mockLocationService,
          initialLocation: '',
          onLocationSelected: (_) {},
        ),
      ),
    );

    expect(find.text('Add Location'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Use current location'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('initial location is filled in the search field', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        LocationSelectionSheet(
          locationService: mockLocationService,
          initialLocation: 'My Office',
          onLocationSelected: (_) {},
        ),
      ),
    );

    expect(find.text('My Office'), findsOneWidget);
  });

  testWidgets('typing in the search field displays suggestions', (WidgetTester tester) async {
    when(() => mockLocationService.getAddressSuggestions('Seatt'))
        .thenAnswer((_) async => ['Seattle, WA, USA', 'Seattle Tacoma Airport']);

    await tester.pumpWidget(
      buildTestableWidget(
        LocationSelectionSheet(
          locationService: mockLocationService,
          initialLocation: '',
          onLocationSelected: (_) {},
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Seatt');
    // Wait for the debounce timer (500ms)
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Seattle, WA, USA'), findsOneWidget);
    expect(find.text('Seattle Tacoma Airport'), findsOneWidget);
  });

  testWidgets('tapping a suggestion updates the text field', (WidgetTester tester) async {
    when(() => mockLocationService.getAddressSuggestions('Seatt'))
        .thenAnswer((_) async => ['Seattle, WA, USA']);

    await tester.pumpWidget(
      buildTestableWidget(
        LocationSelectionSheet(
          locationService: mockLocationService,
          initialLocation: '',
          onLocationSelected: (_) {},
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Seatt');
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.text('Seattle, WA, USA'));
    await tester.pump();

    // The text field should now contain the clicked suggestion
    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller?.text, 'Seattle, WA, USA');
  });

  testWidgets('tapping Use Current Location triggers GPS fetch', (WidgetTester tester) async {
    final completer = Completer<String?>();
    when(() => mockLocationService.getCurrentLocationName())
        .thenAnswer((_) => completer.future);

    await tester.pumpWidget(
      buildTestableWidget(
        LocationSelectionSheet(
          locationService: mockLocationService,
          initialLocation: '',
          onLocationSelected: (_) {},
        ),
      ),
    );

    await tester.tap(find.text('Use current location'));
    await tester.pump(); // Start fetching - shows detecting spinner

    expect(find.text('Detecting location...'), findsOneWidget);

    completer.complete('Detected City');
    await tester.pumpAndSettle(); // Finish fetching

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller?.text, 'Detected City');
  });

  testWidgets('tapping Save emits location and pops', (WidgetTester tester) async {
    String? selectedLocation = 'not-called';
    bool popped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => LocationSelectionSheet(
                    locationService: mockLocationService,
                    initialLocation: 'Initial Office',
                    onLocationSelected: (val) {
                      selectedLocation = val;
                    },
                  ),
                ).then((_) {
                  popped = true;
                });
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Saved Office Address');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(selectedLocation, 'Saved Office Address');
    expect(popped, isTrue);
  });

  testWidgets('tapping Clear emits null location and pops', (WidgetTester tester) async {
    String? selectedLocation = 'not-called';
    bool popped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => LocationSelectionSheet(
                    locationService: mockLocationService,
                    initialLocation: 'Initial Office',
                    onLocationSelected: (val) {
                      selectedLocation = val;
                    },
                  ),
                ).then((_) {
                  popped = true;
                });
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    expect(selectedLocation, isNull);
    expect(popped, isTrue);
  });
}

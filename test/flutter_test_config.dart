import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'helpers/mock_google_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  mockGoogleFonts();
  return GoldenToolkit.runWithConfiguration(
    () async {
      await testMain();
    },
    config: GoldenToolkitConfiguration(
      defaultDevices: const [
        Device.phone,
        Device.iphone11,
      ],
      enableRealShadows: true,
    ),
  );
}

import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'helpers/mock_google_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  mockGoogleFonts();
  dotenv.loadFromString(
    envString: '''
GOOGLE_ANDROID_CLIENT_ID=test-android-client-id
GOOGLE_IOS_CLIENT_ID=test-ios-client-id
GOOGLE_WEB_CLIENT_ID=test-web-client-id
''',
  );
  return GoldenToolkit.runWithConfiguration(
    () async {
      await testMain();
    },
    config: GoldenToolkitConfiguration(
      defaultDevices: const [Device.phone, Device.iphone11],
      enableRealShadows: true,
    ),
  );
}

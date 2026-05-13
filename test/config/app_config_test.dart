import 'package:diary/config/app_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads Google client IDs from dotenv', () {
    dotenv.loadFromString(
      envString: '''
GOOGLE_ANDROID_CLIENT_ID=android-client-id
GOOGLE_IOS_CLIENT_ID=ios-client-id
GOOGLE_WEB_CLIENT_ID=web-client-id
''',
    );

    expect(AppConfig.googleAndroidClientId, 'android-client-id');
    expect(AppConfig.googleIosClientId, 'ios-client-id');
    expect(AppConfig.googleWebClientId, 'web-client-id');
  });
}

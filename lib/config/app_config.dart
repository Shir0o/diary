import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig._();

  static String get googleAndroidClientId {
    return dotenv.maybeGet('GOOGLE_ANDROID_CLIENT_ID') ?? '';
  }

  static String get googleIosClientId {
    return dotenv.maybeGet('GOOGLE_IOS_CLIENT_ID') ?? '';
  }
}

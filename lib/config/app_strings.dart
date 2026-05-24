class AppStrings {
  const AppStrings._();

  // Speech Recognition & Dictation Localizable Strings
  static const String dictationListening = 'Listening...';
  static const String dictationSpeakPrompt = 'Speak now to dictate your entry';
  static const String dictationStopButton = 'Stop';
  static const String speechNotAvailable = 'Speech recognition not available';

  static String dictationError(String error) {
    return 'Dictation Error: $error';
  }

  static String dictationFailed(String exception) {
    return 'Failed to start dictation: $exception';
  }
}

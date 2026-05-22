import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'drive_service.dart';

import '../config/app_config.dart';

class AuthService {
  final GoogleSignIn _googleSignIn;
  GoogleSignInAccount? _currentUser;
  final StreamController<GoogleSignInAccount?> _userController =
      StreamController<GoogleSignInAccount?>.broadcast();

  AuthService({GoogleSignIn? googleSignIn, GoogleSignInAccount? initialUser})
    : _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
      _currentUser = initialUser {
    _googleSignIn.authenticationEvents.listen((event) {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        if (_currentUser != event.user) {
          _currentUser = event.user;
          _userController.add(event.user);
        }
      } else if (event is GoogleSignInAuthenticationEventSignOut) {
        if (_currentUser != null) {
          _currentUser = null;
          _userController.add(null);
        }
      }
    });
  }

  Stream<GoogleSignInAccount?> get onCurrentUserChanged =>
      _userController.stream;

  GoogleSignInAccount? get currentUser => _currentUser;

  DriveService get driveService =>
      DriveService(_googleSignIn, currentUserProvider: () => currentUser);

  Future<void> initialize() async {
    try {
      final webClientId = AppConfig.googleWebClientId.isEmpty
          ? null
          : AppConfig.googleWebClientId;
      String? clientId;
      if (kIsWeb) {
        clientId = webClientId;
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        clientId = AppConfig.googleAndroidClientId.isEmpty
            ? null
            : AppConfig.googleAndroidClientId;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        clientId = AppConfig.googleIosClientId.isEmpty
            ? null
            : AppConfig.googleIosClientId;
      }

      await _googleSignIn.initialize(
        clientId: clientId,
        serverClientId: webClientId,
      );
    } catch (e) {
      debugPrint('Error initializing GoogleSignIn: $e');
    }
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      final user = await _googleSignIn.authenticate();
      if (_currentUser != user) {
        _currentUser = user;
        _userController.add(user);
      }
      return user;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      return null;
    }
  }

  Future<GoogleSignInAccount?> silentSignIn() async {
    try {
      final user = await _googleSignIn.attemptLightweightAuthentication();
      if (_currentUser != user) {
        _currentUser = user;
        _userController.add(user);
      }
      return user;
    } catch (e) {
      debugPrint('Error silent signing in: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      if (_currentUser != null) {
        _currentUser = null;
        _userController.add(null);
      }
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
}

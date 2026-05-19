import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'drive_service.dart';

class AuthService {
  final GoogleSignIn _googleSignIn;

  AuthService({
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: [
                'email',
                'https://www.googleapis.com/auth/userinfo.profile',
                drive.DriveApi.driveFileScope,
              ],
            );

  Stream<GoogleSignInAccount?> get onCurrentUserChanged => _googleSignIn.onCurrentUserChanged;

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  DriveService get driveService => DriveService(_googleSignIn);

  Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<GoogleSignInAccount?> silentSignIn() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (e) {
      print('Error silent signing in: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}

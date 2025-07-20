import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class GoogleSignInService {
  static GoogleSignIn? _googleSignIn;
  
  static GoogleSignIn get _instance {
    if (_googleSignIn == null) {
      if (kIsWeb) {
        // Client ID untuk web dari Firebase Console
        _googleSignIn = GoogleSignIn(
          clientId: '1020357822298-8b145vmidssfalial6fa6mcqg16gqv3u.apps.googleusercontent.com',
        );
      } else {
        // Untuk Android, otomatis menggunakan konfigurasi dari google-services.json
        _googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
        );
      }
    }
    return _googleSignIn!;
  }

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _instance.signIn();
      
      if (googleUser == null) {
        print('Google Sign-In cancelled by user');
        return null;
      }

      // Obtain auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      print('Google Sign-In berhasil: ${userCredential.user?.email}');
      return userCredential;
      
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await _instance.signOut();
    await FirebaseAuth.instance.signOut();
  }
}
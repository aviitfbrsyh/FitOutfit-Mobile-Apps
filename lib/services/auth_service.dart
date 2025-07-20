import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email & Password Sign In
  static Future<AuthResult> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update last login timestamp
      await _updateLastLogin(credential.user!.uid);

      return AuthResult(success: true, user: credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  // Email & Password Sign Up
  static Future<AuthResult> signUpWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    required DateTime birthDate, // NEW: Birth date parameter
  }) async {
    try {
      // Create user with Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(fullName);

      // Save user data to Firestore
      await _saveUserToFirestore(
        user: userCredential.user!,
        fullName: fullName,
        birthDate: birthDate,
      );

      return AuthResult(success: true, user: userCredential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  // Google Sign In
  static Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult(success: false, error: 'Google sign-in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Save Google user to Firestore (if new user)
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await _saveGoogleUserToFirestore(userCredential.user!);
      }

      return AuthResult(success: true, user: userCredential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(success: false, error: 'An unexpected error occurred');
    }
  }

  // Password Reset
  static Future<AuthResult> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return AuthResult(success: true, message: "Password reset email sent. Please check your inbox.");
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: e.message ?? "Failed to send reset email.");
    } catch (e) {
      return AuthResult(success: false, error: "An error occurred.");
    }
  }

  // Sign Out
  static Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  // Save user data to Firestore
  static Future<void> _saveUserToFirestore({
    required User user,
    required String fullName,
    required DateTime birthDate,
  }) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': fullName,
        'email': user.email,
        'tanggal_lahir': Timestamp.fromDate(birthDate), // Save as Firestore Timestamp
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'profileImageUrl': user.photoURL,
        'provider': 'email', // Track registration method
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving user to Firestore: $e');
      // Don't throw error here to not disrupt the registration flow
    }
  }

  // Save Google user to Firestore
  static Future<void> _saveGoogleUserToFirestore(User user) async {
    try {
      // Check if user document already exists
      final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
      
      if (!docSnapshot.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName ?? 'Google User',
          'email': user.email,
          'tanggal_lahir': null, // Google sign-in doesn't provide birth date
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'profileImageUrl': user.photoURL,
          'provider': 'google', // Track registration method
        });
      }
    } catch (e) {
      print('Error saving Google user to Firestore: $e');
    }
  }

  // Update last login timestamp
  static Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  // Get user data from Firestore
  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      return docSnapshot.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user profile
  static Future<void> updateUserProfile({
    required String uid,
    String? name,
    DateTime? birthDate,
    String? profileImageUrl,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updateData['name'] = name;
      if (birthDate != null) updateData['tanggal_lahir'] = Timestamp.fromDate(birthDate);
      if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;

      await _firestore.collection('users').doc(uid).update(updateData);
    } catch (e) {
      throw 'Failed to update profile: $e';
    }
  }

  // Get user-friendly error messages
  static String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

// Result class for auth operations
class AuthResult {
  final bool success;
  final User? user;
  final String? error;
  final String? message;

  AuthResult({required this.success, this.user, this.error, this.message});
}

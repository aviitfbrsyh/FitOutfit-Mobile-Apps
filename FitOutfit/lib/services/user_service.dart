import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Jika pakai Firebase
import '../models/user_personalization.dart';

class UserService {
  static const String _currentUserKey = 'current_user';
  static const String _userIdKey = 'current_user_id';

  // Method yang sudah ada
  Future<UserPersonalization> fetchUserPersonalization(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return UserPersonalization(
      bodyShape: 'Hourglass',
      skinTone: 'Medium',
      hairColor: 'Brown',
      personalColor: 'Spring',
    );
  }

  // Method baru untuk current user management - DIPERBAIKI
  static Future<String> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Cek dari Firebase Auth dulu
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      String username = firebaseUser.displayName ?? 
                       firebaseUser.email?.split('@').first ?? 
                       'User';
      // Simpan ke SharedPreferences untuk cache
      await prefs.setString(_currentUserKey, username);
      return username;
    }
    
    // Fallback ke SharedPreferences
    String? cachedUsername = prefs.getString(_currentUserKey);
    if (cachedUsername != null && cachedUsername.isNotEmpty) {
      return cachedUsername;
    }
    
    // Jika tidak ada sama sekali, return guest
    return 'Guest';
  }

  static Future<String> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Cek dari Firebase Auth dulu
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      // Simpan ke SharedPreferences untuk cache
      await prefs.setString(_userIdKey, firebaseUser.uid);
      return firebaseUser.uid;
    }
    
    // Fallback ke SharedPreferences
    return prefs.getString(_userIdKey) ?? 'guest_user';
  }

  // Method untuk login dan sinkronisasi otomatis
  static Future<void> syncUserFromAuth() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      String username = firebaseUser.displayName ?? 
                       firebaseUser.email?.split('@').first ?? 
                       'User';
      await setCurrentUser(username, userId: firebaseUser.uid);
    }
  }

  static Future<void> setCurrentUser(String username, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, username);
    if (userId != null) {
      await prefs.setString(_userIdKey, userId);
    }
  }

  static Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    await prefs.remove(_userIdKey);
  }

  static Future<bool> isLoggedIn() async {
    // Cek Firebase Auth dulu
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) return true;
    
    // Fallback ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_currentUserKey);
  }

  // Enhanced method - gabungin user info dengan personalization
  Future<Map<String, dynamic>> getCurrentUserWithPersonalization() async {
    final username = await getCurrentUser();
    final userId = await getCurrentUserId();
    final personalization = await fetchUserPersonalization(userId);

    return {
      'username': username,
      'userId': userId,
      'personalization': personalization,
    };
  }
}

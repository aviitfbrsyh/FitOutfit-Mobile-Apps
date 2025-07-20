import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String> uploadImage({
    required Uint8List imageBytes,
    required String fileName,
    String folder = 'wardrobe_items',
  }) async {
    try {
      print('🔥 Starting Firebase upload: $fileName');
      print('🔥 Project: fitoutfit-f47ae');
      print('🔥 Image size: ${imageBytes.length} bytes');
      print('🔥 Platform: ${kIsWeb ? 'WEB' : 'MOBILE'}');
      
      final ref = _storage.ref().child('$folder/$fileName');
      
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploaded_by': 'fitoutfit_app',
          'upload_time': DateTime.now().toIso8601String(),
          'platform': kIsWeb ? 'web' : 'mobile',
        },
      );
      
      print('🔥 Starting upload to: gs://fitoutfit-f47ae.appspot.com/$folder/$fileName');
      final uploadTask = ref.putData(imageBytes, metadata);
      
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('🔥 Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      });
      
      final snapshot = await uploadTask;
      print('🔥 Upload completed: ${snapshot.state}');
      
      final downloadUrl = await ref.getDownloadURL();
      print('🔥 ✅ SUCCESS! Download URL: $downloadUrl');
      
      return downloadUrl;
    } catch (e) {
      print('❌ Firebase upload error: $e');
      print('❌ Error type: ${e.runtimeType}');
      if (e is FirebaseException) {
        print('❌ Firebase error code: ${e.code}');
        print('❌ Firebase error message: ${e.message}');
      }
      throw Exception('Failed to upload image: $e');
    }
  }

  static String generateFileName(String originalName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final cleanName = originalName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final platform = kIsWeb ? 'web' : 'mobile';
    return '${cleanName}_${timestamp}_$platform.jpg';
  }

  static Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('🔥 Image deleted successfully: $imageUrl');
    } catch (e) {
      print('❌ Delete error: $e');
      throw Exception('Failed to delete image: $e');
    }
  }
}

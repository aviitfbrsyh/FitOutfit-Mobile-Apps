import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoritesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  // Get favorites collection reference
  static CollectionReference<Map<String, dynamic>> _getFavoritesCollection() {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(userId).collection('favorites');
  }

  // Add item to favorites
  static Future<void> addToFavorites({
    required String itemId,
    required String title,
    required String category,
    required Color color,
    required IconData icon,
    String? subtitle,
    String? imageUrl,
    String? stats,
    IconData? statsIcon,
    int count = 0,
    List<String> tags = const [],
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final favoritesRef = _getFavoritesCollection();
      
      // Check if item already exists
      final existingDoc = await favoritesRef.doc(itemId).get();
      if (existingDoc.exists) {
        // Item already in favorites, do nothing or update
        return;
      }

      // Add to favorites
      await favoritesRef.doc(itemId).set({
        'id': itemId,
        'title': title,
        'subtitle': subtitle ?? '',
        'category': category,
        'color': color.value, // Convert Color to int
        'icon': icon.codePoint, // Convert IconData to int
        'statsIcon': statsIcon?.codePoint, // Convert IconData to int
        'stats': stats ?? '',
        'count': count,
        'tags': tags,
        'imageUrl': imageUrl ?? '',
        'dateAdded': FieldValue.serverTimestamp(),
        'additionalData': additionalData ?? {},
      });
    } catch (e) {
      print('Error adding to favorites: $e');
      rethrow;
    }
  }

  // Remove item from favorites
  static Future<void> removeFromFavorites(String itemId) async {
    try {
      final favoritesRef = _getFavoritesCollection();
      await favoritesRef.doc(itemId).delete();
    } catch (e) {
      print('Error removing from favorites: $e');
      rethrow;
    }
  }

  // Check if item is in favorites
  static Future<bool> isInFavorites(String itemId) async {
    try {
      final favoritesRef = _getFavoritesCollection();
      final doc = await favoritesRef.doc(itemId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking favorites: $e');
      return false;
    }
  }

  // Get favorites stream (realtime)
  static Stream<QuerySnapshot> getFavoritesStream() {
    try {
      final favoritesRef = _getFavoritesCollection();
      return favoritesRef.orderBy('dateAdded', descending: true).snapshots();
    } catch (e) {
      print('Error getting favorites stream: $e');
      return const Stream.empty();
    }
  }

  // Get favorites list (one time)
  static Future<List<Map<String, dynamic>>> getFavoritesList() async {
    try {
      final favoritesRef = _getFavoritesCollection();
      final snapshot = await favoritesRef.orderBy('dateAdded', descending: true).get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        
        // Convert color and icon from int if needed
        if (data['color'] is int) data['color'] = Color(data['color']);
        if (data['icon'] is int) {
          data['icon'] = IconData(data['icon'], fontFamily: 'MaterialIcons');
        }
        if (data['statsIcon'] is int) {
          data['statsIcon'] = IconData(data['statsIcon'], fontFamily: 'MaterialIcons');
        }
        if (data['dateAdded'] is Timestamp) {
          data['dateAdded'] = (data['dateAdded'] as Timestamp).toDate();
        }
        
        // Fallback untuk field yang mungkin tidak ada
        data['stats'] ??= '';
        data['count'] ??= 0;
        data['tags'] ??= [];
        data['subtitle'] ??= '';
        data['category'] ??= '';
        
        return data;
      }).toList();
    } catch (e) {
      print('Error getting favorites list: $e');
      return [];
    }
  }

  // Toggle favorites (add if not exists, remove if exists)
  static Future<bool> toggleFavorite({
    required String itemId,
    required String title,
    required String category,
    required Color color,
    required IconData icon,
    String? subtitle,
    String? imageUrl,
    String? stats,
    IconData? statsIcon,
    int count = 0,
    List<String> tags = const [],
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final isFavorite = await isInFavorites(itemId);
      
      if (isFavorite) {
        await removeFromFavorites(itemId);
        return false; // Now not favorite
      } else {
        await addToFavorites(
          itemId: itemId,
          title: title,
          category: category,
          color: color,
          icon: icon,
          subtitle: subtitle,
          imageUrl: imageUrl,
          stats: stats,
          statsIcon: statsIcon,
          count: count,
          tags: tags,
          additionalData: additionalData,
        );
        return true; // Now favorite
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      rethrow;
    }
  }

  // Get favorites count
  static Future<int> getFavoritesCount() async {
    try {
      final favoritesRef = _getFavoritesCollection();
      final snapshot = await favoritesRef.get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting favorites count: $e');
      return 0;
    }
  }

  // Search favorites
  static Future<List<Map<String, dynamic>>> searchFavorites(String query) async {
    try {
      final allFavorites = await getFavoritesList();
      final lowercaseQuery = query.toLowerCase();
      
      return allFavorites.where((item) {
        final title = (item['title'] ?? '').toString().toLowerCase();
        final subtitle = (item['subtitle'] ?? '').toString().toLowerCase();
        final category = (item['category'] ?? '').toString().toLowerCase();
        final tags = (item['tags'] as List?)?.cast<String>() ?? [];
        
        return title.contains(lowercaseQuery) ||
               subtitle.contains(lowercaseQuery) ||
               category.contains(lowercaseQuery) ||
               tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
      }).toList();
    } catch (e) {
      print('Error searching favorites: $e');
      return [];
    }
  }

  // Filter favorites by category
  static Future<List<Map<String, dynamic>>> getFavoritesByCategory(String category) async {
    try {
      final allFavorites = await getFavoritesList();
      final lowercaseCategory = category.toLowerCase();
      
      return allFavorites.where((item) {
        final itemCategory = (item['category'] ?? '').toString().toLowerCase();
        
        // Handle special cases
        if (lowercaseCategory == 'articles') {
          return itemCategory.contains('article') || itemCategory.contains('news');
        }
        
        return itemCategory.replaceAll('-', '').replaceAll('s', '') ==
               lowercaseCategory.replaceAll('-', '').replaceAll('s', '');
      }).toList();
    } catch (e) {
      print('Error filtering favorites by category: $e');
      return [];
    }
  }
} 

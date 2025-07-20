import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  // ✅ PERBAIKI COLLECTION REFERENCE - SESUAIKAN DENGAN WARDROBE_PAGE
  static CollectionReference get _wardrobeCollection {
    if (currentUserId == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('wardrobe_items'); // ✅ UBAH DARI 'wardrobe' KE 'wardrobe_items'
  }

  // ✅ SAVE WARDROBE ITEM
  static Future<String> saveWardrobeItem(Map<String, dynamic> itemData) async {
    try {
      print('🔥 Saving item to Firestore: ${itemData['name']}');

      // ✅ TAMBAH VALIDATION
      if (itemData['name'] == null || itemData['name'].toString().trim().isEmpty) {
        throw Exception('Item name is required');
      }

      final docRef = await _wardrobeCollection.add({
        ...itemData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Item saved with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error saving item: $e');
      rethrow;
    }
  }

  // ✅ LOAD ALL WARDROBE ITEMS
  static Future<List<Map<String, dynamic>>> loadWardrobeItems() async {
    try {
      print('🔥 Loading wardrobe items from Firestore...');

      final snapshot = await _wardrobeCollection
          .orderBy('createdAt', descending: true)
          .get();

      final items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID
        
        // ✅ ENSURE SAFE DATA TYPES
        data['favorite'] = data['favorite'] ?? false;
        data['tags'] = data['tags'] ?? [];
        data['name'] = data['name'] ?? 'Unnamed Item';
        data['category'] = data['category'] ?? 'Other';
        data['color'] = data['color'] ?? 'Unknown';
        
        return data;
      }).toList();

      print('✅ Loaded ${items.length} items from Firestore');
      return items;
    } catch (e) {
      print('❌ Error loading items: $e');
      return [];
    }
  }

  // ✅ UPDATE WARDROBE ITEM
  static Future<void> updateWardrobeItem(
    String itemId,
    Map<String, dynamic> updates,
  ) async {
    try {
      print('🔥 Updating item: $itemId');

      // ✅ VALIDATION
      if (itemId.trim().isEmpty) {
        throw Exception('Item ID cannot be empty');
      }

      await _wardrobeCollection.doc(itemId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Item updated successfully');
    } catch (e) {
      print('❌ Error updating item: $e');
      rethrow;
    }
  }

  // ✅ DELETE WARDROBE ITEM - IMPROVED
  static Future<void> deleteWardrobeItem(String itemId) async {
    try {
      print('🔥 Deleting item: $itemId');

      // ✅ VALIDATION
      if (itemId.trim().isEmpty) {
        throw Exception('Item ID cannot be empty');
      }

      // ✅ CHECK IF DOCUMENT EXISTS FIRST
      final doc = await _wardrobeCollection.doc(itemId).get();
      if (!doc.exists) {
        throw Exception('Item not found');
      }

      await _wardrobeCollection.doc(itemId).delete();

      print('✅ Item deleted successfully');
    } catch (e) {
      print('❌ Error deleting item: $e');
      rethrow;
    }
  }

  // ✅ TOGGLE FAVORITE
  static Future<void> toggleFavorite(String itemId, bool isFavorite) async {
    try {
      print('🔥 Toggling favorite for item: $itemId to $isFavorite');
      await updateWardrobeItem(itemId, {'favorite': isFavorite});
      print('✅ Favorite toggled successfully');
    } catch (e) {
      print('❌ Error toggling favorite: $e');
      rethrow;
    }
  }

  // ✅ TAMBAH METHOD BARU - GET SINGLE ITEM
  static Future<Map<String, dynamic>?> getWardrobeItem(String itemId) async {
    try {
      final doc = await _wardrobeCollection.doc(itemId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('❌ Error getting item: $e');
      return null;
    }
  }

  // ✅ TAMBAH METHOD BARU - COUNT ITEMS
  static Future<int> getItemsCount() async {
    try {
      final snapshot = await _wardrobeCollection.get();
      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error counting items: $e');
      return 0;
    }
  }

  // ✅ TAMBAH METHOD BARU - COUNT FAVORITES
  static Future<int> getFavoritesCount() async {
    try {
      final snapshot = await _wardrobeCollection
          .where('favorite', isEqualTo: true)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error counting favorites: $e');
      return 0;
    }
  }

static Future<void> updateWardrobeFavorite(String itemId, bool isFavorite) async {
  await _wardrobeCollection
      .doc(itemId)
      .update({'favorite': isFavorite});
}

  // ✅ TAMBAH METHOD BARU - BATCH DELETE (untuk mass delete)
  static Future<void> deleteMultipleItems(List<String> itemIds) async {
    try {
      final batch = _firestore.batch();
      
      for (String itemId in itemIds) {
        batch.delete(_wardrobeCollection.doc(itemId));
      }
      
      await batch.commit();
      print('✅ ${itemIds.length} items deleted successfully');
    } catch (e) {
      print('❌ Error batch deleting items: $e');
      rethrow;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/wardrobe_item.dart';

class WardrobeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // ✅ GET CURRENT USER ID
  static String? get currentUserId => _auth.currentUser?.uid;
  
  // ✅ COLLECTION REFERENCE
  static CollectionReference get _wardrobeCollection => 
      _firestore.collection('wardrobe_items');

  // ✅ ADD ITEM TO FIRESTORE
  static Future<String> addWardrobeItem(WardrobeItem item) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');
      
      print('🔥 Adding wardrobe item to Firestore...');
      print('🔥 User ID: $userId');
      print('🔥 Item: ${item.name}');
      
      final itemWithUserId = WardrobeItem(
        id: '', // Will be set by Firestore
        name: item.name,
        category: item.category,
        color: item.color,
        description: item.description,
        imageUrl: item.imageUrl,
        tags: item.tags,
        userId: userId, // ✅ SET USER ID
        createdAt: DateTime.now(),
        favorite: item.favorite,
      );
      
      final docRef = await _wardrobeCollection.add(itemWithUserId.toFirestore());
      
      print('✅ Item added successfully with ID: ${docRef.id}');
      return docRef.id;
      
    } catch (e) {
      print('❌ Error adding wardrobe item: $e');
      throw Exception('Failed to add item: $e');
    }
  }

  // ✅ GET USER'S WARDROBE ITEMS
  static Future<List<WardrobeItem>> getUserWardrobeItems() async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');
      
      print('🔍 Fetching wardrobe items for user: $userId');
      
      final querySnapshot = await _wardrobeCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      final items = querySnapshot.docs
          .map((doc) => WardrobeItem.fromFirestore(
              doc.data() as Map<String, dynamic>, 
              doc.id
            ))
          .toList();
      
      print('✅ Found ${items.length} wardrobe items');
      return items;
      
    } catch (e) {
      print('❌ Error fetching wardrobe items: $e');
      return [];
    }
  }

  // ✅ TOGGLE FAVORITE
  static Future<void> toggleFavorite(String itemId, bool isFavorite) async {
    try {
      await _wardrobeCollection.doc(itemId).update({
        'favorite': isFavorite,
      });
      print('✅ Favorite status updated');
      
    } catch (e) {
      print('❌ Error toggling favorite: $e');
      throw Exception('Failed to update favorite: $e');
    }
  }

  // ✅ DELETE ITEM
  static Future<void> deleteWardrobeItem(String itemId) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not logged in');
      
      await _wardrobeCollection.doc(itemId).delete();
      print('✅ Item deleted successfully');
      
    } catch (e) {
      print('❌ Error deleting wardrobe item: $e');
      throw Exception('Failed to delete item: $e');
    }
  }
}

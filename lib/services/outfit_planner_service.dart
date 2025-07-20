import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/outfit_planner/outfit_planner_page.dart';

class OutfitPlannerService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection path for outfit plans
  static String get _outfitPlansCollection => 'outfit_plans';

  // Get current user ID
  static String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  // Save outfit event to database
  static Future<void> saveOutfitEvent(DateTime date, OutfitEvent event) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      print('🔥 Saving outfit event to database...');
      print('🔍 User ID: $_userId');
      print('🔍 Date: ${date.toIso8601String()}');
      print('🔍 Event ID: ${event.id}');

      // Create document reference
      final docRef = _firestore
          .collection(_outfitPlansCollection)
          .doc(_userId)
          .collection('events')
          .doc('${_formatDateKey(date)}_${event.id}');

      // Convert outfit event to map
      final eventData = _outfitEventToMap(event, date);

      // Save to database
      await docRef.set(eventData);

      print('✅ Outfit event saved successfully to database');
    } catch (e) {
      print('❌ Error saving outfit event: $e');
      throw Exception('Failed to save outfit: $e');
    }
  }

  // Update existing outfit event
  static Future<void> updateOutfitEvent(
    DateTime date,
    OutfitEvent event,
  ) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      print('🔥 Updating outfit event in database...');

      // Create document reference
      final docRef = _firestore
          .collection(_outfitPlansCollection)
          .doc(_userId)
          .collection('events')
          .doc('${_formatDateKey(date)}_${event.id}');

      // Convert outfit event to map
      final eventData = _outfitEventToMap(event, date);

      // Update in database
      await docRef.update(eventData);

      print('✅ Outfit event updated successfully in database');
    } catch (e) {
      print('❌ Error updating outfit event: $e');
      throw Exception('Failed to update outfit: $e');
    }
  }

  // Load all outfit events for a user
  static Future<Map<DateTime, List<OutfitEvent>>> loadAllOutfitEvents() async {
    if (_userId == null) {
      print('❌ User not authenticated');
      return {};
    }

    try {
      print('🔥 Loading all outfit events from database...');

      final querySnapshot =
          await _firestore
              .collection(_outfitPlansCollection)
              .doc(_userId)
              .collection('events')
              .orderBy('dateCreated', descending: true)
              .get();

      final Map<DateTime, List<OutfitEvent>> outfitEvents = {};

      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          final event = _mapToOutfitEvent(data);
          final date = DateTime.parse(data['date']);

          // Group by date
          final dateKey = DateTime(date.year, date.month, date.day);
          if (outfitEvents[dateKey] == null) {
            outfitEvents[dateKey] = [];
          }
          outfitEvents[dateKey]!.add(event);
        } catch (e) {
          print('❌ Error parsing outfit event document ${doc.id}: $e');
          continue;
        }
      }

      print(
        '✅ Loaded ${querySnapshot.docs.length} outfit events from database',
      );
      print('✅ Grouped into ${outfitEvents.length} dates');

      return outfitEvents;
    } catch (e) {
      print('❌ Error loading outfit events: $e');
      return {};
    }
  }

  // Load outfit events for a specific date
  static Future<List<OutfitEvent>> loadOutfitEventsForDate(
    DateTime date,
  ) async {
    if (_userId == null) {
      print('❌ User not authenticated');
      return [];
    }

    try {
      print('🔥 Loading outfit events for date: ${date.toIso8601String()}');

      final dateKey = _formatDateKey(date);
      final querySnapshot =
          await _firestore
              .collection(_outfitPlansCollection)
              .doc(_userId)
              .collection('events')
              .where('dateKey', isEqualTo: dateKey)
              .get();

      final List<OutfitEvent> events = [];

      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          final event = _mapToOutfitEvent(data);
          events.add(event);
        } catch (e) {
          print('❌ Error parsing outfit event document ${doc.id}: $e');
          continue;
        }
      }

      print('✅ Loaded ${events.length} outfit events for date');

      return events;
    } catch (e) {
      print('❌ Error loading outfit events for date: $e');
      return [];
    }
  }

  // Delete outfit event
  static Future<void> deleteOutfitEvent(DateTime date, String eventId) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      print('🔥 Deleting outfit event from database...');

      final docRef = _firestore
          .collection(_outfitPlansCollection)
          .doc(_userId)
          .collection('events')
          .doc('${_formatDateKey(date)}_$eventId');

      await docRef.delete();

      print('✅ Outfit event deleted successfully from database');
    } catch (e) {
      print('❌ Error deleting outfit event: $e');
      throw Exception('Failed to delete outfit: $e');
    }
  }

  // Helper method to convert OutfitEvent to Map
  static Map<String, dynamic> _outfitEventToMap(
    OutfitEvent event,
    DateTime date,
  ) {
    return {
      'id': event.id,
      'title': event.title,
      'outfitName': event.outfitName,
      'status': event.status.toString().split('.').last,
      'notes': event.notes,
      'weather': event.weather,
      'wardrobeItems':
          event.wardrobeItems
              ?.map(
                (item) => {
                  'name': item.name,
                  'category': item.category,
                  'imageUrl': item.imageUrl,
                },
              )
              .toList(),
      'date': date.toIso8601String(),
      'dateKey': _formatDateKey(date),
      'dateCreated': FieldValue.serverTimestamp(),
      'dateModified': FieldValue.serverTimestamp(),
    };
  }

  // Helper method to convert Map to OutfitEvent
  static OutfitEvent _mapToOutfitEvent(Map<String, dynamic> data) {
    return OutfitEvent(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      outfitName: data['outfitName'] ?? '',
      status: _parseStatus(data['status']),
      notes: data['notes'],
      weather: data['weather'],
      wardrobeItems: _parseWardrobeItems(data['wardrobeItems']),
    );
  }

static OutfitEventStatus _parseStatus(String? statusString) {
  switch (statusString) {
    case 'planned':
      return OutfitEventStatus.planned;
    case 'emailSent':
      return OutfitEventStatus.emailSent;
    case 'completed':
      return OutfitEventStatus.completed;
    case 'expired': // ✅ Tambahkan ini
      return OutfitEventStatus.expired;
    default:
      return OutfitEventStatus.planned;
  }
}

  // Helper method to parse wardrobe items
  static List<WardrobeItem>? _parseWardrobeItems(dynamic wardrobeItemsData) {
    if (wardrobeItemsData == null) return null;

    try {
      final List<dynamic> itemsList = wardrobeItemsData as List<dynamic>;
      return itemsList.map((item) {
        final itemMap = item as Map<String, dynamic>;
        return WardrobeItem(
          name: itemMap['name'] ?? '',
          category: itemMap['category'] ?? '',
          imageUrl: itemMap['imageUrl'],
        );
      }).toList();
    } catch (e) {
      print('❌ Error parsing wardrobe items: $e');
      return null;
    }
  }

  // Helper method to format date as key
  static String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Get outfit statistics
  static Future<Map<String, int>> getOutfitStatistics() async {
    if (_userId == null) {
      return {'total': 0, 'thisMonth': 0, 'completed': 0};
    }

    try {
      final querySnapshot =
          await _firestore
              .collection(_outfitPlansCollection)
              .doc(_userId)
              .collection('events')
              .get();

      final now = DateTime.now();
      int total = querySnapshot.docs.length;
      int thisMonth = 0;
      int completed = 0;

      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          final date = DateTime.parse(data['date']);

          // Count this month
          if (date.year == now.year && date.month == now.month) {
            thisMonth++;
          }

          // Count completed
          if (data['status'] == 'completed') {
            completed++;
          }
        } catch (e) {
          continue;
        }
      }

      return {'total': total, 'thisMonth': thisMonth, 'completed': completed};
    } catch (e) {
      print('❌ Error getting outfit statistics: $e');
      return {'total': 0, 'thisMonth': 0, 'completed': 0};
    }
  }
}

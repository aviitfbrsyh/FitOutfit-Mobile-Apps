import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class AdminDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize user tracking
  Future<void> initializeUserTracking() async {
    try {
      await _firestore.collection('admin_logs').add({
        'action': 'user_tracking_initialized',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log('Failed to initialize user tracking: $e');
    }
  }

  // Update daily analytics
  Future<void> updateDailyAnalytics() async {
    try {
      await _firestore.collection('analytics').doc('daily').set({
        'last_updated': FieldValue.serverTimestamp(),
        'total_users': await getTotalUsersCount().first,
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log('Failed to update daily analytics: $e');
    }
  }

  // Update user count
  Future<void> updateUserCount() async {
    try {
      final userCount = await getTotalUsersCount().first;
      await _firestore.collection('stats').doc('users').set({
        'total_count': userCount,
        'last_updated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log('Failed to update user count: $e');
    }
  }

  // Get dashboard stats
  Stream<Map<String, dynamic>> getDashboardStats() {
    return _firestore.collection('stats').doc('dashboard').snapshots().map((
      doc,
    ) {
      if (doc.exists) {
        return doc.data() ?? {};
      }
      return {
        'userGrowth': 12.5,
        'outfitGrowth': 8.3,
        'postGrowth': 15.2,
        'newsGrowth': 6.7,
      };
    });
  }

  // Get total users count (real-time)
  Stream<int> getTotalUsersCountRealtime() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get total users count (one-time)
  Stream<int> getTotalUsersCount() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get weekly outfits count
  Future<int> getWeeklyOutfitsCount() async {
    try {
      final DateTime weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final snapshot =
          await _firestore
              .collection('outfits')
              .where('created_at', isGreaterThan: weekAgo)
              .get();
      return snapshot.docs.length;
    } catch (e) {
      developer.log('Failed to get weekly outfits count: $e');
      return 0;
    }
  }

  // Get community posts count
  Stream<int> getCommunityPostsCount() {
    return _firestore
        .collection('community_posts')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get fashion news stats
  Future<Map<String, dynamic>> getFashionNewsStats() async {
    try {
      final DateTime weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final snapshot =
          await _firestore
              .collection('fashion_news')
              .where('created_at', isGreaterThan: weekAgo)
              .get();

      return {
        'weeklyReads': snapshot.docs.length * 15, // Simulate reads
        'totalArticles': snapshot.docs.length,
      };
    } catch (e) {
      developer.log('Failed to get fashion news stats: $e');
      return {'weeklyReads': 0, 'totalArticles': 0};
    }
  }

  // Get trending styles
  Future<List<Map<String, dynamic>>> getTrendingStyles() async {
    try {
      // Check if we have outfit data to base trends on
      await _firestore.collection('outfits').limit(1).get();

      // Simulate trending styles based on data
      return [
        {'style': 'Casual Chic', 'percentage': '28%'},
        {'style': 'Business Professional', 'percentage': '22%'},
        {'style': 'Streetwear', 'percentage': '18%'},
        {'style': 'Formal Evening', 'percentage': '15%'},
        {'style': 'Boho Style', 'percentage': '12%'},
      ];
    } catch (e) {
      developer.log('Failed to get trending styles: $e');
      return [];
    }
  }

  // ✅ UPDATED: Method untuk mengambil distribusi usia dari field 'tanggal_lahir'
  Future<Map<String, int>> getAgeDistribution() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      
      final Map<String, int> ageGroups = {
        '13-17': 0,
        '18-24': 0,
        '25-34': 0,
        '35-44': 0,
        '45+': 0,
      };

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final tanggalLahir = data['tanggal_lahir']; // ✅ Ubah dari 'usia' ke 'tanggal_lahir'
        
        if (tanggalLahir != null) {
          DateTime? birthDate;
          
          // Handle different date formats
          if (tanggalLahir is Timestamp) {
            birthDate = tanggalLahir.toDate();
          } else if (tanggalLahir is String) {
            // Try to parse string date (format: "YYYY-MM-DD" or "DD/MM/YYYY")
            try {
              if (tanggalLahir.contains('/')) {
                final parts = tanggalLahir.split('/');
                if (parts.length == 3) {
                  birthDate = DateTime(
                    int.parse(parts[2]), // year
                    int.parse(parts[1]), // month
                    int.parse(parts[0]), // day
                  );
                }
              } else if (tanggalLahir.contains('-')) {
                birthDate = DateTime.parse(tanggalLahir);
              }
            } catch (e) {
              print('Error parsing date: $tanggalLahir');
            }
          }
          
          if (birthDate != null) {
            final age = _calculateAge(birthDate);
            
            if (age >= 13 && age <= 17) {
              ageGroups['13-17'] = ageGroups['13-17']! + 1;
            } else if (age >= 18 && age <= 24) {
              ageGroups['18-24'] = ageGroups['18-24']! + 1;
            } else if (age >= 25 && age <= 34) {
              ageGroups['25-34'] = ageGroups['25-34']! + 1;
            } else if (age >= 35 && age <= 44) {
              ageGroups['35-44'] = ageGroups['35-44']! + 1;
            } else if (age >= 45) {
              ageGroups['45+'] = ageGroups['45+']! + 1;
            }
          }
        }
      }

      return ageGroups;
    } catch (e) {
      print('Error getting age distribution: $e');
      return {
        '13-17': 0,
        '18-24': 0,
        '25-34': 0,
        '35-44': 0,
        '45+': 0,
      };
    }
  }

  // ✅ ADDED: Helper method untuk menghitung usia dari tanggal lahir
  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // ✅ Method untuk mengambil semua users dengan stream
  Stream<List<Map<String, dynamic>>> getAllUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Tambahkan document ID
        return data;
      }).toList();
    });
  }

  // ✅ Method untuk statistik users
  Future<Map<String, int>> getUserStats() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      int total = snapshot.docs.length;
      int active = 0;
      int inactive = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final isActive = data['isActive'] ?? true;
        if (isActive) {
          active++;
        } else {
          inactive++;
        }
      }

      return {
        'total': total,
        'active': active,
        'inactive': inactive,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {'total': 0, 'active': 0, 'inactive': 0};
    }
  }

  // ✅ Method untuk update status user
  Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }

  // ✅ Method untuk delete user
  Future<void> deleteUser(String userId) async {
    try {
      // Delete user document
      await _firestore.collection('users').doc(userId).delete();
      
      // Delete user's outfits
      final outfitsSnapshot = await _firestore
          .collection('outfits')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (final doc in outfitsSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Delete user's posts from communities
      final communitiesSnapshot = await _firestore.collection('komunitas').get();
      for (final communityDoc in communitiesSnapshot.docs) {
        final postsSnapshot = await communityDoc.reference
            .collection('posts')
            .where('authorId', isEqualTo: userId)
            .get();
        
        for (final postDoc in postsSnapshot.docs) {
          await postDoc.reference.delete();
        }
        
        // Remove user from community members
        final memberDoc = await communityDoc.reference
            .collection('members')
            .doc(userId)
            .get();
        
        if (memberDoc.exists) {
          await memberDoc.reference.delete();
        }
      }
      
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // ✅ NEW: Method untuk mengambil distribusi gender
  // ✅ FIX: Update getGenderDistribution method in admin_data_service.dart
Future<Map<String, int>> getGenderDistribution() async {
  try {
    // Get all users first
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();
    
    final Map<String, int> genderCounts = {
      'Male': 0,
      'Female': 0,
    };
    
    // For each user, fetch their gender from personalisasi
    for (final userDoc in usersSnapshot.docs) {
      try {
        final personalisasiDoc = await FirebaseFirestore.instance
            .collection('personalisasi')
            .doc(userDoc.id)
            .get();
        
        if (personalisasiDoc.exists) {
          final data = personalisasiDoc.data() as Map<String, dynamic>;
          final selectedGender = data['selectedGender']?.toString();
          
          if (selectedGender == 'Male') {
            genderCounts['Male'] = genderCounts['Male']! + 1;
          } else if (selectedGender == 'Female') {
            genderCounts['Female'] = genderCounts['Female']! + 1;
          }
          // ✅ REMOVED: Tidak ada lagi "Not Specified" karena semua user pasti punya gender
        }
      } catch (e) {
        print('Error fetching personalisasi for user ${userDoc.id}: $e');
        // ✅ SKIP: Jika error, skip user ini daripada masuk ke "Not Specified"
      }
    }
    
    return genderCounts;
  } catch (e) {
    print('Error getting gender distribution: $e');
    return {'Male': 0, 'Female': 0};
  }
}
}

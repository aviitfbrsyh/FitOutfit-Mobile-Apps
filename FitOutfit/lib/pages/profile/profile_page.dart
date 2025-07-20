import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../splash_screen_page.dart';
import 'edit_profile_page.dart';
import 'helpnsupport_page.dart';
import 'quiz_history_page.dart';
import 'feedback_form.dart';
import '../outfit_planner/outfit_planner_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color softCream = Color(0xFFFAF9F7);

  String displayName = '';
  String email = '';
  String? bio;
  String? photoUrl;
  String? userUid;

  int wardrobeCount = 0;
  int favoritesCount = 0;
  int postsCount = 0;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    userUid = user?.uid;
    _loadUserData();
    // _loadStats(); DIMUNCULIN NANTI YAA, STATISTIK REAL-TIME
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Hapus data user di Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      // Hapus akun dari Firebase Auth
      await user.delete();

      // Navigasi ke splash screen (atau login)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => SplashScreenPage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please re-login before deleting your account.'),
          ),
        );
        // Optional: Redirect to login page for re-authentication
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: ${e.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete account.')));
    }
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    setState(() {
      displayName = doc.data()?['name'] ?? user.displayName ?? '';
      email = doc.data()?['email'] ?? user.email ?? '';
      bio = doc.data()?['bio'] ?? '';
      photoUrl = doc.data()?['photoUrl'] ?? user.photoURL;
    });
  }
  //DIMUNCULIN NANTI YAA, STATISTIK REAL-TIME
  // Tambahkan method ini untuk mengambil data statistik real-time
  // Future<void> _loadStats() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) return;

  //   // Wardrobe count
  //   final wardrobeSnap =
  //       await FirebaseFirestore.instance
  //           .collection('wardrobe')
  //           .doc(user.uid)
  //           .collection('items')
  //           .get();
  //   wardrobeCount = wardrobeSnap.size;

  //   // Favorites count
  //   final favoritesSnap =
  //       await FirebaseFirestore.instance
  //           .collection('favorites')
  //           .doc(user.uid)
  //           .collection('items')
  //           .get();
  //   favoritesCount = favoritesSnap.size;

  //   // Posts count (dari semua komunitas, filter by authorId)
  //   final postsSnap =
  //       await FirebaseFirestore.instance
  //           .collectionGroup('posts')
  //           .where('authorId', isEqualTo: user.uid)
  //           .get();
  //   postsCount = postsSnap.size;

  //   if (mounted) setState(() {});
  // }

  void _showEventDetails(Map<String, dynamic> plan) {
    // Perbaiki: Cek apakah _EventDetailsModal ada, jika tidak, tampilkan dialog sederhana
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EventDetailsModalFallback(plan: plan),
    );
  }

  String _formatDateFromSessionId(String sessionId) {
    try {
      final timestampStr = sessionId.split('_')[1];
      final timestamp = int.tryParse(timestampStr);
      if (timestamp == null) return 'Unknown date';
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading:
            Navigator.of(context).canPop()
                ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                )
                : null,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            color: darkGray,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryBlue),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () async {
              // Perbaiki: Gunakan onSelected, bukan onTap di PopupMenuItem
              final selected = await showMenu<String>(
                context: context,
                position: const RelativeRect.fromLTRB(100, 80, 0, 0),
                items: [
                  PopupMenuItem(
                    value: 'share',
                    child: Text('Share Profile', style: GoogleFonts.poppins()),
                  ),
                  PopupMenuItem(
                    value: 'help',
                    child: Text('Help Center', style: GoogleFonts.poppins()),
                  ),
                ],
              );
              if (selected == 'share') {
                // Share profile functionality
              } else if (selected == 'help') {
                // Help center functionality
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24.0,
                  horizontal: 24,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          backgroundImage:
                              (photoUrl != null && photoUrl!.isNotEmpty)
                                  ? NetworkImage(photoUrl!)
                                  : const AssetImage('assets/avatar.jpg')
                                      as ImageProvider,
                          // Perbaiki: Tambahkan child jika photoUrl null
                          child:
                              (photoUrl == null || photoUrl!.isEmpty)
                                  ? const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.grey,
                                  )
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName.isNotEmpty
                                  ? displayName.toUpperCase()
                                  : 'No Name',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              email,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Stats Section - DIMUNCULIN NANTI YAA, STATISTIK REAL-TIME
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 24.0),
              //   child: Container(
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(16),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.black.withOpacity(0.05),
              //           blurRadius: 10,
              //           offset: const Offset(0, 2),
              //         ),
              //       ],
              //     ),
              //     padding: const EdgeInsets.all(16),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceAround,
              //       children: [
              //         _StatItem(
              //           label: 'Wardrobe',
              //           value: wardrobeCount.toString(),
              //           icon: Icons.checkroom_rounded,
              //         ),
              //         _StatItem(
              //           label: 'Favorites',
              //           value: favoritesCount.toString(),
              //           icon: Icons.favorite_rounded,
              //         ),
              //         _StatItem(
              //           label: 'Posts',
              //           value: postsCount.toString(),
              //           icon: Icons.post_add_rounded,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 18),

              // Bio Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.07),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: mediumGray,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'About Me',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: darkGray,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bio?.isNotEmpty ?? false
                            ? bio!
                            : 'Tell us about yourself...',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color:
                              bio?.isNotEmpty ?? false ? darkGray : mediumGray,
                          fontStyle:
                              bio?.isNotEmpty ?? false
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Outfit Planner Preview Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Upcoming Event', // Ubah judul
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: darkGray,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const OutfitPlannerPage(),
                                ),
                              );
                            },
                            child: Text(
                              'See All',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        // Tinggi diperbesar agar cukup untuk list
                        height: 180,
                        child: FutureBuilder<QuerySnapshot>(
                          future:
                              FirebaseFirestore.instance
                                  .collection('outfit_plans')
                                  .doc(userUid)
                                  .collection('events')
                                  .where(
                                    'dateKey',
                                    isGreaterThanOrEqualTo: DateTime.now()
                                        .toIso8601String()
                                        .substring(0, 10),
                                  )
                                  .orderBy('dateKey')
                                  .limit(5)
                                  .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Text(
                                  'No upcoming events.',
                                  style: GoogleFonts.poppins(
                                    color: mediumGray,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            }
                            final plans = snapshot.data!.docs;
                            return ListView.separated(
                              scrollDirection: Axis.vertical,
                              itemCount: plans.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, i) {
                                final plan =
                                    plans[i].data() as Map<String, dynamic>;
                                // --- Tambahkan GestureDetector agar bisa tap lihat detail
                                return GestureDetector(
                                  onTap: () => _showEventDetails(plan),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (plan['status'] == 'completed'
                                                  ? _ProfilePageState
                                                      .primaryBlue
                                                  : plan['status'] == 'expired'
                                                  ? _ProfilePageState.mediumGray
                                                  : plan['status'] ==
                                                      'emailSent'
                                                  ? Colors.green
                                                  : _ProfilePageState
                                                      .accentYellow)
                                              .withOpacity(0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child:
                                              plan['imageUrl'] != null &&
                                                      plan['imageUrl']
                                                          .isNotEmpty
                                                  ? Image.network(
                                                    plan['imageUrl'],
                                                    width: 56,
                                                    height: 56,
                                                    fit: BoxFit.cover,
                                                  )
                                                  : Container(
                                                    width: 56,
                                                    height: 56,
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.checkroom_rounded,
                                                      size: 32,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                plan['title'] ?? 'Outfit',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color: darkGray,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (plan['outfitName'] != null &&
                                                  plan['outfitName'].isNotEmpty)
                                                Text(
                                                  plan['outfitName'],
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: primaryBlue,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              if (plan['date'] != null)
                                                Text(
                                                  (() {
                                                    final date =
                                                        plan['date']
                                                                is Timestamp
                                                            ? (plan['date']
                                                                    as Timestamp)
                                                                .toDate()
                                                            : plan['date']
                                                                is DateTime
                                                            ? plan['date']
                                                                as DateTime
                                                            : null;
                                                    if (date != null) {
                                                      return '${date.day}/${date.month}/${date.year}';
                                                    }
                                                    return '';
                                                  })(),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    color: mediumGray,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                (() {
                                                  switch (plan['status']) {
                                                    case 'completed':
                                                      return _ProfilePageState
                                                          .primaryBlue
                                                          .withOpacity(0.13);
                                                    case 'expired':
                                                      return _ProfilePageState
                                                          .mediumGray
                                                          .withOpacity(0.13);
                                                    case 'emailSent':
                                                      return Colors.green
                                                          .withOpacity(0.13);
                                                    default:
                                                      return _ProfilePageState
                                                          .accentYellow
                                                          .withOpacity(0.13);
                                                  }
                                                })(),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                (() {
                                                  switch (plan['status']) {
                                                    case 'completed':
                                                      return Icons
                                                          .check_circle_rounded;
                                                    case 'expired':
                                                      return Icons
                                                          .access_time_rounded;
                                                    case 'emailSent':
                                                      return Icons
                                                          .email_rounded;
                                                    default:
                                                      return Icons
                                                          .schedule_rounded;
                                                  }
                                                })(),
                                                color:
                                                    (() {
                                                      switch (plan['status']) {
                                                        case 'completed':
                                                          return _ProfilePageState
                                                              .primaryBlue;
                                                        case 'expired':
                                                          return _ProfilePageState
                                                              .mediumGray;
                                                        case 'emailSent':
                                                          return Colors.green;
                                                        default:
                                                          return _ProfilePageState
                                                              .accentYellow;
                                                      }
                                                    })(),
                                                size: 14,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                (() {
                                                  switch (plan['status']) {
                                                    case 'completed':
                                                      return 'Completed';
                                                    case 'expired':
                                                      return 'Expired';
                                                    case 'emailSent':
                                                      return 'Reminder Sent';
                                                    default:
                                                      return 'Planned';
                                                  }
                                                })(),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color:
                                                      (() {
                                                        switch (plan['status']) {
                                                          case 'completed':
                                                            return _ProfilePageState
                                                                .primaryBlue;
                                                          case 'expired':
                                                            return _ProfilePageState
                                                                .mediumGray;
                                                          case 'emailSent':
                                                            return Colors.green;
                                                          default:
                                                            return _ProfilePageState
                                                                .accentYellow;
                                                        }
                                                      })(),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              // Widget: Quiz History Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Quiz History',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: darkGray,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Tidak perlu cek userUid, cukup panggil QuizHistoryPage()
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QuizHistoryPage(),
                                ),
                              );
                            },
                            child: Text(
                              'See All',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 180,
                        child:
                            (userUid == null || userUid!.isEmpty)
                                ? Center(
                                  child: Text(
                                    'User not found. Please relogin.',
                                    style: GoogleFonts.poppins(
                                      color: mediumGray,
                                      fontSize: 13,
                                    ),
                                  ),
                                )
                                : FutureBuilder<QuerySnapshot>(
                                  future:
                                      FirebaseFirestore.instance
                                          .collection('budget_quiz_results')
                                          .where('userId', isEqualTo: userUid)
                                          .orderBy(
                                            'timestamp',
                                            descending: true,
                                          )
                                          .limit(3)
                                          .get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    if (!snapshot.hasData ||
                                        snapshot.data!.docs.isEmpty) {
                                      return Center(
                                        child: Text(
                                          'No quiz history yet.',
                                          style: GoogleFonts.poppins(
                                            color: mediumGray,
                                            fontSize: 13,
                                          ),
                                        ),
                                      );
                                    }
                                    final histories = snapshot.data!.docs;
                                    return ListView.separated(
                                      scrollDirection: Axis.vertical,
                                      itemCount: histories.length,
                                      separatorBuilder:
                                          (_, __) => const SizedBox(height: 10),
                                      itemBuilder: (context, i) {
                                        final history =
                                            histories[i].data()
                                                as Map<String, dynamic>;
                                        return Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: primaryBlue.withOpacity(
                                                  0.08,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 56,
                                                height: 56,
                                                decoration: BoxDecoration(
                                                  color: primaryBlue
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Icon(
                                                  Icons.quiz_rounded,
                                                  size: 32,
                                                  color: primaryBlue,
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Budget Quiz - ${history['budget_type'] ?? 'Unknown'}',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 14,
                                                            color: darkGray,
                                                          ),
                                                    ),
                                                    Text(
                                                      history['description'] ??
                                                          'No description',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            color: mediumGray,
                                                          ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Taken on: ' +
                                                          (() {
                                                            final ts =
                                                                history['timestamp'];
                                                            if (ts == null)
                                                              return '-';
                                                            if (ts
                                                                is Timestamp) {
                                                              final dt =
                                                                  ts.toDate();
                                                              return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
                                                            }
                                                            if (ts is String) {
                                                              return ts;
                                                            }
                                                            return '-';
                                                          })(),
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 11,
                                                            color: mediumGray,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
              ),
              // Settings Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.settings,
                          color: _ProfilePageState.primaryBlue,
                        ),
                        title: Text(
                          'Settings',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap:
                            () => showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              builder:
                                  (_) => _SettingsModal(
                                    initialName: displayName,
                                    initialBio: bio ?? '',
                                    initialPhotoUrl: photoUrl,
                                    onProfileUpdated: () async {
                                      await _loadUserData();
                                      if (context.mounted) setState(() {});
                                    },
                                  ),
                            ),
                      ),
                      Divider(height: 1, color: Colors.grey[300]),
                      ListTile(
                        leading: const Icon(
                          Icons.privacy_tip,
                          color: _ProfilePageState.primaryBlue,
                        ),
                        title: Text(
                          'Privacy',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap:
                            () => showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              builder: (_) => _PrivacyModal(),
                            ),
                      ),
                      Divider(height: 1, color: Colors.grey[300]),
                      ListTile(
                        leading: const Icon(
                          Icons.help_outline,
                          color: _ProfilePageState.primaryBlue,
                        ),
                        title: Text(
                          'Help & Support',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HelpNSupportPage(),
                              ),
                            ),
                      ),


                      Divider(height: 1, color: Colors.grey[300]),
                      /* TEMPORARILY HIDDEN - Send Feedback Section
                      ListTile(
                        leading: const Icon(
                          Icons.feedback,
                          color: _ProfilePageState.primaryBlue,
                        ),
                        title: Text(
                          'Send Feedback',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            builder:
                                (_) => Padding(
                                  padding: EdgeInsets.only(
                                    bottom:
                                        MediaQuery.of(
                                          context,
                                        ).viewInsets.bottom,
                                  ),
                                  child: FeedbackForm(
                                    photoUrl: photoUrl,
                                    displayName: displayName,
                                    email: email,
                                  ),
                                ),
                          );
                        },
                      ),
                      Divider(height: 1, color: Colors.grey[300]),
                      */ // END OF TEMPORARILY HIDDEN SECTION
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => SplashScreenPage()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: _ProfilePageState.accentRed,
                      size: 18,
                    ),
                    label: Text(
                      'Logout',
                      style: GoogleFonts.poppins(
                        color: _ProfilePageState.accentRed,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: _ProfilePageState.accentRed,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _ProfilePageState.primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: _ProfilePageState.primaryBlue),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _ProfilePageState.darkGray,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _ProfilePageState.mediumGray,
          ),
        ),
      ],
    );
  }
}

class _SettingsModal extends StatelessWidget {
  final String initialName;
  final String initialBio;
  final String? initialPhotoUrl;
  final VoidCallback onProfileUpdated;

  const _SettingsModal({
    required this.initialName,
    required this.initialBio,
    required this.initialPhotoUrl,
    required this.onProfileUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: _ProfilePageState.primaryBlue,
                size: 26,
              ),
              const SizedBox(width: 14),
              Text(
                'Settings',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: _ProfilePageState.darkGray,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close_rounded,
                  color: _ProfilePageState.mediumGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit, size: 18),
              label: Text(
                'Edit Profile',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => EditProfilePage(
                          initialName: initialName,
                          initialBio: initialBio,
                          initialPhotoUrl: initialPhotoUrl,
                        ),
                  ),
                );
                if (result == true) {
                  onProfileUpdated();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _ProfilePageState.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        title: Text(
                          'Delete Account',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            color: _ProfilePageState.accentRed,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to delete your account? This action cannot be undone.',
                          style: GoogleFonts.poppins(
                            color: _ProfilePageState.darkGray,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                color: _ProfilePageState.mediumGray,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              'Delete',
                              style: GoogleFonts.poppins(
                                color: _ProfilePageState.accentRed,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                );
                if (result == true) {
                  await (_ProfilePageState()._deleteAccount(context));
                }
              },
              icon: const Icon(
                Icons.delete_forever_rounded,
                color: Colors.white,
              ),
              label: Text(
                'Delete Account',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _ProfilePageState.accentRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- PRIVACY MODAL ---
class _PrivacyModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.privacy_tip_rounded,
                color: _ProfilePageState.primaryBlue,
                size: 26,
              ),
              const SizedBox(width: 14),
              Text(
                'Privacy Policy',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: _ProfilePageState.darkGray,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close_rounded,
                  color: _ProfilePageState.mediumGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'We respect your privacy. Data collected is only used to improve your app experience, such as name, email, and fashion preferences. No data is shared with third parties without your permission.',
            style: GoogleFonts.poppins(
              color: _ProfilePageState.darkGray,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Data Collected:',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: _ProfilePageState.darkGray,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '- Name, email, profile photo\n- Fashion preferences & app activity\n- Feedback & bug reports',
            style: GoogleFonts.poppins(
              color: _ProfilePageState.mediumGray,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// Tambahkan fallback modal untuk event details jika _EventDetailsModal tidak ada
class _EventDetailsModalFallback extends StatelessWidget {
  final Map<String, dynamic> plan;
  const _EventDetailsModalFallback({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan['title'] ?? 'Event Details',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          if (plan['outfitName'] != null)
            Text('Outfit: ${plan['outfitName']}', style: GoogleFonts.poppins()),
          if (plan['date'] != null)
            Text(
              (() {
                try {
                  final date = DateTime.parse(plan['date']);
                  return '${date.day}/${date.month}/${date.year}';
                } catch (e) {
                  return plan['date'];
                }
              })(),
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: _ProfilePageState.mediumGray,
              ),
            ),
          if (plan['status'] != null)
            Text('Status: ${plan['status']}', style: GoogleFonts.poppins()),

          const SizedBox(height: 12),

          if (plan['wardrobeItems'] != null &&
              plan['wardrobeItems'] is List &&
              (plan['wardrobeItems'] as List).isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wardrobe Items:',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...List.generate((plan['wardrobeItems'] as List).length, (i) {
                  final item =
                      (plan['wardrobeItems'] as List)[i]
                          as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        if (item['imageUrl'] != null &&
                            item['imageUrl'].toString().isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              item['imageUrl'],
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.checkroom_rounded,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item['name'] ?? '-',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (item['category'] != null)
                          Text(
                            item['category'],
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: _ProfilePageState.mediumGray,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            )
          else
            Text(
              'No wardrobe items.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: _ProfilePageState.mediumGray,
              ),
            ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}

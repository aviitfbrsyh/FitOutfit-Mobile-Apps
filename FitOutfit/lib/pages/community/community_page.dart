import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../wardrobe/wardrobe_page.dart';
import '../virtual_try_on/virtual_try_on_page.dart';
import '../home/home_page.dart';
import 'community_detail_page.dart';
import '../profile/profile_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with TickerProviderStateMixin<CommunityPage> {
  String? _selectedCommunity;
  String _displayName = '';
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _animationController;

  // Remove the hardcoded _communities list and replace with Firestore stream
  final Set<String> _joinedCommunities = {};
  String _searchQuery = '';
  String _selectedCategory = 'All';
  int _selectedBottomNavIndex = 3;

  // Consistent colors
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color softCream = Color(0xFFFAF9F7);

  // Get categories from Firestore communities
  Stream<List<String>> get _categoriesStream {
    return FirebaseFirestore.instance
        .collection('komunitas')
        .snapshots()
        .map((snapshot) {
      final categories = snapshot.docs
          .map((doc) => (doc.data()['category'] as String?) ?? 'Other')
          .toSet()
          .toList();
      categories.sort();
      return ['All', ...categories];
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Helper methods for responsive design
  double _getScreenWidth() => MediaQuery.of(context).size.width;
  bool _isSmallScreen() => _getScreenWidth() < 360;
  bool _isTablet() => _getScreenWidth() > 600;

  double _getResponsiveFontSize(double baseSize) {
    if (_isSmallScreen()) return baseSize * 0.9;
    if (_isTablet()) return baseSize * 1.1;
    return baseSize;
  }

  double _getHorizontalPadding() {
    if (_isSmallScreen()) return 16.0;
    if (_isTablet()) return 32.0;
    return 20.0;
  }

  void _setDisplayName() async {
    HapticFeedback.lightImpact();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Set Display Name',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(18),
                    fontWeight: FontWeight.w700,
                    color: darkGray,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose how you want to appear in the community',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(14),
                    color: mediumGray,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your display name',
                    hintStyle: GoogleFonts.poppins(color: mediumGray),
                    prefixIcon: Icon(Icons.badge_rounded, color: primaryBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: mediumGray.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryBlue, width: 2),
                    ),
                    filled: true,
                    fillColor: lightGray,
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    color: mediumGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _displayName = _displayNameController.text.trim();
                  });
                  Navigator.pop(context);
                  if (_displayName.isNotEmpty && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Display name set to: $_displayName',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: accentYellow,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'Save',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _getHorizontalPadding()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discover Communities',
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(24),
              fontWeight: FontWeight.w800,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find your fashion tribe and connect with like-minded enthusiasts',
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(14),
              color: mediumGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search communities, styles, or interests...',
                hintStyle: GoogleFonts.poppins(
                  color: mediumGray,
                  fontSize: _getResponsiveFontSize(15),
                ),
                prefixIcon: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.search_rounded,
                    color: primaryBlue,
                    size: 24,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
              ),
              style: GoogleFonts.poppins(
                fontSize: _getResponsiveFontSize(16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, userSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('komunitas').snapshots(),
          builder: (context, snapshot) {
            final communityCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
            return _buildStatsRow(communityCount);
          },
        );
      },
    );
  }

Widget _buildStatsRow([int communityCount = 0]) {
  return Container(
    margin: EdgeInsets.symmetric(
      horizontal: _getHorizontalPadding(),
      vertical: 12,
    ),
    padding: EdgeInsets.all(_isSmallScreen() ? 16 : 20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryBlue.withValues(alpha: 0.1),
          accentYellow.withValues(alpha: 0.05),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: primaryBlue.withValues(alpha: 0.1)),
    ),
    child: Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'Communities',
            '$communityCount',
            Icons.groups_rounded,
            primaryBlue,
          ),
        ),
        _buildDivider(),
        Expanded(
          child: _buildStatItem(
            'Inspiration',
            'Today',
            Icons.auto_awesome_rounded,
            accentYellow,
          ),
        ),
        _buildDivider(),
        Expanded(
          child: _buildStatItem(
            'Tips Shared',
            'Daily',
            Icons.lightbulb_rounded,
            accentYellow,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(_isSmallScreen() ? 8 : 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: _isSmallScreen() ? 20 : 22),
        ),
        SizedBox(height: _isSmallScreen() ? 6 : 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(16),
            fontWeight: FontWeight.w800,
            color: darkGray,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(11),
            color: mediumGray,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: _isSmallScreen() ? 50 : 55,
      width: 1,
      margin: EdgeInsets.symmetric(horizontal: _isSmallScreen() ? 12 : 16),
      color: mediumGray.withValues(alpha: 0.2),
    );
  }

  Widget _buildCategoryChips() {
    return StreamBuilder<List<String>>(
      stream: _categoriesStream,
      builder: (context, snapshot) {
        final categories = snapshot.data ?? ['All'];
        
        return Container(
          margin: EdgeInsets.symmetric(horizontal: _getHorizontalPadding()),
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category;
              
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(
                    category,
                    style: GoogleFonts.poppins(
                      fontSize: _getResponsiveFontSize(13),
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : primaryBlue,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  selectedColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? primaryBlue : primaryBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  onSelected: (selected) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCommunityList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('komunitas').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: CircularProgressIndicator(color: primaryBlue),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        // Convert Firestore data to community list
        final communities = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id, // Add document ID for reference
            'name': data['name'] ?? 'Unknown Community',
            'desc': data['desc'] ?? 'No description',
            'color': Color(data['color'] ?? 0xFF4A90E2),
            'icon': IconData(data['icon'] ?? Icons.group.codePoint, fontFamily: 'MaterialIcons'),
            'tags': List<String>.from(data['tags'] ?? []),
            'category': data['category'] ?? 'Other',
            'members': data['members'] ?? 0,
          };
        }).toList();

        // Apply filters
        final filteredCommunities = communities.where((c) {
          // Category filter
          if (_selectedCategory != 'All' && c['category'] != _selectedCategory) {
            return false;
          }
          
          // Search filter
          if (_searchQuery.isEmpty) return true;
          
          final query = _searchQuery.toLowerCase();
          return c['name']!.toLowerCase().contains(query) ||
                 c['desc']!.toLowerCase().contains(query) ||
                 c['category']!.toLowerCase().contains(query) ||
                 (c['tags'] as List<String>).any((tag) => tag.toLowerCase().contains(query));
        }).toList();
        
        // Sort by members count (popular first)
        filteredCommunities.sort((a, b) => (b['members'] as int).compareTo(a['members'] as int));

        if (filteredCommunities.isEmpty) {
          return _buildEmptyState();
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: _getHorizontalPadding()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _selectedCategory == 'All' ? 'All Communities' : '$_selectedCategory Communities',
                    style: GoogleFonts.poppins(
                      fontSize: _getResponsiveFontSize(18),
                      fontWeight: FontWeight.w800,
                      color: darkGray,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${filteredCommunities.length} found',
                      style: GoogleFonts.poppins(
                        fontSize: _getResponsiveFontSize(11),
                        fontWeight: FontWeight.w700,
                        color: primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredCommunities.length,
                itemBuilder: (context, index) => _buildCommunityListItem(filteredCommunities[index]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommunityListItem(Map<String, dynamic> community) {
    final joined = _joinedCommunities.contains(community['id']);
    final isSelected = _selectedCommunity == community['name'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? community['color'].withValues(alpha: 0.15)
                : primaryBlue.withValues(alpha: 0.05),
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isSelected
              ? community['color'].withValues(alpha: 0.3)
              : joined
              ? primaryBlue.withValues(alpha: 0.2)
              : Colors.transparent,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        onTap: () async {
          HapticFeedback.lightImpact();
          final isJoined = await isUserJoined(community['id']);
          if (mounted) {
            if (isJoined) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommunityDetailPage(
                    community: community,
                    displayName: _displayName,
                  ),
                ),
              );
            } else {
              await toggleJoinCommunity(community['id']);
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommunityDetailPage(
                      community: community,
                      displayName: _displayName,
                    ),
                  ),
                );
              }
            }
          }
        },
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                community['color'],
                community['color'].withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            community['icon'],
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                community['name'],
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(16),
                  fontWeight: FontWeight.w700,
                  color: darkGray,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: community['color'].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                community['category'],
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(10),
                  fontWeight: FontWeight.w600,
                  color: community['color'],
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              community['desc'],
              style: GoogleFonts.poppins(
                fontSize: _getResponsiveFontSize(13),
                color: mediumGray,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('komunitas')
                      .doc(community['id'])
                      .collection('members')
                      .snapshots(),
                  builder: (context, snapshot) {
                    final memberCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return Row(
                      children: [
                        Icon(Icons.people_rounded, size: 14, color: mediumGray),
                        const SizedBox(width: 4),
                        Text(
                          '$memberCount members',
                          style: GoogleFonts.poppins(
                            fontSize: _getResponsiveFontSize(11),
                            color: mediumGray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    children: (community['tags'] as List<String>)
                        .take(3)
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: community['color'].withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: community['color'].withValues(alpha: 0.2),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                tag,
                                style: GoogleFonts.poppins(
                                  fontSize: _getResponsiveFontSize(9),
                                  fontWeight: FontWeight.w600,
                                  color: community['color'],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: _buildJoinButton(community, community['id']),
      ),
    );
  }

  Widget _buildJoinButton(Map<String, dynamic> community, String komunitasId) {
    return FutureBuilder<bool>(
      future: isUserJoined(komunitasId),
      builder: (context, snapshot) {
        final isJoined = snapshot.data ?? false;
        return GestureDetector(
          onTap: () => toggleJoinCommunity(komunitasId),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _isSmallScreen() ? 10 : 12,
              vertical: _isSmallScreen() ? 5 : 6,
            ),
            decoration: BoxDecoration(
              color: isJoined ? primaryBlue : community['color'].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isJoined
                    ? primaryBlue.withValues(alpha: 0.3)
                    : community['color'].withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isJoined ? Icons.check_rounded : Icons.add_rounded,
                  color: isJoined ? Colors.white : community['color'],
                  size: _isSmallScreen() ? 14 : 16,
                ),
                const SizedBox(width: 4),
                Text(
                  isJoined ? 'Joined' : 'Join',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(10),
                    fontWeight: FontWeight.w700,
                    color: isJoined ? Colors.white : community['color'],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _getHorizontalPadding()),
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: mediumGray.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(Icons.search_off_rounded, size: 48, color: mediumGray),
          ),
          const SizedBox(height: 24),
          Text(
            'No communities found',
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(18),
              fontWeight: FontWeight.w700,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search terms or browse all available communities.',
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(14),
              color: mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: _selectedBottomNavIndex,
onTap: (index) {
  if (index == _selectedBottomNavIndex) return;
  HapticFeedback.lightImpact();
  setState(() => _selectedBottomNavIndex = index);

  if (index == 0) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );
  } else if (index == 1) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WardrobePage()),
      (route) => false,
    );
  } else if (index == 2) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const VirtualTryOnPage(),
      ),
      (route) => false,
    );
  } else if (index == 4) {
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const ProfilePage(),
  ),
);
  }
},
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: primaryBlue,
          unselectedItemColor: mediumGray,
          selectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: _getResponsiveFontSize(12),
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: _getResponsiveFontSize(12),
          ),
          iconSize: 24,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checkroom_rounded),
              label: 'Wardrobe',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_rounded),
              label: 'Try-On',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_rounded),
              label: 'Community',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> toggleJoinCommunity(String komunitasId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final displayName = _displayName.isNotEmpty
        ? _displayName
        : (user.displayName?.isNotEmpty == true
            ? user.displayName
            : (user.email?.split('@').first ?? 'Anon'));

    final memberRef = FirebaseFirestore.instance
        .collection('komunitas')
        .doc(komunitasId)
        .collection('members')
        .doc(user.uid);

    final memberDoc = await memberRef.get();

    if (memberDoc.exists) {
      await memberRef.delete(); // Leave
      if (mounted) {
        setState(() {
          _joinedCommunities.remove(komunitasId);
        });
      }
    } else {
      await memberRef.set({
        'displayName': displayName,
        'joinedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        setState(() {
          _joinedCommunities.add(komunitasId);
        });
      }
    }
  }

  Future<bool> isUserJoined(String komunitasId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final doc = await FirebaseFirestore.instance
        .collection('komunitas')
        .doc(komunitasId)
        .collection('members')
        .doc(user.uid)
        .get();
    return doc.exists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softCream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryBlue),
        title: Text(
          'Community',
          style: GoogleFonts.poppins(
            color: primaryBlue,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_rounded, color: primaryBlue),
            onPressed: _setDisplayName,
            tooltip: 'Set Display Name',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildSearchSection(),
            const SizedBox(height: 16),
            _buildStatsHeader(),
            const SizedBox(height: 16),
            _buildCategoryChips(),
            const SizedBox(height: 16),
            _buildCommunityList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}

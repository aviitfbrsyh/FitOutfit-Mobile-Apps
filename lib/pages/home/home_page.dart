import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../wardrobe/wardrobe_page.dart';
import '../virtual_try_on/virtual_try_on_page.dart';
import '../favorites/all_favorites_page.dart';
import '../community/community_page.dart';
import '../profile/profile_page.dart';
import '../community/community_selection_popup.dart';
import '../outfit_planner/outfit_planner_page.dart';
import '../style_quiz/style_quiz_page.dart';
import '../news/news_page.dart';
import '../news/news_detail_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:csv/csv.dart';
import '../../services/favorites_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // Consistent FitOutfit brand colors
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color softCream = Color(0xFFFAF9F7);
  static const Color lightGray = Color(0xFFF8F9FA);
  

  late AnimationController _pulseController;
  late AnimationController _staggerController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  int _selectedBottomNavIndex = 0;
  final int _notificationCount = 3;
  String _searchQuery = '';

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // ...existing code...
  // Tambahan untuk AI Outfit Picks
  List<Map<String, dynamic>> _todayOutfitPicks = [];
  List<String?> _todayOutfitImages = [];
  bool _loadingOutfitPicks = false;
  Map<String, dynamic>? _userPersonalization;
  List<Map<String, dynamic>>? _outfitDataset;

  final List<Map<String, dynamic>> _sampleOutfitPicksFemale = [
    {
      'title': 'Casual Chic',
      'destination': 'Casual Outing',
      'weather': 'Mild & Pleasant',
      'imageUrl':
          'assets/images/sample_female_1.png', // ganti sesuai gambar kamu
      'isAsset': true,
    },
    {
      'title': 'Business Ready',
      'destination': 'Job Interview',
      'weather': 'Rainy & Cool',
      'imageUrl': 'assets/images/sample_female_2.png',
      'isAsset': true,
    },
    {
      'title': 'Weekend Vibes',
      'destination': 'Hangout',
      'weather': 'Sunny & Warm',
      'imageUrl': 'assets/images/sample_female_3.png',
      'isAsset': true,
    },
    {
      'title': 'Date Night',
      'destination': 'Wedding Invitation',
      'weather': 'Hot & Humid',
      'imageUrl': 'assets/images/sample_female_4.png',
      'isAsset': true,
    },
    {
      'title': 'Gym Session',
      'destination': 'Travel',
      'weather': 'Sunny & Warm',
      'imageUrl': 'assets/images/sample_female_5.png',
      'isAsset': true,
    },
  ];

  final List<Map<String, dynamic>> _sampleOutfitPicksMale = [
    {
      'title': 'Casual Chic',
      'destination': 'Casual Outing',
      'weather': 'Mild & Pleasant',
      'imageUrl': 'assets/images/sample_male_1.png',
      'isAsset': true,
    },
    {
      'title': 'Business Ready',
      'destination': 'Job Interview',
      'weather': 'Rainy & Cool',
      'imageUrl': 'assets/images/sample_male_2.png',
      'isAsset': true,
    },
    {
      'title': 'Weekend Vibes',
      'destination': 'Hangout',
      'weather': 'Sunny & Warm',
      'imageUrl': 'assets/images/sample_male_3.png',
      'isAsset': true,
    },
    {
      'title': 'Date Night',
      'destination': 'Wedding Invitation',
      'weather': 'Hot & Humid',
      'imageUrl': 'assets/images/sample_male_4.png',
      'isAsset': true,
    },
    {
      'title': 'Gym Session',
      'destination': 'Travel',
      'weather': 'Sunny & Warm',
      'imageUrl': 'assets/images/sample_male_5.png',
      'isAsset': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserPersonalization().then((_) {
      _showSampleOutfitPicks();
    });
    _loadDataset();
  }

  void _showSampleOutfitPicks() {
    // Default female jika belum ada data
    String gender =
        _userPersonalization?['selectedGender']?.toString().toLowerCase() ??
        'female';
    final sample =
        gender == 'male' ? _sampleOutfitPicksMale : _sampleOutfitPicksFemale;
    setState(() {
      _todayOutfitPicks = List<Map<String, dynamic>>.from(sample);
      _todayOutfitImages = sample.map((e) => e['imageUrl'] as String?).toList();
      _loadingOutfitPicks = false;
    });
  }

  Future<void> _loadUserPersonalization() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc =
            await FirebaseFirestore.instance
                .collection('personalisasi')
                .doc(user.uid)
                .get();
        if (doc.exists) {
          setState(() {
            _userPersonalization = doc.data();
          });
        }
      } catch (e) {}
    }
  }

  Future<void> _loadDataset() async {
    if (_outfitDataset != null) return;
    final raw = await rootBundle.loadString('assets/virtual_tryon_dataset.csv');
    final rows = const CsvToListConverter(eol: '\n').convert(raw);
    final headers = rows.first.cast<String>();
    _outfitDataset =
        rows.skip(1).map((row) {
          return Map<String, dynamic>.fromIterables(headers, row);
        }).toList();
  }

  Future<void> _generateTodayOutfitPicks() async {
    setState(() {
      _loadingOutfitPicks = true;
      _todayOutfitPicks = [];
      _todayOutfitImages = [];
    });

    final categories = [
      {
        'title': 'Casual Chic',
        'destination': 'Casual Outing',
        'weather': 'Mild & Pleasant',
      },
      {
        'title': 'Business Ready',
        'destination': 'Job Interview',
        'weather': 'Rainy & Cool',
      },
      {
        'title': 'Weekend Vibes',
        'destination': 'Hangout',
        'weather': 'Sunny & Warm',
      },
      {
        'title': 'Date Night',
        'destination': 'Wedding Invitation',
        'weather': 'Hot & Humid',
      },
      {
        'title': 'Gym Session',
        'destination': 'Travel',
        'weather': 'Sunny & Warm',
      },
    ];

    List<Map<String, dynamic>> picks = [];
    List<String?> images = [];

    for (final cat in categories) {
      final outfit = await _generateOutfitForCategory(
        cat['destination']!,
        cat['weather']!,
      );
      picks.add({...cat, ...?outfit});
      images.add(outfit?['imageUrl']);
    }

    setState(() {
      _todayOutfitPicks = picks;
      _todayOutfitImages = images;
      _loadingOutfitPicks = false;
    });
  }

  Future<Map<String, dynamic>?> _generateOutfitForCategory(
    String destination,
    String weather,
  ) async {
    await _loadDataset();
    final dataset = _outfitDataset!;
    String? userGender =
        _userPersonalization?['selectedGender']?.toString().toLowerCase();

    List<Map<String, dynamic>> filtered =
        dataset.where((outfit) {
          bool matchDestination = outfit['destination'] == destination;
          bool matchWeather = outfit['weather'] == weather;
          bool matchGender =
              userGender == null
                  ? true
                  : (outfit['gender']?.toString().toLowerCase() == userGender);
          return matchDestination && matchWeather && matchGender;
        }).toList();

    if (_userPersonalization != null && filtered.isNotEmpty) {
      List<Map<String, dynamic>> personalized =
          filtered.where((outfit) {
            bool match = true;
            if (_userPersonalization!['selectedBodyShape'] != null) {
              match =
                  match &&
                  outfit['body_shape'].toString().toLowerCase() ==
                      _userPersonalization!['selectedBodyShape']
                          .toString()
                          .toLowerCase();
            }
            if (_userPersonalization!['selectedStyles'] != null) {
              List<String> userStyles = List<String>.from(
                _userPersonalization!['selectedStyles'],
              );
              if (userStyles.isNotEmpty) {
                bool styleMatch = userStyles.any(
                  (userStyle) =>
                      outfit['style'].toString().toLowerCase().contains(
                        userStyle.toLowerCase(),
                      ) ||
                      userStyle.toLowerCase().contains(
                        outfit['style'].toString().toLowerCase(),
                      ),
                );
                match = match && styleMatch;
              }
            }
            return match;
          }).toList();
      if (personalized.isNotEmpty) {
        filtered = personalized;
      }
    }

    if (filtered.isEmpty) return null;

    final selected = filtered[Random().nextInt(filtered.length)];
    final imageUrl = await _generateOutfitImage(selected);

    return {...selected, 'imageUrl': imageUrl};
  }

  Future<String?> _generateOutfitImage(Map<String, dynamic> outfit) async {
    //APINYA TARUH DISINI YA BOSKU
    const apiKey =  'YOUR_OPENAI_API_KEY'; // Ganti dengan API key kamu
    final prompt =
        "Fashion flat lay, ${outfit['style']} ${outfit['gender']} outfit for ${outfit['destination']} in ${outfit['weather']}. "
        "Includes: ${outfit['outfit_top']}, ${outfit['outfit_bottom']}, ${outfit['outfit_shoes']}, ${outfit['outfit_accessories']}. "
        "White background, high quality, realistic, no people.";
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "dall-e-3",
          "prompt": prompt,
          "n": 1,
          "size": "1024x1024",
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl = data['data'][0]['url'];
        return imageUrl;
      }
    } catch (e) {}
    return null;
  }

  @override
  bool get wantKeepAlive => true;

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _staggerController, curve: Curves.easeOut),
    );

    _staggerController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _staggerController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: softCream,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: primaryBlue,
          backgroundColor: Colors.white,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildCustomAppBar(),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      _buildSearchSection(),
                      SizedBox(height: _getResponsiveHeight(20)),
                      _buildDailyOutfitRecommendations(),
                      SizedBox(height: _getResponsiveHeight(24)),
                      _buildQuickAccessFeatures(),
                      SizedBox(height: _getResponsiveHeight(24)),
                      _buildFashionNewsSection(),
                      SizedBox(height: _getResponsiveHeight(24)),
                      _buildMyFavoritesSection(),
                      SizedBox(height: _getResponsiveHeight(24)),
                      _buildCommunityHighlights(),
                      SizedBox(
                        height: _getResponsiveHeight(100),
                      ), // Bottom nav spacing
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildQuickOutfitFAB(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Helper methods for responsive design
  double _getScreenWidth() => MediaQuery.of(context).size.width;
  double _getScreenHeight() => MediaQuery.of(context).size.height;

  bool _isSmallScreen() => _getScreenWidth() < 360;
  bool _isMediumScreen() => _getScreenWidth() >= 360 && _getScreenWidth() < 400;
  bool _isLargeScreen() => _getScreenWidth() >= 400;

  double _getHorizontalPadding() {
    if (_isSmallScreen()) return 16;
    if (_isMediumScreen()) return 20;
    return 24;
  }

  double _getResponsiveHeight(double baseHeight) {
    final screenHeight = _getScreenHeight();
    if (screenHeight < 700) return baseHeight * 0.8;
    if (screenHeight > 900) return baseHeight * 1.1;
    return baseHeight;
  }

  double _getResponsiveFontSize(double baseSize) {
    if (_isSmallScreen()) return baseSize * 0.9;
    if (_isLargeScreen()) return baseSize * 1.05;
    return baseSize;
  }

  Widget _buildCustomAppBar() {
    return SliverAppBar(
      expandedHeight: _getResponsiveHeight(120),
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final top = constraints.biggest.height;
          final safeAreaTop = MediaQuery.of(context).padding.top;
          final minHeight = kToolbarHeight + safeAreaTop;
          final maxHeight = _getResponsiveHeight(120) + safeAreaTop;

          final progress = ((maxHeight - top) / (maxHeight - minHeight)).clamp(
            0.0,
            1.0,
          );

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryBlue.withValues(alpha: 0.95),
                  primaryBlue.withValues(alpha: 0.85),
                  accentYellow.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(_getResponsiveHeight(30)),
                bottomRight: Radius.circular(_getResponsiveHeight(30)),
              ),
            ),
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _getHorizontalPadding(),
                ),
                child: _buildHeaderContent(progress),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderContent(double progress) {
    final expandedOpacity = (1.0 - (progress * 2.0)).clamp(0.0, 1.0);
    final collapsedOpacity = (progress * 2.0 - 0.5).clamp(0.0, 1.0);
    final isCollapsed = progress > 0.5;

    return Stack(
      children: [
        // Expanded header
        if (!isCollapsed || expandedOpacity > 0)
          Positioned.fill(
            child: Opacity(
              opacity: expandedOpacity,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.only(bottom: _getResponsiveHeight(10)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getTimeBasedGreeting(),
                              style: GoogleFonts.poppins(
                                fontSize: _getResponsiveFontSize(16),
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${_userDisplayName}! ✨',
                              style: GoogleFonts.poppins(
                                fontSize: _getResponsiveFontSize(22),
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /* TEMPORARILY HIDDEN - Notification Bell
                        _buildNotificationBell(),
                        SizedBox(width: _isSmallScreen() ? 8 : 10),
                        */ // END OF TEMPORARILY HIDDEN SECTION
                        _buildProfileAvatar(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Collapsed header
        if (isCollapsed || collapsedOpacity > 0)
          Positioned.fill(
            child: Opacity(
              opacity: collapsedOpacity,
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'FitOutfit',
                        style: GoogleFonts.poppins(
                          fontSize: _getResponsiveFontSize(20),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  /* TEMPORARILY HIDDEN - Notification Bell
                  _buildNotificationBell(),
                  const SizedBox(width: 8),
                  */ // END OF TEMPORARILY HIDDEN SECTION
                  _buildProfileAvatar(),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}

  Widget _buildNotificationBell() {
    return GestureDetector(
      onTap: () => _showNotifications(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(_isSmallScreen() ? 7 : 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.notifications_rounded,
              color: Colors.white,
              size: _isSmallScreen() ? 19 : 20,
            ),
          ),
          if (_notificationCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: accentRed,
                  borderRadius: BorderRadius.circular(9),
                ),
                constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                child: Text(
                  '$_notificationCount',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    final avatarSize = _isSmallScreen() ? 36.0 : 40.0;

    return GestureDetector(
      onTap: () => _navigateToProfile(),
      child: Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(avatarSize / 2),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular((avatarSize - 4) / 2),
          child: Image.asset(
            'assets/images/default_avatar.png',
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => Container(
                  color: accentYellow,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: avatarSize * 0.6,
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _getHorizontalPadding(),
        vertical: _getResponsiveHeight(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search outfits, styles, trends...',
            hintStyle: GoogleFonts.poppins(
              color: mediumGray,
              fontSize: _getResponsiveFontSize(14),
            ),
            prefixIcon: Icon(Icons.search_rounded, color: primaryBlue),
            suffixIcon:
                _searchQuery.isNotEmpty
                    ? IconButton(
                      icon: Icon(Icons.clear_rounded, color: mediumGray),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                    : Icon(Icons.tune_rounded, color: primaryBlue),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: _getHorizontalPadding(),
              vertical: _getResponsiveHeight(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyOutfitRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _getHorizontalPadding()),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Outfit Picks',
                      style: GoogleFonts.poppins(
                        fontSize: _getResponsiveFontSize(20),
                        fontWeight: FontWeight.w700,
                        color: darkGray,
                      ),
                    ),
                    Text(
                      'AI-curated just for you',
                      style: GoogleFonts.poppins(
                        fontSize: _getResponsiveFontSize(12),
                        color: mediumGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed:
                    _loadingOutfitPicks ? null : _generateTodayOutfitPicks,
                icon: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  _loadingOutfitPicks ? 'Generating...' : 'Generate Outfit',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: _getResponsiveFontSize(13),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: _getResponsiveHeight(16)),
        SizedBox(
          height: _getResponsiveHeight(280),
          child:
              _loadingOutfitPicks
                  ? Center(child: CircularProgressIndicator(color: primaryBlue))
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: _getHorizontalPadding(),
                    ),
                    itemCount: _todayOutfitPicks.length,
                    itemBuilder:
                        (context, index) => _buildOutfitPickCard(index),
                  ),
        ),
      ],
    );
  }

  Widget _buildOutfitPickCard(int index) {
    final outfit = _todayOutfitPicks[index];
    final imageUrl = _todayOutfitImages[index];
    final cardWidth = _isSmallScreen() ? 180.0 : 200.0;

    return Container(
      width: cardWidth,
      margin: EdgeInsets.only(right: _getHorizontalPadding() * 0.8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background image or placeholder
            imageUrl != null
                ? (outfit['isAsset'] == true
                    ? Image.asset(
                      imageUrl,
                      height: 200,
                      width: cardWidth,
                      fit: BoxFit.cover,
                    )
                    : Image.network(
                      'http://localhost:3000/proxy-image?url=${Uri.encodeComponent(imageUrl)}',
                      height: 200,
                      width: cardWidth,
                      fit: BoxFit.cover,
                    ))
                : Container(
                  color: Colors.white,
                  height: 200,
                  width: cardWidth,
                  child: Center(
                    child: Icon(Icons.image, size: 48, color: mediumGray),
                  ),
                ),
            // Info overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      outfit['title'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: _getResponsiveFontSize(15),
                        fontWeight: FontWeight.w700,
                        color: darkGray,
                      ),
                    ),
                    Text(
                      outfit['destination'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: _getResponsiveFontSize(11),
                        color: mediumGray,
                      ),
                    ),
                    Text(
                      outfit['weather'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: _getResponsiveFontSize(11),
                        color: mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessFeatures() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _getHorizontalPadding()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Access',
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(20),
              fontWeight: FontWeight.w700,
              color: darkGray,
            ),
          ),
          SizedBox(height: _getResponsiveHeight(16)),
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final crossAxisCount =
                  availableWidth > 400
                      ? 2
                      : 2; // Keep 2 columns for consistency
              final childAspectRatio = _isSmallScreen() ? 1.1 : 1.2;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: _getHorizontalPadding() * 0.8,
                mainAxisSpacing: _getResponsiveHeight(16),
                childAspectRatio: childAspectRatio,
                children: [
                  _buildQuickAccessCard(
                    'Virtual Try-On',
                    Icons.camera_alt_rounded,
                    primaryBlue,
                    'See how outfits look on you',
                    () => _navigateToTryOn(),
                  ),
                  _buildQuickAccessCard(
                    'My Wardrobe',
                    Icons.checkroom_rounded,
                    accentYellow,
                    '127 items in your closet',
                    () => _navigateToWardrobe(),
                  ),
                  _buildQuickAccessCard(
                    'Budget Personality',
                    Icons.psychology_rounded,
                    accentRed,
                    'Find out your budget type',
                    () => _navigateToStyleQuiz(),
                  ),
                  _buildQuickAccessCard(
                    'Outfit Planner',
                    Icons.calendar_today_rounded,
                    primaryBlue,
                    'Plan looks for your week',
                    () => _navigateToPlanner(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard(
    String title,
    IconData icon,
    Color color,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.all(_getHorizontalPadding()),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.2),
                        color.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: _isSmallScreen() ? 20 : 24,
                  ),
                ),
                SizedBox(height: _getResponsiveHeight(12)),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(14),
                    fontWeight: FontWeight.w700,
                    color: darkGray,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: _getResponsiveHeight(4)),
                Expanded(
                  child: Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: _getResponsiveFontSize(11),
                      color: mediumGray,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFashionNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _getHorizontalPadding()),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fashion News',
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(20),
                  fontWeight: FontWeight.w700,
                  color: darkGray,
                ),
              ),
              TextButton(
                onPressed: () => _navigateToNews(),
                child: Text(
                  'Read More',
                  style: GoogleFonts.poppins(
                    color: primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: _getResponsiveFontSize(14),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: _getResponsiveHeight(16)),
        SizedBox(
          height: _getResponsiveHeight(160),
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('fashion_news')
                    .orderBy('createdAt', descending: true)
                    .limit(10)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No news yet.',
                    style: GoogleFonts.poppins(color: mediumGray),
                  ),
                );
              }
              final docs = snapshot.data!.docs;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: _getHorizontalPadding(),
                ),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return _buildNewsCardFromFirestore(data, docs[index].id);
                },
              );
            },
          ),
        ),
      ],
    );
  }

Widget _buildNewsCardFromFirestore(Map<String, dynamic> data, String docId) {
  final cardWidth = _isSmallScreen() ? 220.0 : 240.0;
  final user = FirebaseAuth.instance.currentUser;
  final userId = user?.uid ?? '';
  final likedBy = List<String>.from(data['likedBy'] ?? []);

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NewsDetailPage(docId: docId)),
      );
    },
    child: Container(
      width: cardWidth,
      margin: EdgeInsets.only(right: _getHorizontalPadding() * 0.8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((data['imageUrl'] ?? '').isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    data['imageUrl'],
                    height: _getResponsiveHeight(80),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: _getResponsiveHeight(80),
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(_getHorizontalPadding() * 0.6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          data['title'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: _getResponsiveFontSize(13),
                            fontWeight: FontWeight.w600,
                            color: darkGray,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: _getResponsiveHeight(8)),
                      Expanded(
                        child: Text(
                          data['content'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: _getResponsiveFontSize(10),
                            color: mediumGray,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Love button di pojok kanan atas
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () async {
                try {
                  await FavoritesService.toggleFavorite(
                    itemId: docId,
                    title: data['title'] ?? '',
                    category: 'Articles',
                    color: primaryBlue,
                    icon: Icons.article_rounded,
                    subtitle: (data['content'] ?? '').length > 100
                        ? '${(data['content'] ?? '').substring(0, 100)}...'
                        : (data['content'] ?? ''),
                    imageUrl: data['imageUrl'] ?? '',
                    stats: '${likedBy.length} likes',
                    statsIcon: Icons.favorite_rounded,
                    count: likedBy.length,
                    tags: ['fashion', 'news', 'article'],
                    additionalData: {
                      'content': data['content'],
                      'createdAt': data['createdAt'],
                    },
                  );
                  setState(() {});
                } catch (e) {
                  print('Error toggling favorite: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update favorites'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: FutureBuilder<bool>(
                  future: FavoritesService.isInFavorites(docId),
                  builder: (context, snapshot) {
                    final isFavorite = snapshot.data ?? false;
                    return Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFavorite ? accentRed : Colors.grey,
                      size: 22,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildMyFavoritesSection() {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: _getHorizontalPadding()),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSimplifiedFavoritesHeader(),
        SizedBox(height: _getResponsiveHeight(20)),
        _buildFavoritesContentReal(),
      ],
    ),
  );
}

Widget _buildSimplifiedFavoritesHeader() {
  return StreamBuilder<List<Map<String, dynamic>>>(
    stream: FavoritesService.getFavoritesStream().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    }),
    builder: (context, snapshot) {
      final favoritesCount = snapshot.data?.length ?? 0;
      return Container(
        padding: EdgeInsets.all(_getHorizontalPadding()),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, primaryBlue.withValues(alpha: 0.02)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryBlue.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(_isSmallScreen() ? 12 : 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentRed, accentRed.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: accentRed.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: _isSmallScreen() ? 24 : 28,
                  ),
                ),
                SizedBox(width: _getHorizontalPadding() * 0.8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'My Favorites',
                              style: GoogleFonts.poppins(
                                fontSize: _getResponsiveFontSize(18),
                                fontWeight: FontWeight.w800,
                                color: darkGray,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accentYellow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$favoritesCount',
                              style: GoogleFonts.poppins(
                                fontSize: _getResponsiveFontSize(11),
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: _getResponsiveHeight(4)),
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            color: primaryBlue,
                            size: _isSmallScreen() ? 14 : 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              favoritesCount == 0
                                  ? 'Start building your collection'
                                  : 'Your curated style collection',
                              style: GoogleFonts.poppins(
                                fontSize: _getResponsiveFontSize(12),
                                color: mediumGray,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: _getResponsiveHeight(16)),
            GestureDetector(
              onTap: () => _navigateToAllFavorites(),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: _getResponsiveHeight(12)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryBlue, primaryBlue.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.visibility_rounded,
                      color: Colors.white,
                      size: _isSmallScreen() ? 14 : 16,
                    ),
                    SizedBox(width: _getHorizontalPadding() * 0.4),
                    Text(
                      favoritesCount == 0 ? 'Start Adding' : 'See More',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: _getResponsiveFontSize(14),
                      ),
                    ),
                    SizedBox(width: _getHorizontalPadding() * 0.4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: _isSmallScreen() ? 12 : 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildFavoritesContentReal() {
  return StreamBuilder<List<Map<String, dynamic>>>(
    stream: FavoritesService.getFavoritesStream().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
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
        return data;
      }).toList();
    }),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _buildFavoritesLoadingState();
      }
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return _buildFavoritesEmptyState();
      }
      final favorites = snapshot.data!;
      final recentFavorites = favorites.take(6).toList();
      return Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _isSmallScreen() ? 2 : 3,
              crossAxisSpacing: _getHorizontalPadding() * 0.6,
              mainAxisSpacing: _getResponsiveHeight(12),
              childAspectRatio: 0.75,
            ),
            itemCount: recentFavorites.length,
            itemBuilder: (context, index) {
              return _buildFavoriteCard(recentFavorites[index]);
            },
          ),
          if (favorites.length > 6) ...[
            SizedBox(height: _getResponsiveHeight(16)),
            _buildShowMoreFavoritesButton(favorites.length - 6),
          ],
        ],
      );
    },
  );
}

Widget _buildFavoritesLoadingState() {
  return Container(
    height: _getResponsiveHeight(200),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: primaryBlue,
            strokeWidth: 2,
          ),
          SizedBox(height: _getResponsiveHeight(12)),
          Text(
            'Loading your favorites...',
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(14),
              color: mediumGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildFavoritesEmptyState() {
  return Container(
    height: _getResponsiveHeight(200),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(_getHorizontalPadding()),
            decoration: BoxDecoration(
              color: lightGray,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: _getResponsiveHeight(40),
              color: mediumGray,
            ),
          ),
          SizedBox(height: _getResponsiveHeight(12)),
          Text(
            'No favorites yet',
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(16),
              fontWeight: FontWeight.w600,
              color: darkGray,
            ),
          ),
          SizedBox(height: _getResponsiveHeight(4)),
          Text(
            'Start adding items to your favorites collection',
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(12),
              color: mediumGray,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget _buildFavoriteCard(Map<String, dynamic> favorite) {
  return GestureDetector(
    onTap: () => _openFavoriteDetail(
        favorite['category']?.toString().toLowerCase() ?? 'item',
        favorite['id']),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (favorite['color'] as Color).withOpacity(0.1),
                    (favorite['color'] as Color).withOpacity(0.05),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  if ((favorite['imageUrl'] ?? '').toString().isNotEmpty)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Image.network(
                          favorite['imageUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(),
                        ),
                      ),
                    ),
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(_getHorizontalPadding() * 0.4),
                      decoration: BoxDecoration(
                        color: (favorite['color'] as Color).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (favorite['color'] as Color).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        favorite['icon'] is IconData
                            ? favorite['icon']
                            : Icons.favorite_rounded,
                        color: Colors.white,
                        size: _getResponsiveHeight(20),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (favorite['color'] as Color),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (favorite['category'] ?? '').toString().toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: _getResponsiveFontSize(8),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(_getHorizontalPadding() * 0.4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    favorite['title'] ?? 'Untitled',
                    style: GoogleFonts.poppins(
                      fontSize: _getResponsiveFontSize(11),
                      fontWeight: FontWeight.w600,
                      color: darkGray,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: _getResponsiveHeight(2)),
                  Text(
                    favorite['subtitle'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: _getResponsiveFontSize(9),
                      color: mediumGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (favorite['stats'] != null) ...[
                    SizedBox(height: _getResponsiveHeight(4)),
                    Row(
                      children: [
                        Icon(
                          favorite['statsIcon'] is IconData
                              ? favorite['statsIcon']
                              : Icons.favorite_rounded,
                          size: _getResponsiveHeight(12),
                          color: (favorite['color'] as Color),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            favorite['stats'] ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: _getResponsiveFontSize(8),
                              color: mediumGray,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildShowMoreFavoritesButton(int remainingCount) {
  return Container(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () => _navigateToAllFavorites(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: primaryBlue,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: _getResponsiveHeight(12)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryBlue.withOpacity(0.3)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_rounded, size: 16),
          const SizedBox(width: 8),
          Text(
            'Show $remainingCount more favorites',
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(12),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildFavoritesContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final isVeryNarrow = availableWidth < 300;
        final isNarrow = availableWidth < 350;

        return Column(
          children: [
            // Top Section - Featured Outfit & Wardrobe Items
            if (isVeryNarrow) ...[
              // Stack everything vertically on very narrow screens
              _buildFeaturedOutfitCard(),
              SizedBox(height: _getResponsiveHeight(12)),
              _buildWardrobeItemsColumn(),
            ] else if (isNarrow) ...[
              // Stack vertically on narrow screens
              _buildFeaturedOutfitCard(),
              SizedBox(height: _getResponsiveHeight(12)),
              _buildWardrobeItemsRow(),
            ] else ...[
              // Side by side on wider screens
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 3, child: _buildFeaturedOutfitCard()),
                    SizedBox(width: _getHorizontalPadding() * 0.8),
                    Expanded(flex: 2, child: _buildWardrobeItemsColumn()),
                  ],
                ),
              ),
            ],

            SizedBox(height: _getResponsiveHeight(12)),

            // Bottom Section - Articles & Community
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _buildFashionArticleCard()),
                  SizedBox(width: _getHorizontalPadding() * 0.8),
                  Expanded(child: _buildCommunityCard()),
                ],
              ),
            ),

            SizedBox(height: _getResponsiveHeight(12)),

            // Simplified Quick Actions - hanya tombol New Collection
            _buildSimplifiedQuickActionsRow(),
          ],
        );
      },
    );
  }

  Widget _buildFeaturedOutfitCard() {
    return GestureDetector(
      onTap: () => _openFavoriteDetail('outfit', 'autumn-cozy-vibes'),
      child: Container(
        height: _getResponsiveHeight(180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667eea).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background Gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                ),
              ),

              // Decorative Elements
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),

              // Interactive Elements
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: accentRed,
                    size: _isSmallScreen() ? 16 : 18,
                  ),
                ),
              ),

              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accentYellow,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: accentYellow.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up_rounded,
                        color: Colors.white,
                        size: _isSmallScreen() ? 10 : 12,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'TRENDING',
                        style: GoogleFonts.poppins(
                          fontSize: _getResponsiveFontSize(8),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              Positioned(
                left: 16,
                bottom: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Autumn Cozy Vibes',
                      style: GoogleFonts.poppins(
                        fontSize: _getResponsiveFontSize(16),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: _getResponsiveHeight(4)),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Coffee Date',
                            style: GoogleFonts.poppins(
                              fontSize: _getResponsiveFontSize(9),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.favorite_rounded,
                          color: accentRed,
                          size: _isSmallScreen() ? 10 : 12,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '2.3K',
                          style: GoogleFonts.poppins(
                            fontSize: _getResponsiveFontSize(10),
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: _getResponsiveHeight(6)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            color: primaryBlue,
                            size: _isSmallScreen() ? 12 : 14,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Try This Look',
                            style: GoogleFonts.poppins(
                              fontSize: _getResponsiveFontSize(10),
                              fontWeight: FontWeight.w700,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWardrobeItemsColumn() {
    return Column(
      children: [
        _buildWardrobeItem(
          'Vintage Leather',
          'Brown Jacket',
          'Zara • Size M',
          const Color(0xFFa8edea),
          const Color(0xFFfed6e3),
          const Color(0xFF20B2AA),
          Icons.checkroom_rounded,
          () => _openFavoriteDetail('wardrobe', 'vintage-leather-jacket'),
        ),
        SizedBox(height: _getResponsiveHeight(8)),
        _buildWardrobeItem(
          'Silk Midi Dress',
          'Elegant Navy',
          'H&M • \$89.99',
          const Color(0xFFffecd2),
          const Color(0xFFfcb69f),
          const Color(0xFFfcb69f),
          Icons.local_mall_rounded,
          () => _openFavoriteDetail('wardrobe', 'silk-midi-dress'),
        ),
      ],
    );
  }

  Widget _buildWardrobeItemsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildWardrobeItem(
            'Vintage Leather',
            'Brown Jacket',
            'Zara • M',
            const Color(0xFFa8edea),
            const Color(0xFFfed6e3),
            const Color(0xFF20B2AA),
            Icons.checkroom_rounded,
            () => _openFavoriteDetail('wardrobe', 'vintage-leather-jacket'),
          ),
        ),
        SizedBox(width: _getHorizontalPadding() * 0.6),
        Expanded(
          child: _buildWardrobeItem(
            'Silk Midi Dress',
            'Elegant Navy',
            'H&M • \$89.99',
            const Color(0xFFffecd2),
            const Color(0xFFfcb69f),
            const Color(0xFFfcb69f),
            Icons.local_mall_rounded,
            () => _openFavoriteDetail('wardrobe', 'silk-midi-dress'),
          ),
        ),
      ],
    );
  }

  Widget _buildWardrobeItem(
    String title,
    String subtitle,
    String description,
    Color gradientStart,
    Color gradientEnd,
    Color iconColor,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: _getResponsiveHeight(80),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gradientStart, gradientEnd],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientStart.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Favorite Icon
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: accentRed,
                  size: _isSmallScreen() ? 10 : 12,
                ),
              ),
            ),

            // Content
            Positioned(
              left: 12,
              top: 8,
              bottom: 8,
              right: 40,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: _isSmallScreen() ? 14 : 16,
                    ),
                  ),
                  SizedBox(width: _getHorizontalPadding() * 0.4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: _getResponsiveFontSize(11),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2F4F4F),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: _getResponsiveFontSize(10),
                            fontWeight: FontWeight.w600,
                            color: const Color(
                              0xFF2F4F4F,
                            ).withValues(alpha: 0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          description,
                          style: GoogleFonts.poppins(
                            fontSize: _getResponsiveFontSize(8),
                            color: const Color(
                              0xFF2F4F4F,
                            ).withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFashionArticleCard() {
    return GestureDetector(
      onTap: () => _openFavoriteDetail('article', 'spring-trends-2024'),
      child: Container(
        height: _getResponsiveHeight(110),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFfad0c4), Color(0xFFffd1ff)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFfad0c4).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Favorite Icon
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: accentRed,
                  size: _isSmallScreen() ? 10 : 12,
                ),
              ),
            ),

            // Category Badge
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ARTICLE',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(7),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            // Content
            Positioned(
              left: 12,
              bottom: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Spring Fashion Trends 2024',
                    style: GoogleFonts.poppins(
                      fontSize: _getResponsiveFontSize(12),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF8B4513),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: _getResponsiveHeight(3)),
                  Row(
                    children: [
                      Icon(
                        Icons.auto_stories_rounded,
                        color: const Color(0xFFDB7093),
                        size: _isSmallScreen() ? 8 : 10,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          'Fashion Weekly • 5 min read',
                          style: GoogleFonts.poppins(
                            fontSize: _getResponsiveFontSize(9),
                            color: const Color(
                              0xFF8B4513,
                            ).withValues(alpha: 0.8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityCard() {
    return GestureDetector(
      onTap:
          () => _openFavoriteDetail('community', 'minimalist-capsule-wardrobe'),
      child: Container(
        height: _getResponsiveHeight(110),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFa8edea).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Favorite Icon
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: accentRed,
                  size: _isSmallScreen() ? 10 : 12,
                ),
              ),
            ),

            // Category Badge
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: accentYellow,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'COMMUNITY',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(7),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            // Content
            Positioned(
              left: 12,
              bottom: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Minimalist Capsule Wardrobe',
                    style: GoogleFonts.poppins(
                      fontSize: _getResponsiveFontSize(12),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2F4F4F),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: _getResponsiveHeight(3)),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: _isSmallScreen() ? 5 : 6,
                        backgroundColor: primaryBlue,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: _isSmallScreen() ? 6 : 8,
                          // color: Colors.white,
                          // size: _isSmallScreen() ? 6 : 8,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '@sarah_minimal • 1.2K',
                          style: GoogleFonts.poppins(
                            fontSize: _getResponsiveFontSize(9),
                            color: const Color(
                              0xFF2F4F4F,
                            ).withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.favorite_rounded,
                        color: accentRed,
                        size: _isSmallScreen() ? 8 : 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Simplified Quick Actions - hanya tombol New Collection
  Widget _buildSimplifiedQuickActionsRow() {
    return Container(
      padding: EdgeInsets.all(_getHorizontalPadding() * 0.8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primaryBlue.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => _createCollection(),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: _getResponsiveHeight(12)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentYellow, accentYellow.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: accentYellow.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.collections_bookmark_rounded,
                color: Colors.white,
                size: _isSmallScreen() ? 14 : 16,
              ),
              SizedBox(width: _getHorizontalPadding() * 0.4),
              Text(
                'Create New Collection',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: _getResponsiveFontSize(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickOutfitFAB() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: FloatingActionButton.extended(
            onPressed: () => _navigateToQuickOutfit(),
            backgroundColor: accentRed,
            icon: Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: _isSmallScreen() ? 20 : 24,
            ),
            label: Text(
              'Quick Outfit',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: _getResponsiveFontSize(14),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: _selectedBottomNavIndex,
          onTap: (index) {
            setState(() => _selectedBottomNavIndex = index);
            if (index == 0) {
              // Home, stay here
            } else if (index == 1) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const WardrobePage()),
              );
            } else if (index == 2) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const VirtualTryOnPage(),
                ),
              );
            } else if (index == 3) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CommunityPage()),
              );
            } else if (index == 4) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: primaryBlue,
          unselectedItemColor: mediumGray,
          selectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: _getResponsiveFontSize(12),
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: _getResponsiveFontSize(12),
          ),
          iconSize: _isSmallScreen() ? 20 : 24,
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

  Widget _buildCommunityHighlights() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _getHorizontalPadding()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Community',
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(20),
                  fontWeight: FontWeight.w700,
                  color: darkGray,
                ),
              ),
              TextButton(
                onPressed: () => _navigateToJoinCommunity(),
                child: Text(
                  'Join Now',
                  style: GoogleFonts.poppins(
                    color: primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: _getResponsiveFontSize(14),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: _getResponsiveHeight(16)),
          Container(
            padding: EdgeInsets.all(_getHorizontalPadding()),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentYellow.withValues(alpha: 0.1),
                  primaryBlue.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentYellow.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth;
                    final isNarrow = availableWidth < 300;

                    return Column(
                      children: [
                        Row(
                          children: [
                            // Avatar stack
                            SizedBox(
                              width: _isSmallScreen() ? 80 : 100,
                              height: _getResponsiveHeight(40),
                              child: Stack(
                                children: List.generate(4, (index) {
                                  return Positioned(
                                    left:
                                        index *
                                        (_isSmallScreen() ? 16.0 : 20.0),
                                    child: Container(
                                      width: _isSmallScreen() ? 32 : 40,
                                      height: _isSmallScreen() ? 32 : 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          _isSmallScreen() ? 16 : 20,
                                        ),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                        color:
                                            [
                                              primaryBlue,
                                              accentYellow,
                                              accentRed,
                                              darkGray,
                                            ][index],
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: _isSmallScreen() ? 16 : 20,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            SizedBox(width: _getHorizontalPadding()),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '2.5K+ Active Members',
                                    style: GoogleFonts.poppins(
                                      fontSize: _getResponsiveFontSize(14),
                                      fontWeight: FontWeight.w700,
                                      color: darkGray,
                                    ),
                                  ),
                                  Text(
                                    'Share your style & get inspired',
                                    style: GoogleFonts.poppins(
                                      fontSize: _getResponsiveFontSize(11),
                                      color: mediumGray,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: _getResponsiveHeight(16)),
                        if (isNarrow) ...[
                          // Stack buttons vertically on narrow screens
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: GestureDetector(
                                  onTap: _showCommunitySelectionPopup,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: _getResponsiveHeight(12),
                                    ),
                                    decoration: BoxDecoration(
                                      color: primaryBlue,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Share Your Look',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: _getResponsiveFontSize(12),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: _getResponsiveHeight(8)),
                              SizedBox(
                                width: double.infinity,
                                child: GestureDetector(
                                  onTap: () => _navigateToJoinCommunity(),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: _getResponsiveHeight(12),
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: primaryBlue),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Browse Styles',
                                      style: GoogleFonts.poppins(
                                        color: primaryBlue,
                                        fontWeight: FontWeight.w600,
                                        fontSize: _getResponsiveFontSize(12),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Side by side buttons on wider screens
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _showCommunitySelectionPopup,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: _getResponsiveHeight(12),
                                    ),
                                    decoration: BoxDecoration(
                                      color: primaryBlue,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Share Your Look',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: _getResponsiveFontSize(12),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: _getHorizontalPadding() * 0.6),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _navigateToJoinCommunity(),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: _getResponsiveHeight(12),
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: primaryBlue),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Browse Styles',
                                      style: GoogleFonts.poppins(
                                        color: primaryBlue,
                                        fontWeight: FontWeight.w600,
                                        fontSize: _getResponsiveFontSize(12),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToProfile() {
    HapticFeedback.mediumImpact();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ProfilePage()));
  }

  void _navigateToAllFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AllFavoritesPage()),
    );
  }

  void _navigateToTryOn() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const VirtualTryOnPage()));
  }

  void _navigateToWardrobe() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const WardrobePage()));
  }

  void _navigateToStyleQuiz() {
    HapticFeedback.mediumImpact();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const StyleQuizPage()));
  }

  void _navigateToPlanner() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const OutfitPlannerPage()));
  }

  void _navigateToNews() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const NewsPage()));
  }

  void _navigateToJoinCommunity() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CommunityPage()));
  }

  // TAMBAHKAN metode ini:
  void _navigateToQuickOutfit() {
    HapticFeedback.mediumImpact();
    // Navigate to wardrobe for quick outfit selection
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const WardrobePage()));

    // Optional: Show a snackbar to indicate the feature
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Quick Outfit feature - redirecting to Wardrobe!',
          style: GoogleFonts.poppins(fontSize: _getResponsiveFontSize(14)),
        ),
        backgroundColor: accentRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showCommunitySelectionPopup() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => const CommunitySelectionPopup(),
    );
  }

  void _showNotifications() {
    // Show notifications bottom sheet
  }

  Future<void> _handleRefresh() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
  }

  void _openFavoriteDetail(String type, String id) {
    switch (type) {
      case 'wardrobe':
        _navigateToFavoriteWardrobe(id);
        break;
      case 'outfit':
        _navigateToFavoriteOutfit(id);
        break;
      case 'article':
        _navigateToFavoriteArticle(id);
        break;
      case 'tryon':
        _navigateToFavoriteTryOn(id);
        break;
      case 'community':
        _navigateToFavoriteCommunity(id);
        break;
      case 'shopping':
        _navigateToFavoriteShopping(id);
        break;
    }
  }

  void _navigateToFavoriteWardrobe(String id) {
    // Navigate to specific wardrobe item
  }

  void _navigateToFavoriteOutfit(String id) {
    // Navigate to specific outfit recommendation
  }

  void _navigateToFavoriteArticle(String id) {
    // Navigate to specific article
  }

  void _navigateToFavoriteTryOn(String id) {
    // Navigate to specific try-on result
  }

  void _navigateToFavoriteCommunity(String id) {
    // Navigate to specific community post
  }

  void _navigateToFavoriteShopping(String id) {
    // Navigate to specific shopping recommendation
  }

  void _createCollection() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Create New Collection',
              style: GoogleFonts.poppins(
                fontSize: _getResponsiveFontSize(18),
                fontWeight: FontWeight.w700,
                color: darkGray,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Collection name',
                    hintStyle: GoogleFonts.poppins(
                      color: mediumGray,
                      fontSize: _getResponsiveFontSize(14),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: primaryBlue.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryBlue),
                    ),
                  ),
                ),
                SizedBox(height: _getResponsiveHeight(16)),
                TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Description (optional)',
                    hintStyle: GoogleFonts.poppins(
                      color: mediumGray,
                      fontSize: _getResponsiveFontSize(14),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: primaryBlue.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryBlue),
                    ),
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
                    fontSize: _getResponsiveFontSize(14),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Collection created successfully!',
                        style: GoogleFonts.poppins(
                          fontSize: _getResponsiveFontSize(14),
                        ),
                      ),
                      backgroundColor: primaryBlue,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Create',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: _getResponsiveFontSize(14),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  String get _userDisplayName {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? 'User';
  }
}

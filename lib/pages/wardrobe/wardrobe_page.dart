import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; 
import '../../services/gpt_vision_service.dart';
import 'outfit_result_page.dart';
import '../../models/wardrobe_item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart'; // ✅ TAMBAH INI
import '../../services/firebase_storage_service.dart';
import '../../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/favorites_service.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage>
    with TickerProviderStateMixin {
  // Enhanced FitOutfit brand colors with better color harmony
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color secondaryBlue = Color(0xFF6BA3F0);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color softCream = Color(0xFFFAF9F7);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color shadowColor = Color(0x1A000000);

  late TabController _tabController;
  late AnimationController _fabController;
  late AnimationController _headerController;
  late Animation<double> _fabAnimation;
  late Animation<double> _headerAnimation;

  String _selectedCategory = 'All';
  bool _showAIRecommendations = false;
  String _selectedOccasion = '';
  String _selectedWeather = '';
  String _selectedStyle = '';

  final List<String> _categories = [
    'All',
    'Tops',
    'Bottoms',
    'Dresses',
    'Outerwear',
    'Accessories',
    'Shoes',
  ];
  final List<String> _occasions = [
    'Work/Office',
    'Casual Day',
    'Date Night',
    'Party/Event',
    'Formal Meeting',
    'Workout/Gym',
    'Travel/Vacation',
    'Home/Relaxing',
  ];
  final List<String> _weatherOptions = [
    'Sunny & Warm',
    'Rainy & Cool',
    'Cold & Windy',
    'Hot & Humid',
    'Mild & Pleasant',
  ];
  final List<String> _stylePreferences = [
    'Minimalist',
    'Bohemian',
    'Classic',
    'Trendy',
    'Edgy',
    'Romantic',
    'Sporty',
    'Professional',
  ];




  // Add search controller
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

// Make _wardrobeItems final but keep the list mutable
final List<Map<String, dynamic>> _wardrobeItems = [];

@override
void initState() {
  super.initState();
  _tabController = TabController(length: 2, vsync: this);
  _fabController = AnimationController(
    duration: const Duration(milliseconds: 400),
    vsync: this,
  );
  _headerController = AnimationController(
    duration: const Duration(milliseconds: 600),
    vsync: this,
  );
  _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
  );
  _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _headerController, curve: Curves.easeOutQuart),
  );

  _fabController.forward();
  _headerController.forward();

  _tabController.addListener(() {
    setState(() {});
  });

  _searchController.addListener(() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  });

  // ✅ TAMBAH INI
  _loadWardrobeData();
}


// ✅ TAMBAH METHOD INI
Future<void> _loadWardrobeData() async {
  if (FirebaseAuth.instance.currentUser == null) {
    print('❌ User not authenticated');
    setState(() => _isLoading = false);
    return;
  }

  try {
    print('🔥 Loading wardrobe data...');
    final items = await FirestoreService.loadWardrobeItems();
    
    setState(() {
      _wardrobeItems.clear();
      _wardrobeItems.addAll(items);
      _isLoading = false;
    });
    
    print('✅ Loaded ${items.length} items');
  } catch (e) {
    print('❌ Error loading wardrobe: $e');
    setState(() => _isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load wardrobe: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


  @override
  void dispose() {
    _tabController.dispose();
    _fabController.dispose();
    _headerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softCream,
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [_buildEnhancedSliverAppBar()],
        body: Column(
          children: [
            _buildEnhancedTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEnhancedWardrobeTab(),
                  _buildEnhancedAIAssistantTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      // Only show FAB when on My Collection tab (index 0)
      floatingActionButton:
          _tabController.index == 0
              ? _buildEnhancedFloatingActionButton()
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
// FIX: Replace Wrap with Row/Column untuk responsive layout
Widget _buildEnhancedSliverAppBar() {
  return SliverAppBar(
    expandedHeight: 140,
    collapsedHeight: 90,
    pinned: true,
    floating: false,
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
    leading: Container(
      margin: const EdgeInsets.all(8),
      child: Material(
        color: pureWhite.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: darkGray,
              size: 20,
            ),
          ),
        ),
      ),
    ),
    actions: const [],
    title: null,
    flexibleSpace: LayoutBuilder(
      builder: (context, constraints) {
        final top = constraints.biggest.height;
        final isCollapsed = top <= 110;
        final screenWidth = MediaQuery.of(context).size.width;

        return FlexibleSpaceBar(
          title: const SizedBox.shrink(),
          background: AnimatedBuilder(
            animation: _headerAnimation,
            builder: (context, child) => Transform.scale(
              scale: 0.95 + (0.05 * _headerAnimation.value),
              child: Opacity(
                opacity: _headerAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryBlue,
                        primaryBlue.withValues(alpha: 0.95),
                        primaryBlue.withValues(alpha: 0.9),
                        Color(0xFF5BA3F5).withValues(alpha: 0.8),
                        Color(0xFF6BB6FF).withValues(alpha: 0.7),
                        accentYellow.withValues(alpha: 0.4),
                        accentRed.withValues(alpha: 0.2),
                        primaryBlue.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.15, 0.3, 0.45, 0.6, 0.75, 0.9, 1.0],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(isCollapsed ? 35 : 45),
                      bottomRight: Radius.circular(isCollapsed ? 35 : 45),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withValues(
                          alpha: isCollapsed ? 0.15 : 0.25,
                        ),
                        blurRadius: isCollapsed ? 15 : 25,
                        offset: Offset(0, isCollapsed ? 8 : 12),
                      ),
                      BoxShadow(
                        color: shadowColor.withValues(
                          alpha: isCollapsed ? 0.1 : 0.15,
                        ),
                        blurRadius: isCollapsed ? 10 : 18,
                        offset: Offset(0, isCollapsed ? 4 : 6),
                      ),
                      BoxShadow(
                        color: primaryBlue.withValues(alpha: 0.08),
                        blurRadius: isCollapsed ? 20 : 35,
                        offset: Offset(0, isCollapsed ? 12 : 18),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                        screenWidth > 400 ? 32 : 24,
                        25,
                        screenWidth > 400 ? 24 : 16,
                        isCollapsed ? 20 : 32,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isCollapsed ? 0.0 : 1.0,
                            child: LayoutBuilder(
                              builder: (context, boxConstraints) {
                                final availableWidth = boxConstraints.maxWidth;
                                
                                return Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(
                                        screenWidth > 400 
                                          ? (isCollapsed ? 12 : 16)
                                          : (isCollapsed ? 10 : 12),
                                      ),
                                      decoration: BoxDecoration(
                                        color: pureWhite.withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(
                                          screenWidth > 400 
                                            ? (isCollapsed ? 16 : 20)
                                            : (isCollapsed ? 14 : 16),
                                        ),
                                        border: Border.all(
                                          color: pureWhite.withValues(alpha: 0.4),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: pureWhite.withValues(alpha: 0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.checkroom_rounded,
                                        color: pureWhite,
                                        size: screenWidth > 400 
                                          ? (isCollapsed ? 24 : 28)
                                          : (isCollapsed ? 20 : 24),
                                      ),
                                    ),
                                    SizedBox(width: screenWidth > 400 ? 18 : 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'My Wardrobe',
                                              style: GoogleFonts.poppins(
                                                fontSize: screenWidth > 400 
                                                  ? (isCollapsed ? 22 : 30)
                                                  : (isCollapsed ? 18 : 24),
                                                fontWeight: FontWeight.w800,
                                                color: pureWhite,
                                                letterSpacing: -0.8,
                                                height: 1.0,
                                              ),
                                            ),
                                          ),
                                          if (!isCollapsed) ...[
                                            SizedBox(height: screenWidth > 400 ? 8 : 6),
                                            // FIX: Replace Wrap with Row
                                            Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: screenWidth > 400 ? 12 : 8,
                                                    vertical: screenWidth > 400 ? 5 : 3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: pureWhite.withValues(alpha: 0.25),
                                                    borderRadius: BorderRadius.circular(
                                                      screenWidth > 400 ? 12 : 8,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '${_wardrobeItems.length} items',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: screenWidth > 400 ? 13 : 11,
                                                      color: pureWhite,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                if (availableWidth > 200) ...[
                                                  SizedBox(width: 8),
                                                  Icon(
                                                    Icons.fiber_manual_record,
                                                    size: screenWidth > 400 ? 6 : 4,
                                                    color: pureWhite.withValues(alpha: 0.7),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      'Updated real-time',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: screenWidth > 400 ? 14 : 12,
                                                        color: pureWhite.withValues(alpha: 0.9),
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
  Widget _buildEnhancedTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        20,
        24,
        20,
        16,
      ), // Increased top margin for more spacing
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.6), // Reduced shadow opacity
            blurRadius: 8, // Reduced blur radius
            offset: const Offset(0, 2), // Reduced offset
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [primaryBlue, secondaryBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          labelColor: pureWhite,
          unselectedLabelColor: mediumGray,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: -0.2,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: -0.2,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          tabs: [
            Tab(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_rounded, size: 16),
                  const SizedBox(width: 8),
                  Text('My Collection'),
                ],
              ),
            ),
            Tab(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 16),
                  const SizedBox(width: 8),
                  Text('StyleMate AI'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildSearchAndActions() {
  return Container(
    margin: const EdgeInsets.fromLTRB(
      20,
      8,
      20,
      12,
    ),
    child: Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: pureWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search wardrobe...',
                hintStyle: GoogleFonts.poppins(
                  color: mediumGray.withValues(alpha: 0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: mediumGray,
                  size: 18,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: mediumGray,
                          size: 16,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: darkGray,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // CATEGORIES BUTTON - FUNGSIONAL
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryBlue, secondaryBlue],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showCategoriesBottomSheet(),
              child: Icon(
                Icons.category_rounded,
                color: pureWhite,
                size: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // FILTER BUTTON - FUNGSIONAL
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentYellow, accentYellow.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: accentYellow.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showFilterBottomSheet(),
              child: Icon(
                Icons.tune_rounded,
                color: pureWhite,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// CATEGORIES BOTTOM SHEET
void _showCategoriesBottomSheet() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // HANDLE BAR
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: lightGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // HEADER
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryBlue, secondaryBlue],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.category_rounded,
                    color: pureWhite,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Select Category',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: darkGray,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          // CATEGORIES LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                final itemCount = category == 'All'
                    ? _wardrobeItems.length
                    : _wardrobeItems
                        .where((item) => item['category'] == category)
                        .length;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                        Navigator.pop(context);
                        // HAPTIC FEEDBACK
                        HapticFeedback.lightImpact();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryBlue.withValues(alpha: 0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? primaryBlue : lightGray,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? primaryBlue 
                                    : lightGray,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _getCategoryIcon(category),
                                color: isSelected ? pureWhite : mediumGray,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                category,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: isSelected ? primaryBlue : darkGray,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? primaryBlue.withValues(alpha: 0.2)
                                    : lightGray,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$itemCount',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? primaryBlue : mediumGray,
                                ),
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.check_circle_rounded,
                                color: primaryBlue,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

// FILTER BOTTOM SHEET - BERDASARKAN TAGS
void _showFilterBottomSheet() {
  // COLLECT ALL UNIQUE TAGS FROM WARDROBE ITEMS
  Set<String> allTags = {};
  for (var item in _wardrobeItems) {
    if (item['tags'] != null) {
      allTags.addAll((item['tags'] as List<dynamic>).cast<String>());
    }
  }
  
  List<String> sortedTags = allTags.toList()..sort();
  
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setModalState) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: pureWhite,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // HANDLE BAR
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: lightGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // HEADER
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentYellow, accentYellow.withValues(alpha: 0.8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_offer_rounded, // TAG ICON
                      color: pureWhite,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Filter by Tags',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: darkGray,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  // CLEAR ALL BUTTON
                  if (_selectedTags.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedTags.clear();
                        });
                        HapticFeedback.lightImpact();
                      },
                      child: Text(
                        'Clear All',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: accentRed,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // SELECTED TAGS PREVIEW
            if (_selectedTags.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryBlue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryBlue.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.filter_alt_rounded,
                          color: primaryBlue,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Active Filters (${_selectedTags.length})',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: _selectedTags.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: pureWhite,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // AVAILABLE TAGS
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Tags (${sortedTags.length})',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: darkGray,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    if (sortedTags.isEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.local_offer_outlined,
                              color: mediumGray,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No tags available',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: mediumGray,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add items with tags to filter',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: mediumGray.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: sortedTags.map((tag) {
                          final isSelected = _selectedTags.contains(tag);
                          final itemCount = _wardrobeItems.where((item) => 
                            (item['tags'] as List).contains(tag)
                          ).length;
                          
                          return Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                setModalState(() {
                                  if (isSelected) {
                                    _selectedTags.remove(tag);
                                  } else {
                                    _selectedTags.add(tag);
                                  }
                                });
                                HapticFeedback.selectionClick();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? primaryBlue : pureWhite,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? primaryBlue : lightGray,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected ? [
                                    BoxShadow(
                                      color: primaryBlue.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ] : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.local_offer_rounded,
                                      size: 14,
                                      color: isSelected ? pureWhite : mediumGray,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      tag,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? pureWhite : darkGray,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                            ? pureWhite.withValues(alpha: 0.2)
                                            : lightGray,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '$itemCount',
                                        style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected 
                                              ? pureWhite.withValues(alpha: 0.9)
                                              : mediumGray,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            // APPLY BUTTON
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: pureWhite,
                border: Border(
                  top: BorderSide(
                    color: lightGray,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // RESULTS COUNT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getFilteredItemsCount()} items found',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: darkGray,
                          ),
                        ),
                        if (_selectedTags.isNotEmpty)
                          Text(
                            'with selected tags',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: mediumGray,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // APPLY BUTTON
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // APPLY FILTER AKAN UPDATE STATE
                        });
                        Navigator.pop(context);
                        HapticFeedback.mediumImpact();
                        
                        // SHOW SNACKBAR
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _selectedTags.isEmpty 
                                  ? 'All filters cleared!'
                                  : 'Filtered by ${_selectedTags.length} tag${_selectedTags.length > 1 ? 's' : ''}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: primaryBlue,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: pureWhite,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      child: Text(
                        'Apply Filters',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

// ADD THIS TO CLASS VARIABLES
final Set<String> _selectedTags = {};

// ✅ TAMBAH INI
bool _isLoading = true;

// HELPER FUNCTION UNTUK COUNT FILTERED ITEMS
int _getFilteredItemsCount() {
  if (_selectedTags.isEmpty) return _wardrobeItems.length;
  
  return _wardrobeItems.where((item) {
    final itemTags = (item['tags'] as List<dynamic>).cast<String>();
    return _selectedTags.every((selectedTag) => itemTags.contains(selectedTag));
  }).length;
}

Widget _buildEnhancedWardrobeGrid() {
  List<Map<String, dynamic>> filteredItems = _wardrobeItems;

  // Filter by category
  if (_selectedCategory != 'All') {
    filteredItems = filteredItems
        .where((item) => item['category'] == _selectedCategory)
        .toList();
  }

  // Filter by selected tags
  if (_selectedTags.isNotEmpty) {
    filteredItems = filteredItems.where((item) {
      final itemTags = (item['tags'] as List<dynamic>).cast<String>();
      return _selectedTags.every((selectedTag) => itemTags.contains(selectedTag));
    }).toList();
  }

  // Filter by search query
  if (_searchQuery.isNotEmpty) {
    filteredItems = filteredItems.where((item) {
      final name = item['name'].toString().toLowerCase();
      final brand = (item['brand'] ?? '').toString().toLowerCase();
      final category = item['category'].toString().toLowerCase();
      final color = item['color'].toString().toLowerCase();
      final description = item['description'].toString().toLowerCase();
      final tags = (item['tags'] as List).join(' ').toLowerCase();

      return name.contains(_searchQuery) ||
          brand.contains(_searchQuery) ||
          category.contains(_searchQuery) ||
          color.contains(_searchQuery) ||
          description.contains(_searchQuery) ||
          tags.contains(_searchQuery);
    }).toList();
  }

  if (filteredItems.isEmpty) {
    return _buildEnhancedEmptyState();
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) => _buildEnhancedWardrobeItem(filteredItems[index]),
    ),
  );
}



// Replace _buildEnhancedStatsCards method (around line 560-600)

Widget _buildEnhancedStatsCards() {
  // ✅ SAFE FAVORITE COUNT
  final favoriteCount = _wardrobeItems.where((item) => item['favorite'] == true).length;
  
  return Container(
    margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
    child: Row(
      children: [
        Expanded(
          child: _buildCompactStatCard(
            'Items',
            '${_wardrobeItems.length}',
            Icons.inventory_rounded,
            primaryBlue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildCompactStatCard(
            'Favorites',
            '$favoriteCount', // ✅ Use safe count
            Icons.favorite_rounded,
            accentRed,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildCompactStatCard(
            'Categories',
            '${_categories.length - 1}',
            Icons.category_rounded,
            accentYellow,
          ),
        ),
      ],
    ),
  );
}
  Widget _buildCompactStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.12),
                  color.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: darkGray,
                    letterSpacing: -0.3,
                    height: 1.0,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: mediumGray,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCategoryFilter() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Categories',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: darkGray,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            // Changed from Container to SizedBox
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                final itemCount =
                    category == 'All'
                        ? _wardrobeItems.length
                        : _wardrobeItems
                            .where((item) => item['category'] == category)
                            .length;

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => setState(() => _selectedCategory = category),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryBlue : pureWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? primaryBlue : lightGray,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  isSelected
                                      ? primaryBlue.withValues(alpha: 0.2)
                                      : shadowColor.withValues(alpha: 0.4),
                              blurRadius: isSelected ? 6 : 3,
                              offset: Offset(0, isSelected ? 2 : 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCategoryIcon(category),
                              size: 14,
                              color: isSelected ? pureWhite : mediumGray,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              category,
                              style: GoogleFonts.poppins(
                                color: isSelected ? pureWhite : darkGray,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? pureWhite.withValues(alpha: 0.2)
                                        : lightGray,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$itemCount',
                                style: GoogleFonts.poppins(
                                  color:
                                      isSelected
                                          ? pureWhite.withValues(alpha: 0.9)
                                          : mediumGray,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

// Replace _buildEnhancedWardrobeItem method (around line 1040-1140)

Widget _buildEnhancedWardrobeItem(Map<String, dynamic> item) {
  // ✅ SAFE BOOLEAN HANDLING
  final bool isFavorite = item['favorite'] == true; // ✅ Handle null safely
  
  return Container(
    decoration: BoxDecoration(
      color: pureWhite,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: primaryBlue.withValues(alpha: 0.04),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _showItemDetails(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryBlue.withValues(alpha: 0.06),
                      accentYellow.withValues(alpha: 0.04),
                      accentRed.withValues(alpha: 0.03),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Stack(
                  children: [
                    // Main image
                    Center(
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: _buildItemImage(item),
                      ),
                    ),
                    // Favorite button
Positioned(
  top: 12,
  right: 12,
  child: Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _toggleFavorite(item['id'] ?? ''),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: pureWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: FutureBuilder<bool>(
          future: FavoritesService.isInFavorites(item['id'] ?? ''),
          builder: (context, snapshot) {
            final isFavorite = snapshot.data ?? false;
            return Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: 14,
              color: isFavorite ? accentRed : mediumGray,
            );
          },
        ),
      ),
    ),
  ),
),
                    // Color indicator
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getColorFromName(item['color'] ?? 'Gray'),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: pureWhite, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: shadowColor,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          item['color'] ?? 'Gray',
                          style: GoogleFonts.poppins(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: _getTextColorForBackground(
                              _getColorFromName(item['color'] ?? 'Gray'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Details section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? 'Unnamed Item',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: darkGray,
                        letterSpacing: -0.2,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (item['brand'] != null &&
                        item['brand'].toString().isNotEmpty)
                      Text(
                        item['brand'],
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: mediumGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryBlue.withValues(alpha: 0.1),
                                primaryBlue.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['category'] ?? 'Other',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: primaryBlue,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 10,
                              color: mediumGray,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              item['lastWorn'] ?? 'Never',
                              style: GoogleFonts.poppins(
                                fontSize: 8,
                                color: mediumGray,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Replace _buildItemImage method

Widget _buildItemImage(Map<String, dynamic> item) {
  final imageUrl = item['image'];
  
  print('🔍 DEBUG: Building image for item ${item['name']}');
  print('🔍 DEBUG: Image URL: $imageUrl');
  
  // ✅ IMPROVED URL VALIDATION
  if (imageUrl != null && 
      imageUrl.toString().trim().isNotEmpty && 
      imageUrl.toString() != 'null' &&
      imageUrl.toString().startsWith('http')) {
    
    print('✅ DEBUG: Loading image: $imageUrl');
    
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: CachedNetworkImage(  // ✅ Use CachedNetworkImage for both Web and Mobile
        imageUrl: imageUrl.toString().trim(),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => _buildLoadingPlaceholder(null),
        errorWidget: (context, url, error) {
          print('❌ CachedNetworkImage error: $error');
          print('❌ Error URL: $url');
          
          // ✅ Try fallback with different approach
          return _buildImageFallback(imageUrl.toString());
        },
        // ✅ Add HTTP headers for CORS
        httpHeaders: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
        },
        // ✅ Add cache options
        cacheManager: DefaultCacheManager(),
        fadeInDuration: Duration(milliseconds: 300),
        fadeOutDuration: Duration(milliseconds: 100),
      ),
    );
  } else {
    print('⚠️ Invalid image URL for item: ${item['name']}');
    print('⚠️ URL value: $imageUrl');
    return _buildFallbackIcon(item['category']);
  }
}

// ✅ ADD FALLBACK IMAGE WIDGET
Widget _buildImageFallback(String imageUrl) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryBlue.withValues(alpha: 0.1),
          accentYellow.withValues(alpha: 0.05),
          Colors.white,
        ],
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: primaryBlue.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.image_not_supported_rounded,
                size: 32,
                color: primaryBlue,
              ),
              const SizedBox(height: 8),
              Text(
                'Image Load Failed',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'CORS Error on Web',
                style: GoogleFonts.poppins(
                  fontSize: 8,
                  color: mediumGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // ✅ ADD RETRY BUTTON
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Force refresh the widget
              if (mounted) {
                setState(() {});
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: primaryBlue.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// ✅ ADD SUCCESS PLACEHOLDER FOR WEB IMAGES

// ✅ ADD LOADING PLACEHOLDER
Widget _buildLoadingPlaceholder(ImageChunkEvent? loadingProgress) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryBlue.withValues(alpha: 0.05),
          accentYellow.withValues(alpha: 0.03),
          Colors.white,
        ],
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              value: loadingProgress?.expectedTotalBytes != null
                  ? loadingProgress!.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: primaryBlue,
              strokeWidth: 3,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Loading Image...',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (loadingProgress?.expectedTotalBytes != null) ...[
          const SizedBox(height: 4),
          Text(
            '${((loadingProgress!.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!) * 100).toInt()}%',
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: mediumGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    ),
  );
}

// ✅ UPDATE FALLBACK ICON METHOD (keep your existing one but improve it)
Widget _buildFallbackIcon(String category) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          mediumGray.withValues(alpha: 0.1),
          lightGray,
          Colors.white,
        ],
      ),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: pureWhite.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: lightGray,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            _getCategoryIcon(category),
            size: 28,
            color: primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'No Image',
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: mediumGray,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Add photo to this item',
          style: GoogleFonts.poppins(
            fontSize: 8,
            color: mediumGray.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

 Widget _buildEnhancedEmptyState() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryBlue.withValues(alpha: 0.1),
                  accentYellow.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.checkroom_rounded,
              size: 80,
              color: primaryBlue.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'No items in $_selectedCategory',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: darkGray,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Start building your digital wardrobe\nby adding your first $_selectedCategory item',
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: mediumGray,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
        ],
      ),
    ),
  );
}

  Widget _buildEnhancedFloatingActionButton() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accentRed, accentRed.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: accentRed.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showAddItemDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, color: pureWhite, size: 24),
          label: Text(
            'Add Item',
            style: GoogleFonts.poppins(
              color: pureWhite,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced AI Assistant Tab
  Widget _buildEnhancedAIAssistantTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEnhancedAIAssistantHeader(),
          const SizedBox(height: 28),
          _buildEnhancedOccasionSelector(),
          const SizedBox(height: 24),
          _buildEnhancedWeatherSelector(),
          const SizedBox(height: 24),
          _buildEnhancedStyleSelector(),
          const SizedBox(height: 36),
          _buildEnhancedGenerateOutfitButton(),
          if (_showAIRecommendations) ...[
            const SizedBox(height: 36),
            _buildEnhancedAIRecommendations(),
          ],
        ],
      ),
    );
  }

  Widget _buildEnhancedAIAssistantHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentYellow.withValues(alpha: 0.12),
            primaryBlue.withValues(alpha: 0.08),
            accentRed.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: accentYellow.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentYellow.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentYellow, accentYellow.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: accentYellow.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: pureWhite,
                  size: 32,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'StyleMate AI Assistant',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: darkGray,
                        letterSpacing: -0.6,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your Personal Fashion Curator',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: mediumGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: pureWhite.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: pureWhite.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentYellow.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.tips_and_updates_rounded,
                    color: accentYellow,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Tell me your plans, and I\'ll create the perfect outfit from your wardrobe with professional styling tips.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: darkGray,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedOccasionSelector() {
    return _buildEnhancedSelectorSection(
      'Where are you going?',
      Icons.location_on_rounded,
      _occasions,
      _selectedOccasion,
      (occasion) => setState(() => _selectedOccasion = occasion),
      primaryBlue,
      // Add gradient background for this section
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryBlue.withValues(alpha: 0.08),
          secondaryBlue.withValues(alpha: 0.05),
          Colors.white,
        ],
      ),
    );
  }

  Widget _buildEnhancedWeatherSelector() {
    return _buildEnhancedSelectorSection(
      'What\'s the weather like?',
      Icons.wb_sunny_rounded,
      _weatherOptions,
      _selectedWeather,
      (weather) => setState(() => _selectedWeather = weather),
      accentYellow,
      // Add gradient background for this section
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accentYellow.withValues(alpha: 0.12),
          accentYellow.withValues(alpha: 0.06),
          Colors.white,
        ],
      ),
    );
  }

  Widget _buildEnhancedStyleSelector() {
    return _buildEnhancedSelectorSection(
      'What\'s your style vibe today?',
      Icons.palette_rounded,
      _stylePreferences,
      _selectedStyle,
      (style) => setState(() => _selectedStyle = style),
      accentRed,
      // Add gradient background for this section
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accentRed.withValues(alpha: 0.08),
          accentRed.withValues(alpha: 0.04),
          Colors.white,
        ],
      ),
    );
  }

  Widget _buildEnhancedSelectorSection(
    String title,
    IconData icon,
    List<String> options,
    String selected,
    Function(String) onSelect,
    Color accentColor, {
    Gradient? backgroundGradient, // Add optional background gradient parameter
  }) {
    return Container(
      // Add container with gradient background
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: backgroundGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.15),
                      accentColor.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: darkGray,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                options.map((option) {
                  final isSelected = selected == option;
                  return Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => onSelect(option),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          gradient:
                              isSelected
                                  ? LinearGradient(
                                    colors: [
                                      accentColor,
                                      accentColor.withValues(alpha: 0.8),
                                    ],
                                  )
                                  : null,
                          color: isSelected ? null : pureWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : lightGray,
                            width: isSelected ? 0 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  isSelected
                                      ? accentColor.withValues(alpha: 0.3)
                                      : shadowColor,
                              blurRadius: isSelected ? 16 : 8,
                              offset: Offset(0, isSelected ? 6 : 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (title.contains('weather')) ...[
                              Icon(
                                _getWeatherIcon(option),
                                size: 16,
                                color: isSelected ? pureWhite : mediumGray,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              option,
                              style: GoogleFonts.poppins(
                                color: isSelected ? pureWhite : darkGray,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedGenerateOutfitButton() {
    final canGenerate =
        _selectedOccasion.isNotEmpty &&
        _selectedWeather.isNotEmpty &&
        _selectedStyle.isNotEmpty;

    return Container(
      // Add container with gradient background for the button section
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF9B59B6).withValues(alpha: 0.08), // Purple accent
            const Color(0xFF3498DB).withValues(alpha: 0.06), // Blue accent
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF9B59B6).withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9B59B6).withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Add icon and title for this section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF9B59B6).withValues(alpha: 0.15),
                      const Color(0xFF3498DB).withValues(alpha: 0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: const Color(0xFF9B59B6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Generate Your Perfect Look',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: darkGray,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              gradient:
                  canGenerate
                      ? LinearGradient(
                        colors: [accentRed, accentRed.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                      : null,
              color: canGenerate ? null : mediumGray.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              boxShadow:
                  canGenerate
                      ? [
                        // Main shadow for depth
                        BoxShadow(
                          color: accentRed.withValues(alpha: 0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                        // Secondary glow effect
                        BoxShadow(
                          color: accentRed.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                        // Subtle inner highlight
                        BoxShadow(
                          color: accentRed.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                        // Bottom emphasis shadow
                        BoxShadow(
                          color: shadowColor.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ]
                      : [
                        // Disabled state shadow
                        BoxShadow(
                          color: shadowColor.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
            ),
            child: ElevatedButton.icon(
              onPressed: canGenerate ? _generateAIRecommendations : null,
              icon: Icon(Icons.auto_awesome_rounded, size: 24),
              label: Text(
                'Generate Perfect Outfit',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: -0.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: pureWhite,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedAIRecommendations() {
    // Remove this entire method content - it should not show anything automatically
    return const SizedBox.shrink(); // Return empty widget instead
  }

Future<void> _generateAIRecommendations() async {
  if (_wardrobeItems.isEmpty ||
      _selectedOccasion.isEmpty ||
      _selectedWeather.isEmpty ||
      _selectedStyle.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Please complete all selections and add items to wardrobe!'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // ✅ FILTER ITEMS YANG PUNYA GAMBAR VALID
  final itemsWithImages = _wardrobeItems.where((item) => 
    item['image'] != null && 
    item['image'].toString().trim().isNotEmpty && 
    item['image'].toString() != 'null'
  ).toList();

  if (itemsWithImages.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ No items with photos found. Add photos to your wardrobe items first!'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
    return;
  }

  print('🤖 Items with valid images: ${itemsWithImages.length}/${_wardrobeItems.length}');

  // ✅ SHOW LOADING DIALOG
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (c) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryBlue, secondaryBlue],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '🤖 AI Analyzing Your Style',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: darkGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Analyzing ${itemsWithImages.length} items with photos...',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Occasion: $_selectedOccasion\nWeather: $_selectedWeather\nStyle: $_selectedStyle',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: mediumGray,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );

  try {
    // ✅ CONVERT WARDROBE ITEMS TO WARDROBEITEM MODEL
    final wardrobeItems = itemsWithImages
        .map((item) => WardrobeItem.fromMap(item))
        .toList();

    print('🤖 Sending ${wardrobeItems.length} items to AI:');
    for (var item in wardrobeItems) {
      print('   - ${item.name} (${item.category}, ${item.color})');
      print('     Image: ${item.imageUrl?.substring(0, 50)}...');
    }

    // ✅ TEST API KEY FIRST
    print('🔑 Testing OpenAI API key...');
    final isApiKeyValid = await GptVisionService.testApiKey();
    if (!isApiKeyValid) {
      throw Exception('Invalid OpenAI API key. Please check your configuration.');
    }
    print('✅ API key is valid!');

    // ✅ GENERATE AI RECOMMENDATIONS
    final result = await GptVisionService.generateOutfitRecommendation(
      wardrobeItems, // ✅ Pass WardrobeItem objects with imageUrl
      occasion: _selectedOccasion,
      weather: _selectedWeather,
      style: _selectedStyle,
    );

    Navigator.of(context).pop(); // Close loading dialog

    print('✅ AI generation successful!');
    print('🎯 Result: $result');

    // ✅ NAVIGATE TO OUTFIT RESULT PAGE
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OutfitResultPage(
          result: result,
          occasion: _selectedOccasion,
          weather: _selectedWeather,
          style: _selectedStyle,
        ),
      ),
    );
  } catch (e) {
    Navigator.of(context).pop(); // Close loading dialog
    
    print('❌ AI Generation Error: $e');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '❌ AI Generation Failed',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              e.toString().length > 100 
                ? '${e.toString().substring(0, 100)}...'
                : e.toString(),
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ✅ GANTI METHOD INI (ganti yang ada di line 2772-2799)
Future<void> _addNewItem(Map<String, dynamic> newItem) async {
  try {
    print('🔥 Adding new item to Firestore...');
    
    // Save to Firestore and get document ID
    final docId = await FirestoreService.saveWardrobeItem(newItem);
    
    // Add to local list with Firestore ID
    newItem['id'] = docId;
    newItem['lastWorn'] = 'Never';
    newItem['favorite'] = false;
    
    setState(() {
      _wardrobeItems.insert(0, newItem); // Add to beginning
    });
    
    print('✅ Item added successfully with ID: $docId');
  } catch (e) {
    print('❌ Error adding item: $e');
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  void _showAddItemDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddItemBottomSheet(onItemAdded: _addNewItem),
    );
  }

// ...existing code...

Widget _buildEnhancedWardrobeTab() {
  return Column(
    children: [
      _buildSearchAndActions(),
      _buildEnhancedStatsCards(),
      _buildEnhancedCategoryFilter(),
      const SizedBox(height: 16),
      Expanded(
        child: _isLoading 
            ? _buildLoadingState()  // ✅ Use _isLoading here
            : _buildEnhancedWardrobeGrid()
      ),
    ],
  );
}

// ✅ Add this loading state widget
Widget _buildLoadingState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryBlue.withValues(alpha: 0.1),
                accentYellow.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: CircularProgressIndicator(
            color: primaryBlue,
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Loading your wardrobe...',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: darkGray,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please wait while we fetch your items',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: mediumGray,
          ),
        ),
      ],
    ),
  );
}

// ...existing code...

// Ganti method _showItemDetails yang ada dengan ini:

void _showItemDetails(Map<String, dynamic> item) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ItemDetailsBottomSheet(
      item: item,
      onDeleteItem: _deleteItem, // ✅ Pass callback function
    ),
  );
}
  // Helper methods
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'All':
      case 'Tops':
        return Icons.checkroom_rounded;
      case 'Bottoms':
        return Icons.straighten_rounded;
      case 'Dresses':
        return Icons.woman_rounded;
      case 'Outerwear':
        return Icons.checkroom_rounded;
      case 'Accessories':
        return Icons.watch_rounded;
      case 'Shoes':
        return Icons.run_circle_rounded;
      default:
        return Icons.checkroom_rounded;
    }
  }

  IconData _getWeatherIcon(String weather) {
    switch (weather) {
      case 'Sunny & Warm':
        return Icons.wb_sunny_rounded;
      case 'Rainy & Cool':
        return Icons.umbrella_rounded;
      case 'Cold & Windy':
        return Icons.ac_unit_rounded;
      case 'Hot & Humid':
        return Icons.whatshot_rounded;
      case 'Mild & Pleasant':
        return Icons.thermostat_rounded;
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'white':
        return Colors.white;
      case 'black':
        return Colors.black;
      case 'blue':
        return Colors.blue;
      case 'navy':
        return const Color(0xFF001F3F);
      case 'red':
        return Colors.red;
      case 'yellow':
        return Colors.yellow;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'gray':
      case 'grey':
        return Colors.grey;
      case 'beige':
        return const Color(0xFFF5F5DC);
      default:
        return mediumGray;
    }
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
  }

Future<void> _toggleFavorite(String itemId) async {
  try {
    final itemIndex = _wardrobeItems.indexWhere((item) => item['id'] == itemId);
    if (itemIndex == -1) return;

    final item = _wardrobeItems[itemIndex];

    // Toggle favorite using FavoritesService
    final isFavorite = await FavoritesService.toggleFavorite(
      itemId: itemId,
      title: item['name'] ?? 'Unnamed Item',
      category: 'Wardrobe',
      color: primaryBlue,
      icon: Icons.checkroom_rounded,
      subtitle: item['brand'] ?? '',
      imageUrl: item['image'] ?? '',
      stats: item['category'] ?? 'Other',
      statsIcon: Icons.category_rounded,
      count: 1,
      tags: [item['category'] ?? 'Other', item['color'] ?? 'Gray'],
      additionalData: {
        'brand': item['brand'],
        'lastWorn': item['lastWorn'],
        'size': item['size'],
        'material': item['material'],
      },
    );

    // Tambahkan baris ini untuk update field favorite di Firestore
    await FirestoreService.updateWardrobeFavorite(itemId, isFavorite);

    // Update locally for immediate UI response
    setState(() {
      _wardrobeItems[itemIndex]['favorite'] = isFavorite;
    });

    print('✅ Favorite toggled successfully');
  } catch (e) {
    print('❌ Error toggling favorite: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update favorite: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// ✅ PERBAIKI METHOD _deleteItem
Future<void> _deleteItem(String itemId, String itemName) async {
  print('🗑️ Attempting to delete item: $itemId ($itemName)');
  
print('🔍 DEBUG: Current wardrobe items count: ${_wardrobeItems.length}');
print('🔍 DEBUG: Looking for item with ID: $itemId');
print('🔍 DEBUG: All item IDs: ${_wardrobeItems.map((e) => e['id']).toList()}');
  // Show confirmation dialog
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning_rounded, color: accentRed, size: 24),
          const SizedBox(width: 12),
          Text(
            'Delete Item?',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: darkGray,
            ),
          ),
        ],
      ),
      content: Text(
        'Are you sure you want to permanently delete "$itemName" from your wardrobe?',
        style: GoogleFonts.poppins(color: mediumGray),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(
              color: mediumGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: accentRed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Delete',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    try {
      print('🗑️ User confirmed deletion');
      
      // Show loading snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 12),
              Text('Deleting "$itemName"...'),
            ],
          ),
          backgroundColor: primaryBlue,
          duration: Duration(seconds: 2),
        ),
      );

      // Delete from Firestore
      await FirestoreService.deleteWardrobeItem(itemId);
      print('✅ Successfully deleted from Firestore');
      
      // Remove from local list
      setState(() {
        _wardrobeItems.removeWhere((item) => item['id'] == itemId);
      });
      print('✅ Successfully removed from local list');
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('✅ "$itemName" deleted successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Error deleting item: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('❌ Failed to delete: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: accentRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  } else {
    print('🚫 User cancelled deletion');
  }
}

}


// Method _deleteItem dipindah ke dalam class _WardrobePageState

// ✅ Pindahkan class keluar dari _WardrobePageState
class _AddItemBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onItemAdded;

  const _AddItemBottomSheet({required this.onItemAdded});

  @override
  State<_AddItemBottomSheet> createState() => _AddItemBottomSheetState();
  
}


class _AddItemBottomSheetState extends State<_AddItemBottomSheet> {
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFF8F9FA);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Tops';
  String _selectedColor = 'White';
  dynamic _selectedImage;
  final List<String> _selectedTags = [];

  bool _isUploading = false;

  final List<String> _categories = [
    'Tops',
    'Bottoms',
    'Dresses',
    'Outerwear',
    'Accessories',
    'Shoes',
  ];
  final List<String> _colors = [
    'White',
    'Black',
    'Blue',
    'Navy',
    'Red',
    'Yellow',
    'Green',
    'Purple',
    'Pink',
    'Brown',
    'Gray',
    'Beige',
  ];
  final List<String> _availableTags = [
    'professional',
    'casual',
    'formal',
    'trendy',
    'vintage',
    'comfortable',
    'stretchy',
    'breathable',
    'versatile',
    'statement',
    'classic',
    'summer',
    'winter',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 48,
            height: 6,
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              color: mediumGray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryBlue, primaryBlue.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.add_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add New Item',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: darkGray,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Build your digital wardrobe',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: mediumGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: lightGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: mediumGray,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagePicker(),
                    const SizedBox(height: 32),
                    _buildTextField(
                      'Item Name',
                      _nameController,
                      'e.g., Classic White Button-Down Shirt',
                      Icons.label_rounded,
                    ),
                    const SizedBox(height: 20),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 20),
                    _buildColorDropdown(),
                    const SizedBox(height: 20),
                    _buildTextField(
                      'Description',
                      _descriptionController,
                      'e.g., Crisp cotton button-down shirt perfect for professional settings',
                      Icons.description_rounded,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    _buildTagSelector(),
                    const SizedBox(height: 40),
                    _buildSaveButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Photo',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: darkGray,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryBlue.withValues(alpha: 0.1),
                accentYellow.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: mediumGray.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: _selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _buildSelectedImage(),
                )
              : Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: primaryBlue,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Add Photo',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: darkGray,
                          ),
                        ),
                        Text(
                          'Tap to take a photo or choose from gallery',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSelectedImage() {
    if (kIsWeb) {
      return Image.memory(
        _selectedImage as Uint8List,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      return Image.file(
        _selectedImage as File,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: darkGray,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: mediumGray.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, color: primaryBlue, size: 20),
            filled: true,
            fillColor: lightGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: primaryBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: darkGray,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: darkGray,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: lightGray,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.category_rounded,
                color: primaryBlue,
                size: 20,
              ),
              filled: true,
              fillColor: lightGray,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: primaryBlue, width: 2),
              ),
            ),
            items:
                _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(
                          category,
                          style: GoogleFonts.poppins(color: darkGray),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (value) => setState(() => _selectedCategory = value!),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a category';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: darkGray,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: lightGray,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedColor,
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _getColorValue(_selectedColor),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
              ),
              filled: true,
              fillColor: lightGray,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: primaryBlue, width: 2),
              ),
            ),
            items:
                _colors
                    .map(
                      (color) => DropdownMenuItem(
                        value: color,
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: _getColorValue(color),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              color,
                              style: GoogleFonts.poppins(color: darkGray),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (value) => setState(() => _selectedColor = value!),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a color';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTagSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags (Optional)',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: darkGray,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select tags that describe this item',
          style: GoogleFonts.poppins(fontSize: 12, color: mediumGray),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedTags.remove(tag);
                      } else {
                        _selectedTags.add(tag);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isSelected
                                ? primaryBlue
                                : mediumGray.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isSelected ? Colors.white : darkGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, primaryBlue.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isUploading ? null : _saveItem,
        icon: _isUploading 
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(Icons.save_rounded, color: Colors.white, size: 20),
        label: Text(
          _isUploading ? 'Uploading...' : 'Save Item',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Color _getColorValue(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'white':
        return Colors.white;
      case 'black':
        return Colors.black;
      case 'blue':
        return Colors.blue;
      case 'navy':
        return const Color(0xFF001F3F);
      case 'red':
        return Colors.red;
      case 'yellow':
        return Colors.yellow;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'gray':
        return Colors.grey;
      case 'beige':
        return const Color(0xFFF5F5DC);
      default:
        return mediumGray;
    }
  }

  void _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt_rounded, color: primaryBlue),
              title: Text('Take Photo', style: GoogleFonts.poppins()),
              onTap: () async {
                Navigator.pop(context);
                await _pickImageFromSource(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library_rounded,
                color: primaryBlue,
              ),
              title: Text(
                'Choose from Gallery',
                style: GoogleFonts.poppins(),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _pickImageFromSource(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    
    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = bytes;
        });
      } else {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    }
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please add a photo!')),
        );
        return;
      }
      
      setState(() => _isUploading = true);

      try {
        Uint8List bytes;
        if (kIsWeb) {
          bytes = _selectedImage as Uint8List;
        } else {
          bytes = await (_selectedImage as File).readAsBytes();
        }
        
        print('🔥 DEBUG: Starting Firebase upload');
        print('🔥 DEBUG: Platform: ${kIsWeb ? 'WEB' : 'MOBILE'}');
        print('🔥 DEBUG: Image size: ${bytes.length} bytes');

        final fileName = FirebaseStorageService.generateFileName('wardrobe_item');
        print('🔥 DEBUG: Generated filename: $fileName');
        
        final imageUrl = await FirebaseStorageService.uploadImage(
          imageBytes: bytes,
          fileName: fileName,
          folder: 'wardrobe_items',
        );

        print('🔥 DEBUG: Firebase upload successful!');
        print('🔥 DEBUG: Image URL: $imageUrl');

        setState(() => _isUploading = false);

        final newItem = {
          'name': _nameController.text.trim(),
          'category': _selectedCategory,
          'color': _selectedColor,
          'brand': '',
          'description': _descriptionController.text.trim(),
          'image': imageUrl,
          'tags': List<String>.from(_selectedTags),
        };

        print('🔥 DEBUG: New item created: $newItem');

        widget.onItemAdded(newItem);
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
           content: Text('🎉 Yay! Successfully added to your wardrobe collection.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('❌ Firebase upload error: $e');
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Firebase upload failed: $e')),
        );
      }
    }
  }
}

// Ganti class _ItemDetailsBottomSheet yang ada dengan ini:

class _ItemDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> item;
  final Function(String, String) onDeleteItem; // ✅ Tambah callback untuk delete

  const _ItemDetailsBottomSheet({
    required this.item,
    required this.onDeleteItem, // ✅ Require callback
  });

  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    // ✅ SAFE BOOLEAN HANDLING
    final bool isFavorite = item['favorite'] == true;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 48,
            height: 6,
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              color: mediumGray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with name and favorite
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['name'] ?? 'Unnamed Item',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: darkGray,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: lightGray,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavorite 
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite ? accentRed : mediumGray,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  
                  // Brand if available
                  if (item['brand'] != null && item['brand'].toString().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item['brand'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: mediumGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Image section
                  Container(
                    width: double.infinity,
                    height: 240,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryBlue.withValues(alpha: 0.08),
                          accentYellow.withValues(alpha: 0.06),
                          Colors.white,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: primaryBlue.withValues(alpha: 0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: (item['image'] != null && 
                              item['image'].toString().trim().isNotEmpty &&
                              item['image'].toString() != 'null' &&
                              item['image'].toString().startsWith('http'))
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl: item['image'],
                                width: 180,
                                height: 180,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: primaryBlue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 32,
                                        height: 32,
                                        child: CircularProgressIndicator(
                                          color: primaryBlue,
                                          strokeWidth: 3,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Loading image...',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: primaryBlue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: primaryBlue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: primaryBlue.withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported_rounded,
                                        size: 48,
                                        color: primaryBlue.withValues(alpha: 0.6),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Image Load Failed',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: primaryBlue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'CORS Error on Web',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: mediumGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                httpHeaders: {
                                  'Access-Control-Allow-Origin': '*',
                                  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
                                  'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
                                },
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: primaryBlue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: primaryBlue.withValues(alpha: 0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.checkroom_rounded,
                                      size: 64,
                                      color: primaryBlue.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No Image Available',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: mediumGray,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Add a photo to this item',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: mediumGray.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Details section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: lightGray.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: primaryBlue.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Category', item['category']),
                        _buildDetailRow('Color', item['color']),
                        if (item['brand'] != null && item['brand'].toString().isNotEmpty)
                          _buildDetailRow('Brand', item['brand']),
                        _buildDetailRow('Last Worn', item['lastWorn'] ?? 'Never'),
                        _buildDetailRow('Status', isFavorite ? 'Favorite ❤️' : 'Regular'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Description section
                  Text(
                    'Description',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: darkGray,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: lightGray,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      item['description']?.toString().isNotEmpty == true
                          ? item['description']
                          : 'No description available for this item.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: mediumGray,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Tags section
                  if (item['tags'] != null && (item['tags'] as List).isNotEmpty) ...[
                    Text(
                      'Tags',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: darkGray,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (item['tags'] as List)
                          .map<Widget>(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryBlue.withValues(alpha: 0.1),
                                    primaryBlue.withValues(alpha: 0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: primaryBlue.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryBlue.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.local_offer_rounded,
                                    size: 12,
                                    color: primaryBlue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    tag.toString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: primaryBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // ✅ ACTION BUTTONS SECTION
                  const SizedBox(height: 16),
                  Text(
                    'Actions',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: darkGray,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // ✅ Delete button - GUNAKAN CALLBACK
                  Container(
                    width: double.infinity,
                    height: 56,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentRed, accentRed.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: accentRed.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Close detail popup first
                        Navigator.pop(context);
                        
                        // ✅ GUNAKAN CALLBACK UNTUK DELETE
                        onDeleteItem(
                          item['id']?.toString() ?? '', 
                          item['name']?.toString() ?? 'Unknown Item'
                        );
                      },
                      icon: Icon(
                        Icons.delete_forever_rounded, 
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        'Delete Item Permanently',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: -0.2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  
                  // Additional spacing at bottom
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ HELPER METHOD UNTUK DETAIL ROW
  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: mediumGray,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value?.toString() ?? 'Not specified',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: darkGray,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

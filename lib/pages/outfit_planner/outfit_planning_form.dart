import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'outfit_planner_page.dart';
import '../wardrobe/wardrobe_page.dart';
import '../../services/firestore_service.dart';
import '../../services/outfit_planner_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OutfitPlanningForm extends StatefulWidget {
  final DateTime selectedDate;
  final OutfitEvent? editingEvent;

  const OutfitPlanningForm({
    super.key,
    required this.selectedDate,
    this.editingEvent,
  });

  @override
  State<OutfitPlanningForm> createState() => _OutfitPlanningFormState();
}

class _OutfitPlanningFormState extends State<OutfitPlanningForm> {
  // FitOutfit brand colors
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color softCream = Color(0xFFFAF9F7);

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _outfitNameController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedOccasion = '';
  String _selectedWeather = '';
  List<WardrobeItem> _selectedWardrobeItems = [];

  // REAL WARDROBE DATA
  List<Map<String, dynamic>> _wardrobeItems = [];
  bool _isLoadingWardrobe = true;
  bool _isSaving = false; // ✅ Added loading state for save button

  final List<String> _occasions = [
    'Work Meeting',
    'Date Night',
    'Casual Outing',
    'Party',
    'Wedding',
    'Exercise',
    'Travel',
    'Other',
  ];

  final List<String> _weatherOptions = [
    'Sunny',
    'Rainy',
    'Cloudy',
    'Cold',
    'Hot',
    'Windy',
  ];

  @override
  void initState() {
    super.initState();
    _loadWardrobeData(); // ✅ Only load real wardrobe data

    if (widget.editingEvent != null) {
      _titleController.text = widget.editingEvent!.title;
      _outfitNameController.text = widget.editingEvent!.outfitName;
      _notesController.text = widget.editingEvent!.notes ?? '';
      _selectedWeather = widget.editingEvent!.weather ?? '';
      _selectedWardrobeItems = List.from(
        widget.editingEvent!.wardrobeItems ?? [],
      );
    }
    // ✅ REMOVED: Any sample data initialization
  }

  @override
  void dispose() {
    _titleController.dispose();
    _outfitNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // LOAD REAL WARDROBE DATA
  Future<void> _loadWardrobeData() async {
    if (FirebaseAuth.instance.currentUser == null) {
      print('❌ User not authenticated');
      setState(() => _isLoadingWardrobe = false);
      return;
    }

    try {
      print('🔥 Loading wardrobe data for outfit planning...');
      final items = await FirestoreService.loadWardrobeItems();

      setState(() {
        _wardrobeItems = items;
        _isLoadingWardrobe = false;
      });

      print('✅ Loaded ${items.length} wardrobe items for selection');
    } catch (e) {
      print('❌ Error loading wardrobe: $e');
      setState(() => _isLoadingWardrobe = false);

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softCream,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: Text(
          widget.editingEvent != null ? 'Edit Outfit Plan' : 'Plan New Outfit',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.checkroom_rounded, color: Colors.white),
            onPressed: () => _navigateToWardrobe(),
            tooltip: 'Go to Wardrobe',
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryBlue.withValues(alpha: 0.1),
                        accentYellow.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryBlue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, color: primaryBlue),
                      const SizedBox(width: 12),
                      Text(
                        'Planning for ${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Event Title
                _buildTextField(
                  controller: _titleController,
                  label: 'Event Title',
                  hint: 'e.g., Work Meeting, Date Night',
                  icon: Icons.event_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an event title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Outfit Name
                _buildTextField(
                  controller: _outfitNameController,
                  label: 'Outfit Name',
                  hint: 'e.g., Professional Chic, Casual Cool',
                  icon: Icons.checkroom_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an outfit name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Occasion Selection
                _buildSectionTitle('Occasion'),
                const SizedBox(height: 8),
                _buildChipSelection(
                  items: _occasions,
                  selectedItem: _selectedOccasion,
                  onSelected:
                      (value) => setState(() => _selectedOccasion = value),
                  color: primaryBlue,
                ),
                const SizedBox(height: 16),

                // Weather Selection
                _buildSectionTitle('Weather'),
                const SizedBox(height: 8),
                _buildChipSelection(
                  items: _weatherOptions,
                  selectedItem: _selectedWeather,
                  onSelected:
                      (value) => setState(() => _selectedWeather = value),
                  color: accentYellow,
                ),
                const SizedBox(height: 16),

                // REAL WARDROBE ITEMS SELECTION WITH PHOTOS
                _buildSectionTitle('Select from My Wardrobe'),
                const SizedBox(height: 8),
                _buildRealWardrobeItemsSelectionWithPhotos(),
                const SizedBox(height: 16),

                // Notes
                _buildTextField(
                  controller: _notesController,
                  label: 'Notes (Optional)',
                  hint: 'Additional notes about this outfit...',
                  icon: Icons.note_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // ✅ Enhanced Save Button with loading state and better error handling
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isSaving ? null : _saveOutfit, // ✅ Disable when saving
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSaving ? mediumGray : primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isSaving
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Saving...',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                            : Text(
                              widget.editingEvent != null
                                  ? 'Update Outfit'
                                  : 'Save Outfit Plan',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: mediumGray.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: darkGray,
      ),
    );
  }

  Widget _buildChipSelection({
    required List<String> items,
    required String selectedItem,
    required Function(String) onSelected,
    required Color color,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          items.map((item) {
            final isSelected = selectedItem == item;
            return GestureDetector(
              onTap: () => onSelected(item),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? color : color.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  item,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  // NEW: WARDROBE ITEMS SELECTION WITH PHOTOS
  Widget _buildRealWardrobeItemsSelectionWithPhotos() {
    if (_isLoadingWardrobe) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryBlue.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            CircularProgressIndicator(color: primaryBlue),
            const SizedBox(height: 16),
            Text(
              'Loading your wardrobe...',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: darkGray,
              ),
            ),
          ],
        ),
      );
    }

    if (_wardrobeItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryBlue.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(Icons.checkroom_rounded, color: mediumGray, size: 48),
            const SizedBox(height: 16),
            Text(
              'No items in wardrobe',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: darkGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add items to your wardrobe first before planning outfits',
              style: GoogleFonts.poppins(fontSize: 12, color: mediumGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _navigateToWardrobe(),
              icon: Icon(Icons.add_rounded, size: 16),
              label: Text(
                'Go to Wardrobe',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Group items by category
    Map<String, List<Map<String, dynamic>>> groupedItems = {};
    for (var item in _wardrobeItems) {
      final category = item['category'] ?? 'Other';
      if (groupedItems[category] == null) {
        groupedItems[category] = [];
      }
      groupedItems[category]!.add(item);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // Header - ✅ FIXED: Better responsive layout to prevent overflow
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.checkroom_rounded, color: primaryBlue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Select Items from Your Wardrobe',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: darkGray,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_selectedWardrobeItems.length} selected',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _navigateToWardrobe(),
                      icon: Icon(
                        Icons.open_in_new_rounded,
                        color: primaryBlue,
                        size: 16,
                      ),
                      label: Text(
                        'Open Wardrobe',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryBlue,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Categories with Photo Cards
          ...groupedItems.entries.map((entry) {
            return _buildCategorySectionWithPhotos(entry.key, entry.value);
          }).toList(),
        ],
      ),
    );
  }

  // NEW: CATEGORY SECTION WITH PHOTO CARDS
  Widget _buildCategorySectionWithPhotos(
    String category,
    List<Map<String, dynamic>> items,
  ) {
    return ExpansionTile(
      initiallyExpanded: false,
      title: Row(
        children: [
          Icon(_getCategoryIcon(category), size: 16, color: primaryBlue),
          const SizedBox(width: 8),
          Text(
            category,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkGray,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${items.length}',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: primaryBlue,
              ),
            ),
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildWardrobeItemCard(item);
            },
          ),
        ),
      ],
    );
  }

  // FIXED: WARDROBE ITEM CARD WITH PHOTO
  Widget _buildWardrobeItemCard(Map<String, dynamic> item) {
    // Check if item is selected by comparing with WardrobeItem objects
    final isSelected = _selectedWardrobeItems.any(
      (selectedItem) =>
          selectedItem.name == item['name'] &&
          selectedItem.category == item['category'],
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            // Remove WardrobeItem from list
            _selectedWardrobeItems.removeWhere(
              (selectedItem) =>
                  selectedItem.name == item['name'] &&
                  selectedItem.category == item['category'],
            );
          } else {
            // Add WardrobeItem to list
            _selectedWardrobeItems.add(
              WardrobeItem(
                name: item['name'] ?? 'Unnamed Item',
                category: item['category'] ?? 'Other',
                imageUrl: item['image'],
              ),
            );
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentRed : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
                      ? accentRed.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 8 : 4,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Section
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryBlue.withValues(alpha: 0.05),
                      accentYellow.withValues(alpha: 0.03),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Main Image
                    Center(
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: _buildItemImage(item),
                      ),
                    ),
                    // Selection Indicator
                    if (isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: accentRed,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: accentRed.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    // Color Indicator
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _getColorFromName(item['color'] ?? 'Gray'),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? 'Unnamed Item',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? accentRed : darkGray,
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
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? accentRed.withValues(alpha: 0.1)
                                    : primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['category'] ?? 'Other',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? accentRed : primaryBlue,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          item['color'] ?? 'Unknown',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: mediumGray,
                            fontWeight: FontWeight.w500,
                          ),
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
    );
  }

  // BUILD ITEM IMAGE WITH CACHING
  Widget _buildItemImage(Map<String, dynamic> item) {
    final imageUrl = item['image'];

    if (imageUrl != null &&
        imageUrl.toString().trim().isNotEmpty &&
        imageUrl.toString() != 'null' &&
        imageUrl.toString().startsWith('http')) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: CachedNetworkImage(
          imageUrl: imageUrl.toString().trim(),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder:
              (context, url) => _buildImagePlaceholder(isLoading: true),
          errorWidget:
              (context, url, error) => _buildImagePlaceholder(isError: true),
          httpHeaders: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
            'Access-Control-Allow-Headers':
                'Origin, Content-Type, Accept, Authorization',
          },
          fadeInDuration: const Duration(milliseconds: 300),
          fadeOutDuration: const Duration(milliseconds: 100),
        ),
      );
    } else {
      return _buildImagePlaceholder();
    }
  }

  // IMAGE PLACEHOLDER FOR CARDS
  Widget _buildImagePlaceholder({
    bool isLoading = false,
    bool isError = false,
  }) {
    IconData icon;
    String text;
    Color color;

    if (isLoading) {
      icon = Icons.image_rounded;
      text = 'Loading...';
      color = primaryBlue;
    } else if (isError) {
      icon = Icons.image_not_supported_rounded;
      text = 'Load Failed';
      color = accentRed;
    } else {
      icon = Icons.image_outlined;
      text = 'No Image';
      color = mediumGray;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
            Colors.white,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: color, strokeWidth: 2),
            )
          else
            Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // HELPER METHODS
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'tops':
        return Icons.checkroom_rounded;
      case 'bottoms':
        return Icons.straighten_rounded;
      case 'dresses':
        return Icons.woman_rounded;
      case 'outerwear':
        return Icons.checkroom_rounded;
      case 'accessories':
        return Icons.watch_rounded;
      case 'shoes':
        return Icons.run_circle_rounded;
      default:
        return Icons.checkroom_rounded;
    }
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'navy':
        return Colors.indigo;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'gray':
      case 'grey':
        return Colors.grey;
      case 'brown':
        return Colors.brown;
      case 'yellow':
        return Colors.yellow;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'beige':
        return const Color(0xFFF5F5DC);
      default:
        return Colors.grey;
    }
  }

  void _navigateToWardrobe() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WardrobePage()),
    );

    // Reload wardrobe data when returning from wardrobe page
    if (result != null || mounted) {
      _loadWardrobeData();
    }
  }

  // ✅ Enhanced save outfit with database integration
  void _saveOutfit() async {
    print('🔍 Save outfit button pressed');

    // Check if already saving
    if (_isSaving) {
      print('🔍 Already saving, ignoring tap');
      return;
    }

    try {
      // Set saving state
      setState(() {
        _isSaving = true;
      });

      // Validate form
      if (!_formKey.currentState!.validate()) {
        print('🔍 Form validation failed');
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please fill in all required fields',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: accentRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      // Log form data
      print('🔍 Form validation passed');
      print('🔍 Title: ${_titleController.text.trim()}');
      print('🔍 Outfit Name: ${_outfitNameController.text.trim()}');
      print('🔍 Weather: $_selectedWeather');
      print('🔍 Notes: ${_notesController.text.trim()}');
      print('🔍 Selected Items: ${_selectedWardrobeItems.length}');

      // Create outfit event
      final outfitEvent = OutfitEvent(
        id:
            widget.editingEvent?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        outfitName: _outfitNameController.text.trim(),
        status: OutfitEventStatus.planned,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
        weather: _selectedWeather.isEmpty ? null : _selectedWeather,
        wardrobeItems:
            _selectedWardrobeItems.isEmpty ? null : _selectedWardrobeItems,
      );

      print('🔍 OutfitEvent created successfully');
      print('🔍 Outfit ID: ${outfitEvent.id}');

      // ✅ ADDED: Save to database
      if (widget.editingEvent != null) {
        // Update existing outfit
        await OutfitPlannerService.updateOutfitEvent(
          widget.selectedDate,
          outfitEvent,
        );
        print('🔍 Outfit updated in database');
      } else {
        // Save new outfit
        await OutfitPlannerService.saveOutfitEvent(
          widget.selectedDate,
          outfitEvent,
        );
        print('🔍 Outfit saved to database');
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.editingEvent != null
                        ? 'Outfit updated successfully!'
                        : 'Outfit planned successfully!',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      print('🔍 Navigating back with result');
      // Navigate back with result
      Navigator.pop(context, outfitEvent);
    } catch (e, stackTrace) {
      print('❌ Error saving outfit: $e');
      print('❌ Stack trace: $stackTrace');

      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to save outfit: $e',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: accentRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

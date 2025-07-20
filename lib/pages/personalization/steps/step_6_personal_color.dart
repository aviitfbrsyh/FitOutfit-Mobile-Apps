import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/personalization_data.dart';

class Step6PersonalColor extends StatefulWidget {
  final PersonalizationData data;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final VoidCallback onChanged;

  const Step6PersonalColor({
    super.key,
    required this.data,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.onChanged,
  });

  @override
  State<Step6PersonalColor> createState() => _Step6PersonalColorState();
}

class _Step6PersonalColorState extends State<Step6PersonalColor>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Consistent colors with Step 5
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color softGray = Color(0xFFF8F9FA);

  String _selectedSeasonName = '';
  String? _hoveredSeason;
  bool _showColorGuide = false;
  bool _showSeasonDetails = false;
  bool _showPaletteGuide = false;
  bool _showPersonalAnalysis = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);

    // Initialize from existing data
    if (widget.data.selectedPersonalColor != null) {
      _selectedSeasonName = widget.data.selectedPersonalColor!;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.fadeAnimation,
      child: SlideTransition(
        position: widget.slideAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 120,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Enhanced Header matching Step 5 style
                    _buildPremiumHeader(),
                    const SizedBox(height: 24),

                    // Interactive Color Analysis Guide
                    _buildInteractiveGuideSection(),
                    const SizedBox(height: 24),

                    // Main Personal Color Selection
                    _buildPersonalColorSelectionSection(),
                    const SizedBox(height: 24),

                    // Selected Season Info
                    if (widget.data.selectedPersonalColor != null)
                      _buildSelectedSeasonInfo(),
                    if (widget.data.selectedPersonalColor != null)
                      const SizedBox(height: 24),

                    // Color Compatibility Analysis
                    if (widget.data.selectedPersonalColor != null &&
                        widget.data.selectedSkinTone != null)
                      _buildColorCompatibilitySection(),
                    if (widget.data.selectedPersonalColor != null &&
                        widget.data.selectedSkinTone != null)
                      const SizedBox(height: 24),

                    // Benefits Section
                    _buildBenefitsSection(),
                    const SizedBox(height: 16),

                    // Pro Tips Section
                    _buildProTipsSection(),

                    // Bottom spacing for safe area
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced Header matching Step 5 design
  Widget _buildPremiumHeader() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            primaryBlue.withValues(alpha: 0.03),
            accentYellow.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryBlue, accentYellow],
                      stops: [0.3, 0.9],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.palette_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          ShaderMask(
            shaderCallback:
                (bounds) => const LinearGradient(
                  colors: [primaryBlue, accentYellow],
                ).createShader(bounds),
            child: Text(
              'Personal Color Analysis',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'Discover your perfect color palette based on your natural features and undertones',
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: darkGray.withValues(alpha: 0.8),
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Interactive Guide Section
  Widget _buildInteractiveGuideSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: softGray.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: primaryBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                'Color Analysis Tools',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Comprehensive guides to help you identify your perfect color season',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Guide tools grid
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Color Guide',
                  Icons.palette_rounded,
                  primaryBlue,
                  () => setState(() => _showColorGuide = !_showColorGuide),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Season Details',
                  Icons.info_rounded,
                  accentYellow,
                  () =>
                      setState(() => _showSeasonDetails = !_showSeasonDetails),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Palette Guide',
                  Icons.gradient_rounded,
                  accentRed,
                  () => setState(() => _showPaletteGuide = !_showPaletteGuide),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Personal Analysis',
                  Icons.psychology_rounded,
                  primaryBlue,
                  () => setState(
                    () => _showPersonalAnalysis = !_showPersonalAnalysis,
                  ),
                ),
              ),
            ],
          ),

          // Expandable guides
          if (_showColorGuide) ...[
            const SizedBox(height: 20),
            _buildColorGuide(),
          ],
          if (_showSeasonDetails) ...[
            const SizedBox(height: 20),
            _buildSeasonDetailsGuide(),
          ],
          if (_showPaletteGuide) ...[
            const SizedBox(height: 20),
            _buildPaletteGuide(),
          ],
          if (_showPersonalAnalysis) ...[
            const SizedBox(height: 20),
            _buildPersonalAnalysisGuide(),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorGuide() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: softGray.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Understanding Color Seasons',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 16),
          _buildGuideItem(
            'Undertones',
            'Warm vs cool undertones in your skin determine your season',
            primaryBlue,
          ),
          _buildGuideItem(
            'Contrast Level',
            'High contrast features suit different palettes than low contrast',
            accentYellow,
          ),
          _buildGuideItem(
            'Natural Coloring',
            'Your hair, eyes, and skin work together to create your palette',
            accentRed,
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonDetailsGuide() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: softGray.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The Four Color Seasons',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 16),
          _buildGuideItem(
            'Spring (Warm & Light)',
            'Clear, warm colors with yellow undertones',
            primaryBlue,
          ),
          _buildGuideItem(
            'Summer (Cool & Light)',
            'Soft, cool colors with blue undertones',
            accentYellow,
          ),
          _buildGuideItem(
            'Autumn (Warm & Deep)',
            'Rich, warm colors with golden undertones',
            accentRed,
          ),
          _buildGuideItem(
            'Winter (Cool & Deep)',
            'Bold, cool colors with blue undertones',
            primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildPaletteGuide() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: softGray.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Creating Your Color Palette',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 16),
          _buildGuideItem(
            'Base Colors',
            'Neutrals that form the foundation of your wardrobe',
            primaryBlue,
          ),
          _buildGuideItem(
            'Accent Colors',
            'Bold colors that make you shine and stand out',
            accentYellow,
          ),
          _buildGuideItem(
            'Harmony Rules',
            'How to combine colors for maximum impact',
            accentRed,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalAnalysisGuide() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: softGray.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Color Analysis Tips',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 16),
          _buildGuideItem(
            'Natural Light',
            'Always analyze colors in natural daylight',
            primaryBlue,
          ),
          _buildGuideItem(
            'Clean Face',
            'Remove makeup to see your true coloring',
            accentYellow,
          ),
          _buildGuideItem(
            'Draping Test',
            'Hold different colored fabrics near your face',
            accentRed,
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem(String title, String description, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.info_outline, color: color, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: darkGray,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(fontSize: 12, color: mediumGray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Main Personal Color Selection Section
  Widget _buildPersonalColorSelectionSection() {
    bool hasSelection = widget.data.selectedPersonalColor != null;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              hasSelection
                  ? [accentYellow.withValues(alpha: 0.08), Colors.white]
                  : [
                    primaryBlue.withValues(alpha: 0.05),
                    accentYellow.withValues(alpha: 0.02),
                  ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: (hasSelection ? accentYellow : primaryBlue).withValues(
              alpha: 0.12,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    hasSelection
                        ? [
                          accentYellow.withValues(alpha: 0.15),
                          accentYellow.withValues(alpha: 0.05),
                        ]
                        : [
                          primaryBlue.withValues(alpha: 0.15),
                          primaryBlue.withValues(alpha: 0.05),
                        ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasSelection
                      ? Icons.check_circle_rounded
                      : Icons.palette_rounded,
                  color: hasSelection ? accentYellow : primaryBlue,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  hasSelection
                      ? 'Season: $_selectedSeasonName'
                      : 'Choose Your Color Season',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: hasSelection ? accentYellow : primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Color seasons grid
          _buildColorSeasonsGrid(),
        ],
      ),
    );
  }

  Widget _buildColorSeasonsGrid() {
    final seasons = [
      {
        'name': 'Spring',
        'subtitle': 'Warm & Bright',
        'description':
            'Clear, warm colors with yellow undertones that energize and brighten your natural coloring',
        'colors': [
          const Color(0xFFFFEB3B), // Bright Yellow
          const Color(0xFF4CAF50), // Fresh Green
          const Color(0xFFFF9800), // Warm Orange
          const Color(0xFFF06292), // Coral Pink
          const Color(0xFF03A9F4), // Clear Blue
        ],
        'characteristics': [
          'Warm undertones',
          'Clear colors',
          'Medium contrast',
        ],
        'bestColors': ['Coral', 'Turquoise', 'Golden Yellow', 'Peach'],
        'avoidColors': ['Black', 'Navy', 'Burgundy', 'Gray'],
        'icon': '🌸',
        'brandColor': accentYellow,
        'season': 'Spring',
      },
      {
        'name': 'Summer',
        'subtitle': 'Cool & Soft',
        'description':
            'Soft, cool colors with blue undertones that complement your gentle natural coloring',
        'colors': [
          const Color(0xFF2196F3), // Soft Blue
          const Color(0xFF9C27B0), // Lavender
          const Color(0xFFE91E63), // Rose Pink
          const Color(0xFF607D8B), // Blue Gray
          const Color(0xFF4DB6AC), // Mint Green
        ],
        'characteristics': ['Cool undertones', 'Soft colors', 'Low contrast'],
        'bestColors': ['Powder Blue', 'Rose', 'Lavender', 'Mint'],
        'avoidColors': ['Orange', 'Bright Yellow', 'Warm Red', 'Gold'],
        'icon': '🌊',
        'brandColor': primaryBlue,
        'season': 'Summer',
      },
      {
        'name': 'Autumn',
        'subtitle': 'Warm & Deep',
        'description':
            'Rich, warm colors with golden undertones that enhance your natural depth and warmth',
        'colors': [
          const Color(0xFFFF5722), // Rust Orange
          const Color(0xFF795548), // Warm Brown
          const Color(0xFFFF9800), // Golden Orange
          const Color(0xFF8BC34A), // Olive Green
          const Color(0xFFD32F2F), // Deep Red
        ],
        'characteristics': ['Warm undertones', 'Rich colors', 'High contrast'],
        'bestColors': ['Rust', 'Forest Green', 'Golden Brown', 'Burgundy'],
        'avoidColors': ['Pink', 'Light Blue', 'Silver', 'Purple'],
        'icon': '🍂',
        'brandColor': accentRed,
        'season': 'Autumn',
      },
      {
        'name': 'Winter',
        'subtitle': 'Cool & Bold',
        'description':
            'Bold, cool colors with blue undertones that match your striking natural contrast',
        'colors': [
          const Color(0xFF000000), // True Black
          const Color(0xFFFFFFFF), // Pure White
          const Color(0xFFD32F2F), // True Red
          const Color(0xFF3F51B5), // Royal Blue
          const Color(0xFF9C27B0), // Bright Purple
        ],
        'characteristics': ['Cool undertones', 'Bold colors', 'High contrast'],
        'bestColors': ['Black', 'White', 'True Red', 'Royal Blue'],
        'avoidColors': ['Orange', 'Gold', 'Peach', 'Warm Brown'],
        'icon': '❄️',
        'brandColor': primaryBlue,
        'season': 'Winter',
      },
    ];

    return Column(
      children: [
        // First row - 2 cards
        Row(
          children: [
            Expanded(child: _buildSeasonCard(seasons[0])),
            const SizedBox(width: 12),
            Expanded(child: _buildSeasonCard(seasons[1])),
          ],
        ),
        const SizedBox(height: 12),
        // Second row - 2 cards
        Row(
          children: [
            Expanded(child: _buildSeasonCard(seasons[2])),
            const SizedBox(width: 12),
            Expanded(child: _buildSeasonCard(seasons[3])),
          ],
        ),
      ],
    );
  }

  Widget _buildSeasonCard(Map<String, dynamic> season) {
    String name = season['name'] as String;
    bool isSelected = _selectedSeasonName == name;
    bool isHovered = _hoveredSeason == name;
    Color brandColor = season['brandColor'] as Color;
    List<Color> colors = season['colors'] as List<Color>;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() {
          widget.data.selectedPersonalColor = name;
          _selectedSeasonName = name;
          _hoveredSeason = null;
        });
        widget.onChanged();
        _showDetailedSeasonModal(season);
      },
      onTapDown: (_) => setState(() => _hoveredSeason = name),
      onTapCancel: () => setState(() => _hoveredSeason = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isSelected
                    ? [
                      brandColor.withValues(alpha: 0.15),
                      brandColor.withValues(alpha: 0.05),
                    ]
                    : isHovered
                    ? [
                      brandColor.withValues(alpha: 0.1),
                      brandColor.withValues(alpha: 0.05),
                    ]
                    : [Colors.white, Colors.grey.withValues(alpha: 0.02)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected
                    ? brandColor.withValues(alpha: 0.4)
                    : isHovered
                    ? brandColor.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
                      ? brandColor.withValues(alpha: 0.15)
                      : isHovered
                      ? brandColor.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Season icon
            Text(
              season['icon'] as String,
              style: TextStyle(fontSize: isSelected ? 32 : 28),
            ),

            // Color palette preview
            _buildColorPalette(colors, isSelected),

            // Text section
            Column(
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? brandColor : darkGray,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  season['subtitle'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to explore',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: isSelected ? brandColor : Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            // Selection indicator
            SizedBox(
              height: 20,
              child:
                  isSelected
                      ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: brandColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: brandColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 12,
                              color: brandColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Selected',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: brandColor,
                              ),
                            ),
                          ],
                        ),
                      )
                      : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          'Learn More',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPalette(List<Color> colors, bool isSelected) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children:
            colors.asMap().entries.map((entry) {
              int index = entry.key;
              Color color = entry.value;
              bool isFirst = index == 0;
              bool isLast = index == colors.length - 1;

              return Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isFirst ? 12 : 0),
                      bottomLeft: Radius.circular(isFirst ? 12 : 0),
                      topRight: Radius.circular(isLast ? 12 : 0),
                      bottomRight: Radius.circular(isLast ? 12 : 0),
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child:
                      isSelected && index == 2
                          ? const Center(
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 2,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          )
                          : null,
                ),
              );
            }).toList(),
      ),
    );
  }

  // ...existing code for other sections...

  Widget _buildSelectedSeasonInfo() {
    String selectedSeason = _selectedSeasonName;
    Map<String, dynamic> seasonData = _getSeasonData(selectedSeason);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryBlue.withValues(alpha: 0.08),
            accentYellow.withValues(alpha: 0.05),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryBlue.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryBlue.withValues(alpha: 0.2),
                      primaryBlue.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Icons.palette_rounded,
                  color: primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perfect Match!',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: primaryBlue,
                      ),
                    ),
                    Text(
                      '$selectedSeason season selected',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seasonData['description'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      (seasonData['characteristics'] as List<String>).map((
                        char,
                      ) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accentYellow.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: accentYellow.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            char,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: accentYellow,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorCompatibilitySection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: accentYellow,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Color Harmony Analysis',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: darkGray,
                      ),
                    ),
                    Text(
                      'Your colors work beautifully with your features',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: lightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Color Recommendations',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: darkGray,
                  ),
                ),
                const SizedBox(height: 12),
                ..._getColorRecommendations().map(
                  (rec) => _buildRecommendationItem(rec),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: accentYellow,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendation,
              style: GoogleFonts.poppins(fontSize: 12, color: darkGray),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    final benefits = [
      {
        'icon': Icons.auto_awesome_rounded,
        'title': 'Perfect Harmony',
        'desc': 'Colors that enhance your natural beauty',
      },
      {
        'icon': Icons.palette_rounded,
        'title': 'Style Confidence',
        'desc': 'Know exactly which colors suit you',
      },
      {
        'icon': Icons.trending_up_rounded,
        'title': 'Personal Brand',
        'desc': 'Create a cohesive, professional image',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: softGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, color: accentYellow, size: 24),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Benefits of Color Analysis',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: darkGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children:
                benefits.map((benefit) {
                  return Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            benefit['icon'] as IconData,
                            color: primaryBlue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          benefit['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: darkGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          benefit['desc'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProTipsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue.withValues(alpha: 0.08), Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: primaryBlue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pro Tip',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: darkGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Remember that personal color analysis is a guide. Trust your instincts and wear colors that make you feel confident and beautiful.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Map<String, dynamic> _getSeasonData(String season) {
    switch (season) {
      case 'Spring':
        return {
          'description':
              'Spring coloring is characterized by warm, clear, and bright colors that reflect the fresh energy of springtime. These colors complement warm undertones and create a vibrant, youthful appearance.',
          'characteristics': [
            'Warm undertones',
            'Clear colors',
            'Medium contrast',
          ],
        };
      case 'Summer':
        return {
          'description':
              'Summer coloring features soft, cool colors with blue undertones. These gentle hues complement cool undertones and create an elegant, refined appearance.',
          'characteristics': ['Cool undertones', 'Soft colors', 'Low contrast'],
        };
      case 'Autumn':
        return {
          'description':
              'Autumn coloring is defined by rich, warm colors with golden undertones. These deep, earthy hues complement warm undertones and create a sophisticated, grounded appearance.',
          'characteristics': [
            'Warm undertones',
            'Rich colors',
            'High contrast',
          ],
        };
      case 'Winter':
        return {
          'description':
              'Winter coloring features bold, cool colors with blue undertones. These striking hues complement cool undertones and create a dramatic, powerful appearance.',
          'characteristics': [
            'Cool undertones',
            'Bold colors',
            'High contrast',
          ],
        };
      default:
        return {
          'description': 'A beautiful color season.',
          'characteristics': ['Beautiful'],
        };
    }
  }

  List<String> _getColorRecommendations() {
    switch (_selectedSeasonName) {
      case 'Spring':
        return [
          'Wear coral, turquoise, and golden yellow for maximum impact',
          'Avoid black, navy, and burgundy which can overpower your coloring',
          'Choose warm metals like gold for jewelry and accessories',
        ];
      case 'Summer':
        return [
          'Embrace powder blue, rose, and lavender for a harmonious look',
          'Avoid orange, bright yellow, and warm red which clash with cool undertones',
          'Silver jewelry complements your cool coloring beautifully',
        ];
      case 'Autumn':
        return [
          'Rich rust, forest green, and golden brown enhance your natural warmth',
          'Avoid pink, light blue, and silver which can wash you out',
          'Gold and copper metals bring out your warm undertones',
        ];
      case 'Winter':
        return [
          'Bold black, white, and true red create striking contrast',
          'Avoid orange, gold, and warm brown which compete with your cool tones',
          'Silver and platinum metals enhance your cool coloring',
        ];
      default:
        return ['Choose colors that make you feel confident and beautiful'];
    }
  }

  void _showDetailedSeasonModal(Map<String, dynamic> season) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) => _buildDetailedSeasonModal(season),
    );
  }

  Widget _buildDetailedSeasonModal(Map<String, dynamic> season) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 25,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Enhanced Handle bar with color indicator
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              season['brandColor'] as Color,
                              (season['brandColor'] as Color).withValues(
                                alpha: 0.5,
                              ),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (season['brandColor'] as Color).withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (season['brandColor'] as Color).withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Text(
                          '${season['name']} Color Analysis',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: season['brandColor'] as Color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      24,
                      0,
                      24,
                      MediaQuery.of(context).padding.bottom + 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        // Enhanced Header with animated icon
                        _buildEnhancedModalHeader(season),
                        const SizedBox(height: 24),

                        // Enhanced Description with visual elements
                        _buildEnhancedDescription(season),
                        const SizedBox(height: 28),

                        // Interactive Color Palette with individual color details
                        _buildInteractiveColorPalette(season),
                        const SizedBox(height: 28),

                        // Color Psychology Section
                        _buildColorPsychologySection(season),
                        const SizedBox(height: 24),

                        // Best Colors with visual swatches
                        _buildEnhancedColorSection(
                          'Your Power Colors',
                          Icons.favorite_rounded,
                          accentYellow,
                          season['bestColors'] as List<String>,
                          _getBestColorSwatches(season['name'] as String),
                          'These colors make you glow and enhance your natural radiance',
                        ),
                        const SizedBox(height: 20),

                        // Colors to avoid with explanations
                        _buildEnhancedColorSection(
                          'Colors to Use Sparingly',
                          Icons.warning_rounded,
                          accentRed,
                          season['avoidColors'] as List<String>,
                          _getAvoidColorSwatches(season['name'] as String),
                          'These colors may wash you out or compete with your natural beauty',
                        ),
                        const SizedBox(height: 24),

                        // Styling & Makeup Section
                        _buildStylingSection(season),
                        const SizedBox(height: 24),

                        // Color Moodboard Section
                        _buildColorMoodboardSection(season),
                        const SizedBox(height: 24),

                        // Color Visualization Section
                        _buildColorVisualizationSection(season),
                        const SizedBox(height: 24),

                        // Celebrity Inspiration Section
                        _buildCelebritySection(season),
                        const SizedBox(height: 28),

                        // Enhanced Action Button (only one button now)
                        _buildEnhancedActionButtons(season),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedModalHeader(Map<String, dynamic> season) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (season['brandColor'] as Color).withValues(alpha: 0.1),
            (season['brandColor'] as Color).withValues(alpha: 0.05),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (season['brandColor'] as Color).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Animated season icon
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.8, end: 1.0),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        season['brandColor'] as Color,
                        (season['brandColor'] as Color).withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: (season['brandColor'] as Color).withValues(
                          alpha: 0.3,
                        ),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      season['icon'] as String,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback:
                      (bounds) => LinearGradient(
                        colors: [
                          season['brandColor'] as Color,
                          (season['brandColor'] as Color).withValues(
                            alpha: 0.7,
                          ),
                        ],
                      ).createShader(bounds),
                  child: Text(
                    '${season['name']} Season',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  season['subtitle'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: mediumGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (season['brandColor'] as Color).withValues(
                      alpha: 0.15,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getSeasonTemperature(season['name'] as String),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: season['brandColor'] as Color,
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

  Widget _buildEnhancedDescription(Map<String, dynamic> season) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: softGray.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_rounded, color: primaryBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                'Your Season Personality',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            season['description'] as String,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: darkGray,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),
          // Characteristics with enhanced styling
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                (season['characteristics'] as List<String>).map((char) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (season['brandColor'] as Color).withValues(
                            alpha: 0.15,
                          ),
                          (season['brandColor'] as Color).withValues(
                            alpha: 0.08,
                          ),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (season['brandColor'] as Color).withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: season['brandColor'] as Color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          char,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: season['brandColor'] as Color,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveColorPalette(Map<String, dynamic> season) {
    List<Color> colors = season['colors'] as List<Color>;
    List<String> colorNames = _getColorNames(season['name'] as String);
    List<String> colorDescriptions = _getColorDescriptions(
      season['name'] as String,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
              Icon(
                Icons.palette_rounded,
                color: season['brandColor'] as Color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Your Color Palette',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Interactive color swatches
          Column(
            children:
                colors.asMap().entries.map((entry) {
                  int index = entry.key;
                  Color color = entry.value;
                  String colorName =
                      index < colorNames.length
                          ? colorNames[index]
                          : 'Color ${index + 1}';
                  String description =
                      index < colorDescriptions.length
                          ? colorDescriptions[index]
                          : 'Beautiful color';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        // Enhanced color swatch
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(13),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.2),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.1),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                colorName,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: darkGray,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                description,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: mediumGray,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getColorUsage(colorName),
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPsychologySection(Map<String, dynamic> season) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentYellow.withValues(alpha: 0.08),
            accentYellow.withValues(alpha: 0.03),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentYellow.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_alt_rounded, color: accentYellow, size: 24),
              const SizedBox(width: 12),
              Text(
                'Color Psychology',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getColorPsychology(season['name'] as String),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: darkGray,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: accentYellow, size: 18),
              const SizedBox(width: 8),
              Text(
                'Impact on Others:',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: accentYellow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getColorImpact(season['name'] as String),
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: mediumGray,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedColorSection(
    String title,
    IconData icon,
    Color color,
    List<String> colorNames,
    List<Color> colorSwatches,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: mediumGray,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                colorNames.asMap().entries.map((entry) {
                  int index = entry.key;
                  String colorName = entry.value;
                  Color swatch =
                      index < colorSwatches.length
                          ? colorSwatches[index]
                          : color;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: swatch.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: swatch,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: swatch.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          colorName,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: darkGray,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStylingSection(Map<String, dynamic> season) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.style_rounded, color: primaryBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                'Color Harmony & Styling',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStylingCategory(
            'Jewelry & Accessories',
            Icons.diamond_rounded,
            _getJewelryTips(season['name'] as String),
          ),
          const SizedBox(height: 16),
          _buildStylingCategory(
            'Hair Color Harmony',
            Icons.color_lens_rounded,
            _getHairColorTips(season['name'] as String),
          ),
        ],
      ),
    );
  }

  Widget _buildStylingCategory(String title, IconData icon, List<String> tips) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryBlue, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tip,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: mediumGray,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorMoodboardSection(Map<String, dynamic> season) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (season['brandColor'] as Color).withValues(alpha: 0.08),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (season['brandColor'] as Color).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.dashboard_rounded,
                color: season['brandColor'] as Color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Color Moodboard',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Visualize how your ${season['name']} colors work together in real life:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: mediumGray,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Color mood grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children:
                _getMoodboardItems(season['name'] as String).map((item) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: item['color'] as Color,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (item['color'] as Color).withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorVisualizationSection(Map<String, dynamic> season) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: softGray.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility_rounded, color: primaryBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                'Color Visualization',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'See how your ${season['name']} colors work in different contexts:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: mediumGray,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Visualization examples
          Column(
            children:
                _getVisualizationExamples(season['name'] as String).map((
                  example,
                ) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: example['colors'] as List<Color>,
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                example['title'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: darkGray,
                                ),
                              ),
                              Text(
                                example['description'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: mediumGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
  List<Map<String, dynamic>> _getMoodboardItems(String season) {
    switch (season) {
      case 'Spring':
        return [
          {
            'title': 'Fresh & Bright',
            'icon': Icons.wb_sunny_rounded,
            'color': const Color(0xFFFFEB3B),
          },
          {
            'title': 'Natural Glow',
            'icon': Icons.local_florist_rounded,
            'color': const Color(0xFF4CAF50),
          },
          {
            'title': 'Warm Coral',
            'icon': Icons.favorite_rounded,
            'color': const Color(0xFFF06292),
          },
          {
            'title': 'Clear Blue',
            'icon': Icons.water_drop_rounded,
            'color': const Color(0xFF03A9F4),
          },
        ];
      case 'Summer':
        return [
          {
            'title': 'Cool Elegance',
            'icon': Icons.ac_unit_rounded,
            'color': const Color(0xFF2196F3),
          },
          {
            'title': 'Soft Romance',
            'icon': Icons.favorite_border_rounded,
            'color': const Color(0xFFE91E63),
          },
          {
            'title': 'Gentle Lavender',
            'icon': Icons.spa_rounded,
            'color': const Color(0xFF9C27B0),
          },
          {
            'title': 'Serene Mint',
            'icon': Icons.eco_rounded,
            'color': const Color(0xFF4DB6AC),
          },
        ];
      case 'Autumn':
        return [
          {
            'title': 'Rich Rust',
            'icon': Icons.local_fire_department_rounded,
            'color': const Color(0xFFBF360C),
          },
          {
            'title': 'Golden Brown',
            'icon': Icons.coffee_rounded,
            'color': const Color(0xFF5D4037),
          },
          {
            'title': 'Forest Green',
            'icon': Icons.forest_rounded,
            'color': const Color(0xFF2E7D32),
          },
          {
            'title': 'Deep Burgundy',
            'icon': Icons.wine_bar_rounded,
            'color': const Color(0xFF880E4F),
          },
        ];
      case 'Winter':
        return [
          {
            'title': 'Pure Black',
            'icon': Icons.dark_mode_rounded,
            'color': const Color(0xFF000000),
          },
          {
            'title': 'Snow White',
            'icon': Icons.ac_unit_rounded,
            'color': const Color(0xFFFFFFFF),
          },
          {
            'title': 'True Red',
            'icon': Icons.favorite_rounded,
            'color': const Color(0xFFD32F2F),
          },
          {
            'title': 'Royal Blue',
            'icon': Icons.star_rounded,
            'color': const Color(0xFF1976D2),
          },
        ];
      default:
        return [
          {
            'title': 'Beautiful',
            'icon': Icons.palette_rounded,
            'color': primaryBlue,
          },
          {
            'title': 'Elegant',
            'icon': Icons.star_rounded,
            'color': accentYellow,
          },
          {
            'title': 'Stunning',
            'icon': Icons.favorite_rounded,
            'color': accentRed,
          },
          {
            'title': 'Perfect',
            'icon': Icons.check_circle_rounded,
            'color': darkGray,
          },
        ];
    }
  }

  List<Map<String, dynamic>> _getVisualizationExamples(String season) {
    switch (season) {
      case 'Spring':
        return [
          {
            'title': 'Professional Look',
            'description': 'Navy blazer with coral blouse and gold accessories',
            'colors': [const Color(0xFF1976D2), const Color(0xFFFF7043)],
          },
          {
            'title': 'Casual Weekend',
            'description': 'Turquoise top with cream pants and brown leather',
            'colors': [const Color(0xFF26C6DA), const Color(0xFFF5F5DC)],
          },
          {
            'title': 'Evening Elegance',
            'description': 'Golden dress with warm metallic accents',
            'colors': [const Color(0xFFFFD700), const Color(0xFFFF9800)],
          },
        ];
      case 'Summer':
        return [
          {
            'title': 'Office Chic',
            'description':
                'Powder blue shirt with gray suit and silver details',
            'colors': [const Color(0xFFB3E5FC), const Color(0xFF90A4AE)],
          },
          {
            'title': 'Romantic Date',
            'description': 'Rose pink dress with soft lavender accessories',
            'colors': [const Color(0xFFE1BEE7), const Color(0xFFF8BBD9)],
          },
          {
            'title': 'Casual Comfort',
            'description': 'Soft mint sweater with white jeans',
            'colors': [const Color(0xFFB2DFDB), const Color(0xFFFAFAFA)],
          },
        ];
      case 'Autumn':
        return [
          {
            'title': 'Power Meeting',
            'description': 'Rust blazer with chocolate brown and gold accents',
            'colors': [const Color(0xFFBF360C), const Color(0xFF5D4037)],
          },
          {
            'title': 'Cozy Weekend',
            'description': 'Forest green sweater with warm brown boots',
            'colors': [const Color(0xFF2E7D32), const Color(0xFF8D6E63)],
          },
          {
            'title': 'Evening Warmth',
            'description': 'Deep burgundy dress with copper jewelry',
            'colors': [const Color(0xFF880E4F), const Color(0xFFFF8A65)],
          },
        ];
      case 'Winter':
        return [
          {
            'title': 'Executive Power',
            'description': 'Black suit with white shirt and silver accessories',
            'colors': [const Color(0xFF000000), const Color(0xFFFFFFFF)],
          },
          {
            'title': 'Bold Statement',
            'description': 'True red dress with black and white accents',
            'colors': [const Color(0xFFD32F2F), const Color(0xFF000000)],
          },
          {
            'title': 'Regal Elegance',
            'description': 'Royal blue gown with crystal details',
            'colors': [const Color(0xFF1976D2), const Color(0xFFE3F2FD)],
          },
        ];
      default:
        return [
          {
            'title': 'Beautiful Look',
            'description': 'Perfect color combination',
            'colors': [primaryBlue, accentYellow],
          },
        ];
    }
  }

  List<String> _getJewelryTips(String season) {
    switch (season) {
      case 'Spring':
        return [
          'Gold jewelry enhances your warm undertones perfectly',
          'Coral, turquoise, and yellow gemstones are ideal',
          'Delicate, fine jewelry complements your light coloring',
          'Avoid heavy, dark metals that overpower your brightness',
        ];
      case 'Summer':
        return [
          'Silver and white gold complement your cool undertones',
          'Blue, rose, and lavender gemstones are beautiful',
          'Delicate, elegant pieces suit your refined nature',
          'Pearls are particularly flattering on your coloring',
        ];
      case 'Autumn':
        return [
          'Gold, copper, and bronze metals enhance your warmth',
          'Amber, topaz, and warm gemstones are perfect',
          'Bold, substantial pieces complement your rich coloring',
          'Natural materials like wood and leather work beautifully',
        ];
      case 'Winter':
        return [
          'Silver, platinum, and white gold are ideal',
          'Diamonds, sapphires, and rubies create stunning contrast',
          'Bold, dramatic pieces complement your striking features',
          'Black jewelry can be very sophisticated on you',
        ];
      default:
        return ['Choose metals and stones that enhance your natural beauty'];
    }
  }

  List<String> _getHairColorTips(String season) {
    switch (season) {
      case 'Spring':
        return [
          'Golden blonde, strawberry blonde work beautifully',
          'Warm brown shades with golden highlights',
          'Avoid ash tones that can wash out your warmth',
          'Copper and auburn shades can be stunning',
        ];
      case 'Summer':
        return [
          'Ash blonde and cool brown shades are perfect',
          'Platinum blonde creates beautiful contrast',
          'Avoid golden or warm tones that clash with your coolness',
          'Cool-toned highlights enhance your natural beauty',
        ];
      case 'Autumn':
        return [
          'Rich browns, auburn, and deep reds are ideal',
          'Golden blonde with warm undertones works well',
          'Avoid cool or ash tones that conflict with your warmth',
          'Copper and bronze highlights add beautiful dimension',
        ];
      case 'Winter':
        return [
          'Deep browns, black, and platinum blonde are striking',
          'Bold colors can work if they have cool undertones',
          'Avoid warm or golden tones that compete with your coolness',
          'High contrast colors enhance your dramatic features',
        ];
      default:
        return ['Choose hair colors that complement your natural coloring'];
    }
  }

  // Add missing helper methods
  String _getSeasonTemperature(String season) {
    switch (season) {
      case 'Spring':
        return 'Warm • Light';
      case 'Summer':
        return 'Cool • Light';
      case 'Autumn':
        return 'Warm • Deep';
      case 'Winter':
        return 'Cool • Deep';
      default:
        return 'Beautiful';
    }
  }

  List<String> _getColorNames(String season) {
    switch (season) {
      case 'Spring':
        return [
          'Sunshine Yellow',
          'Fresh Mint',
          'Coral Bloom',
          'Peach Glow',
          'Clear Sky',
        ];
      case 'Summer':
        return [
          'Ocean Blue',
          'Lavender Dream',
          'Rose Quartz',
          'Misty Gray',
          'Sage Green',
        ];
      case 'Autumn':
        return [
          'Burnt Orange',
          'Golden Brown',
          'Amber Glow',
          'Forest Green',
          'Deep Burgundy',
        ];
      case 'Winter':
        return [
          'Pure Black',
          'Snow White',
          'Ruby Red',
          'Royal Blue',
          'Amethyst',
        ];
      default:
        return ['Color 1', 'Color 2', 'Color 3', 'Color 4', 'Color 5'];
    }
  }

  List<String> _getColorDescriptions(String season) {
    switch (season) {
      case 'Spring':
        return [
          'Energizing and optimistic, perfect for statement pieces',
          'Fresh and rejuvenating, ideal for casual wear',
          'Warm and flattering, enhances your natural glow',
          'Soft and romantic, beautiful for evening looks',
          'Clear and crisp, great for professional settings',
        ];
      case 'Summer':
        return [
          'Calming and sophisticated, perfect for formal wear',
          'Gentle and dreamy, ideal for romantic occasions',
          'Soft and feminine, enhances your delicate features',
          'Subtle and elegant, great for everyday wear',
          'Fresh and natural, perfect for casual looks',
        ];
      case 'Autumn':
        return [
          'Bold and earthy, makes a powerful statement',
          'Rich and warm, perfect for professional settings',
          'Luxurious and glowing, enhances your warmth',
          'Deep and natural, ideal for casual elegance',
          'Sophisticated and dramatic, perfect for evening',
        ];
      case 'Winter':
        return [
          'Classic and dramatic, creates striking contrast',
          'Pure and clean, perfect for minimalist looks',
          'Bold and passionate, makes a powerful statement',
          'Regal and confident, ideal for formal occasions',
          'Mysterious and elegant, perfect for evening wear',
        ];
      default:
        return [
          'Beautiful color',
          'Lovely shade',
          'Perfect tone',
          'Great choice',
          'Stunning hue',
        ];
    }
  }

  String _getColorUsage(String colorName) {
    if (colorName.contains('Black') ||
        colorName.contains('White') ||
        colorName.contains('Gray')) {
      return 'Base Color';
    } else if (colorName.contains('Blue') ||
        colorName.contains('Green') ||
        colorName.contains('Brown')) {
      return 'Secondary';
    } else {
      return 'Accent Color';
    }
  }

  String _getColorPsychology(String season) {
    switch (season) {
      case 'Spring':
        return 'Your bright, warm colors project energy, optimism, and approachability. You naturally draw people in with your fresh, youthful vibe and create an atmosphere of joy and possibility.';
      case 'Summer':
        return 'Your soft, cool colors convey elegance, reliability, and grace. You project a sense of calm sophistication and trustworthiness that makes others feel at ease around you.';
      case 'Autumn':
        return 'Your rich, warm colors communicate strength, authenticity, and groundedness. You project confidence and reliability while maintaining an approachable, earthy sophistication.';
      case 'Winter':
        return 'Your bold, cool colors project power, sophistication, and authority. You naturally command attention and respect with your striking, confident presence.';
      default:
        return 'Your colors reflect your unique personality and natural beauty.';
    }
  }

  String _getColorImpact(String season) {
    switch (season) {
      case 'Spring':
        return 'Others see you as vibrant, creative, and full of life. Your colors make you appear youthful and energetic.';
      case 'Summer':
        return 'Others see you as refined, trustworthy, and effortlessly elegant. Your colors create a calming, harmonious presence.';
      case 'Autumn':
        return 'Others see you as confident, authentic, and naturally sophisticated. Your colors project warmth and reliability.';
      case 'Winter':
        return 'Others see you as powerful, sophisticated, and naturally commanding. Your colors create a memorable, striking impression.';
      default:
        return 'Your colors create a beautiful, memorable impression.';
    }
  }

  List<Color> _getBestColorSwatches(String season) {
    switch (season) {
      case 'Spring':
        return [
          const Color(0xFFFF7F7F), // Coral
          const Color(0xFF40E0D0), // Turquoise
          const Color(0xFFFFD700), // Golden Yellow
          const Color(0xFFFFDAB9), // Peach
        ];
      case 'Summer':
        return [
          const Color(0xFFB0E0E6), // Powder Blue
          const Color(0xFFBC8F8F), // Rose
          const Color(0xFFE6E6FA), // Lavender
          const Color(0xFF98FB98), // Mint
        ];
      case 'Autumn':
        return [
          const Color(0xFFB22222), // Rust
          const Color(0xFF228B22), // Forest Green
          const Color(0xFFDAA520), // Golden Brown
          const Color(0xFF800020), // Burgundy
        ];
      case 'Winter':
        return [
          const Color(0xFF000000), // Black
          const Color(0xFFFFFFFF), // White
          const Color(0xFFDC143C), // True Red
          const Color(0xFF4169E1), // Royal Blue
        ];
      default:
        return [primaryBlue, accentYellow, accentRed, darkGray];
    }
  }

  List<Color> _getAvoidColorSwatches(String season) {
    switch (season) {
      case 'Spring':
        return [
          const Color(0xFF000000), // Black
          const Color(0xFF000080), // Navy
          const Color(0xFF800020), // Burgundy
          const Color(0xFF808080), // Gray
        ];
      case 'Summer':
        return [
          const Color(0xFFFF4500), // Orange
          const Color(0xFFFFD700), // Bright Yellow
          const Color(0xFFDC143C), // Warm Red
          const Color(0xFFFFD700), // Gold
        ];
      case 'Autumn':
        return [
          const Color(0xFFFFC0CB), // Pink
          const Color(0xFFADD8E6), // Light Blue
          const Color(0xFFC0C0C0), // Silver
          const Color(0xFF800080), // Purple
        ];
      case 'Winter':
        return [
          const Color(0xFFFF4500), // Orange
          const Color(0xFFFFD700), // Gold
          const Color(0xFFFFDAB9), // Peach
          const Color(0xFFA52A2A), // Warm Brown
        ];
      default:
        return [Colors.grey, Colors.brown, Colors.orange, Colors.pink];
    }
  }

  Widget _buildCelebritySection(Map<String, dynamic> season) {
    List<String> celebrities = _getCelebrityInspiration(
      season['name'] as String,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: accentRed.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentRed.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_rounded, color: accentRed, size: 24),
              const SizedBox(width: 12),
              Text(
                'Celebrity Inspiration',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Celebrities who share your ${season['name']} coloring:',
            style: GoogleFonts.poppins(fontSize: 14, color: mediumGray),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children:
                celebrities.map((celebrity) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: accentRed.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_rounded, color: accentRed, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          celebrity,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: darkGray,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedActionButtons(Map<String, dynamic> season) {
    return Column(
      children: [
        // Primary action button only
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  season['brandColor'] as Color,
                  (season['brandColor'] as Color).withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (season['brandColor'] as Color).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Perfect! This is my season',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Add safe area bottom padding
        SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
      ],
    );
  }

  List<String> _getCelebrityInspiration(String season) {
    switch (season) {
      case 'Spring':
        return [
          'Emma Stone',
          'Blake Lively',
          'Amy Adams',
          'Jessica Chastain',
          'Scarlett Johansson',
        ];
      case 'Summer':
        return [
          'Grace Kelly',
          'Gwyneth Paltrow',
          'Cate Blanchett',
          'Emily Blunt',
          'Rose Byrne',
        ];
      case 'Autumn':
        return [
          'Julia Roberts',
          'Jennifer Lopez',
          'Halle Berry',
          'Tyra Banks',
          'Julianne Moore',
        ];
      case 'Winter':
        return [
          'Megan Fox',
          'Lucy Liu',
          'Anne Hathaway',
          'Zooey Deschanel',
          'Courteney Cox',
        ];
      default:
        return ['Many beautiful celebrities share your coloring'];
    }
  }
}

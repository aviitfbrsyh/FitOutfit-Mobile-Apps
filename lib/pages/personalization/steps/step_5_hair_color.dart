import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/personalization_data.dart';

class Step5HairColor extends StatefulWidget {
  final PersonalizationData data;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final VoidCallback onChanged;

  const Step5HairColor({
    super.key,
    required this.data,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.onChanged,
  });

  @override
  State<Step5HairColor> createState() => _Step5HairColorState();
}

class _Step5HairColorState extends State<Step5HairColor>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Consistent colors with Step 4
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color softGray = Color(0xFFF8F9FA);

  String _selectedHairColorName = '';
  String? _hoveredColor;
  bool _showColorGuide = false;
  bool _showMaintenanceTips = false;
  bool _showStylingGuide = false;

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
                    // Enhanced Header matching Step 4 style
                    _buildPremiumHeader(),
                    const SizedBox(height: 24),

                    // Interactive Hair Color Guide
                    _buildInteractiveGuideSection(),
                    const SizedBox(height: 24),

                    // Main Hair Color Selection
                    _buildHairColorSelectionSection(),
                    const SizedBox(height: 24),

                    // Selected Hair Color Info
                    if (widget.data.selectedHairColor != null)
                      _buildSelectedHairColorInfo(),
                    if (widget.data.selectedHairColor != null)
                      const SizedBox(height: 24),

                    // Color Compatibility with Skin Tone
                    if (widget.data.selectedHairColor != null &&
                        widget.data.selectedSkinTone != null)
                      _buildColorCompatibilitySection(),
                    if (widget.data.selectedHairColor != null &&
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

  // Enhanced Header matching Step 4 design
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
                    Icons.color_lens_rounded,
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
              'Your Hair Color',
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
            'Find the perfect hair color that complements your skin tone and personal style',
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
                'Hair Color Guidance',
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
            'Get expert tips and guidance for choosing your perfect hair color',
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
                  'Maintenance',
                  Icons.healing_rounded,
                  accentYellow,
                  () => setState(
                    () => _showMaintenanceTips = !_showMaintenanceTips,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            'Styling Tips',
            Icons.style_rounded,
            accentRed,
            () => setState(() => _showStylingGuide = !_showStylingGuide),
            fullWidth: true,
          ),

          // Expandable guides
          if (_showColorGuide) ...[
            const SizedBox(height: 20),
            _buildColorGuide(),
          ],
          if (_showMaintenanceTips) ...[
            const SizedBox(height: 20),
            _buildMaintenanceGuide(),
          ],
          if (_showStylingGuide) ...[
            const SizedBox(height: 20),
            _buildStylingGuide(),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool fullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
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
            'Choosing Your Hair Color',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 16),
          _buildGuideItem(
            'Skin Tone Match',
            'Choose colors that complement your skin undertone',
            primaryBlue,
          ),
          _buildGuideItem(
            'Eye Color',
            'Consider colors that enhance your natural eye color',
            accentYellow,
          ),
          _buildGuideItem(
            'Lifestyle',
            'Factor in maintenance requirements and daily routine',
            accentRed,
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceGuide() {
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
            'Hair Color Maintenance',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 16),
          _buildGuideItem(
            'Touch-ups',
            'Roots typically need refreshing every 4-6 weeks',
            primaryBlue,
          ),
          _buildGuideItem(
            'Color Protection',
            'Use color-safe shampoo and UV protection',
            accentYellow,
          ),
          _buildGuideItem(
            'Deep Conditioning',
            'Regular treatments maintain color vibrancy',
            accentRed,
          ),
        ],
      ),
    );
  }

  Widget _buildStylingGuide() {
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
            'Styling Your Hair Color',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 16),
          _buildGuideItem(
            'Heat Protection',
            'Always use heat protectant before styling',
            primaryBlue,
          ),
          _buildGuideItem(
            'Color Coordination',
            'Match accessories and makeup to your new color',
            accentYellow,
          ),
          _buildGuideItem(
            'Professional Care',
            'Regular salon visits maintain color quality',
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

  // Main Hair Color Selection Section
  Widget _buildHairColorSelectionSection() {
    bool hasSelection = widget.data.selectedHairColor != null;

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
                      : Icons.color_lens_rounded,
                  color: hasSelection ? accentYellow : primaryBlue,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  hasSelection
                      ? 'Hair Color: $_selectedHairColorName'
                      : 'Choose Your Hair Color',
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

          // Hair color grid
          _buildHairColorGrid(),
        ],
      ),
    );
  }

  Widget _buildHairColorGrid() {
    final hairColors = [
      {
        'name': 'Black',
        'description': 'Deep, rich and timeless',
        'colors': [
          const Color(0xFF1C1C1C),
          const Color(0xFF2C2C2C),
          const Color(0xFF0F0F0F),
        ],
        'icon': '🖤',
        'characteristics': ['Classic', 'Low maintenance', 'Universal'],
        'brandColor': darkGray,
      },
      {
        'name': 'Dark Brown',
        'description': 'Warm and sophisticated',
        'colors': [
          const Color(0xFF4A2C17),
          const Color(0xFF6B3E1A),
          const Color(0xFF3D1F0A),
        ],
        'icon': '🌰',
        'characteristics': ['Natural', 'Versatile', 'Professional'],
        'brandColor': primaryBlue,
      },
      {
        'name': 'Light Brown',
        'description': 'Soft and approachable',
        'colors': [
          const Color(0xFF8B4513),
          const Color(0xFFA0522D),
          const Color(0xFF654321),
        ],
        'icon': '🥜',
        'characteristics': ['Friendly', 'Gentle', 'Modern'],
        'brandColor': accentYellow,
      },
      {
        'name': 'Blonde',
        'description': 'Bright and youthful',
        'colors': [
          const Color(0xFFDAA520),
          const Color(0xFFFFD700),
          const Color(0xFFB8860B),
        ],
        'icon': '🌾',
        'characteristics': ['Vibrant', 'Trendy', 'Eye-catching'],
        'brandColor': accentYellow,
      },
      {
        'name': 'Red',
        'description': 'Bold and expressive',
        'colors': [
          const Color(0xFFB22222),
          const Color(0xFFDC143C),
          const Color(0xFF8B0000),
        ],
        'icon': '🔥',
        'characteristics': ['Unique', 'Bold', 'Expressive'],
        'brandColor': accentRed,
      },
      {
        'name': 'Gray',
        'description': 'Elegant and distinguished',
        'colors': [
          const Color(0xFF808080),
          const Color(0xFFA9A9A9),
          const Color(0xFF696969),
        ],
        'icon': '⚪',
        'characteristics': ['Sophisticated', 'Modern', 'Distinguished'],
        'brandColor': mediumGray,
      },
    ];

    return Column(
      children: [
        // First row - 2 cards
        Row(
          children: [
            Expanded(child: _buildHairColorCard(hairColors[0], 0)),
            const SizedBox(width: 12),
            Expanded(child: _buildHairColorCard(hairColors[1], 1)),
          ],
        ),
        const SizedBox(height: 12),
        // Second row - 2 cards
        Row(
          children: [
            Expanded(child: _buildHairColorCard(hairColors[2], 2)),
            const SizedBox(width: 12),
            Expanded(child: _buildHairColorCard(hairColors[3], 3)),
          ],
        ),
        const SizedBox(height: 12),
        // Third row - 2 cards
        Row(
          children: [
            Expanded(child: _buildHairColorCard(hairColors[4], 4)),
            const SizedBox(width: 12),
            Expanded(child: _buildHairColorCard(hairColors[5], 5)),
          ],
        ),
      ],
    );
  }

  Widget _buildHairColorCard(Map<String, dynamic> hairColor, int index) {
    String name = hairColor['name'] as String;
    bool isSelected = _selectedHairColorName == name;
    bool isHovered = _hoveredColor == name;
    Color brandColor = hairColor['brandColor'] as Color;
    List<Color> colors = hairColor['colors'] as List<Color>;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() {
          widget.data.selectedHairColor = name;
          _selectedHairColorName = name;
          _hoveredColor = null;
        });
        widget.onChanged();
        _showDetailedHairColorModal(hairColor);
      },
      onTapDown: (_) => setState(() => _hoveredColor = name),
      onTapCancel: () => setState(() => _hoveredColor = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 180,
        padding: const EdgeInsets.all(14),
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
          borderRadius: BorderRadius.circular(14),
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
              blurRadius: isSelected ? 10 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Static Hair Icon
            Text(
              hairColor['icon'] as String,
              style: TextStyle(fontSize: isSelected ? 28 : 24),
            ),

            // Natural Hair Color Animation
            _buildHairColorAnimation(colors, isSelected),

            // Text section
            Column(
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? brandColor : darkGray,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  hairColor['description'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                          horizontal: 6,
                          vertical: 2,
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
                              size: 10,
                              color: brandColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Selected',
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: brandColor,
                              ),
                            ),
                          ],
                        ),
                      )
                      : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
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
                            fontSize: 9,
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

  Widget _buildHairColorAnimation(List<Color> colors, bool isSelected) {
    return Container(
      height: 32,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // Base hair color
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Hair texture overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Hair strands simulation
            Positioned.fill(
              child: CustomPaint(painter: HairStrandsPainter(colors.first)),
            ),
            // Selection check
            if (isSelected)
              const Center(
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 2,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Selected Hair Color Info
  Widget _buildSelectedHairColorInfo() {
    String selectedColor = _selectedHairColorName;
    Map<String, dynamic> colorData = _getHairColorData(selectedColor);

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
                  Icons.color_lens_rounded,
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
                      'Great Choice!',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: primaryBlue,
                      ),
                    ),
                    Text(
                      '$selectedColor hair color selected',
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
                  colorData['description'] as String,
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
                      (colorData['features'] as List<String>).map((feature) {
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
                            feature,
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

  // Color Compatibility Section
  Widget _buildColorCompatibilitySection() {
    Map<String, dynamic> compatibility = _getColorCompatibility(
      widget.data.selectedHairColor!,
    );

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
                      'Perfect Color Match',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: darkGray,
                      ),
                    ),
                    Text(
                      'This color complements your features beautifully',
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
                  'Styling Recommendations',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: darkGray,
                  ),
                ),
                const SizedBox(height: 12),
                ...((compatibility['recommendations'] as List<String>).map(
                  (rec) => _buildRecommendationItem(rec),
                )),
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

  // Benefits Section
  Widget _buildBenefitsSection() {
    final benefits = [
      {
        'icon': Icons.auto_awesome_rounded,
        'title': 'Perfect Match',
        'desc': 'Colors that enhance your natural beauty',
      },
      {
        'icon': Icons.palette_rounded,
        'title': 'Style Guide',
        'desc': 'Personalized styling recommendations',
      },
      {
        'icon': Icons.trending_up_rounded,
        'title': 'Confidence',
        'desc': 'Look and feel your absolute best',
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
                    'Why Hair Color Matters',
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

  // Pro Tips Section
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
                  'Always consult with a professional colorist for major hair color changes to achieve the best results.',
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

  // Helper methods for data
  Map<String, dynamic> _getHairColorData(String color) {
    switch (color) {
      case 'Black':
        return {
          'description':
              'Black hair is timeless, classic, and works with almost every style. It\'s low maintenance and gives a sleek, polished look.',
          'features': [
            'Low maintenance',
            'Classic',
            'Versatile',
            'Professional',
          ],
        };
      case 'Dark Brown':
        return {
          'description':
              'Dark brown hair is natural-looking and sophisticated. It complements most skin tones and is perfect for both casual and professional settings.',
          'features': ['Natural', 'Sophisticated', 'Warm', 'Versatile'],
        };
      case 'Light Brown':
        return {
          'description':
              'Light brown hair offers a soft, approachable look. It\'s perfect for those who want a natural color with subtle warmth.',
          'features': ['Soft', 'Natural', 'Approachable', 'Gentle'],
        };
      case 'Blonde':
        return {
          'description':
              'Blonde hair is bright, youthful, and eye-catching. It requires more maintenance but offers endless styling possibilities.',
          'features': ['Bright', 'Youthful', 'Trendy', 'Eye-catching'],
        };
      case 'Red':
        return {
          'description':
              'Red hair is bold, unique, and expressive. It\'s perfect for those who want to make a statement and stand out.',
          'features': ['Bold', 'Unique', 'Expressive', 'Statement-making'],
        };
      case 'Gray':
        return {
          'description':
              'Gray hair is elegant, modern, and distinguished. It\'s a bold choice that works beautifully with the right styling.',
          'features': ['Elegant', 'Modern', 'Distinguished', 'Sophisticated'],
        };
      default:
        return {
          'description': 'A beautiful hair color choice.',
          'features': ['Beautiful'],
        };
    }
  }

  Map<String, dynamic> _getColorCompatibility(String hairColor) {
    // This would normally use skin tone data for better recommendations
    switch (hairColor) {
      case 'Black':
        return {
          'recommendations': [
            'Try bold makeup colors to complement the dramatic hair',
            'Silver jewelry works beautifully with black hair',
            'Consider subtle highlights for dimension',
          ],
        };
      case 'Dark Brown':
        return {
          'recommendations': [
            'Warm makeup tones enhance the natural warmth',
            'Gold jewelry complements the brown undertones',
            'Caramel highlights add beautiful dimension',
          ],
        };
      case 'Light Brown':
        return {
          'recommendations': [
            'Neutral makeup tones work perfectly',
            'Both gold and silver jewelry are flattering',
            'Honey highlights add natural-looking brightness',
          ],
        };
      case 'Blonde':
        return {
          'recommendations': [
            'Cool-toned makeup prevents washing out',
            'Silver jewelry enhances the bright color',
            'Regular toning maintains color vibrancy',
          ],
        };
      case 'Red':
        return {
          'recommendations': [
            'Green and gold makeup tones are complementary',
            'Gold jewelry enhances the warm undertones',
            'Color-protecting products are essential',
          ],
        };
      case 'Gray':
        return {
          'recommendations': [
            'Bold makeup colors create striking contrast',
            'Silver jewelry enhances the sophisticated look',
            'Purple shampoo maintains the color tone',
          ],
        };
      default:
        return {
          'recommendations': ['Consult with a professional colorist'],
        };
    }
  }

  void _showDetailedHairColorModal(Map<String, dynamic> hairColor) {
    String colorName = hairColor['name'] as String;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) => _buildDetailedHairColorModal(colorName),
    );
  }

  Widget _buildDetailedHairColorModal(String colorName) {
    Map<String, dynamic> detailedData = _getDetailedHairColorData(colorName);

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.9,
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
                // Handle bar
                Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Text(
                              detailedData['icon'] as String,
                              style: const TextStyle(fontSize: 48),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$colorName Hair',
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: darkGray,
                                    ),
                                  ),
                                  Text(
                                    detailedData['subtitle'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: mediumGray,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Description
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: primaryBlue.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            detailedData['description'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: darkGray,
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Maintenance tips
                        _buildModalSection(
                          'Maintenance Tips',
                          Icons.healing_rounded,
                          accentYellow,
                          Column(
                            children:
                                (detailedData['maintenance'] as List<String>)
                                    .map((tip) => _buildTipItem(tip))
                                    .toList(),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Styling suggestions
                        _buildModalSection(
                          'Styling Suggestions',
                          Icons.style_rounded,
                          accentRed,
                          Column(
                            children:
                                (detailedData['styling'] as List<String>)
                                    .map((tip) => _buildTipItem(tip))
                                    .toList(),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Action Button
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [primaryBlue, accentYellow],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Perfect! This is my hair color',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
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
      },
    );
  }

  Widget _buildModalSection(
    String title,
    IconData icon,
    Color color,
    Widget content,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
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
              color: primaryBlue,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.poppins(fontSize: 13, color: darkGray),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getDetailedHairColorData(String colorName) {
    switch (colorName) {
      case 'Black':
        return {
          'icon': '🖤',
          'subtitle': 'Classic and timeless beauty',
          'description':
              'Black hair is the ultimate classic choice. It\'s sleek, sophisticated, and works with virtually every skin tone. This timeless color requires minimal maintenance while providing maximum impact.',
          'maintenance': [
            'Use sulfate-free shampoo to maintain shine',
            'Apply deep conditioning treatments weekly',
            'Protect from sun exposure to prevent fading',
            'Touch up roots every 6-8 weeks',
          ],
          'styling': [
            'Sleek straight styles showcase the color beautifully',
            'Soft waves add movement and dimension',
            'Bold makeup colors complement the dramatic hair',
            'Silver accessories enhance the sophisticated look',
          ],
        };
      case 'Dark Brown':
        return {
          'icon': '🌰',
          'subtitle': 'Natural warmth and sophistication',
          'description':
              'Dark brown hair offers the perfect balance of natural beauty and sophistication. It\'s versatile, professional, and complements most skin tones with its warm undertones.',
          'maintenance': [
            'Use color-protecting shampoo and conditioner',
            'Regular deep conditioning prevents dryness',
            'Consider subtle highlights for dimension',
            'Root touch-ups needed every 6-8 weeks',
          ],
          'styling': [
            'Warm makeup tones enhance the natural beauty',
            'Gold jewelry complements the brown undertones',
            'Layered cuts add movement and texture',
            'Caramel highlights create beautiful dimension',
          ],
        };
      case 'Light Brown':
        return {
          'icon': '🥜',
          'subtitle': 'Soft and naturally beautiful',
          'description':
              'Light brown hair provides a soft, approachable look that\'s perfect for any occasion. It\'s natural-looking and works beautifully with both warm and cool undertones.',
          'maintenance': [
            'Gentle, color-safe products preserve the tone',
            'Regular trims maintain healthy-looking hair',
            'UV protection prevents unwanted brassiness',
            'Gloss treatments enhance shine and color',
          ],
          'styling': [
            'Neutral makeup tones work perfectly',
            'Both gold and silver jewelry are flattering',
            'Beach waves create a natural, effortless look',
            'Honey highlights add natural-looking brightness',
          ],
        };
      case 'Blonde':
        return {
          'icon': '🌾',
          'subtitle': 'Bright, youthful, and vibrant',
          'description':
              'Blonde hair is eye-catching and youthful. While it requires more maintenance, it offers endless styling possibilities and always makes a statement.',
          'maintenance': [
            'Purple shampoo prevents brassiness',
            'Deep conditioning treatments are essential',
            'Regular salon visits for toning',
            'Heat protection is crucial for styling',
          ],
          'styling': [
            'Cool-toned makeup prevents washing out',
            'Silver jewelry enhances the bright color',
            'Textured styles add dimension and movement',
            'Regular toning maintains color vibrancy',
          ],
        };
      case 'Red':
        return {
          'icon': '🔥',
          'subtitle': 'Bold, unique, and expressive',
          'description':
              'Red hair is for those who want to make a statement. It\'s bold, unique, and incredibly expressive. This vibrant color requires special care but offers unmatched personality.',
          'maintenance': [
            'Color-protecting products are essential',
            'Cold water rinses prevent fading',
            'Regular color refresh treatments',
            'UV protection prevents color degradation',
          ],
          'styling': [
            'Green and gold makeup tones are complementary',
            'Gold jewelry enhances the warm undertones',
            'Avoid excessive heat styling',
            'Color-depositing masks maintain vibrancy',
          ],
        };
      case 'Gray':
        return {
          'icon': '⚪',
          'subtitle': 'Elegant and distinguished',
          'description':
              'Gray hair is sophisticated, modern, and incredibly elegant. It\'s a bold choice that represents confidence and style, perfect for those who embrace their natural beauty.',
          'maintenance': [
            'Purple shampoo maintains the tone',
            'Regular moisturizing treatments are key',
            'Gentle, sulfate-free products only',
            'Professional toning every 6-8 weeks',
          ],
          'styling': [
            'Bold makeup colors create striking contrast',
            'Silver jewelry enhances the sophisticated look',
            'Sleek styles showcase the beautiful color',
            'Proper cutting techniques are essential',
          ],
        };
      default:
        return {
          'icon': '✨',
          'subtitle': 'Beautiful and unique',
          'description': 'A beautiful hair color choice.',
          'maintenance': ['Regular care maintains beauty'],
          'styling': ['Style with confidence'],
        };
    }
  }
}

// Custom painter for hair strands effect
class HairStrandsPainter extends CustomPainter {
  final Color baseColor;

  HairStrandsPainter(this.baseColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = baseColor.withValues(alpha: 0.3)
          ..strokeWidth = 0.5
          ..style = PaintingStyle.stroke;

    // Draw subtle hair strand lines
    for (int i = 0; i < 8; i++) {
      final startX = (size.width / 8) * i;
      final path = Path();
      path.moveTo(startX, 0);
      path.quadraticBezierTo(
        startX + (size.width / 16),
        size.height / 2,
        startX + (size.width / 8),
        size.height,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

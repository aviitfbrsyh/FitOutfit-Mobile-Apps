import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/personalization_data.dart';

class Step4SkinTone extends StatefulWidget {
  final PersonalizationData data;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final VoidCallback onChanged;

  const Step4SkinTone({
    super.key,
    required this.data,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.onChanged,
  });

  @override
  State<Step4SkinTone> createState() => _Step4SkinToneState();
}

class _Step4SkinToneState extends State<Step4SkinTone>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Consistent colors with Step 3
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color softGray = Color(0xFFF8F9FA);

  String? _selectedUndertone;
  bool _showColorAnalysis = false;
  bool _showUndertoneGuide = false;
  bool _showVeinTest = false;
  String _selectedSkinToneName = '';
  String? _hoveredTone;

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
                    // Enhanced Header matching Step 3 style
                    _buildPremiumHeader(),
                    const SizedBox(height: 24),

                    // Interactive Analysis Tools
                    _buildInteractiveAnalysisSection(),
                    const SizedBox(height: 24),

                    // Main Skin Tone Selection
                    _buildSkinToneSelectionSection(),
                    const SizedBox(height: 24),

                    // Undertone Selection
                    if (widget.data.selectedSkinTone != null)
                      _buildUndertoneSection(),
                    if (widget.data.selectedSkinTone != null)
                      const SizedBox(height: 24),

                    // Color Recommendations
                    if (_selectedUndertone != null)
                      _buildColorRecommendationsSection(),
                    if (_selectedUndertone != null) const SizedBox(height: 24),

                    // Selected Skin Tone Info
                    if (widget.data.selectedSkinTone != null)
                      _buildSelectedSkinToneInfo(),
                    if (widget.data.selectedSkinTone != null)
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

  // Enhanced Header matching Step 3 design
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
              'Your Skin Tone',
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
            'Discover your perfect color palette and makeup recommendations based on your unique skin tone',
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

  // Interactive Analysis Section matching Step 3 style
  Widget _buildInteractiveAnalysisSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: softGray.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.science_rounded, color: primaryBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                'Skin Tone Analysis Tools',
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
            'Use our interactive tools to accurately determine your skin tone and undertone',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Analysis tools grid
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Vein Test',
                  Icons.bloodtype_rounded,
                  primaryBlue,
                  () => setState(() => _showVeinTest = !_showVeinTest),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Undertone Guide',
                  Icons.colorize_rounded,
                  accentYellow,
                  () => setState(
                    () => _showUndertoneGuide = !_showUndertoneGuide,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            'Color Analysis',
            Icons.auto_awesome_rounded,
            accentRed,
            () => setState(() => _showColorAnalysis = !_showColorAnalysis),
            fullWidth: true,
          ),

          // Expandable guides
          if (_showVeinTest) ...[
            const SizedBox(height: 20),
            _buildVeinTestGuide(),
          ],
          if (_showUndertoneGuide) ...[
            const SizedBox(height: 20),
            _buildUndertoneGuide(),
          ],
          if (_showColorAnalysis) ...[
            const SizedBox(height: 20),
            _buildColorAnalysisGuide(),
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

  Widget _buildVeinTestGuide() {
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
            'Wrist Vein Test',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Look at the veins on your wrist in natural light:',
            style: GoogleFonts.poppins(fontSize: 14, color: mediumGray),
          ),
          const SizedBox(height: 16),
          _buildVeinTestOption(
            'Blue/Purple Veins',
            'Cool Undertone',
            primaryBlue,
          ),
          _buildVeinTestOption('Green Veins', 'Warm Undertone', accentYellow),
          _buildVeinTestOption(
            'Blue-Green Veins',
            'Neutral Undertone',
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildVeinTestOption(String veinColor, String undertone, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
            child: Icon(Icons.bloodtype, color: color, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  veinColor,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: darkGray,
                  ),
                ),
                Text(
                  undertone,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUndertoneGuide() {
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
            'Understanding Undertones',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 16),
          _buildUndertoneInfo('Cool', 'Pink, red, or blue base', primaryBlue),
          _buildUndertoneInfo(
            'Warm',
            'Yellow, peach, or golden base',
            accentYellow,
          ),
          _buildUndertoneInfo('Neutral', 'Mix of cool and warm', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildUndertoneInfo(String type, String description, Color color) {
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
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
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

  Widget _buildColorAnalysisGuide() {
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
            'Color Analysis Methods',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Additional methods to determine your undertone:',
            style: GoogleFonts.poppins(fontSize: 14, color: mediumGray),
          ),
          const SizedBox(height: 16),
          _buildAnalysisMethod(
            'Sun Reaction',
            'Burn easily? Cool. Tan easily? Warm.',
          ),
          _buildAnalysisMethod(
            'Jewelry Test',
            'Silver looks better? Cool. Gold looks better? Warm.',
          ),
          _buildAnalysisMethod(
            'White Test',
            'Bright white vs off-white against your skin',
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisMethod(String method, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: accentRed,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: darkGray,
                  ),
                ),
                const SizedBox(height: 4),
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

  // Main Skin Tone Selection Section
  Widget _buildSkinToneSelectionSection() {
    bool hasSelection = widget.data.selectedSkinTone != null;

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
                      ? 'Skin Tone: $_selectedSkinToneName'
                      : 'Choose Your Skin Tone',
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

          // Skin tone grid
          _buildSkinToneGrid(),
        ],
      ),
    );
  }

  Widget _buildSkinToneGrid() {
    final skinTones = [
      {
        'name': 'Fair',
        'description': 'Light complexion with cool undertones',
        'colors': [Color(0xFFFEF7F0), Color(0xFFFAE6D3), Color(0xFFF7DCC6)],
        'emoji': '🌸',
        'characteristics': [
          'Burns easily',
          'Rarely tans',
          'Pink/red undertones visible',
        ],
        'color': primaryBlue,
      },
      {
        'name': 'Light',
        'description': 'Light to medium with mixed undertones',
        'colors': [Color(0xFFEFDBCD), Color(0xFFE8CFC0), Color(0xFFE0C3B3)],
        'emoji': '🌼',
        'characteristics': [
          'Burns then tans',
          'Gradual tanning',
          'Mixed undertones',
        ],
        'color': accentYellow,
      },
      {
        'name': 'Medium',
        'description': 'Medium complexion with warm undertones',
        'colors': [Color(0xFFD4A574), Color(0xFFCA9A68), Color(0xFFC08F5C)],
        'emoji': '🌻',
        'characteristics': ['Tans well', 'Rarely burns', 'Golden undertones'],
        'color': accentRed,
      },
      {
        'name': 'Olive',
        'description': 'Medium with green undertones',
        'colors': [Color(0xFFB5966F), Color(0xFFAA8B64), Color(0xFF9F8059)],
        'emoji': '🫒',
        'characteristics': [
          'Tans easily',
          'Green/yellow undertones',
          'Mediterranean heritage',
        ],
        'color': Colors.green,
      },
      {
        'name': 'Deep',
        'description': 'Rich complexion with warm undertones',
        'colors': [Color(0xFF8B5A3C), Color(0xFF7A4F37), Color(0xFF694432)],
        'emoji': '🌰',
        'characteristics': [
          'Natural sun protection',
          'Rich undertones',
          'Rarely burns',
        ],
        'color': Colors.brown,
      },
      {
        'name': 'Dark',
        'description': 'Deep complexion with rich undertones',
        'colors': [Color(0xFF5D3317), Color(0xFF4A2B17), Color(0xFF3C2318)],
        'emoji': '🍫',
        'characteristics': [
          'High melanin',
          'Natural UV protection',
          'Rich golden/red undertones',
        ],
        'color': Colors.deepPurple,
      },
    ];

    return Column(
      children: [
        // First row - 2 cards
        Row(
          children: [
            Expanded(child: _buildSkinToneCard(skinTones[0])),
            const SizedBox(width: 12),
            Expanded(child: _buildSkinToneCard(skinTones[1])),
          ],
        ),
        const SizedBox(height: 12),
        // Second row - 2 cards
        Row(
          children: [
            Expanded(child: _buildSkinToneCard(skinTones[2])),
            const SizedBox(width: 12),
            Expanded(child: _buildSkinToneCard(skinTones[3])),
          ],
        ),
        const SizedBox(height: 12),
        // Third row - 2 cards
        Row(
          children: [
            Expanded(child: _buildSkinToneCard(skinTones[4])),
            const SizedBox(width: 12),
            Expanded(child: _buildSkinToneCard(skinTones[5])),
          ],
        ),
      ],
    );
  }

  Widget _buildSkinToneCard(Map<String, dynamic> skinTone) {
    List<Color> colors = skinTone['colors'] as List<Color>;
    String name = skinTone['name'] as String;
    bool isSelected = _selectedSkinToneName == name;
    bool isHovered = _hoveredTone == name;
    Color toneColor = skinTone['color'] as Color;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() {
          widget.data.selectedSkinTone = colors.first;
          _selectedSkinToneName = name;
          _selectedUndertone = null;
          _hoveredTone = null;
        });
        widget.onChanged();
        _showDetailedSkinToneModal(skinTone);
      },
      onTapDown: (_) => setState(() => _hoveredTone = name),
      onTapCancel: () => setState(() => _hoveredTone = null),
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
                      toneColor.withValues(alpha: 0.15),
                      toneColor.withValues(alpha: 0.05),
                    ]
                    : isHovered
                    ? [
                      toneColor.withValues(alpha: 0.1),
                      toneColor.withValues(alpha: 0.05),
                    ]
                    : [Colors.white, Colors.grey.withValues(alpha: 0.02)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isSelected
                    ? toneColor.withValues(alpha: 0.4)
                    : isHovered
                    ? toneColor.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
                      ? toneColor.withValues(alpha: 0.15)
                      : isHovered
                      ? toneColor.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 10 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Emoji
            Text(
              skinTone['emoji'] as String,
              style: TextStyle(fontSize: isSelected ? 28 : 24),
            ),

            // Color gradient display
            Container(
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
            ),

            // Text section
            Column(
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? toneColor : darkGray,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  skinTone['description'] as String,
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
                          color: toneColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: toneColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 10,
                              color: toneColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Selected',
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: toneColor,
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

  Widget _buildUndertoneSection() {
    final undertones = [
      {
        'name': 'Cool',
        'description': 'Pink, red, or blue undertones',
        'color': primaryBlue,
        'characteristics': [
          'Burns easily',
          'Silver jewelry looks better',
          'Blue/purple veins',
        ],
      },
      {
        'name': 'Warm',
        'description': 'Yellow, peach, or golden undertones',
        'color': accentYellow,
        'characteristics': [
          'Tans easily',
          'Gold jewelry looks better',
          'Green veins',
        ],
      },
      {
        'name': 'Neutral',
        'description': 'Mix of cool and warm undertones',
        'color': Colors.purple,
        'characteristics': [
          'Burns then tans',
          'Both metals look good',
          'Blue-green veins',
        ],
      },
    ];

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
                  color: primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.colorize_rounded,
                  color: primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Your Undertone',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: darkGray,
                      ),
                    ),
                    Text(
                      'Select the undertone that best matches your skin',
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
          const SizedBox(height: 24),
          Column(
            children:
                undertones.map((undertone) {
                  bool isSelected = _selectedUndertone == undertone['name'];
                  Color undertoneColor = undertone['color'] as Color;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedUndertone = undertone['name'] as String;
                        // Add this line to save to data model:
                        widget.data.selectedUndertone =
                            undertone['name'] as String;
                      });
                      widget.onChanged();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? undertoneColor.withValues(alpha: 0.05)
                                : lightGray,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            isSelected
                                ? Border.all(color: undertoneColor, width: 2)
                                : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: undertoneColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: undertoneColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  undertone['name'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isSelected ? undertoneColor : darkGray,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  undertone['description'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: mediumGray,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children:
                                      (undertone['characteristics']
                                              as List<String>)
                                          .map((char) {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                char,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                  color: undertoneColor,
                                                ),
                                              ),
                                            );
                                          })
                                          .toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  // Color Recommendations Section
  Widget _buildColorRecommendationsSection() {
    Map<String, dynamic> colorData = _getColorRecommendations(
      _selectedUndertone!,
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
                      'Your Perfect Colors',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: darkGray,
                      ),
                    ),
                    Text(
                      'Colors that will make you shine',
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
          const SizedBox(height: 24),
          ...((colorData['categories']
                  as Map<String, List<Map<String, dynamic>>>)
              .entries
              .map((entry) {
                String category = entry.key;
                List<Map<String, dynamic>> colors = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: lightGray,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: darkGray,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children:
                            colors.map((colorInfo) {
                              return _buildColorSwatch(colorInfo);
                            }).toList(),
                      ),
                    ],
                  ),
                );
              })),
        ],
      ),
    );
  }

  Widget _buildColorSwatch(Map<String, dynamic> colorInfo) {
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: colorInfo['color'] as Color,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: (colorInfo['color'] as Color).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            colorInfo['name'] as String,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: darkGray,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getColorRecommendations(String undertone) {
    switch (undertone) {
      case 'Cool':
        return {
          'categories': {
            'Best Colors': [
              {'name': 'Navy Blue', 'color': Color(0xFF001F3F)},
              {'name': 'Emerald', 'color': Color(0xFF50C878)},
              {'name': 'Purple', 'color': Color(0xFF6A0DAD)},
              {'name': 'Pink', 'color': Color(0xFFFF69B4)},
              {'name': 'Silver', 'color': Color(0xFFC0C0C0)},
            ],
            'Neutral Colors': [
              {'name': 'White', 'color': Colors.white},
              {'name': 'Black', 'color': Colors.black},
              {'name': 'Cool Gray', 'color': Color(0xFF708090)},
              {'name': 'Charcoal', 'color': Color(0xFF36454F)},
            ],
          },
          'makeup': {
            'Lipstick': 'Berry, plum, rose, cherry red',
            'Blush': 'Pink, rose, berry tones',
            'Eyeshadow': 'Cool browns, purples, blues, silvers',
            'Foundation': 'Pink or neutral undertones',
          },
        };
      case 'Warm':
        return {
          'categories': {
            'Best Colors': [
              {'name': 'Coral', 'color': Color(0xFFFF7F50)},
              {'name': 'Gold', 'color': Color(0xFFFFD700)},
              {'name': 'Olive', 'color': Color(0xFF808000)},
              {'name': 'Orange', 'color': Color(0xFFFF8C00)},
              {'name': 'Rust', 'color': Color(0xFFB7410E)},
            ],
            'Neutral Colors': [
              {'name': 'Cream', 'color': Color(0xFFF5F5DC)},
              {'name': 'Warm Gray', 'color': Color(0xFF8B8680)},
              {'name': 'Camel', 'color': Color(0xFFC19A6B)},
              {'name': 'Chocolate', 'color': Color(0xFFD2691E)},
            ],
          },
          'makeup': {
            'Lipstick': 'Coral, peach, warm red, orange-red',
            'Blush': 'Peach, apricot, warm pink',
            'Eyeshadow': 'Warm browns, golds, corals, oranges',
            'Foundation': 'Yellow or golden undertones',
          },
        };
      case 'Neutral':
        return {
          'categories': {
            'Best Colors': [
              {'name': 'Teal', 'color': Color(0xFF008080)},
              {'name': 'Jade', 'color': Color(0xFF00A86B)},
              {'name': 'Dusty Rose', 'color': Color(0xFFDCCDCD)},
              {'name': 'Soft Blue', 'color': Color(0xFF87CEEB)},
              {'name': 'Mauve', 'color': Color(0xFFE0B0FF)},
            ],
            'Neutral Colors': [
              {'name': 'Off-White', 'color': Color(0xFFFAF0E6)},
              {'name': 'True Gray', 'color': Color(0xFF808080)},
              {'name': 'Taupe', 'color': Color(0xFF483C32)},
              {'name': 'Mushroom', 'color': Color(0xFFC2B5A7)},
            ],
          },
          'makeup': {
            'Lipstick': 'Nude, mauve, soft pink, berry',
            'Blush': 'Soft pink, peach-pink, rosy brown',
            'Eyeshadow': 'Neutral browns, taupes, soft purples',
            'Foundation': 'Neutral undertones',
          },
        };
      default:
        return {
          'categories': {
            'Universal Colors': [
              {'name': 'Navy', 'color': Color(0xFF000080)},
              {'name': 'White', 'color': Colors.white},
              {'name': 'Black', 'color': Colors.black},
              {'name': 'Gray', 'color': Colors.grey},
            ],
          },
          'makeup': {'Foundation': 'Match your skin tone'},
        };
    }
  }

  // Benefits section matching Step 3 style
  Widget _buildBenefitsSection() {
    final benefits = [
      {
        'icon': Icons.palette_rounded,
        'title': 'Perfect Colors',
        'desc': 'Colors that enhance your natural beauty',
      },
      {
        'icon': Icons.auto_awesome_rounded,
        'title': 'Makeup Match',
        'desc': 'Foundation and cosmetics recommendations',
      },
      {
        'icon': Icons.style_rounded,
        'title': 'Style Guide',
        'desc': 'Wardrobe colors that flatter you',
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
                Icon(Icons.auto_awesome, color: accentYellow, size: 24),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Why Skin Tone Analysis Matters',
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

  // Pro Tips section matching Step 3 style
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
                  'Natural daylight is best for skin tone assessment. Check near a window during the day for the most accurate results.',
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

  Widget _buildSelectedSkinToneInfo() {
    String selectedTone = _selectedSkinToneName;
    Map<String, dynamic> toneData = _getSkinToneData(selectedTone);

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
                      '$selectedTone skin tone selected',
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
                  toneData['description'] as String,
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
                      (toneData['features'] as List<String>).map((feature) {
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

  Map<String, dynamic> _getSkinToneData(String tone) {
    switch (tone) {
      case 'Fair':
        return {
          'description':
              'Your fair skin tone has delicate undertones that work beautifully with cool and soft colors. We\'ll recommend shades that complement your natural luminosity.',
          'features': [
            'Cool undertones',
            'Delicate complexion',
            'Light colors',
            'Soft pastels',
          ],
        };
      case 'Light':
        return {
          'description':
              'Your light skin tone offers versatility with mixed undertones. You can wear both warm and cool colors depending on your specific undertone.',
          'features': [
            'Mixed undertones',
            'Versatile palette',
            'Medium saturation',
            'Balanced tones',
          ],
        };
      case 'Medium':
        return {
          'description':
              'Your medium skin tone typically has warm golden undertones that work wonderfully with rich, vibrant colors and earth tones.',
          'features': [
            'Warm undertones',
            'Golden base',
            'Rich colors',
            'Earth tones',
          ],
        };
      case 'Olive':
        return {
          'description':
              'Your olive skin tone has unique green undertones that look stunning in jewel tones and sophisticated earth colors.',
          'features': [
            'Green undertones',
            'Jewel tones',
            'Earth colors',
            'Sophisticated palette',
          ],
        };
      case 'Deep':
        return {
          'description':
              'Your deep skin tone has rich undertones that are enhanced by bold, saturated colors and metallic accents.',
          'features': [
            'Rich undertones',
            'Bold colors',
            'Metallics',
            'Saturated tones',
          ],
        };
      case 'Dark':
        return {
          'description':
              'Your dark skin tone has beautiful deep undertones that shine in vibrant colors, rich jewel tones, and bright accents.',
          'features': [
            'Deep undertones',
            'Vibrant colors',
            'Jewel tones',
            'Bright accents',
          ],
        };
      default:
        return {
          'description': 'Every skin tone is unique and beautiful.',
          'features': ['Confidence'],
        };
    }
  }

  void _showDetailedSkinToneModal(Map<String, dynamic> skinTone) {
    String toneName = skinTone['name'] as String;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) => _buildDetailedSkinToneModal(toneName),
    );
  }

  Widget _buildDetailedSkinToneModal(String toneName) {
    Map<String, dynamic> detailedData = _getDetailedSkinToneData(toneName);

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
                        // Header with emoji and title
                        Row(
                          children: [
                            Text(
                              detailedData['emoji'] as String,
                              style: const TextStyle(fontSize: 48),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$toneName Skin Tone',
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

                        // Key Characteristics
                        _buildModalSection(
                          'Key Characteristics',
                          Icons.star_rounded,
                          primaryBlue,
                          Column(
                            children:
                                (detailedData['characteristics']
                                        as List<String>)
                                    .map(
                                      (char) => _buildCharacteristicItem(char),
                                    )
                                    .toList(),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Best Colors Palette
                        _buildModalSection(
                          'Your Perfect Color Palette',
                          Icons.palette_rounded,
                          accentYellow,
                          Column(
                            children: [
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children:
                                    (detailedData['colorPalette']
                                            as List<Map<String, dynamic>>)
                                        .map(
                                          (color) =>
                                              _buildDetailedColorSwatch(color),
                                        )
                                        .toList(),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: accentYellow.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  detailedData['colorTip'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: darkGray,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Celebrity Inspiration
                        _buildModalSection(
                          'Celebrity Inspiration',
                          Icons.star_border_rounded,
                          Colors.purple,
                          Column(
                            children: [
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children:
                                    (detailedData['celebrities']
                                            as List<String>)
                                        .map(
                                          (celebrity) =>
                                              _buildCelebrityChip(celebrity),
                                        )
                                        .toList(),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'These celebrities share similar skin tones and can serve as great style inspiration!',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: mediumGray,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Care Tips
                        _buildModalSection(
                          'Skincare & Sun Protection',
                          Icons.health_and_safety_rounded,
                          Colors.green,
                          Column(
                            children:
                                (detailedData['careTips'] as List<String>)
                                    .map((tip) => _buildCareTip(tip))
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
                              'Perfect! This is my skin tone',
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

  Widget _buildCharacteristicItem(String characteristic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              characteristic,
              style: GoogleFonts.poppins(fontSize: 13, color: darkGray),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedColorSwatch(Map<String, dynamic> colorInfo) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: colorInfo['color'] as Color,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: (colorInfo['color'] as Color).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            colorInfo['name'] as String,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: darkGray,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrityChip(String celebrity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Text(
        celebrity,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.purple,
        ),
      ),
    );
  }

  Widget _buildCareTip(String tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.tips_and_updates, color: Colors.green, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.poppins(fontSize: 12, color: darkGray),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getDetailedSkinToneData(String toneName) {
    switch (toneName) {
      case 'Fair':
        return {
          'emoji': '🌸',
          'subtitle': 'Delicate and luminous complexion',
          'description':
              'Fair skin tones are characterized by their delicate, porcelain-like appearance with subtle pink or blue undertones. This skin tone reflects light beautifully and has a natural luminosity that works wonderfully with soft, muted colors and cool tones.',
          'characteristics': [
            'Burns easily in the sun, requires high SPF protection',
            'Often has visible veins showing blue or purple',
            'Natural pink or red flush in cheeks',
            'May have freckles or light pigmentation',
            'Cool undertones dominate the complexion',
            'Translucent quality that reflects light beautifully',
          ],
          'colorPalette': [
            {'name': 'Navy Blue', 'color': Color(0xFF001F3F)},
            {'name': 'Soft Pink', 'color': Color(0xFFFFB6C1)},
            {'name': 'Lavender', 'color': Color(0xFFE6E6FA)},
            {'name': 'Mint Green', 'color': Color(0xFF98FB98)},
            {'name': 'Silver', 'color': Color(0xFFC0C0C0)},
            {'name': 'Icy Blue', 'color': Color(0xFFB0E0E6)},
          ],
          'colorTip':
              'Stick to cool undertones and avoid warm yellows or oranges that can wash you out.',
          'celebrities': [
            'Anne Hathaway',
            'Emma Stone',
            'Nicole Kidman',
            'Cate Blanchett',
            'Amy Adams',
          ],
          'careTips': [
            'Always use SPF 30+ sunscreen, even on cloudy days',
            'Choose gentle, fragrance-free skincare products',
            'Use a hydrating primer to enhance natural luminosity',
            'Consider tinted moisturizer for light, natural coverage',
            'Avoid over-exfoliation which can cause irritation',
          ],
        };
      case 'Light':
        return {
          'emoji': '🌼',
          'subtitle': 'Versatile and balanced complexion',
          'description':
              'Light skin tones offer beautiful versatility with the ability to wear both warm and cool colors depending on your specific undertones. This adaptable complexion can tan gradually and works with a wide range of color palettes.',
          'characteristics': [
            'Burns initially but can develop a light tan',
            'Neutral to mixed undertones',
            'Veins appear blue-green',
            'Can wear both gold and silver jewelry',
            'Natural color ranges from peachy to neutral',
            'Moderate sun sensitivity',
          ],
          'colorPalette': [
            {'name': 'Soft Coral', 'color': Color(0xFFFF6B6B)},
            {'name': 'Dusty Rose', 'color': Color(0xFFDCCDCD)},
            {'name': 'Sage Green', 'color': Color(0xFF9CAF88)},
            {'name': 'Warm Gray', 'color': Color(0xFF8B8680)},
            {'name': 'Champagne', 'color': Color(0xFFF7E7CE)},
            {'name': 'Soft Teal', 'color': Color(0xFF4DB6AC)},
          ],
          'colorTip':
              'You have the flexibility to wear both warm and cool colors - experiment to find your favorites!',
          'celebrities': [
            'Taylor Swift',
            'Reese Witherspoon',
            'Natalie Portman',
            'Scarlett Johansson',
          ],
          'careTips': [
            'Use SPF 25-30 for daily protection',
            'Gradual tanning products work well for your skin tone',
            'Both warm and cool-toned products can work',
            'Test makeup in natural light to find your best match',
            'Moisturize regularly to maintain even tone',
          ],
        };
      case 'Medium':
        return {
          'emoji': '🌻',
          'subtitle': 'Warm and golden complexion',
          'description':
              'Medium skin tones typically feature beautiful warm, golden undertones that create a natural radiance. This complexion tans well and looks stunning in rich, vibrant colors and warm earth tones that complement the natural golden glow.',
          'characteristics': [
            'Tans easily with minimal burning',
            'Warm golden or yellow undertones',
            'Green-tinted veins',
            'Gold jewelry enhances natural warmth',
            'Natural olive or golden hue',
            'Good natural sun protection',
          ],
          'colorPalette': [
            {'name': 'Warm Coral', 'color': Color(0xFFFF5722)},
            {'name': 'Golden Yellow', 'color': Color(0xFFFFD700)},
            {'name': 'Terracotta', 'color': Color(0xFFE2725B)},
            {'name': 'Olive Green', 'color': Color(0xFF808000)},
            {'name': 'Rust Orange', 'color': Color(0xFFB7410E)},
            {'name': 'Warm Brown', 'color': Color(0xFFA0522D)},
          ],
          'colorTip':
              'Embrace warm, rich colors that enhance your natural golden glow and avoid icy or very cool tones.',
          'celebrities': [
            'Jessica Alba',
            'Eva Longoria',
            'Priyanka Chopra',
            'Jennifer Lopez',
          ],
          'careTips': [
            'SPF 20-25 is usually sufficient for daily wear',
            'Use warm-toned skincare and makeup products',
            'Bronze and gold makeup enhance your natural warmth',
            'Coconut or argan oil work well for skin hydration',
            'Embrace your natural glow with minimal foundation',
          ],
        };
      case 'Olive':
        return {
          'emoji': '🫒',
          'subtitle': 'Sophisticated and unique complexion',
          'description':
              'Olive skin tones feature distinctive green undertones that create a sophisticated, Mediterranean-inspired complexion. This unique skin tone looks absolutely stunning in jewel tones and rich earth colors that complement the natural green undertones.',
          'characteristics': [
            'Distinctive green or yellow-green undertones',
            'Often associated with Mediterranean heritage',
            'Tans beautifully with minimal burning',
            'Can appear slightly golden or gray-green',
            'Both warm and cool colors can work',
            'Natural protection against sun damage',
          ],
          'colorPalette': [
            {'name': 'Forest Green', 'color': Color(0xFF228B22)},
            {'name': 'Deep Burgundy', 'color': Color(0xFF800020)},
            {'name': 'Rich Navy', 'color': Color(0xFF000080)},
            {'name': 'Warm Camel', 'color': Color(0xFFC19A6B)},
            {'name': 'Eggplant', 'color': Color(0xFF614051)},
            {'name': 'Golden Bronze', 'color': Color(0xFFCD7F32)},
          ],
          'colorTip':
              'Jewel tones and rich, sophisticated colors are your best friends - they enhance your unique undertones beautifully.',
          'celebrities': [
            'Sofia Vergara',
            'Kim Kardashian',
            'Salma Hayek',
            'Jessica Biel',
          ],
          'careTips': [
            'SPF 15-25 for daily protection',
            'Look for olive-toned or yellow-based foundations',
            'Rich, warm colors enhance your natural beauty',
            'Avoid overly pink or ashy tones in makeup',
            'Embrace earth-toned and jewel-toned clothing',
          ],
        };
      case 'Deep':
        return {
          'emoji': '🌰',
          'subtitle': 'Rich and radiant complexion',
          'description':
              'Deep skin tones showcase rich, warm undertones that create a naturally radiant and glowing complexion. This beautiful skin tone is enhanced by bold, saturated colors and metallic accents that complement the natural depth and richness.',
          'characteristics': [
            'Rich brown complexion with warm undertones',
            'Natural protection from UV damage',
            'Red, golden, or chocolate undertones',
            'Rarely burns, tans beautifully',
            'Glowing, healthy appearance',
            'Can wear bold, saturated colors well',
          ],
          'colorPalette': [
            {'name': 'Rich Purple', 'color': Color(0xFF4B0082)},
            {'name': 'Emerald Green', 'color': Color(0xFF50C878)},
            {'name': 'Golden Yellow', 'color': Color(0xFFFFD700)},
            {'name': 'Deep Orange', 'color': Color(0xFFFF4500)},
            {'name': 'Royal Blue', 'color': Color(0xFF4169E1)},
            {'name': 'Rich Burgundy', 'color': Color(0xFF800020)},
          ],
          'colorTip':
              'Bold, saturated colors and metallics look absolutely stunning on your rich complexion.',
          'celebrities': [
            'Lupita Nyong\'o',
            'Issa Rae',
            'Danai Gurira',
            'Michaela Coel',
          ],
          'careTips': [
            'SPF 15-20 for basic daily protection',
            'Look for foundations with rich, warm undertones',
            'Bold colors and metallics enhance your natural beauty',
            'Avoid ashy or overly cool-toned products',
            'Embrace vibrant, saturated clothing colors',
          ],
        };
      case 'Dark':
        return {
          'emoji': '🍫',
          'subtitle': 'Deep and luminous complexion',
          'description':
              'Dark skin tones feature beautiful deep complexions with rich golden, red, or chocolate undertones. This stunning skin tone has natural luminosity and looks absolutely magnificent in vibrant colors, rich jewel tones, and bright accent colors.',
          'characteristics': [
            'Deep, rich complexion with high melanin',
            'Excellent natural UV protection',
            'Golden, red, or blue undertones',
            'Natural luminosity and glow',
            'Very rarely burns',
            'Stunning in bright, vibrant colors',
          ],
          'colorPalette': [
            {'name': 'Bright Fuchsia', 'color': Color(0xFFFF1493)},
            {'name': 'Electric Blue', 'color': Color(0xFF0080FF)},
            {'name': 'Vibrant Orange', 'color': Color(0xFFFF6600)},
            {'name': 'Deep Emerald', 'color': Color(0xFF006A4E)},
            {'name': 'Rich Gold', 'color': Color(0xFFFFD700)},
            {'name': 'Royal Purple', 'color': Color(0xFF7851A9)},
          ],
          'colorTip':
              'Vibrant, bright colors and rich jewel tones celebrate your beautiful deep complexion magnificently.',
          'celebrities': [
            'Lupita Nyong\'o',
            'Aja Naomi King',
            'Kiki Layne',
            'Michaela Coel',
          ],
          'careTips': [
            'SPF 15 for daily protection (still important!)',
            'Seek foundations with deep, rich undertones',
            'Bright, vibrant colors showcase your natural beauty',
            'Avoid muddy or ashy tones',
            'Celebrate your gorgeous deep complexion with bold choices',
          ],
        };
      default:
        return {
          'emoji': '✨',
          'subtitle': 'Beautiful and unique',
          'description': 'Every skin tone is beautiful and unique.',
          'characteristics': ['Confidence is your best accessory'],
          'colorPalette': [],
          'colorTip': 'Embrace your unique beauty!',
          'celebrities': [],
          'careTips': ['Love and celebrate your skin'],
        };
    }
  }
}

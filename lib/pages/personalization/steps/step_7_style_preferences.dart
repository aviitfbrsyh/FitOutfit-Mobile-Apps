import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/personalization_data.dart';

class Step7StylePreferences extends StatefulWidget {
  final PersonalizationData data;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final VoidCallback onChanged;

  const Step7StylePreferences({
    super.key,
    required this.data,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.onChanged,
  });

  @override
  State<Step7StylePreferences> createState() => _Step7StylePreferencesState();
}

class _Step7StylePreferencesState extends State<Step7StylePreferences>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Consistent colors with previous steps
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color softGray = Color(0xFFF8F9FA);

  String? _hoveredStyle;
  bool _showStyleGuide = false;
  bool _showMixingTips = false;
  bool _showTrendGuide = false;

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
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    return FadeTransition(
      opacity: widget.fadeAnimation,
      child: SlideTransition(
        position: widget.slideAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - safeAreaTop - safeAreaBottom - 80,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16, // Reduced from 20
                  4, // Reduced from 8
                  16, // Reduced from 20
                  4, // Reduced from 8
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Enhanced Header matching previous steps style
                    _buildPremiumHeader(),
                    const SizedBox(height: 16), // Reduced from 20
                    // Interactive Style Guide
                    _buildInteractiveGuideSection(),
                    const SizedBox(height: 16), // Reduced from 20
                    // Main Style Selection Section
                    _buildStyleSelectionSection(),
                    const SizedBox(height: 16), // Reduced from 20
                    // Selected Styles Summary
                    if (widget.data.selectedStyles.isNotEmpty)
                      _buildSelectedStylesInfo(),
                    if (widget.data.selectedStyles.isNotEmpty)
                      const SizedBox(height: 16), // Reduced from 20
                    // Style Mixing Recommendations
                    if (widget.data.selectedStyles.length > 1)
                      _buildStyleMixingSection(),
                    if (widget.data.selectedStyles.length > 1)
                      const SizedBox(height: 16), // Reduced from 20
                    // Benefits Section
                    _buildBenefitsSection(),
                    const SizedBox(height: 12), // Reduced from 16
                    // Pro Tips Section
                    _buildProTipsSection(),

                    // Bottom spacing for safe area - fixed
                    SizedBox(height: safeAreaBottom + 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced Header matching previous steps design
  Widget _buildPremiumHeader() {
    return Container(
      padding: const EdgeInsets.all(24), // Reduced from 28
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
        borderRadius: BorderRadius.circular(20), // Reduced from 24
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.08),
            blurRadius: 24, // Reduced from 28
            offset: const Offset(0, 10), // Reduced from 12
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
                  width: 70, // Reduced from 80
                  height: 70, // Reduced from 80
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryBlue, accentYellow],
                      stops: [0.3, 0.9],
                    ),
                    borderRadius: BorderRadius.circular(35), // Reduced from 40
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withValues(alpha: 0.4),
                        blurRadius: 16, // Reduced from 20
                        offset: const Offset(0, 6), // Reduced from 8
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.style_rounded,
                    color: Colors.white,
                    size: 32, // Reduced from 36
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16), // Reduced from 20

          ShaderMask(
            shaderCallback:
                (bounds) => const LinearGradient(
                  colors: [primaryBlue, accentYellow],
                ).createShader(bounds),
            child: Text(
              'Your Style DNA',
              style: GoogleFonts.poppins(
                fontSize: 22, // Reduced from 26
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5, // Reduced from -0.6
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10), // Reduced from 12

          Text(
            'Choose multiple styles that reflect your personality and lifestyle preferences',
            style: GoogleFonts.poppins(
              fontSize: 14, // Reduced from 15
              color: darkGray.withValues(alpha: 0.8),
              height: 1.3, // Reduced from 1.4
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
      padding: const EdgeInsets.all(20), // Reduced from 24
      decoration: BoxDecoration(
        color: softGray.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18), // Reduced from 20
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: primaryBlue,
                size: 22,
              ), // Reduced from 24
              const SizedBox(width: 10), // Reduced from 12
              Flexible(
                // Added Flexible to prevent overflow
                child: Text(
                  'Style Discovery Guide',
                  style: GoogleFonts.poppins(
                    fontSize: 16, // Reduced from 18
                    fontWeight: FontWeight.w700,
                    color: darkGray,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Reduced from 16
          Text(
            'Learn about different style personalities and how to mix them perfectly',
            style: GoogleFonts.poppins(
              fontSize: 13, // Reduced from 14
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              height: 1.3, // Reduced from 1.4
            ),
          ),
          const SizedBox(height: 16), // Reduced from 20
          // Guide tools grid
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Style Guide',
                  Icons.book_rounded,
                  primaryBlue,
                  () => setState(() => _showStyleGuide = !_showStyleGuide),
                ),
              ),
              const SizedBox(width: 10), // Reduced from 12
              Expanded(
                child: _buildQuickActionButton(
                  'Mix Styles',
                  Icons.shuffle_rounded,
                  accentYellow,
                  () => setState(() => _showMixingTips = !_showMixingTips),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10), // Reduced from 12
          _buildQuickActionButton(
            'Trend Guide',
            Icons.trending_up_rounded,
            accentRed,
            () => setState(() => _showTrendGuide = !_showTrendGuide),
            fullWidth: true,
          ),

          // Expandable guides
          if (_showStyleGuide) ...[
            const SizedBox(height: 16), // Reduced from 20
            _buildStyleGuide(),
          ],
          if (_showMixingTips) ...[
            const SizedBox(height: 16), // Reduced from 20
            _buildMixingTipsGuide(),
          ],
          if (_showTrendGuide) ...[
            const SizedBox(height: 16), // Reduced from 20
            _buildTrendGuide(),
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
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 14,
        ), // Reduced padding
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14), // Reduced from 16
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16), // Reduced from 18
            const SizedBox(width: 6), // Reduced from 8
            Flexible(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11, // Reduced from 12
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis, // Added overflow handling
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleGuide() {
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
            'Understanding Style Types',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 16),
          _buildGuideItem(
            'Classic Style',
            'Timeless, elegant pieces that never go out of style',
            primaryBlue,
          ),
          _buildGuideItem(
            'Trendy Style',
            'Latest fashion trends and statement pieces',
            accentYellow,
          ),
          _buildGuideItem(
            'Minimalist Style',
            'Clean lines, neutral colors, and simple silhouettes',
            accentRed,
          ),
        ],
      ),
    );
  }

  Widget _buildMixingTipsGuide() {
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
            'How to Mix Styles',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 16),
          _buildGuideItem(
            'Balance is Key',
            'Mix 70% one style with 30% another for harmony',
            primaryBlue,
          ),
          _buildGuideItem(
            'Start Small',
            'Add accessories from different styles first',
            accentYellow,
          ),
          _buildGuideItem(
            'Common Elements',
            'Use color or silhouette to tie different styles together',
            accentRed,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendGuide() {
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
            'Current Fashion Trends',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 16),
          _buildGuideItem(
            'Sustainable Fashion',
            'Quality pieces that last and ethical brands',
            primaryBlue,
          ),
          _buildGuideItem(
            'Gender-Neutral',
            'Unisex pieces and fluid fashion expressions',
            accentYellow,
          ),
          _buildGuideItem(
            'Comfort First',
            'Athleisure and comfortable yet stylish pieces',
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

  // Main Style Selection Section
  Widget _buildStyleSelectionSection() {
    bool hasSelection = widget.data.selectedStyles.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24), // Reduced from 28
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
        borderRadius: BorderRadius.circular(24), // Reduced from 28
        boxShadow: [
          BoxShadow(
            color: (hasSelection ? accentYellow : primaryBlue).withValues(
              alpha: 0.12,
            ),
            blurRadius: 16, // Reduced from 20
            offset: const Offset(0, 6), // Reduced from 8
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ), // Reduced padding
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
              borderRadius: BorderRadius.circular(18), // Reduced from 20
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasSelection
                      ? Icons.check_circle_rounded
                      : Icons.style_rounded,
                  color: hasSelection ? accentYellow : primaryBlue,
                  size: 14, // Reduced from 16
                ),
                const SizedBox(width: 6),
                Flexible(
                  // Added Flexible to prevent overflow
                  child: Text(
                    hasSelection
                        ? '${widget.data.selectedStyles.length} Style${widget.data.selectedStyles.length > 1 ? 's' : ''} Selected'
                        : 'Choose Your Style Preferences',
                    style: GoogleFonts.poppins(
                      fontSize: 12, // Reduced from 13
                      fontWeight: FontWeight.w600,
                      color: hasSelection ? accentYellow : primaryBlue,
                    ),
                    overflow: TextOverflow.ellipsis, // Added overflow handling
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20), // Reduced from 24
          // Style selection grid
          _buildStyleGrid(),
        ],
      ),
    );
  }

  Widget _buildStyleGrid() {
    final styles = [
      {
        'name': 'Casual',
        'description': 'Relaxed & comfortable vibes',
        'icon': '👕',
        'characteristics': ['Comfortable', 'Relaxed', 'Everyday', 'Easy'],
        'brandColor': primaryBlue,
        'examples': [
          'Oversized hoodies with bike shorts',
          'Mom jeans with crop tops',
          'Sneakers (chunky dad shoes trend)',
          'Streetwear brands like Champion, Nike',
          'Tie-dye and vintage band tees',
          'Baggy cargo pants with fitted tops',
        ],
        'genZTrends': [
          'Y2K revival pieces',
          'Cottagecore aesthetics',
          'Thrift finds and vintage',
          'Gender-neutral basics',
        ],
        'occasions': ['Daily wear', 'Campus life', 'Hangouts', 'Weekend trips'],
        'keyPieces': [
          'Oversized blazers',
          'High-waisted jeans',
          'Platform sneakers',
          'Bucket hats',
        ],
        'personality': 'Effortless and approachable with a touch of rebellion',
      },
      {
        'name': 'Formal',
        'description': 'Professional & polished power',
        'icon': '👔',
        'characteristics': ['Professional', 'Polished', 'Structured', 'Sharp'],
        'brandColor': darkGray,
        'examples': [
          'Power suits with bold shoulders',
          'Midi blazer dresses',
          'Statement jewelry with professional attire',
          'Pointed-toe pumps or oxford shoes',
          'Structured handbags and briefcases',
          'Monochromatic color schemes',
        ],
        'genZTrends': [
          'Sustainable luxury brands',
          'Gender-fluid business wear',
          'Bold colors in conservative cuts',
          'Tech-integrated accessories',
        ],
        'occasions': [
          'Job interviews',
          'Board meetings',
          'Networking events',
          'Corporate dinners',
        ],
        'keyPieces': [
          'Tailored blazers',
          'Pencil skirts',
          'Statement watches',
          'Silk blouses',
        ],
        'personality':
            'Confident, ambitious, and ready to conquer the boardroom',
      },
      {
        'name': 'Trendy',
        'description': 'Fashion-forward & viral-worthy',
        'icon': '✨',
        'characteristics': ['Current', 'Bold', 'Statement', 'Instagram-ready'],
        'brandColor': accentYellow,
        'examples': [
          'Viral TikTok fashion challenges',
          'Neon colors and holographic materials',
          'Asymmetrical cuts and deconstructed pieces',
          'Platform boots and chunky jewelry',
          'Mix of textures: velvet, PVC, mesh',
          'Influencer-inspired outfit combinations',
        ],
        'genZTrends': [
          'Dopamine dressing',
          'Micro trends from social media',
          'Fast fashion dupes of luxury',
          'Maximalist layering',
        ],
        'occasions': [
          'Parties',
          'Music festivals',
          'Fashion events',
          'Social media content',
        ],
        'keyPieces': [
          'Statement earrings',
          'Colored hair accessories',
          'Graphic prints',
          'Tech wear',
        ],
        'personality': 'Bold trendsetter who\'s always ahead of the curve',
      },
      {
        'name': 'Classic',
        'description': 'Timeless & elegant sophistication',
        'icon': '⭐',
        'characteristics': ['Timeless', 'Elegant', 'Quality', 'Refined'],
        'brandColor': primaryBlue,
        'examples': [
          'Little black dress with modern twists',
          'Crisp white button-downs',
          'Tailored trench coats',
          'Pearl jewelry and gold accessories',
          'Cashmere sweaters and wool coats',
          'Leather handbags and loafers',
        ],
        'genZTrends': [
          'Quiet luxury movement',
          'Investment pieces over fast fashion',
          'Vintage designer finds',
          'Minimalist color palettes',
        ],
        'occasions': [
          'Formal dinners',
          'Art gallery openings',
          'Business casual',
          'Date nights',
        ],
        'keyPieces': [
          'Wool blazers',
          'Silk scarves',
          'Leather accessories',
          'Timeless jewelry',
        ],
        'personality': 'Sophisticated and refined with impeccable taste',
      },
      {
        'name': 'Bohemian',
        'description': 'Free-spirited & artistic soul',
        'icon': '🌸',
        'characteristics': ['Artistic', 'Free-spirited', 'Flowing', 'Natural'],
        'brandColor': accentRed,
        'examples': [
          'Flowing maxi dresses with floral prints',
          'Layered jewelry and stacked rings',
          'Fringe details and crochet pieces',
          'Earthy tones and natural fabrics',
          'Wide-brimmed hats and headbands',
          'Vintage band tees with flowing skirts',
        ],
        'genZTrends': [
          'Cottagecore and fairycore aesthetics',
          'Sustainable and ethical fashion',
          'Handmade and artisanal pieces',
          'Crystal and spiritual accessories',
        ],
        'occasions': [
          'Music festivals',
          'Art fairs',
          'Beach trips',
          'Outdoor events',
        ],
        'keyPieces': [
          'Peasant blouses',
          'Layered necklaces',
          'Ankle boots',
          'Tapestry bags',
        ],
        'personality': 'Creative free spirit who marches to their own beat',
      },
      {
        'name': 'Minimalist',
        'description': 'Clean & intentionally simple',
        'icon': '◽',
        'characteristics': ['Clean', 'Simple', 'Neutral', 'Intentional'],
        'brandColor': mediumGray,
        'examples': [
          'Neutral color palettes (beige, white, black)',
          'Clean-lined silhouettes',
          'High-quality basic pieces',
          'Minimal jewelry and accessories',
          'Capsule wardrobe essentials',
          'Geometric shapes and structured designs',
        ],
        'genZTrends': [
          'Scandinavian-inspired fashion',
          'Slow fashion movement',
          'Capsule wardrobe challenges',
          'Sustainable brand focus',
        ],
        'occasions': [
          'Work meetings',
          'Coffee dates',
          'Gallery visits',
          'Everyday wear',
        ],
        'keyPieces': [
          'White t-shirts',
          'Black trousers',
          'Neutral sweaters',
          'Simple sneakers',
        ],
        'personality': 'Intentional and mindful with a less-is-more philosophy',
      },
    ];

    return Column(
      children: [
        // First row - 2 cards
        Row(
          children: [
            Expanded(child: _buildStyleCard(styles[0])),
            const SizedBox(width: 12),
            Expanded(child: _buildStyleCard(styles[1])),
          ],
        ),
        const SizedBox(height: 12),
        // Second row - 2 cards
        Row(
          children: [
            Expanded(child: _buildStyleCard(styles[2])),
            const SizedBox(width: 12),
            Expanded(child: _buildStyleCard(styles[3])),
          ],
        ),
        const SizedBox(height: 12),
        // Third row - 2 cards
        Row(
          children: [
            Expanded(child: _buildStyleCard(styles[4])),
            const SizedBox(width: 12),
            Expanded(child: _buildStyleCard(styles[5])),
          ],
        ),
      ],
    );
  }

  Widget _buildStyleCard(Map<String, dynamic> style) {
    String name = style['name'] as String;
    bool isSelected = widget.data.selectedStyles.contains(name);
    bool isHovered = _hoveredStyle == name;
    Color brandColor = style['brandColor'] as Color;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() {
          if (isSelected) {
            widget.data.selectedStyles.remove(name);
          } else {
            widget.data.selectedStyles.add(name);
          }
          _hoveredStyle = null;
        });
        widget.onChanged();
        if (!isSelected) {
          _showDetailedStyleModal(style);
        }
      },
      onTapDown: (_) => setState(() => _hoveredStyle = name),
      onTapCancel: () => setState(() => _hoveredStyle = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 170, // Reduced from 180
        padding: const EdgeInsets.all(14), // Reduced from 16
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
          borderRadius: BorderRadius.circular(14), // Reduced from 16
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
              blurRadius: isSelected ? 8 : 4, // Reduced blur
              offset: const Offset(0, 2), // Reduced offset
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Style Icon
            Text(
              style['icon'] as String,
              style: TextStyle(fontSize: isSelected ? 28 : 24), // Reduced sizes
            ),

            // Text section
            Column(
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 13, // Reduced from 14
                    fontWeight: FontWeight.w700,
                    color: isSelected ? brandColor : darkGray,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 3), // Reduced from 4
                Text(
                  style['description'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 10, // Reduced from 11
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

            // Characteristics preview
            SizedBox(
              height: 28, // Reduced from 32
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 3, // Reduced from 4
                runSpacing: 3, // Reduced from 4
                children:
                    (style['characteristics'] as List<String>).take(2).map((
                      char,
                    ) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5, // Reduced from 6
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: brandColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            6,
                          ), // Reduced from 8
                        ),
                        child: Text(
                          char,
                          style: GoogleFonts.poppins(
                            fontSize: 8, // Reduced from 9
                            fontWeight: FontWeight.w600,
                            color: brandColor,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),

            // Selection indicator
            SizedBox(
              height: 18, // Reduced from 20
              child:
                  isSelected
                      ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6, // Reduced from 8
                          vertical: 2, // Reduced from 3
                        ),
                        decoration: BoxDecoration(
                          color: brandColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            8,
                          ), // Reduced from 10
                          border: Border.all(
                            color: brandColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 10, // Reduced from 12
                              color: brandColor,
                            ),
                            const SizedBox(width: 3), // Reduced from 4
                            Text(
                              'Selected',
                              style: GoogleFonts.poppins(
                                fontSize: 9, // Reduced from 10
                                fontWeight: FontWeight.w600,
                                color: brandColor,
                              ),
                            ),
                          ],
                        ),
                      )
                      : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6, // Reduced from 8
                          vertical: 2, // Reduced from 3
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            8,
                          ), // Reduced from 10
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          'Learn More',
                          style: GoogleFonts.poppins(
                            fontSize: 9, // Reduced from 10
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

  // Selected Styles Summary
  Widget _buildSelectedStylesInfo() {
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
                child: const Icon(
                  Icons.style_rounded,
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
                      'Your Style Mix',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: primaryBlue,
                      ),
                    ),
                    Text(
                      '${widget.data.selectedStyles.length} style${widget.data.selectedStyles.length > 1 ? 's' : ''} selected',
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
                  'Perfect! Your style combination creates a unique fashion personality.',
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
                      widget.data.selectedStyles.map((styleName) {
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
                            styleName,
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

  // Style Mixing Section
  Widget _buildStyleMixingSection() {
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
                  color: accentRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.shuffle_rounded,
                  color: accentRed,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Style Mixing Tips',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: darkGray,
                      ),
                    ),
                    Text(
                      'How to combine your selected styles beautifully',
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
                  'Mixing Recommendations',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: darkGray,
                  ),
                ),
                const SizedBox(height: 12),
                ..._getStyleMixingTips().map((tip) => _buildMixingTipItem(tip)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMixingTipItem(String tip) {
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
              color: accentRed,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
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

  // Benefits Section
  Widget _buildBenefitsSection() {
    final benefits = [
      {
        'icon': Icons.person_rounded,
        'title': 'Personal Expression',
        'desc': 'Styles that reflect your true self',
      },
      {
        'icon': Icons.trending_up_rounded,
        'title': 'Versatility',
        'desc': 'Mix and match for any occasion',
      },
      {
        'icon': Icons.favorite_rounded,
        'title': 'Confidence',
        'desc': 'Feel amazing in your unique style',
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
                const Icon(Icons.star_rounded, color: accentYellow, size: 24),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Why Style Matters',
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
          const Icon(Icons.lightbulb_outline, color: primaryBlue, size: 24),
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
                  'Start with one dominant style (70%) and accent with others (30%) for a balanced, authentic look.',
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
  List<String> _getStyleMixingTips() {
    List<String> selectedStyles = widget.data.selectedStyles;
    List<String> tips = [];

    if (selectedStyles.contains('Casual') &&
        selectedStyles.contains('Formal')) {
      tips.add('Mix blazers with jeans for smart-casual looks');
    }
    if (selectedStyles.contains('Classic') &&
        selectedStyles.contains('Trendy')) {
      tips.add('Add trendy accessories to classic pieces');
    }
    if (selectedStyles.contains('Minimalist') &&
        selectedStyles.contains('Bohemian')) {
      tips.add('Use neutral base with boho accents for balance');
    }

    // Add general tips
    tips.addAll([
      'Use accessories to transition between styles',
      'Keep colors coordinated across different style elements',
      'Mix textures and patterns thoughtfully for visual interest',
    ]);

    return tips.take(3).toList();
  }

  void _showDetailedStyleModal(Map<String, dynamic> style) {
    String styleName = style['name'] as String;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) => _buildDetailedStyleModal(styleName, style),
    );
  }

  Widget _buildDetailedStyleModal(
    String styleName,
    Map<String, dynamic> style,
  ) {
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
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    (style['brandColor'] as Color).withValues(
                                      alpha: 0.2,
                                    ),
                                    (style['brandColor'] as Color).withValues(
                                      alpha: 0.1,
                                    ),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  style['icon'] as String,
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$styleName Style',
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: darkGray,
                                    ),
                                  ),
                                  Text(
                                    style['personality'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: mediumGray,
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Characteristics
                        _buildModalSection(
                          'Key Characteristics',
                          primaryBlue,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                (style['characteristics'] as List<String>).map((
                                  char,
                                ) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primaryBlue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: primaryBlue.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      char,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: primaryBlue,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Gen Z Trends
                        _buildModalSection(
                          'Gen Z Trends 🔥',
                          accentYellow,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                (style['genZTrends'] as List<String>).map((
                                  trend,
                                ) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          margin: const EdgeInsets.only(top: 6),
                                          decoration: BoxDecoration(
                                            color: accentYellow,
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            trend,
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: darkGray,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Style Examples
                        _buildModalSection(
                          'Style Examples',
                          accentRed,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                (style['examples'] as List<String>).map((
                                  example,
                                ) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(
                                        alpha: 0.05,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: accentRed,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            example,
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: darkGray,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Key Pieces
                        _buildModalSection(
                          'Must-Have Pieces',
                          primaryBlue,
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children:
                                (style['keyPieces'] as List<String>).map((
                                  piece,
                                ) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
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
                                        color: primaryBlue.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      piece,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: primaryBlue,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Perfect Occasions
                        _buildModalSection(
                          'Perfect For',
                          mediumGray,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                (style['occasions'] as List<String>).map((
                                  occasion,
                                ) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: mediumGray.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      occasion,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: mediumGray,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Action Button
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            if (!widget.data.selectedStyles.contains(
                              styleName,
                            )) {
                              setState(() {
                                widget.data.selectedStyles.add(styleName);
                              });
                              widget.onChanged();
                            }
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors:
                                    widget.data.selectedStyles.contains(
                                          styleName,
                                        )
                                        ? [Colors.green, Colors.green.shade400]
                                        : [primaryBlue, accentYellow],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: (widget.data.selectedStyles.contains(
                                            styleName,
                                          )
                                          ? Colors.green
                                          : primaryBlue)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  widget.data.selectedStyles.contains(styleName)
                                      ? Icons.check_circle
                                      : Icons.add_circle,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.data.selectedStyles.contains(styleName)
                                      ? 'Perfect! This is My Style'
                                      : 'Add to My Style DNA',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
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
    Color color, {
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../models/personalization_data.dart';
import '../../home/home_page.dart';

class Step8Completion extends StatelessWidget {
  final PersonalizationData data;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const Step8Completion({
    super.key,
    required this.data,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color mediumGray = Color(0xFF6C757D);
  static const Color softBlue = Color(0xFFE8F4FD);
  static const Color softYellow = Color(0xFFFEF9E7);
  static const Color deepBlue = Color(0xFF1A365D);
  static const Color premiumGold = Color(0xFFD4AF37);
  static const Color fashionPink = Color(0xFFE91E63);
  static const Color mintGreen = Color(0xFF00BCD4);

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
        reverseTransitionDuration: const Duration(milliseconds: 400),
      ),
      (route) => false,
    );
  }

  // 🎨 Helper function untuk skin tone name
  String _getSkinToneName(Color? color) {
    if (color == null) return 'Not specified';

    // Convert to ARGB32 for comparison (modern approach)
    final colorValue =
        ((color.a * 255).round() << 24) |
        ((color.r * 255).round() << 16) |
        ((color.g * 255).round() << 8) |
        (color.b * 255).round();

    // Exact color matching berdasarkan step 4 skin tone colors
    switch (colorValue) {
      // Fair skin tones
      case 0xFFFEF7F0:
      case 0xFFFAE6D3:
      case 0xFFF7DCC6:
        return 'Fair 🌸';

      // Light skin tones
      case 0xFFEFDBCD:
      case 0xFFE8CFC0:
      case 0xFFE0C3B3:
        return 'Light 🌼';

      // Medium skin tones
      case 0xFFD4A574:
      case 0xFFCA9A68:
      case 0xFFC08F5C:
        return 'Medium 🌻';

      // Olive skin tones
      case 0xFFB5966F:
      case 0xFFAA8B64:
      case 0xFF9F8059:
        return 'Olive 🫒';

      // Deep skin tones
      case 0xFF8B5A3C:
      case 0xFF7A4F37:
      case 0xFF694432:
        return 'Deep 🌰';

      // Dark skin tones
      case 0xFF5D3317:
      case 0xFF4A2B17:
      case 0xFF3C2318:
        return 'Dark 🍫';

      default:
        // Fallback: Range-based detection using modern color accessors
        final red = (color.r * 255).round();
        final green = (color.g * 255).round();
        final blue = (color.b * 255).round();
        final brightness = (red + green + blue) / 3;

        if (brightness > 240) return 'Fair 🌸';
        if (brightness > 220) return 'Light 🌼';
        if (brightness > 180) return 'Medium 🌻';
        if (brightness > 140) return 'Olive 🫒';
        if (brightness > 100) return 'Deep 🌰';
        if (brightness > 60) return 'Dark 🍫';
        return 'Custom Tone 🎨';
    }
  }

  // 🌡️ Helper function untuk undertone name
  String _getUndertoneName(String? undertone) {
    if (undertone == null || undertone.isEmpty) return 'Not specified';

    switch (undertone) {
      case 'Cool':
        return 'Cool 🧊';
      case 'Warm':
        return 'Warm ☀️';
      case 'Neutral':
        return 'Neutral ⚖️';
      default:
        return undertone;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final isSmallScreen = screenWidth < 360;

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: Container(
          width: screenWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                softBlue.withValues(alpha: 0.1),
                Colors.white,
                softYellow.withValues(alpha: 0.08),
                fashionPink.withValues(alpha: 0.03),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : (isSmallScreen ? 12 : 16),
                vertical: isTablet ? 20 : 12,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                        isTablet
                            ? 1000
                            : screenWidth - (isSmallScreen ? 24 : 32),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Spectacular Success Header
                      _buildSpectacularHeader(context, isTablet, isSmallScreen),
                      SizedBox(height: isTablet ? 28 : 20),

                      // Fashion Journey Card
                      _buildFashionJourneyCard(
                        context,
                        isTablet,
                        isSmallScreen,
                      ),
                      SizedBox(height: isTablet ? 24 : 16),

                      // Profile Showcase Dashboard
                      _buildProfileShowcase(context, isTablet, isSmallScreen),
                      SizedBox(height: isTablet ? 20 : 14),

                      // Detailed Style Analysis
                      _buildDetailedStyleAnalysis(isTablet, isSmallScreen),
                      SizedBox(height: isTablet ? 24 : 16),

                      // Next Steps Fashion Hub
                      _buildFashionHub(context, isTablet, isSmallScreen),
                      SizedBox(height: isTablet ? 20 : 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpectacularHeader(
    BuildContext context,
    bool isTablet,
    bool isSmallScreen,
  ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 0),
      padding: EdgeInsets.all(isTablet ? 32 : (isSmallScreen ? 16 : 24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [deepBlue, primaryBlue, mintGreen.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isTablet ? 28 : 20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.3),
            blurRadius: isTablet ? 30 : 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: mintGreen.withValues(alpha: 0.15),
            blurRadius: isTablet ? 50 : 35,
            offset: const Offset(0, 20),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Animated Success Icon with Fixed Stars
          SizedBox(
            width: isTablet ? 120 : (isSmallScreen ? 100 : 110),
            height: isTablet ? 120 : (isSmallScreen ? 100 : 110),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Outer glow ring
                Container(
                  width: isTablet ? 120 : (isSmallScreen ? 90 : 100),
                  height: isTablet ? 120 : (isSmallScreen ? 90 : 100),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accentYellow.withValues(alpha: 0.25),
                        accentYellow.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Main icon container
                Container(
                  width: isTablet ? 90 : (isSmallScreen ? 70 : 80),
                  height: isTablet ? 90 : (isSmallScreen ? 70 : 80),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.white,
                        Colors.white.withValues(alpha: 0.95),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.4),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    size: isTablet ? 50 : (isSmallScreen ? 40 : 45),
                    color: primaryBlue,
                  ),
                ),
                // Fixed Floating stars with proper positioning
                ...List.generate(6, (index) {
                  final angles = [30, 90, 150, 210, 270, 330];
                  final radius =
                      isTablet ? 45.0 : (isSmallScreen ? 35.0 : 40.0);
                  final angle = angles[index] * math.pi / 180;
                  final x =
                      radius * (0.75 + 0.15 * (index % 2)) * math.cos(angle);
                  final y =
                      radius * (0.75 + 0.15 * (index % 2)) * math.sin(angle);

                  return Positioned(
                    left: (isTablet ? 60 : (isSmallScreen ? 50 : 55)) + x,
                    top: (isTablet ? 60 : (isSmallScreen ? 50 : 55)) + y,
                    child: Container(
                      width: isTablet ? 12 : (isSmallScreen ? 8 : 10),
                      height: isTablet ? 12 : (isSmallScreen ? 8 : 10),
                      decoration: BoxDecoration(
                        color:
                            [accentYellow, fashionPink, mintGreen][index % 3],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: [
                              accentYellow,
                              fashionPink,
                              mintGreen,
                            ][index % 3].withValues(alpha: 0.4),
                            blurRadius: 4,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        size: isTablet ? 6 : (isSmallScreen ? 4 : 5),
                        color: Colors.white,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: isTablet ? 20 : (isSmallScreen ? 12 : 16)),

          // Premium Typography with better text wrapping
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '✨ Style Profile Complete! ✨',
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 28 : (isSmallScreen ? 18 : 22),
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.4,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
          SizedBox(height: isTablet ? 10 : 6),

          // Elegant divider with brand accent - responsive
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: isTablet ? 30 : (isSmallScreen ? 15 : 20),
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentYellow, premiumGold],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 12 : (isSmallScreen ? 6 : 8),
                    ),
                    child: Text(
                      'Welcome to FitOutfit',
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 16 : (isSmallScreen ? 11 : 13),
                        color: Colors.white.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Container(
                  width: isTablet ? 30 : (isSmallScreen ? 15 : 20),
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [premiumGold, accentYellow],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isTablet ? 14 : 10),

          // Achievement badges with better wrapping
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 0),
            child: Wrap(
              spacing: isTablet ? 10 : (isSmallScreen ? 4 : 6),
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                _buildAchievementBadge(
                  'AI Powered',
                  Icons.psychology_rounded,
                  fashionPink,
                  isTablet,
                  isSmallScreen,
                ),
                _buildAchievementBadge(
                  'Trendy',
                  Icons.diamond_rounded,
                  accentYellow,
                  isTablet,
                  isSmallScreen,
                ),
                _buildAchievementBadge(
                  'Personalized',
                  Icons.auto_fix_high_rounded,
                  mintGreen,
                  isTablet,
                  isSmallScreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(
    String text,
    IconData icon,
    Color color,
    bool isTablet,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12 : (isSmallScreen ? 6 : 8),
        vertical: isTablet ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 6,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isTablet ? 14 : (isSmallScreen ? 9 : 11),
            color: Colors.white,
          ),
          SizedBox(width: 3),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 11 : (isSmallScreen ? 8 : 9),
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFashionJourneyCard(
    BuildContext context,
    bool isTablet,
    bool isSmallScreen,
  ) {
    return GestureDetector(
      onTap: () => _navigateToHome(context),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 2 : 0),
        padding: EdgeInsets.all(isTablet ? 28 : (isSmallScreen ? 12 : 16)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              softYellow.withValues(alpha: 0.25),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(isTablet ? 24 : 16),
          border: Border.all(
            color: accentYellow.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accentYellow.withValues(alpha: 0.15),
              blurRadius: isTablet ? 25 : 15,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: isTablet ? 35 : 25,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            // Animated icon with particles
            Container(
              width: isTablet ? 70 : (isSmallScreen ? 45 : 55),
              height: isTablet ? 70 : (isSmallScreen ? 45 : 55),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    accentYellow.withValues(alpha: 0.15),
                    accentYellow.withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_mosaic_rounded,
                size: isTablet ? 40 : (isSmallScreen ? 25 : 30),
                color: accentYellow,
              ),
            ),
            SizedBox(height: isTablet ? 16 : 8),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 0),
              child: Text(
                isSmallScreen
                    ? 'Fashion Journey\nBegins Now! 🌟'
                    : 'Your Fashion Journey\nBegins Now! 🌟',
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 22 : (isSmallScreen ? 14 : 18),
                  fontWeight: FontWeight.w800,
                  color: darkGray,
                  letterSpacing: 0.3,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: isTablet ? 12 : 6),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 2 : 0),
              child: Text(
                'Our advanced AI has analyzed your unique style DNA and created a personalized fashion profile. Get ready for outfit recommendations that perfectly match your aesthetic vision and lifestyle preferences!',
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 14 : (isSmallScreen ? 10 : 12),
                  color: mediumGray,
                  height: 1.5,
                  letterSpacing: 0.1,
                ),
                textAlign: TextAlign.center,
                maxLines: isSmallScreen ? 7 : 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: isTablet ? 16 : 10),

            // Feature highlights row with better spacing
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 2 : 0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 250) {
                    // Very small screens - stack vertically
                    return Column(
                      children: [
                        _buildFeatureHighlight(
                          Icons.palette_rounded,
                          'Style\nAnalysis',
                          primaryBlue,
                          isTablet,
                          isSmallScreen,
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildFeatureHighlight(
                              Icons.insights_rounded,
                              'Smart\nRecommendations',
                              fashionPink,
                              isTablet,
                              isSmallScreen,
                            ),
                            _buildFeatureHighlight(
                              Icons.trending_up_rounded,
                              'Fashion\nTrends',
                              mintGreen,
                              isTablet,
                              isSmallScreen,
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    // Normal layout
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFeatureHighlight(
                          Icons.palette_rounded,
                          'Style\nAnalysis',
                          primaryBlue,
                          isTablet,
                          isSmallScreen,
                        ),
                        _buildFeatureHighlight(
                          Icons.insights_rounded,
                          'Smart\nRecommendations',
                          fashionPink,
                          isTablet,
                          isSmallScreen,
                        ),
                        _buildFeatureHighlight(
                          Icons.trending_up_rounded,
                          'Fashion\nTrends',
                          mintGreen,
                          isTablet,
                          isSmallScreen,
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureHighlight(
    IconData icon,
    String label,
    Color color,
    bool isTablet,
    bool isSmallScreen,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 12 : (isSmallScreen ? 8 : 10)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.12),
                color.withValues(alpha: 0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
          ),
          child: Icon(
            icon,
            size: isTablet ? 24 : (isSmallScreen ? 16 : 20),
            color: color,
          ),
        ),
        SizedBox(height: isTablet ? 6 : 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isTablet ? 10 : (isSmallScreen ? 8 : 9),
            fontWeight: FontWeight.w600,
            color: mediumGray,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfileShowcase(
    BuildContext context,
    bool isTablet,
    bool isSmallScreen,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 28 : (isSmallScreen ? 18 : 22)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            softBlue.withValues(alpha: 0.15),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isTablet ? 24 : 18),
        border: Border.all(color: primaryBlue.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.1),
            blurRadius: isTablet ? 30 : 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with completion badge
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 14 : 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryBlue.withValues(alpha: 0.15),
                      primaryBlue.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.dashboard_customize_rounded,
                  color: primaryBlue,
                  size: isTablet ? 32 : (isSmallScreen ? 24 : 28),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Style Dashboard',
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 22 : (isSmallScreen ? 16 : 19),
                        fontWeight: FontWeight.w800,
                        color: darkGray,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      'Complete profile analytics',
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 13 : (isSmallScreen ? 11 : 12),
                        color: mediumGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 14 : (isSmallScreen ? 10 : 12),
                  vertical: isTablet ? 7 : 5,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [accentYellow, premiumGold]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: isTablet ? 14 : 12,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      _calculateCompletionPercentage(),
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 12 : (isSmallScreen ? 10 : 11),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 24 : 18),

          // Stats grid
          _buildResponsiveStatsGrid(context, isTablet, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildResponsiveStatsGrid(
    BuildContext context,
    bool isTablet,
    bool isSmallScreen,
  ) {
    final stats = [
      {
        'label': '⚧️ Gender',
        'value': data.selectedGender ?? 'Not Set',
        'icon': Icons.wc_rounded,
        'color': primaryBlue,
        'description': 'Style preference basis',
      },

      {
        'label': '👗 Body Shape',
        'value': data.selectedBodyShape ?? 'Not Set',
        'icon': Icons.accessibility_rounded,
        'color': fashionPink,
        'description': 'Fit optimization',
      },
      {
        'label': '🌈 Skin Tone',
        'value': _getSkinToneName(data.selectedSkinTone),
        'icon': Icons.face_rounded,
        'color': premiumGold,
        'description': 'Color harmony analysis',
      },
      {
        'label': '🎨 Undertone',
        'value': _getUndertoneName(data.selectedUndertone),
        'icon': Icons.colorize_rounded,
        'color': Colors.purple,
        'description': 'Skin undertone analysis',
      },
      {
        'label': '💇‍♀️ Hair Color',
        'value': data.selectedHairColor ?? 'Not Set',
        'icon': Icons.face_rounded,
        'color': accentRed,
        'description': 'Style coordination',
      },
      {
        'label': '🎨 Color Season',
        'value': data.selectedPersonalColor ?? 'Not Set',
        'icon': Icons.palette_rounded,
        'color': fashionPink,
        'description': 'Seasonal color palette',
      },
      {
        'label': '✨ Style Types',
        'value': '${data.selectedStyles.length} Selected',
        'icon': Icons.style_rounded,
        'color': mintGreen,
        'description': 'Fashion preferences',
      },
    ];

    if (isTablet) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            stats
                .map(
                  (stat) => SizedBox(
                    width: (MediaQuery.of(context).size.width - 140) / 4.5,
                    child: _buildEnhancedStatCard(
                      stat,
                      isTablet,
                      isSmallScreen,
                    ),
                  ),
                )
                .toList(),
      );
    } else {
      return Column(
        children: [
          // Row 1: Gender & Photo & Body Shape
          Row(
            children: [
              Expanded(
                child: _buildEnhancedStatCard(
                  stats[0],
                  isTablet,
                  isSmallScreen,
                ),
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Expanded(
                child: _buildEnhancedStatCard(
                  stats[1],
                  isTablet,
                  isSmallScreen,
                ),
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Expanded(
                child: _buildEnhancedStatCard(
                  stats[2],
                  isTablet,
                  isSmallScreen,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 10),

          // Row 2: Skin Tone & Undertone & Hair Color
          Row(
            children: [
              Expanded(
                child: _buildEnhancedStatCard(
                  stats[3],
                  isTablet,
                  isSmallScreen,
                ),
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Expanded(
                child: _buildEnhancedStatCard(
                  stats[4],
                  isTablet,
                  isSmallScreen,
                ),
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Expanded(
                child: _buildEnhancedStatCard(
                  stats[5],
                  isTablet,
                  isSmallScreen,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 10),

          // Row 3: Color Season & Style Types
          Row(
            children: [
              Expanded(
                child: _buildEnhancedStatCard(
                  stats[6],
                  isTablet,
                  isSmallScreen,
                ),
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Expanded(
                child: _buildEnhancedStatCard(
                  stats[7],
                  isTablet,
                  isSmallScreen,
                ),
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Expanded(child: Container()), // Empty space
            ],
          ),
        ],
      );
    }
  }

  String _calculateCompletionPercentage() {
    int completed = 0;
    int total = 8; // Updated total untuk include undertone

    if (data.selectedGender != null && data.selectedGender!.isNotEmpty)
      completed++;
    if (data.selectedBodyShape != null && data.selectedBodyShape!.isNotEmpty)
      completed++;
    if (data.selectedSkinTone != null) completed++;
    if (data.selectedUndertone != null && data.selectedUndertone!.isNotEmpty)
      completed++;
    if (data.selectedHairColor != null && data.selectedHairColor!.isNotEmpty)
      completed++;
    if (data.selectedPersonalColor != null &&
        data.selectedPersonalColor!.isNotEmpty)
      completed++;
    if (data.selectedStyles.isNotEmpty) completed++;

    int percent = ((completed / total) * 100).round();
    return '$percent%';
  }

  Widget _buildEnhancedStatCard(
    Map<String, dynamic> stat,
    bool isTablet,
    bool isSmallScreen,
  ) {
    // Extract emoji from label
    final label = stat['label'] as String;
    final labelParts = label.split(' ');
    final emoji =
        labelParts.first.contains(
              RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true),
            )
            ? labelParts.first
            : '';
    final cleanLabel =
        labelParts.length > 1 ? labelParts.skip(1).join(' ') : label;

    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : (isSmallScreen ? 10 : 12)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            (stat['color'] as Color).withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (stat['color'] as Color).withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (stat['color'] as Color).withValues(alpha: 0.12),
            blurRadius: 12,
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
                padding: EdgeInsets.all(isTablet ? 8 : 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (stat['color'] as Color).withValues(alpha: 0.15),
                      (stat['color'] as Color).withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      stat['icon'] as IconData,
                      color: stat['color'] as Color,
                      size: isTablet ? 16 : (isSmallScreen ? 12 : 14),
                    ),
                    if (emoji.isNotEmpty)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Text(
                          emoji,
                          style: TextStyle(fontSize: isTablet ? 10 : 8),
                        ),
                      ),
                  ],
                ),
              ),
              if (emoji.isNotEmpty) ...[
                SizedBox(width: 4),
                Text(emoji, style: TextStyle(fontSize: isTablet ? 12 : 10)),
              ],
            ],
          ),
          SizedBox(height: isTablet ? 10 : 6),

          Text(
            cleanLabel,
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 10 : (isSmallScreen ? 8 : 9),
              fontWeight: FontWeight.w600,
              color: mediumGray,
            ),
          ),
          SizedBox(height: 3),

          Text(
            stat['value'] as String,
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 11 : (isSmallScreen ? 9 : 10),
              fontWeight: FontWeight.w700,
              color: darkGray,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),

          Text(
            stat['description'] as String,
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 8 : (isSmallScreen ? 6 : 7),
              color: mediumGray.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStyleAnalysis(bool isTablet, bool isSmallScreen) {
    return Column(
      children: [
        _buildDetailedSection(
          '👤 Personal Identity',
          Icons.person_4_rounded,
          primaryBlue,
          [
            _buildDetailItem(
              '⚧️ Gender Identity',
              data.selectedGender ?? 'Not specified',
              '🎯 Foundation for personalized style recommendations',
              Icons.wc_rounded,
              isTablet,
              isSmallScreen,
            ),
          ],
          isTablet,
          isSmallScreen,
        ),
        SizedBox(height: isTablet ? 20 : 16),

        _buildDetailedSection(
          '🏃‍♀️ Physical Attributes',
          Icons.accessibility_new_rounded,
          fashionPink,
          [
            _buildDetailItem(
              '👗 Body Shape',
              data.selectedBodyShape ?? 'Not specified',
              '📐 Optimizes fit and silhouette recommendations',
              Icons.accessibility_rounded,
              isTablet,
              isSmallScreen,
            ),
            _buildDetailItem(
              '🌈 Skin Tone',
              _getSkinToneName(data.selectedSkinTone),
              '✨ Determines most flattering color palettes',
              Icons.face_rounded,
              isTablet,
              isSmallScreen,
            ),
            _buildDetailItem(
              '🎨 Skin Undertone',
              _getUndertoneName(data.selectedUndertone),
              '🌡️ Cool, warm, or neutral undertones for precise color matching',
              Icons.colorize_rounded,
              isTablet,
              isSmallScreen,
            ),
            _buildDetailItem(
              '💇‍♀️ Hair Color',
              data.selectedHairColor ?? 'Not specified',
              '🎨 Enhances color coordination and styling harmony',
              Icons.face_rounded,
              isTablet,
              isSmallScreen,
            ),
          ],
          isTablet,
          isSmallScreen,
        ),
        SizedBox(height: isTablet ? 20 : 16),

        _buildDetailedSection(
          '🎨 Color & Style Analysis',
          Icons.palette_rounded,
          mintGreen,
          [
            _buildDetailItem(
              '🎨 Personal Color Season',
              data.selectedPersonalColor ?? 'Not specified',
              '🌈 Your seasonal color palette (Spring, Summer, Autumn, Winter)',
              Icons.palette_rounded,
              isTablet,
              isSmallScreen,
            ),
            _buildDetailItem(
              '✨ Style Preferences',
              data.selectedStyles.isEmpty
                  ? '🤔 No styles selected yet - let\'s discover your taste!'
                  : data.selectedStyles.map((style) => '🔥 $style').join('\n'),
              '🎯 Fashion styles: Casual, Formal, Trendy, Classic, Bohemian, Minimalist',
              Icons.style_rounded,
              isTablet,
              isSmallScreen,
              isMultiline: true,
            ),
          ],
          isTablet,
          isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildDetailedSection(
    String title,
    IconData icon,
    Color accentColor,
    List<Widget> items,
    bool isTablet,
    bool isSmallScreen,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : (isSmallScreen ? 16 : 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            accentColor.withValues(alpha: 0.03),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.12),
            blurRadius: 25,
            offset: const Offset(0, 8),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 16 : 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.2),
                      accentColor.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: isTablet ? 28 : (isSmallScreen ? 20 : 24),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: isTablet ? 20 : (isSmallScreen ? 15 : 17),
                    fontWeight: FontWeight.w800,
                    color: darkGray,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value,
    String description,
    IconData icon,
    bool isTablet,
    bool isSmallScreen, {
    bool isMultiline = false,
  }) {
    // Extract emoji from label if present
    final labelParts = label.split(' ');
    final emoji =
        labelParts.first.contains(
              RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true),
            )
            ? labelParts.first
            : '✨';
    final cleanLabel =
        labelParts.length > 1 ? labelParts.skip(1).join(' ') : label;

    // Special handling for Style Preferences to show icons
    bool isStylePreferences = cleanLabel == 'Style Preferences';

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 14 : 10),
      padding: EdgeInsets.all(isTablet ? 18 : (isSmallScreen ? 14 : 16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            lightGray.withValues(alpha: 0.3),
            Colors.white,
            lightGray.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced icon container with emoji
              Container(
                padding: EdgeInsets.all(isTablet ? 12 : 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryBlue.withValues(alpha: 0.1),
                      primaryBlue.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryBlue.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      icon,
                      size: isTablet ? 18 : (isSmallScreen ? 14 : 16),
                      color: primaryBlue.withValues(alpha: 0.7),
                    ),
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Text(
                        emoji,
                        style: TextStyle(fontSize: isTablet ? 12 : 10),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isTablet ? 14 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cleanLabel,
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 14 : (isSmallScreen ? 12 : 13),
                        fontWeight: FontWeight.w600,
                        color: darkGray,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 14 : (isSmallScreen ? 10 : 12),
                        vertical: isTablet ? 10 : (isSmallScreen ? 6 : 8),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: primaryBlue.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child:
                          isStylePreferences && data.selectedStyles.isNotEmpty
                              ? _buildStylePreferencesDisplay(
                                isTablet,
                                isSmallScreen,
                              )
                              : Text(
                                value,
                                style: GoogleFonts.poppins(
                                  fontSize:
                                      isTablet ? 13 : (isSmallScreen ? 11 : 12),
                                  fontWeight: FontWeight.w600,
                                  color: primaryBlue,
                                ),
                                maxLines: isMultiline ? 4 : 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 12 : 8,
              vertical: isTablet ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: lightGray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: mediumGray.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: isTablet ? 14 : 12,
                  color: mediumGray.withValues(alpha: 0.7),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: isTablet ? 11 : (isSmallScreen ? 9 : 10),
                      color: mediumGray.withValues(alpha: 0.8),
                      fontStyle: FontStyle.italic,
                      height: 1.3,
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

  Widget _buildStylePreferencesDisplay(bool isTablet, bool isSmallScreen) {
    // Map of style names to their icons from Step 7
    final styleIcons = {
      'Casual': '👕',
      'Formal': '👔',
      'Trendy': '✨',
      'Classic': '⭐',
      'Bohemian': '🌸',
      'Minimalist': '◽',
    };

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children:
          data.selectedStyles.map((styleName) {
            final styleIcon = styleIcons[styleName] ?? '🎨';
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 10 : (isSmallScreen ? 6 : 8),
                vertical: isTablet ? 6 : 4,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryBlue.withValues(alpha: 0.15),
                    primaryBlue.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryBlue.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    styleIcon,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : (isSmallScreen ? 10 : 12),
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    styleName,
                    style: GoogleFonts.poppins(
                      fontSize: isTablet ? 11 : (isSmallScreen ? 9 : 10),
                      fontWeight: FontWeight.w600,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildFashionHub(
    BuildContext context,
    bool isTablet,
    bool isSmallScreen,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 28 : (isSmallScreen ? 18 : 22)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            softYellow.withValues(alpha: 0.6),
            fashionPink.withValues(alpha: 0.08),
            softBlue.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isTablet ? 24 : 18),
        border: Border.all(
          color: accentYellow.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentYellow.withValues(alpha: 0.2),
            blurRadius: isTablet ? 30 : 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  accentRed.withValues(alpha: 0.15),
                  accentRed.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.rocket_launch_rounded,
              size: isTablet ? 40 : (isSmallScreen ? 30 : 35),
              color: accentRed,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),

          Text(
            'What\'s Next? 🚀',
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 22 : (isSmallScreen ? 16 : 19),
              fontWeight: FontWeight.w800,
              color: darkGray,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),

          Text(
            'Your AI-powered style journey continues! Get ready for personalized outfit recommendations, trend insights, and a wardrobe that truly represents your unique fashion DNA.',
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 14 : (isSmallScreen ? 12 : 13),
              color: mediumGray,
              height: 1.6,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isTablet ? 20 : 16),

          _buildNextStepsGrid(context, isTablet, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildNextStepsGrid(
    BuildContext context,
    bool isTablet,
    bool isSmallScreen,
  ) {
    final nextSteps = [
      {
        'icon': Icons.auto_awesome_rounded,
        'title': 'Get Recommendations',
        'subtitle': 'AI-curated outfits',
        'color': primaryBlue,
        'onTap': () => _navigateToHome(context),
      },
      {
        'icon': Icons.shopping_bag_rounded,
        'title': 'Smart Shopping',
        'subtitle': 'Personalized collections',
        'color': fashionPink,
        'onTap': () => _navigateToHome(context),
      },
      {
        'icon': Icons.favorite_rounded,
        'title': 'Build Wardrobe',
        'subtitle': 'Style evolution tracking',
        'color': mintGreen,
        'onTap': () => _navigateToHome(context),
      },
    ];

    if (isTablet) {
      return Row(
        children:
            nextSteps
                .map(
                  (step) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildNextStepCard(step, isTablet, isSmallScreen),
                    ),
                  ),
                )
                .toList(),
      );
    } else {
      return Column(
        children: [
          _buildNextStepCard(nextSteps[0], isTablet, isSmallScreen),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Row(
            children: [
              Expanded(
                child: _buildNextStepCard(
                  nextSteps[1],
                  isTablet,
                  isSmallScreen,
                ),
              ),
              SizedBox(width: isSmallScreen ? 12 : 16),
              Expanded(
                child: _buildNextStepCard(
                  nextSteps[2],
                  isTablet,
                  isSmallScreen,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildNextStepCard(
    Map<String, dynamic> step,
    bool isTablet,
    bool isSmallScreen,
  ) {
    return GestureDetector(
      onTap: step['onTap'] as VoidCallback,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 18 : (isSmallScreen ? 12 : 15)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (step['color'] as Color).withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (step['color'] as Color).withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 12 : 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (step['color'] as Color).withValues(alpha: 0.15),
                    (step['color'] as Color).withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                step['icon'] as IconData,
                color: step['color'] as Color,
                size: isTablet ? 24 : (isSmallScreen ? 18 : 20),
              ),
            ),
            SizedBox(height: isTablet ? 10 : 8),

            Text(
              step['title'] as String,
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 12 : (isSmallScreen ? 10 : 11),
                fontWeight: FontWeight.w700,
                color: darkGray,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),

            Text(
              step['subtitle'] as String,
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 10 : (isSmallScreen ? 8 : 9),
                color: mediumGray,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class OutfitResultPage extends StatefulWidget {
  final Map<String, dynamic> result;
  final String occasion;
  final String weather;
  final String style;

  const OutfitResultPage({
    super.key,
    required this.result,
    required this.occasion,
    required this.weather,
    required this.style,
  });

  @override
  State<OutfitResultPage> createState() => _OutfitResultPageState();
}

class _OutfitResultPageState extends State<OutfitResultPage>
    with TickerProviderStateMixin {
  // Organized Color Palette
  static const Map<String, Color> colors = {
    // Primary Colors
    'primaryBlue': Color(0xFF4A90E2),
    'secondaryBlue': Color(0xFF6BA3F0),
    'electricBlue': Color(0xFF00D4FF),
    'skyBlue': Color(0xFFE3F2FD),

    // Accent Colors
    'accentYellow': Color(0xFFF5A623),
    'sunsetOrange': Color(0xFFFF6B35),
    'vibrantPurple': Color(0xFF9B59B6),
    'hotPink': Color(0xFFE91E63),
    'neonGreen': Color(0xFF2ECC71),
    'deepTeal': Color(0xFF00BCD4),
    'accentRed': Color(0xFFD0021B),

    // Neutral Colors
    'darkGray': Color(0xFF2C3E50),
    'mediumGray': Color(0xFF6B7280),
    'lightGray': Color(0xFFF8F9FA),
    'pureWhite': Color(0xFFFFFFFF),

    // Background Colors
    'lightLavender': Color(0xFFF3E5F5),
    'mintGreen': Color(0xFFE8F5E8),
    'softPeach': Color(0xFFFFF3E0),
    'shadowColor': Color(0x1A000000),
  };

  // Consistent Spacing and Sizing
  static const double spacing = 16.0;

  // Animation Controllers
  late final List<AnimationController> _controllers;
  late final Map<String, Animation<double>> _animations;

  bool _showAIAnalysis = false;
  int _currentSwipeIndex = 0;
  late PageController _pageController;


  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    final controllerConfigs = [
      {'name': 'header', 'duration': 600},
      {'name': 'content', 'duration': 800},
      {'name': 'badge', 'duration': 1000},
      {'name': 'aiPulse', 'duration': 2000},
      {'name': 'sparkle', 'duration': 3000},
      {'name': 'match', 'duration': 1200},
    ];

    _controllers =
        controllerConfigs
            .map(
              (config) => AnimationController(
                duration: Duration(milliseconds: config['duration'] as int),
                vsync: this,
              ),
            )
            .toList();

    _animations = {
      'header': Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controllers[0], curve: Curves.easeOutQuart),
      ),
      'content': Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controllers[1], curve: Curves.easeOutCubic),
      ),
      'badge': Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controllers[2], curve: Curves.elasticOut),
      ),
      'aiPulse': Tween<double>(begin: 0.98, end: 1.02).animate(
        CurvedAnimation(parent: _controllers[3], curve: Curves.easeInOut),
      ),
      'sparkle': Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controllers[4], curve: Curves.linear)),
      'match': Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controllers[5], curve: Curves.easeOutCubic),
      ),
    };
  }

  void _startAnimationSequence() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controllers[0].forward();
        _controllers[3].repeat(reverse: true);
      }
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controllers[1].forward();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _controllers[2].forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _controllers[4].repeat();
        _controllers[5].forward();
        setState(() => _showAIAnalysis = true);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors['lightGray'],
      body: Container(
        decoration: _buildBackgroundDecoration(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors['pureWhite']!,
            colors['lightGray']!.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors['shadowColor']!,
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _animations['badge']!,
        builder:
            (context, child) => Transform.scale(
              scale: _animations['badge']!.value,
              child: Row(
                children: [
                  // Save to Favorites Button
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    Icons.favorite_rounded,
                                    color: colors['pureWhite'],
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Saved!',
                                      style: GoogleFonts.poppins(
                                        color: colors['pureWhite'],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: colors['hotPink'],
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(12),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors['hotPink']!.withValues(
                            alpha: 0.1,
                          ),
                          foregroundColor: colors['hotPink'],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: colors['hotPink']!.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Icon(Icons.favorite_rounded, size: 18),
                      ),
                    ),
                  ),

                  SizedBox(width: 8),

                  // Generate Another Button
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _generateAnother,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors['vibrantPurple'],
                          foregroundColor: colors['pureWhite'],
                          elevation: 6,
                          shadowColor: colors['vibrantPurple']!.withValues(
                            alpha: 0.3,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh_rounded, size: 16),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Generate',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colors['lightGray']!,
          colors['skyBlue']!,
          colors['mintGreen']!,
          colors['softPeach']!,
          colors['lightLavender']!,
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      collapsedHeight: 70,
      pinned: true,
      floating: false,
      snap: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final top = constraints.biggest.height;
          final isCollapsed = top <= 90;

          return FlexibleSpaceBar(
            background: _buildSimpleAppBarBackground(isCollapsed),
            collapseMode: CollapseMode.pin,
            titlePadding: EdgeInsets.zero,
          );
        },
      ),
    );
  }

  Widget _buildSimpleAppBarBackground(bool isCollapsed) {
    return AnimatedBuilder(
      animation: _animations['header']!,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors['vibrantPurple']!.withValues(alpha: 0.95),
                colors['electricBlue']!.withValues(alpha: 0.9),
                colors['deepTeal']!.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(isCollapsed ? 16 : 24),
              bottomRight: Radius.circular(isCollapsed ? 16 : 24),
            ),
            boxShadow: [
              BoxShadow(
                color: colors['vibrantPurple']!.withValues(
                  alpha: isCollapsed ? 0.1 : 0.2,
                ),
                blurRadius: isCollapsed ? 8 : 16,
                offset: Offset(0, isCollapsed ? 3 : 6),
              ),
            ],
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Background pattern (simplified)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.05,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(isCollapsed ? 16 : 24),
                          bottomRight: Radius.circular(isCollapsed ? 16 : 24),
                        ),
                      ),
                    ),
                  ),
                ),

                // Top controls - Fixed positioning
                Positioned(
                  top: 8,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSimpleBackButton(),
                      SizedBox(width: 40), // Placeholder for symmetry
                    ],
                  ),
                ),

                // Main content - Responsive positioning
                Positioned(
                  bottom: isCollapsed ? 8 : 16,
                  left: 20,
                  right: 20,
                  child: Transform.translate(
                    offset: Offset(0, 10 * (1 - _animations['header']!.value)),
                    child: Opacity(
                      opacity: _animations['header']!.value,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Responsive layout based on available width
                          final screenWidth = MediaQuery.of(context).size.width;
                          final isSmallScreen = screenWidth < 360;

                          return Row(
                            children: [
                              // Icon container
                              Container(
                                padding: EdgeInsets.all(
                                  isCollapsed ? 6 : (isSmallScreen ? 8 : 10),
                                ),
                                decoration: BoxDecoration(
                                  color: colors['pureWhite']!.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    isCollapsed ? 10 : 14,
                                  ),
                                  border: Border.all(
                                    color: colors['pureWhite']!.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons
                                      .psychology_rounded, // Changed from auto_awesome_rounded
                                  color: colors['pureWhite'],
                                  size:
                                      isCollapsed
                                          ? 16
                                          : (isSmallScreen ? 18 : 20),
                                ),
                              ),
                              SizedBox(width: isSmallScreen ? 10 : 12),

                              // Text content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Title
                                    Text(
                                      widget.result['name'] ??
                                          'Perfect AI Match',
                                      style: GoogleFonts.poppins(
                                        fontSize:
                                            isCollapsed
                                                ? (isSmallScreen ? 16 : 18)
                                                : (isSmallScreen ? 20 : 24),
                                        fontWeight: FontWeight.w800,
                                        color: colors['pureWhite'],
                                        letterSpacing: -0.5,
                                        height: 1.1,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    // Stats row - only show when not collapsed
                                    if (!isCollapsed) ...[
                                      SizedBox(height: isSmallScreen ? 2 : 4),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            _buildCompactStat(
                                              Icons.star_rounded,
                                              '${widget.result['rating'] ?? 4.9}',
                                              colors['accentYellow']!,
                                              isSmallScreen,
                                            ),
                                            SizedBox(
                                              width: isSmallScreen ? 6 : 8,
                                            ),
                                            AnimatedBuilder(
                                              animation: _animations['match']!,
                                              builder:
                                                  (
                                                    context,
                                                    child,
                                                  ) => _buildCompactStat(
                                                    Icons.verified_rounded,
                                                    '${((widget.result['matchScore'] ?? 95) * _animations['match']!.value).round()}%',
                                                    colors['neonGreen']!,
                                                    isSmallScreen,
                                                  ),
                                            ),
                                            SizedBox(
                                              width: isSmallScreen ? 6 : 8,
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    isSmallScreen ? 6 : 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: colors['pureWhite']!
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${widget.occasion} • ${widget.weather}',
                                                style: GoogleFonts.poppins(
                                                  fontSize:
                                                      isSmallScreen ? 8 : 9,
                                                  color: colors['pureWhite']!
                                                      .withValues(alpha: 0.9),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
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
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimpleBackButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors['pureWhite']!.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors['pureWhite']!.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colors['pureWhite'],
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStat(
    IconData icon,
    String value,
    Color color,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : 8,
        vertical: isSmallScreen ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: colors['pureWhite']!.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: isSmallScreen ? 10 : 12),
          SizedBox(width: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 9 : 10,
              fontWeight: FontWeight.w700,
              color: colors['pureWhite'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return AnimatedBuilder(
      animation: _animations['content']!,
      builder:
          (context, child) => Transform.translate(
            offset: Offset(0, 50 * (1 - _animations['content']!.value)),
            child: Opacity(
              opacity: _animations['content']!.value,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildAIConfidenceSection(),
                  const SizedBox(height: 16),
                  _buildOutfitPreviewSection(),
                  const SizedBox(height: 16),
                  _buildSwipeableSections(),
                  const SizedBox(height: 16),
                  _buildSmartInsightsSection(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildAIConfidenceSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors['pureWhite']!,
            colors['lightGray']!.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors['shadowColor']!,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _animations['match']!,
        builder:
            (context, child) => Transform.scale(
              scale: 0.98 + (0.02 * _animations['match']!.value),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors['electricBlue']!, colors['deepTeal']!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colors['electricBlue']!.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons
                          .verified_rounded, // Changed from auto_awesome_rounded
                      color: colors['pureWhite'],
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Confidence',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: colors['darkGray'],
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${((widget.result['matchScore'] ?? 95) * _animations['match']!.value).round()}%',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: colors['vibrantPurple'],
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colors['neonGreen']!,
                                    colors['deepTeal']!,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'EXCELLENT',
                                style: GoogleFonts.poppins(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: colors['pureWhite'],
                                  letterSpacing: 0.8,
                                ),
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
      ),
    );
  }

  Widget _buildSwipeableSections() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      height: 380,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors['pureWhite']!,
            colors['lightGray']!.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors['shadowColor']!,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildSectionTab('Analysis', Icons.psychology_rounded, 0),
                _buildSectionTab('Tips', Icons.tips_and_updates_rounded, 1),
                _buildSectionTab('More', Icons.grid_view_rounded, 2),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentSwipeIndex = index);
                HapticFeedback.lightImpact();
              },
              children: [
                _buildAIAnalysisContent(),
                _buildStyleTipsContent(),
                _buildAlternativesContent(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => _buildPageIndicator(index)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTab(String title, IconData icon, int index) {
    final isActive = _currentSwipeIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient:
                isActive
                    ? LinearGradient(
                      colors: [
                        colors['vibrantPurple']!,
                        colors['electricBlue']!,
                      ],
                    )
                    : null,
            color:
                isActive ? null : colors['lightGray']!.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? colors['pureWhite'] : colors['mediumGray'],
                size: 16,
              ),
              SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isActive ? colors['pureWhite'] : colors['mediumGray'],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = _currentSwipeIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        gradient:
            isActive
                ? LinearGradient(
                  colors: [colors['vibrantPurple']!, colors['electricBlue']!],
                )
                : null,
        color: isActive ? null : colors['mediumGray']!.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

Widget _buildAIAnalysisContent() {
  final outfitItems = widget.result['outfit'] as List<dynamic>? ?? [];
  
  return SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.psychology_rounded,
              color: colors['vibrantPurple'],
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'AI Deep Analysis',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colors['darkGray'],
              ),
            ),
            Spacer(),
            _buildLiveBadge(),
          ],
        ),
        SizedBox(height: 16),
        AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          child: _showAIAnalysis
              ? Column(
                  children: [
                    _buildRealAnalysisItem(
                      'Style Coherence Analysis',
                      _getStyleCoherenceAnalysis(),
                      Icons.visibility_rounded,
                      _calculateOverallStyleScore(),
                      colors['vibrantPurple']!,
                    ),
                    SizedBox(height: 12),
                    _buildRealAnalysisItem(
                      'Color Harmony Detection',
                      _getColorHarmonyAnalysis(outfitItems),
                      Icons.palette_rounded,
                      _calculateColorHarmonyScore(outfitItems),
                      colors['sunsetOrange']!,
                    ),
                    SizedBox(height: 12),
                    _buildRealAnalysisItem(
                      'Occasion Intelligence',
                      'Analyzed ${widget.occasion.toLowerCase()} appropriateness',
                      Icons.event_rounded,
                      _calculateOccasionScore(),
                      colors['neonGreen']!,
                    ),
                    SizedBox(height: 12),
                    _buildRealAnalysisItem(
                      'Weather Optimization',
                      'Optimized for ${widget.weather.toLowerCase()} conditions',
                      Icons.thermostat_rounded,
                      _calculateWeatherScore(),
                      colors['electricBlue']!,
                    ),
                  ],
                )
              : _buildLoadingIndicator(),
        ),
      ],
    ),
  );
}

Widget _buildStyleTipsContent() {
  final outfitItems = widget.result['outfit'] as List<dynamic>? ?? [];
  final realTips = _generateRealStyleTips(outfitItems);
  
  return SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Style Recommendations',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: colors['darkGray'],
          ),
        ),
        SizedBox(height: 16),
        ...realTips.map((tip) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildStyleTip(
            tip['title'],
            tip['description'],
            tip['icon'],
            tip['color'],
          ),
        )),
      ],
    ),
  );
}

 Widget _buildAlternativesContent() {
  final outfitItems = widget.result['outfit'] as List<dynamic>? ?? [];
  final realAlternatives = _generateRealAlternatives(outfitItems);
  
  return SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Style Variations',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: colors['darkGray'],
          ),
        ),
        SizedBox(height: 16),
        if (realAlternatives.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors['lightGray']!.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors['mediumGray']!.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.auto_awesome_outlined,
                  color: colors['mediumGray'],
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  'Perfect as is!',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors['darkGray'],
                  ),
                ),
                Text(
                  'Your current outfit is optimally styled',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: colors['mediumGray'],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...realAlternatives.map((alt) => _buildRealAlternativeCard(alt)),
      ],
    ),
  );
}



  Widget _buildStyleTip(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colors['pureWhite'], size: 16),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors['darkGray'],
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: colors['mediumGray'],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors['neonGreen']!, colors['deepTeal']!],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.live_tv_rounded, color: colors['pureWhite'], size: 12),
          SizedBox(width: 4),
          Text(
            'LIVE',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: colors['pureWhite'],
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  colors['vibrantPurple']!,
                ),
                strokeWidth: 4,
              ),
            ),
            SizedBox(height: spacing),
            Text(
              'Analyzing your style...',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: colors['mediumGray'],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildSmartInsightsSection() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 12),
    child: Row(
      children: [
        Expanded(
          child: _buildInsightCard(
            'Weather',
            '${_calculateWeatherScore()}%',
            _getWeatherStatus(_calculateWeatherScore()),
            Icons.wb_sunny_rounded,
            _getWeatherColor(_calculateWeatherScore()),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _buildInsightCard(
            'Occasion',
            '${_calculateOccasionScore()}%',
            _getOccasionStatus(_calculateOccasionScore()),
            Icons.event_rounded,
            _getOccasionColor(_calculateOccasionScore()),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _buildInsightCard(
            'Style',
            '${_calculateOverallStyleScore()}%',
            _getStyleStatus(_calculateOverallStyleScore()),
            Icons.trending_up_rounded,
            _getStyleColor(_calculateOverallStyleScore()),
          ),
        ),
      ],
    ),
  );
}
  Widget _buildInsightCard(
    String title,
    String percentage,
    String status,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors['pureWhite']!,
            colors['lightGray']!.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors['shadowColor']!,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          SizedBox(height: 8),
          Text(
            percentage,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            status,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: colors['darkGray'],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 8,
              color: colors['mediumGray'],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

Widget _buildOutfitPreviewSection() {
  // ✅ HAPUS hardcoded data, pakai data real dari AI result
  final outfitItems = widget.result['outfit'] as List<dynamic>? ?? [];
  
  // ✅ Convert ke format yang sesuai (TANPA brand field)
  final components = outfitItems.map((item) => {
    'name': item['name'] ?? 'Unknown Item',
    'category': item['category'] ?? 'Item',
    'imageUrl': item['imageUrl'] ?? '',
    'description': item['description'] ?? '',
    'color': item['color'] ?? '',
    // ✅ HAPUS brand karena tidak ada di wardrobe form kamu
  }).toList();

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colors['pureWhite']!,
          colors['lightGray']!.withValues(alpha: 0.8),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: colors['shadowColor']!,
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors['primaryBlue']!,
                    colors['primaryBlue']!.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colors['primaryBlue']!.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.collections_rounded,
                color: colors['pureWhite'],
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your AI Generated Outfit',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: colors['darkGray'],
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    '${components.length} items selected',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: colors['mediumGray'],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        SizedBox(height: 16),
        
        // ✅ TAMPILKAN REAL DATA atau pesan jika kosong
        if (components.isEmpty)
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: colors['lightGray']!.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors['mediumGray']!.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: colors['mediumGray'],
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No outfit items generated',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: colors['mediumGray'],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
    crossAxisSpacing: 12, // ✅ Spacing yang lebih besar
    mainAxisSpacing: 12,  // ✅ Spacing yang lebih besar
    childAspectRatio: 0.65, // ✅ UBAH DARI 0.8 KE 0.65 (lebih tinggi untuk gambar besar)
  ),
  itemCount: components.length,
  itemBuilder: (context, index) => _buildOutfitItemCard(components[index]),
),
      ],
    ),
  );
}

Widget _buildOutfitItemCard(Map<String, dynamic> item) {
  if (item.isEmpty) return const SizedBox.shrink();

  final categoryColor = _getCategoryColor(item['category']);

  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [colors['pureWhite']!, categoryColor.withValues(alpha: 0.1)],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: categoryColor.withValues(alpha: 0.3),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: categoryColor.withValues(alpha: 0.15),
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
        onTap: () => _showOutfitItemDetails(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ CATEGORY BADGE DI ATAS
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      categoryColor,
                      categoryColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item['category']?.toString() ?? 'Item',
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: colors['pureWhite'],
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            
            // ✅ GAMBAR YANG LEBIH BESAR - MENGAMBIL SEBAGIAN BESAR SPACE
            Expanded(
              flex: 5, // ✅ Berikan lebih banyak space untuk gambar
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: categoryColor.withValues(alpha: 0.05),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: (item['imageUrl'] != null && item['imageUrl'] != "")
                      ? Image.network(
                          item['imageUrl'],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover, // ✅ Cover untuk mengisi seluruh area
                          errorBuilder: (ctx, e, s) => _buildFallbackIcon(
                            item['category'], 
                            categoryColor,
                            isLarge: true, // ✅ Tambah parameter untuk icon besar
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _buildLoadingWidget(categoryColor);
                          },
                        )
                      : _buildFallbackIcon(
                          item['category'], 
                          categoryColor,
                          isLarge: true, // ✅ Icon besar untuk fallback
                        ),
                ),
              ),
            ),
            
            // ✅ INFO SECTION DI BAWAH - LEBIH COMPACT
            Expanded(
              flex: 2, // ✅ Space lebih kecil untuk text
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Item name
                    Text(
                      item['name']?.toString() ?? 'Item',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors['darkGray'],
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // ✅ TAP INDICATOR - LEBIH KECIL DAN SUBTLE
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: categoryColor.withValues(alpha: 0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            size: 8,
                            color: categoryColor.withValues(alpha: 0.8),
                          ),
                          SizedBox(width: 2),
                          Text(
                            'Details',
                            style: GoogleFonts.poppins(
                              fontSize: 7,
                              fontWeight: FontWeight.w600,
                              color: categoryColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
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
  );
}

// ✅ TAMBAH HELPER METHOD UNTUK FALLBACK ICON YANG BISA BESAR/KECIL
Widget _buildFallbackIcon(String? category, Color categoryColor, {bool isLarge = false}) {
  return Container(
    width: double.infinity,
    height: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          categoryColor.withValues(alpha: 0.1),
          categoryColor.withValues(alpha: 0.05),
        ],
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _getCategoryIconData(category),
          size: isLarge ? 48 : 28, // ✅ Icon size yang responsif
          color: categoryColor.withValues(alpha: 0.8),
        ),
        if (isLarge) ...[
          SizedBox(height: 8),
          Text(
            category?.toString() ?? 'Item',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: categoryColor.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    ),
  );
}

// ✅ TAMBAH LOADING WIDGET YANG BAGUS
Widget _buildLoadingWidget(Color categoryColor) {
  return Container(
    width: double.infinity,
    height: double.infinity,
    decoration: BoxDecoration(
      color: categoryColor.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            color: categoryColor,
            strokeWidth: 3,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Loading...',
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: categoryColor.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

 void _showOutfitItemDetails(Map<String, dynamic> item) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors['pureWhite']!,
              colors['lightGray']!.withValues(alpha: 0.95),
              colors['skyBlue']!.withValues(alpha: 0.3),
            ],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: colors['shadowColor']!,
              blurRadius: 25,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 60,
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors['vibrantPurple']!.withValues(alpha: 0.6),
                        colors['electricBlue']!.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Header with Category Badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getCategoryColor(item['category']),
                          _getCategoryColor(item['category']).withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _getCategoryColor(item['category']).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIconData(item['category']),
                          color: colors['pureWhite'],
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          item['category']?.toString().toUpperCase() ?? 'ITEM',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: colors['pureWhite'],
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors['lightGray']!.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: colors['mediumGray'],
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Item Image with Real Image Support
              Container(
                height: 250,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getCategoryColor(item['category']).withValues(alpha: 0.1),
                      _getCategoryColor(item['category']).withValues(alpha: 0.05),
                      colors['pureWhite']!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _getCategoryColor(item['category']).withValues(alpha: 0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getCategoryColor(item['category']).withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Main Item Display - Support Real Images
                    Center(
                      child: (item['imageUrl'] != null && item['imageUrl'] != "")
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                item['imageUrl'],
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, e, s) => _buildFallbackDisplay(item),
                              ),
                            )
                          : _buildFallbackDisplay(item),
                    ),

                    // AI Confidence Badge
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colors['neonGreen']!, colors['deepTeal']!],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: colors['neonGreen']!.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              color: colors['pureWhite'],
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${_getItemConfidence(item['category'])}%',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: colors['pureWhite'],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Item Details
              Text(
                item['name']?.toString() ?? 'Item Details',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: colors['darkGray'],
                  letterSpacing: -0.5,
                ),
              ),

              SizedBox(height: 8),

              // ✅ FIXED: Brand and Price Row - HAPUS brand reference
              Row(
                children: [
                  // ✅ HAPUS seluruh brand section karena tidak ada di wardrobe form
                  if (item['price'] != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors['accentRed']!.withValues(alpha: 0.1),
                            colors['sunsetOrange']!.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colors['accentRed']!.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        item['price'].toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: colors['accentRed'],
                        ),
                      ),
                    ),
                  ],
                  // ✅ ATAU jika tidak ada price, tampilkan kategori sebagai fallback
                  if (item['price'] == null && item['category'] != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(item['category']).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getCategoryColor(item['category']).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        item['category'].toString().toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _getCategoryColor(item['category']),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              SizedBox(height: 24),

              // AI Analysis Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors['vibrantPurple']!.withValues(alpha: 0.05),
                      colors['electricBlue']!.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors['vibrantPurple']!.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colors['vibrantPurple']!,
                                colors['electricBlue']!,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.psychology_rounded,
                            color: colors['pureWhite'],
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'AI Selection Reasoning',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: colors['darkGray'],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors['neonGreen']!,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'OPTIMAL',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: colors['pureWhite'],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    Text(
                      _getAIReasoningText(item),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: colors['darkGray'],
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Analysis Metrics
              _buildAnalysisMetrics(item),

              SizedBox(height: 20),

              // Style Compatibility
              _buildStyleCompatibility(item),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    ),
  );
}

// ✅ TAMBAH helper method untuk fallback display
Widget _buildFallbackDisplay(Map<String, dynamic> item) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _getCategoryColor(item['category']).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          _getCategoryIconData(item['category']),
          size: 64,
          color: _getCategoryColor(item['category']),
        ),
      ),
      SizedBox(height: 16),
      Text(
        'AI Visual Analysis',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colors['mediumGray'],
        ),
      ),
    ],
  );
}

  void _generateAnother() {
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colors['pureWhite']!),
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Generating new outfit...',
              style: GoogleFonts.poppins(
                color: colors['pureWhite'],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: colors['vibrantPurple'],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(spacing),
        duration: const Duration(seconds: 2),
      ),
    );

    // Simulate navigation back to generate new outfit
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  // Helper methods for AI analysis
  String _getAIReasoningText(Map<String, dynamic> item) {
    final category = item['category']?.toString().toLowerCase() ?? '';

    switch (category) {
      case 'outerwear':
        return "This ${item['name']} was selected as the perfect outer layer for ${widget.occasion.toLowerCase()} occasions. The AI analyzed the color harmony with your other pieces, ensuring a sophisticated look that complements the ${widget.weather.toLowerCase()} weather conditions. The structured silhouette adds professional polish while maintaining comfort and style versatility.";

      case 'tops':
        return "The AI chose this ${item['name']} as your foundational piece based on its exceptional versatility and color coordination. It perfectly balances formality for ${widget.occasion.toLowerCase()} settings while ensuring comfort in ${widget.weather.toLowerCase()} conditions. The fabric choice and cut create an ideal base layer that enhances your overall silhouette.";

      case 'bottoms':
        return "These ${item['name']} were selected for their perfect fit profile and occasion appropriateness. The AI considered the proportional balance with your top pieces, ensuring a flattering silhouette. The style seamlessly transitions between professional and casual settings, making them ideal for ${widget.occasion.toLowerCase()} events.";

      case 'shoes':
        return "The AI selected these ${item['name']} based on comprehensive comfort and style analysis. They provide the perfect finishing touch for ${widget.occasion.toLowerCase()} settings while ensuring all-day comfort. The design complements your outfit's color palette and adds the right level of sophistication to your overall look.";

      case 'accessories':
        return "This ${item['name']} was chosen to perfectly complete your ensemble. The AI analyzed how this piece enhances your outfit's visual balance and adds subtle elegance. It serves as the ideal accent piece that ties together your entire look while maintaining appropriateness for ${widget.occasion.toLowerCase()} occasions.";

      default:
        return "The AI selected this item through comprehensive style analysis, considering color harmony, occasion appropriateness, and overall outfit balance. Every element of your outfit works together to create a cohesive and stylish look that's perfect for your needs.";
    }
  }

  int _getItemConfidence(String? category) {
    switch (category?.toLowerCase()) {
      case 'outerwear':
        return 97;
      case 'tops':
        return 95;
      case 'bottoms':
        return 96;
      case 'shoes':
        return 94;
      case 'accessories':
        return 93;
      default:
        return 95;
    }
  }
   // ✅ REPLACE method _getItemMetrics dengan dynamic calculation
  Map<String, Map<String, dynamic>> _getItemMetrics(Map<String, dynamic> item) {
    // ✅ Get real data from AI result
    final itemCategory = item['category']?.toString().toLowerCase() ?? '';
    final itemColor = item['color']?.toString().toLowerCase() ?? '';
    
    // ✅ Calculate realistic scores based on actual data
    int colorScore = _calculateColorHarmonyScoreForItem(itemColor, item);
    int occasionScore = _calculateOccasionMatchScore(itemCategory, widget.occasion);
    int weatherScore = _calculateWeatherSuitabilityScore(itemCategory, widget.weather);
    int styleScore = _calculateStyleCoherenceScore(itemCategory, widget.style);
    
    return {
      'Color Harmony': {
        'score': colorScore,
        'color': colors['vibrantPurple']!,
        'description': _getColorHarmonyDescription(colorScore, itemColor),
      },
      'Occasion Match': {
        'score': occasionScore,
        'color': colors['neonGreen']!,
        'description': _getOccasionMatchDescription(occasionScore, widget.occasion),
      },
      'Weather Suitability': {
        'score': weatherScore,
        'color': colors['electricBlue']!,
        'description': _getWeatherSuitabilityDescription(weatherScore, widget.weather),
      },
      'Style Coherence': {
        'score': styleScore,
        'color': colors['sunsetOrange']!,
        'description': _getStyleCoherenceDescription(styleScore, widget.style),
      },
    };
  }

  // ✅ REPLACE _getStyleCompatibilities dengan dynamic tags
  List<Map<String, dynamic>> _getStyleCompatibilities(Map<String, dynamic> item) {
    final itemCategory = item['category']?.toString().toLowerCase() ?? '';
    final itemColor = item['color']?.toString().toLowerCase() ?? '';
    
    List<Map<String, dynamic>> compatibilities = [];
    
    // ✅ Dynamic compatibility berdasarkan actual item properties
    
    // Professional compatibility
    int professionalScore = _calculateOccasionMatchScore(itemCategory, 'work/office');
    if (professionalScore >= 85) {
      compatibilities.add({
        'label': 'Professional',
        'icon': Icons.business_center_rounded,
        'color': colors['primaryBlue']!,
      });
    }
    
    // Versatile compatibility
    int versatilityScore = (
      _calculateOccasionMatchScore(itemCategory, 'casual day') +
      _calculateOccasionMatchScore(itemCategory, 'work/office') +
      _calculateOccasionMatchScore(itemCategory, 'date night')
    ) ~/ 3;
    if (versatilityScore >= 80) {
      compatibilities.add({
        'label': 'Versatile',
        'icon': Icons.tune_rounded,
        'color': colors['neonGreen']!,
      });
    }
    
    // Seasonal compatibility
    int seasonalScore = (
      _calculateWeatherSuitabilityScore(itemCategory, 'sunny & warm') +
      _calculateWeatherSuitabilityScore(itemCategory, 'mild & pleasant')
    ) ~/ 2;
    if (seasonalScore >= 80) {
      compatibilities.add({
        'label': 'Seasonal',
        'icon': Icons.wb_sunny_rounded,
        'color': colors['sunsetOrange']!,
      });
    }
    
    // Trending compatibility (berdasarkan style coherence)
    int trendingScore = _calculateStyleCoherenceScore(itemCategory, 'trendy');
    if (trendingScore >= 85) {
      compatibilities.add({
        'label': 'Trending',
        'icon': Icons.trending_up_rounded,
        'color': colors['vibrantPurple']!,
      });
    }
    
    // ✅ Tambahkan compatibility khusus berdasarkan warna
    if (['black', 'white', 'navy', 'gray'].contains(itemColor)) {
      compatibilities.add({
        'label': 'Timeless',
        'icon': Icons.access_time_rounded,
        'color': colors['darkGray']!,
      });
    }
    
    // ✅ Fallback jika tidak ada compatibility
    if (compatibilities.isEmpty) {
      compatibilities.addAll([
        {
          'label': 'Casual',
          'icon': Icons.weekend_rounded,
          'color': colors['mediumGray']!,
        },
        {
          'label': 'Comfortable',
          'icon': Icons.sentiment_satisfied_rounded,
          'color': colors['neonGreen']!,
        },
      ]);
    }
    
    return compatibilities;
  }


int _calculateColorHarmonyScoreForItem(String itemColor, Map<String, dynamic> item) {
  // Get outfit items untuk analyze color harmony
  final outfitItems = widget.result['outfit'] as List<dynamic>? ?? [];
  
  // Base score berdasarkan warna
  Map<String, int> colorBaseScores = {
    'black': 95, 'white': 95, 'navy': 90, 'gray': 90, 'beige': 88,
    'blue': 85, 'brown': 85, 'red': 80, 'green': 80, 'purple': 75,
    'yellow': 70, 'pink': 70, 'orange': 65,
  };
  
  int baseScore = colorBaseScores[itemColor] ?? 75;
  
  // Bonus jika ada color coordination dengan items lain
  int coordinationBonus = 0;
  for (var otherItem in outfitItems) {
    if (otherItem['color']?.toString().toLowerCase() == itemColor) {
      coordinationBonus += 5; // Bonus untuk matching colors
    }
  }
  
  // Cap maximum score
  return (baseScore + coordinationBonus).clamp(65, 98);
}


  int _calculateOccasionMatchScore(String itemCategory, String occasion) {
    // Mapping category-occasion compatibility
    Map<String, Map<String, int>> categoryOccasionScores = {
      'tops': {
        'work/office': 95, 'formal meeting': 98, 'casual day': 85, 
        'date night': 88, 'party/event': 80, 'workout/gym': 30, 
        'travel/vacation': 85, 'home/relaxing': 90,
      },
      'bottoms': {
        'work/office': 90, 'formal meeting': 95, 'casual day': 95, 
        'date night': 85, 'party/event': 88, 'workout/gym': 40, 
        'travel/vacation': 90, 'home/relaxing': 95,
      },
      'outerwear': {
        'work/office': 85, 'formal meeting': 90, 'casual day': 95, 
        'date night': 80, 'party/event': 85, 'workout/gym': 60, 
        'travel/vacation': 98, 'home/relaxing': 70,
      },
      'shoes': {
        'work/office': 90, 'formal meeting': 95, 'casual day': 85, 
        'date night': 90, 'party/event': 95, 'workout/gym': 98, 
        'travel/vacation': 85, 'home/relaxing': 60,
      },
      'accessories': {
        'work/office': 80, 'formal meeting': 85, 'casual day': 75, 
        'date night': 95, 'party/event': 98, 'workout/gym': 20, 
        'travel/vacation': 80, 'home/relaxing': 40,
      },
    };
    
    return categoryOccasionScores[itemCategory]?[occasion.toLowerCase()] ?? 75;
  }

  int _calculateWeatherSuitabilityScore(String itemCategory, String weather) {
    // Mapping category-weather compatibility
    Map<String, Map<String, int>> categoryWeatherScores = {
      'tops': {
        'sunny & warm': 85, 'hot & humid': 90, 'mild & pleasant': 95,
        'rainy & cool': 80, 'cold & windy': 70,
      },
      'bottoms': {
        'sunny & warm': 90, 'hot & humid': 85, 'mild & pleasant': 95,
        'rainy & cool': 90, 'cold & windy': 88,
      },
      'outerwear': {
        'sunny & warm': 40, 'hot & humid': 30, 'mild & pleasant': 80,
        'rainy & cool': 98, 'cold & windy': 98,
      },
      'shoes': {
        'sunny & warm': 85, 'hot & humid': 80, 'mild & pleasant': 90,
        'rainy & cool': 95, 'cold & windy': 90,
      },
      'accessories': {
        'sunny & warm': 70, 'hot & humid': 65, 'mild & pleasant': 80,
        'rainy & cool': 75, 'cold & windy': 85,
      },
    };
    
    return categoryWeatherScores[itemCategory]?[weather.toLowerCase()] ?? 75;
  }

  int _calculateStyleCoherenceScore(String itemCategory, String style) {
    // Mapping category-style compatibility
    Map<String, Map<String, int>> categoryStyleScores = {
      'tops': {
        'professional': 95, 'classic': 90, 'minimalist': 90, 'trendy': 85,
        'bohemian': 75, 'edgy': 80, 'romantic': 85, 'sporty': 70,
      },
      'bottoms': {
        'professional': 90, 'classic': 95, 'minimalist': 95, 'trendy': 88,
        'bohemian': 80, 'edgy': 85, 'romantic': 75, 'sporty': 90,
      },
      'outerwear': {
        'professional': 85, 'classic': 90, 'minimalist': 85, 'trendy': 90,
        'bohemian': 88, 'edgy': 95, 'romantic': 75, 'sporty': 85,
      },
      'shoes': {
        'professional': 90, 'classic': 85, 'minimalist': 80, 'trendy': 95,
        'bohemian': 85, 'edgy': 90, 'romantic': 88, 'sporty': 98,
      },
      'accessories': {
        'professional': 75, 'classic': 80, 'minimalist': 70, 'trendy': 95,
        'bohemian': 98, 'edgy': 95, 'romantic': 98, 'sporty': 60,
      },
    };
    
    return categoryStyleScores[itemCategory]?[style.toLowerCase()] ?? 75;
  }

  // ✅ TAMBAH description methods yang dinamis
  String _getColorHarmonyDescription(int score, String color) {
    if (score >= 90) return 'Excellent color coordination with perfect palette balance';
    if (score >= 80) return 'Good color harmony with complementary tones';
    if (score >= 70) return 'Decent color matching with room for improvement';
    return 'Color coordination could be enhanced for better harmony';
  }

  String _getOccasionMatchDescription(int score, String occasion) {
    if (score >= 95) return 'Perfect match for ${occasion.toLowerCase()} settings';
    if (score >= 85) return 'Very suitable for ${occasion.toLowerCase()} occasions';
    if (score >= 75) return 'Appropriate for ${occasion.toLowerCase()} with minor adjustments';
    return 'May need styling adjustments for ${occasion.toLowerCase()}';
  }

  String _getWeatherSuitabilityDescription(int score, String weather) {
    if (score >= 90) return 'Optimally designed for ${weather.toLowerCase()} conditions';
    if (score >= 80) return 'Well-suited for ${weather.toLowerCase()} weather';
    if (score >= 70) return 'Adequate for ${weather.toLowerCase()} with layering options';
    return 'Consider weather-appropriate alternatives for ${weather.toLowerCase()}';
  }

  String _getStyleCoherenceDescription(int score, String style) {
    if (score >= 90) return 'Perfectly embodies ${style.toLowerCase()} aesthetic principles';
    if (score >= 80) return 'Strong alignment with ${style.toLowerCase()} style elements';
    if (score >= 70) return 'Good fit for ${style.toLowerCase()} with minor style notes';
    return 'Style elements could be refined for better ${style.toLowerCase()} coherence';
  }
  
  Widget _buildAnalysisMetrics(Map<String, dynamic> item) {
    final metrics = _getItemMetrics(item);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors['pureWhite'],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors['shadowColor']!,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analysis Metrics',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors['darkGray'],
            ),
          ),
          SizedBox(height: 16),

          ...metrics.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildMetricRow(
                entry.key,
                entry.value['score'] as int,
                entry.value['color'] as Color,
                entry.value['description'] as String,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    String label,
    int score,
    Color color,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors['darkGray'],
              ),
            ),
            Text(
              '$score%',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),

        Container(
          height: 6,
          decoration: BoxDecoration(
            color: colors['lightGray'],
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: score / 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),

        SizedBox(height: 4),

        Text(
          description,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: colors['mediumGray'],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildStyleCompatibility(Map<String, dynamic> item) {
    final compatibilities = _getStyleCompatibilities(item);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors['neonGreen']!.withValues(alpha: 0.15),
            colors['deepTeal']!.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors['neonGreen']!.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_rounded, color: colors['neonGreen'], size: 20),
              SizedBox(width: 8),
              Text(
                'Style Compatibility',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: colors['darkGray'],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                compatibilities
                    .map(
                      (compatibility) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: compatibility['color'] as Color,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: (compatibility['color'] as Color)
                                  .withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              compatibility['icon'] as IconData,
                              color: colors['pureWhite'],
                              size: 14,
                            ),
                            SizedBox(width: 6),
                            Text(
                              compatibility['label'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: colors['pureWhite'],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'outerwear':
        return colors['vibrantPurple']!;
      case 'tops':
        return colors['electricBlue']!;
      case 'bottoms':
        return colors['sunsetOrange']!;
      case 'shoes':
        return colors['neonGreen']!;
      case 'accessories':
        return colors['hotPink']!;
      case 'bags':
        return colors['deepTeal']!;
      default:
        return colors['primaryBlue']!;
    }
  }
  IconData _getCategoryIconData(String? category) {
    switch (category?.toLowerCase()) {
      case 'outerwear':
        return Icons.dry_cleaning_rounded;
      case 'tops':
        return Icons.checkroom_rounded;
      case 'bottoms':
        return Icons.local_laundry_service_rounded;
      case 'shoes':
        return Icons.sports_handball_rounded;
      case 'accessories':
        return Icons.watch_rounded;
      case 'bags':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  // ✅ TAMBAHKAN SEMUA HELPER METHODS INI

  // Calculate real style coherence
  int _calculateOverallStyleScore() {
    final outfitItems = widget.result['outfit'] as List<dynamic>? ?? [];
    if (outfitItems.isEmpty) return 75;
    
    int totalScore = 0;
    int itemCount = 0;
    
    for (var item in outfitItems) {
      final category = item['category']?.toString().toLowerCase() ?? '';
      final score = _calculateStyleCoherenceScoreForItem(category, widget.style);
      totalScore += score;
      itemCount++;
    }
    
    return itemCount > 0 ? (totalScore / itemCount).round() : 75;
  }

  // Calculate color harmony based on actual items
  int _calculateColorHarmonyScore(List<dynamic> items) {
    if (items.isEmpty) return 75;
    
    // Get unique colors
    Set<String> colors = {};
    for (var item in items) {
      final color = item['color']?.toString().toLowerCase();
      if (color != null && color.isNotEmpty) {
        colors.add(color);
      }
    }
    
    // Score based on color coordination
    if (colors.length <= 2) return 95; // Monochromatic/complementary
    if (colors.length == 3) return 85; // Triadic
    if (colors.length == 4) return 75; // Complex but workable
    return 65; // Too many colors
  }

  // Calculate occasion appropriateness
  int _calculateOccasionScore() {
    final outfitItems = widget.result['outfit'] as List<dynamic>? ?? [];
    if (outfitItems.isEmpty) return 75;
    
    int totalScore = 0;
    int itemCount = 0;
    
    for (var item in outfitItems) {
      final category = item['category']?.toString().toLowerCase() ?? '';
      final score = _calculateOccasionMatchScoreForItem(category, widget.occasion);
      totalScore += score;
      itemCount++;
    }
    
    return itemCount > 0 ? (totalScore / itemCount).round() : 75;
  }

  // Calculate weather suitability
  int _calculateWeatherScore() {
    final outfitItems = widget.result['outfit'] as List<dynamic>? ?? [];
    if (outfitItems.isEmpty) return 75;
    
    int totalScore = 0;
    int itemCount = 0;
    
    for (var item in outfitItems) {
      final category = item['category']?.toString().toLowerCase() ?? '';
      final score = _calculateWeatherSuitabilityScoreForItem(category, widget.weather);
      totalScore += score;
      itemCount++;
    }
    
    return itemCount > 0 ? (totalScore / itemCount).round() : 75;
  }

  // Generate real style tips based on actual outfit
  List<Map<String, dynamic>> _generateRealStyleTips(List<dynamic> items) {
    List<Map<String, dynamic>> tips = [];
    
    if (items.isEmpty) {
      return [
        {
          'title': 'AI Recommendations',
          'description': 'Generate an outfit to receive personalized style tips.',
          'icon': Icons.lightbulb_outline_rounded,
          'color': colors['mediumGray']!,
        }
      ];
    }
    
    // Analyze actual items for tips
    final categories = items.map((item) => item['category']?.toString().toLowerCase()).toSet();
    final itemColors = items.map((item) => item['color']?.toString().toLowerCase()).toSet();
    
    // Color coordination tip
    if (itemColors.length <= 2) {
      tips.add({
        'title': 'Perfect Color Harmony',
        'description': 'Your ${itemColors.join(' and ')} color palette creates excellent visual balance and sophistication.',
        'icon': Icons.palette_rounded,
        'color': colors['sunsetOrange']!,
      });
    } else if (itemColors.length == 3) {
      tips.add({
        'title': 'Balanced Color Mix',
        'description': 'The three-color combination adds visual interest while maintaining harmony.',
        'icon': Icons.palette_rounded,
        'color': colors['sunsetOrange']!,
      });
    }
    
    // Occasion appropriateness tip
    if (_calculateOccasionScore() >= 90) {
      tips.add({
        'title': 'Occasion Perfect',
        'description': 'This outfit is exceptionally well-suited for ${widget.occasion.toLowerCase()} settings.',
        'icon': Icons.event_rounded,
        'color': colors['neonGreen']!,
      });
    }
    
    // Layering tip based on weather
    if (widget.weather.toLowerCase().contains('cool') || widget.weather.toLowerCase().contains('cold')) {
      if (categories.contains('outerwear')) {
        tips.add({
          'title': 'Smart Layering',
          'description': 'The outerwear piece provides perfect weather protection while maintaining style.',
          'icon': Icons.layers_rounded,
          'color': colors['electricBlue']!,
        });
      }
    }
    
    // Style coherence tip
    if (_calculateOverallStyleScore() >= 90) {
      tips.add({
        'title': 'Style Mastery',
        'description': 'Your outfit perfectly embodies ${widget.style.toLowerCase()} aesthetic principles.',
        'icon': Icons.auto_awesome_rounded,
        'color': colors['vibrantPurple']!,
      });
    }
    
    // Default tip if no specific tips generated
    if (tips.isEmpty) {
      tips.add({
        'title': 'Versatile Selection',
        'description': 'This combination offers great flexibility for various situations.',
        'icon': Icons.tune_rounded,
        'color': colors['primaryBlue']!,
      });
    }
    
    return tips;
  }

  // Generate real alternatives based on current outfit
  List<Map<String, dynamic>> _generateRealAlternatives(List<dynamic> items) {
    List<Map<String, dynamic>> alternatives = [];
    
    if (items.isEmpty) return alternatives;
    
    // Create variations based on current items
    items.map((item) => item['category']?.toString()).toList();
    final currentNames = items.map((item) => item['name']?.toString()).toList();
    
    // Suggest seasonal alternative
    if (widget.weather.toLowerCase().contains('warm')) {
      alternatives.add({
        'name': 'Summer Variation',
        'rating': 4.7,
        'items': currentNames.take(2).toList() + ['Light Accessories'],
        'style': 'Breathable & Cool',
        'description': 'Lighter version perfect for warmer weather',
      });
    } else if (widget.weather.toLowerCase().contains('cold')) {
      alternatives.add({
        'name': 'Winter Layered',
        'rating': 4.8,
        'items': currentNames + ['Warm Scarf'],
        'style': 'Cozy & Stylish',
        'description': 'Enhanced warmth without sacrificing style',
      });
    }
    
    // Suggest occasion alternative
    if (widget.occasion.toLowerCase().contains('casual')) {
      alternatives.add({
        'name': 'Elevated Casual',
        'rating': 4.6,
        'items': currentNames.map((name) => name?.replaceAll(RegExp(r'Casual|Basic'), 'Premium') ?? 'Premium Item').toList(),
        'style': 'Refined Casual',
        'description': 'Same comfort, elevated sophistication',
      });
    }
    
    return alternatives;
  }

  // Helper method for real analysis items
  Widget _buildRealAnalysisItem(
    String title,
    String description,
    IconData icon,
    int percentage,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colors['pureWhite'], size: 16),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors['darkGray'],
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: colors['mediumGray'],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$percentage%',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Real alternative card builder
  Widget _buildRealAlternativeCard(Map<String, dynamic> alternative) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors['pureWhite'],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors['shadowColor']!,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors['primaryBlue']!, colors['electricBlue']!],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: colors['pureWhite'],
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alternative['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors['darkGray'],
                      ),
                    ),
                    Text(
                      alternative['style'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: colors['mediumGray'],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star_rounded, color: colors['accentYellow'], size: 16),
                  SizedBox(width: 4),
                  Text(
                    '${alternative['rating']}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors['darkGray'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (alternative['description'] != null) ...[
            SizedBox(height: 8),
            Text(
              alternative['description'],
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: colors['mediumGray'],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Status and color helpers for insights
  String _getWeatherStatus(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Good';
    if (score >= 70) return 'Fair';
    return 'Poor';
  }

  String _getOccasionStatus(int score) {
    if (score >= 95) return 'Perfect';
    if (score >= 85) return 'Great';
    if (score >= 75) return 'Good';
    return 'Fair';
  }

  String _getStyleStatus(int score) {
    if (score >= 90) return 'Trending';
    if (score >= 80) return 'Stylish';
    if (score >= 70) return 'Good';
    return 'Basic';
  }

  Color _getWeatherColor(int score) {
    if (score >= 90) return colors['neonGreen']!;
    if (score >= 80) return Colors.orange;
    if (score >= 70) return colors['accentYellow']!;
    return colors['accentRed']!;
  }

  Color _getOccasionColor(int score) {
    if (score >= 95) return colors['neonGreen']!;
    if (score >= 85) return colors['electricBlue']!;
    if (score >= 75) return colors['accentYellow']!;
    return colors['accentRed']!;
  }

  Color _getStyleColor(int score) {
    if (score >= 90) return colors['vibrantPurple']!;
    if (score >= 80) return colors['primaryBlue']!;
    if (score >= 70) return colors['accentYellow']!;
    return colors['mediumGray']!;
  }

  // Additional helper methods for analysis
  String _getStyleCoherenceAnalysis() {
    final score = _calculateOverallStyleScore();
    if (score >= 90) return 'Exceptional ${widget.style.toLowerCase()} style alignment detected';
    if (score >= 80) return 'Strong ${widget.style.toLowerCase()} style coherence';
    if (score >= 70) return 'Good ${widget.style.toLowerCase()} style compatibility';
    return 'Basic ${widget.style.toLowerCase()} style elements present';
  }

  String _getColorHarmonyAnalysis(List<dynamic> items) {
    final score = _calculateColorHarmonyScore(items);
    final itemColors = items.map((item) => item['color']?.toString()).where((c) => c != null).toSet();
    
    if (score >= 90) return 'Perfect ${itemColors.length}-color harmony achieved';
    if (score >= 80) return 'Excellent color coordination with ${itemColors.length} tones';
    if (score >= 70) return 'Good color balance maintained';
    return 'Color coordination needs refinement';
  }

  // Helper methods for item-specific calculations
  int _calculateStyleCoherenceScoreForItem(String category, String style) {
    Map<String, Map<String, int>> categoryStyleScores = {
      'tops': {
        'professional': 95, 'classic': 90, 'minimalist': 90, 'trendy': 85,
        'bohemian': 75, 'edgy': 80, 'romantic': 85, 'sporty': 70,
      },
      'bottoms': {
        'professional': 90, 'classic': 95, 'minimalist': 95, 'trendy': 88,
        'bohemian': 80, 'edgy': 85, 'romantic': 75, 'sporty': 90,
      },
      'outerwear': {
        'professional': 85, 'classic': 90, 'minimalist': 85, 'trendy': 90,
        'bohemian': 88, 'edgy': 95, 'romantic': 75, 'sporty': 85,
      },
      'shoes': {
        'professional': 90, 'classic': 85, 'minimalist': 80, 'trendy': 95,
        'bohemian': 85, 'edgy': 90, 'romantic': 88, 'sporty': 98,
      },
      'accessories': {
        'professional': 75, 'classic': 80, 'minimalist': 70, 'trendy': 95,
        'bohemian': 98, 'edgy': 95, 'romantic': 98, 'sporty': 60,
      },
    };
    
    return categoryStyleScores[category]?[style.toLowerCase()] ?? 75;
  }

  int _calculateOccasionMatchScoreForItem(String category, String occasion) {
    Map<String, Map<String, int>> categoryOccasionScores = {
      'tops': {
        'work/office': 95, 'formal meeting': 98, 'casual day': 85, 
        'date night': 88, 'party/event': 80, 'workout/gym': 30, 
        'travel/vacation': 85, 'home/relaxing': 90,
      },
      'bottoms': {
        'work/office': 90, 'formal meeting': 95, 'casual day': 95, 
        'date night': 85, 'party/event': 88, 'workout/gym': 40, 
        'travel/vacation': 90, 'home/relaxing': 95,
      },
      'outerwear': {
        'work/office': 85, 'formal meeting': 90, 'casual day': 95, 
        'date night': 80, 'party/event': 85, 'workout/gym': 60, 
        'travel/vacation': 98, 'home/relaxing': 70,
      },
      'shoes': {
        'work/office': 90, 'formal meeting': 95, 'casual day': 85, 
        'date night': 90, 'party/event': 95, 'workout/gym': 98, 
        'travel/vacation': 85, 'home/relaxing': 60,
      },
      'accessories': {
        'work/office': 80, 'formal meeting': 85, 'casual day': 75, 
        'date night': 95, 'party/event': 98, 'workout/gym': 20, 
        'travel/vacation': 80, 'home/relaxing': 40,
      },
    };
    
    return categoryOccasionScores[category]?[occasion.toLowerCase()] ?? 75;
  }

  int _calculateWeatherSuitabilityScoreForItem(String category, String weather) {
    Map<String, Map<String, int>> categoryWeatherScores = {
      'tops': {
        'sunny & warm': 85, 'hot & humid': 90, 'mild & pleasant': 95,
        'rainy & cool': 80, 'cold & windy': 70,
      },
      'bottoms': {
        'sunny & warm': 90, 'hot & humid': 85, 'mild & pleasant': 95,
        'rainy & cool': 90, 'cold & windy': 88,
      },
      'outerwear': {
        'sunny & warm': 40, 'hot & humid': 30, 'mild & pleasant': 80,
        'rainy & cool': 98, 'cold & windy': 98,
      },
      'shoes': {
        'sunny & warm': 85, 'hot & humid': 80, 'mild & pleasant': 90,
        'rainy & cool': 95, 'cold & windy': 90,
      },
      'accessories': {
        'sunny & warm': 70, 'hot & humid': 65, 'mild & pleasant': 80,
        'rainy & cool': 75, 'cold & windy': 85,
      },
    };
    
    return categoryWeatherScores[category]?[weather.toLowerCase()] ?? 75;
  }
}

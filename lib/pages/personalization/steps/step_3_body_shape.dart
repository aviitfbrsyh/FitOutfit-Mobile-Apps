import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/personalization_data.dart';

class Step3BodyShape extends StatefulWidget {
  final PersonalizationData data;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final VoidCallback onChanged;

  const Step3BodyShape({
    super.key,
    required this.data,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.onChanged,
  });

  @override
  State<Step3BodyShape> createState() => _Step3BodyShapeState();
}

class _Step3BodyShapeState extends State<Step3BodyShape>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color softGray = Color(0xFFF8F9FA);

  String? _hoveredShape;
  bool _showComparison = false;
  bool _showMeasurementGuide = false;

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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 200,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Enhanced Header
                  _buildPremiumHeader(),

                  const SizedBox(height: 32),

                  // Interactive Guide Section (Compact)
                  _buildInteractiveGuideSection(),

                  const SizedBox(height: 32),

                  // Main Body Shape Selection Section
                  _buildBodyShapeSelectionSection(),

                  const SizedBox(height: 32),

                  // Additional Info Section
                  if (widget.data.selectedBodyShape != null)
                    _buildSelectedShapeInfo(),

                  const SizedBox(height: 32),

                  // Benefits Section
                  _buildBenefitsSection(),

                  const SizedBox(height: 24),

                  // Tips Section
                  _buildTipsSection(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
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
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          // Animated body shape icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryBlue, accentYellow],
                      stops: [0.3, 0.9],
                    ),
                    borderRadius: BorderRadius.circular(45),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withValues(alpha: 0.4),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.accessibility_new_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Enhanced title with gradient
          ShaderMask(
            shaderCallback:
                (bounds) => const LinearGradient(
                  colors: [primaryBlue, accentYellow],
                ).createShader(bounds),
            child: Text(
              'Your Body Shape',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.8,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Choose the shape that best describes your body type for personalized recommendations',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: darkGray.withValues(alpha: 0.8),
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveGuideSection() {
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
              Icon(Icons.help_outline, color: primaryBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                'Need Help Identifying?',
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
            'Use our quick guides to identify your body shape more accurately',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Measurement Guide',
                  Icons.straighten_rounded,
                  primaryBlue,
                  () => setState(
                    () => _showMeasurementGuide = !_showMeasurementGuide,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Shape Compare',
                  Icons.compare_arrows_rounded,
                  accentYellow,
                  () => setState(() => _showComparison = !_showComparison),
                ),
              ),
            ],
          ),

          if (_showMeasurementGuide) ...[
            const SizedBox(height: 20),
            _buildMeasurementGuide(),
          ],

          if (_showComparison) ...[
            const SizedBox(height: 20),
            _buildShapeComparison(),
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

  Widget _buildSelectedShapeInfo() {
    String selectedShape = widget.data.selectedBodyShape!;
    Map<String, dynamic> shapeData = _getShapeData(selectedShape);

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
                  Icons.favorite_rounded,
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
                      '$selectedShape body shape selected',
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
                  shapeData['description'] as String,
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
                      (shapeData['features'] as List<String>).map((feature) {
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

  Widget _buildBenefitsSection() {
    final benefits = [
      {
        'icon': Icons.style_rounded,
        'title': 'Perfect Fit',
        'desc': 'Clothes that flatter your shape',
      },
      {
        'icon': Icons.favorite_rounded,
        'title': 'Confidence',
        'desc': 'Look and feel amazing',
      },
      {
        'icon': Icons.trending_up_rounded,
        'title': 'Style Goals',
        'desc': 'Achieve your fashion dreams',
      },
    ];

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
              Icon(Icons.auto_awesome, color: accentYellow, size: 24),
              const SizedBox(width: 12),
              Text(
                'Why Body Shape Matters',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkGray,
                ),
              ),
            ],
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

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue.withValues(alpha: 0.08), Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryBlue.withValues(alpha: 0.2)),
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
                  'Style Tip',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: darkGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Remember, these are guidelines! Fashion is about expressing yourself and feeling confident in what you wear.',
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

  Map<String, dynamic> _getDetailedBodyShapeData(String shape) {
    // Check if it's male body shape
    if (widget.data.selectedGender == 'Male') {
      switch (shape) {
        case 'Rectangle':
          return {
            'percentage': '35%',
            'tagline': 'Build a powerful and confident silhouette',
            'visualDescription':
                'Athletic, straight build with similar measurements across chest, waist, and hips - the foundation of masculine strength.',
            'characteristics': [
              'Similar chest, waist, and hip measurements',
              'Athletic, straight build',
              'Minimal waist definition',
              'Lean muscle distribution',
              'Natural athletic appearance',
            ],
            'styleCategories': {
              'Shirts & Tops': [
                'Layered looks',
                'Textured fabrics',
                'Horizontal stripes',
                'Fitted henley',
                'Structured polo',
              ],
              'Suits & Blazers': [
                'Structured shoulders',
                'Double-breasted',
                'Textured blazers',
                'Layered vests',
                'Statement lapels',
              ],
              'Casual Wear': [
                'Fitted jeans',
                'Chinos with texture',
                'Layered outerwear',
                'Contrast colors',
                'Structured jackets',
              ],
              'Outerwear': [
                'Bomber jackets',
                'Structured coats',
                'Layered looks',
                'Textured materials',
              ],
            },
            'celebrities': [
              'Ryan Gosling',
              'Brad Pitt',
              'Orlando Bloom',
              'Keanu Reeves',
              'Matt Damon',
            ],
            'dos': [
              'Add dimension with layered clothing',
              'Use textured fabrics and patterns',
              'Create visual interest with color blocking',
              'Choose structured fits that add shape',
              'Experiment with different textures',
            ],
            'donts': [
              'Avoid shapeless, baggy clothing',
              'Don\'t wear all monotone outfits',
              'Skip too-loose fitting clothes',
              'Avoid minimal, plain styling',
              'Don\'t ignore proportions',
            ],
          };
        case 'Triangle':
          return {
            'percentage': '28%',
            'tagline': 'Showcase your powerful upper body with confidence',
            'visualDescription':
                'Broad shoulders and chest with a narrower waist - the classic masculine V-shape that commands presence.',
            'characteristics': [
              'Broader shoulders and chest area',
              'Well-developed upper body',
              'Narrower waist and hips',
              'Natural V-shaped silhouette',
              'Strong, athletic build',
            ],
            'styleCategories': {
              'Shirts & Tops': [
                'Fitted cuts',
                'V-neck shirts',
                'Slim fit polo',
                'Tailored button-downs',
                'Minimal structure',
              ],
              'Suits & Blazers': [
                'Slim fit suits',
                'Single-breasted',
                'Minimal padding',
                'Clean lines',
                'Tailored fit',
              ],
              'Casual Wear': [
                'Straight leg jeans',
                'Fitted chinos',
                'Slim cut shorts',
                'Tailored casuals',
                'Clean silhouettes',
              ],
              'Outerwear': [
                'Fitted jackets',
                'Minimal bulk',
                'Clean lines',
                'Structured coats',
              ],
            },
            'celebrities': [
              'Chris Hemsworth',
              'Ryan Reynolds',
              'Michael B. Jordan',
              'Chris Evans',
              'Henry Cavill',
            ],
            'dos': [
              'Emphasize your natural V-shape',
              'Choose fitted, tailored clothing',
              'Keep silhouettes clean and streamlined',
              'Highlight your strong upper body',
              'Maintain balanced proportions',
            ],
            'donts': [
              'Avoid adding bulk to shoulders',
              'Don\'t wear oversized tops',
              'Skip horizontal stripes on chest',
              'Avoid too much structure on top',
              'Don\'t hide your natural shape',
            ],
          };
        case 'Inverted Triangle':
          return {
            'percentage': '20%',
            'tagline': 'Balance your athletic build with smart styling',
            'visualDescription':
                'Strong, broad shoulders tapering to a narrower waist - the powerful athlete\'s silhouette that exudes strength.',
            'characteristics': [
              'Very broad shoulders',
              'Well-developed chest and arms',
              'Narrow waist and hips',
              'Athletic, muscular build',
              'Pronounced V-shaped torso',
            ],
            'styleCategories': {
              'Shirts & Tops': [
                'Soft shoulders',
                'Unstructured fits',
                'Flowing fabrics',
                'Minimal chest details',
                'Clean necklines',
              ],
              'Suits & Blazers': [
                'Soft construction',
                'Unpadded shoulders',
                'Relaxed fit',
                'Single-breasted',
                'Natural drape',
              ],
              'Casual Wear': [
                'Straight fits',
                'Hip emphasis',
                'Balanced proportions',
                'Relaxed cuts',
                'Comfortable fits',
              ],
              'Outerwear': [
                'Unstructured jackets',
                'Soft blazers',
                'Hip-length coats',
                'Relaxed fits',
              ],
            },
            'celebrities': [
              'Dwayne Johnson',
              'John Cena',
              'Vin Diesel',
              'Jason Momoa',
              'Terry Crews',
            ],
            'dos': [
              'Balance proportions with softer lines',
              'Choose unstructured, relaxed fits',
              'Add visual weight to lower body',
              'Opt for comfortable, natural drapes',
              'Create harmony between upper and lower body',
            ],
            'donts': [
              'Avoid structured, padded shoulders',
              'Don\'t emphasize chest width further',
              'Skip tight-fitting bottoms',
              'Avoid horizontal stripes on top',
              'Don\'t choose overly fitted tops',
            ],
          };
        case 'Oval':
          return {
            'percentage': '12%',
            'tagline': 'Create a strong, confident silhouette with style',
            'visualDescription':
                'Rounded midsection with broader chest - embrace your solid, powerful presence with strategic styling.',
            'characteristics': [
              'Fuller midsection',
              'Broader chest area',
              'Rounder torso shape',
              'Less defined waistline',
              'Solid, substantial build',
            ],
            'styleCategories': {
              'Shirts & Tops': [
                'Vertical lines',
                'V-neck cuts',
                'Open collars',
                'Structured fits',
                'Elongating styles',
              ],
              'Suits & Blazers': [
                'Single-breasted',
                'Longer jackets',
                'Vertical details',
                'Structured shoulders',
                'Clean lines',
              ],
              'Casual Wear': [
                'Straight leg pants',
                'Dark colors',
                'Vertical stripes',
                'Structured fits',
                'Quality fabrics',
              ],
              'Outerwear': [
                'Open jackets',
                'Long coats',
                'Vertical emphasis',
                'Structured fits',
              ],
            },
            'celebrities': [
              'Jack Black',
              'Jonah Hill',
              'James Corden',
              'Kevin James',
              'Russell Crowe',
            ],
            'dos': [
              'Create vertical lines to elongate',
              'Choose structured, tailored fits',
              'Emphasize your strong presence',
              'Use quality fabrics that drape well',
              'Maintain clean, sharp lines',
            ],
            'donts': [
              'Avoid tight-fitting clothes around middle',
              'Don\'t wear horizontal stripes',
              'Skip cropped jackets',
              'Avoid bulky layers around waist',
              'Don\'t choose shapeless clothing',
            ],
          };
        case 'Trapezoid':
          return {
            'percentage': '5%',
            'tagline': 'Build a balanced, powerful masculine silhouette',
            'visualDescription':
                'Broader shoulders with a fuller waist and narrower hips - create balance and strength with smart styling choices.',
            'characteristics': [
              'Broad shoulders',
              'Fuller waist area',
              'Narrower hips',
              'Athletic upper body',
              'Substantial midsection',
            ],
            'styleCategories': {
              'Shirts & Tops': [
                'Straight cuts',
                'Minimal waist emphasis',
                'Clean lines',
                'Structured fits',
                'Quality materials',
              ],
              'Suits & Blazers': [
                'Straight silhouettes',
                'Minimal waist suppression',
                'Clean construction',
                'Quality tailoring',
                'Classic fits',
              ],
              'Casual Wear': [
                'Straight leg pants',
                'Hip emphasis',
                'Balanced cuts',
                'Quality fabrics',
                'Classic styles',
              ],
              'Outerwear': [
                'Straight jackets',
                'Hip-length coats',
                'Balanced proportions',
                'Classic cuts',
              ],
            },
            'celebrities': [
              'Hugh Jackman',
              'Russell Wilson',
              'Mark Wahlberg',
              'Channing Tatum',
              'Josh Brolin',
            ],
            'dos': [
              'Create balance with straight lines',
              'Choose quality, well-tailored pieces',
              'Emphasize your strong build',
              'Maintain clean, classic proportions',
              'Focus on fit and quality',
            ],
            'donts': [
              'Avoid emphasizing waist area',
              'Don\'t choose too-fitted clothing',
              'Skip horizontal details at waist',
              'Avoid bulky layers',
              'Don\'t ignore proper fit',
            ],
          };
        default:
          return {
            'percentage': '0%',
            'tagline': 'Every man\'s body is unique and powerful',
            'visualDescription':
                'Your unique masculine build deserves personalized styling that reflects your strength and character.',
            'characteristics': ['Every man\'s body is unique and strong'],
            'styleCategories': {
              'General': ['Confidence', 'Quality', 'Fit'],
            },
            'celebrities': ['You'],
            'dos': ['Wear what makes you feel confident and powerful'],
            'donts': ['Don\'t let anyone define your masculine style'],
          };
      }
    } else {
      // Female body shapes (existing data from step_3_body_shape.dart)
      switch (shape) {
        case 'Apple':
          return {
            'percentage': '23%',
            'tagline': 'Embrace your natural elegance and confidence',
            'visualDescription':
                'Fuller midsection with broader shoulders and bust, creating a beautiful upper body silhouette.',
            'characteristics': [
              'Broader shoulders and chest area',
              'Fuller bust that draws attention upward',
              'Less defined waistline',
              'Narrower hips compared to upper body',
              'Weight tends to be carried in the midsection',
            ],
            'styleCategories': {
              'Tops & Blouses': [
                'Empire waist',
                'V-neck',
                'Scoop neck',
                'Wrap tops',
                'Peplum',
                'Tunic style',
              ],
              'Dresses': [
                'A-line',
                'Empire waist',
                'Wrap dress',
                'Shift dress',
                'Maxi with defined waist',
              ],
              'Bottoms': [
                'High-waisted',
                'Straight leg',
                'Bootcut',
                'Wide leg',
                'A-line skirts',
              ],
              'Outerwear': [
                'Open cardigans',
                'Structured blazers',
                'Long coats',
                'Waterfall jackets',
              ],
            },
            'celebrities': [
              'Adele',
              'Oprah Winfrey',
              'Jennifer Hudson',
              'Rebel Wilson',
              'Amy Schumer',
            ],
            'dos': [
              'Emphasize your legs with great pants',
              'Choose tops that flow away from your body',
              'Wear V-necks to elongate your torso',
              'Add accessories to draw attention up or down',
              'Choose structured shoulders for balance',
            ],
            'donts': [
              'Avoid tight-fitting tops around the midsection',
              'Skip horizontal stripes across the middle',
              'Don\'t wear belts at your natural waist',
              'Avoid bulky layers around the middle',
              'Skip cropped jackets that hit at the waist',
            ],
          };
        case 'Pear':
          return {
            'percentage': '34%',
            'tagline': 'Celebrate your feminine curves and grace',
            'visualDescription':
                'Narrower shoulders with fuller hips, creating the classic feminine silhouette.',
            'characteristics': [
              'Narrower shoulders and smaller bust',
              'Well-defined waistline',
              'Fuller hips and thighs',
              'Weight carried primarily in lower body',
              'Proportionally smaller upper body',
            ],
            'styleCategories': {
              'Tops & Blouses': [
                'Boat neck',
                'Off-shoulder',
                'Statement sleeves',
                'Structured shoulders',
                'Bright colors',
              ],
              'Dresses': [
                'A-line',
                'Fit-and-flare',
                'Empire waist',
                'Wrap dress with emphasis on top',
              ],
              'Bottoms': [
                'Straight leg',
                'Bootcut',
                'Dark colors',
                'High-waisted',
                'A-line skirts',
              ],
              'Outerwear': [
                'Structured blazers',
                'Cropped jackets',
                'Statement coats',
                'Wide lapels',
              ],
            },
            'celebrities': [
              'Beyoncé',
              'Jennifer Lopez',
              'Shakira',
              'Rihanna',
              'Kim Kardashian',
            ],
            'dos': [
              'Emphasize your upper body with details',
              'Wear bright colors and patterns on top',
              'Choose structured shoulders',
              'Highlight your defined waist',
              'Wear statement necklaces and earrings',
            ],
            'donts': [
              'Avoid tight-fitting bottoms',
              'Skip horizontal stripes on hips',
              'Don\'t wear baggy tops',
              'Avoid pockets on hips',
              'Skip tapered pants',
            ],
          };
        case 'Hourglass':
          return {
            'percentage': '18%',
            'tagline': 'The perfect balance of feminine curves',
            'visualDescription':
                'Balanced bust and hips with a well-defined waist - the classic hourglass silhouette.',
            'characteristics': [
              'Balanced bust and hip measurements',
              'Well-defined, narrow waistline',
              'Proportional upper and lower body',
              'Natural curves that create an hourglass shape',
              'Weight distributed evenly',
            ],
            'styleCategories': {
              'Tops & Blouses': [
                'Fitted',
                'Wrap style',
                'V-neck',
                'Scoop neck',
                'Button-down',
              ],
              'Dresses': [
                'Bodycon',
                'Wrap dress',
                'Fit-and-flare',
                'Sheath',
                'Mermaid',
              ],
              'Bottoms': [
                'High-waisted',
                'Fitted',
                'Straight leg',
                'Pencil skirts',
                'A-line',
              ],
              'Outerwear': [
                'Belted coats',
                'Fitted blazers',
                'Wrap coats',
                'Cropped jackets',
              ],
            },
            'celebrities': [
              'Marilyn Monroe',
              'Scarlett Johansson',
              'Sofia Vergara',
              'Christina Hendricks',
              'Salma Hayek',
            ],
            'dos': [
              'Emphasize your waistline',
              'Choose fitted clothing',
              'Wear belts to highlight your waist',
              'Embrace your natural curves',
              'Choose quality fabrics that drape well',
            ],
            'donts': [
              'Avoid baggy, shapeless clothing',
              'Don\'t hide your waistline',
              'Skip boxy, oversized tops',
              'Avoid too much layering',
              'Don\'t wear low-rise bottoms',
            ],
          };
        case 'Rectangle':
          return {
            'percentage': '20%',
            'tagline': 'Create beautiful curves with strategic styling',
            'visualDescription':
                'Straight silhouette with similar bust, waist, and hip measurements.',
            'characteristics': [
              'Similar measurements for bust, waist, and hips',
              'Straight, athletic build',
              'Less defined waistline',
              'Minimal natural curves',
              'Often tall and lean appearance',
            ],
            'styleCategories': {
              'Tops & Blouses': [
                'Peplum',
                'Ruffles',
                'Layers',
                'Crop tops',
                'Textured fabrics',
              ],
              'Dresses': [
                'Fit-and-flare',
                'A-line',
                'Wrap dress',
                'Tiered',
                'Belted',
              ],
              'Bottoms': [
                'High-waisted',
                'Flared',
                'Pleated',
                'Textured',
                'Patterned',
              ],
              'Outerwear': [
                'Belted jackets',
                'Peplum blazers',
                'Cropped styles',
                'Textured coats',
              ],
            },
            'celebrities': [
              'Gwyneth Paltrow',
              'Cameron Diaz',
              'Keira Knightley',
              'Taylor Swift',
              'Kate Middleton',
            ],
            'dos': [
              'Create curves with strategic styling',
              'Use belts to define your waist',
              'Add texture and volume',
              'Layer clothing for dimension',
              'Choose interesting necklines',
            ],
            'donts': [
              'Avoid shapeless, boxy clothing',
              'Don\'t wear all straight lines',
              'Skip minimalist styling',
              'Avoid too-loose fitting clothes',
              'Don\'t ignore your waistline',
            ],
          };
        case 'Inverted Triangle':
          return {
            'percentage': '5%',
            'tagline': 'Balance your strong shoulders with elegant styling',
            'visualDescription':
                'Broader shoulders with narrower hips, creating an athletic silhouette.',
            'characteristics': [
              'Broader shoulders than hips',
              'Athletic, strong upper body',
              'Narrower hip area',
              'Minimal waist definition',
              'Often tall with long legs',
            ],
            'styleCategories': {
              'Tops & Blouses': [
                'Soft shoulders',
                'V-neck',
                'Scoop neck',
                'Flowing fabrics',
                'Minimal structure',
              ],
              'Dresses': [
                'A-line',
                'Fit-and-flare',
                'Empire waist',
                'Drop waist',
                'Flowy maxi',
              ],
              'Bottoms': [
                'Wide leg',
                'Flared',
                'Full skirts',
                'High-waisted',
                'Pleated',
              ],
              'Outerwear': [
                'Soft blazers',
                'Draped cardigans',
                'Hip-length jackets',
                'Unstructured coats',
              ],
            },
            'celebrities': [
              'Angelina Jolie',
              'Naomi Campbell',
              'Demi Moore',
              'Renee Zellweger',
              'Teri Hatcher',
            ],
            'dos': [
              'Add volume to your lower body',
              'Choose soft, flowing fabrics',
              'Emphasize your legs',
              'Create hip curves with details',
              'Wear statement accessories below the waist',
            ],
            'donts': [
              'Avoid structured, padded shoulders',
              'Don\'t wear horizontal stripes on top',
              'Skip tight-fitting bottoms',
              'Avoid emphasizing shoulder width',
              'Don\'t wear cropped tops',
            ],
          };
        default:
          return {
            'percentage': '0%',
            'tagline': 'Every body is unique and beautiful',
            'visualDescription':
                'Your unique body shape deserves personalized styling.',
            'characteristics': ['Every body is unique'],
            'styleCategories': {
              'General': ['Confidence'],
            },
            'celebrities': ['You'],
            'dos': ['Wear what makes you feel confident'],
            'donts': ['Don\'t let anyone define your style'],
          };
      }
    }
  }

  Widget _buildStyleRecommendationsSection(
    Map<String, dynamic> detailData,
    Color shapeColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.style_rounded, color: shapeColor, size: 24),
            const SizedBox(width: 12),
            Text(
              'Perfect Styles for You',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _Step3BodyShapeState.darkGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Style categories
        ...((detailData['styleCategories'] as Map<String, List<String>>).entries
            .map((entry) {
              String category = entry.key;
              List<String> styles = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: shapeColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          styles.map((style) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    shapeColor.withValues(alpha: 0.1),
                                    shapeColor.withValues(alpha: 0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: shapeColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                style,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: shapeColor,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              );
            })),
      ],
    );
  }

  Widget _buildCelebrityExamplesSection(
    Map<String, dynamic> detailData,
    Color shapeColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _Step3BodyShapeState.accentYellow.withValues(alpha: 0.08),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _Step3BodyShapeState.accentYellow.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: _Step3BodyShapeState.accentYellow,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Celebrity Inspirations',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _Step3BodyShapeState.darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                (detailData['celebrities'] as List<String>).map((celebrity) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _Step3BodyShapeState.accentYellow.withValues(
                            alpha: 0.15,
                          ),
                          _Step3BodyShapeState.accentYellow.withValues(
                            alpha: 0.05,
                          ),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _Step3BodyShapeState.accentYellow.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_rounded,
                          color: _Step3BodyShapeState.accentYellow,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          celebrity,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _Step3BodyShapeState.accentYellow,
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

  Widget _buildDosAndDontsSection(
    Map<String, dynamic> detailData,
    Color shapeColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Styling Do\'s and Don\'ts',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _Step3BodyShapeState.darkGray,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            // Do's
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _Step3BodyShapeState.primaryBlue.withValues(alpha: 0.08),
                      Colors.white,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _Step3BodyShapeState.primaryBlue.withValues(
                      alpha: 0.2,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: _Step3BodyShapeState.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'DO\'S',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _Step3BodyShapeState.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...(detailData['dos'] as List<String>).map((tip) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.only(top: 8, right: 8),
                              decoration: BoxDecoration(
                                color: _Step3BodyShapeState.primaryBlue,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                tip,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Don'ts
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _Step3BodyShapeState.accentRed.withValues(alpha: 0.08),
                      Colors.white,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _Step3BodyShapeState.accentRed.withValues(
                      alpha: 0.2,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.cancel,
                          color: _Step3BodyShapeState.accentRed,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'DON\'TS',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _Step3BodyShapeState.accentRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...(detailData['donts'] as List<String>).map((tip) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.only(top: 8, right: 8),
                              decoration: BoxDecoration(
                                color: _Step3BodyShapeState.accentRed,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                tip,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModalActionButtons(String shapeName, Color shapeColor) {
    bool isSelected = widget.data.selectedBodyShape == shapeName;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [shapeColor, shapeColor.withValues(alpha: 0.8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: shapeColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                setState(() {
                  widget.data.selectedBodyShape = shapeName;
                });
                widget.onChanged();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : Icons.add_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isSelected ? 'Selected' : 'Select This Shape',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
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

  void _showDetailedBodyShapeModal(Map<String, dynamic> bodyShape) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) => _buildDetailedBodyShapeModal(bodyShape),
    );
  }

  Widget _buildDetailedBodyShapeModal(Map<String, dynamic> bodyShape) {
    String shapeName = bodyShape['name'] as String;
    Color shapeColor = bodyShape['color'] as Color;
    Map<String, dynamic> detailData = _getDetailedBodyShapeData(shapeName);

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
                        // Header Section
                        _buildModalHeader(bodyShape, shapeColor, detailData),

                        const SizedBox(height: 32),

                        // Body Visualization Section
                        _buildBodyVisualizationSection(
                          shapeName,
                          shapeColor,
                          detailData,
                          widget,
                        ),

                        const SizedBox(height: 32),

                        // Characteristics Section
                        _buildCharacteristicsSection(detailData, shapeColor),

                        const SizedBox(height: 32),

                        // Style Recommendations Section
                        _buildStyleRecommendationsSection(
                          detailData,
                          shapeColor,
                        ),

                        const SizedBox(height: 32),

                        // Celebrity Examples Section
                        _buildCelebrityExamplesSection(detailData, shapeColor),

                        const SizedBox(height: 32),

                        // Do's and Don'ts Section
                        _buildDosAndDontsSection(detailData, shapeColor),

                        const SizedBox(height: 32),

                        // Action Buttons
                        _buildModalActionButtons(shapeName, shapeColor),

                        const SizedBox(height: 16),
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

  Widget _buildModalHeader(
    Map<String, dynamic> bodyShape,
    Color shapeColor,
    Map<String, dynamic> detailData,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            shapeColor.withValues(alpha: 0.1),
            shapeColor.withValues(alpha: 0.05),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: shapeColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [shapeColor, shapeColor.withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: shapeColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                bodyShape['emoji'] as String,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${bodyShape['name']} Body Shape',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: darkGray,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: shapeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: shapeColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${detailData['percentage']} of population',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: shapeColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  detailData['tagline'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

Widget _buildBodyShapeCard(Map<String, dynamic> bodyShape) {
  bool isSelected = widget.data.selectedBodyShape == bodyShape['name'];
  bool isHovered = _hoveredShape == bodyShape['name'];
  Color shapeColor = bodyShape['color'] as Color;

  return GestureDetector(
    onTap: () {
      HapticFeedback.mediumImpact();
      setState(() {
        widget.data.selectedBodyShape = bodyShape['name'] as String;
        _hoveredShape = null;
      });
      widget.onChanged();
      // Show detailed modal when selected
      _showDetailedBodyShapeModal(bodyShape);
    },
    onTapDown: (_) => setState(() => _hoveredShape = bodyShape['name'] as String),
    onTapCancel: () => setState(() => _hoveredShape = null),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 180, // Kurangi tinggi karena menghilangkan icon
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSelected
              ? [
                  shapeColor.withValues(alpha: 0.15),
                  shapeColor.withValues(alpha: 0.05),
                ]
              : isHovered
                  ? [
                      shapeColor.withValues(alpha: 0.1),
                      shapeColor.withValues(alpha: 0.05),
                    ]
                  : [Colors.white, Colors.grey.withValues(alpha: 0.02)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? shapeColor.withValues(alpha: 0.4)
              : isHovered
                  ? shapeColor.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? shapeColor.withValues(alpha: 0.15)
                : isHovered
                    ? shapeColor.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Emoji dengan ukuran yang lebih besar karena tidak ada icon lagi
          Text(
            bodyShape['emoji'] as String,
            style: TextStyle(fontSize: isSelected ? 40 : 36),
          ),

          // Text section dengan spacing yang lebih baik
          Column(
            children: [
              Text(
                bodyShape['name'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 16, // Sedikit lebih besar
                  fontWeight: FontWeight.w700,
                  color: isSelected ? shapeColor : darkGray,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 6),

              Text(
                bodyShape['description'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 12, // Sedikit lebih besar
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          // Selection indicator atau learn more button
          SizedBox(
            height: 26,
            child: isSelected
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: shapeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: shapeColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: shapeColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Selected',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: shapeColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'Tap to Select',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
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

  Widget _buildMeasurementGuide() {
    return Container(
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
            'How to Measure Yourself',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 12),
          ..._getMeasurementSteps().map((step) => _buildMeasurementStep(step)),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMeasurementSteps() {
    if (widget.data.selectedGender == 'Male') {
      return [
        {
          'title': 'Chest',
          'description': 'Measure around the fullest part of chest',
          'icon': Icons.straighten,
          'color': accentRed,
        },
        {
          'title': 'Waist',
          'description': 'Measure around natural waistline',
          'icon': Icons.height,
          'color': accentYellow,
        },
        {
          'title': 'Hips',
          'description': 'Measure around fullest part of hips',
          'icon': Icons.straighten,
          'color': primaryBlue,
        },
      ];
    } else {
      return [
        {
          'title': 'Bust/Chest',
          'description': 'Measure around the fullest part',
          'icon': Icons.straighten,
          'color': accentRed,
        },
        {
          'title': 'Waist',
          'description': 'Measure around natural waistline',
          'icon': Icons.height,
          'color': accentYellow,
        },
        {
          'title': 'Hips',
          'description': 'Measure around fullest part of hips',
          'icon': Icons.straighten,
          'color': primaryBlue,
        },
      ];
    }
  }

  Widget _buildMeasurementStep(Map<String, dynamic> step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (step['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              step['icon'] as IconData,
              color: step['color'] as Color,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step['title'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: darkGray,
                  ),
                ),
                Text(
                  step['description'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShapeComparison() {
    List<Map<String, String>> comparisonRules;

    if (widget.data.selectedGender == 'Male') {
      comparisonRules = [
        {'shape': 'Rectangle', 'rule': 'Chest ≈ Waist ≈ Hips'},
        {'shape': 'Triangle', 'rule': 'Chest > Waist, Waist ≥ Hips'},
        {'shape': 'Inverted Triangle', 'rule': 'Chest > Hips, V-shaped'},
        {'shape': 'Oval', 'rule': 'Waist > Chest, Rounded middle'},
        {'shape': 'Trapezoid', 'rule': 'Chest > Hips, Fuller waist'},
      ];
    } else {
      comparisonRules = [
        {'shape': 'Apple', 'rule': 'Bust > Waist, Waist ≥ Hips'},
        {'shape': 'Pear', 'rule': 'Hips > Bust, Defined Waist'},
        {'shape': 'Hourglass', 'rule': 'Bust ≈ Hips, Waist < Both'},
        {'shape': 'Rectangle', 'rule': 'Bust ≈ Waist ≈ Hips'},
        {'shape': 'Inverted Triangle', 'rule': 'Bust > Hips'},
      ];
    }

    return Container(
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
            'Quick Shape Comparison',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Compare your measurements:',
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          ...comparisonRules.map(
            (rule) => _buildComparisonRule(rule['shape']!, rule['rule']!),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRule(String shape, String rule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
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
          const SizedBox(width: 8),
          Text(
            '$shape: ',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: darkGray,
            ),
          ),
          Expanded(
            child: Text(
              rule,
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyShapeSelectionSection() {
    bool hasSelection = widget.data.selectedBodyShape != null;

    return Container(
      padding: const EdgeInsets.all(36),
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
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color:
              hasSelection
                  ? accentYellow.withValues(alpha: 0.3)
                  : primaryBlue.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (hasSelection ? accentYellow : primaryBlue).withValues(
              alpha: 0.15,
            ),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: (hasSelection ? accentYellow : primaryBlue).withValues(
                  alpha: 0.3,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasSelection
                      ? Icons.check_circle_rounded
                      : Icons.accessibility_new_rounded,
                  color: hasSelection ? accentYellow : primaryBlue,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  hasSelection ? 'Shape Selected' : 'Choose Your Shape',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: hasSelection ? accentYellow : primaryBlue,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Body Shape Options Grid
          _buildBodyShapeGrid(),
        ],
      ),
    );
  }

  Widget _buildBodyShapeGrid() {
    // Get body shapes based on selected gender
    final bodyShapes = _getBodyShapesForGender();

    return Column(
      children: [
        // First row - 2 cards
        Row(
          children: [
            Expanded(child: _buildBodyShapeCard(bodyShapes[0])),
            const SizedBox(width: 12),
            Expanded(child: _buildBodyShapeCard(bodyShapes[1])),
          ],
        ),
        const SizedBox(height: 12),
        // Second row - 2 cards
        Row(
          children: [
            Expanded(child: _buildBodyShapeCard(bodyShapes[2])),
            const SizedBox(width: 12),
            Expanded(child: _buildBodyShapeCard(bodyShapes[3])),
          ],
        ),
        if (bodyShapes.length > 4) ...[
          const SizedBox(height: 12),
          // Third row - 1 card with same width as others (using flex)
          Row(
            children: [
              Expanded(flex: 1, child: Container()),
              Expanded(flex: 2, child: _buildBodyShapeCard(bodyShapes[4])),
              Expanded(flex: 1, child: Container()),
            ],
          ),
        ],
      ],
    );
  }

  List<Map<String, dynamic>> _getBodyShapesForGender() {
    // Check if gender is selected and is male
    if (widget.data.selectedGender == 'Male') {
      return [
        {
          'name': 'Rectangle',
          'icon': Icons.crop_square,
          'description': 'Athletic build',
          'emoji': '🔲',
          'color': primaryBlue,
        },
        {
          'name': 'Triangle',
          'icon': Icons.change_history,
          'description': 'Broad shoulders',
          'emoji': '🔺',
          'color': accentRed,
        },
        {
          'name': 'Inverted Triangle',
          'icon': Icons.details,
          'description': 'V-shaped torso',
          'emoji': '🔻',
          'color': accentYellow,
        },
        {
          'name': 'Oval',
          'icon': Icons.circle,
          'description': 'Rounded midsection',
          'emoji': '⭕',
          'color': primaryBlue,
        },
        {
          'name': 'Trapezoid',
          'icon': Icons.crop_landscape,
          'description': 'Broader waist',
          'emoji': '📐',
          'color': accentRed,
        },
      ];
    } else {
      // Female body shapes (existing)
      return [
        {
          'name': 'Apple',
          'icon': Icons.circle,
          'description': 'Fuller midsection',
          'emoji': '🍎',
          'color': accentRed,
        },
        {
          'name': 'Pear',
          'icon': Icons.water_drop_outlined,
          'description': 'Wider hips',
          'emoji': '🍐',
          'color': primaryBlue,
        },
        {
          'name': 'Hourglass',
          'icon': Icons.hourglass_empty,
          'description': 'Balanced curves',
          'emoji': '⏳',
          'color': accentYellow,
        },
        {
          'name': 'Rectangle',
          'icon': Icons.crop_square,
          'description': 'Straight silhouette',
          'emoji': '📏',
          'color': primaryBlue,
        },
        {
          'name': 'Inverted Triangle',
          'icon': Icons.change_history,
          'description': 'Broader shoulders',
          'emoji': '🔺',
          'color': accentRed,
        },
      ];
    }
  }

  Map<String, dynamic> _getShapeData(String shape) {
    // Check if it's male body shape
    if (widget.data.selectedGender == 'Male') {
      switch (shape) {
        case 'Rectangle':
          return {
            'description':
                'You have an athletic, straight build with similar measurements across chest, waist, and hips. We\'ll recommend styles that add dimension and create a more defined silhouette.',
            'features': [
              'Layered looks',
              'Textured fabrics',
              'Structured fits',
              'Color blocking',
            ],
          };
        case 'Triangle':
          return {
            'description':
                'You have broader shoulders and chest with a narrower waist and hips. We\'ll focus on balancing your proportions with styles that complement your strong upper body.',
            'features': [
              'Fitted tops',
              'Straight cuts',
              'Minimal shoulders',
              'Hip emphasis',
            ],
          };
        case 'Inverted Triangle':
          return {
            'description':
                'You have a V-shaped torso with broad shoulders tapering to a narrower waist. We\'ll recommend styles that balance your strong shoulder line.',
            'features': [
              'Soft shoulders',
              'Straight cuts',
              'Hip details',
              'Minimal structure',
            ],
          };
        case 'Oval':
          return {
            'description':
                'You carry weight around the midsection with a rounder torso. We\'ll help create a more defined silhouette with strategic styling.',
            'features': [
              'Vertical lines',
              'Open jackets',
              'V-necks',
              'Structured fits',
            ],
          };
        case 'Trapezoid':
          return {
            'description':
                'You have broader shoulders with a fuller waist and narrower hips. We\'ll recommend styles that create balance and definition.',
            'features': [
              'Straight cuts',
              'Minimal waist',
              'Hip emphasis',
              'Vertical lines',
            ],
          };
        default:
          return {
            'description': 'Every body is unique and handsome.',
            'features': ['Confidence'],
          };
      }
    } else {
      // Female body shape data (existing)
      switch (shape) {
        case 'Apple':
          return {
            'description':
                'Your body carries weight around the midsection with broader shoulders and bust. We\'ll recommend styles that elongate your torso and highlight your best features.',
            'features': ['Empire waist', 'V-necks', 'A-line', 'Flowing tops'],
          };
        case 'Pear':
          return {
            'description':
                'You have narrower shoulders with fuller hips and thighs. Our recommendations will balance your proportions and highlight your defined waist.',
            'features': [
              'Boat necks',
              'Structured tops',
              'Bootcut',
              'A-line skirts',
            ],
          };
        case 'Hourglass':
          return {
            'description':
                'You have balanced bust and hips with a well-defined waist. We\'ll recommend fitted styles that follow your natural silhouette.',
            'features': ['Wrap styles', 'Fitted', 'High-waisted', 'Body-con'],
          };
        case 'Rectangle':
          return {
            'description':
                'Your bust, waist, and hips are similar in measurement. We\'ll help create curves and define your waistline with strategic styling.',
            'features': ['Peplum', 'Belted', 'Layered', 'Textured'],
          };
        case 'Inverted Triangle':
          return {
            'description':
                'You have broader shoulders than your hips. Our recommendations will balance your proportions by adding volume to your lower body.',
            'features': [
              'Wide leg pants',
              'Full skirts',
              'Hip details',
              'Soft shoulders',
            ],
          };
        default:
          return {
            'description': 'Every body is unique and beautiful.',
            'features': ['Confidence'],
          };
      }
    }
  }
  
// Hapus semua kode dari baris 2657 sampai akhir dan ganti dengan yang berikut:

// Ganti method _buildCharacteristicsSection yang kosong dengan implementasi lengkap:
Widget _buildCharacteristicsSection(Map<String, dynamic> detailData, Color shapeColor) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline, color: shapeColor, size: 24),
            const SizedBox(width: 12),
            Text(
              'Key Characteristics',
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
          detailData['visualDescription'] as String,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Column(
          children: (detailData['characteristics'] as List<String>).map((characteristic) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 8, right: 12),
                    decoration: BoxDecoration(
                      color: shapeColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      characteristic,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
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

// Perbaiki method _buildBodyVisualizationSection:
Widget _buildBodyVisualizationSection(
  String shapeName,
  Color shapeColor,
  Map<String, dynamic> detailData, Step3BodyShape widget,
) {
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
            Icon(Icons.visibility_rounded, color: shapeColor, size: 24),
            const SizedBox(width: 12),
            Text(
              'Body Visualization',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: darkGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        Center(
          child: Column(
            children: [
              // Body Shape Illustration
              SizedBox(
                width: 200,
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            shapeColor.withValues(alpha: 0.1),
                            shapeColor.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    
                    // Body Shape illustration
                    CustomPaint(
                      size: const Size(160, 240),
                      painter: BodyShapePainter(
                        shapeName: shapeName,
                        color: shapeColor,
                        isGenderMale: widget.data.selectedGender == 'Male',
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Description container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: shapeColor.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Text(
                      detailData['tagline'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: shapeColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${detailData['percentage']} of ${widget.data.selectedGender?.toLowerCase() ?? 'people'} have this body shape',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

} // Tutup class _Step3BodyShapeState

// Custom Painter class di luar class _Step3BodyShapeState
class BodyShapePainter extends CustomPainter {
  final String shapeName;
  final Color color;
  final bool isGenderMale;

  BodyShapePainter({
    required this.shapeName,
    required this.color,
    required this.isGenderMale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    if (isGenderMale) {
      _drawMaleBodyShape(canvas, size, paint, strokePaint, centerX, centerY);
    } else {
      _drawFemaleBodyShape(canvas, size, paint, strokePaint, centerX, centerY);
    }
  }

  void _drawMaleBodyShape(Canvas canvas, Size size, Paint fillPaint, Paint strokePaint, double centerX, double centerY) {
    final path = Path();
    
    switch (shapeName) {
      case 'Rectangle':
        path.moveTo(centerX - 25, centerY - 100);
        path.lineTo(centerX - 42, centerY - 78);
        path.lineTo(centerX - 40, centerY - 20);
        path.lineTo(centerX - 38, centerY + 10);
        path.lineTo(centerX - 36, centerY + 60);
        path.lineTo(centerX - 28, centerY + 120);
        path.lineTo(centerX + 28, centerY + 120);
        path.lineTo(centerX + 36, centerY + 60);
        path.lineTo(centerX + 38, centerY + 10);
        path.lineTo(centerX + 40, centerY - 20);
        path.lineTo(centerX + 42, centerY - 78);
        path.lineTo(centerX + 25, centerY - 100);
        path.close();
        break;
        
      case 'Triangle':
        path.moveTo(centerX - 25, centerY - 100);
        path.lineTo(centerX - 48, centerY - 78);
        path.lineTo(centerX - 45, centerY - 20);
        path.lineTo(centerX - 32, centerY + 10);
        path.lineTo(centerX - 34, centerY + 60);
        path.lineTo(centerX - 26, centerY + 120);
        path.lineTo(centerX + 26, centerY + 120);
        path.lineTo(centerX + 34, centerY + 60);
        path.lineTo(centerX + 32, centerY + 10);
        path.lineTo(centerX + 45, centerY - 20);
        path.lineTo(centerX + 48, centerY - 78);
        path.lineTo(centerX + 25, centerY - 100);
        path.close();
        break;
        
      case 'Inverted Triangle':
        path.moveTo(centerX - 25, centerY - 100);
        path.lineTo(centerX - 52, centerY - 78);
        path.lineTo(centerX - 48, centerY - 20);
        path.lineTo(centerX - 28, centerY + 10);
        path.lineTo(centerX - 22, centerY + 60);
        path.lineTo(centerX - 18, centerY + 120);
        path.lineTo(centerX + 18, centerY + 120);
        path.lineTo(centerX + 22, centerY + 60);
        path.lineTo(centerX + 28, centerY + 10);
        path.lineTo(centerX + 48, centerY - 20);
        path.lineTo(centerX + 52, centerY - 78);
        path.lineTo(centerX + 25, centerY - 100);
        path.close();
        break;
        
      case 'Oval':
        path.moveTo(centerX - 25, centerY - 100);
        path.lineTo(centerX - 42, centerY - 78);
        path.lineTo(centerX - 48, centerY - 20);
        path.lineTo(centerX - 52, centerY + 10);
        path.lineTo(centerX - 42, centerY + 60);
        path.lineTo(centerX - 30, centerY + 120);
        path.lineTo(centerX + 30, centerY + 120);
        path.lineTo(centerX + 42, centerY + 60);
        path.lineTo(centerX + 52, centerY + 10);
        path.lineTo(centerX + 48, centerY - 20);
        path.lineTo(centerX + 42, centerY - 78);
        path.lineTo(centerX + 25, centerY - 100);
        path.close();
        break;
        
      case 'Trapezoid':
        path.moveTo(centerX - 25, centerY - 100);
        path.lineTo(centerX - 46, centerY - 78);
        path.lineTo(centerX - 42, centerY - 20);
        path.lineTo(centerX - 46, centerY + 10);
        path.lineTo(centerX - 32, centerY + 60);
        path.lineTo(centerX - 26, centerY + 120);
        path.lineTo(centerX + 26, centerY + 120);
        path.lineTo(centerX + 32, centerY + 60);
        path.lineTo(centerX + 46, centerY + 10);
        path.lineTo(centerX + 42, centerY - 20);
        path.lineTo(centerX + 46, centerY - 78);
        path.lineTo(centerX + 25, centerY - 100);
        path.close();
        break;
    }
    
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawFemaleBodyShape(Canvas canvas, Size size, Paint fillPaint, Paint strokePaint, double centerX, double centerY) {
    final path = Path();
    
    switch (shapeName) {
      case 'Apple':
        path.moveTo(centerX - 22, centerY - 100);
        path.lineTo(centerX - 38, centerY - 78);
        path.quadraticBezierTo(centerX - 44, centerY - 40, centerX - 42, centerY - 20);
        path.quadraticBezierTo(centerX - 48, centerY, centerX - 46, centerY + 20);
        path.quadraticBezierTo(centerX - 32, centerY + 50, centerX - 28, centerY + 80);
        path.lineTo(centerX - 24, centerY + 120);
        path.lineTo(centerX + 24, centerY + 120);
        path.quadraticBezierTo(centerX + 28, centerY + 80, centerX + 32, centerY + 50);
        path.quadraticBezierTo(centerX + 46, centerY + 20, centerX + 48, centerY);
        path.quadraticBezierTo(centerX + 42, centerY - 20, centerX + 44, centerY - 40);
        path.quadraticBezierTo(centerX + 38, centerY - 78, centerX + 22, centerY - 100);
        path.close();
        break;
        
      case 'Pear':
        path.moveTo(centerX - 22, centerY - 100);
        path.lineTo(centerX - 32, centerY - 78);
        path.quadraticBezierTo(centerX - 36, centerY - 40, centerX - 34, centerY - 20);
        path.quadraticBezierTo(centerX - 24, centerY, centerX - 22, centerY + 20);
        path.quadraticBezierTo(centerX - 46, centerY + 50, centerX - 48, centerY + 80);
        path.lineTo(centerX - 32, centerY + 120);
        path.lineTo(centerX + 32, centerY + 120);
        path.quadraticBezierTo(centerX + 48, centerY + 80, centerX + 46, centerY + 50);
        path.quadraticBezierTo(centerX + 22, centerY + 20, centerX + 24, centerY);
        path.quadraticBezierTo(centerX + 34, centerY - 20, centerX + 36, centerY - 40);
        path.quadraticBezierTo(centerX + 32, centerY - 78, centerX + 22, centerY - 100);
        path.close();
        break;
        
      case 'Hourglass':
        path.moveTo(centerX - 22, centerY - 100);
        path.lineTo(centerX - 38, centerY - 78);
        path.quadraticBezierTo(centerX - 44, centerY - 40, centerX - 42, centerY - 20);
        path.quadraticBezierTo(centerX - 18, centerY, centerX - 16, centerY + 20);
        path.quadraticBezierTo(centerX - 44, centerY + 50, centerX - 46, centerY + 80);
        path.lineTo(centerX - 28, centerY + 120);
        path.lineTo(centerX + 28, centerY + 120);
        path.quadraticBezierTo(centerX + 46, centerY + 80, centerX + 44, centerY + 50);
        path.quadraticBezierTo(centerX + 16, centerY + 20, centerX + 18, centerY);
        path.quadraticBezierTo(centerX + 42, centerY - 20, centerX + 44, centerY - 40);
        path.quadraticBezierTo(centerX + 38, centerY - 78, centerX + 22, centerY - 100);
        path.close();
        break;
        
      case 'Rectangle':
        path.moveTo(centerX - 22, centerY - 100);
        path.lineTo(centerX - 34, centerY - 78);
        path.quadraticBezierTo(centerX - 36, centerY - 40, centerX - 35, centerY - 20);
        path.quadraticBezierTo(centerX - 34, centerY, centerX - 35, centerY + 20);
        path.quadraticBezierTo(centerX - 36, centerY + 50, centerX - 34, centerY + 80);
        path.lineTo(centerX - 24, centerY + 120);
        path.lineTo(centerX + 24, centerY + 120);
        path.quadraticBezierTo(centerX + 34, centerY + 80, centerX + 36, centerY + 50);
        path.quadraticBezierTo(centerX + 35, centerY + 20, centerX + 34, centerY);
        path.quadraticBezierTo(centerX + 35, centerY - 20, centerX + 36, centerY - 40);
        path.quadraticBezierTo(centerX + 34, centerY - 78, centerX + 22, centerY - 100);
        path.close();
        break;
        
      case 'Inverted Triangle':
        path.moveTo(centerX - 22, centerY - 100);
        path.lineTo(centerX - 44, centerY - 78);
        path.quadraticBezierTo(centerX - 48, centerY - 40, centerX - 46, centerY - 20);
        path.quadraticBezierTo(centerX - 28, centerY, centerX - 26, centerY + 20);
        path.quadraticBezierTo(centerX - 24, centerY + 50, centerX - 20, centerY + 80);
        path.lineTo(centerX - 16, centerY + 120);
        path.lineTo(centerX + 16, centerY + 120);
        path.quadraticBezierTo(centerX + 20, centerY + 80, centerX + 24, centerY + 50);
        path.quadraticBezierTo(centerX + 26, centerY + 20, centerX + 28, centerY);
        path.quadraticBezierTo(centerX + 46, centerY - 20, centerX + 48, centerY - 40);
        path.quadraticBezierTo(centerX + 44, centerY - 78, centerX + 22, centerY - 100);
        path.close();
        break;
    }
    
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/personalization_data.dart';

class Step1GenderSelection extends StatefulWidget {
  final PersonalizationData data;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final VoidCallback onChanged;

  const Step1GenderSelection({
    super.key,
    required this.data,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.onChanged,
  });

  @override
  State<Step1GenderSelection> createState() => _Step1GenderSelectionState();
}

class _Step1GenderSelectionState extends State<Step1GenderSelection>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // FitOutfit brand colors
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color softGray = Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
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
                  // Simple header
                  _buildSimpleHeader(),

                  const SizedBox(height: 32),

                  // Main Gender Selection - HIGHLIGHTED AT TOP
                  _buildMainGenderSelection(),

                  const SizedBox(height: 40),

                  // Gender details and descriptions
                  if (widget.data.selectedGender != null) _buildGenderDetails(),

                  const SizedBox(height: 32),

                  // Why this matters section
                  _buildWhyItMatters(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleHeader() {
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
          // Simple animated icon
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
                    Icons.people_alt_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Enhanced title with gradient - centered
          ShaderMask(
            shaderCallback:
                (bounds) => const LinearGradient(
                  colors: [primaryBlue, accentYellow],
                ).createShader(bounds),
            child: Text(
              'Choose Your Identity',
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
            'Help us understand your style preferences better',
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

  Widget _buildMainGenderSelection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryBlue.withValues(alpha: 0.05),
            accentYellow.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: primaryBlue.withValues(alpha: 0.1), width: 2),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main title
          Text(
            'Select Your Gender',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: darkGray,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'This helps us provide personalized recommendations',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Gender cards - MAIN FOCUS
          Row(
            children: [
              Expanded(
                child: _buildFocusedGenderCard(
                  'Male',
                  Icons.male_rounded,
                  primaryBlue,
                  '👨',
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildFocusedGenderCard(
                  'Female',
                  Icons.female_rounded,
                  accentRed,
                  '👩',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFocusedGenderCard(
    String gender,
    IconData icon,
    Color color,
    String emoji,
  ) {
    bool isSelected = widget.data.selectedGender == gender;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 1.0 + (value * 0.05),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              setState(() {
                widget.data.selectedGender = gender;
              });
              widget.onChanged();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: 280,
              decoration: BoxDecoration(
                gradient:
                    isSelected
                        ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [color, color.withValues(alpha: 0.8)],
                        )
                        : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, color.withValues(alpha: 0.05)],
                        ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color:
                      isSelected
                          ? color.withValues(alpha: 0.6)
                          : Colors.grey.withValues(alpha: 0.2),
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        isSelected
                            ? color.withValues(alpha: 0.4)
                            : Colors.black.withValues(alpha: 0.06),
                    blurRadius: isSelected ? 25 : 15,
                    offset: Offset(0, isSelected ? 12 : 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Large emoji
                  Text(emoji, style: TextStyle(fontSize: isSelected ? 50 : 45)),

                  const SizedBox(height: 20),

                  // Icon
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Colors.white.withValues(alpha: 0.2)
                              : color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(
                        color:
                            isSelected
                                ? Colors.white.withValues(alpha: 0.4)
                                : color.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 35,
                      color: isSelected ? Colors.white : color,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Gender text
                  Text(
                    gender,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : darkGray,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Status
                  Text(
                    isSelected ? '✓ Selected' : 'Tap to select',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected
                              ? Colors.white.withValues(alpha: 0.9)
                              : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenderDetails() {
    String selectedGender = widget.data.selectedGender!;
    Map<String, dynamic> genderInfo = _getGenderInfo(selectedGender);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (genderInfo['color'] as Color).withValues(alpha: 0.08),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (genderInfo['color'] as Color).withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (genderInfo['color'] as Color).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                  color: (genderInfo['color'] as Color).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  genderInfo['icon'] as IconData,
                  color: genderInfo['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perfect Choice!',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: genderInfo['color'] as Color,
                      ),
                    ),
                    Text(
                      'You selected: $selectedGender',
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

          const SizedBox(height: 24),

          Text(
            genderInfo['title'] as String,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: darkGray,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            genderInfo['description'] as String,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 20),

          // Style preferences for this gender
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children:
                (genderInfo['styles'] as List<String>).map((style) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: (genderInfo['color'] as Color).withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (genderInfo['color'] as Color).withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Text(
                      style,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: genderInfo['color'] as Color,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getGenderInfo(String gender) {
    if (gender == 'Male') {
      return {
        'color': primaryBlue,
        'icon': Icons.male_rounded,
        'title': 'Masculine Style Preferences',
        'description':
            'We\'ll focus on classic masculine cuts, structured designs, and versatile pieces that work for both casual and formal occasions. Our recommendations will emphasize clean lines, quality fabrics, and timeless styles.',
        'styles': [
          'Classic Fit',
          'Structured',
          'Minimalist',
          'Business Casual',
          'Urban Casual',
        ],
      };
    } else {
      return {
        'color': accentRed,
        'icon': Icons.female_rounded,
        'title': 'Feminine Style Preferences',
        'description':
            'We\'ll curate outfits that celebrate feminine elegance with flowing silhouettes, vibrant colors, and versatile pieces that transition beautifully from day to night. Expect styles that are both trendy and timeless.',
        'styles': ['Elegant', 'Flowy', 'Trendy', 'Chic', 'Versatile'],
      };
    }
  }

  Widget _buildWhyItMatters() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: softGray.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: primaryBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                'Why We Ask This',
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
            'Gender identity helps us understand your style preferences and provide more accurate recommendations. We respect all identities and use this information solely to enhance your fashion experience.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

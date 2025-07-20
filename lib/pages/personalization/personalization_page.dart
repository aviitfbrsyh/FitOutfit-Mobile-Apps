import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/personalization_data.dart';
import 'steps/step_1_gender_selection.dart';
import 'steps/step_3_body_shape.dart';
import 'steps/step_4_skin_tone.dart';
import 'steps/step_5_hair_color.dart';
import 'steps/step_6_personal_color.dart';
import 'steps/step_7_style_preferences.dart';
import 'steps/step_8_completion.dart';
import '../home/home_page.dart';

class PersonalizationPage extends StatefulWidget {
  const PersonalizationPage({super.key});

  @override
  State<PersonalizationPage> createState() => _PersonalizationPageState();
}

class _PersonalizationPageState extends State<PersonalizationPage>
    with TickerProviderStateMixin {
  int currentStep = 0;
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Shared data model
  final PersonalizationData _data = PersonalizationData();

  // FitOutfit brand colors with extended palette
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color successGreen = Color(0xFF27AE60);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void nextStep() {
    if (currentStep < 7) {
      HapticFeedback.lightImpact();
      setState(() {
        currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
      _resetAnimations();
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      HapticFeedback.selectionClick();
      setState(() {
        currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
      _resetAnimations();
    }
  }

  void _resetAnimations() {
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  void _onStepDataChanged() {
    setState(() {
      // Update UI when step data changes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              lightGray,
              Colors.white,
              primaryBlue.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildModernHeader(),
              _buildAdvancedProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Step1GenderSelection(
                      data: _data,
                      fadeAnimation: _fadeAnimation,
                      slideAnimation: _slideAnimation,
                      onChanged: _onStepDataChanged,
                    ),
                    Step3BodyShape(
                      data: _data,
                      fadeAnimation: _fadeAnimation,
                      slideAnimation: _slideAnimation,
                      onChanged: _onStepDataChanged,
                    ),
                    Step4SkinTone(
                      data: _data,
                      fadeAnimation: _fadeAnimation,
                      slideAnimation: _slideAnimation,
                      onChanged: _onStepDataChanged,
                    ),
                    Step5HairColor(
                      data: _data,
                      fadeAnimation: _fadeAnimation,
                      slideAnimation: _slideAnimation,
                      onChanged: _onStepDataChanged,
                    ),
                    Step6PersonalColor(
                      data: _data,
                      fadeAnimation: _fadeAnimation,
                      slideAnimation: _slideAnimation,
                      onChanged: _onStepDataChanged,
                    ),
                    Step7StylePreferences(
                      data: _data,
                      fadeAnimation: _fadeAnimation,
                      slideAnimation: _slideAnimation,
                      onChanged: _onStepDataChanged,
                    ),
                    Step8Completion(
                      data: _data,
                      fadeAnimation: _fadeAnimation,
                      slideAnimation: _slideAnimation,
                    ),
                  ],
                ),
              ),
              _buildFloatingNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Row(
          children: [
            if (currentStep > 0)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: previousStep,
                  icon: const Icon(Icons.arrow_back_ios_new, color: darkGray),
                  splashRadius: 24,
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step ${currentStep + 1} of 8',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: primaryBlue,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      _getStepTitle(),
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: darkGray,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!_isRequiredStep())
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accentYellow.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Row(
            children: List.generate(8, (index) {
              bool isCompleted = index < currentStep;
              bool isCurrent = index == currentStep;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 7 ? 8 : 0),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 50)),
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient:
                          isCompleted || isCurrent
                              ? const LinearGradient(
                                colors: [primaryBlue, accentYellow],
                              )
                              : null,
                      color:
                          isCompleted || isCurrent
                              ? null
                              : Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(8, (index) {
              bool isCompleted = index < currentStep;
              bool isCurrent = index == currentStep;
              return AnimatedContainer(
                duration: Duration(milliseconds: 200 + (index * 30)),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient:
                      isCompleted
                          ? const LinearGradient(
                            colors: [successGreen, primaryBlue],
                          )
                          : isCurrent
                          ? const LinearGradient(
                            colors: [primaryBlue, accentYellow],
                          )
                          : null,
                  color:
                      isCompleted || isCurrent
                          ? null
                          : Colors.grey.withValues(alpha: 0.3),
                  boxShadow:
                      isCurrent
                          ? [
                            BoxShadow(
                              color: primaryBlue.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                          : null,
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check
                      : isCurrent
                      ? Icons.circle
                      : Icons.circle_outlined,
                  size: 12,
                  color: Colors.white,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  bool _isRequiredStep() {
    return true; 
  }

  String _getStepTitle() {
    switch (currentStep) {
      case 0:
        return 'Gender Identity';
      case 1:
        return 'Body Shape';
      case 2:
        return 'Skin Analysis';
      case 3:
        return 'Hair Color';
      case 4:
        return 'Color Palette';
      case 5:
        return 'Style DNA';
      case 6:
        return 'Profile Complete!';
      default:
        return '';
    }
  }

  bool _canProceed() {
    return _data.canProceedFromStep(currentStep);
  }

  void _completePersonalization() async {
    HapticFeedback.heavyImpact();

    // Simpan data ke Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('personalisasi')
          .doc(user.uid)
          .set(_data.toJson());
    }

    // Navigate to HomePage
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
        reverseTransitionDuration: const Duration(milliseconds: 400),
      ),
      (route) => false,
    );
  }

  Widget _buildFloatingNavigation() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (currentStep > 0)
              SizedBox(
                width: 100,
                height: 48,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: primaryBlue, width: 1.5),
                  ),
                  child: OutlinedButton(
                    onPressed: previousStep,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Previous',
                      style: GoogleFonts.poppins(
                        color: primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            if (currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient:
                        currentStep == 7
                            ? const LinearGradient(
                              colors: [successGreen, primaryBlue],
                            )
                            : const LinearGradient(
                              colors: [primaryBlue, accentYellow],
                            ),
                    boxShadow: [
                      BoxShadow(
                        color: (currentStep == 7 ? successGreen : primaryBlue)
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed:
                        _canProceed()
                            ? (currentStep == 7
                                ? _completePersonalization
                                : nextStep)
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            currentStep == 7 ? 'Start FitOutfit' : 'Continue',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          currentStep == 7
                              ? Icons.rocket_launch
                              : Icons.arrow_forward,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

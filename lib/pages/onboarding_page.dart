import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth/login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _currentIndex = 0;
  final int _totalPages = 4;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Virtual Try-On',
      subtitle: 'AI-Powered Fashion Experience',
      description:
          'Try on clothes virtually with our advanced AI technology. See how outfits look on you before buying!',
      icon: Icons.camera_alt_outlined,
      colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
    ),
    OnboardingData(
      title: 'Smart Wardrobe',
      subtitle: 'Your Personal Fashion Assistant',
      description:
          'Organize your wardrobe digitally and get personalized outfit recommendations based on weather, occasion, and style.',
      icon: Icons.checkroom_outlined,
      colors: [Color(0xFFF5A623), Color(0xFFE8940F)],
    ),
    OnboardingData(
      title: 'Fashion Community',
      subtitle: 'Connect & Share Style',
      description:
          'Join a vibrant community of fashion enthusiasts. Share your outfits, get inspiration, and discover new trends.',
      icon: Icons.people_outline,
      colors: [Color(0xFFD0021B), Color(0xFFB8001A)],
    ),
    OnboardingData(
      title: 'Outfit History',
      subtitle: 'Track Your Style Journey',
      description:
          'Keep track of your favorite outfits, create lookbooks, and build your personal style portfolio.',
      icon: Icons.history_outlined,
      colors: [Color(0xFF7B68EE), Color(0xFF6A5ACD)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToHome();
    }
  }

  void _skipOnboarding() {
    _navigateToHome();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: _totalPages,
                itemBuilder: (context, index) {
                  return _buildOnboardingSlide(_onboardingData[index]);
                },
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'FitOutfit',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              foreground:
                  Paint()
                    ..shader = const LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFFF5A623)],
                    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
            ),
          ),
          TextButton(
            onPressed: _skipOnboarding,
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            child: Text(
              'Skip',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingSlide(OnboardingData data) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            _buildIconContainer(data),
            const SizedBox(height: 50),
            _buildTitleSection(data),
            const SizedBox(height: 30),
            _buildDescriptionText(data.description),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer(OnboardingData data) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: data.colors[0].withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(data.icon, size: 50, color: Colors.white),
    );
  }

  Widget _buildTitleSection(OnboardingData data) {
    return Column(
      children: [
        Text(
          data.title,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          data.subtitle,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDescriptionText(String description) {
    return Text(
      description,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.grey[600],
        height: 1.6,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildBottomNavigation() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        children: [
          _buildPageIndicator(),
          const SizedBox(height: 30),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentIndex == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color:
                _currentIndex == index
                    ? _onboardingData[_currentIndex].colors[0]
                    : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentIndex > 0) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: _onboardingData[_currentIndex].colors[0],
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Previous',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _onboardingData[_currentIndex].colors[0],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          flex: _currentIndex == 0 ? 1 : 1,
          child: ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: _onboardingData[_currentIndex].colors[0],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            child: Text(
              _currentIndex == _totalPages - 1 ? 'Get Started' : 'Next',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> colors;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.colors,
  });
}

// Placeholder home page - replace with your actual home page
class PlaceholderHomePage extends StatelessWidget {
  const PlaceholderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: Text(
          'FitOutfit Home',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            foreground:
                Paint()
                  ..shader = const LinearGradient(
                    colors: [Color(0xFF4A90E2), Color(0xFFF5A623)],
                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Welcome to FitOutfit!\nMain app will be here.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

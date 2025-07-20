import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickAccessGrid extends StatelessWidget {
  final Function(String) onFeatureTap;

  const QuickAccessGrid({super.key, required this.onFeatureTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Access',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _buildFeatureCard(
                'Virtual Try-On',
                'Experience AR magic',
                Icons.camera_alt_outlined,
                const [Color(0xFF4A90E2), Color(0xFF357ABD)],
                'try_on',
              ),
              _buildFeatureCard(
                'My Wardrobe',
                '142 items',
                Icons.checkroom_outlined,
                const [Color(0xFFF5A623), Color(0xFFE8940F)],
                'wardrobe',
              ),
              _buildFeatureCard(
                'Style Quiz',
                'Discover your style',
                Icons.quiz_outlined,
                const [Color(0xFFD0021B), Color(0xFFB8001A)],
                'quiz',
              ),
              _buildFeatureCard(
                'Outfit Planner',
                '3 upcoming events',
                Icons.calendar_today_outlined,
                const [Color(0xFF7B68EE), Color(0xFF6A5ACD)],
                'planner',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    String subtitle,
    IconData icon,
    List<Color> gradientColors,
    String featureId,
  ) {
    return GestureDetector(
      onTap: () => onFeatureTap(featureId),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

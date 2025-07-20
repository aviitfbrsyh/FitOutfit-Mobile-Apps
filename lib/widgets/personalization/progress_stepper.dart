import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgressStepper extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;

  const ProgressStepper({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress Bar
        Container(
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Colors.grey[300],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final progress =
                  totalSteps > 1 ? currentStep / (totalSteps - 1) : 0.0;
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Step Info
        Text(
          'Step ${currentStep + 1} of $totalSteps',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        if (currentStep < stepTitles.length) ...[
          const SizedBox(height: 4),
          Text(
            stepTitles[currentStep],
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF667eea),
            ),
          ),
        ],
      ],
    );
  }
}

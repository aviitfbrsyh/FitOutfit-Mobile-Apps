import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/outfit_recommendation.dart';
import '../../../services/favorites_service.dart';

class DailyRecommendations extends StatelessWidget {
  final List<OutfitRecommendation> recommendations;
  final Function(OutfitRecommendation) onLike;
  final Function(OutfitRecommendation) onSave;
  final VoidCallback onSeeAll;

  const DailyRecommendations({
    super.key,
    required this.recommendations,
    required this.onLike,
    required this.onSave,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Picks',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    'AI-curated outfits just for you',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onSeeAll,
                child: Text(
                  'See All',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4A90E2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              return _buildRecommendationCard(recommendations[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(OutfitRecommendation recommendation) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background Image
            Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[300]!, Colors.grey[100]!],
                ),
              ),
              child:
                  recommendation.imageUrls.isNotEmpty
                      ? Image.network(
                        recommendation.imageUrls.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF4A90E2), Color(0xFFF5A623)],
                              ),
                            ),
                            child: const Icon(
                              Icons.checkroom_outlined,
                              size: 60,
                              color: Colors.white,
                            ),
                          );
                        },
                      )
                      : const Icon(
                        Icons.checkroom_outlined,
                        size: 60,
                        color: Colors.white,
                      ),
            ),
            // Gradient Overlay
            Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            recommendation.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                try {
                                  final isFavorite = await FavoritesService.toggleFavorite(
                                    itemId: recommendation.id,
                                    title: recommendation.title,
                                    category: 'Outfits',
                                    color: const Color(0xFF4A90E2),
                                    icon: Icons.checkroom_rounded,
                                    subtitle: recommendation.occasion,
                                    imageUrl: recommendation.imageUrls.isNotEmpty ? recommendation.imageUrls.first : '',
                                    stats: recommendation.weather,
                                    statsIcon: Icons.wb_sunny_rounded,
                                    count: 1,
                                    tags: [recommendation.occasion, recommendation.weather, 'outfit'],
                                    additionalData: {
                                      'imageUrls': recommendation.imageUrls,
                                      'description': recommendation.description,
                                    },
                                  );
                                  
                                  // Call the original onLike callback for UI updates
                                  onLike(recommendation);
                                } catch (e) {
                                  print('Error toggling favorite: $e');
                                }
                              },
                              child: FutureBuilder<bool>(
                                future: FavoritesService.isInFavorites(recommendation.id),
                                builder: (context, snapshot) {
                                  final isFavorite = snapshot.data ?? false;
                                  return Icon(
                                    isFavorite ? Icons.favorite : Icons.favorite_border,
                                    color: isFavorite ? const Color(0xFFD0021B) : Colors.white,
                                    size: 20,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => onSave(recommendation),
                              child: Icon(
                                recommendation.isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color:
                                    recommendation.isSaved
                                        ? const Color(0xFFF5A623)
                                        : Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recommendation.occasion,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90E2).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        recommendation.weather,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
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
  }
}

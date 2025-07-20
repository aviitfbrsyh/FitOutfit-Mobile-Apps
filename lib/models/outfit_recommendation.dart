class OutfitRecommendation {
  final String id;
  final String title;
  final String description;
  final List<String> imageUrls;
  final String weather;
  final String occasion;
  final List<String> tags;
  final double rating;
  final bool isLiked;
  final bool isSaved;
  final String aiReason;

  OutfitRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.weather,
    required this.occasion,
    required this.tags,
    required this.rating,
    this.isLiked = false,
    this.isSaved = false,
    required this.aiReason,
  });

  OutfitRecommendation copyWith({bool? isLiked, bool? isSaved}) {
    return OutfitRecommendation(
      id: id,
      title: title,
      description: description,
      imageUrls: imageUrls,
      weather: weather,
      occasion: occasion,
      tags: tags,
      rating: rating,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      aiReason: aiReason,
    );
  }
}

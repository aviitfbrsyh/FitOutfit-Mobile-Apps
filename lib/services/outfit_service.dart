import '../models/user_personalization.dart';
import '../models/outfit_suggestion.dart';

class OutfitService {
  OutfitSuggestion suggestOutfit(UserPersonalization user, String destination) {
    // Simple logic for demonstration
    if (destination.toLowerCase().contains('beach')) {
      return OutfitSuggestion(
        top: 'Light Linen Shirt',
        bottom: 'Shorts',
        shoes: 'Sandals',
        accessory: 'Sunglasses',
        imageAsset: 'assets/outfits/beach.png',
      );
    }
    if (user.bodyShape == 'Hourglass' && user.personalColor == 'Spring') {
      return OutfitSuggestion(
        top: 'Fitted Floral Blouse',
        bottom: 'High-waisted Jeans',
        shoes: 'Ballet Flats',
        accessory: 'Pastel Scarf',
        imageAsset: 'assets/outfits/spring_hourglass.png',
      );
    }
    // Add more rules as needed
    return OutfitSuggestion(
      top: 'Basic Tee',
      bottom: 'Jeans',
      shoes: 'Sneakers',
      accessory: 'Watch',
      imageAsset: 'assets/outfits/default.png',
    );
  }
}
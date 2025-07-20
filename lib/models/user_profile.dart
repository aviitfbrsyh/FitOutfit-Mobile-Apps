import 'dart:io';

enum Gender { male, female, nonBinary, preferNotToSay }

enum BodyShape { apple, pear, hourglass, rectangle, invertedTriangle }

enum SkinTone { veryFair, fair, light, medium, tan, dark, veryDark }

enum Undertone { cool, warm, neutral }

enum HairColor {
  black,
  brown,
  blonde,
  red,
  gray,
  auburn,
  strawberryBlonde,
  silver,
  other,
}

enum SeasonalPalette { spring, summer, autumn, winter }

enum StylePreference {
  casual,
  formal,
  trendy,
  classic,
  bohemian,
  minimalist,
  sporty,
  romantic,
}

class UserProfile {
  final String id;
  final Gender? gender;
  final File? profilePhoto;
  final BodyShape? bodyShape;
  final SkinTone? skinTone;
  final Undertone? undertone;
  final HairColor? hairColor;
  final String? customHairColor;
  final SeasonalPalette? personalColorSeason;
  final List<StylePreference> stylePreferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    this.gender,
    this.profilePhoto,
    this.bodyShape,
    this.skinTone,
    this.undertone,
    this.hairColor,
    this.customHairColor,
    this.personalColorSeason,
    this.stylePreferences = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gender': gender?.toString(),
      'profilePhoto': profilePhoto?.path,
      'bodyShape': bodyShape?.toString(),
      'skinTone': skinTone?.toString(),
      'undertone': undertone?.toString(),
      'hairColor': hairColor?.toString(),
      'customHairColor': customHairColor,
      'personalColorSeason': personalColorSeason?.toString(),
      'stylePreferences': stylePreferences.map((e) => e.toString()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

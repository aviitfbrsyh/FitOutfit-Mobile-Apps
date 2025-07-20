import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wardrobe_item.dart';

class GptVisionService {
  static const _apiKey = 'your_api_key_here'; // Ganti dengan API key kamu
  static const _apiUrl = 'https://api.openai.com/v1/chat/completions';

  static Future<Map<String, dynamic>> generateOutfitRecommendation(
    List<WardrobeItem> items, {
    required String occasion,
    required String weather,
    required String style,
  }) async {
    try {
      print('🤖 Starting AI outfit generation...');
      print('🤖 Items count: ${items.length}');
      print('🤖 Occasion: $occasion, Weather: $weather, Style: $style');

      // ✅ FILTER ITEMS WITH VALID IMAGES
      final validItems =
          items
              .where(
                (item) =>
                    item.imageUrl != null &&
                    item.imageUrl!.isNotEmpty &&
                    item.imageUrl != 'null',
              )
              .toList();

      if (validItems.isEmpty) {
        throw Exception('Tidak ada item dengan gambar yang valid di wardrobe');
      }

      print('🤖 Valid items with images: ${validItems.length}');

      // ✅ CREATE ITEMS MAP FOR MATCHING
      final Map<String, WardrobeItem> itemsMap = {};
      for (var item in validItems) {
        final key =
            '${item.name.toLowerCase().replaceAll(' ', '_')}_${item.category.toLowerCase()}';
        itemsMap[key] = item;
        print('🤖 Item: ${item.name} - Image: ${item.imageUrl}');
      }

      // ✅ TEST API KEY FIRST
      print('🔑 Testing OpenAI API key...');
      final apiKeyValid = await testApiKey();
      if (!apiKeyValid) {
        print('🚨 API Key invalid, using enhanced smart fallback');
        return _createEnhancedSmartFallbackResponse(
          validItems,
          occasion,
          weather,
          style,
        );
      }
      print('✅ API key is valid!');

      // ✅ TRY REAL AI WITH IMAGE ANALYSIS
      try {
        final List<Map<String, dynamic>> images =
            validItems
                .map(
                  (e) => {
                    'type': 'image_url',
                    'image_url': {'url': e.imageUrl!, 'detail': 'low'},
                  },
                )
                .toList();

        // ✅ SUPER INTELLIGENT PROMPT WITH CONTEXT ANALYSIS
        final prompt = '''
You are an expert fashion stylist with deep understanding of personal style, destination appropriateness, and weather-specific dressing. Analyze the clothing images and create the perfect outfit recommendation based on comprehensive context analysis.

Available wardrobe items:
${validItems.map((item) => '- ${item.name} (${item.category}, ${item.color})').join('\n')}

USER CONTEXT ANALYSIS:
- Style Preference: $style
- Destination/Occasion: $occasion  
- Weather Conditions: $weather

INTELLIGENT STYLING FRAMEWORK:

1. STYLE PERSONALITY ANALYSIS:
   ${_getStylePersonalityGuide(style)}

2. DESTINATION & OCCASION INTELLIGENCE:
   ${_getDestinationGuide(occasion)}

3. WEATHER-SMART DRESSING:
   ${_getWeatherGuide(weather)}

4. ADVANCED FASHION RULES:
   - LAYERING INTELLIGENCE: Never layer long-sleeved tops with outerwear
   - COLOR PSYCHOLOGY: Choose colors that match the mood and setting
   - SILHOUETTE BALANCE: Mix fitted and relaxed pieces appropriately
   - FABRIC CONSIDERATIONS: Match fabric choices to weather and activity level
   - COMFORT-STYLE RATIO: Balance looking good with feeling comfortable

5. COMPLETE COORDINATION SYSTEM:
   - Analyze ALL image colors for perfect harmony
   - Consider color temperature (warm/cool undertones)
   - Use 60-30-10 rule: 60% dominant color, 30% secondary, 10% accent
   - Coordinate accessories and shoes as integral parts of the look
   - Ensure outfit works for the specific time of day and setting

6. SMART SELECTION CRITERIA:
   - Prioritize versatile pieces that work for the specific context
   - Consider the user's confidence level with different styles
   - Factor in practical needs (comfort, movement, weather protection)
   - Choose pieces that enhance the user's best features

IMPORTANT: Use EXACT item names from the list. Create a cohesive look that makes the user feel confident and appropriately dressed.

Respond with JSON format only:
{
  "outfit": [
    {
      "name": "EXACT_NAME_FROM_LIST",
      "category": "EXACT_CATEGORY_FROM_LIST", 
      "description": "detailed reasoning including why this piece is perfect for their style, destination, and weather"
    }
  ],
  "alasan": "comprehensive style analysis explaining how this outfit perfectly matches their style personality, is appropriate for their destination, and works with the weather conditions"
}
''';

        final body = jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {
              "role": "user",
              "content": [
                {"type": "text", "text": prompt},
                ...images,
              ],
            },
          ],
          "max_tokens": 1200,
          "temperature": 0.8,
        });

        print('🤖 Sending request to OpenAI...');

        final response = await http.post(
          Uri.parse(_apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: body,
        );

        print('🤖 Response status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final content = data['choices'][0]['message']['content'] as String;

          print('🤖 AI Response: $content');

          try {
            final jsonStart = content.indexOf('{');
            final jsonEnd = content.lastIndexOf('}');

            if (jsonStart != -1 && jsonEnd != -1) {
              final jsonString = content.substring(jsonStart, jsonEnd + 1);
              final aiResult = jsonDecode(jsonString);

              // ✅ MAP AI RESPONSE TO REAL WARDROBE ITEMS
              final mappedResult = _mapAIResponseToRealItems(
                aiResult,
                itemsMap,
              );

              print('✅ Real AI outfit generated and mapped successfully!');
              return mappedResult;
            } else {
              throw Exception('No valid JSON found in response');
            }
          } catch (parseError) {
            print(
              '⚠️ JSON parse error: $parseError, falling back to enhanced smart logic',
            );
            return _createEnhancedSmartFallbackResponse(
              validItems,
              occasion,
              weather,
              style,
            );
          }
        } else {
          final errorBody = response.body;
          print(
            '❌ API Error: $errorBody, falling back to enhanced smart logic',
          );
          return _createEnhancedSmartFallbackResponse(
            validItems,
            occasion,
            weather,
            style,
          );
        }
      } catch (apiError) {
        print('❌ AI API call failed: $apiError, using enhanced smart fallback');
        return _createEnhancedSmartFallbackResponse(
          validItems,
          occasion,
          weather,
          style,
        );
      }
    } catch (e) {
      print(
        '❌ Error in generateOutfitRecommendation: $e, using enhanced fallback',
      );
      // ✅ FIX: Gunakan items parameter, bukan validItems yang undefined
      final validItemsForFallback =
          items
              .where(
                (item) =>
                    item.imageUrl != null &&
                    item.imageUrl!.isNotEmpty &&
                    item.imageUrl != 'null',
              )
              .toList();
      return _createEnhancedSmartFallbackResponse(
        validItemsForFallback,
        occasion,
        weather,
        style,
      );
    }
  }

  // ✅ NEW METHOD: MAP AI RESPONSE TO REAL WARDROBE ITEMS
  static Map<String, dynamic> _mapAIResponseToRealItems(
    Map<String, dynamic> aiResult,
    Map<String, WardrobeItem> itemsMap,
  ) {
    print('🔄 Mapping AI response to real wardrobe items...');

    final aiOutfit = aiResult['outfit'] as List<dynamic>;
    List<Map<String, dynamic>> mappedOutfit = [];

    for (var aiItem in aiOutfit) {
      final aiName = aiItem['name']?.toString() ?? '';
      final aiCategory = aiItem['category']?.toString() ?? '';

      print('🔍 Looking for AI item: $aiName ($aiCategory)');

      // ✅ FIND MATCHING REAL ITEM
      WardrobeItem? matchedItem;

      // Try exact match first
      final exactKey =
          '${aiName.toLowerCase().replaceAll(' ', '_')}_${aiCategory.toLowerCase()}';
      if (itemsMap.containsKey(exactKey)) {
        matchedItem = itemsMap[exactKey];
        print('✅ Exact match found: ${matchedItem!.name}');
      } else {
        // Try fuzzy match
        for (var entry in itemsMap.entries) {
          final item = entry.value;
          if (item.name.toLowerCase().contains(
                aiName.toLowerCase().split(' ').first,
              ) ||
              aiName.toLowerCase().contains(
                item.name.toLowerCase().split(' ').first,
              )) {
            if (item.category.toLowerCase() == aiCategory.toLowerCase()) {
              matchedItem = item;
              print('✅ Fuzzy match found: ${matchedItem.name}');
              break;
            }
          }
        }
      }

      if (matchedItem != null) {
        // ✅ ADD REAL ITEM WITH REAL IMAGE URL (REMOVED 'brand')
        mappedOutfit.add({
          'name': matchedItem.name,
          'category': matchedItem.category,
          'description': aiItem['description'] ?? 'Selected by AI',
          'imageUrl': matchedItem.imageUrl!, // ✅ REAL FIREBASE URL!
          'color': matchedItem.color,
          'id': matchedItem.id,
        });

        print(
          '🎯 Mapped: ${matchedItem.name} - Real Image: ${matchedItem.imageUrl}',
        );
      } else {
        print('⚠️ No real item found for AI suggestion: $aiName');
        // Skip items that can't be matched
      }
    }

    // ✅ RETURN MAPPED RESULT
    return {
      'outfit': mappedOutfit,
      'alasan': aiResult['alasan'] ?? 'AI-generated outfit recommendation',
    };
  }

  // ✅ ENHANCED SMART FALLBACK (REMOVED UNUSED VARIABLES)
  static Map<String, dynamic> _createEnhancedSmartFallbackResponse(
    List<WardrobeItem> items,
    String occasion,
    String weather,
    String style,
  ) {
    print('🔄 Using SUPER INTELLIGENT fashion coordination...');

    // ✅ ANALYZE USER CONTEXT FIRST
    final styleProfile = _analyzeStyleProfile(style);
    final destinationNeeds = _analyzeDestination(occasion);
    final weatherRequirements = _analyzeWeather(weather);

    print('🧠 Style Profile: ${styleProfile['type']}');
    print('🏢 Destination: ${destinationNeeds['formality']}');
    print('🌤️ Weather Needs: ${weatherRequirements['priority']}');

    items.shuffle();

    final tops = items.where((item) => item.category == 'Tops').toList();
    final bottoms = items.where((item) => item.category == 'Bottoms').toList();
    final outerwear =
        items.where((item) => item.category == 'Outerwear').toList();
    final dresses = items.where((item) => item.category == 'Dresses').toList();
    final shoes = items.where((item) => item.category == 'Shoes').toList();
    final accessories =
        items.where((item) => item.category == 'Accessories').toList();

    List<Map<String, dynamic>> selectedItems = [];
    List<String> usedColors = [];

    // ✅ INTELLIGENT DRESS vs SEPARATES DECISION
    final shouldWearDress = _shouldChooseDress(
      dresses,
      destinationNeeds,
      styleProfile,
      weatherRequirements,
    );

    if (shouldWearDress && dresses.isNotEmpty) {
      final dress = _selectContextAwareDress(
        dresses,
        styleProfile,
        destinationNeeds,
        weatherRequirements,
      );
      selectedItems.add({
        "name": dress.name,
        "category": dress.category,
        "description":
            "Perfect ${dress.color.toLowerCase()} dress yang ${_getStyleReasoning(dress, styleProfile)} dan ${_getDestinationReasoning(dress, destinationNeeds)} untuk ${occasion.toLowerCase()}",
        "imageUrl": dress.imageUrl ?? "",
      });
      usedColors.add(dress.color.toLowerCase());
    } else {
      // ✅ SMART SEPARATES SELECTION
      if (tops.isNotEmpty) {
        final selectedTop = _selectContextAwareTop(
          tops,
          styleProfile,
          destinationNeeds,
          weatherRequirements,
        );
        selectedItems.add({
          "name": selectedTop.name,
          "category": selectedTop.category,
          "description":
              "Stylish ${selectedTop.color.toLowerCase()} top yang ${_getStyleReasoning(selectedTop, styleProfile)} dan cocok untuk ${destinationNeeds['setting']} dengan weather ${weather.toLowerCase()}",
          "imageUrl": selectedTop.imageUrl ?? "",
        });
        usedColors.add(selectedTop.color.toLowerCase());

        // ✅ INTELLIGENT BOTTOM COORDINATION
        if (bottoms.isNotEmpty) {
          final selectedBottom = _selectContextAwareBottom(
            bottoms,
            selectedTop,
            styleProfile,
            destinationNeeds,
          );
          selectedItems.add({
            "name": selectedBottom.name,
            "category": selectedBottom.category,
            "description":
                "Perfect ${selectedBottom.color.toLowerCase()} bottom yang menciptakan ${styleProfile['aesthetic']} look dan ${_getComfortReasoning(selectedBottom, destinationNeeds)}",
            "imageUrl": selectedBottom.imageUrl ?? "",
          });
          usedColors.add(selectedBottom.color.toLowerCase());
        }

        // ✅ SMART LAYERING DECISION
        final needsLayer = _intelligentLayeringDecision(
          selectedTop,
          weatherRequirements,
          destinationNeeds,
        );
        if (needsLayer && outerwear.isNotEmpty) {
          final selectedOuter = _selectContextAwareOuterwear(
            outerwear,
            usedColors,
            styleProfile,
            weatherRequirements,
          );
          selectedItems.add({
            "name": selectedOuter.name,
            "category": selectedOuter.category,
            "description":
                "Smart layering dengan ${selectedOuter.color.toLowerCase()} outerwear untuk ${weatherRequirements['protection']} dan ${styleProfile['vibe']}",
            "imageUrl": selectedOuter.imageUrl ?? "",
          });
          usedColors.add(selectedOuter.color.toLowerCase());
        }
      }
    }

    // ✅ INTELLIGENT FOOTWEAR SELECTION
    if (shoes.isNotEmpty) {
      final selectedShoes = _selectContextAwareShoes(
        shoes,
        usedColors,
        styleProfile,
        destinationNeeds,
        weatherRequirements,
      );
      selectedItems.add({
        "name": selectedShoes.name,
        "category": selectedShoes.category,
        "description":
            "Perfect ${selectedShoes.color.toLowerCase()} footwear yang ${_getShoeReasoning(selectedShoes, destinationNeeds, weatherRequirements, styleProfile)}",
        "imageUrl": selectedShoes.imageUrl ?? "",
      });
    }

    // ✅ SMART ACCESSORIES FINISHING
    if (accessories.isNotEmpty) {
      final selectedAccessory = _selectContextAwareAccessory(
        accessories,
        usedColors,
        styleProfile,
        destinationNeeds,
      );
      selectedItems.add({
        "name": selectedAccessory.name,
        "category": selectedAccessory.category,
        "description":
            "Finishing touch dengan ${selectedAccessory.color.toLowerCase()} accessory yang ${_getAccessoryReasoning(selectedAccessory, styleProfile, destinationNeeds)}",
        "imageUrl": selectedAccessory.imageUrl ?? "",
      });
    }

    // ✅ INTELLIGENT REASONING
    String reasoning = _generateIntelligentReasoning(
      selectedItems,
      styleProfile,
      destinationNeeds,
      weatherRequirements,
      occasion,
      weather,
      style,
    );

    return {"outfit": selectedItems, "alasan": reasoning};
  }

  // ✅ NEW: Analyze user's style profile
  static Map<String, dynamic> _analyzeStyleProfile(String style) {
    final styleType = style.toLowerCase();

    if (styleType.contains('casual') || styleType.contains('relaxed')) {
      return {
        'type': 'casual',
        'aesthetic': 'effortless',
        'vibe': 'comfortable confidence',
        'colors': ['denim', 'white', 'gray', 'earth tones'],
        'priority': 'comfort',
      };
    } else if (styleType.contains('formal') ||
        styleType.contains('professional')) {
      return {
        'type': 'formal',
        'aesthetic': 'polished',
        'vibe': 'professional elegance',
        'colors': ['black', 'navy', 'white', 'gray'],
        'priority': 'sophistication',
      };
    } else if (styleType.contains('chic') || styleType.contains('elegant')) {
      return {
        'type': 'chic',
        'aesthetic': 'refined',
        'vibe': 'effortless sophistication',
        'colors': ['black', 'white', 'beige', 'camel'],
        'priority': 'style',
      };
    } else if (styleType.contains('trendy') || styleType.contains('fashion')) {
      return {
        'type': 'trendy',
        'aesthetic': 'fashion-forward',
        'vibe': 'style statement',
        'colors': ['bold colors', 'patterns', 'seasonal'],
        'priority': 'trends',
      };
    } else {
      return {
        'type': 'versatile',
        'aesthetic': 'balanced',
        'vibe': 'adaptable style',
        'colors': ['neutrals', 'basics'],
        'priority': 'versatility',
      };
    }
  }

  // ✅ NEW: Analyze destination needs
  static Map<String, dynamic> _analyzeDestination(String occasion) {
    final dest = occasion.toLowerCase();

    if (dest.contains('work') ||
        dest.contains('office') ||
        dest.contains('meeting')) {
      return {
        'formality': 'high',
        'setting': 'professional',
        'movement': 'limited',
        'duration': 'long',
        'impression': 'competent',
      };
    } else if (dest.contains('party') ||
        dest.contains('dinner') ||
        dest.contains('date')) {
      return {
        'formality': 'medium-high',
        'setting': 'social',
        'movement': 'moderate',
        'duration': 'medium',
        'impression': 'attractive',
      };
    } else if (dest.contains('casual') ||
        dest.contains('shopping') ||
        dest.contains('coffee')) {
      return {
        'formality': 'low',
        'setting': 'relaxed',
        'movement': 'high',
        'duration': 'variable',
        'impression': 'approachable',
      };
    } else if (dest.contains('gym') ||
        dest.contains('sport') ||
        dest.contains('exercise')) {
      return {
        'formality': 'athletic',
        'setting': 'active',
        'movement': 'very high',
        'duration': 'medium',
        'impression': 'energetic',
      };
    } else {
      return {
        'formality': 'medium',
        'setting': 'general',
        'movement': 'moderate',
        'duration': 'medium',
        'impression': 'appropriate',
      };
    }
  }

  // ✅ NEW: Analyze weather requirements
  static Map<String, dynamic> _analyzeWeather(String weather) {
    final temp = weather.toLowerCase();

    if (temp.contains('hot') ||
        temp.contains('warm') ||
        temp.contains('sunny')) {
      return {
        'priority': 'cooling',
        'protection': 'sun protection',
        'layers': 'minimal',
        'fabrics': 'breathable',
        'colors': 'light',
      };
    } else if (temp.contains('cold') ||
        temp.contains('chilly') ||
        temp.contains('winter')) {
      return {
        'priority': 'warmth',
        'protection': 'wind/cold protection',
        'layers': 'multiple',
        'fabrics': 'insulating',
        'colors': 'dark',
      };
    } else if (temp.contains('rainy') || temp.contains('wet')) {
      return {
        'priority': 'dryness',
        'protection': 'water resistance',
        'layers': 'protective',
        'fabrics': 'quick-dry',
        'colors': 'practical',
      };
    } else {
      return {
        'priority': 'comfort',
        'protection': 'general',
        'layers': 'adaptable',
        'fabrics': 'versatile',
        'colors': 'any',
      };
    }
  }

  // ✅ NEW: Smart dress decision
  static bool _shouldChooseDress(
    List<WardrobeItem> dresses,
    Map<String, dynamic> destinationNeeds,
    Map<String, dynamic> styleProfile,
    Map<String, dynamic> weatherRequirements,
  ) {
    if (dresses.isEmpty) return false;

    // Formal occasions favor dresses
    if (destinationNeeds['formality'] == 'high' ||
        destinationNeeds['formality'] == 'medium-high') {
      return true;
    }

    // Chic/elegant styles favor dresses
    if (styleProfile['type'] == 'chic' || styleProfile['type'] == 'formal') {
      return true;
    }

    // Weather considerations
    if (weatherRequirements['priority'] == 'cooling') {
      return true;
    }

    return false;
  }

  // ✅ NEW: Context-aware item selection methods
  static WardrobeItem _selectContextAwareDress(
    List<WardrobeItem> dresses,
    Map<String, dynamic> styleProfile,
    Map<String, dynamic> destinationNeeds,
    Map<String, dynamic> weatherRequirements,
  ) {
    // Score each dress based on context
    WardrobeItem bestDress = dresses.first;
    int bestScore = 0;

    for (var dress in dresses) {
      int score = 0;
      final color = dress.color.toLowerCase();

      // Style score
      if (styleProfile['colors'].any(
        (c) => color.contains(c.toString().toLowerCase()),
      )) {
        score += 3;
      }

      // Formality score
      if (destinationNeeds['formality'] == 'high' &&
          (color.contains('black') || color.contains('navy'))) {
        score += 3;
      }

      // Weather score
      if (weatherRequirements['colors'] == 'light' &&
          (color.contains('white') || color.contains('light'))) {
        score += 2;
      }

      if (score > bestScore) {
        bestScore = score;
        bestDress = dress;
      }
    }

    return bestDress;
  }

  static WardrobeItem _selectContextAwareTop(
    List<WardrobeItem> tops,
    Map<String, dynamic> styleProfile,
    Map<String, dynamic> destinationNeeds,
    Map<String, dynamic> weatherRequirements,
  ) {
    return _scoreAndSelectItem(
      tops,
      styleProfile,
      destinationNeeds,
      weatherRequirements,
    );
  }

  static WardrobeItem _selectContextAwareBottom(
    List<WardrobeItem> bottoms,
    WardrobeItem selectedTop,
    Map<String, dynamic> styleProfile,
    Map<String, dynamic> destinationNeeds,
  ) {
    // Find bottom that coordinates with selected top
    final topColor = selectedTop.color.toLowerCase();
    WardrobeItem bestBottom = bottoms.first;
    int bestScore = 0;

    for (var bottom in bottoms) {
      int score = 0;
      final color = bottom.color.toLowerCase();

      // Color coordination score
      if (_colorsHarmonize(topColor, color)) {
        score += 3;
      }

      // Style appropriateness
      if (destinationNeeds['formality'] == 'high' &&
          (color.contains('black') || color.contains('navy'))) {
        score += 2;
      }

      if (score > bestScore) {
        bestScore = score;
        bestBottom = bottom;
      }
    }

    return bestBottom;
  }

  static WardrobeItem _selectContextAwareOuterwear(
    List<WardrobeItem> outerwear,
    List<String> usedColors,
    Map<String, dynamic> styleProfile,
    Map<String, dynamic> weatherRequirements,
  ) {
    return _scoreAndSelectItem(
      outerwear,
      styleProfile,
      {},
      weatherRequirements,
    );
  }

  static WardrobeItem _selectContextAwareShoes(
    List<WardrobeItem> shoes,
    List<String> usedColors,
    Map<String, dynamic> styleProfile,
    Map<String, dynamic> destinationNeeds,
    Map<String, dynamic> weatherRequirements,
  ) {
    return _scoreAndSelectItem(
      shoes,
      styleProfile,
      destinationNeeds,
      weatherRequirements,
    );
  }

  static WardrobeItem _selectContextAwareAccessory(
    List<WardrobeItem> accessories,
    List<String> usedColors,
    Map<String, dynamic> styleProfile,
    Map<String, dynamic> destinationNeeds,
  ) {
    return _scoreAndSelectItem(accessories, styleProfile, destinationNeeds, {});
  }

  // ✅ NEW: Generic scoring function
  static WardrobeItem _scoreAndSelectItem(
    List<WardrobeItem> items,
    Map<String, dynamic> styleProfile,
    Map<String, dynamic> destinationNeeds,
    Map<String, dynamic> weatherRequirements,
  ) {
    WardrobeItem bestItem = items.first;
    int bestScore = 0;

    for (var item in items) {
      int score = 0;
      final color = item.color.toLowerCase();

      // Style compatibility
      if (styleProfile.containsKey('colors')) {
        final styleColors = styleProfile['colors'] as List;
        if (styleColors.any(
          (c) => color.contains(c.toString().toLowerCase()),
        )) {
          score += 2;
        }
      }

      // Destination appropriateness
      if (destinationNeeds.containsKey('formality')) {
        if (destinationNeeds['formality'] == 'high' &&
            (color.contains('black') ||
                color.contains('navy') ||
                color.contains('white'))) {
          score += 2;
        }
      }

      // Weather suitability
      if (weatherRequirements.containsKey('colors')) {
        if (weatherRequirements['colors'] == 'light' &&
            (color.contains('white') || color.contains('light'))) {
          score += 1;
        }
        if (weatherRequirements['colors'] == 'dark' &&
            (color.contains('black') || color.contains('dark'))) {
          score += 1;
        }
      }

      if (score > bestScore) {
        bestScore = score;
        bestItem = item;
      }
    }

    return bestItem;
  }

  // ✅ NEW: Check if top is long-sleeved (MISSING METHOD)
  static bool _isLongSleevedTop(WardrobeItem top) {
    final name = top.name.toLowerCase();
    final longSleeveKeywords = [
      'long sleeve',
      'longsleeve',
      'long-sleeve',
      'kemeja',
      'blouse',
      'sweater',
      'hoodie',
      'turtleneck',
      'mock neck',
      'polo',
      'lengan panjang',
    ];

    return longSleeveKeywords.any((keyword) => name.contains(keyword));
  }

  // ✅ NEW: Helper functions for intelligent reasoning
  static bool _intelligentLayeringDecision(
    WardrobeItem top,
    Map<String, dynamic> weatherRequirements,
    Map<String, dynamic> destinationNeeds,
  ) {
    final isLongSleeved = _isLongSleevedTop(top);
    final needsWarmth = weatherRequirements['priority'] == 'warmth';
    return needsWarmth && !isLongSleeved;
  }

  static bool _colorsHarmonize(String color1, String color2) {
    final harmonies = {
      'blue': ['white', 'gray', 'beige'],
      'black': ['white', 'gray', 'beige'],
      'white': ['black', 'navy', 'gray'],
      'red': ['black', 'white', 'navy'],
      'green': ['white', 'beige', 'brown'],
    };

    final harmonious = harmonies[color1] ?? [];
    return harmonious.any((h) => color2.contains(h));
  }

  static String _generateIntelligentReasoning(
    List<Map<String, dynamic>> selectedItems,
    Map<String, dynamic> styleProfile,
    Map<String, dynamic> destinationNeeds,
    Map<String, dynamic> weatherRequirements,
    String occasion,
    String weather,
    String style,
  ) {
    String reasoning =
        "Outfit ini dibuat dengan analisis mendalam terhadap preferensi style ${styleProfile['type']}, ";
    reasoning +=
        "kebutuhan untuk ${destinationNeeds['setting']} setting dengan formality level ${destinationNeeds['formality']}, ";
    reasoning +=
        "dan pertimbangan cuaca yang memprioritaskan ${weatherRequirements['priority']}. ";

    if (selectedItems.isNotEmpty) {
      reasoning +=
          "Setiap piece dipilih untuk menciptakan ${styleProfile['aesthetic']} aesthetic dengan ${styleProfile['vibe']}. ";
    }

    reasoning +=
        "Color coordination mengikuti prinsip harmony yang menciptakan keseimbangan visual, ";
    reasoning +=
        "sementara fabric dan style choices disesuaikan dengan aktivitas dan comfort level yang dibutuhkan.";

    return reasoning;
  }

  // ✅ NEW: Context-specific reasoning helpers
  static String _getStyleReasoning(
    WardrobeItem item,
    Map<String, dynamic> styleProfile,
  ) {
    return "mencerminkan ${styleProfile['aesthetic']} aesthetic sesuai preferensi ${styleProfile['type']} style";
  }

  static String _getDestinationReasoning(
    WardrobeItem item,
    Map<String, dynamic> destinationNeeds,
  ) {
    return "sempurna untuk ${destinationNeeds['setting']} environment dengan impression yang ${destinationNeeds['impression']}";
  }

  static String _getComfortReasoning(
    WardrobeItem item,
    Map<String, dynamic> destinationNeeds,
  ) {
    return "memberikan comfort level yang sesuai untuk aktivitas dengan movement ${destinationNeeds['movement']}";
  }

  static String _getShoeReasoning(
    WardrobeItem shoes,
    Map<String, dynamic> destinationNeeds,
    Map<String, dynamic> weatherRequirements,
    Map<String, dynamic> styleProfile,
  ) {
    return "ideal untuk ${destinationNeeds['setting']} dengan ${weatherRequirements['protection']} dan ${styleProfile['vibe']}";
  }

  static String _getAccessoryReasoning(
    WardrobeItem accessory,
    Map<String, dynamic> styleProfile,
    Map<String, dynamic> destinationNeeds,
  ) {
    return "melengkapi ${styleProfile['aesthetic']} look dan appropriate untuk ${destinationNeeds['impression']} impression";
  }

  // ✅ NEW: Style guide generators
  static String _getStylePersonalityGuide(String style) {
    final styleType = style.toLowerCase();
    if (styleType.contains('casual')) {
      return "CASUAL STYLE: Prioritize comfort, choose relaxed fits, embrace effortless combinations, focus on versatile basics";
    } else if (styleType.contains('formal')) {
      return "FORMAL STYLE: Select structured pieces, maintain clean lines, choose sophisticated colors, ensure professional polish";
    } else if (styleType.contains('chic')) {
      return "CHIC STYLE: Emphasize refined elegance, select quality over quantity, choose timeless pieces, maintain minimalist aesthetic";
    } else {
      return "VERSATILE STYLE: Balance comfort and style, choose adaptable pieces, mix different aesthetics appropriately";
    }
  }

  static String _getDestinationGuide(String occasion) {
    final dest = occasion.toLowerCase();
    if (dest.contains('work')) {
      return "WORK SETTING: Professional appearance required, conservative choices preferred, comfort for long hours, authoritative presence";
    } else if (dest.contains('party')) {
      return "SOCIAL EVENT: Statement pieces welcome, attention to detail important, confidence-boosting choices, memorable impression";
    } else {
      return "GENERAL OCCASION: Appropriate for setting, comfortable for activities, reflects personal style, versatile choices";
    }
  }

  static String _getWeatherGuide(String weather) {
    final temp = weather.toLowerCase();
    if (temp.contains('hot')) {
      return "HOT WEATHER: Light colors preferred, breathable fabrics essential, minimal layers, sun protection considered";
    } else if (temp.contains('cold')) {
      return "COLD WEATHER: Layering strategies important, insulating materials preferred, coverage prioritized, warmth without bulk";
    } else {
      return "MODERATE WEATHER: Adaptable layering options, comfortable temperature regulation, versatile fabric choices";
    }
  }

  // ✅ API KEY TEST METHOD
  static Future<bool> testApiKey() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.openai.com/v1/models'),
        headers: {'Authorization': 'Bearer $_apiKey'},
      );

      print('🔑 API Key test - Status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('🔑 API Key test failed: $e');
      return false;
    }
  }
}

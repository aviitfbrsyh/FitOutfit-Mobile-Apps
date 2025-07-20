import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StyleQuizPage extends StatefulWidget {
  const StyleQuizPage({super.key});

  @override
  State<StyleQuizPage> createState() => _StyleQuizPageState();
}

class _StyleQuizPageState extends State<StyleQuizPage>
    with TickerProviderStateMixin {
  // FitOutfit Brand Colors
  static const Color primaryGreen = Color(0xFF2ECC7A); // Emerald Green
  static const Color accentBeige = Color(0xFFF5F5DC); // Beige
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color accentPurple = Color(0xFF7B68EE);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color deepBlue = Color(0xFF1A2B4A);
  static const Color lightBlue = Color(0xFFE6F0FF);
  static const Color shadowColor = Color(0x1A000000);

  // API Configuration - GANTI API KEY MU DI SINI!
  static const String OPENAI_API_KEY =   'YOUR_OPENAI_API_KEY';
      
  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _progressController;
  late AnimationController _shimmerController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _shimmerAnimation;

  // State Variables
  int _currentQuestion = 0;
  final Map<int, String> _answers = {};
  bool _isLoading = false;
  bool _isGeneratingQuestions = true;
  bool _showResult = false;
  String? _budgetResult;
  String? _budgetDescription;
  List<String> _budgetTips = [];
  String _quizSessionId = '';
  int _quizSessionCount = 0;
  List<String> _previousQuizIds = [];

  // User Data
  String _currentUser = 'User';
  String _currentUserId = 'user_001';

  // AI-Generated Questions
  List<Map<String, dynamic>> _budgetQuestions = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
    _generateUniqueSession();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotationController);

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    final breathingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _breathingAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: breathingController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  Future<void> _loadUserData() async {
    try {
      // Sinkronkan dulu dengan Firebase Auth
      await UserService.syncUserFromAuth();

      final username = await UserService.getCurrentUser();
      final userId = await UserService.getCurrentUserId();

      // Load previous quiz sessions
      final prefs = await SharedPreferences.getInstance();
      _quizSessionCount = prefs.getInt('quiz_session_count_$userId') ?? 0;
      _previousQuizIds = prefs.getStringList('previous_quiz_ids_$userId') ?? [];

      setState(() {
        _currentUser = username;
        _currentUserId = userId;
      });

      // Generate questions after loading user data
      _generateBudgetBehaviorQuestions();
    } catch (e) {
      print('Failed to load user data: $e');
      // Fallback to default
      setState(() {
        _currentUser = 'Guest';
        _currentUserId = 'guest_user';
      });
      _generateBudgetBehaviorQuestions();
    }
  }

  DateTime _getCurrentDateTime() {
    try {
      return DateTime.parse('2025-06-29 06:35:56');
    } catch (e) {
      return DateTime.now(); // Fallback to system time
    }
  }

  void _generateUniqueSession() {
    final now = _getCurrentDateTime();
    _quizSessionCount++;
    _quizSessionId =
        'quiz_${now.millisecondsSinceEpoch}_${_currentUser}_session${_quizSessionCount}_${math.Random().nextInt(99999)}';
  }

  Future<void> _generateBudgetBehaviorQuestions() async {
    setState(() => _isGeneratingQuestions = true);

    try {
      // Try OpenAI first dengan enhanced prompt
      final aiQuestions = await _tryOpenAI(
        context: "analyze fashion shopping habits with fresh questions",
        sessionCount: _quizSessionCount,
        previousIds: _previousQuizIds,
      );
      if (aiQuestions != null) {
        setState(() {
          _budgetQuestions = aiQuestions;
          _isGeneratingQuestions = false;
        });
        await _saveQuizSession();
        _startQuiz();
        return;
      }

      // Enhanced fallback with rotation
      await _generateEnhancedContextualFallback();
    } catch (e) {
      print('AI Generation failed: $e');
      await _generateEnhancedContextualFallback();
    }
  }

  Future<List<Map<String, dynamic>>?> _tryOpenAI({
    String context = "",
    int sessionCount = 0,
    List<String> previousIds = const [],
  }) async {
    if (OPENAI_API_KEY == 'sk-your-openai-api-key-here') return null;

    try {
      final currentDateTime = _getCurrentDateTime();
      final dayOfWeek =
          [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday',
          ][currentDateTime.weekday - 1];
      final timeOfDay =
          '${currentDateTime.hour.toString().padLeft(2, '0')}:${currentDateTime.minute.toString().padLeft(2, '0')}';

      // Enhanced prompt with STRICT value constraints
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $OPENAI_API_KEY',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  '''You are FitOutfit's AI budget fashion advisor for user "$_currentUser". 

CRITICAL: Generate COMPLETELY DIFFERENT questions each time. This is session #$sessionCount.
Previous quiz IDs: ${previousIds.join(', ')}

Context: $context. Current: $dayOfWeek $timeOfDay UTC, late June 2025.
User: $_currentUser (Session #$sessionCount)

STRICT VALUE REQUIREMENTS:
You MUST use ONLY these predefined answer values for scoring to work:

SMART SAVER values: rare, planned, aware, wishlist, disciplined, strict, quality, independent, never, never_regret, donate, thorough_compare, days_weeks, overnight, ignore_trends, stick_style, shopping_ban, early_planner, end_season_deals, year_round, basics, practical, own_creativity, alone, dont_care, ignore

OVERBUDGET FASHIONISTA values: overbudget, often, impulse, no_idea, rarely, frequent, opportunistic, quantity, social_media, early_adopter, very_important, buy_similar, stand_out, immediate_change, continue_normal, peak_season, new_season, trendy, expression, social, emotional, instant, few_minutes, mainstream, often_regret, expensive_regret

IMPULSE SWITCHER values: switcher, sometimes, flexible, monthly, mix, seasonal, balanced, selective, compromise, follow_along, more_confident, adapt, hurt_no_change, adjust_budget, return_items, keep_all, share, quick_check, selective_adoption, depends_mood, depends, mixed, occasional_regret, fit_issues, need_based, accessories, outerwear, magazines, friends_family, with_friends, with_family, somewhat_important, neutral, feels_right

DEAL HUNTER values: deal_hunter, thrift, cashback, investment, resell, trust_store, sale_events, end_season, deal_hunter_discount, discount_reaction, impulse_buy, satisfied, morning, afternoon, evening, weekend, events, trends, practical_needs, ask_others, blend_in, avoid_groups, self_conscious

REQUIREMENTS:
1. Generate 6 UNIQUE questions that are DIFFERENT from previous sessions
2. Use fresh scenarios, different wording, and varied contexts
3. Mix question types: scenarios, preferences, behaviors, reactions
4. Address user by name occasionally but vary the approach
5. Make questions feel contextual to current time/situation
6. Each option MUST use one of the predefined values above
7. Match the value to the appropriate personality type

VARIETY EXAMPLES:
- Session 1: "How often do you shop?"
- Session 2: "When do you typically buy new clothes?"
- Session 3: "What triggers your fashion purchases?"

Categories to rotate (pick 6 different angles):
- Shopping frequency & timing
- Budget reactions & limits  
- Brand preferences & choices
- Planning vs spontaneous behavior
- Spending awareness & tracking
- Saving strategies & methods
- Seasonal shopping patterns
- Social influence on purchases
- Quality vs quantity mindset
- Trend following behavior

Return ONLY valid JSON with exactly 6 FRESH questions:
{
  "questions": [
    {
      "id": 1,
      "category": "Fresh Category Name",
      "question": "Completely different question for $_currentUser?",
      "subtitle": "New engaging subtitle",
      "icon": "relevant_icon",
      "options": [
        {"text": "Fresh option 1", "subtitle": "New description", "value": "rare", "icon": "icon1", "color": "primaryGreen"},
        {"text": "Fresh option 2", "subtitle": "New description", "value": "sometimes", "icon": "icon2", "color": "accentBeige"},
        {"text": "Fresh option 3", "subtitle": "New description", "value": "often", "icon": "icon3", "color": "accentYellow"},
        {"text": "Fresh option 4", "subtitle": "New description", "value": "impulse", "icon": "icon4", "color": "accentRed"}
      ]
    }
  ]
}

MAKE EACH SESSION FEEL COMPLETELY DIFFERENT BUT USE ONLY THE PREDEFINED VALUES!''',
            },
            {
              'role': 'user',
              'content':
                  'Generate FRESH $dayOfWeek budget fashion quiz for $_currentUser. Session #$sessionCount at $timeOfDay. Make it completely different from previous sessions. ID: $_quizSessionId. Use ONLY the predefined answer values.',
            },
          ],
          'max_tokens': 3000,
          'temperature': 0.9,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final cleanContent =
            content.replaceAll('```json', '').replaceAll('```', '').trim();
        final parsed = jsonDecode(cleanContent);
        return _parseAIQuestions(parsed['questions']);
      }
    } catch (e) {
      print('OpenAI error: $e');
    }
    return null;
  }

  List<Map<String, dynamic>> _parseAIQuestions(List<dynamic> aiQuestions) {
    return aiQuestions.map<Map<String, dynamic>>((q) {
      return {
        'id': q['id'],
        'category': q['category'],
        'question': q['question'],
        'subtitle': q['subtitle'],
        'icon': _parseIcon(q['icon']),
        'options':
            (q['options'] as List)
                .map(
                  (opt) => {
                    'text': opt['text'],
                    'subtitle': opt['subtitle'],
                    'value': opt['value'],
                    'icon': _parseIcon(opt['icon']),
                    'color': _parseColor(opt['color']),
                  },
                )
                .toList(),
      };
    }).toList();
  }

  IconData _parseIcon(String iconName) {
    switch (iconName) {
      case 'wb_sunny_outlined':
        return Icons.wb_sunny_outlined;
      case 'palette_outlined':
        return Icons.palette_outlined;
      case 'color_lens_outlined':
        return Icons.color_lens_outlined;
      case 'weekend_outlined':
        return Icons.weekend_outlined;
      case 'checkroom_outlined':
        return Icons.checkroom_outlined;
      case 'watch_outlined':
        return Icons.watch_outlined;
      case 'star_outline':
        return Icons.star_outline;
      case 'home_outlined':
        return Icons.home_outlined;
      case 'flash_on_outlined':
        return Icons.flash_on_outlined;
      case 'diamond_outlined':
        return Icons.diamond_outlined;
      case 'nature_people_outlined':
        return Icons.nature_people_outlined;
      case 'trending_up_outlined':
        return Icons.trending_up_outlined;
      case 'favorite_border_outlined':
        return Icons.favorite_border_outlined;
      case 'shopping_bag_outlined':
        return Icons.shopping_bag_outlined;
      case 'camera_alt_outlined':
        return Icons.camera_alt_outlined;
      case 'waves_outlined':
        return Icons.waves_outlined;
      case 'circle_outlined':
        return Icons.circle_outlined;
      case 'local_fire_department_outlined':
        return Icons.local_fire_department_outlined;
      case 'architecture_outlined':
        return Icons.architecture_outlined;
      case 'psychology_outlined':
        return Icons.psychology_outlined;
      case 'straighten_outlined':
        return Icons.straighten_outlined;
      case 'air_outlined':
        return Icons.air_outlined;
      case 'balance_outlined':
        return Icons.balance_outlined;
      case 'fitness_center_outlined':
        return Icons.fitness_center_outlined;
      case 'photo_camera_outlined':
        return Icons.photo_camera_outlined;
      case 'directions_walk_outlined':
        return Icons.directions_walk_outlined;
      case 'auto_awesome_outlined':
        return Icons.auto_awesome_outlined;
      case 'directions_run_outlined':
        return Icons.directions_run_outlined;
      case 'business_center_outlined':
        return Icons.business_center_outlined;
      case 'celebration_outlined':
        return Icons.celebration_outlined;
      case 'spa_outlined':
        return Icons.spa_outlined;
      default:
        return Icons.style_outlined;
    }
  }

  Color _parseColor(String colorName) {
    switch (colorName) {
      case 'primaryBlue':
        return primaryGreen;
      case 'accentYellow':
        return accentYellow;
      case 'accentRed':
        return accentRed;
      case 'accentPurple':
        return accentPurple;
      case 'deepBlue':
        return deepBlue;
      case 'mediumGray':
        return mediumGray;
      default:
        return primaryGreen;
    }
  }

  Future<void> _generateEnhancedContextualFallback() async {
    // Buat berbagai set soal yang bisa dirotasi
    List<List<Map<String, dynamic>>> questionSets = [
      _getQuestionSet1(), // Original set
      _getQuestionSet2(), // Alternative scenarios
      _getQuestionSet3(), // Seasonal/contextual
      _getQuestionSet4(), // Behavioral focus
      _getQuestionSet5(), // Social influence
    ];

    // Pilih set berdasarkan session count
    int setIndex = _quizSessionCount % questionSets.length;
    List<Map<String, dynamic>> selectedSet = questionSets[setIndex];

    // Shuffle questions dalam set
    selectedSet.shuffle(math.Random(_quizSessionCount));

    setState(() {
      _budgetQuestions = selectedSet;
      _isGeneratingQuestions = false;
    });

    await _saveQuizSession();
    _startQuiz();
  }

  Map<String, dynamic> _getShoppingFrequencyQuestion() {
    return {
      'id': 1,
      'category': 'Shopping Frequency',
      'question': 'How often do you shop for fashion items, $_currentUser?',
      'subtitle': 'Budgeting your shopping habits',
      'icon': Icons.shopping_bag_outlined,
      'options': [
        {
          'text': 'Once a month or less',
          'subtitle': 'Very planned',
          'value': 'rare',
          'icon': Icons.calendar_today,
          'color': primaryGreen,
        },
        {
          'text': '2-3 times a month',
          'subtitle': 'Occasional treat',
          'value': 'sometimes',
          'icon': Icons.event_note,
          'color': accentBeige,
        },
        {
          'text': 'Weekly',
          'subtitle': 'Love new arrivals',
          'value': 'often',
          'icon': Icons.local_mall,
          'color': accentYellow,
        },
        {
          'text': 'Whenever I see something I like',
          'subtitle': 'Spontaneous',
          'value': 'impulse',
          'icon': Icons.flash_on_outlined,
          'color': accentRed,
        },
      ],
    };
  }

  Map<String, dynamic> _getDiscountReactionQuestion() {
    return {
      'id': 2,
      'category': 'Discount Reaction',
      'question': 'What do you do when you see a big fashion sale?',
      'subtitle': 'Promo temptation check',
      'icon': Icons.sell_outlined,
      'options': [
        {
          'text': 'Only buy if I need it',
          'subtitle': 'Stay disciplined',
          'value': 'disciplined',
          'icon': Icons.check_circle_outline,
          'color': primaryGreen,
        },
        {
          'text': 'Add to wishlist, decide later',
          'subtitle': 'Smart waiting',
          'value': 'wishlist',
          'icon': Icons.bookmark_border,
          'color': accentBeige,
        },
        {
          'text': 'Buy if the deal is too good',
          'subtitle': 'Deal hunter',
          'value': 'deal_hunter',
          'icon': Icons.local_offer,
          'color': accentYellow,
        },
        {
          'text': 'Buy a lot, can\'t resist',
          'subtitle': 'Overbudget',
          'value': 'overbudget',
          'icon': Icons.shopping_cart,
          'color': accentRed,
        },
      ],
    };
  }

  Map<String, dynamic> _getBrandVsThriftQuestion() {
    return {
      'id': 3,
      'category': 'Brand vs Thrift',
      'question': 'Which do you prefer for fashion shopping?',
      'subtitle': 'Brand or thrift store?',
      'icon': Icons.storefront_outlined,
      'options': [
        {
          'text': 'Only trusted brands',
          'subtitle': 'Quality first',
          'value': 'brand',
          'icon': Icons.star_outline,
          'color': primaryGreen,
        },
        {
          'text': 'Mix of both',
          'subtitle': 'Flexible',
          'value': 'mix',
          'icon': Icons.compare_arrows,
          'color': accentBeige,
        },
        {
          'text': 'Mostly thrift/secondhand',
          'subtitle': 'Budget-friendly',
          'value': 'thrift',
          'icon': Icons.recycling,
          'color': accentYellow,
        },
        {
          'text': 'Wherever the best deal is',
          'subtitle': 'Deal hunter',
          'value': 'deal_hunter',
          'icon': Icons.local_offer,
          'color': accentRed,
        },
      ],
    };
  }

  Map<String, dynamic> _getShoppingPlanningQuestion() {
    return {
      'id': 4,
      'category': 'Shopping Planning',
      'question': 'How do you usually shop for fashion?',
      'subtitle': 'Impulse or planned?',
      'icon': Icons.assignment_turned_in_outlined,
      'options': [
        {
          'text': 'Always plan & budget',
          'subtitle': 'Smart saver',
          'value': 'planned',
          'icon': Icons.assignment,
          'color': primaryGreen,
        },
        {
          'text': 'Plan sometimes, but open to impulse',
          'subtitle': 'Impulse switcher',
          'value': 'switcher',
          'icon': Icons.swap_horiz,
          'color': accentBeige,
        },
        {
          'text': 'Mostly impulsive',
          'subtitle': 'Spontaneous',
          'value': 'impulse',
          'icon': Icons.flash_on_outlined,
          'color': accentRed,
        },
        {
          'text': 'Depends on mood',
          'subtitle': 'Flexible',
          'value': 'flexible',
          'icon': Icons.mood,
          'color': accentYellow,
        },
      ],
    };
  }

  Map<String, dynamic> _getSpendingAwarenessQuestion() {
    return {
      'id': 5,
      'category': 'Spending Awareness',
      'question': 'How aware are you of your fashion spending?',
      'subtitle': 'Track your expenses',
      'icon': Icons.receipt_long_outlined,
      'options': [
        {
          'text': 'Track every purchase',
          'subtitle': 'Very aware',
          'value': 'aware',
          'icon': Icons.visibility,
          'color': primaryGreen,
        },
        {
          'text': 'Check monthly',
          'subtitle': 'Somewhat aware',
          'value': 'monthly',
          'icon': Icons.calendar_today,
          'color': accentBeige,
        },
        {
          'text': 'Rarely check',
          'subtitle': 'Not really aware',
          'value': 'rarely',
          'icon': Icons.visibility_off,
          'color': accentRed,
        },
        {
          'text': 'Don\'t track at all',
          'subtitle': 'No idea',
          'value': 'no_idea',
          'icon': Icons.help_outline,
          'color': accentYellow,
        },
      ],
    };
  }

  Map<String, dynamic> _getSavingStrategyQuestion() {
    return {
      'id': 6,
      'category': 'Saving Strategy',
      'question': 'What\'s your favorite way to save on fashion?',
      'subtitle': 'Smart shopping tips',
      'icon': Icons.savings_outlined,
      'options': [
        {
          'text': 'Wait for big sales',
          'subtitle': 'Deal hunter',
          'value': 'deal_hunter',
          'icon': Icons.sell_outlined,
          'color': accentYellow,
        },
        {
          'text': 'Use wishlist & plan',
          'subtitle': 'Smart saver',
          'value': 'wishlist',
          'icon': Icons.bookmark_border,
          'color': primaryGreen,
        },
        {
          'text': 'Buy secondhand/thrift',
          'subtitle': 'Eco & budget',
          'value': 'thrift',
          'icon': Icons.recycling,
          'color': accentBeige,
        },
        {
          'text': 'Use cashback/rewards',
          'subtitle': 'Extra saving',
          'value': 'cashback',
          'icon': Icons.card_giftcard,
          'color': accentPurple,
        },
      ],
    };
  }

  // Original question set
  List<Map<String, dynamic>> _getQuestionSet1() {
    return [
      _getShoppingFrequencyQuestion(),
      _getDiscountReactionQuestion(),
      _getBrandVsThriftQuestion(),
      _getShoppingPlanningQuestion(),
      _getSpendingAwarenessQuestion(),
      _getSavingStrategyQuestion(),
    ];
  }

  // Update the fallback question sets to use consistent values
  List<Map<String, dynamic>> _getQuestionSet2() {
    return [
      {
        'id': 1,
        'category': 'Shopping Triggers',
        'question':
            'What usually makes you want to buy new clothes, $_currentUser?',
        'subtitle': 'Understanding your shopping motivation',
        'icon': Icons.psychology_outlined,
        'options': [
          {
            'text': 'Only when I need replacements',
            'subtitle': 'Practical needs',
            'value': 'practical',
            'icon': Icons.build,
            'color': primaryGreen,
          },
          {
            'text': 'When I see something trendy',
            'subtitle': 'Fashion forward',
            'value': 'trendy',
            'icon': Icons.trending_up,
            'color': accentYellow,
          },
          {
            'text': 'Special occasions or events',
            'subtitle': 'Event-driven',
            'value': 'events',
            'icon': Icons.event,
            'color': accentPurple,
          },
          {
            'text': 'Whenever I feel like it',
            'subtitle': 'Impulse driven',
            'value': 'impulse',
            'icon': Icons.flash_on,
            'color': accentRed,
          },
        ],
      },
      {
        'id': 2,
        'category': 'Budget Boundaries',
        'question': 'How do you handle your fashion budget limits?',
        'subtitle': 'Setting spending boundaries',
        'icon': Icons.account_balance_wallet,
        'options': [
          {
            'text': 'Stick to planned budget strictly',
            'subtitle': 'Disciplined approach',
            'value': 'disciplined',
            'icon': Icons.rule,
            'color': primaryGreen,
          },
          {
            'text': 'Flexible within reason',
            'subtitle': 'Adaptable spending',
            'value': 'flexible',
            'icon': Icons.tune,
            'color': accentBeige,
          },
          {
            'text': 'Often go over budget',
            'subtitle': 'Overspending tendency',
            'value': 'overbudget',
            'icon': Icons.trending_up,
            'color': accentYellow,
          },
          {
            'text': 'Don\'t really track spending',
            'subtitle': 'No budget awareness',
            'value': 'no_idea',
            'icon': Icons.help_outline,
            'color': accentRed,
          },
        ],
      },
      {
        'id': 3,
        'category': 'Quality vs Quantity',
        'question': 'Which approach do you prefer for fashion shopping?',
        'subtitle': 'Your shopping philosophy',
        'icon': Icons.balance,
        'options': [
          {
            'text': 'Few high-quality pieces',
            'subtitle': 'Quality focused',
            'value': 'quality',
            'icon': Icons.star,
            'color': primaryGreen,
          },
          {
            'text': 'Good deals and discounts',
            'subtitle': 'Value hunting',
            'value': 'deal_hunter',
            'icon': Icons.local_offer,
            'color': accentYellow,
          },
          {
            'text': 'Mix of both approaches',
            'subtitle': 'Balanced strategy',
            'value': 'mix',
            'icon': Icons.balance,
            'color': accentBeige,
          },
          {
            'text': 'Many trendy pieces',
            'subtitle': 'Quantity over quality',
            'value': 'quantity',
            'icon': Icons.shopping_cart,
            'color': accentPurple,
          },
        ],
      },
      {
        'id': 4,
        'category': 'Shopping Timing',
        'question': 'When do you typically shop for fashion items?',
        'subtitle': 'Your preferred shopping schedule',
        'icon': Icons.schedule,
        'options': [
          {
            'text': 'Plan ahead for seasons',
            'subtitle': 'Early planner',
            'value': 'early_planner',
            'icon': Icons.schedule,
            'color': primaryGreen,
          },
          {
            'text': 'Beginning of new season',
            'subtitle': 'Fresh start',
            'value': 'new_season',
            'icon': Icons.fiber_new,
            'color': accentYellow,
          },
          {
            'text': 'Whenever I need something',
            'subtitle': 'Need-based',
            'value': 'need_based',
            'icon': Icons.shopping_cart,
            'color': accentBeige,
          },
          {
            'text': 'During major sale events',
            'subtitle': 'Deal hunter',
            'value': 'sale_events',
            'icon': Icons.local_offer,
            'color': accentRed,
          },
        ],
      },
      {
        'id': 5,
        'category': 'Social Influence',
        'question': 'How much do others influence your fashion purchases?',
        'subtitle': 'Social shopping behavior',
        'icon': Icons.people,
        'options': [
          {
            'text': 'I shop completely independently',
            'subtitle': 'Independent buyer',
            'value': 'independent',
            'icon': Icons.person,
            'color': primaryGreen,
          },
          {
            'text': 'Sometimes ask friends for advice',
            'subtitle': 'Occasional advisor',
            'value': 'ask_others',
            'icon': Icons.question_answer,
            'color': accentBeige,
          },
          {
            'text': 'Influenced by social media',
            'subtitle': 'Trend follower',
            'value': 'social_media',
            'icon': Icons.phone_android,
            'color': accentYellow,
          },
          {
            'text': 'Need others\' validation',
            'subtitle': 'Social dependent',
            'value': 'very_important',
            'icon': Icons.people,
            'color': accentPurple,
          },
        ],
      },
      {
        'id': 6,
        'category': 'Spending Awareness',
        'question': 'How aware are you of your fashion spending?',
        'subtitle': 'Budget tracking behavior',
        'icon': Icons.visibility,
        'options': [
          {
            'text': 'Track every purchase carefully',
            'subtitle': 'Very aware',
            'value': 'aware',
            'icon': Icons.visibility,
            'color': primaryGreen,
          },
          {
            'text': 'Check spending monthly',
            'subtitle': 'Monthly tracking',
            'value': 'monthly',
            'icon': Icons.calendar_today,
            'color': accentBeige,
          },
          {
            'text': 'Rarely check my spending',
            'subtitle': 'Limited awareness',
            'value': 'rarely',
            'icon': Icons.visibility_off,
            'color': accentYellow,
          },
          {
            'text': 'Don\'t track at all',
            'subtitle': 'No awareness',
            'value': 'no_idea',
            'icon': Icons.help_outline,
            'color': accentRed,
          },
        ],
      },
    ];
  }

  // Question set 3 - Seasonal/contextual
  List<Map<String, dynamic>> _getQuestionSet3() {
    return [
      {
        'id': 1,
        'category': 'Seasonal Shopping',
        'question':
            'How do you approach seasonal fashion shopping, $_currentUser?',
        'subtitle': 'Your seasonal style strategy',
        'icon': Icons.wb_sunny_outlined,
        'options': [
          {
            'text': 'Buy before season starts',
            'subtitle': 'Early planner',
            'value': 'early_planner',
            'icon': Icons.schedule,
            'color': primaryGreen,
          },
          {
            'text': 'Shop during peak season',
            'subtitle': 'Current needs',
            'value': 'peak_season',
            'icon': Icons.local_fire_department,
            'color': accentYellow,
          },
          {
            'text': 'Wait for end-of-season sales',
            'subtitle': 'Deal hunter',
            'value': 'end_season_deals',
            'icon': Icons.local_offer,
            'color': accentPurple,
          },
          {
            'text': 'Year-round basic pieces',
            'subtitle': 'Timeless style',
            'value': 'year_round',
            'icon': Icons.all_inclusive,
            'color': accentBeige,
          },
        ],
      },
      {
        'id': 2,
        'category': 'Wardrobe Management',
        'question': 'What happens to clothes you no longer wear?',
        'subtitle': 'Closet cleaning habits',
        'icon': Icons.checkroom_outlined,
        'options': [
          {
            'text': 'Donate regularly',
            'subtitle': 'Generous giver',
            'value': 'donate',
            'icon': Icons.favorite,
            'color': primaryGreen,
          },
          {
            'text': 'Sell online/consignment',
            'subtitle': 'Smart seller',
            'value': 'resell',
            'icon': Icons.sell,
            'color': accentYellow,
          },
          {
            'text': 'Keep everything',
            'subtitle': 'Collector',
            'value': 'keep_all',
            'icon': Icons.storage,
            'color': accentPurple,
          },
          {
            'text': 'Give to friends/family',
            'subtitle': 'Share with loved ones',
            'value': 'share',
            'icon': Icons.people,
            'color': accentBeige,
          },
        ],
      },
      {
        'id': 3,
        'category': 'Price Comparison',
        'question': 'How do you handle price research before buying?',
        'subtitle': 'Your price-checking behavior',
        'icon': Icons.compare_arrows,
        'options': [
          {
            'text': 'Always compare 3+ stores',
            'subtitle': 'Thorough researcher',
            'value': 'thorough_compare',
            'icon': Icons.search,
            'color': primaryGreen,
          },
          {
            'text': 'Quick online check',
            'subtitle': 'Fast comparer',
            'value': 'quick_check',
            'icon': Icons.speed,
            'color': accentYellow,
          },
          {
            'text': 'Trust favorite stores',
            'subtitle': 'Loyal shopper',
            'value': 'trust_store',
            'icon': Icons.star,
            'color': accentPurple,
          },
          {
            'text': 'Buy first, regret later',
            'subtitle': 'Impulse buyer',
            'value': 'impulse_buy',
            'icon': Icons.flash_on,
            'color': accentRed,
          },
        ],
      },
      {
        'id': 4,
        'category': 'Fashion Investment',
        'question': 'Which fashion items do you splurge on?',
        'subtitle': 'Your investment priorities',
        'icon': Icons.diamond_outlined,
        'options': [
          {
            'text': 'Shoes and bags',
            'subtitle': 'Accessories first',
            'value': 'accessories',
            'icon': Icons.shopping_bag,
            'color': primaryGreen,
          },
          {
            'text': 'Outerwear and coats',
            'subtitle': 'Statement pieces',
            'value': 'outerwear',
            'icon': Icons.ac_unit,
            'color': accentYellow,
          },
          {
            'text': 'Basic everyday items',
            'subtitle': 'Foundation builder',
            'value': 'basics',
            'icon': Icons.checkroom,
            'color': accentPurple,
          },
          {
            'text': 'Trendy statement pieces',
            'subtitle': 'Fashion forward',
            'value': 'trendy',
            'icon': Icons.auto_awesome,
            'color': accentRed,
          },
        ],
      },
      {
        'id': 5,
        'category': 'Shopping Emotions',
        'question': 'How do you feel after a big shopping session?',
        'subtitle': 'Post-shopping emotional state',
        'icon': Icons.psychology_outlined,
        'options': [
          {
            'text': 'Satisfied and happy',
            'subtitle': 'Positive shopper',
            'value': 'satisfied',
            'icon': Icons.sentiment_very_satisfied,
            'color': primaryGreen,
          },
          {
            'text': 'Excited but worried',
            'subtitle': 'Mixed feelings',
            'value': 'mixed',
            'icon': Icons.sentiment_neutral,
            'color': accentYellow,
          },
          {
            'text': 'Guilty about spending',
            'subtitle': 'Regretful buyer',
            'value': 'guilty',
            'icon': Icons.sentiment_dissatisfied,
            'color': accentRed,
          },
          {
            'text': 'Depends on what I bought',
            'subtitle': 'Situational',
            'value': 'depends',
            'icon': Icons.help_outline,
            'color': accentPurple,
          },
        ],
      },
      {
        'id': 6,
        'category': 'Budget Recovery',
        'question': 'How do you recover after overspending on fashion?',
        'subtitle': 'Post-overspending strategy',
        'icon': Icons.healing,
        'options': [
          {
            'text': 'No shopping ban for weeks',
            'subtitle': 'Strict discipline',
            'value': 'shopping_ban',
            'icon': Icons.block,
            'color': primaryGreen,
          },
          {
            'text': 'Return some items',
            'subtitle': 'Damage control',
            'value': 'return_items',
            'icon': Icons.keyboard_return,
            'color': accentYellow,
          },
          {
            'text': 'Adjust other expenses',
            'subtitle': 'Budget juggler',
            'value': 'adjust_budget',
            'icon': Icons.tune,
            'color': accentPurple,
          },
          {
            'text': 'Continue as normal',
            'subtitle': 'No regrets',
            'value': 'continue_normal',
            'icon': Icons.sentiment_satisfied,
            'color': accentBeige,
          },
        ],
      },
    ];
  }

  // Question set 4 - Behavioral focus
  List<Map<String, dynamic>> _getQuestionSet4() {
    return [
      {
        'id': 1,
        'category': 'Shopping Motivation',
        'question': 'What drives your fashion purchases most, $_currentUser?',
        'subtitle': 'Your primary shopping motivation',
        'icon': Icons.psychology_outlined,
        'options': [
          {
            'text': 'Practical needs',
            'subtitle': 'Function over form',
            'value': 'practical',
            'icon': Icons.build,
            'color': primaryGreen,
          },
          {
            'text': 'Self-expression',
            'subtitle': 'Personal style',
            'value': 'expression',
            'icon': Icons.palette,
            'color': accentYellow,
          },
          {
            'text': 'Social acceptance',
            'subtitle': 'Fit in',
            'value': 'social',
            'icon': Icons.people,
            'color': accentPurple,
          },
          {
            'text': 'Emotional comfort',
            'subtitle': 'Retail therapy',
            'value': 'emotional',
            'icon': Icons.favorite,
            'color': accentRed,
          },
        ],
      },
      {
        'id': 2,
        'category': 'Decision Making',
        'question': 'How long do you typically take to decide on a purchase?',
        'subtitle': 'Your decision-making speed',
        'icon': Icons.timer_outlined,
        'options': [
          {
            'text': 'Instant decision',
            'subtitle': 'Quick decider',
            'value': 'instant',
            'icon': Icons.flash_on,
            'color': accentRed,
          },
          {
            'text': 'Few minutes thinking',
            'subtitle': 'Fast thinker',
            'value': 'few_minutes',
            'icon': Icons.speed,
            'color': accentYellow,
          },
          {
            'text': 'Sleep on it overnight',
            'subtitle': 'Careful considerer',
            'value': 'overnight',
            'icon': Icons.bedtime,
            'color': accentPurple,
          },
          {
            'text': 'Days or weeks',
            'subtitle': 'Thorough analyzer',
            'value': 'days_weeks',
            'icon': Icons.calendar_today,
            'color': primaryGreen,
          },
        ],
      },
      {
        'id': 3,
        'category': 'Style Inspiration',
        'question': 'Where do you get your fashion inspiration from?',
        'subtitle': 'Your style influence sources',
        'icon': Icons.lightbulb_outline,
        'options': [
          {
            'text': 'Social media influencers',
            'subtitle': 'Digital inspiration',
            'value': 'social_media',
            'icon': Icons.phone_android,
            'color': accentYellow,
          },
          {
            'text': 'Friends and family',
            'subtitle': 'Personal circle',
            'value': 'friends_family',
            'icon': Icons.people,
            'color': accentPurple,
          },
          {
            'text': 'Fashion magazines/blogs',
            'subtitle': 'Traditional media',
            'value': 'magazines',
            'icon': Icons.article,
            'color': accentBeige,
          },
          {
            'text': 'Own creativity',
            'subtitle': 'Self-inspired',
            'value': 'own_creativity',
            'icon': Icons.auto_awesome,
            'color': primaryGreen,
          },
        ],
      },
      {
        'id': 4,
        'category': 'Trend Following',
        'question': 'How do you approach fashion trends?',
        'subtitle': 'Your trend adoption style',
        'icon': Icons.trending_up,
        'options': [
          {
            'text': 'Early adopter',
            'subtitle': 'Trendsetter',
            'value': 'early_adopter',
            'icon': Icons.rocket_launch,
            'color': accentRed,
          },
          {
            'text': 'Follow when popular',
            'subtitle': 'Mainstream follower',
            'value': 'mainstream',
            'icon': Icons.people,
            'color': accentYellow,
          },
          {
            'text': 'Selective adoption',
            'subtitle': 'Trend filter',
            'value': 'selective',
            'icon': Icons.tune,
            'color': accentPurple,
          },
          {
            'text': 'Ignore trends',
            'subtitle': 'Timeless style',
            'value': 'ignore_trends',
            'icon': Icons.block,
            'color': primaryGreen,
          },
        ],
      },
      {
        'id': 5,
        'category': 'Shopping Habits',
        'question': 'What time do you prefer to shop for fashion?',
        'subtitle': 'Your shopping timing preference',
        'icon': Icons.access_time,
        'options': [
          {
            'text': 'Morning hours',
            'subtitle': 'Fresh start',
            'value': 'morning',
            'icon': Icons.wb_sunny,
            'color': accentYellow,
          },
          {
            'text': 'Afternoon/lunch break',
            'subtitle': 'Midday break',
            'value': 'afternoon',
            'icon': Icons.lunch_dining,
            'color': accentPurple,
          },
          {
            'text': 'Evening after work',
            'subtitle': 'Post-work unwind',
            'value': 'evening',
            'icon': Icons.nights_stay,
            'color': accentBeige,
          },
          {
            'text': 'Weekend leisure time',
            'subtitle': 'Weekend warrior',
            'value': 'weekend',
            'icon': Icons.weekend,
            'color': primaryGreen,
          },
        ],
      },
      {
        'id': 6,
        'category': 'Purchase Regret',
        'question': 'How often do you regret fashion purchases?',
        'subtitle': 'Your buyer\'s remorse frequency',
        'icon': Icons.sentiment_dissatisfied,
        'options': [
          {
            'text': 'Almost never',
            'subtitle': 'Confident buyer',
            'value': 'never_regret',
            'icon': Icons.sentiment_very_satisfied,
            'color': primaryGreen,
          },
          {
            'text': 'Occasionally',
            'subtitle': 'Mostly satisfied',
            'value': 'occasional_regret',
            'icon': Icons.sentiment_neutral,
            'color': accentYellow,
          },
          {
            'text': 'Often',
            'subtitle': 'Frequent regret',
            'value': 'often_regret',
            'icon': Icons.sentiment_dissatisfied,
            'color': accentRed,
          },
          {
            'text': 'Only for expensive items',
            'subtitle': 'Price-sensitive regret',
            'value': 'expensive_regret',
            'icon': Icons.attach_money,
            'color': accentPurple,
          },
        ],
      },
    ];
  }

  // Question set 5 - Social influence
  List<Map<String, dynamic>> _getQuestionSet5() {
    return [
      {
        'id': 1,
        'category': 'Social Shopping',
        'question':
            'Do you prefer shopping alone or with others, $_currentUser?',
        'subtitle': 'Your social shopping preference',
        'icon': Icons.people_outline,
        'options': [
          {
            'text': 'Always alone',
            'subtitle': 'Independent shopper',
            'value': 'alone',
            'icon': Icons.person,
            'color': primaryGreen,
          },
          {
            'text': 'With close friends',
            'subtitle': 'Social shopper',
            'value': 'with_friends',
            'icon': Icons.people,
            'color': accentYellow,
          },
          {
            'text': 'With family',
            'subtitle': 'Family time',
            'value': 'with_family',
            'icon': Icons.family_restroom,
            'color': accentPurple,
          },
          {
            'text': 'Depends on mood',
            'subtitle': 'Flexible approach',
            'value': 'depends_mood',
            'icon': Icons.mood,
            'color': accentBeige,
          },
        ],
      },
      {
        'id': 2,
        'category': 'Opinion Seeking',
        'question':
            'How important are others\' opinions on your fashion choices?',
        'subtitle': 'Social validation importance',
        'icon': Icons.thumbs_up_down,
        'options': [
          {
            'text': 'Very important',
            'subtitle': 'Validation seeker',
            'value': 'very_important',
            'icon': Icons.star,
            'color': accentRed,
          },
          {
            'text': 'Somewhat important',
            'subtitle': 'Moderate influence',
            'value': 'somewhat_important',
            'icon': Icons.star_half,
            'color': accentYellow,
          },
          {
            'text': 'Not very important',
            'subtitle': 'Mostly independent',
            'value': 'not_important',
            'icon': Icons.star_border,
            'color': accentPurple,
          },
          {
            'text': 'I don\'t care at all',
            'subtitle': 'Completely independent',
            'value': 'dont_care',
            'icon': Icons.block,
            'color': primaryGreen,
          },
        ],
      },
      {
        'id': 3,
        'category': 'Peer Pressure',
        'question': 'How do you handle fashion peer pressure?',
        'subtitle': 'Your response to social influence',
        'icon': Icons.group,
        'options': [
          {
            'text': 'Stick to my style',
            'subtitle': 'Style confident',
            'value': 'stick_style',
            'icon': Icons.self_improvement,
            'color': primaryGreen,
          },
          {
            'text': 'Compromise sometimes',
            'subtitle': 'Flexible adapter',
            'value': 'compromise',
            'icon': Icons.balance,
            'color': accentYellow,
          },
          {
            'text': 'Usually follow along',
            'subtitle': 'Group harmonizer',
            'value': 'follow_along',
            'icon': Icons.follow_the_signs,
            'color': accentPurple,
          },
          {
            'text': 'Avoid group situations',
            'subtitle': 'Conflict avoider',
            'value': 'avoid_groups',
            'icon': Icons.visibility_off,
            'color': accentRed,
          },
        ],
      },
      {
        'id': 4,
        'category': 'Fashion Compliments',
        'question': 'How do compliments affect your fashion choices?',
        'subtitle': 'Response to positive feedback',
        'icon': Icons.favorite_border,
        'options': [
          {
            'text': 'Buy more similar items',
            'subtitle': 'Compliment chaser',
            'value': 'buy_similar',
            'icon': Icons.repeat,
            'color': accentRed,
          },
          {
            'text': 'Feel more confident',
            'subtitle': 'Confidence booster',
            'value': 'more_confident',
            'icon': Icons.sentiment_very_satisfied,
            'color': accentYellow,
          },
          {
            'text': 'Nice but doesn\'t change anything',
            'subtitle': 'Neutral response',
            'value': 'neutral',
            'icon': Icons.sentiment_neutral,
            'color': accentPurple,
          },
          {
            'text': 'Make me self-conscious',
            'subtitle': 'Overthink response',
            'value': 'self_conscious',
            'icon': Icons.sentiment_dissatisfied,
            'color': primaryGreen,
          },
        ],
      },
      {
        'id': 5,
        'category': 'Social Events',
        'question': 'How do you approach dressing for social events?',
        'subtitle': 'Event dressing strategy',
        'icon': Icons.event,
        'options': [
          {
            'text': 'Ask what others are wearing',
            'subtitle': 'Coordination seeker',
            'value': 'ask_others',
            'icon': Icons.question_answer,
            'color': accentYellow,
          },
          {
            'text': 'Dress to stand out',
            'subtitle': 'Attention seeker',
            'value': 'stand_out',
            'icon': Icons.star,
            'color': accentRed,
          },
          {
            'text': 'Dress to blend in',
            'subtitle': 'Harmony seeker',
            'value': 'blend_in',
            'icon': Icons.people,
            'color': accentPurple,
          },
          {
            'text': 'Wear what feels right',
            'subtitle': 'Authentic dresser',
            'value': 'feels_right',
            'icon': Icons.self_improvement,
            'color': primaryGreen,
          },
        ],
      },
      {
        'id': 6,
        'category': 'Fashion Criticism',
        'question': 'How do you handle fashion criticism?',
        'subtitle': 'Response to negative feedback',
        'icon': Icons.feedback,
        'options': [
          {
            'text': 'Ignore and move on',
            'subtitle': 'Thick skinned',
            'value': 'ignore',
            'icon': Icons.block,
            'color': primaryGreen,
          },
          {
            'text': 'Consider and adapt',
            'subtitle': 'Constructive learner',
            'value': 'adapt',
            'icon': Icons.lightbulb,
            'color': accentYellow,
          },
          {
            'text': 'Feel hurt but don\'t change',
            'subtitle': 'Sensitive but stubborn',
            'value': 'hurt_no_change',
            'icon': Icons.sentiment_dissatisfied,
            'color': accentPurple,
          },
          {
            'text': 'Immediately want to change',
            'subtitle': 'Highly sensitive',
            'value': 'immediate_change',
            'icon': Icons.autorenew,
            'color': accentRed,
          },
        ],
      },
    ];
  }

  Future<void> _saveQuizSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Update session count
      await prefs.setInt(
        'quiz_session_count_$_currentUserId',
        _quizSessionCount,
      );
      // Add current session to previous IDs
      _previousQuizIds.add(_quizSessionId);
      // Keep only last 10 sessions to avoid too much data
      if (_previousQuizIds.length > 10) {
        _previousQuizIds = _previousQuizIds.sublist(
          _previousQuizIds.length - 10,
        );
      }
      await prefs.setStringList(
        'previous_quiz_ids_$_currentUserId',
        _previousQuizIds,
      );
      print(
        'Quiz session saved: $_quizSessionId (Session #$_quizSessionCount)',
      );
    } catch (e) {
      print('Failed to save quiz session: $e');
    }
  }

  void _startQuiz() {
    _slideController.forward();
    _scaleController.forward();
    _progressController.forward();
  }

  Future<void> _submitAnswers() async {
    print('Submit answers dipanggil');
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      // GUNAKAN UNIFIED SCORING UNTUK SEMUA KOMPONEN
      final unifiedResult = _generateBudgetEnhancedResult();

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _budgetResult = unifiedResult['budget_type'] ?? 'Smart Saver';
        _budgetDescription =
            unifiedResult['description'] ??
            'Your fashion spending is unique! Here are some tips to save more and stay stylish.';
        _budgetTips = List<String>.from(
          unifiedResult['tips'] ?? _generateBudgetFallbackTips(),
        );
        _showResult = true;
        _isLoading = false;
      });

      _scaleController.reset();
      _scaleController.forward();
      HapticFeedback.lightImpact();

      // Save result for future personalization
      await _saveQuizResult(unifiedResult);
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar(
        'Analysis complete! Using smart analysis for your results.',
      );
    }
  }


  Map<String, double> _getUnifiedUserScores() {
    Map<String, double> userScores = {
      'Smart Saver': 0.0,
      'Overbudget Fashionista': 0.0,
      'Impulse Switcher': 0.0,
      'Deal Hunter': 0.0,
    };

    final answers = _answers.values.toList();
    print('DEBUG UNIFIED - Processing answers: $answers');

    // ENHANCED SCORING SYSTEM dengan bobot yang lebih akurat
    for (String answer in answers) {
      switch (answer) {
        // Smart Saver indicators - HIGH WEIGHT (10 points untuk strong indicators)
        case 'rare':
        case 'planned':
        case 'aware':
        case 'disciplined':
          userScores['Smart Saver'] = userScores['Smart Saver']! + 10.0;
          break;

        case 'quality':
        case 'wishlist':
        case 'thorough_compare':
        case 'days_weeks':
        case 'overnight':
        case 'shopping_ban':
        case 'early_planner':
        case 'basics':
        case 'independent':
        case 'ignore_trends':
        case 'stick_style':
        case 'donate':
        case 'never_regret':
        case 'end_season_deals':
        case 'year_round':
        case 'own_creativity':
        case 'dont_care':
        case 'ignore':
        case 'avoid_groups':
        case 'practical':
          userScores['Smart Saver'] = userScores['Smart Saver']! + 5.0;
          break;

        // Deal Hunter indicators - HIGH WEIGHT
        case 'deal_hunter':
        case 'thrift':
        case 'cashback':
        case 'sale_events':
          userScores['Deal Hunter'] = userScores['Deal Hunter']! + 10.0;
          break;

        case 'resell':
        case 'trust_store':
        case 'investment':
        case 'end_season':
        case 'satisfied':
        case 'ask_others':
        case 'quick_check':
        case 'morning':
          userScores['Deal Hunter'] = userScores['Deal Hunter']! + 5.0;
          break;

        // Overbudget Fashionista indicators - HIGH WEIGHT
        case 'overbudget':
        case 'often':
        case 'impulse':
        case 'no_idea':
        case 'rarely':
          userScores['Overbudget Fashionista'] =
              userScores['Overbudget Fashionista']! + 10.0;
          break;

        case 'frequent':
        case 'opportunistic':
        case 'quantity':
        case 'social_media':
        case 'early_adopter':
        case 'very_important':
        case 'buy_similar':
        case 'stand_out':
        case 'immediate_change':
        case 'continue_normal':
        case 'peak_season':
        case 'new_season':
        case 'trendy':
        case 'expression':
        case 'social':
        case 'emotional':
        case 'instant':
        case 'few_minutes':
        case 'mainstream':
        case 'often_regret':
        case 'expensive_regret':
        case 'evening':
        case 'trends':
          userScores['Overbudget Fashionista'] =
              userScores['Overbudget Fashionista']! + 5.0;
          break;

        // Impulse Switcher indicators - MEDIUM WEIGHT
        case 'switcher':
        case 'sometimes':
        case 'flexible':
        case 'depends_mood':
          userScores['Impulse Switcher'] =
              userScores['Impulse Switcher']! + 7.0;
          break;

        case 'monthly':
        case 'mix':
        case 'seasonal':
        case 'balanced':
        case 'selective':
        case 'compromise':
        case 'follow_along':
        case 'more_confident':
        case 'adapt':
        case 'hurt_no_change':
        case 'adjust_budget':
        case 'return_items':
        case 'keep_all':
        case 'share':
        case 'selective_adoption':
        case 'depends':
        case 'mixed':
        case 'occasional_regret':
        case 'fit_issues':
        case 'need_based':
        case 'accessories':
        case 'outerwear':
        case 'magazines':
        case 'friends_family':
        case 'with_friends':
        case 'with_family':
        case 'somewhat_important':
        case 'neutral':
        case 'feels_right':
        case 'afternoon':
        case 'weekend':
        case 'events':
        case 'blend_in':
        case 'self_conscious':
        case 'alone':
          userScores['Impulse Switcher'] =
              userScores['Impulse Switcher']! + 3.0;
          break;

        // Practical indicators - LOW WEIGHT
        case 'practical_needs':
          userScores['Smart Saver'] = userScores['Smart Saver']! + 2.0;
          break;

        // Default - MINIMAL WEIGHT
        default:
          userScores['Smart Saver'] = userScores['Smart Saver']! + 1.0;
          break;
      }
    }

    print('DEBUG UNIFIED - Raw scores: $userScores');
    return userScores;
  }

  // PERBAIKI ENHANCED RESULT DENGAN TIE-BREAKING YANG LEBIH KUAT
  Map<String, dynamic> _generateBudgetEnhancedResult() {
    final answers = _answers.values.toList();
    print('DEBUG ENHANCED - Processing answers: $answers');

    final budgetScores = _getUnifiedUserScores();
    print('DEBUG ENHANCED - Using unified scores: $budgetScores');

    // ENHANCED TIE-BREAKING SYSTEM dengan threshold yang lebih ketat
    double maxScore = budgetScores.values.reduce((a, b) => a > b ? a : b);

    // Jika skor tertinggi terlalu rendah, gunakan fallback
    if (maxScore < 5.0) {
      maxScore = 5.0;
      budgetScores['Smart Saver'] = 5.0; // Default fallback
    }

    List<String> topCategories =
        budgetScores.entries
            .where((entry) => entry.value >= maxScore - 2.0) // Toleransi 2 poin
            .map((entry) => entry.key)
            .toList();

    print('DEBUG ENHANCED - Max score: $maxScore');
    print('DEBUG ENHANCED - Top categories: $topCategories');

    String finalType = 'Smart Saver';

    if (topCategories.length == 1) {
      finalType = topCategories.first;
    } else if (topCategories.length > 1) {
      print('DEBUG ENHANCED - TIE DETECTED: $topCategories');

      // ADVANCED TIE-BREAKING dengan multiple criteria
      Map<String, double> tieBreakingScores = {};
      for (String category in topCategories) {
        tieBreakingScores[category] = 0.0;
      }

      // Tier 1: Ultra-strong discriminators
      for (String answer in answers) {
        switch (answer) {
          case 'rare':
          case 'planned':
          case 'aware':
          case 'disciplined':
            if (topCategories.contains('Smart Saver')) {
              tieBreakingScores['Smart Saver'] =
                  (tieBreakingScores['Smart Saver'] ?? 0) + 20.0;
            }
            break;

          case 'deal_hunter':
          case 'thrift':
          case 'cashback':
          case 'sale_events':
            if (topCategories.contains('Deal Hunter')) {
              tieBreakingScores['Deal Hunter'] =
                  (tieBreakingScores['Deal Hunter'] ?? 0) + 20.0;
            }
            break;

          case 'overbudget':
          case 'often':
          case 'impulse':
          case 'no_idea':
          case 'rarely':
            if (topCategories.contains('Overbudget Fashionista')) {
              tieBreakingScores['Overbudget Fashionista'] =
                  (tieBreakingScores['Overbudget Fashionista'] ?? 0) + 20.0;
            }
            break;

          case 'switcher':
          case 'flexible':
          case 'depends_mood':
          case 'sometimes':
            if (topCategories.contains('Impulse Switcher')) {
              tieBreakingScores['Impulse Switcher'] =
                  (tieBreakingScores['Impulse Switcher'] ?? 0) + 20.0;
            }
            break;
        }
      }

      // Tier 2: Strong discriminators
      for (String answer in answers) {
        switch (answer) {
          case 'quality':
          case 'wishlist':
          case 'thorough_compare':
          case 'shopping_ban':
          case 'ignore_trends':
            if (topCategories.contains('Smart Saver')) {
              tieBreakingScores['Smart Saver'] =
                  (tieBreakingScores['Smart Saver'] ?? 0) + 10.0;
            }
            break;

          case 'resell':
          case 'trust_store':
          case 'investment':
          case 'quick_check':
            if (topCategories.contains('Deal Hunter')) {
              tieBreakingScores['Deal Hunter'] =
                  (tieBreakingScores['Deal Hunter'] ?? 0) + 10.0;
            }
            break;

          case 'social_media':
          case 'early_adopter':
          case 'quantity':
          case 'trendy':
          case 'emotional':
            if (topCategories.contains('Overbudget Fashionista')) {
              tieBreakingScores['Overbudget Fashionista'] =
                  (tieBreakingScores['Overbudget Fashionista'] ?? 0) + 10.0;
            }
            break;

          case 'mix':
          case 'balanced':
          case 'selective':
          case 'compromise':
            if (topCategories.contains('Impulse Switcher')) {
              tieBreakingScores['Impulse Switcher'] =
                  (tieBreakingScores['Impulse Switcher'] ?? 0) + 10.0;
            }
            break;
        }
      }

      print('DEBUG ENHANCED - Tie-breaking scores: $tieBreakingScores');

      // Find winner after tie-breaking
      if (tieBreakingScores.isNotEmpty) {
        double maxTieBreakScore = tieBreakingScores.values.reduce(
          (a, b) => a > b ? a : b,
        );

        if (maxTieBreakScore > 0) {
          List<String> finalCandidates =
              tieBreakingScores.entries
                  .where((entry) => entry.value == maxTieBreakScore)
                  .map((entry) => entry.key)
                  .toList();

          if (finalCandidates.length == 1) {
            finalType = finalCandidates.first;
          } else {
            // Final fallback dengan priority berdasarkan skor asli
            String highestOriginalScore = '';
            double highestScore = 0.0;

            for (String candidate in finalCandidates) {
              if (budgetScores[candidate]! > highestScore) {
                highestScore = budgetScores[candidate]!;
                highestOriginalScore = candidate;
              }
            }

            finalType =
                highestOriginalScore.isNotEmpty
                    ? highestOriginalScore
                    : finalCandidates.first;
          }
        }
      }
    }

    print('DEBUG ENHANCED - Final winner: $finalType');

    // Update scores untuk konsistensi chart
    final profileKey = _getProfileKey(finalType);
    final profiles = _getBudgetProfiles();
    final profile = profiles[profileKey] ?? profiles['smart_saver']!;

    return {
      'budget_type': finalType,
      'description': profile['description'],
      'tips': profile['tips'],
      'profile': profile,
      'debug_scores': budgetScores,
      'final_type': finalType,
      'tie_detected': topCategories.length > 1,
      'tie_categories': topCategories,
      'max_score': maxScore,
    };
  }

  // Helper function untuk mapping profile
  String _getProfileKey(String displayName) {
    switch (displayName) {
      case 'Smart Saver':
        return 'smart_saver';
      case 'Deal Hunter':
        return 'deal_hunter';
      case 'Overbudget Fashionista':
        return 'overbudget_fashionista';
      case 'Impulse Switcher':
        return 'impulse_switcher';
      default:
        return 'smart_saver';
    }
  }

  // ...existi

  // Update chart untuk menggunakan max score yang lebih tinggi
  Widget _buildRealBudgetPieChart(Size screenSize) {
    final isSmallScreen = screenSize.width < 360;

    // Gunakan fungsi unified scoring
    final userScores = _getUnifiedUserScores();

    print('DEBUG PIE CHART - Unified scores: $userScores');

    // Jika semua skor 0, berikan minimal data
    if (userScores.values.every((score) => score == 0)) {
      userScores['Smart Saver'] = 1.0;
    }

    // Create pie chart sections
    List<PieChartSectionData> sections = [];
    final colors = [primaryGreen, accentRed, accentPurple, accentYellow];
    final keys = [
      'Smart Saver',
      'Overbudget Fashionista',
      'Impulse Switcher',
      'Deal Hunter',
    ];

    for (int i = 0; i < keys.length; i++) {
      final key = keys[i];
      final value = userScores[key] ?? 0.0;
      if (value > 0) {
        sections.add(
          PieChartSectionData(
            value: value,
            color: colors[i],
            title: value.toInt().toString(),
            titleStyle: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 10 : 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            radius: isSmallScreen ? 40 : 50,
            showTitle: true,
          ),
        );
      }
    }

    return Container(
          height: isSmallScreen ? 220 : 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 18),
        border: Border.all(color: primaryGreen.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Row(
              children: [
                Icon(
                  Icons.pie_chart_outline_rounded,
                  color: primaryGreen,
                  size: isSmallScreen ? 18 : 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Your Budget Profile Distribution',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w700,
                    color: darkGray,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
             padding: EdgeInsets.all(isSmallScreen ? 12 : 16), // <- TAMBAH PADDING DARI 8/12 JADI 12/16
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: isSmallScreen ? 35 : 40,
                  startDegreeOffset: -90,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserScoreBarChart(Size screenSize) {
    final isSmallScreen = screenSize.width < 360;

    // Gunakan fungsi unified scoring yang sama
    final userScores = _getUnifiedUserScores();

    print('DEBUG BAR CHART - Unified scores: $userScores');

    // Jika semua skor 0, berikan minimal data
    if (userScores.values.every((score) => score == 0)) {
      userScores['Smart Saver'] = 1.0;
    }

    // Create bar chart data
    List<BarChartGroupData> barGroups = [];
    final colors = [primaryGreen, accentRed, accentPurple, accentYellow];
    final chartLabels = [
      'Smart\nSaver',
      'Overbudget\nFashionista',
      'Impulse\nSwitcher',
      'Deal\nHunter',
    ];
    final keys = [
      'Smart Saver',
      'Overbudget Fashionista',
      'Impulse Switcher',
      'Deal Hunter',
    ];

    for (int i = 0; i < keys.length; i++) {
      final key = keys[i];
      final value = userScores[key] ?? 0.0;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: colors[i],
              width: isSmallScreen ? 24 : 28,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return Container(
      height: isSmallScreen ? 140 : 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 18),
        border: Border.all(color: primaryGreen.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Row(
              children: [
                Icon(
                  Icons.bar_chart_rounded,
                  color: primaryGreen,
                  size: isSmallScreen ? 18 : 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Your Score Breakdown',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w700,
                    color: darkGray,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  maxY: 30, // Adjust untuk skor yang lebih tinggi
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 10 : 12,
                              color: mediumGray,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < chartLabels.length) {
                            return Text(
                              chartLabels[value.toInt()],
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 8 : 10,
                                color: mediumGray,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: lightGray, strokeWidth: 1);
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.black87,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${chartLabels[group.x]}\n${rod.toY.toInt()} points',
                          GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, Map<String, dynamic>> _getBudgetProfiles() {
    return {
      'smart_saver': {
        'title': 'Smart Saver',
        'description':
            'You are very wise in managing your fashion budget, $_currentUser! Always planning every purchase and not easily tempted by promos. Your style stays stylish with a controlled budget.',
        'tips': [
          'Maintain the good habit of creating a wishlist before shopping',
          'Take advantage of end-of-season sales for quality items',
          'Invest in basic items that can be mixed and matched',
          'Set a monthly fashion budget and stick to it religiously',
          'Research prices across multiple platforms before buying',
          'Focus on cost-per-wear when evaluating purchases',
        ],
      },
      'overbudget_fashionista': {
        'title': 'Overbudget Fashionista',
        'description':
            'You have high fashion taste but sometimes forget budget limits, $_currentUser. Love following the latest trends and impulse shopping. Time to be more aware of your spending!',
        'tips': [
          'Create a monthly fashion budget and stick to it',
          'Delay purchases by 24 hours to avoid impulse buying',
          'Prioritize quality over quantity in your purchases',
          'Use the "cost per wear" formula before buying',
          'Unsubscribe from promotional emails that trigger spending',
          'Shop with a specific list and avoid browsing aimlessly',
        ],
      },
      'impulse_switcher': {
        'title': 'Impulse Switcher',
        'description':
            'Mood greatly influences your shopping decisions, $_currentUser. Sometimes very thrifty, sometimes totally splurging. Inconsistent but still controllable with the right strategy.',
        'tips': [
          'Create a "cooling off period" system of 3 days before checkout',
          'Use budget tracking apps for monitoring expenses',
          'Set monthly reminders to review fashion spending',
          'Create separate savings for planned fashion purchases',
          'Practice mindful shopping by asking "do I really need this?"',
          'Find alternative activities when you feel like impulse shopping',
        ],
      },
      'deal_hunter': {
        'title': 'Deal Hunter',
        'description':
            'You are a master at finding the best discounts and promos, $_currentUser! Always researching prices and looking for cashback. But be careful not to buy unnecessary items just because they are cheap.',
        'tips': [
          'Still create a wishlist even when there are big discounts',
          'Compare prices on at least 3 platforms before buying',
          'Focus on value for money, not just cheap prices',
          'Set alerts for specific items you actually need',
          'Calculate the true cost including shipping and returns',
          'Avoid buying items just because they are on sale',
        ],
      },
    };
  }

  List<String> _generateBudgetFallbackTips() {
    return [
      'Use a wishlist before shopping for fashion items',
      'Set a specific monthly budget for fashion purchases',
      'Take advantage of cashback and promotional offers',
      'Research prices across multiple platforms before buying',
      'Focus on versatile pieces that can be styled multiple ways',
      'Practice the 24-hour rule for non-essential purchases',
    ];
  }


// Fungsi untuk menganalisis konten tips yang sebenarnya
List<Map<String, dynamic>> _analyzeTipsContent() {
  Map<String, int> categoryCount = {
    'Planning': 0,
    'Research': 0,
    'Budgeting': 0,
    'Smart Shopping': 0,
  };

  // Keywords untuk setiap kategori
  Map<String, List<String>> categoryKeywords = {
    'Planning': [
      'wishlist', 'plan', 'budget', 'schedule', 'organize', 'prepare',
      'list', 'ahead', 'strategy', 'systematic', 'routine', 'calendar'
    ],
    'Research': [
      'research', 'compare', 'price', 'platform', 'check', 'review',
      'analyze', 'investigate', 'study', 'search', 'evaluate', 'examine'
    ],
    'Budgeting': [
      'budget', 'money', 'cost', 'spending', 'expense', 'financial',
      'save', 'limit', 'track', 'monitor', 'control', 'manage'
    ],
    'Smart Shopping': [
      'discount', 'sale', 'deal', 'promo', 'cashback', 'offer',
      'coupon', 'bargain', 'thrift', 'secondhand', 'value', 'opportunity'
    ],
  };

  // Analisis setiap tip
  for (String tip in _budgetTips) {
    String tipLower = tip.toLowerCase();
    
    // Cek setiap kategori dan hitung berdasarkan keywords
    for (String category in categoryKeywords.keys) {
      List<String> keywords = categoryKeywords[category]!;
      int matchCount = 0;
      
      for (String keyword in keywords) {
        if (tipLower.contains(keyword)) {
          matchCount++;
        }
      }
      
      // Jika ada match, tambahkan ke kategori tersebut
      if (matchCount > 0) {
        categoryCount[category] = categoryCount[category]! + matchCount;
      }
    }
  }

  // Pastikan minimal ada 1 untuk setiap kategori jika tidak ada tips
  if (_budgetTips.isEmpty) {
    categoryCount = {
      'Planning': 1,
      'Research': 1,
      'Budgeting': 1,
      'Smart Shopping': 1,
    };
  }

  // Convert ke format yang dibutuhkan chart
  List<Map<String, dynamic>> result = [
    {
      'category': 'Planning',
      'count': categoryCount['Planning']!,
      'color': primaryGreen,
      'tips': _getRelevantTips('Planning'),
    },
    {
      'category': 'Research',
      'count': categoryCount['Research']!,
      'color': accentYellow,
      'tips': _getRelevantTips('Research'),
    },
    {
      'category': 'Budgeting',
      'count': categoryCount['Budgeting']!,
      'color': accentPurple,
      'tips': _getRelevantTips('Budgeting'),
    },
    {
      'category': 'Smart Shopping',
      'count': categoryCount['Smart Shopping']!,
      'color': accentRed,
      'tips': _getRelevantTips('Smart Shopping'),
    },
  ];

  return result;
}

// Fungsi helper untuk mendapatkan tips yang relevan untuk setiap kategori
List<String> _getRelevantTips(String category) {
  Map<String, List<String>> categoryKeywords = {
    'Planning': [
      'wishlist', 'plan', 'budget', 'schedule', 'organize', 'prepare',
      'list', 'ahead', 'strategy', 'systematic', 'routine', 'calendar'
    ],
    'Research': [
      'research', 'compare', 'price', 'platform', 'check', 'review',
      'analyze', 'investigate', 'study', 'search', 'evaluate', 'examine'
    ],
    'Budgeting': [
      'budget', 'money', 'cost', 'spending', 'expense', 'financial',
      'save', 'limit', 'track', 'monitor', 'control', 'manage'
    ],
    'Smart Shopping': [
      'discount', 'sale', 'deal', 'promo', 'cashback', 'offer',
      'coupon', 'bargain', 'thrift', 'secondhand', 'value', 'opportunity'
    ],
  };

  List<String> relevantTips = [];
  List<String> keywords = categoryKeywords[category] ?? [];

  for (String tip in _budgetTips) {
    String tipLower = tip.toLowerCase();
    
    for (String keyword in keywords) {
      if (tipLower.contains(keyword)) {
        relevantTips.add(tip);
        break; // Avoid duplicate tips
      }
    }
  }

  return relevantTips;
}

// Opsional: Tambahkan tooltip untuk chart yang menampilkan tips detail
Widget _buildBudgetTipsChartWithTooltip(Size screenSize) {
  final isSmallScreen = screenSize.width < 360;
  final tipAnalysis = _analyzeTipsContent();

  return Container(
    height: isSmallScreen ? 180 : 200,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 18),
      border: Border.all(color: primaryGreen.withOpacity(0.2)),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Row(
            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                color: primaryGreen,
                size: isSmallScreen ? 18 : 20,
              ),
              SizedBox(width: 8),
              Text(
                'Your Tips Breakdown (${_budgetTips.length} tips)',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w700,
                  color: darkGray,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20), // <- TAMBAH PADDING DARI 8/12 JADI 16/20
            child: Row(
              children: tipAnalysis.map((category) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Show tooltip dengan tips detail
                      _showTipsCategoryDialog(category);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Animated bar
                          AnimatedContainer(
                            duration: Duration(milliseconds: 800),
                            height: (category['count'] as int) * 
                                   (isSmallScreen ? 12.0 : 15.0), 
                            decoration: BoxDecoration(
                              color: category['color'] as Color,
                              borderRadius: BorderRadius.circular(4),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  category['color'] as Color,
                                  (category['color'] as Color).withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: Text(
                                '${category['count']}',
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 10 : 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          // Category label
                          Text(
                            category['category'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 8 : 10,
                              fontWeight: FontWeight.w600,
                              color: mediumGray,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    ),
  );
}

// Dialog untuk menampilkan tips detail per kategori
void _showTipsCategoryDialog(Map<String, dynamic> category) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: category['color'] as Color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8),
            Text(
              category['category'] as String,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: darkGray,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tips in this category:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: mediumGray,
              ),
            ),
            SizedBox(height: 8),
            ...((category['tips'] as List<String>).isEmpty 
                ? ['No specific tips for this category']
                : category['tips'] as List<String>)
                .map((tip) => Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $tip',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: darkGray,
                    ),
                  ),
                ))
                .toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: primaryGreen,
              ),
            ),
          ),
        ],
      );
    },
  );
}

  Future<void> _saveQuizResult(Map<String, dynamic> result) async {
    print('SaveQuizResult dipanggil');
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().toIso8601String();

    // Konversi _answers ke Map<String, String>
    final answersStringKey = _answers.map(
      (key, value) => MapEntry(key.toString(), value),
    );

    // Simpan ke local (debug error)
    try {
      await prefs.setString(
        'last_style_result',
        jsonEncode({
          'result': result,
          'answers': answersStringKey,
          'user': _currentUser,
          'userId': _currentUserId,
          'timestamp': timestamp,
          'session_id': _quizSessionId,
        }),
      );
      print('Berhasil simpan ke local');
    } catch (e) {
      print('Gagal simpan ke local: $e');
    }

    // Simpan ke Firestore untuk admin analytics
    try {
      print('Menyimpan hasil quiz ke Firestore...');
      await FirebaseFirestore.instance.collection('budget_quiz_results').add({
        'userId': _currentUserId,
        'username': _currentUser,
        'budget_type': result['budget_type'],
        'description': result['description'],
        'tips': result['tips'],
        'answers': answersStringKey,
        'timestamp': FieldValue.serverTimestamp(),
        'session_id': _quizSessionId,
      });
      print('Berhasil simpan hasil quiz ke Firestore!');
    } catch (e) {
      print('Failed to save quiz result to Firestore: $e');
    }
  }

  void _nextQuestion() {
    HapticFeedback.selectionClick();
    if (_currentQuestion < _budgetQuestions.length - 1) {
      setState(() => _currentQuestion++);
      _slideController.reset();
      _slideController.forward();
      _scaleController.reset();
      _scaleController.forward();
    } else {
      _submitAnswers();
    }
  }

  void _previousQuestion() {
    HapticFeedback.selectionClick();
    if (_currentQuestion > 0) {
      setState(() => _currentQuestion--);
      _slideController.reset();
      _slideController.forward();
      _scaleController.reset();
      _scaleController.forward();
    }
  }

  void _selectAnswer(String value) {
    HapticFeedback.lightImpact();
    setState(() {
      _answers[_budgetQuestions[_currentQuestion]['id']] = value;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.smart_toy_outlined, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'AI Analysis Complete!',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(message, style: GoogleFonts.poppins(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _progressController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: accentBeige,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [accentBeige, primaryGreen.withOpacity(0.08), accentBeige],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildMobileAppBar(screenSize),
              Expanded(
                child:
                    _isGeneratingQuestions
                        ? _buildAILoadingScreen(screenSize)
                        : _showResult
                        ? _buildMobileBudgetResultView(screenSize)
                        : _buildMobileBudgetQuizView(screenSize),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAILoadingScreen(Size screenSize) {
    final isSmallScreen = screenSize.width < 360;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AI Brain Animation
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * math.pi,
                  child: Container(
                    padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryGreen.withOpacity(0.2),
                          accentPurple.withOpacity(0.2),
                          accentYellow.withOpacity(0.2),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryGreen.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.psychology_outlined,
                      color: primaryGreen,
                      size: isSmallScreen ? 48 : 64,
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: screenSize.height * 0.04),

            // Shimmer Text Effect
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: [primaryGreen, accentYellow, primaryGreen],
                      stops: [
                        _shimmerAnimation.value - 0.3,
                        _shimmerAnimation.value,
                        _shimmerAnimation.value + 0.3,
                      ],
                    ).createShader(bounds);
                  },
                  child: Text(
                    'AI is Crafting Your Quiz...',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),

            SizedBox(height: screenSize.height * 0.02),

            Text(
              'Creating personalized questions just for $_currentUser',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 14 : 16,
                color: mediumGray,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: screenSize.height * 0.04),

            // Animated Progress Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    final delay = index * 0.3;
                    final animValue = (_rotationAnimation.value + delay) % 1.0;
                    final scale =
                        0.8 + (math.sin(animValue * 2 * math.pi) * 0.3);

                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isSmallScreen ? 8 : 10,
                        height: isSmallScreen ? 8 : 10,
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileAppBar(Size screenSize) {
    final isSmallScreen = screenSize.width < 360;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.05,
        vertical: screenSize.height * 0.015,
      ),
      child: Row(
        children: [
          // Back Button
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: isSmallScreen ? 40 : 44,
              height: isSmallScreen ? 40 : 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 18),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 18),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: darkGray,
                    size: isSmallScreen ? 18 : 20,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: screenSize.width * 0.04),

          // Title
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback:
                        (bounds) => LinearGradient(
                          colors: [primaryGreen, accentPurple],
                        ).createShader(bounds),
                    child: Row(
                      children: [
                        Text(
                          'AI Budget Quiz',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 18 : 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (!_isGeneratingQuestions && !isSmallScreen) ...[
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [accentYellow, accentRed],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'SMART',
                              style: GoogleFonts.poppins(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!_showResult &&
                      !isSmallScreen &&
                      !_isGeneratingQuestions) ...[
                    Text(
                      'Personalized for $_currentUser',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: mediumGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // AI Indicator
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 2 * math.pi,
                child: Container(
                  width: isSmallScreen ? 36 : 40,
                  height: isSmallScreen ? 36 : 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          _isGeneratingQuestions
                              ? [accentYellow, accentRed]
                              : [primaryGreen, accentPurple],
                    ),
                    borderRadius: BorderRadius.circular(
                      isSmallScreen ? 14 : 16,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryGreen.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isGeneratingQuestions
                        ? Icons.psychology_outlined
                        : Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: isSmallScreen ? 18 : 20,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBudgetQuizView(Size screenSize) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildMobileProgressBar(screenSize),
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: screenSize.height * 0.02),
                  child: _buildMobileBudgetQuestionCard(screenSize),
                ),
              ),
            ),
          ),
          _buildMobileNavigationButtons(screenSize),
        ],
      ),
    );
  }

  Widget _buildMobileProgressBar(Size screenSize) {
    double progress = (_currentQuestion + 1) / _budgetQuestions.length;
    final question = _budgetQuestions[_currentQuestion];
    final isSmallScreen = screenSize.width < 360;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.05,
        vertical: screenSize.height * 0.01,
      ),
      child: Column(
        children: [
          // Progress Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 10 : 12,
                    vertical: isSmallScreen ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      isSmallScreen ? 14 : 16,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        question['icon'],
                        color: primaryGreen,
                        size: isSmallScreen ? 14 : 16,
                      ),
                      SizedBox(width: isSmallScreen ? 4 : 6),
                      Flexible(
                        child: Text(
                          question['category'],
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 11 : 12,
                            fontWeight: FontWeight.w600,
                            color: darkGray,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 10 : 12,
                  vertical: isSmallScreen ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryGreen, accentPurple],
                  ),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryGreen.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${_currentQuestion + 1}/${_budgetQuestions.length}',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 11 : 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: screenSize.height * 0.015),

          // Progress Bar
          Container(
            height: isSmallScreen ? 6 : 8,
            decoration: BoxDecoration(
              color: lightGray,
              borderRadius: BorderRadius.circular(isSmallScreen ? 3 : 4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isSmallScreen ? 3 : 4),
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: progress * _progressAnimation.value,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                  );
                },
              ),
            ),
          ),

          SizedBox(height: screenSize.height * 0.005),

          Text(
            '${(progress * 100).round()}% Complete',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBudgetQuestionCard(Size screenSize) {
    final question = _budgetQuestions[_currentQuestion];
    final isSmallScreen = screenSize.width < 360;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.04,
        vertical: screenSize.height * 0.01,
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        ),
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: isSmallScreen ? 15 : 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryGreen.withOpacity(0.1),
                            accentYellow.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          isSmallScreen ? 14 : 16,
                        ),
                        border: Border.all(
                          color: primaryGreen.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        question['icon'],
                        size: isSmallScreen ? 20 : 24,
                        color: primaryGreen,
                      ),
                    ),

                    SizedBox(width: screenSize.width * 0.04),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Question ${_currentQuestion + 1}',
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 11 : 12,
                                  fontWeight: FontWeight.w600,
                                  color: primaryGreen,
                                ),
                              ),
                              SizedBox(width: 6),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: accentYellow.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'AI',
                                  style: GoogleFonts.poppins(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: accentYellow,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            question['category'],
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 10 : 11,
                              fontWeight: FontWeight.w500,
                              color: mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenSize.height * 0.02),

                // Question Text
                Text(
                  question['question'],
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.w700,
                    color: darkGray,
                    height: 1.3,
                  ),
                ),

                SizedBox(height: screenSize.height * 0.008),

                Text(
                  question['subtitle'],
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 13 : 14,
                    color: mediumGray,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: screenSize.height * 0.025),

                // Options
                ...question['options']
                    .map<Widget>(
                      (option) => _buildMobileOptionCard(option, screenSize),
                    )
                    .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileOptionCard(Map<String, dynamic> option, Size screenSize) {
    bool isSelected =
        _answers[_budgetQuestions[_currentQuestion]['id']] == option['value'];
    final isSmallScreen = screenSize.width < 360;

    return Container(
      margin: EdgeInsets.only(bottom: screenSize.height * 0.012),
      child: Material(
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectAnswer(option['value']),
          borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.all(screenSize.width * 0.04),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? option['color'].withOpacity(0.1)
                      : lightGray.withOpacity(0.5),
              borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
              border: Border.all(
                color: isSelected ? option['color'] : Colors.transparent,
                width: 1.5,
              ),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: option['color'].withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                      : [],
            ),
            child: Row(
              children: [
                // Radio Button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: isSmallScreen ? 20 : 22,
                  height: isSmallScreen ? 20 : 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? option['color'] : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? option['color'] : mediumGray,
                      width: 1.5,
                    ),
                  ),
                  child:
                      isSelected
                          ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: isSmallScreen ? 12 : 14,
                          )
                          : null,
                ),

                SizedBox(width: screenSize.width * 0.03),

                // Option Icon
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? option['color'].withOpacity(0.2)
                            : mediumGray.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                  ),
                  child: Icon(
                    option['icon'],
                    color: isSelected ? option['color'] : mediumGray,
                    size: isSmallScreen ? 16 : 18,
                  ),
                ),

                SizedBox(width: screenSize.width * 0.03),

                // Option Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option['text'],
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? option['color'] : darkGray,
                        ),
                      ),
                      Text(
                        option['subtitle'],
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 11 : 12,
                          color:
                              isSelected
                                  ? option['color'].withOpacity(0.8)
                                  : mediumGray,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileNavigationButtons(Size screenSize) {
    bool hasAnswer = _answers.containsKey(
      _budgetQuestions[_currentQuestion]['id'],
    );
    final isSmallScreen = screenSize.width < 360;

    return Container(
      padding: EdgeInsets.all(screenSize.width * 0.05),
      child: Row(
        children: [
          // Previous Button
          if (_currentQuestion > 0) ...[
            Expanded(
              child: Container(
                height: isSmallScreen ? 44 : 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 20),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: OutlinedButton.icon(
                  onPressed: _previousQuestion,
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    size: isSmallScreen ? 14 : 16,
                  ),
                  label: Text(
                    'Back',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 13 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryGreen,
                    side: BorderSide(color: primaryGreen, width: 1.5),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        isSmallScreen ? 18 : 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: screenSize.width * 0.03),
          ],

          // Next/Submit Button
          Expanded(
            flex: _currentQuestion == 0 ? 1 : 1,
            child: Container(
              height: isSmallScreen ? 44 : 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 20),
                gradient:
                    hasAnswer
                        ? LinearGradient(colors: [primaryGreen, accentPurple])
                        : null,
                color: hasAnswer ? null : mediumGray.withOpacity(0.3),
                boxShadow:
                    hasAnswer
                        ? [
                          BoxShadow(
                            color: primaryGreen.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : [],
              ),
              child: ElevatedButton.icon(
                onPressed: hasAnswer ? _nextQuestion : null,
                icon:
                    _isLoading
                        ? SizedBox(
                          width: isSmallScreen ? 16 : 18,
                          height: isSmallScreen ? 16 : 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 1.5,
                          ),
                        )
                        : Icon(
                          _currentQuestion == _budgetQuestions.length - 1
                              ? Icons.auto_awesome_rounded
                              : Icons.arrow_forward_ios_rounded,
                          size: isSmallScreen ? 14 : 16,
                        ),
                label: Text(
                  _isLoading
                      ? 'Analyzing...'
                      : _currentQuestion == _budgetQuestions.length - 1
                      ? 'Show Budget Type'
                      : 'Next',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      isSmallScreen ? 18 : 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBudgetResultView(Size screenSize) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(screenSize.width * 0.04),
        child: Column(
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: _buildMobileBudgetResultCard(screenSize),
            ),
            SizedBox(height: screenSize.height * 0.025),
            _buildBudgetChartsPlaceholder(screenSize),
            SizedBox(height: screenSize.height * 0.025),
            _buildMobileBudgetTips(screenSize),
            SizedBox(height: screenSize.height * 0.025),
            _buildMobileActionButtons(screenSize),
          ],
        ),
      ),
    );
  }

  // TAMBAHKAN DEBUG INFO DI RESULT CARD
  Widget _buildMobileBudgetResultCard(Size screenSize) {
    final isSmallScreen = screenSize.width < 360;
    final debugScores = _getUnifiedUserScores();

    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _breathingAnimation.value,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isSmallScreen ? 24 : 28),
              boxShadow: [
                BoxShadow(
                  color: primaryGreen.withOpacity(0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 24 : 28),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryGreen, accentPurple],
                  ),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 24 : 28),
                ),
                padding: EdgeInsets.all(screenSize.width * 0.08),
                child: Column(
                  children: [
                    // AI Badge dengan Score Info
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.psychology_outlined,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'AI Analyzed • Score: ${debugScores[_budgetResult ?? 'Smart Saver']?.toInt() ?? 0}',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenSize.height * 0.02),

                    // Result Icon
                    AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Container(
                          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Transform.rotate(
                            angle: _rotationAnimation.value * 0.3 * math.pi,
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              size: isSmallScreen ? 36 : 42,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: screenSize.height * 0.02),

                    Text(
                      '🎉 Your AI Budget Profile',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),

                    SizedBox(height: screenSize.height * 0.01),

                    // Style Title - GUNAKAN UNIFIED RESULT
                    Text(
                      _budgetResult ?? 'Smart Saver',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 22 : 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: screenSize.height * 0.015),

                    // Description
                    Container(
                      padding: EdgeInsets.all(screenSize.width * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(
                          isSmallScreen ? 14 : 16,
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _budgetDescription ??
                            'Your budget habits are unique, $_currentUser. You know how to manage your fashion spending smartly and efficiently.',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 12 : 13,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

Widget _buildBudgetChartsPlaceholder(Size screenSize) {
  return Column(
    children: [
      // Real Budget Distribution Chart
      _buildRealBudgetPieChart(screenSize),
      SizedBox(height: screenSize.height * 0.02),

      // User's Score Breakdown Chart
      _buildUserScoreBarChart(screenSize),
    ],
  );
}


  // Update _buildMobileBudgetTips untuk menggunakan chart
Widget _buildMobileBudgetTips(Size screenSize) {
  final isSmallScreen = screenSize.width < 360;

  return Column(
    children: [
      // Tips Chart (pilih salah satu)
      _buildBudgetTipsChartWithTooltip(screenSize), // <- GANTI DARI _buildBudgetTipsChart ke _buildBudgetTipsChartWithTooltip

      SizedBox(height: screenSize.height * 0.02),

      // Original Tips Card
      Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 20),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 20),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: EdgeInsets.all(screenSize.width * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentYellow.withOpacity(0.2),
                          accentYellow.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        isSmallScreen ? 10 : 12,
                      ),
                    ),
                    child: Icon(
                      Icons.lightbulb_outline_rounded,
                      color: accentYellow,
                      size: isSmallScreen ? 20 : 24,
                    ),
                  ),
                  SizedBox(width: screenSize.width * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Budget Tips',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w700,
                            color: darkGray,
                          ),
                        ),
                        Text(
                          'Personalized for $_currentUser',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: mediumGray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenSize.height * 0.02),

              // Tips
              ..._budgetTips.asMap().entries.map((entry) {
                int index = entry.key;
                String tip = entry.value;
                return _buildMobileTipItem(tip, index, screenSize);
              }).toList(),
            ],
          ),
        ),
      ),
    ],
  );
}
  Widget _buildMobileTipItem(String tip, int index, Size screenSize) {
    final isSmallScreen = screenSize.width < 360;

    return Container(
      margin: EdgeInsets.only(bottom: screenSize.height * 0.015),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number Badge
          Container(
            width: isSmallScreen ? 24 : 28,
            height: isSmallScreen ? 24 : 28,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primaryGreen, accentPurple]),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 11 : 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SizedBox(width: screenSize.width * 0.03),

          // Tip Content
          Expanded(
            child: Container(
              padding: EdgeInsets.all(screenSize.width * 0.04),
              decoration: BoxDecoration(
                color: lightBlue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
                border: Border.all(
                  color: primaryGreen.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Text(
                tip,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 12 : 13,
                  color: darkGray,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ...existing code...
  Widget _buildMobileActionButtons(Size screenSize) {
    final isSmallScreen = screenSize.width < 360;

    return Column(
      children: [
        // Primary Action (Create AI Outfits) - Dihapus
        // SizedBox(height: screenSize.height * 0.015),

        // Secondary Actions Row (Share & Retake) - Share Dihapus
        Row(
          children: [
            // Share button dihapus
            // Expanded(
            //   child: Container(
            //     height: isSmallScreen ? 44 : 48,
            //     child: OutlinedButton.icon(
            //       onPressed: () => _shareResult(),
            //       icon: Icon(
            //         Icons.share_outlined,
            //         size: isSmallScreen ? 16 : 18,
            //       ),
            //       label: Text(
            //         'Share',
            //         style: GoogleFonts.poppins(
            //           fontSize: isSmallScreen ? 12 : 14,
            //           fontWeight: FontWeight.w600,
            //         ),
            //       ),
            //       style: OutlinedButton.styleFrom(
            //         foregroundColor: primaryGreen,
            //         side: BorderSide(color: primaryGreen, width: 1.5),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(
            //             isSmallScreen ? 18 : 20,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            Expanded(
              child: Container(
                height: isSmallScreen ? 44 : 48,
                child: TextButton.icon(
                  onPressed: () => _retakeQuiz(),
                  icon: Icon(
                    Icons.refresh_rounded,
                    size: isSmallScreen ? 16 : 18,
                  ),
                  label: Text(
                    'Retake',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: mediumGray,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        isSmallScreen ? 18 : 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  // ...existing code...

  void _retakeQuiz() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentQuestion = 0;
      _answers.clear();
      _showResult = false;
      _budgetResult = null;
      _budgetDescription = null;
      _budgetTips.clear();
      _isGeneratingQuestions = true;
    });

    // Generate new session for retake
    _generateUniqueSession();
    _generateBudgetBehaviorQuestions();

    _slideController.reset();
    _scaleController.reset();
  }
}

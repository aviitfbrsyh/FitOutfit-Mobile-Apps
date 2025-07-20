import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpNSupportPage extends StatefulWidget {
  const HelpNSupportPage({Key? key}) : super(key: key);

  @override
  State<HelpNSupportPage> createState() => _HelpNSupportPageState();
}

class _HelpNSupportPageState extends State<HelpNSupportPage> {
  final List<Map<String, String>> faqList = [
    {
      'question': 'What is FitOutfit?',
      'answer':
          'FitOutfit is a personal fashion assistant app that helps you choose, organize, and plan your daily outfits, as well as manage your digital wardrobe collection.',
    },
    {
      'question': 'How do I use the Virtual Try-On feature?',
      'answer':
          'The Virtual Try-On feature lets you try on clothes virtually. Simply select the "Virtual Try-On" menu on the homepage and follow the instructions to see how outfits look on you.',
    },
    {
      'question': 'What is the function of My Wardrobe?',
      'answer':
          'My Wardrobe is a feature to manage your digital clothing collection. You can add, edit, and delete clothing items, as well as view your wardrobe statistics.',
    },
    {
      'question': 'How do I use the Outfit Planner?',
      'answer':
          'The Outfit Planner helps you plan outfits for different events or specific days. Select the "Outfit Planner" menu, then add an event and choose the appropriate outfit.',
    },
    {
      'question': 'What is the Budget Personality Quiz?',
      'answer':
          'The Budget Personality Quiz helps you discover your shopping personality. The results will help the app recommend outfits that match your style and budget.',
    },
    {
      'question': 'How do I view and add Favorites?',
      'answer':
          'You can mark outfits, articles, or wardrobe items as favorites by tapping the heart icon. All your favorites can be viewed in the "My Favorites" section on the homepage.',
    },
    {
      'question': 'What are the benefits of the AI Outfit Picks feature?',
      'answer':
          'The AI Outfit Picks feature gives you daily outfit recommendations curated just for you based on your preferences, weather, and events. Tap "Generate Outfit" to get new inspiration every day.',
    },
    {
      'question': 'How do I read Fashion News?',
      'answer':
          'You can read the latest fashion news and articles in the "Fashion News" section on the homepage. Click "Read More" to see the full article.',
    },
    {
      'question': 'What is the Community feature?',
      'answer':
          'The Community feature allows you to share your style, get inspiration from other users, and join the fashion community. Tap "Share Your Look" or "Browse Styles" in the Community section.',
    },
    {
      'question': 'How do I contact FitOutfit support?',
      'answer':
          'If you experience any issues, use the "Send Feedback" menu on the profile page or contact us via the support email listed in the app.',
    },
    {
      'question': 'How do I edit my profile and delete my account?',
      'answer':
          'Go to the Settings menu on your profile page, then select "Edit Profile" to update your information or "Delete Account" to permanently remove your account.',
    },
    {
      'question': 'How do I create a new collection?',
      'answer':
          'Use the "Create New Collection" button at the bottom of the homepage to make your own favorite outfit collections.',
    },
    // Tambahkan FAQ lain sesuai kebutuhan
  ];
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredFaqs =
        faqList
            .where(
              (faq) =>
                  faq['question']!.toLowerCase().contains(
                    _search.toLowerCase(),
                  ) ||
                  faq['answer']!.toLowerCase().contains(_search.toLowerCase()),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FAQ',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.primaryColor),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari pertanyaan...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  ...filteredFaqs.map(
                    (faq) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        title: Text(
                          faq['question']!,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              faq['answer']!,
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

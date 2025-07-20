import 'package:flutter/material.dart';
import '../home/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VirtualTryOnPage extends StatefulWidget {
  const VirtualTryOnPage({super.key});

  @override
  State<VirtualTryOnPage> createState() => _VirtualTryOnPageState();
}

class _VirtualTryOnPageState extends State<VirtualTryOnPage> {
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color softCream = Color(0xFFFAF9F7);

  final List<String> _destinations = [
    'Beach',
    'Wedding Invitation',
    'Casual Outing',
    'Campus',
    'Hangout',
    'Job Interview',
    'Formal Meeting',
    'Travel',
  ];

  final List<String> _weatherOptions = [
    'Sunny & Warm',
    'Rainy & Cool',
    'Cold & Windy',
    'Hot & Humid',
    'Mild & Pleasant',
  ];

  String _selectedDestination = '';
  String _selectedWeather = '';
  bool _loading = false;
  String? _outfitResult;

  List<Map<String, dynamic>> _outfitDataset = [];
  String? _generatedImageUrl;
  Map<String, dynamic>? _userPersonalization;
  Map<String, dynamic>? _selectedOutfit;

  @override
  void initState() {
    super.initState();
    _loadDataset();
    _loadUserPersonalization();
  }

  Future<void> _loadDataset() async {
    final raw = await rootBundle.loadString('assets/virtual_tryon_dataset.csv');
    final rows = const CsvToListConverter(eol: '\n').convert(raw);
    final headers = rows.first.cast<String>();
    _outfitDataset =
        rows.skip(1).map((row) {
          return Map<String, dynamic>.fromIterables(headers, row);
        }).toList();
    print('Dataset loaded: ${_outfitDataset.length} items');
  }

  Future<void> _loadUserPersonalization() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc =
            await FirebaseFirestore.instance
                .collection('personalisasi')
                .doc(user.uid)
                .get();
        if (doc.exists) {
          setState(() {
            _userPersonalization = doc.data();
          });
          print('User personalization loaded: $_userPersonalization');
        } else {
          print('No personalization data found for user');
        }
      } catch (e) {
        print('Error loading personalization: $e');
      }
    }
  }

  Future<void> _generateOutfit() async {
    setState(() {
      _loading = true;
      _outfitResult = null;
      _selectedOutfit = null;
      _generatedImageUrl = null;
    });

    try {
      // Ambil gender user dari personalisasi
      String? userGender =
          _userPersonalization?['selectedGender']?.toString().toLowerCase();

      List<Map<String, dynamic>> filteredOutfits =
          _outfitDataset.where((outfit) {
            bool matchDestination =
                outfit['destination'] == _selectedDestination;
            bool matchWeather = outfit['weather'] == _selectedWeather;
            bool matchGender =
                userGender == null
                    ? true
                    : (outfit['gender']?.toString().toLowerCase() ==
                        userGender);
            return matchDestination && matchWeather && matchGender;
          }).toList();

      if (_userPersonalization != null && filteredOutfits.isNotEmpty) {
        List<Map<String, dynamic>> personalizedOutfits =
            filteredOutfits.where((outfit) {
              bool matchPersonalization = true;
              // Gender sudah difilter di atas, jadi tidak perlu lagi di sini
              if (_userPersonalization!['selectedBodyShape'] != null) {
                matchPersonalization =
                    matchPersonalization &&
                    outfit['body_shape'].toString().toLowerCase() ==
                        _userPersonalization!['selectedBodyShape']
                            .toString()
                            .toLowerCase();
              }
              if (_userPersonalization!['selectedStyles'] != null) {
                List<String> userStyles = List<String>.from(
                  _userPersonalization!['selectedStyles'],
                );
                if (userStyles.isNotEmpty) {
                  bool styleMatch = userStyles.any(
                    (userStyle) =>
                        outfit['style'].toString().toLowerCase().contains(
                          userStyle.toLowerCase(),
                        ) ||
                        userStyle.toLowerCase().contains(
                          outfit['style'].toString().toLowerCase(),
                        ),
                  );
                  matchPersonalization = matchPersonalization && styleMatch;
                }
              }
              return matchPersonalization;
            }).toList();
        if (personalizedOutfits.isNotEmpty) {
          filteredOutfits = personalizedOutfits;
        }
      }

      if (filteredOutfits.isEmpty) {
        setState(() {
          _loading = false;
          _outfitResult = "No outfit found for your selection.";
        });
        return;
      }

      final selectedOutfit =
          filteredOutfits[Random().nextInt(filteredOutfits.length)];
      final imageUrl = await _generateOutfitImage(selectedOutfit);

      setState(() {
        _loading = false;
        _selectedOutfit = selectedOutfit;
        _generatedImageUrl = imageUrl;
        _outfitResult = selectedOutfit['reason'];
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _outfitResult = "Error generating outfit: $e";
      });
    }
  }

  Future<String?> _generateOutfitImage(Map<String, dynamic> outfit) async {
    //GANTI OPENAI_API_KEY DISINI YAAAA GAIS
    const apiKey = 'YOUR_OPENAI_API_KEY';
        
    final prompt =
        "Fashion flat lay, ${outfit['style']} ${outfit['gender']} outfit for ${outfit['destination']} in ${outfit['weather']}. "
        "Includes: ${outfit['outfit_top']}, ${outfit['outfit_bottom']}, ${outfit['outfit_shoes']}, ${outfit['outfit_accessories']}. "
        "White background, high quality, realistic, no people.";
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "dall-e-3",
          "prompt": prompt,
          "n": 1,
          "size": "1024x1024",
        }),
      );
      print('DALL-E status: ${response.statusCode}');
      print('DALL-E body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl = data['data'][0]['url'];
        print('DALL-E imageUrl: $imageUrl');
        return imageUrl;
      } else {
        print('DALL-E error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('DALL-E exception: $e');
      return null;
    }
  }

  String _getOutfitReason(Map<String, dynamic> outfit) {
    final reason = outfit['reason']?.toString();
    if (reason != null && reason.trim().isNotEmpty && reason != 'null') {
      return reason;
    }
    return "This outfit is recommended because it matches your style (${outfit['style']}), gender (${outfit['gender']}), and is suitable for ${outfit['destination']} in ${outfit['weather']}. It consists of ${outfit['outfit_top']}, ${outfit['outfit_bottom']}, ${outfit['outfit_shoes']}, and ${outfit['outfit_accessories']}.";
  }

  Widget _buildOutfitResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child:
          _selectedOutfit == null
              ? Text(
                _outfitResult ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: mediumGray,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header - Personalization Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_rounded,
                          color: primaryBlue,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Personalized for You',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: primaryBlue,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${_selectedOutfit!['gender']} • ${_selectedOutfit!['style']} • ${_selectedOutfit!['body_shape']}',
                                style: GoogleFonts.poppins(
                                  color: darkGray.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_generatedImageUrl != null)
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: primaryBlue.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            'http://localhost:3000/proxy-image?url=${Uri.encodeComponent(_generatedImageUrl!)}',
                            height: 300,
                            width: 300,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 300,
                                width: 300,
                                decoration: BoxDecoration(
                                  color: lightGray,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      color: primaryBlue,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Loading your outfit...',
                                      style: GoogleFonts.poppins(
                                        color: mediumGray,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 300,
                                width: 300,
                                decoration: BoxDecoration(
                                  color: lightGray,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      size: 48,
                                      color: primaryBlue,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Your Outfit is Ready!',
                                      style: GoogleFonts.poppins(
                                        color: darkGray,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Generated by AI',
                                      style: GoogleFonts.poppins(
                                        color: mediumGray,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    'Outfit Details',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: darkGray,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildOutfitDetail(
                    '👕 Top',
                    _selectedOutfit!['outfit_top']?.toString() ?? '-',
                  ),
                  _buildOutfitDetail(
                    '👖 Bottom',
                    _selectedOutfit!['outfit_bottom']?.toString() ?? '-',
                  ),
                  _buildOutfitDetail(
                    '👟 Shoes',
                    _selectedOutfit!['outfit_shoes']?.toString() ?? '-',
                  ),
                  _buildOutfitDetail(
                    '💎 Accessories',
                    _selectedOutfit!['outfit_accessories']?.toString() ?? '-',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: accentYellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentYellow.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: accentYellow,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Why this outfit?',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: darkGray,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getOutfitReason(_selectedOutfit!),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: darkGray.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildOutfitDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: primaryBlue,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(color: darkGray, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: Material(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              },
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ),
        title: Text(
          'Virtual Try-On',
          style: GoogleFonts.poppins(
            color: darkGray,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 28),
            _buildDestinationSelector(),
            const SizedBox(height: 24),
            _buildWeatherSelector(),
            const SizedBox(height: 36),
            _buildGenerateButton(),
            if (_loading) ...[
              const SizedBox(height: 36),
              Center(child: CircularProgressIndicator(color: primaryBlue)),
            ],
            if (_selectedOutfit != null && !_loading) ...[
              const SizedBox(height: 36),
              _buildOutfitResult(),
            ],
            if (_outfitResult != null &&
                !_loading &&
                _selectedOutfit == null) ...[
              const SizedBox(height: 36),
              Text(
                _outfitResult!,
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryBlue.withOpacity(0.18),
            accentYellow.withOpacity(0.12),
            accentRed.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.10),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: accentYellow.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: primaryBlue.withOpacity(0.10), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [primaryBlue, accentYellow],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accentYellow.withOpacity(0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Color(0xFF4A90E2),
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [primaryBlue, accentYellow, accentRed],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    'Virtual Try-On',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Simulate your best outfit for your chosen destination. Stylish, easy, and personal!',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: darkGray.withOpacity(0.85),
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationSelector() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryBlue.withOpacity(0.08),
            accentYellow.withOpacity(0.05),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryBlue.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryBlue.withOpacity(0.15),
                      primaryBlue.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryBlue.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.place_rounded,
                  color: primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Choose Destination',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: darkGray,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                _destinations.map((dest) {
                  final isSelected = _selectedDestination == dest;
                  return Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _selectedDestination = dest),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          gradient:
                              isSelected
                                  ? LinearGradient(
                                    colors: [primaryBlue, accentYellow],
                                  )
                                  : null,
                          color: isSelected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : lightGray,
                            width: isSelected ? 0 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  isSelected
                                      ? primaryBlue.withOpacity(0.2)
                                      : darkGray.withOpacity(0.04),
                              blurRadius: isSelected ? 16 : 8,
                              offset: Offset(0, isSelected ? 6 : 2),
                            ),
                          ],
                        ),
                        child: Text(
                          dest,
                          style: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : darkGray,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherSelector() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentYellow.withOpacity(0.08),
            accentYellow.withOpacity(0.05),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentYellow.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: accentYellow.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentYellow.withOpacity(0.15),
                      accentYellow.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: accentYellow.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.wb_sunny_rounded,
                  color: accentYellow,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Choose Weather',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: darkGray,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                _weatherOptions.map((weather) {
                  final isSelected = _selectedWeather == weather;
                  return Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _selectedWeather = weather),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          gradient:
                              isSelected
                                  ? LinearGradient(
                                    colors: [
                                      accentYellow,
                                      accentYellow.withOpacity(0.8),
                                    ],
                                  )
                                  : null,
                          color: isSelected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : lightGray,
                            width: isSelected ? 0 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  isSelected
                                      ? accentYellow.withOpacity(0.2)
                                      : darkGray.withOpacity(0.04),
                              blurRadius: isSelected ? 16 : 8,
                              offset: Offset(0, isSelected ? 6 : 2),
                            ),
                          ],
                        ),
                        child: Text(
                          weather,
                          style: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : darkGray,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    final canGenerate =
        _selectedDestination.isNotEmpty && _selectedWeather.isNotEmpty;
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient:
            canGenerate
                ? LinearGradient(
                  colors: [accentRed, accentRed.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : null,
        color: canGenerate ? null : mediumGray.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        boxShadow:
            canGenerate
                ? [
                  BoxShadow(
                    color: accentRed.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: accentRed.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: accentRed.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: darkGray.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
                : [
                  BoxShadow(
                    color: darkGray.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
      ),
      child: ElevatedButton.icon(
        onPressed: canGenerate ? _generateOutfit : null,
        icon: const Icon(Icons.auto_awesome_rounded, size: 24),
        label: Text(
          'Generate Outfit',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: -0.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

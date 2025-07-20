import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart'; // ✅ ADD THIS
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/wardrobe_provider.dart';
import 'pages/splash_screen_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // ✅ INITIALIZE FIREBASE dengan config yang benar
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    print('🔥 Firebase initialized successfully!');
    print('🔥 Project: fitoutfit-f47ae');
    
    // ✅ GET ACTUAL BUCKET FROM FIREBASE INSTANCE
    final storage = FirebaseStorage.instance;
    print('🔥 Storage bucket (actual): ${storage.bucket}');
    print('🔥 Storage bucket (config): ${DefaultFirebaseOptions.currentPlatform.storageBucket}');
    
    // ✅ VERIFY FIREBASE CONFIG
    print('🔥 Platform: ${DefaultFirebaseOptions.currentPlatform.projectId}');
    print('🔥 Auth domain: ${DefaultFirebaseOptions.currentPlatform.authDomain}');
    
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WardrobeProvider()),
        // Tambahkan provider lain di sini jika butuh
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitOutfit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4A90E2), // Blue
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90E2),
          secondary: const Color(0xFFF5A623), // Yellow
          tertiary: const Color(0xFFD0021B), // Red
        ),
        useMaterial3: true,
      ),
      home: const SplashScreenPage(),
    );
  }
}

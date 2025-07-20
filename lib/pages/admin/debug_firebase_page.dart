import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DebugFirebasePage extends StatefulWidget {
  const DebugFirebasePage({super.key});

  @override
  State<DebugFirebasePage> createState() => _DebugFirebasePageState();
}

class _DebugFirebasePageState extends State<DebugFirebasePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _connectionStatus = 'Checking...';
  String _authStatus = 'Checking...';
  List<String> _collectionStatus = [];

  @override
  void initState() {
    super.initState();
    _checkFirebaseConnection();
  }

  Future<void> _checkFirebaseConnection() async {
    try {
      // Check Firestore connection
      await _firestore.collection('test').limit(1).get();
      setState(() {
        _connectionStatus = '✅ Connected';
      });
    } catch (e) {
      setState(() {
        _connectionStatus = '❌ Connection failed: $e';
      });
    }

    // Check Auth status
    try {
      final user = _auth.currentUser;
      setState(() {
        _authStatus =
            user != null
                ? '✅ Authenticated: ${user.email}'
                : '❌ Not authenticated';
      });
    } catch (e) {
      setState(() {
        _authStatus = '❌ Auth error: $e';
      });
    }

    // Check collections
    await _checkCollections();
  }

  Future<void> _checkCollections() async {
    final collections = ['users', 'outfits', 'community_posts', 'fashion_news'];
    List<String> status = [];

    for (String collection in collections) {
      try {
        final snapshot = await _firestore.collection(collection).limit(1).get();
        status.add('✅ $collection: ${snapshot.docs.length} docs found');
      } catch (e) {
        status.add('❌ $collection: Error - $e');
      }
    }

    setState(() {
      _collectionStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Firebase Debug Console',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Status',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Firestore: $_connectionStatus'),
                    Text('Auth: $_authStatus'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Collections Status',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._collectionStatus.map(
                      (status) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(status),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkFirebaseConnection,
              child: const Text('Refresh Status'),
            ),
          ],
        ),
      ),
    );
  }
}

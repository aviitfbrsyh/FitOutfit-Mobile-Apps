import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AddNewsScreen extends StatefulWidget {
  @override
  _AddNewsScreenState createState() => _AddNewsScreenState();
}

class _AddNewsScreenState extends State<AddNewsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage;

  Future<String?> _uploadImageToFirebase(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('news_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  Future<void> _addNews() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      return;
    }

    String? imageUrl;
    if (_selectedImage != null) {
      imageUrl = await _uploadImageToFirebase(_selectedImage!);
    }
    await FirebaseFirestore.instance.collection('fashion_news').add({
      'title': _titleController.text,
      'content': _contentController.text,
      'imageUrl': imageUrl ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    _titleController.clear();
    _contentController.clear();
    // Navigate back or show a success message
  }

  Future<void> addFashionNews(
      {required String title,
      required String content,
      required String imageUrl}) async {
    await FirebaseFirestore.instance.collection('fashion_news').add({
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add News'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addNews,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class FashionNewsServices {
  static final _collection = FirebaseFirestore.instance.collection('fashion_news');

  // Stream semua news (realtime)
  static Stream<QuerySnapshot> getNewsStream() {
    return _collection.orderBy('createdAt', descending: true).snapshots();
  }

  // Stream detail news by docId (realtime)
  static Stream<DocumentSnapshot> getNewsDetailStream(String docId) {
    return _collection.doc(docId).snapshots();
  }

  // Future detail news by docId (one time)
  static Future<DocumentSnapshot> getNewsDetail(String docId) {
    return _collection.doc(docId).get();
  }

  // Like news
  static Future<void> likeNews(String docId, String userId) async {
    await _collection.doc(docId).update({
      'likedBy': FieldValue.arrayUnion([userId])
    });
  }

  // Unlike news
  static Future<void> unlikeNews(String docId, String userId) async {
    await _collection.doc(docId).update({
      'likedBy': FieldValue.arrayRemove([userId])
    });
  }

  static int getLikesCount(Map<String, dynamic> data) {
    final likedBy = data['likedBy'];
    if (likedBy is List) return likedBy.length;
    return 0;
  }

  static bool isLikedByUser(Map<String, dynamic> data, String userId) {
    final likedBy = data['likedBy'];
    if (likedBy is List) return likedBy.contains(userId);
    return false;
  }

  static List<QueryDocumentSnapshot> filterNewsByTitle(
      List<QueryDocumentSnapshot> docs, String query) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final title = (data['title'] ?? '').toString().toLowerCase();
      return title.contains(query.toLowerCase());
    }).toList();
  }

  static String getPreviewContent(String content, {int maxLength = 140}) {
    if (content.length > maxLength) {
      return content.substring(0, maxLength) + '...';
    }
    return content;
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackForm extends StatefulWidget {
  final String? photoUrl;
  final String displayName;
  final String email;

  const FeedbackForm({
    super.key,
    required this.photoUrl,
    required this.displayName,
    required this.email,
  });

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  int _rating = 0;
  String? _category;
  final _commentController = TextEditingController();
  final List<String> _categories = [
    'Try-On Feature',
    'Wardrobe Feature',
    'Style Quiz',
    'Outfit Planner',
    'Fashion News',
    'My Favorites',
    'Profile & Settings',
    'Lainnya'
  ];
  bool _isSubmitting = false;

  void _submitFeedback() async {
    if (_rating == 0 || _category == null || _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua isian feedback!')),
      );
      return;
    }
    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('feedbacks').add({
        'photoUrl': widget.photoUrl,
        'displayName': widget.displayName,
        'email': widget.email,
        'rating': _rating,
        'category': _category,
        'comment': _commentController.text.trim(),
        'sentAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback berhasil dikirim!')),
      );
      setState(() {
        _rating = 0;
        _category = null;
        _commentController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim feedback: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF4A90E2);
    final Color accentYellow = const Color(0xFFF5A623);
    final Color darkGray = const Color(0xFF2C3E50);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kirim Feedback',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: (widget.photoUrl != null && widget.photoUrl!.isNotEmpty)
                      ? NetworkImage(widget.photoUrl!)
                      : const AssetImage('assets/avatar.jpg') as ImageProvider,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.displayName,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: darkGray,
                        ),
                      ),
                      Text(
                        widget.email,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Rating',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            Row(
              children: List.generate(5, (i) => IconButton(
                icon: Icon(
                  i < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                  color: Colors.amber,
                  size: 30,
                ),
                onPressed: () => setState(() => _rating = i + 1),
                tooltip: '${i + 1} Bintang',
              )),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _category,
              items: _categories.map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat, style: GoogleFonts.poppins(fontSize: 13)),
              )).toList(),
              onChanged: (val) => setState(() => _category = val),
              decoration: InputDecoration(
                labelText: 'Kategori',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _commentController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Komentar',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitFeedback,
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                label: Text(
                  _isSubmitting ? 'Mengirim...' : 'Kirim',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentYellow,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
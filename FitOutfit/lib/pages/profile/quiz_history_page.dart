import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizHistoryPage extends StatelessWidget {
  const QuizHistoryPage({super.key});

  String _formatDateFromSessionId(String sessionId) {
    try {
      final timestampStr = sessionId.split('_')[1];
      final timestamp = int.tryParse(timestampStr);
      if (timestamp == null) return 'Unknown date';
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color darkGray = const Color(0xFF333333);
    final Color mediumGray = const Color(0xFF777777);
    final Color primaryBlue = const Color(0xFF4F6EF7);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Quiz History',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: darkGray,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: darkGray),
        elevation: 1,
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          // Cek apakah user sudah login
          if (!authSnapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, size: 64, color: mediumGray),
                  const SizedBox(height: 16),
                  Text(
                    'Please login to view your quiz history',
                    style: GoogleFonts.poppins(color: mediumGray, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final currentUser = authSnapshot.data!;
          // Query hanya berdasarkan UID user yang sedang login
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('budget_quiz_results')
                .where('userId', isEqualTo: currentUser.uid)
                .orderBy('session_id', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${snapshot.error}',
                        style: GoogleFonts.poppins(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz_outlined, size: 64, color: mediumGray),
                      const SizedBox(height: 16),
                      Text(
                        'No quiz history found.',
                        style: GoogleFonts.poppins(color: mediumGray, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Take your first quiz to see results here!',
                        style: GoogleFonts.poppins(color: mediumGray, fontSize: 12),
                      ),
                    ],
                  ),
                );
              }

              final histories = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: histories.length,
                itemBuilder: (context, index) {
                  final history = histories[index].data() as Map<String, dynamic>;
                  final docId = histories[index].id;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.quiz, color: primaryBlue, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Budget Quiz - ${history['budget_type'] ?? 'Unknown'}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: darkGray,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                history['description'] ?? 'No description available.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: mediumGray,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 12, color: mediumGray),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Taken on: ${_formatDateFromSessionId(history['session_id'] ?? '')}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: mediumGray,
                                    ),
                                  ),
                                ],
                              ),
                              if (history['score'] != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.star, size: 12, color: Colors.amber),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Score: ${history['score']}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: mediumGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') {
                              _deleteQuizResult(context, docId);
                            } else if (value == 'view') {
                              _viewQuizDetail(context, history);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility, size: 16),
                                  SizedBox(width: 8),
                                  Text('View Details'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 16, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _deleteQuizResult(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Quiz Result'),
        content: Text('Are you sure you want to delete this quiz result?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('budget_quiz_results')
                    .doc(docId)
                    .delete();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Quiz result deleted successfully')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting quiz result: $e')),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _viewQuizDetail(BuildContext context, Map<String, dynamic> history) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quiz Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Budget Type: ${history['budget_type'] ?? 'Unknown'}'),
            SizedBox(height: 8),
            Text('Description: ${history['description'] ?? 'No description'}'),
            SizedBox(height: 8),
            Text('Session ID: ${history['session_id'] ?? 'Unknown'}'),
            if (history['score'] != null) ...[
              SizedBox(height: 8),
              Text('Score: ${history['score']}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

// CARA PEMANGGILAN YANG BENAR:
// Dari halaman sebelumnya, cukup panggil:
// Navigator.push(
//   context,
//   MaterialPageRoute(builder: (context) => QuizHistoryPage()),
// );
// Tidak perlu passing userUid karena sudah diambil dari FirebaseAuth
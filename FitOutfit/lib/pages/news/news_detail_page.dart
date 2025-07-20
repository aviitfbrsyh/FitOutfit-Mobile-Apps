import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

class NewsDetailPage extends StatefulWidget {
  final String docId;

  const NewsDetailPage({Key? key, required this.docId}) : super(key: key);

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color softCream = Color(0xFFFAF9F7);

  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _trackView(); // ✅ User boleh track views
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ✅ Track view hanya untuk user (bukan admin) - Also track userViews separately
  Future<void> _trackView() async {
    await FirebaseFirestore.instance
        .collection('fashion_news')
        .doc(widget.docId)
        .update({
          'views': FieldValue.increment(1),
          'userViews': FieldValue.increment(
            1,
          ), // ✅ NEW: Track user views separately
          'lastViewedAt': FieldValue.serverTimestamp(),
        });
  }

  // ✅ PERBAIKI: Handle like/unlike dengan direct Firestore
  Future<void> _handleLike(bool isLiked, String userId) async {
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to like articles')),
      );
      return;
    }

    try {
      if (isLiked) {
        // Unlike: hapus userId dari array likedBy
        await FirebaseFirestore.instance
            .collection('fashion_news')
            .doc(widget.docId)
            .update({
              'likedBy': FieldValue.arrayRemove([userId]),
            });
      } else {
        // Like: tambah userId ke array likedBy
        await FirebaseFirestore.instance
            .collection('fashion_news')
            .doc(widget.docId)
            .update({
              'likedBy': FieldValue.arrayUnion([userId]),
            });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // ✅ PERBAIKI: Handle comment dengan validasi user
  Future<void> _handleComment() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login to comment')));
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a comment')));
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('fashion_news')
          .doc(widget.docId)
          .collection('comments')
          .add({
            'userId': currentUser.uid,
            'userName': currentUser.displayName ?? 'Anonymous User',
            'userEmail': currentUser.email ?? '',
            'comment': _commentController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });

      _commentController.clear();

      // ✅ Hide keyboard setelah comment
      FocusScope.of(context).unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding comment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ PERBAIKI: Handle share dengan validasi
  Future<void> _handleShare(String title, String content) async {
    try {
      // ✅ Share content
      await Share.share(
        '$title\n\n$content\n\nShared from FitOutfit App',
        subject: title,
      );

      // ✅ Track share di Firestore
      await FirebaseFirestore.instance
          .collection('fashion_news')
          .doc(widget.docId)
          .update({'shares': FieldValue.increment(1)});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Article shared successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? '';

    return Scaffold(
      backgroundColor: softCream,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('fashion_news')
                  .doc(widget.docId)
                  .snapshots(), // ✅ Direct Firestore stream
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                ),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
            final title = data['title']?.toString() ?? '';
            final imageUrl = data['imageUrl']?.toString() ?? '';
            final content = data['content']?.toString() ?? '';
            final likedBy = List<String>.from(data['likedBy'] ?? []);
            final isLiked = likedBy.contains(userId);
            final views = data['views'] ?? 0;
            final shares = data['shares'] ?? 0;

            return Column(
              children: [
                // ✅ Custom AppBar dengan like button yang working
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: primaryBlue,
                          size: 26,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'Fashion News',
                          style: GoogleFonts.poppins(
                            color: primaryBlue,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // ✅ Like button di AppBar
                      IconButton(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isLiked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            key: ValueKey(isLiked),
                            color: isLiked ? Colors.red : Colors.grey,
                            size: 26,
                          ),
                        ),
                        onPressed: () => _handleLike(isLiked, userId),
                      ),
                      // ✅ Share button di AppBar
                      IconButton(
                        icon: const Icon(
                          Icons.share_rounded,
                          color: primaryBlue,
                          size: 24,
                        ),
                        onPressed: () => _handleShare(title, content),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ Article Content
                        Container(
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: primaryBlue.withValues(alpha: 0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Text(
                                  title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: darkGray,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // ✅ Stats Row dengan real-time data
                                Row(
                                  children: [
                                    _buildStatChip(
                                      Icons.visibility,
                                      '$views views',
                                    ),
                                    const SizedBox(width: 8),
                                    _buildStatChip(
                                      Icons.favorite,
                                      '${likedBy.length} likes',
                                    ),
                                    const SizedBox(width: 8),
                                    _buildStatChip(
                                      Icons.share,
                                      '$shares shares',
                                    ),
                                    const SizedBox(width: 8),
                                    // ✅ Comment count dengan StreamBuilder
                                    StreamBuilder<QuerySnapshot>(
                                      stream:
                                          FirebaseFirestore.instance
                                              .collection('fashion_news')
                                              .doc(widget.docId)
                                              .collection('comments')
                                              .snapshots(),
                                      builder: (context, commentSnapshot) {
                                        final commentCount =
                                            commentSnapshot.hasData
                                                ? commentSnapshot.data!.docs.length
                                                : 0;
                                        return _buildStatChip(
                                          Icons.comment,
                                          '$commentCount comments',
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),

                                // Image
                                if (imageUrl.isNotEmpty)
                                  Container(
                                    width: double.infinity,
                                    height: 200,
                                    margin: const EdgeInsets.only(bottom: 18),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        imageUrl,
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            height: 200,
                                            color: Colors.grey[100],
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  CircularProgressIndicator(
                                                    value:
                                                        loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                            : null,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Loading image...',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          print(
                                            'Image loading error: $error',
                                          ); // ✅ Debug log
                                          return Container(
                                            height: 200,
                                            color: Colors.grey[200],
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey,
                                                  size: 48,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Failed to load image',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Tap to retry',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 18),

                                // Content
                                Text(
                                  content,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: mediumGray,
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // ✅ Action Buttons yang working
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildActionButton(
                                      icon:
                                          isLiked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                      label: 'Like (${likedBy.length})',
                                      onPressed:
                                          () => _handleLike(isLiked, userId),
                                      isActive: isLiked,
                                      color: Colors.red,
                                    ),
                                    _buildActionButton(
                                      icon: Icons.comment_outlined,
                                      label: 'Comment',
                                      onPressed: () {
                                        // ✅ Focus ke comment input
                                        Future.delayed(
                                          const Duration(milliseconds: 100),
                                          () {
                                            _scrollController.animateTo(
                                              _scrollController
                                                  .position
                                                  .maxScrollExtent,
                                              duration: const Duration(
                                                milliseconds: 500,
                                              ),
                                              curve: Curves.easeInOut,
                                            );
                                          },
                                        );
                                      },
                                      color: primaryBlue,
                                    ),
                                    _buildActionButton(
                                      icon: Icons.share_outlined,
                                      label: 'Share',
                                      onPressed:
                                          () => _handleShare(title, content),
                                      color: Colors.green,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ✅ Comments Section
                        _buildCommentsSection(),
                        const SizedBox(height: 100), // Space for bottom input
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _buildCommentInput(),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? color : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isActive ? color : Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? color : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('fashion_news')
              .doc(widget.docId)
              .collection('comments')
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.comment_outlined, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No comments yet',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to comment!',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Comments (${snapshot.data!.docs.length})',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: darkGray,
                  ),
                ),
              ),
              ...snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _buildCommentItem(data);
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final createdAt = comment['createdAt'] as Timestamp?;
    final timeAgo =
        createdAt != null ? _getTimeAgo(createdAt.toDate()) : 'Just now';

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: primaryBlue,
                child: Text(
                  (comment['userName'] ?? 'A').substring(0, 1).toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment['userName'] ?? 'Anonymous',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment['comment'] ?? '',
            style: GoogleFonts.poppins(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // ✅ User avatar
            CircleAvatar(
              radius: 16,
              backgroundColor: primaryBlue,
              child: Text(
                user != null
                    ? (user.displayName ?? user.email ?? 'U')
                        .substring(0, 1)
                        .toUpperCase()
                    : 'G',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText:
                      user != null ? 'Add a comment...' : 'Login to comment...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                enabled: user != null,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _handleComment,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      user != null && _commentController.text.isNotEmpty
                          ? primaryBlue
                          : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

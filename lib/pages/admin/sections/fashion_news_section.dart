import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math' as math;
import 'news_detail_page_admin.dart';

class FashionNewsSection {
  // FitOutfit Brand Colors
  static const Color primaryLavender = Color(0xFFE8E4F3);
  static const Color softBlue = Color(0xFFE8F4FD);
  static const Color darkPurple = Color(0xFF6B46C1);
  static const Color lightPurple = Color(0xFFAD8EE6);

  static Widget buildFashionNewsManagement(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final verticalPadding =
        isMobile
            ? 12.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 16.0
                : 20.0);

    // ✅ Initialize userViews for existing articles (run once)
    initializeUserViewsForExistingArticles();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(
            context,
            'Fashion News Management',
            'Create and manage fashion news articles for users',
            Icons.newspaper_rounded,
          ),
          SizedBox(height: verticalPadding * 1.5),
          _buildNewsAnalyticsCards(context),
          SizedBox(height: verticalPadding),
          if (isMobile) ...[
            _buildAddNewsForm(context),
            SizedBox(height: verticalPadding),
            _buildNewsStats(context),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('fashion_news')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No fashion news yet',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first article to get started!',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    SizedBox(height: verticalPadding),
                    ...snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final imageUrl = data['imageUrl'] ?? '';

                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => NewsDetailPage(
                                        title: data['title'] ?? '',
                                        imageUrl: imageUrl,
                                        content: data['content'] ?? '',
                                        newsId: doc.id,
                                      ),
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title
                                    Text(
                                      data['title'] ?? 'Untitled',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),

                                    // ✅ FIXED: Image dengan proper handling
                                    if (imageUrl.isNotEmpty)
                                      Container(
                                        width: double.infinity,
                                        height: 120,
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            imageUrl,
                                            width: double.infinity,
                                            height: 120,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (
                                              context,
                                              child,
                                              loadingProgress,
                                            ) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Container(
                                                height: 120,
                                                color: Colors.grey[100],
                                                child: Center(
                                                  child: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
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
                                                'Card image loading error: $error',
                                              ); // ✅ Debug log
                                              return Container(
                                                height: 120,
                                                color: Colors.grey[100],
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.broken_image,
                                                      color: Colors.grey[400],
                                                      size: 32,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Image failed to load',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 10,
                                                            color:
                                                                Colors
                                                                    .grey[500],
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),

                                    // Content Preview
                                    Text(
                                      (data['content'] ?? '').length > 120
                                          ? '${data['content']!.substring(0, 120)}...'
                                          : data['content'] ??
                                              'No content available',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        height: 1.4,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),

                                    // ✅ Stats Row with individual article engagement
                                    Row(
                                      children: [
                                        _buildMiniStatChip(
                                          Icons.visibility,
                                          (data['userViews'] ??
                                                  data['views'] ??
                                                  0)
                                              .toString(),
                                        ),
                                        const SizedBox(width: 8),
                                        _buildMiniStatChip(
                                          Icons.favorite,
                                          ((data['likedBy'] as List<dynamic>? ??
                                                      [])
                                                  .length)
                                              .toString(),
                                        ),
                                        const SizedBox(width: 8),
                                        _buildMiniStatChip(
                                          Icons.share,
                                          (data['shares'] ?? 0).toString(),
                                        ),
                                        const SizedBox(width: 8),
                                    
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Delete button
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                tooltip: 'Delete',
                                onPressed: () async {
                                  final confirm = await _showDeleteConfirmation(
                                    context,
                                  );
                                  if (confirm == true) {
                                    await _deleteNews(doc, data['imageUrl']);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildNewsTable(context),
                      SizedBox(height: verticalPadding),
                      _buildNewsEngagementChart(context),
                    ],
                  ),
                ),
                SizedBox(width: verticalPadding),
                Expanded(
                  child: Column(
                    children: [
                      _buildAddNewsForm(context),
                      SizedBox(height: verticalPadding),
                      _buildNewsStats(context),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ✅ UPDATE: Real-time analytics dengan trending berdasarkan views terbanyak
  static Widget _buildNewsAnalyticsCards(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('fashion_news').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingAnalytics(context);
        }

        final docs = snapshot.data!.docs;

        // ✅ Real-time calculations
        final totalNews = docs.length;

        final totalViews = docs.fold<int>(0, (sum, doc) {
          final data = doc.data() as Map<String, dynamic>;
          return sum + (data['views'] as int? ?? 0);
        });

        // ✅ NEW: Count only user views for engagement calculation
        final totalUserViews = docs.fold<int>(0, (sum, doc) {
          final data = doc.data() as Map<String, dynamic>;
          // If userViews doesn't exist, fall back to views for backward compatibility
          final userViews = data['userViews'] as int?;
          final views = data['views'] as int? ?? 0;
          return sum + (userViews ?? views);
        });

        final totalLikes = docs.fold<int>(0, (sum, doc) {
          final data = doc.data() as Map<String, dynamic>;
          final likedBy = data['likedBy'] as List<dynamic>? ?? [];
          return sum + likedBy.length;
        });

        final totalShares = docs.fold<int>(0, (sum, doc) {
          final data = doc.data() as Map<String, dynamic>;
          return sum + (data['shares'] as int? ?? 0);
        });

        // ✅ NEW: Calculate total comments dengan StreamBuilder
        return StreamBuilder<List<QuerySnapshot>>(
          stream: _getCommentsStreams(docs),
          builder: (context, commentsSnapshot) {
            int totalComments = 0;

            if (commentsSnapshot.hasData) {
              for (final commentQuery in commentsSnapshot.data!) {
                totalComments += commentQuery.docs.length;
              }
            }

            // ✅ SIMPLIFIED: Calculate simple metrics instead of engagement
            final totalInteractions = totalLikes + totalShares + totalComments;
            final avgViewsPerArticle =
                totalNews > 0 ? (totalViews / totalNews).round() : 0;
            final avgInteractionsPerArticle =
                totalNews > 0 ? (totalInteractions / totalNews).round() : 0;

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isMobile ? 2 : 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isMobile ? 1.2 : 1.3,
              children: [
                _buildNewsOverviewCard(
                  context,
                  'Total News',
                  totalNews.toString(),
                  'articles published',
                  Icons.article_rounded,
                  const Color(0xFF6B46C1),
                  _getWeeklyGrowth(docs),
                ),
                _buildNewsOverviewCard(
                  context,
                  'Total Views',
                  _formatNumber(totalViews),
                  'total views',
                  Icons.visibility_rounded,
                  const Color(0xFF0EA5E9),
                  _getViewsTrend(totalViews),
                ),
                _buildNewsOverviewCard(
                  context,
                  'Total Interactions',
                  _formatNumber(totalInteractions),
                  'likes + shares + comments',
                  Icons.thumb_up_rounded,
                  const Color(0xFF10B981),
                  _getInteractionsTrend(totalInteractions),
                ),
                _buildNewsOverviewCard(
                  context,
                  'Avg Views',
                  _formatNumber(avgViewsPerArticle),
                  'per article',
                  Icons.trending_up_rounded,
                  const Color(0xFFF59E0B),
                  _getAvgViewsTrend(avgViewsPerArticle),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Widget _buildLoadingAnalytics(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width < 768 ? 2 : 4,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(child: CircularProgressIndicator()),
        );
      }),
    );
  }

  static Widget _buildPageHeader(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final isTablet =
        MediaQuery.of(context).size.width >= 768 &&
        MediaQuery.of(context).size.width < 1024;
    final cardPadding = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
    final borderRadius = isMobile ? 12.0 : (isTablet ? 16.0 : 20.0);

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child:
          isMobile
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryLavender, softBlue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: darkPurple, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: darkPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              )
              : Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 24 : 28,
                            fontWeight: FontWeight.w700,
                            color: darkPurple,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(isTablet ? 16 : 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryLavender, softBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      color: darkPurple,
                      size: isTablet ? 28 : 36,
                    ),
                  ),
                ],
              ),
    );
  }

  static Widget _buildNewsOverviewCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    String trend,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final cardPadding =
        isMobile
            ? 16.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 20.0
                : 24.0);
    final borderRadius =
        isMobile
            ? 12.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 16.0
                : 20.0);

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: isMobile ? 16 : 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 11 : 13,
                    fontWeight: FontWeight.w600,
                    color: darkPurple,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 8 : 10,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              trend,
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 7 : 9,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildNewsTable(BuildContext context) {
    final borderRadius =
        MediaQuery.of(context).size.width < 768
            ? 12.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 16.0
                : 20.0);
    final cardPadding =
        MediaQuery.of(context).size.width < 768
            ? 16.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 20.0
                : 24.0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Row(
              children: [
                Text(
                  'Recent Fashion News',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: darkPurple,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showNewsFilters(context),
                  icon: const Icon(Icons.filter_list_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: primaryLavender,
                    foregroundColor: darkPurple,
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(3, (index) => _buildSimpleNewsRow(context, index)),
        ],
      ),
    );
  }

  static Widget _buildSimpleNewsRow(BuildContext context, int index) {
    final news = [
      {
        'title': 'Spring Fashion Trends 2024',
        'views': '3.2K',
        'status': 'Published',
      },
      {
        'title': 'Sustainable Fashion Guide',
        'views': '2.8K',
        'status': 'Featured',
      },
      {'title': 'Color Matching Tips', 'views': '1.9K', 'status': 'Draft'},
    ];

    final item = news[index];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item['title']!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            item['views']!,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  item['status'] == 'Published'
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item['status']!,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color:
                    item['status'] == 'Published'
                        ? Colors.green
                        : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildAddNewsForm(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder:
                (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: _AddNewsForm(),
                      ),
                    ),
                  ),
                ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Add Fashion News Content'),
      ),
    );
  }

  static Widget _buildNewsStats(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final cardPadding = isMobile ? 16.0 : 24.0;
    final borderRadius = isMobile ? 12.0 : 20.0;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('fashion_news').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            padding: EdgeInsets.all(cardPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snapshot.data!.docs;

        // ✅ Real-time calculations
        final totalNews = docs.length;

        final totalViews = docs.fold<int>(0, (sum, doc) {
          final data = doc.data() as Map<String, dynamic>;
          return sum + (data['views'] as int? ?? 0);
        });

        // ✅ NEW: Count only user views for engagement calculation
        final totalUserViews = docs.fold<int>(0, (sum, doc) {
          final data = doc.data() as Map<String, dynamic>;
          // If userViews doesn't exist, fall back to views for backward compatibility
          final userViews = data['userViews'] as int?;
          final views = data['views'] as int? ?? 0;
          return sum + (userViews ?? views);
        });

        final totalLikes = docs.fold<int>(0, (sum, doc) {
          final data = doc.data() as Map<String, dynamic>;
          final likedBy = data['likedBy'] as List<dynamic>? ?? [];
          return sum + likedBy.length;
        });

        final totalShares = docs.fold<int>(0, (sum, doc) {
          final data = doc.data() as Map<String, dynamic>;
          return sum + (data['shares'] as int? ?? 0);
        });

        return StreamBuilder<List<QuerySnapshot>>(
          stream: _getCommentsStreams(docs),
          builder: (context, commentsSnapshot) {
            int totalComments = 0;

            if (commentsSnapshot.hasData) {
              for (final commentQuery in commentsSnapshot.data!) {
                totalComments += commentQuery.docs.length;
              }
            }

            final totalInteractions = totalLikes + totalShares + totalComments;
            final engagementRate =
                totalUserViews > 0
                    ? ((totalInteractions / totalUserViews) * 100)
                        .toStringAsFixed(1)
                    : '0.0';

            return Container(
              padding: EdgeInsets.all(cardPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'News Performance',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: darkPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow(
                    'Total Articles',
                    totalNews.toString(),
                    Icons.article,
                  ),
                  _buildStatRow(
                    'Total Views',
                    _formatNumber(totalViews),
                    Icons.visibility,
                  ),
                  _buildStatRow(
                    'Total Likes',
                    _formatNumber(totalLikes),
                    Icons.favorite,
                  ),
                  _buildStatRow(
                    'Total Shares',
                    _formatNumber(totalShares),
                    Icons.share,
                  ),
                  _buildStatRow(
                    'Total Comments',
                    _formatNumber(totalComments),
                    Icons.comment,
                  ),
    
                  _buildStatRow(
                    'Total Interactions',
                    _formatNumber(totalInteractions),
                    Icons.touch_app,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: darkPurple,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildNewsEngagementChart(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final cardPadding = isMobile ? 16.0 : 24.0;
    final borderRadius = isMobile ? 12.0 : 20.0;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Engagement Trends',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: darkPurple,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 2),
                      FlSpot(1, 4),
                      FlSpot(2, 3),
                      FlSpot(3, 5),
                      FlSpot(4, 4),
                      FlSpot(5, 6),
                    ],
                    isCurved: true,
                    color: darkPurple,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _showNewsFilters(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filter News'),
            content: const Text('Filter options here...'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  // ✅ HELPER METHODS for analytics calculations
  static String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  static String _getWeeklyGrowth(List<QueryDocumentSnapshot> docs) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final weeklyCount =
        docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final createdAt = data['createdAt'] as Timestamp?;
          return createdAt != null && createdAt.toDate().isAfter(weekAgo);
        }).length;

    return weeklyCount > 0 ? '+$weeklyCount this week' : 'No new articles';
  }

  static String _getViewsTrend(int totalViews) {
    if (totalViews >= 10000) return 'Excellent reach! 🚀';
    if (totalViews >= 5000) return 'Great visibility! ✨';
    if (totalViews >= 2000) return 'Good readership! �';
    if (totalViews >= 1000) return 'Building audience! �';
    if (totalViews >= 500) return 'Growing steadily! 🌱';
    return 'Just getting started! 💪';
  }

  static String _getInteractionsTrend(int totalInteractions) {
    if (totalInteractions >= 1000) return 'Highly engaging! �';
    if (totalInteractions >= 500) return 'Great response! �';
    if (totalInteractions >= 200) return 'Good interaction! �';
    if (totalInteractions >= 100) return 'Building community! 🤝';
    if (totalInteractions >= 50) return 'Active readers! 📚';
    return 'Growing interaction! 🌟';
  }

  static String _getAvgViewsTrend(int avgViews) {
    if (avgViews >= 2000) return 'Incredible reach! 🌟';
    if (avgViews >= 1000) return 'Highly popular! ✨';
    if (avgViews >= 500) return 'Great quality! 👏';
    if (avgViews >= 200) return 'Good response! 📝';
    if (avgViews >= 100) return 'Building audience 🌱';
    if (avgViews >= 50) return 'Growing slowly 🔄';
    return 'Focus on quality 💡';
  }

  // ✅ Comments streams helper
  static Stream<List<QuerySnapshot>> _getCommentsStreams(
    List<QueryDocumentSnapshot> docs,
  ) async* {
    if (docs.isEmpty) {
      yield [];
      return;
    }

    try {
      final List<QuerySnapshot> results = [];
      for (final doc in docs) {
        final commentsSnapshot =
            await FirebaseFirestore.instance
                .collection('fashion_news')
                .doc(doc.id)
                .collection('comments')
                .get();
        results.add(commentsSnapshot);
      }
      yield results;
    } catch (e) {
      print('Error getting comments: $e');
      yield [];
    }
  }

  // ✅ Helper methods untuk mobile cards
  static Widget _buildMiniStatChip(IconData icon, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 2),
          Text(
            count,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  static String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }

  static Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Delete News',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Are you sure you want to delete this news article?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Delete',
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  static Future<void> _deleteNews(
    QueryDocumentSnapshot doc,
    String? imageUrl,
  ) async {
    try {
      // Delete image from storage if exists
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final ref = FirebaseStorage.instance.refFromURL(imageUrl);
          await ref.delete();
        } catch (e) {
          print('Error deleting image: $e');
        }
      }

      // Delete comments subcollection
      final commentsQuery = await doc.reference.collection('comments').get();
      for (final commentDoc in commentsQuery.docs) {
        await commentDoc.reference.delete();
      }

      // Delete the main document
      await doc.reference.delete();

      print('News deleted successfully');
    } catch (e) {
      print('Error deleting news: $e');
    }
  }

  // ✅ Utility method to initialize userViews for existing articles
  static Future<void> initializeUserViewsForExistingArticles() async {
    // ✅ REMOVED: Tidak perlu lagi karena hanya menggunakan field 'views'
    print('✅ Using existing views field - no initialization needed');
  }

  // ✅ ADD: Individual article engagement calculation
  static double calculateArticleEngagement(Map<String, dynamic> data) {
    final views = data['views'] as int? ?? 0;
    final likes = (data['likedBy'] as List<dynamic>? ?? []).length;
    final shares = data['shares'] as int? ?? 0;

    if (views == 0) return 0.0;

    final interactions = likes + shares;

    // ✅ IMPROVED: Better logic untuk realistic engagement
    int effectiveViews;
    if (interactions > 0) {
      // Jika ada interactions, minimal views = interactions * 5
      effectiveViews = math.max(views, interactions * 5);
    } else {
      effectiveViews = views;
    }

    final engagementRate = (interactions / effectiveViews) * 100;

    // ✅ DEBUG: Print untuk debugging
    print('=== Article Debug ===');
    print('Title: ${data['title']}');
    print('Views: $views');
    print('Effective Views: $effectiveViews');
    print('Likes: $likes, Shares: $shares');
    print('Interactions: $interactions');
    print('Engagement: ${engagementRate.toStringAsFixed(2)}%');
    print('===================');

    // ✅ IMPORTANT: Cap at realistic maximum (50% adalah sangat tinggi)
    return engagementRate.clamp(0.0, 50.0);
  }

  // ✅ ADD: Engagement chip untuk setiap artikel
  static Widget _buildEngagementChip(Map<String, dynamic> data) {
    final engagement = calculateArticleEngagement(data);

    Color chipColor;
    // String label; // Removed unused variable

    // ✅ REALISTIC engagement ranges
    if (engagement >= 15) {
      chipColor = Colors.purple;
      // label = 'Viral';
    } else if (engagement >= 8) {
      chipColor = Colors.green;
      // label = 'Great';
    } else if (engagement >= 5) {
      chipColor = Colors.blue;
      // label = 'Good';
    } else if (engagement >= 2) {
      chipColor = Colors.orange;
      // label = 'Fair';
    } else {
      chipColor = Colors.red;
      // label = 'Low';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up, size: 10, color: chipColor),
          const SizedBox(width: 2),
          Text(
            '${engagement.toStringAsFixed(1)}%',
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: chipColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ ADD: Debug method untuk melihat data artikel
  static void debugArticleEngagement(Map<String, dynamic> data, String title) {
    final userViews = data['userViews'] as int? ?? data['views'] as int? ?? 0;
    final likes = (data['likedBy'] as List<dynamic>? ?? []).length;
    final shares = data['shares'] as int? ?? 0;
    final engagement = calculateArticleEngagement(data);

    print('=== Article: $title ===');
    print('User Views: $userViews');
    print('Likes: $likes');
    print('Shares: $shares');
    print('Engagement Rate: ${engagement.toStringAsFixed(2)}%');
    print('========================');
  }
}

// ✅ ADD: _AddNewsForm class for creating new news articles
class _AddNewsForm extends StatefulWidget {
  @override
  State<_AddNewsForm> createState() => _AddNewsFormState();
}

class _AddNewsFormState extends State<_AddNewsForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _publishNews() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ✅ ADD: Initialize all required fields including userViews
      await FirebaseFirestore.instance.collection('fashion_news').add({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'imageUrl': '', // No image for now
        'createdAt': FieldValue.serverTimestamp(),
        'views': 0,
        'userViews': 0, // ✅ NEW: Track only user views for engagement
        'likedBy': [],
        'shares': 0,
        'lastViewedAt': null,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('News published successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final cardPadding = isMobile ? 16.0 : 24.0;
    final borderRadius = isMobile ? 12.0 : 20.0;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Add Fashion News',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: FashionNewsSection.darkPurple,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Article Title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Content',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _publishNews,
              style: ElevatedButton.styleFrom(
                backgroundColor: FashionNewsSection.darkPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(
                        'Publish Article',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityModerationSection {
  // FitOutfit Brand Colors
  static const Color primaryLavender = Color(0xFFE8E4F3);
  static const Color softBlue = Color(0xFFE8F4FD);
  static const Color darkPurple = Color(0xFF6B46C1);
  static const Color lightPurple = Color(0xFFAD8EE6);

  static Widget buildCommunityModeration(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final verticalPadding =
        isMobile
            ? 12.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 16.0
                : 20.0);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(
            context,
            'Community Moderation',
            'Monitor and manage user interactions and community content',
            Icons.forum_rounded,
          ),
          SizedBox(height: verticalPadding * 1.5),
          _buildModerationOverviewCards(context),
          SizedBox(height: verticalPadding),
          if (isMobile) ...[
            _buildCommunityManagement(context),
            SizedBox(height: verticalPadding),
            _buildQuickActions(context),
            SizedBox(height: verticalPadding),
            _buildCommunityStats(context),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildCommunityManagement(context),
                      SizedBox(height: verticalPadding),
                      _buildActivityChart(context),
                    ],
                  ),
                ),
                SizedBox(width: verticalPadding),
                Expanded(
                  child: Column(
                    children: [
                      _buildQuickActions(context),
                      SizedBox(height: verticalPadding),
                      _buildCommunityStats(context),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
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

  static Widget _buildModerationOverviewCards(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final horizontalPadding =
        isMobile
            ? 16.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 20.0
                : 24.0);
    final verticalPadding =
        isMobile
            ? 12.0
            : (MediaQuery.of(context).size.width >= 768 &&
                    MediaQuery.of(context).size.width < 1024
                ? 16.0
                : 20.0);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 2 : 4,
      crossAxisSpacing: horizontalPadding,
      mainAxisSpacing: verticalPadding,
      childAspectRatio: isMobile ? 1.2 : 1.3,
      children: [
        _buildRealtimeModerationCard(
          context,
          'Active Users',
          Icons.people_rounded,
          const Color(0xFF10B981),
          'users online',
          FirebaseAuth.instance.authStateChanges().map(
            (user) => user != null ? 1 : 0,
          ),
        ),
        _buildRealtimeModerationCard(
          context,
          'Community Posts',
          Icons.forum_rounded,
          const Color(0xFF0EA5E9),
          'total posts',
          FirebaseFirestore.instance
              .collectionGroup('posts')
              .snapshots()
              .map((snapshot) => snapshot.docs.length),
        ),
        _buildRealtimeModerationCard(
          context,
          'Communities',
          Icons.groups_rounded,
          const Color(0xFF6B46C1),
          'active communities',
          FirebaseFirestore.instance
              .collection('komunitas')
              .snapshots()
              .map((snapshot) => snapshot.docs.length),
        ),
        _buildRealtimeModerationCard(
          context,
          'Total Members',
          Icons.group_add_rounded,
          const Color(0xFFF59E0B),
          'community members',
          FirebaseFirestore.instance
              .collectionGroup('members')
              .snapshots()
              .map((snapshot) => snapshot.docs.length),
        ),
      ],
    );
  }

  static Widget _buildRealtimeModerationCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String subtitle,
    Stream<int> dataStream,
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

    return StreamBuilder<int>(
      stream: dataStream,
      builder: (context, snapshot) {
        final value = snapshot.hasData ? snapshot.data.toString() : '...';
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

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
              isLoading
                  ? SizedBox(
                    height: isMobile ? 20 : 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  )
                  : Text(
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
                  'Real-time',
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
      },
    );
  }

  static Widget _buildCommunityManagement(BuildContext context) {
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
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Community Management',
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: darkPurple,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Active',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('komunitas')
                    .limit(5)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No communities found',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                );
              }

              return Column(
                children:
                    snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return _buildCommunityItem(context, data, doc.id);
                    }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  static Widget _buildCommunityItem(
    BuildContext context,
    Map<String, dynamic> community,
    String communityId,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isMobile ? 40 : 48,
                height: isMobile ? 40 : 48,
                decoration: BoxDecoration(
                  color: Color(community['color'] ?? 0xFF6B46C1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  IconData(
                    community['icon'] ?? 0xe7ff,
                    fontFamily: 'MaterialIcons',
                  ),
                  color: Colors.white,
                  size: isMobile ? 20 : 24,
                ),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      community['name'] ?? 'Unknown Community',
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: darkPurple,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      community['desc'] ?? 'No description',
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 10 : 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(
                    community['color'] ?? 0xFF6B46C1,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  community['category'] ?? 'General',
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 8 : 10,
                    fontWeight: FontWeight.w600,
                    color: Color(community['color'] ?? 0xFF6B46C1),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('komunitas')
                        .doc(communityId)
                        .collection('members')
                        .snapshots(),
                builder: (context, memberSnapshot) {
                  final memberCount =
                      memberSnapshot.hasData
                          ? memberSnapshot.data!.docs.length
                          : 0;
                  return Text(
                    '$memberCount members',
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 8 : 10,
                      color: Colors.grey[500],
                    ),
                  );
                },
              ),
              const Spacer(),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('komunitas')
                        .doc(communityId)
                        .collection('posts')
                        .snapshots(),
                builder: (context, postSnapshot) {
                  final postCount =
                      postSnapshot.hasData ? postSnapshot.data!.docs.length : 0;
                  return Row(
                    children: [
                      Icon(
                        Icons.forum_rounded,
                        size: isMobile ? 12 : 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$postCount posts',
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 8 : 10,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildQuickActions(BuildContext context) {
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
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: darkPurple,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildActionButton(
            context,
            'Create Community',
            'Add a new community category',
            Icons.add_circle_rounded,
            const Color(0xFF10B981),
            () => _showCreateCommunityDialog(context),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildActionButton(
            context,
            'Manage Posts',
            'Moderate community posts and content',
            Icons.forum_rounded,
            const Color(0xFF0EA5E9),
            () => _showManagePostsDialog(context),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildActionButton(
            context,
            'Community Analytics',
            'View detailed community statistics',
            Icons.analytics_rounded,
            const Color(0xFF6B46C1),
            () => _showAnalyticsDialog(context),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildActionButton(
            context,
            'Member Management',
            'Manage community members and roles',
            Icons.group_rounded,
            const Color(0xFFF59E0B),
            () => _showMemberManagementDialog(context),
          ),
        ],
      ),
    );
  }

  static Widget _buildActionButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 8 : 10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: isMobile ? 16 : 20),
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 10 : 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: isMobile ? 14 : 16,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildCommunityStats(BuildContext context) {
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
            'Community Statistics',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: darkPurple,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('komunitas').snapshots(),
            builder: (context, snapshot) {
              final communityCount =
                  snapshot.hasData ? snapshot.data!.docs.length : 0;
              return _buildStatItem(
                'Total Communities',
                '$communityCount',
                const Color(0xFF10B981),
              );
            },
          ),
          SizedBox(height: isMobile ? 12 : 16),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collectionGroup('posts').snapshots(),
            builder: (context, snapshot) {
              final postCount =
                  snapshot.hasData ? snapshot.data!.docs.length : 0;
              return _buildStatItem(
                'Total Posts',
                '$postCount',
                const Color(0xFF0EA5E9),
              );
            },
          ),
          SizedBox(height: isMobile ? 12 : 16),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collectionGroup('members')
                    .snapshots(),
            builder: (context, snapshot) {
              final memberCount =
                  snapshot.hasData ? snapshot.data!.docs.length : 0;
              return _buildStatItem(
                'Total Members',
                '$memberCount',
                const Color(0xFFF59E0B),
              );
            },
          ),
          SizedBox(height: isMobile ? 12 : 16),
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final activeUsers = snapshot.hasData ? 1 : 0;
              return _buildStatItem(
                'Active Users',
                '$activeUsers',
                const Color(0xFF6B46C1),
              );
            },
          ),
          SizedBox(height: isMobile ? 16 : 20),

          // Community Categories Breakdown
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryLavender.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Popular Categories',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('komunitas')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    // Count categories
                    Map<String, int> categoryCount = {};
                    for (var doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final category = data['category'] ?? 'Other';
                      categoryCount[category] =
                          (categoryCount[category] ?? 0) + 1;
                    }

                    // Sort by count and take top 4
                    final sortedCategories =
                        categoryCount.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value));

                    final topCategories = sortedCategories.take(4).toList();
                    final total = snapshot.data!.docs.length;

                    return Column(
                      children:
                          topCategories.map((entry) {
                            final percentage =
                                total > 0
                                    ? ((entry.value / total) * 100)
                                        .toStringAsFixed(0)
                                    : '0';
                            return _buildViolationItem(
                              entry.key,
                              '$percentage%',
                              _getCategoryColor(entry.key),
                            );
                          }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'style':
        return const Color(0xFF6B46C1);
      case 'street':
        return const Color(0xFFEF4444);
      case 'formal':
        return const Color(0xFF0EA5E9);
      case 'boho':
        return const Color(0xFF8E44AD);
      case 'sport':
        return const Color(0xFF27AE60);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  static Widget _buildStatItem(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  static Widget _buildViolationItem(
    String type,
    String percentage,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              type,
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[700]),
            ),
          ),
          Text(
            percentage,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildActivityChart(BuildContext context) {
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
            'Moderation Activity',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 14 : 18,
              fontWeight: FontWeight.w600,
              color: darkPurple,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          SizedBox(
            height: isMobile ? 150 : 200,
            child: _buildModerationChart(),
          ),
        ],
      ),
    );
  }

  static Widget _buildModerationChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 20,
        barTouchData: BarTouchData(enabled: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [BarChartRodData(toY: 8, color: const Color(0xFFEF4444))],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [BarChartRodData(toY: 12, color: const Color(0xFFF59E0B))],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [BarChartRodData(toY: 6, color: const Color(0xFF10B981))],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [BarChartRodData(toY: 15, color: const Color(0xFF6B46C1))],
          ),
          BarChartGroupData(
            x: 4,
            barRods: [BarChartRodData(toY: 9, color: const Color(0xFF0EA5E9))],
          ),
          BarChartGroupData(
            x: 5,
            barRods: [BarChartRodData(toY: 11, color: const Color(0xFFEF4444))],
          ),
          BarChartGroupData(
            x: 6,
            barRods: [BarChartRodData(toY: 7, color: const Color(0xFF10B981))],
          ),
        ],
        gridData: const FlGridData(show: false),
      ),
    );
  }

  // Helper Methods
  static void _showCreateCommunityDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    String selectedCategory = 'Style';
    Color selectedColor = const Color(0xFF6B46C1);
    IconData selectedIcon = Icons.group_rounded;

    final categories = ['Style', 'Street', 'Formal', 'Boho', 'Sport', 'Casual'];
    final colors = [
      const Color(0xFF6B46C1), // Purple
      const Color(0xFF0EA5E9), // Blue
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Orange
      const Color(0xFFEF4444), // Red
      const Color(0xFF8E44AD), // Dark Purple
    ];
    final icons = [
      Icons.group_rounded,
      Icons.style_rounded,
      Icons.local_fire_department_rounded,
      Icons.star_rounded,
      Icons.favorite_rounded,
      Icons.flash_on_rounded,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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
                      child: Icon(
                        Icons.add_circle_rounded,
                        color: darkPurple,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create New Community',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: darkPurple,
                            ),
                          ),
                          Text(
                            'Build a new space for fashion enthusiasts',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Community Preview
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: selectedColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selectedColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Preview',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: selectedColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: selectedColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      selectedIcon,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nameController.text.isEmpty
                                              ? 'Community Name'
                                              : nameController.text,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: nameController.text.isEmpty
                                                ? Colors.grey[400]
                                                : darkPurple,
                                          ),
                                        ),
                                        Text(
                                          descController.text.isEmpty
                                              ? 'Community description will appear here...'
                                              : descController.text,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: descController.text.isEmpty
                                                ? Colors.grey[400]
                                                : Colors.grey[600],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: selectedColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      selectedCategory,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: selectedColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '0 members',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Community Name
                        Text(
                          'Community Name',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: darkPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: nameController,
                          onChanged: (value) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Enter community name...',
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: selectedColor, width: 2),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Description
                        Text(
                          'Description',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: darkPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: descController,
                          onChanged: (value) => setState(() {}),
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Describe your community...',
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: selectedColor, width: 2),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Category Selection
                        Text(
                          'Category',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: darkPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: categories.map((category) {
                            final isSelected = selectedCategory == category;
                            return GestureDetector(
                              onTap: () => setState(() => selectedCategory = category),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? selectedColor : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? selectedColor : Colors.grey[300]!,
                                  ),
                                ),
                                child: Text(
                                  category,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : Colors.grey[700],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Color Selection
                        Text(
                          'Theme Color',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: darkPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: colors.map((color) {
                            final isSelected = selectedColor == color;
                            return GestureDetector(
                              onTap: () => setState(() => selectedColor = color),
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    if (isSelected)
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                  ],
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Icon Selection
                        Text(
                          'Community Icon',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: darkPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: icons.map((icon) {
                            final isSelected = selectedIcon == icon;
                            return GestureDetector(
                              onTap: () => setState(() => selectedIcon = icon),
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSelected ? selectedColor : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? selectedColor : Colors.grey[300]!,
                                  ),
                                ),
                                child: Icon(
                                  icon,
                                  color: isSelected ? Colors.white : Colors.grey[600],
                                  size: 20,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                // Create Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: nameController.text.isNotEmpty && descController.text.isNotEmpty
                        ? () async {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('komunitas')
                                  .add({
                                    'name': nameController.text.trim(),
                                    'desc': descController.text.trim(),
                                    'category': selectedCategory,
                                    'color': selectedColor.value,
                                    'icon': selectedIcon.codePoint,
                                    'tags': [selectedCategory.toLowerCase()],
                                    'members': 0,
                                    'createdAt': FieldValue.serverTimestamp(),
                                  });
                              
                              Navigator.pop(context);
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Community "${nameController.text}" created successfully!',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF10B981),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.all(16),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to create community. Please try again.',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_rounded,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Create Community',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _showManagePostsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.forum_rounded, color: darkPurple, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Manage Community Posts',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: darkPurple,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('komunitas')
                      .snapshots(),
                  builder: (context, communitySnapshot) {
                    if (communitySnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!communitySnapshot.hasData || communitySnapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No communities found'));
                    }

                    return ListView.builder(
                      itemCount: communitySnapshot.data!.docs.length,
                      itemBuilder: (context, communityIndex) {
                        final community = communitySnapshot.data!.docs[communityIndex];
                        final communityData = community.data() as Map<String, dynamic>;
                        final communityId = community.id;
                        
                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('komunitas')
                              .doc(communityId)
                              .collection('posts')
                              .snapshots(),
                          builder: (context, postSnapshot) {
                            final postCount = postSnapshot.hasData 
                                ? postSnapshot.data!.docs.length 
                                : 0;
                            
                            // Skip communities with no posts
                            if (postCount == 0) {
                              return const SizedBox.shrink();
                            }

                            return ExpansionTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color(communityData['color'] ?? 0xFF6B46C1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  IconData(
                                    communityData['icon'] ?? 0xe7ff,
                                    fontFamily: 'MaterialIcons',
                                  ),
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                communityData['name'] ?? 'Unknown Community',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: darkPurple,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Color(communityData['color'] ?? 0xFF6B46C1).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      communityData['category'] ?? 'General',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Color(communityData['color'] ?? 0xFF6B46C1),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$postCount posts',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                if (!postSnapshot.hasData || postSnapshot.data!.docs.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Center(
                                      child: Text(
                                        'No posts in this community',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: postSnapshot.data!.docs.map((post) {
                                        final postData = post.data() as Map<String, dynamic>;
                                        final postId = post.id;
                                        
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey[200]!),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 12,
                                                    backgroundColor: Color(communityData['color'] ?? 0xFF6B46C1),
                                                    child: Text(
                                                      (postData['authorName'] ?? 'U')[0].toUpperCase(),
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          postData['authorName'] ?? 'Unknown Author',
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                        Text(
                                                          'Posted: ${_formatDate(postData['createdAt'])}',
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 9,
                                                            color: Colors.grey[500],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete_rounded,
                                                      color: Colors.red,
                                                      size: 18,
                                                    ),
                                                    onPressed: () async {
                                                      final confirm = await showDialog<bool>(
                                                        context: context,
                                                        builder: (context) => AlertDialog(
                                                          title: Text(
                                                            'Delete Post',
                                                            style: GoogleFonts.poppins(
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                          content: Text(
                                                            'Are you sure you want to delete this post? This action cannot be undone.',
                                                            style: GoogleFonts.poppins(),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Navigator.pop(context, false),
                                                              child: const Text('Cancel'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () => Navigator.pop(context, true),
                                                              style: TextButton.styleFrom(
                                                                foregroundColor: Colors.red,
                                                              ),
                                                              child: const Text('Delete'),
                                                            ),
                                                          ],
                                                        ),
                                                      );

                                                      if (confirm == true) {
                                                        await post.reference.delete();
                                                        if (context.mounted) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                'Post deleted from ${communityData['name']}',
                                                                style: GoogleFonts.poppins(),
                                                              ),
                                                              backgroundColor: Colors.red,
                                                            ),
                                                          );
                                                        }
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  postData['content'] ?? 'No content',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    color: Colors.grey[700],
                                                  ),
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (postData['imageUrl'] != null)
                                                Container(
                                                  margin: const EdgeInsets.only(top: 8),
                                                  padding: const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.image_rounded,
                                                        size: 14,
                                                        color: Color(0xFF0EA5E9),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Contains image',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 9,
                                                          fontWeight: FontWeight.w500,
                                                          color: const Color(0xFF0EA5E9),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Color(communityData['color'] ?? 0xFF6B46C1).withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Text(
                                                      'In: ${communityData['name']}',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 9,
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(communityData['color'] ?? 0xFF6B46C1),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Post ID: ${postId.substring(0, 8)}...',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 8,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showAnalyticsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Community Analytics',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('komunitas')
                          .snapshots(),
                  builder: (context, snapshot) {
                    final communityCount =
                        snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return Text('Total Communities: $communityCount');
                  },
                ),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collectionGroup('posts')
                          .snapshots(),
                  builder: (context, snapshot) {
                    final postCount =
                        snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return Text('Total Posts: $postCount');
                  },
                ),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collectionGroup('members')
                          .snapshots(),
                  builder: (context, snapshot) {
                    final memberCount =
                        snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return Text('Total Members: $memberCount');
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  static void _showMemberManagementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.group_rounded, color: darkPurple, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Member Management',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: darkPurple,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('komunitas')
                      .snapshots(),
                  builder: (context, communitySnapshot) {
                    if (communitySnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!communitySnapshot.hasData || communitySnapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No communities found'));
                    }

                    return ListView.builder(
                      itemCount: communitySnapshot.data!.docs.length,
                      itemBuilder: (context, communityIndex) {
                        final community = communitySnapshot.data!.docs[communityIndex];
                        final communityData = community.data() as Map<String, dynamic>;
                        final communityId = community.id;
                        
                        return ExpansionTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(communityData['color'] ?? 0xFF6B46C1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              IconData(
                                communityData['icon'] ?? 0xe7ff,
                                fontFamily: 'MaterialIcons',
                              ),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            communityData['name'] ?? 'Unknown Community',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: darkPurple,
                            ),
                          ),
                          subtitle: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('komunitas')
                                .doc(communityId)
                                .collection('members')
                                .snapshots(),
                            builder: (context, memberSnapshot) {
                              final memberCount = memberSnapshot.hasData 
                                  ? memberSnapshot.data!.docs.length 
                                  : 0;
                              return Text(
                                '$memberCount members',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              );
                            },
                          ),
                          children: [
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('komunitas')
                                  .doc(communityId)
                                  .collection('members')
                                  .snapshots(),
                              builder: (context, memberSnapshot) {
                                if (memberSnapshot.connectionState == ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }

                                if (!memberSnapshot.hasData || memberSnapshot.data!.docs.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Center(
                                      child: Text(
                                        'No members in this community',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: memberSnapshot.data!.docs.map((member) {
                                      final memberData = member.data() as Map<String, dynamic>;
                                      final memberId = member.id;
                                      
                                      return ListTile(
                                        dense: true,
                                        leading: CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Color(communityData['color'] ?? 0xFF6B46C1),
                                          child: Text(
                                            (memberData['displayName'] ?? 'U')[0].toUpperCase(),
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          memberData['displayName'] ?? 'Unknown User',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Member ID: $memberId',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                            Text(
                                              'Joined: ${_formatDate(memberData['joinedAt'])}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Color(communityData['color'] ?? 0xFF6B46C1).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            communityData['category'] ?? 'General',
                                            style: GoogleFonts.poppins(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600,
                                              color: Color(communityData['color'] ?? 0xFF6B46C1),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method untuk format tanggal
  static String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        return '${date.day}/${date.month}/${date.year}';
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }
}

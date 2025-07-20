import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/fashion_news_services.dart';
import 'news_detail_page.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color softCream = Color(0xFFFAF9F7);

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  double _getResponsiveFontSize(double base) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return base * 0.9;
    if (width > 400) return base * 1.05;
    return base;
  }

  double _getHorizontalPadding() {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 16;
    if (width < 400) return 20;
    return 24;
  }

  double _getResponsiveHeight(double base) {
    final height = MediaQuery.of(context).size.height;
    if (height < 700) return base * 0.8;
    if (height > 900) return base * 1.1;
    return base;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softCream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryBlue),
        title: Text(
          'Fashion News',
          style: GoogleFonts.poppins(
            color: primaryBlue,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              _getHorizontalPadding(),
              _getResponsiveHeight(18),
              _getHorizontalPadding(),
              _getResponsiveHeight(8),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search news by title...',
                hintStyle: GoogleFonts.poppins(
                  color: mediumGray,
                  fontSize: _getResponsiveFontSize(14),
                ),
                prefixIcon: Icon(Icons.search_rounded, color: primaryBlue),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: mediumGray),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                        : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: _getHorizontalPadding(),
                  vertical: _getResponsiveHeight(14),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FashionNewsServices.getNewsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No news yet.',
                      style: GoogleFonts.poppins(color: mediumGray),
                    ),
                  );
                }
                final docs = FashionNewsServices.filterNewsByTitle(
                  snapshot.data!.docs,
                  _searchQuery,
                );

                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No news found.',
                      style: GoogleFonts.poppins(color: mediumGray),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: _getHorizontalPadding(),
                    vertical: _getResponsiveHeight(8),
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildNewsPreviewCard(context, data, doc.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsPreviewCard(
    BuildContext context,
    Map<String, dynamic> data,
    String docId,
  ) {
    final cardRadius = 18.0;
    final imageUrl = data['imageUrl'] ?? '';
    final title = data['title'] ?? '';
    final content = data['content'] ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NewsDetailPage(docId: docId)),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: _getResponsiveHeight(18)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(cardRadius),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(_getHorizontalPadding()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    imageUrl,
                    height: _getResponsiveHeight(120),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          height: _getResponsiveHeight(120),
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                  ),
                ),
              SizedBox(height: _getResponsiveHeight(12)),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(16),
                  fontWeight: FontWeight.w700,
                  color: darkGray,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: _getResponsiveHeight(8)),
              Text(
                FashionNewsServices.getPreviewContent(content),
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(12),
                  color: mediumGray,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: _getResponsiveHeight(10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.thumb_up, color: primaryBlue, size: 18),
                      SizedBox(width: 4),
                      Text(
                        '${FashionNewsServices.getLikesCount(data)} likes',
                        style: GoogleFonts.poppins(
                          color: mediumGray,
                          fontSize: _getResponsiveFontSize(12),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Implement like functionality
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: primaryBlue,
                          size: 18,
                        ),
                        SizedBox(width: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

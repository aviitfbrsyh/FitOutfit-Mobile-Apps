import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'outfit_planner_page.dart';

class OutfitPreviewPage extends StatefulWidget {
  final OutfitEvent outfitEvent;
  final DateTime date;

  const OutfitPreviewPage({
    super.key,
    required this.outfitEvent,
    required this.date,
  });

  @override
  State<OutfitPreviewPage> createState() => _OutfitPreviewPageState();
}

class _OutfitPreviewPageState extends State<OutfitPreviewPage>
    with TickerProviderStateMixin {
  // FitOutfit brand colors
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  // ✅ REMOVED: accentRed unused field
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color softCream = Color(0xFFFAF9F7);

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  double _getScreenWidth() => MediaQuery.of(context).size.width;
  bool _isSmallScreen() => _getScreenWidth() < 360;
  double _getHorizontalPadding() => _isSmallScreen() ? 16 : 20;
  double _getResponsiveHeight(double baseHeight) =>
      _isSmallScreen() ? baseHeight * 0.9 : baseHeight;
  double _getResponsiveFontSize(double baseSize) =>
      _isSmallScreen() ? baseSize * 0.9 : baseSize;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softCream,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(_getHorizontalPadding()),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOutfitHeader(),
                        SizedBox(height: _getResponsiveHeight(24)),
                        _buildOutfitVisualization(),
                        SizedBox(height: _getResponsiveHeight(24)),
                        _buildOutfitDetails(),
                        SizedBox(height: _getResponsiveHeight(24)),
                        _buildClothingItems(),
                        SizedBox(height: _getResponsiveHeight(100)),
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

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: _getResponsiveHeight(120),
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.arrow_back_ios_rounded, color: primaryBlue),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [SizedBox(width: _getHorizontalPadding())],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryBlue.withValues(alpha: 0.9),
                accentYellow.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(_getResponsiveHeight(30)),
              bottomRight: Radius.circular(_getResponsiveHeight(30)),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(_getHorizontalPadding()),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Outfit Details',
                    style: GoogleFonts.poppins(
                      fontSize: _getResponsiveFontSize(28),
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Complete outfit information',
                    style: GoogleFonts.poppins(
                      fontSize: _getResponsiveFontSize(14),
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: _getResponsiveHeight(10)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutfitHeader() {
    Color statusColor = _getStatusColor();

    return Container(
      padding: EdgeInsets.all(_getHorizontalPadding()),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.1),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.outfitEvent.outfitName,
                      style: GoogleFonts.poppins(
                        fontSize: _getResponsiveFontSize(22),
                        fontWeight: FontWeight.w800,
                        color: darkGray,
                      ),
                    ),
                    SizedBox(height: _getResponsiveHeight(4)),
                    Text(
                      widget.outfitEvent.title,
                      style: GoogleFonts.poppins(
                        fontSize: _getResponsiveFontSize(16),
                        color: primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(),
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(12),
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: _getResponsiveHeight(16)),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, color: mediumGray, size: 16),
              const SizedBox(width: 8),
              Text(
                '${widget.date.day}/${widget.date.month}/${widget.date.year}',
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(14),
                  color: mediumGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time_rounded, color: mediumGray, size: 16),
              const SizedBox(width: 8),
              Text(
                'All Day',
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(14),
                  color: mediumGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitVisualization() {
    return Container(
      width: double.infinity,
      height: _getResponsiveHeight(300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryBlue.withValues(alpha: 0.1),
                  accentYellow.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.checkroom_rounded,
                    color: primaryBlue,
                    size: 64,
                  ),
                ),
                SizedBox(height: _getResponsiveHeight(16)),
                Text(
                  'Outfit Overview',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(18),
                    fontWeight: FontWeight.w700,
                    color: darkGray,
                  ),
                ),
                SizedBox(height: _getResponsiveHeight(8)),
                Text(
                  'Complete outfit details below',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(12),
                    color: mediumGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitDetails() {
    return Container(
      padding: EdgeInsets.all(_getHorizontalPadding()),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Outfit Details',
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(18),
              fontWeight: FontWeight.w700,
              color: darkGray,
            ),
          ),
          SizedBox(height: _getResponsiveHeight(16)),
          _buildDetailRow(
            'Event',
            widget.outfitEvent.title,
            Icons.event_rounded,
          ),
          SizedBox(height: _getResponsiveHeight(12)),
          _buildDetailRow(
            'Style',
            widget.outfitEvent.outfitName,
            Icons.style_rounded,
          ),
          // Added weather information
          if (widget.outfitEvent.weather != null &&
              widget.outfitEvent.weather!.isNotEmpty) ...[
            SizedBox(height: _getResponsiveHeight(12)),
            _buildDetailRow(
              'Weather',
              widget.outfitEvent.weather!,
              Icons.wb_sunny_rounded,
            ),
          ],
          if (widget.outfitEvent.notes != null &&
              widget.outfitEvent.notes!.isNotEmpty) ...[
            SizedBox(height: _getResponsiveHeight(12)),
            _buildDetailRow(
              'Notes',
              widget.outfitEvent.notes!,
              Icons.note_rounded,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryBlue, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(12),
                  fontWeight: FontWeight.w600,
                  color: mediumGray,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(14),
                  color: darkGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClothingItems() {
    // ✅ FIXED: Handle WardrobeItem objects properly and remove unused variable
    final wardrobeItems = widget.outfitEvent.wardrobeItems;

    return Container(
      padding: EdgeInsets.all(_getHorizontalPadding()),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Wardrobe Items (${wardrobeItems?.length ?? 0})',
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(18),
              fontWeight: FontWeight.w700,
              color: darkGray,
            ),
          ),
          SizedBox(height: _getResponsiveHeight(16)),

          // Show items in a more detailed way if they have images
          if (wardrobeItems?.isNotEmpty == true)
            _buildItemsGrid(wardrobeItems!)
          else
            _buildEmptyItemsMessage(),
        ],
      ),
    );
  }

  // New method to build items grid with images
  Widget _buildItemsGrid(List<WardrobeItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemPreviewCard(item);
      },
    );
  }

  // New method to build individual item preview card
  Widget _buildItemPreviewCard(WardrobeItem item) {
    return Container(
      decoration: BoxDecoration(
        color: softCream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child:
                    item.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  _buildItemPlaceholder(),
                        )
                        : _buildItemPlaceholder(),
              ),
            ),
          ),

          // Item Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.poppins(
                      fontSize: _getResponsiveFontSize(12),
                      fontWeight: FontWeight.w600,
                      color: darkGray,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.category,
                      style: GoogleFonts.poppins(
                        fontSize: _getResponsiveFontSize(9),
                        fontWeight: FontWeight.w600,
                        color: primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Placeholder for items without images
  Widget _buildItemPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: primaryBlue.withValues(alpha: 0.1),
      child: Icon(
        Icons.checkroom_rounded,
        size: 32,
        color: primaryBlue.withValues(alpha: 0.5),
      ),
    );
  }

  // Message when no items are selected
  Widget _buildEmptyItemsMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: mediumGray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.checkroom_rounded, color: mediumGray, size: 48),
          const SizedBox(height: 12),
          Text(
            'No items selected',
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(14),
              fontWeight: FontWeight.w600,
              color: mediumGray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This outfit doesn\'t have any specific items selected',
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(12),
              color: mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

Color _getStatusColor() {
  switch (widget.outfitEvent.status) {
    case OutfitEventStatus.planned:
      return accentYellow;
    case OutfitEventStatus.emailSent:
      return Colors.green;
    case OutfitEventStatus.completed:
      return primaryBlue;
    case OutfitEventStatus.expired: // ✅ ADDED
      return mediumGray;
  }
}


String _getStatusText() {
  switch (widget.outfitEvent.status) {
    case OutfitEventStatus.planned:
      return 'Planned';
    case OutfitEventStatus.emailSent:
      return 'Reminder Sent';
    case OutfitEventStatus.completed:
      return 'Completed';
    case OutfitEventStatus.expired: // ✅ ADDED
      return 'Expired';
  }
}
}

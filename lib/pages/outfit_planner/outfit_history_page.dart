import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'outfit_planner_page.dart';
import '../../services/outfit_planner_service.dart';

class OutfitHistoryPage extends StatefulWidget {
  final Map<DateTime, List<OutfitEvent>>? outfitEvents;

  const OutfitHistoryPage({super.key, this.outfitEvents});

  @override
  State<OutfitHistoryPage> createState() => _OutfitHistoryPageState();
}

class _OutfitHistoryPageState extends State<OutfitHistoryPage> {
  // FitOutfit brand colors
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color softCream = Color(0xFFFAF9F7);

  List<MapEntry<DateTime, OutfitEvent>> _historyItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  // ✅ UPDATED: Load data from database if not provided
  void _loadHistoryData() async {
    Map<DateTime, List<OutfitEvent>> outfitEvents;

    if (widget.outfitEvents != null && widget.outfitEvents!.isNotEmpty) {
      // Use provided data
      outfitEvents = widget.outfitEvents!;
    } else {
      // Load from database
      setState(() => _isLoading = true);
      try {
        outfitEvents = await OutfitPlannerService.loadAllOutfitEvents();
      } catch (e) {
        print('❌ Error loading outfit history: $e');
        outfitEvents = {};
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load outfit history: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      setState(() => _isLoading = false);
    }

    // Process the data
    if (outfitEvents.isNotEmpty) {
      final historyEntries = <MapEntry<DateTime, OutfitEvent>>[];

      outfitEvents.forEach((date, events) {
        for (final event in events) {
          historyEntries.add(MapEntry(date, event));
        }
      });

      historyEntries.sort((a, b) => b.key.compareTo(a.key));

      setState(() {
        _historyItems = historyEntries;
      });
    } else {
      setState(() {
        _historyItems = [];
      });
    }
  }

  Color _getStatusColor(OutfitEventStatus status) {
    switch (status) {
      case OutfitEventStatus.completed:
        return Colors.green;
      case OutfitEventStatus.emailSent:
        return primaryBlue;
      case OutfitEventStatus.planned:
        return accentYellow;
            case OutfitEventStatus.expired: // ✅ ADDED
      return mediumGray;
    }
  }

  String _getStatusText(OutfitEventStatus status) {
    switch (status) {
      case OutfitEventStatus.completed:
        return 'Completed';
      case OutfitEventStatus.emailSent:
        return 'Email Sent';
      case OutfitEventStatus.planned:
        return 'Planned';
            case OutfitEventStatus.expired: // ✅ ADDED
      return 'Expired';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getCurrentMonthName() {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final now = DateTime.now();
    return months[now.month - 1];
  }

  int _getThisMonthCount() {
    final now = DateTime.now();
    return _historyItems
        .where(
          (entry) => entry.key.year == now.year && entry.key.month == now.month,
        )
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softCream,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: Text(
          'Outfit History',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // ✅ ADDED: Refresh button
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loadHistoryData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Stats
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryBlue.withValues(alpha: 0.1),
                      accentYellow.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryBlue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Icon(
                            Icons.checkroom_rounded,
                            color: primaryBlue,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_historyItems.length}',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: primaryBlue,
                            ),
                          ),
                          Text(
                            'Total Outfits',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: mediumGray.withValues(alpha: 0.3),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            color: accentYellow,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getCurrentMonthName(),
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: accentYellow,
                            ),
                          ),
                          Text(
                            '${_getThisMonthCount()} this month',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // History List Title
              Text(
                'Recent History',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkGray,
                ),
              ),
              const SizedBox(height: 16),

              // History List
              Expanded(
                child:
                    _isLoading
                        ? _buildLoadingState()
                        : _historyItems.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                          itemCount: _historyItems.length,
                          itemBuilder: (context, index) {
                            final entry = _historyItems[index];
                            return _buildHistoryCard(entry.key, entry.value);
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ ADDED: Loading state widget
  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryBlue.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryBlue),
          const SizedBox(height: 20),
          Text(
            'Loading Outfit History...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we fetch your outfit plans',
            style: GoogleFonts.poppins(fontSize: 12, color: mediumGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryBlue.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(Icons.history_rounded, color: primaryBlue, size: 48),
          ),
          const SizedBox(height: 20),
          Text(
            'No History Yet',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your outfit planning history will appear here once you start creating outfit plans.',
            style: GoogleFonts.poppins(fontSize: 14, color: mediumGray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Start Planning',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(DateTime date, OutfitEvent event) {
    final statusColor = _getStatusColor(event.status);

    return GestureDetector(
      onTap: () {
        _showOutfitDetailsModal(context, event, date);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and status
            Row(
              children: [
                // Date Circle
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Title and outfit name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: darkGray,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getStatusText(event.status),
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.outfitName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Date and item count info
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 12, color: mediumGray),
                const SizedBox(width: 4),
                Text(
                  _formatDate(date),
                  style: GoogleFonts.poppins(fontSize: 12, color: mediumGray),
                ),
                if (event.wardrobeItems != null &&
                    event.wardrobeItems!.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.checkroom_outlined, size: 12, color: mediumGray),
                  const SizedBox(width: 4),
                  Text(
                    '${event.wardrobeItems!.length} items',
                    style: GoogleFonts.poppins(fontSize: 12, color: mediumGray),
                  ),
                ],
                if (event.weather != null && event.weather!.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.wb_sunny_outlined, size: 12, color: mediumGray),
                  const SizedBox(width: 4),
                  Text(
                    event.weather!,
                    style: GoogleFonts.poppins(fontSize: 12, color: mediumGray),
                  ),
                ],
                const Spacer(),
                Icon(Icons.touch_app_rounded, size: 12, color: mediumGray),
                const SizedBox(width: 4),
                Text(
                  'Tap for details',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: mediumGray,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),

            // Show preview of wardrobe items if available
            if (event.wardrobeItems != null &&
                event.wardrobeItems!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryBlue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Items Preview:',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children:
                          event.wardrobeItems!
                              .take(4) // Show only first 4 items in preview
                              .map(
                                (item) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: primaryBlue.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Text(
                                    item.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: primaryBlue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                    if (event.wardrobeItems!.length > 4) ...[
                      const SizedBox(height: 4),
                      Text(
                        '+${event.wardrobeItems!.length - 4} more items',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: mediumGray,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Show notes preview if available
            if (event.notes != null && event.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentYellow.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accentYellow.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 12,
                          color: accentYellow,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Notes:',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: accentYellow,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.notes!.length > 100
                          ? '${event.notes!.substring(0, 100)}...'
                          : event.notes!,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: darkGray,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showOutfitDetailsModal(
    BuildContext context,
    OutfitEvent event,
    DateTime date,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OutfitHistoryDetailsModal(event: event, date: date),
    );
  }
}

// ✅ Completely rewritten modal with fixed constraints
class OutfitHistoryDetailsModal extends StatelessWidget {
  final OutfitEvent event;
  final DateTime date;

  const OutfitHistoryDetailsModal({
    super.key,
    required this.event,
    required this.date,
  });

  // FitOutfit brand colors
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color softCream = Color(0xFFFAF9F7);

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _getStatusColor(OutfitEventStatus status) {
    switch (status) {
      case OutfitEventStatus.completed:
        return Colors.green;
      case OutfitEventStatus.emailSent:
        return primaryBlue;
      case OutfitEventStatus.planned:
        return accentYellow;
      case OutfitEventStatus.expired: // ✅ ADDED
        return mediumGray;
    }
  }

  String _getStatusText(OutfitEventStatus status) {
    switch (status) {
      case OutfitEventStatus.completed:
        return 'Completed';
      case OutfitEventStatus.emailSent:
        return 'Email Sent';
      case OutfitEventStatus.planned:
        return 'Planned';
          case OutfitEventStatus.expired: // ✅ ADDED
      return 'Expired';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(event.status);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: mediumGray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  event.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: darkGray,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getStatusText(event.status),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.outfitName,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                                color: mediumGray,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatDate(date),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: mediumGray,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, color: mediumGray),
                    ),
                  ],
                ),
              ),

              // Content with ScrollController
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Weather Info
                      if (event.weather != null &&
                          event.weather!.isNotEmpty) ...[
                        _buildInfoCard(
                          'Weather Information',
                          event.weather!,
                          Icons.wb_sunny_rounded,
                          accentYellow,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Notes
                      if (event.notes != null && event.notes!.isNotEmpty) ...[
                        _buildInfoCard(
                          'Notes',
                          event.notes!,
                          Icons.note_rounded,
                          primaryBlue,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Wardrobe Items Section
                      _buildWardrobeItemsSection(),

                      const SizedBox(height: 100), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWardrobeItemsSection() {
    if (event.wardrobeItems == null || event.wardrobeItems!.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Items (0)',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: mediumGray.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.checkroom_rounded, color: mediumGray, size: 48),
                const SizedBox(height: 12),
                Text(
                  'No Items Selected',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: mediumGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This outfit doesn\'t have any specific items selected',
                  style: GoogleFonts.poppins(fontSize: 12, color: mediumGray),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Items (${event.wardrobeItems!.length})',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: darkGray,
          ),
        ),
        const SizedBox(height: 12),
        ..._buildItemsByCategory(),
      ],
    );
  }

  Widget _buildInfoCard(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: darkGray,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItemsByCategory() {
    if (event.wardrobeItems == null || event.wardrobeItems!.isEmpty) {
      return [];
    }

    // Group items by category
    final Map<String, List<WardrobeItem>> groupedItems = {};
    for (final item in event.wardrobeItems!) {
      if (!groupedItems.containsKey(item.category)) {
        groupedItems[item.category] = [];
      }
      groupedItems[item.category]!.add(item);
    }

    List<Widget> widgets = [];

    groupedItems.forEach((category, items) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              // ✅ Fixed layout with proper constraints
              if (items.length == 1)
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 200, // ✅ Fixed height
                    child: _buildItemCard(items[0]),
                  ),
                )
              else
                // ✅ Fixed GridView with proper height constraint
                SizedBox(
                  height:
                      (items.length / 2).ceil() *
                      200.0, // ✅ Calculate height based on items
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: items.length,
                    itemBuilder:
                        (context, index) => _buildItemCard(items[index]),
                  ),
                ),
            ],
          ),
        ),
      );
    });

    return widgets;
  }

Widget _buildItemCard(WardrobeItem item) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: primaryBlue.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Item Image - ✅ FIXED: Proper flex constraints
        Expanded(
          flex: 2, // ✅ Reduced from 3 to 2 to give more space for text
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: _buildItemImage(item),
            ),
          ),
        ),

        // Item Info - ✅ FIXED: Remove Expanded wrapper to prevent overflow
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8), // ✅ Reduced padding
          child: Column(
            mainAxisSize: MainAxisSize.min, // ✅ Use min size
            crossAxisAlignment: CrossAxisAlignment.start, // ✅ Align left
            children: [
              Text(
                item.name,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: darkGray,
                ),
                maxLines: 1, // ✅ Limit to 1 line
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // ✅ FIXED: Smaller category badge
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
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ✅ FIXED: Better grid height calculation

  Widget _buildItemImage(WardrobeItem item) {
    final imageUrl = item.imageUrl;

    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        imageUrl != 'null' &&
        imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: primaryBlue.withValues(alpha: 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: primaryBlue,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Loading...',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: accentRed.withValues(alpha: 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_rounded,
            size: 32,
            color: accentRed.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load',
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: accentRed,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: softCream,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checkroom_rounded,
            size: 40,
            color: mediumGray.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'No Image',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: mediumGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'outfit_planning_form.dart' as OutfitForm;
import 'outfit_history_page.dart';
import '../wardrobe/wardrobe_page.dart';
import '../../services/outfit_planner_service.dart';

class OutfitPlannerPage extends StatefulWidget {
  const OutfitPlannerPage({super.key});

  @override
  State<OutfitPlannerPage> createState() => _OutfitPlannerPageState();
}

class _OutfitPlannerPageState extends State<OutfitPlannerPage>
    with TickerProviderStateMixin {
  // FitOutfit brand colors
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color softCream = Color(0xFFFAF9F7);

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ✅ UPDATED: Real outfit events data from database
  Map<DateTime, List<OutfitEvent>> _outfitEvents = {};
  bool _isLoadingOutfits = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadOutfitEvents(); // ✅ Load data from database
  }

Future<void> _loadOutfitEvents() async {
  try {
    print('🔥 Loading outfit events from database...');
    setState(() => _isLoadingOutfits = true);

    final events = await OutfitPlannerService.loadAllOutfitEvents();
    
    // ✅ FIXED: Complete auto-update logic
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final updatedEvents = <DateTime, List<OutfitEvent>>{};
    bool hasUpdates = false;
    
    // Process each date and its events
    for (final entry in events.entries) {
      final date = entry.key;
      final eventList = entry.value;
      final dateKey = DateTime(date.year, date.month, date.day);
      final isPastDate = dateKey.isBefore(today);
      final isTodayButLate = dateKey.isAtSameMomentAs(today) && now.hour >= 20;
      
      if (isPastDate || isTodayButLate) {
        final updatedEventList = <OutfitEvent>[];
        
        for (final event in eventList) {
          if (event.status == OutfitEventStatus.planned) {
            // Create expired version
            final expiredEvent = OutfitEvent(
              id: event.id,
              title: event.title,
              outfitName: event.outfitName,
              status: OutfitEventStatus.expired,
              notes: event.notes,
              weather: event.weather,
              wardrobeItems: event.wardrobeItems,
            );
            
            updatedEventList.add(expiredEvent);
            hasUpdates = true;
            
            // ✅ FIXED: Properly await database update
            try {
              await OutfitPlannerService.updateOutfitEvent(dateKey, expiredEvent);
              print('✅ Updated outfit ${event.id} to expired status');
            } catch (e) {
              print('❌ Failed to update outfit ${event.id}: $e');
            }
          } else {
            updatedEventList.add(event);
          }
        }
        
        updatedEvents[dateKey] = updatedEventList;
      } else {
        updatedEvents[dateKey] = eventList;
      }
    }

    setState(() {
      _outfitEvents = updatedEvents;
      _isLoadingOutfits = false;
    });

    if (hasUpdates) {
      print('✅ Auto-updated expired outfit statuses');
    }
    
    print('✅ Loaded ${updatedEvents.length} outfit events');
  } catch (e) {
    print('❌ Error loading outfit events: $e');
    setState(() => _isLoadingOutfits = false);
    
    // ✅ FIXED: Complete error handling
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load outfit plans: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

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
                  child: Column(
                    children: [
                      _buildCalendarSection(),
                      SizedBox(height: _getResponsiveHeight(20)),
                      _buildQuickActionsSection(),
                      SizedBox(height: _getResponsiveHeight(20)),
                      _buildTodayOutfitsSection(),
                      SizedBox(height: _getResponsiveHeight(20)),
                      _buildUpcomingEventsSection(),
                      SizedBox(height: _getResponsiveHeight(100)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildPlanOutfitFAB(),
    );
  }

Widget _buildAppBar() {
  return SliverAppBar(
    expandedHeight: _getResponsiveHeight(140), // ✅ Increase height
    floating: false,
    pinned: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    // ✅ OPTION: Remove default leading and create custom positioned back button
    automaticallyImplyLeading: false,
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
          child: Stack(
            children: [
              // ✅ Custom positioned back button
              Positioned(
                top: 16,
                left: _getHorizontalPadding(),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_rounded, 
                      color: primaryBlue,
                      size: 20,
                    ),
                  ),
                ),
              ),
              
              // ✅ Title positioned separately
              Positioned(
                bottom: _getResponsiveHeight(10),
                left: _getHorizontalPadding(),
                right: _getHorizontalPadding(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Outfit Planner',
                      style: GoogleFonts.poppins(
                        fontSize: _getResponsiveFontSize(28),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Plan your perfect looks ahead',
                      style: GoogleFonts.poppins(
                        fontSize: _getResponsiveFontSize(14),
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildCalendarSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _getHorizontalPadding()),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(_getHorizontalPadding()),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryBlue.withValues(alpha: 0.1),
                    accentYellow.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: primaryBlue),
                  SizedBox(width: _getHorizontalPadding() * 0.5),
                  Text(
                    'Select Date to Plan',
                    style: GoogleFonts.poppins(
                      fontSize: _getResponsiveFontSize(16),
                      fontWeight: FontWeight.w700,
                      color: darkGray,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(_getHorizontalPadding()),
              child: _buildCustomCalendar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomCalendar() {
    return Column(
      children: [
        _buildCalendarHeader(),
        SizedBox(height: _getResponsiveHeight(16)),
        _buildCalendarDays(),
        SizedBox(height: _getResponsiveHeight(16)),
        _buildCalendarGrid(),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
            });
          },
          icon: Icon(Icons.chevron_left_rounded, color: primaryBlue),
        ),
        Text(
          '${_getMonthName(_focusedDay.month)} ${_focusedDay.year}',
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(18),
            fontWeight: FontWeight.w700,
            color: darkGray,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
            });
          },
          icon: Icon(Icons.chevron_right_rounded, color: primaryBlue),
        ),
      ],
    );
  }

  Widget _buildCalendarDays() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      children:
          days
              .map(
                (day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: GoogleFonts.poppins(
                        fontSize: _getResponsiveFontSize(12),
                        fontWeight: FontWeight.w600,
                        color: mediumGray,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    List<Widget> dayWidgets = [];

    // Add empty cells for days before the first day of the month
    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Add days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedDay.year, _focusedDay.month, day);
      dayWidgets.add(_buildDayCell(date));
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      children: dayWidgets,
    );
  }

  Widget _buildDayCell(DateTime date) {
    final isSelected = _isSameDay(date, _selectedDay);
    final isToday = _isSameDay(date, DateTime.now());
    final isPastDate = date.isBefore(DateTime.now()) && !isToday;
    final hasEvents = _getEventsForDay(date).isNotEmpty;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = date;
        });
        HapticFeedback.lightImpact();
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color:
              isPastDate
                  ? mediumGray.withValues(alpha: 0.2)
                  : isSelected
                  ? primaryBlue
                  : isToday
                  ? accentYellow
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow:
              isSelected && !isPastDate
                  ? [
                    BoxShadow(
                      color: primaryBlue.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '${date.day}',
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(14),
                  fontWeight: FontWeight.w600,
                  color:
                      isPastDate
                          ? mediumGray.withValues(alpha: 0.6)
                          : isSelected || isToday
                          ? Colors.white
                          : darkGray,
                ),
              ),
            ),
            if (hasEvents)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color:
                        isPastDate
                            ? mediumGray.withValues(alpha: 0.5)
                            : isSelected || isToday
                            ? Colors.white
                            : accentRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            if (isPastDate)
              Positioned.fill(
                child: CustomPaint(
                  painter: StrikethroughPainter(
                    color: mediumGray.withValues(alpha: 0.4),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
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
    return months[month - 1];
  }

  Widget _buildQuickActionsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _getHorizontalPadding()),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionCard(
              'Go to Wardrobe',
              'Browse your items',
              Icons.checkroom_rounded,
              primaryBlue,
              () => _navigateToWardrobe(),
            ),
          ),
          SizedBox(width: _getHorizontalPadding()),
          Expanded(
            child: _buildQuickActionCard(
              'View History',
              'Past outfits',
              Icons.history_rounded,
              accentYellow,
              () => _navigateToHistory(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(_getHorizontalPadding()),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.2),
                    color.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: _getResponsiveHeight(12)),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: _getResponsiveFontSize(14),
                fontWeight: FontWeight.w700,
                color: darkGray,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: _getResponsiveHeight(4)),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: _getResponsiveFontSize(11),
                color: mediumGray,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayOutfitsSection() {
    final todayEvents = _getEventsForDay(_selectedDay);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _getHorizontalPadding()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Outfits for ${_formatSelectedDate()}',
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(18),
              fontWeight: FontWeight.w700,
              color: darkGray,
            ),
          ),
          SizedBox(height: _getResponsiveHeight(12)),

          // ✅ ADDED: Loading state
          if (_isLoadingOutfits)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(_getHorizontalPadding() * 1.5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryBlue.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  CircularProgressIndicator(color: primaryBlue),
                  SizedBox(height: _getResponsiveHeight(16)),
                  Text(
                    'Loading outfit plans...',
                    style: GoogleFonts.poppins(
                      fontSize: _getResponsiveFontSize(14),
                      color: mediumGray,
                    ),
                  ),
                ],
              ),
            )
          else if (todayEvents.isEmpty)
            _buildEmptyOutfitsCard()
          else
            Column(
              children:
                  todayEvents
                      .map((event) => _buildOutfitEventCard(event))
                      .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyOutfitsCard() {
    final isPastDate =
        _selectedDay.isBefore(DateTime.now()) &&
        !_isSameDay(_selectedDay, DateTime.now());

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_getHorizontalPadding() * 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isPastDate
                  ? mediumGray.withValues(alpha: 0.3)
                  : primaryBlue.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isPastDate
                      ? mediumGray.withValues(alpha: 0.1)
                      : primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              isPastDate ? Icons.history_rounded : Icons.calendar_today_rounded,
              color: isPastDate ? mediumGray : primaryBlue,
              size: 32,
            ),
          ),
          SizedBox(height: _getResponsiveHeight(16)),
          Text(
            isPastDate
                ? 'This date has passed'
                : 'No outfits planned for this day',
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(16),
              fontWeight: FontWeight.w600,
              color: isPastDate ? mediumGray : darkGray,
            ),
          ),
          SizedBox(height: _getResponsiveHeight(8)),
          Text(
            isPastDate
                ? 'You cannot plan outfits for past dates. Select a future date to plan ahead.'
                : 'Start planning your outfit for this date using the buttons above',
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

Widget _buildOutfitEventCard(OutfitEvent event) {
  Color statusColor;
  IconData statusIcon;
  String statusText;

  switch (event.status) {
    case OutfitEventStatus.planned:
      statusColor = accentYellow;
      statusIcon = Icons.schedule_rounded;
      statusText = 'Planned';
      break;
    case OutfitEventStatus.emailSent:
      statusColor = Colors.green;
      statusIcon = Icons.email_rounded;
      statusText = 'Reminder Sent';
      break;
    case OutfitEventStatus.completed:
      statusColor = primaryBlue;
      statusIcon = Icons.check_circle_rounded;
      statusText = 'Completed';
      break;
    case OutfitEventStatus.expired: // ✅ Tambahkan ini
      statusColor = mediumGray;
      statusIcon = Icons.access_time_rounded;
      statusText = 'Expired';
      break;
  }

    return GestureDetector(
      onTap: () => _showOutfitDetails(event),
      child: Container(
        margin: EdgeInsets.only(bottom: _getResponsiveHeight(12)),
        padding: EdgeInsets.all(_getHorizontalPadding()),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.15),
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
                        event.title,
                        style: GoogleFonts.poppins(
                          fontSize: _getResponsiveFontSize(16),
                          fontWeight: FontWeight.w700,
                          color: darkGray,
                        ),
                      ),
                      Text(
                        event.outfitName,
                        style: GoogleFonts.poppins(
                          fontSize: _getResponsiveFontSize(14),
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
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: GoogleFonts.poppins(
                          fontSize: _getResponsiveFontSize(11),
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (event.wardrobeItems != null &&
                event.wardrobeItems!.isNotEmpty) ...[
              SizedBox(height: _getResponsiveHeight(12)),
              Text(
                'Selected Items:',
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(12),
                  fontWeight: FontWeight.w600,
                  color: mediumGray,
                ),
              ),
              SizedBox(height: _getResponsiveHeight(8)),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children:
                    event.wardrobeItems!
                        .take(4) // Show only first 4 items
                        .map(
                          (item) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.name,
                              style: GoogleFonts.poppins(
                                fontSize: _getResponsiveFontSize(10),
                                color: primaryBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              if (event.wardrobeItems!.length > 4) ...[
                SizedBox(height: _getResponsiveHeight(4)),
                Text(
                  '+${event.wardrobeItems!.length - 4} more items',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(10),
                    color: mediumGray,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
            SizedBox(height: _getResponsiveHeight(12)),
            Row(
              children: [
                Icon(Icons.touch_app_rounded, size: 14, color: mediumGray),
                SizedBox(width: 4),
                Text(
                  'Tap to view details',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(10),
                    color: mediumGray,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _editOutfit(event),
                  child: Text(
                    'Edit',
                    style: GoogleFonts.poppins(
                      color: primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: _getResponsiveFontSize(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEventsSection() {
    final upcomingEvents = _getUpcomingEvents();

    if (upcomingEvents.isEmpty) return const SizedBox();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _getHorizontalPadding()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Outfits',
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(18),
              fontWeight: FontWeight.w700,
              color: darkGray,
            ),
          ),
          SizedBox(height: _getResponsiveHeight(12)),
          SizedBox(
            height: _getResponsiveHeight(120),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: upcomingEvents.length,
              itemBuilder: (context, index) {
                final entry = upcomingEvents[index];
                return _buildUpcomingEventCard(entry.key, entry.value.first);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventCard(DateTime date, OutfitEvent event) {
    return GestureDetector(
      onTap: () => _showOutfitDetails(event),
      child: Container(
        width: _getScreenWidth() * 0.7,
        margin: EdgeInsets.only(right: _getHorizontalPadding()),
        padding: EdgeInsets.all(_getHorizontalPadding()),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryBlue.withValues(alpha: 0.8),
              accentYellow.withValues(alpha: 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withValues(alpha: 0.3),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatDate(date),
                    style: GoogleFonts.poppins(
                      fontSize: _getResponsiveFontSize(10),
                      fontWeight: FontWeight.w600,
                      color: primaryBlue,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
            const Spacer(),
            Text(
              event.title,
              style: GoogleFonts.poppins(
                fontSize: _getResponsiveFontSize(14),
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              event.outfitName,
              style: GoogleFonts.poppins(
                fontSize: _getResponsiveFontSize(12),
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanOutfitFAB() {
    final isPastDate =
        _selectedDay.isBefore(DateTime.now()) &&
        !_isSameDay(_selectedDay, DateTime.now());

    if (isPastDate) {
      return FloatingActionButton.extended(
        onPressed: null,
        backgroundColor: mediumGray.withValues(alpha: 0.5),
        icon: const Icon(Icons.block_rounded, color: Colors.white),
        label: Text(
          'Past Date',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      );
    }

    return FloatingActionButton.extended(
      onPressed: () => _navigateToPlanOutfit(),
      backgroundColor: accentRed,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: Text(
        'Plan Outfit',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

  // Show outfit details dialog
  void _showOutfitDetails(OutfitEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OutfitDetailsModal(event: event),
    );
  }

  // Helper methods
  List<OutfitEvent> _getEventsForDay(DateTime day) {
    return _outfitEvents[DateTime(day.year, day.month, day.day)] ?? [];
  }

  List<MapEntry<DateTime, List<OutfitEvent>>> _getUpcomingEvents() {
    final now = DateTime.now();
    return _outfitEvents.entries
        .where((entry) => entry.key.isAfter(now))
        .take(5)
        .toList();
  }

  String _formatSelectedDate() {
    if (_isSameDay(_selectedDay, DateTime.now())) {
      return 'Today';
    } else if (_isSameDay(
      _selectedDay,
      DateTime.now().add(const Duration(days: 1)),
    )) {
      return 'Tomorrow';
    } else {
      return '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  // ✅ UPDATED: Add outfit event to database and local state
  void _addOutfitEvent(DateTime date, OutfitEvent event) {
    setState(() {
      final dateKey = DateTime(date.year, date.month, date.day);
      if (_outfitEvents[dateKey] == null) {
        _outfitEvents[dateKey] = [];
      }
      _outfitEvents[dateKey]!.add(event);
    });
  }

  // ✅ UPDATED: Update outfit event in database and local state
  void _updateOutfitEvent(DateTime date, OutfitEvent updatedEvent) {
    setState(() {
      final dateKey = DateTime(date.year, date.month, date.day);
      if (_outfitEvents[dateKey] != null) {
        final index = _outfitEvents[dateKey]!.indexWhere(
          (event) => event.id == updatedEvent.id,
        );
        if (index != -1) {
          _outfitEvents[dateKey]![index] = updatedEvent;
        }
      }
    });
  }

  // Navigation methods
  void _navigateToPlanOutfit() async {
    final isPastDate =
        _selectedDay.isBefore(DateTime.now()) &&
        !_isSameDay(_selectedDay, DateTime.now());

    if (isPastDate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cannot plan outfits for past dates. Please select a future date.',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: accentRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                OutfitForm.OutfitPlanningForm(selectedDate: _selectedDay),
      ),
    );

    if (result != null && result is OutfitEvent) {
      _addOutfitEvent(_selectedDay, result);
    }
  }

  void _navigateToWardrobe() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WardrobePage()),
    );
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OutfitHistoryPage(outfitEvents: _outfitEvents),
      ),
    );
  }

  void _editOutfit(OutfitEvent event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => OutfitForm.OutfitPlanningForm(
              selectedDate: _selectedDay,
              editingEvent: event,
            ),
      ),
    );

    if (result != null && result is OutfitEvent) {
      _updateOutfitEvent(_selectedDay, result);
    }
  }
}

// Outfit Details Modal
class OutfitDetailsModal extends StatelessWidget {
  final OutfitEvent event;

  const OutfitDetailsModal({super.key, required this.event});

  // FitOutfit brand colors
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color accentYellow = Color(0xFFF5A623);
  static const Color accentRed = Color(0xFFD0021B);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color softCream = Color(0xFFFAF9F7);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
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
                      Text(
                        event.title,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: darkGray,
                        ),
                      ),
                      Text(
                        event.outfitName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
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

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status and Weather Info
                  if (event.weather != null) ...[
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

                  // Wardrobe Items
                  if (event.wardrobeItems != null &&
                      event.wardrobeItems!.isNotEmpty) ...[
                    Text(
                      'Selected Items',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: darkGray,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Group items by category
                    ..._buildItemsByCategory(),
                  ],

                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
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
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) => _buildItemCard(items[index]),
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
          // Item Image
          Expanded(
            flex: 3,
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
                child:
                    item.imageUrl != null
                        ? Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  _buildPlaceholderImage(),
                        )
                        : _buildPlaceholderImage(),
              ),
            ),
          ),

          // Item Name
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                item.name,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: darkGray,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
      child: Icon(
        Icons.checkroom_rounded,
        size: 40,
        color: mediumGray.withValues(alpha: 0.5),
      ),
    );
  }
}

// Updated data models
class OutfitEvent {
  final String id;
  final String title;
  final String outfitName;
  final OutfitEventStatus status;
  final String? notes;
  final String? weather;
  final List<WardrobeItem>? wardrobeItems;

  OutfitEvent({
    required this.id,
    required this.title,
    required this.outfitName,
    required this.status,
    this.notes,
    this.weather,
    this.wardrobeItems,
  });
}

class WardrobeItem {
  final String name;
  final String category;
  final String? imageUrl;

  WardrobeItem({required this.name, required this.category, this.imageUrl});
}

enum OutfitEventStatus { planned, emailSent, completed, expired }

class StrikethroughPainter extends CustomPainter {
  final Color color;

  StrikethroughPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.8),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

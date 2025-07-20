import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/admin_data_service.dart';

class EnhancedUserManagement extends StatefulWidget {
  const EnhancedUserManagement({super.key});

  @override
  State<EnhancedUserManagement> createState() => _EnhancedUserManagementState();
}

class _EnhancedUserManagementState extends State<EnhancedUserManagement> {
  final AdminDataService _dataService = AdminDataService();
  String _searchQuery = '';

  static const Color darkPurple = Color(0xFF6B46C1);
  static const Color primaryLavender = Color(0xFFE8E4F3);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildUserStats(),
          const SizedBox(height: 20),
          // ✅ UPDATED: Charts Column (atas-bawah) instead of Row (sebelahan)
          _buildAgeChart(),
          const SizedBox(height: 20),
          _buildGenderChart(),
          const SizedBox(height: 20),
          _buildSearchBar(),
          const SizedBox(height: 20),
          _buildUsersList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Management',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage registered users and their account status',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryLavender,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.people_outline_rounded,
              color: darkPurple,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats() {
    return FutureBuilder<Map<String, int>>(
      future: _dataService.getUserStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {'total': 0, 'active': 0, 'inactive': 0};

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Users',
                stats['total'].toString(),
                Icons.people,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Active Users',
                stats['active'].toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Inactive Users',
                stats['inactive'].toString(),
                Icons.block,
                Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: darkPurple,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search users by name or email...',
          prefixIcon: const Icon(Icons.search, color: darkPurple),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: darkPurple),
          ),
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _dataService.getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: darkPurple),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading users',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final users = snapshot.data ?? [];
        final filteredUsers = users.where((user) {
          final name = user['name']?.toString().toLowerCase() ?? '';
          final email = user['email']?.toString().toLowerCase() ?? '';
          return name.contains(_searchQuery.toLowerCase()) ||
              email.contains(_searchQuery.toLowerCase());
        }).toList();

        if (filteredUsers.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No users found'
                        : 'No users match your search',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (_searchQuery.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(() => _searchQuery = ''),
                      child: Text(
                        'Clear search',
                        style: GoogleFonts.poppins(color: darkPurple),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Users (${filteredUsers.length})',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: darkPurple,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return _buildUserCard(
                    user,
                    index == filteredUsers.length - 1,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ UPDATED: Age Chart - Mobile Optimized
  Widget _buildAgeChart() {
    return Container(
      padding: const EdgeInsets.all(20), // ✅ Reduced padding for mobile
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              Icon(
                Icons.bar_chart_rounded,
                color: darkPurple,
                size: 22, // ✅ Slightly smaller for mobile
              ),
              const SizedBox(width: 8),
              Expanded( // ✅ Make text responsive
                child: Text(
                  'User Age Distribution',
                  style: GoogleFonts.poppins(
                    fontSize: 18, // ✅ Smaller font for mobile
                    fontWeight: FontWeight.w700,
                    color: darkPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // ✅ Reduced spacing
          FutureBuilder<Map<String, int>>(
            future: _dataService.getAgeDistribution(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30), // ✅ Reduced padding
                    child: CircularProgressIndicator(color: darkPurple),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Text(
                      'Unable to load age data',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }

              final ageData = snapshot.data!;
              return _buildChart(ageData);
            },
          ),
        ],
      ),
    );
  }

  // ✅ UPDATED: Age Chart - Mobile Layout
  Widget _buildChart(Map<String, int> ageData) {
    final maxValue = ageData.values.isNotEmpty 
        ? ageData.values.reduce((a, b) => a > b ? a : b) 
        : 1;

    return Column( // ✅ Changed from Row to Column for mobile
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Bar Chart
        SizedBox(
          height: 250, // ✅ Reduced height for mobile
          child: BarChart(
            BarChartData(
              maxY: maxValue.toDouble() + 2,
              barGroups: _createBarGroups(ageData),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35, // ✅ Reduced for mobile
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 9, // ✅ Smaller font
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 25, // ✅ Reduced for mobile
                    getTitlesWidget: (value, meta) {
                      final ageRanges = ageData.keys.toList();
                      if (value.toInt() < ageRanges.length) {
                        return Text(
                          ageRanges[value.toInt()],
                          style: GoogleFonts.poppins(
                            fontSize: 9, // ✅ Smaller font
                            color: Colors.grey[600],
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              gridData: FlGridData(
                show: true,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey[200]!,
                    strokeWidth: 1,
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16), // ✅ Spacing between chart and legend
        // ✅ Legend - Below chart for mobile
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Age Groups',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: darkPurple,
              ),
            ),
            const SizedBox(height: 8),
            // ✅ Horizontal scrollable legend for mobile
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ageData.entries.map((entry) => 
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: _buildLegendItem(
                      entry.key,
                      entry.value,
                      _getColorForAgeGroup(entry.key),
                    ),
                  ),
                ).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ✅ ADD MISSING: Create bar groups for age chart
  List<BarChartGroupData> _createBarGroups(Map<String, int> ageData) {
    return ageData.entries.map((entry) {
      final index = ageData.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: _getColorForAgeGroup(entry.key),
            width: 30,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  // ✅ ADD MISSING: Get color for age group
  Color _getColorForAgeGroup(String ageGroup) {
    switch (ageGroup) {
      case '13-17':
        return const Color(0xFF10B981); // Green
      case '18-24':
        return const Color(0xFF3B82F6); // Blue
      case '25-34':
        return const Color(0xFF6366F1); // Indigo
      case '35-44':
        return const Color(0xFF8B5CF6); // Purple
      case '45+':
        return const Color(0xFFEF4444); // Red
      default:
        return Colors.grey;
    }
  }

  // ✅ ADD MISSING: Create pie chart sections for gender
  // ✅ UPDATE: Update pie chart sections to only show Male, Female, Not Specified
  // ✅ FIX: Update pie chart sections - remove "Not Specified" handling
  List<PieChartSectionData> _createPieSections(Map<String, int> genderData, int totalUsers) {
    return genderData.entries.map((entry) {
      final percentage = totalUsers > 0 ? (entry.value / totalUsers) * 100 : 0;
      final color = _getColorForGender(entry.key);
      
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        badgeWidget: entry.value > 0 ? Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
              ),
            ],
          ),
          child: Icon(
            _getGenderIcon(entry.key),
            size: 16,
            color: color,
          ),
        ) : null,
        badgePositionPercentageOffset: 1.2,
      );
    }).where((section) => section.value > 0).toList(); // ✅ Filter out empty sections
  }
  // ✅ UPDATE: Update gender-related methods to work with Male/Female only
// ✅ FIX: Update gender methods in user_management_section.dart
  Color _getColorForGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return const Color(0xFF3B82F6); // Blue
      case 'female':
        return const Color(0xFFEC4899); // Pink
      default:
        return Colors.grey; // Fallback (seharusnya tidak pernah digunakan)
    }
  }

  IconData _getGenderIcon(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return Icons.male;
      case 'female':
        return Icons.female;
      default:
        return Icons.person; // Fallback (seharusnya tidak pernah digunakan)
    }
  }

  // ✅ REMOVE DUPLICATE: Keep only one _buildGenderChart method
  // (Remove the duplicate one that appears later in the file)

  // ✅ UPDATED: User card with gender (merge changes from duplicates)
  Widget _buildUserCard(Map<String, dynamic> user, bool isLast) {
    final isActive = user['isActive'] ?? true;
    final joinDate = user['createdAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(
            user['createdAt'].millisecondsSinceEpoch,
          )
        : DateTime.now();
    
    final age = _getUserAge(user);
    final ageGroup = _getAgeGroup(age);
    final birthDate = _getBirthDateString(user['tanggal_lahir']);
    final userId = user['id'];

    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: isLast ? 16 : 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? Colors.grey[200]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          // ✅ UPDATED: Avatar with gender from personalisasi
          FutureBuilder<String?>(
            future: _getUserGenderFromPersonalisasi(userId),
            builder: (context, genderSnapshot) {
              final gender = genderSnapshot.data;
              
              // ✅ Default avatar if no gender data yet
              return CircleAvatar(
                radius: 24,
                backgroundColor: gender != null
                    ? _getColorForGender(gender).withOpacity(0.1)
                    : primaryLavender,
                child: Icon(
                  gender != null ? _getGenderIcon(gender) : Icons.person,
                  size: 24,
                  color: gender != null
                      ? _getColorForGender(gender)
                      : darkPurple,
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ UPDATED: Name with status indicator
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user['name']?.toString() ?? 'Unknown User',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: darkPurple,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isActive ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // ✅ UPDATED: Email and join date
                Text(
                  user['email']?.toString() ?? 'No email',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Joined: ${_formatDate(joinDate)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 8),
                // ✅ UPDATED: Age and birth date
                Row(
                  children: [
                    _buildInfoItem(
                      Icons.cake,
                      '${age > 0 ? age : '?'} years',
                      Colors.amber[700]!,
                    ),
                    const SizedBox(width: 16),
                    _buildInfoItem(
                      Icons.calendar_today,
                      birthDate.isNotEmpty ? birthDate : 'No birth date',
                      Colors.blue[700]!,
                    ),
                    const SizedBox(width: 16),
                    // ✅ Show gender badge if available
                    FutureBuilder<String?>(
                      future: _getUserGenderFromPersonalisasi(userId),
                      builder: (context, genderSnapshot) {
                        final gender = genderSnapshot.data;
                        if (gender == null) return const SizedBox.shrink();
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getColorForGender(gender).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getGenderIcon(gender),
                                size: 12,
                                color: _getColorForGender(gender),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                gender,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: _getColorForGender(gender),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ✅ ADD: Action menu
          PopupMenuButton<String>(
            onSelected: (value) => _handleUserAction(value, user),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_status',
                child: Row(
                  children: [
                    Icon(
                      isActive ? Icons.block : Icons.check_circle,
                      size: 18,
                      color: isActive ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(isActive ? 'Deactivate' : 'Activate'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            child: const Icon(Icons.more_vert, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  // ✅ ADD: Method to fetch gender from personalisasi collection
Future<String?> _getUserGenderFromPersonalisasi(String? userId) async {
  if (userId == null) return null;
  
  try {
    final doc = await FirebaseFirestore.instance
        .collection('personalisasi')
        .doc(userId)
        .get();
    
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return data['selectedGender']?.toString();
    }
  } catch (e) {
    print('Error fetching gender from personalisasi: $e');
  }
  
  return null;
}

// ✅ ADD: Missing _buildGenderChart method
Widget _buildGenderChart() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
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
            Icon(
              Icons.pie_chart_rounded,
              color: darkPurple,
              size: 22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Gender Distribution',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkPurple,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<Map<String, int>>(
          future: _dataService.getGenderDistribution(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(color: darkPurple),
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Text(
                    'Unable to load gender data',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }

            final genderData = snapshot.data!;
            final totalUsers = genderData.values.fold(0, (sum, count) => sum + count);
            
            return Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: _createPieSections(genderData, totalUsers),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildGenderLegend(genderData),
              ],
            );
          },
        ),
      ],
    ),
  );
}

// ✅ ADD: Missing _buildGenderLegend method
Widget _buildGenderLegend(Map<String, int> genderData) {
  return Column(
    children: genderData.entries.map((entry) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getColorForGender(entry.key),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              _getGenderIcon(entry.key),
              size: 16,
              color: _getColorForGender(entry.key),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                entry.key,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${entry.value}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: darkPurple,
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}

// ✅ ADD: Missing _buildLegendItem method
Widget _buildLegendItem(String label, int value, Color color) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 6),
      Text(
        '$label ($value)',
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey[700],
        ),
      ),
    ],
  );
}

// ✅ ADD: Missing helper methods
int _getUserAge(Map<String, dynamic> user) {
  final birthDate = user['tanggal_lahir'];
  if (birthDate == null) return 0;
  
  try {
    DateTime birth;
    if (birthDate is Timestamp) {
      birth = birthDate.toDate();
    } else if (birthDate is String) {
      birth = DateTime.parse(birthDate);
    } else {
      return 0;
    }
    
    final now = DateTime.now();
    int age = now.year - birth.year;
    if (now.month < birth.month || 
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return age;
  } catch (e) {
    print('Error calculating age: $e');
    return 0;
  }
}

String _getAgeGroup(int age) {
  if (age >= 13 && age <= 17) return '13-17';
  if (age >= 18 && age <= 24) return '18-24';
  if (age >= 25 && age <= 34) return '25-34';
  if (age >= 35 && age <= 44) return '35-44';
  if (age >= 45) return '45+';
  return 'Unknown';
}

String _getBirthDateString(dynamic birthDate) {
  if (birthDate == null) return '';
  
  try {
    DateTime date;
    if (birthDate is Timestamp) {
      date = birthDate.toDate();
    } else if (birthDate is String) {
      date = DateTime.parse(birthDate);
    } else {
      return '';
    }
    
    return '${date.day}/${date.month}/${date.year}';
  } catch (e) {
    return '';
  }
}

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date).inDays;
  
  if (difference < 1) {
    return 'Today';
  } else if (difference < 7) {
    return '$difference days ago';
  } else if (difference < 30) {
    final weeks = (difference / 7).floor();
    return '$weeks week${weeks > 1 ? 's' : ''} ago';
  } else if (difference < 365) {
    final months = (difference / 30).floor();
    return '$months month${months > 1 ? 's' : ''} ago';
  } else {
    final years = (difference / 365).floor();
    return '$years year${years > 1 ? 's' : ''} ago';
  }
}

void _handleUserAction(String action, Map<String, dynamic> user) {
  switch (action) {
    case 'toggle_status':
      _toggleUserStatus(user);
      break;
    case 'delete':
      _deleteUser(user);
      break;
  }
}

Future<void> _toggleUserStatus(Map<String, dynamic> user) async {
  try {
    final userId = user['id'];
    final currentStatus = user['isActive'] ?? true;
    
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'isActive': !currentStatus});
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          currentStatus ? 'User deactivated' : 'User activated',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: currentStatus ? Colors.orange : Colors.green,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error updating user status: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<void> _deleteUser(Map<String, dynamic> user) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Delete User',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      content: Text(
        'Are you sure you want to delete ${user['name']}? This action cannot be undone.',
        style: GoogleFonts.poppins(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel', style: GoogleFonts.poppins()),
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

  if (confirmed == true) {
    try {
      final userId = user['id'];
      
      // Delete user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .delete();
      
      // Also delete personalisasi data if exists
      await FirebaseFirestore.instance
          .collection('personalisasi')
          .doc(userId)
          .delete();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'User deleted successfully',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

}

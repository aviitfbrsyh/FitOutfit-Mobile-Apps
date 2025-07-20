import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class BudgetPersonalitySection extends StatelessWidget {
  const BudgetPersonalitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Personality Analytics', style: GoogleFonts.poppins()),
      ),
body: Padding(
  padding: const EdgeInsets.all(16),
  child: SingleChildScrollView(
    child: Column(
      children: [
        _buildBudgetPieChart(),
        const SizedBox(height: 24),
        SizedBox(
          height: 400, // Atur tinggi sesuai kebutuhan
          child: _buildUserList(),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildBudgetPieChart() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('budget_quiz_results').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final docs = snapshot.data!.docs;
        final counts = <String, int>{
          'Smart Saver': 0,
          'Overbudget Fashionista': 0,
          'Impulse Switcher': 0,
          'Deal Hunter': 0,
        };
        for (var doc in docs) {
          final type = doc['budget_type'] ?? '';
          if (counts.containsKey(type)) counts[type] = counts[type]! + 1;
        }
        final total = counts.values.fold(0, (a, b) => a + b);
        return SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sections: counts.entries.map((e) {
                final percent = total > 0 ? (e.value / total * 100).toStringAsFixed(1) : '0';
                return PieChartSectionData(
                  value: e.value.toDouble(),
                  title: '${e.key}\n$percent%',
                  color: _getColor(e.key),
                  radius: 60,
                  titleStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

// ...existing code...
Widget _buildUserList() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('budget_quiz_results').orderBy('timestamp', descending: true).snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      final docs = snapshot.data!.docs;
      return ListView.separated(
        itemCount: docs.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, i) {
          final d = docs[i];
          return ListTile(
            leading: Icon(Icons.person, color: _getColor(d['budget_type'] ?? '')),
            title: Text('${d['username']}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            subtitle: Text('${d['budget_type']} • ${d['description']}', maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: Text(
              d['timestamp'] != null
                ? (d['timestamp'] as Timestamp).toDate().toString().substring(0, 16)
                : '-',
              style: GoogleFonts.poppins(fontSize: 11),
            ),
          );
        },
      );
    },
  );
}
// ...existing code...

  Color _getColor(String type) {
    switch (type) {
      case 'Smart Saver': return Colors.green;
      case 'Overbudget Fashionista': return Colors.redAccent;
      case 'Impulse Switcher': return Colors.purple;
      case 'Deal Hunter': return Colors.orange;
      default: return Colors.grey;
    }
  }
}

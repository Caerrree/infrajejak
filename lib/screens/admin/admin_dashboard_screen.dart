import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hazard.dart';
import '../../providers/hazard_provider.dart';
import '../../widgets/hazard_card.dart';
import 'admin_report_review_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _filter = 'Pending Review';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HazardProvider>();
    final reports = provider.allHazards.where((h) => h.source == HazardSource.community).toList();

    final pendingReview = reports.where((h) =>
        h.status == HazardStatus.reported || h.status == HazardStatus.underReview).toList();
    final highSeverity = reports.where((h) => h.severity == HazardSeverity.high).toList();
    final highlyValidated = reports.where((h) => h.confirmationCount >= 5).toList()
      ..sort((a, b) => b.confirmationCount.compareTo(a.confirmationCount));
    final recent = [...reports]..sort((a, b) => b.dateReported.compareTo(a.dateReported));
    final resolved = reports.where((h) => h.status == HazardStatus.resolved).toList();

    final categories = <String, List<Hazard>>{
      'Pending Review': pendingReview,
      'High Severity': highSeverity,
      'Highly Validated': highlyValidated,
      'Recent Reports': recent,
      'Resolved': resolved,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                _StatCard(label: 'Pending', value: pendingReview.length, color: const Color(0xFFE0A020)),
                _StatCard(label: 'Verified', value: reports.where((h) => h.status == HazardStatus.communityVerified).length, color: const Color(0xFF9333EA)),
                _StatCard(label: 'Repairing', value: reports.where((h) => h.status == HazardStatus.repairing).length, color: const Color(0xFFF97316)),
                _StatCard(label: 'Resolved', value: resolved.length, color: const Color(0xFF2E9E5B)),
                _StatCard(label: 'High Severity', value: highSeverity.length, color: const Color(0xFFD1453B)),
                _StatCard(label: 'Total', value: reports.length, color: const Color(0xFF0B5D3B)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: categories.keys.map((label) {
                  final selected = _filter == label;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (_) => setState(() => _filter = label),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: categories[_filter]!.isEmpty
                ? const Center(child: Text('Nothing here.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: categories[_filter]!.length,
                    itemBuilder: (_, i) {
                      final h = categories[_filter]![i];
                      return HazardCard(
                        hazard: h,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => AdminReportReviewScreen(hazardId: h.id)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$value', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }
}

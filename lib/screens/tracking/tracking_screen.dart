import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hazard_provider.dart';
import '../../models/hazard.dart';
import '../../widgets/hazard_card.dart';
import 'report_status_screen.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final hazardProvider = context.watch<HazardProvider>();

    final myReports = hazardProvider.allHazards
        .where((h) => h.source == HazardSource.community && h.reportedByUserId == auth.user?.uid)
        .toList()
      ..sort((a, b) => b.dateReported.compareTo(a.dateReported));

    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: myReports.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 100),
                Icon(Icons.assignment_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Center(child: Text("You haven't submitted any reports yet.", style: TextStyle(color: Colors.grey))),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: myReports.length,
              itemBuilder: (_, i) {
                final h = myReports[i];
                return HazardCard(
                  hazard: h,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ReportStatusScreen(hazardId: h.id)),
                  ),
                );
              },
            ),
    );
  }
}

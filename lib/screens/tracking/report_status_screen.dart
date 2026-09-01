import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/hazard_provider.dart';
import '../../widgets/badges.dart';
import '../../widgets/status_timeline.dart';
import '../../models/hazard.dart';

class ReportStatusScreen extends StatelessWidget {
  final String hazardId;
  const ReportStatusScreen({super.key, required this.hazardId});

  @override
  Widget build(BuildContext context) {
    final hazard = context.watch<HazardProvider>().byId(hazardId);
    if (hazard == null) {
      return const Scaffold(body: Center(child: Text('Report not found.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Report Status')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hazard.type.label, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(hazard.roadName, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, children: [
              SeverityChip(severity: hazard.severity),
              StatusBadge(status: hazard.status),
            ]),
            const SizedBox(height: 20),
            Text('Report ID: ${hazard.id}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Submitted: ${DateFormat('d MMM yyyy, h:mm a').format(hazard.dateReported)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 24),
            Text('Progress', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            StatusTimeline(currentStatus: hazard.status),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  const Icon(Icons.thumb_up_alt_outlined, color: Color(0xFF2E9E5B), size: 18),
                  const SizedBox(width: 6),
                  Text('${hazard.confirmationCount} confirmed'),
                  const SizedBox(width: 20),
                  const Icon(Icons.thumb_down_alt_outlined, color: Color(0xFFD1453B), size: 18),
                  const SizedBox(width: 6),
                  Text('${hazard.disputeCount} disputed'),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

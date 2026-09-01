import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/hazard.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hazard_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/badges.dart';

class AdminReportReviewScreen extends StatefulWidget {
  final String hazardId;
  const AdminReportReviewScreen({super.key, required this.hazardId});

  @override
  State<AdminReportReviewScreen> createState() => _AdminReportReviewScreenState();
}

class _AdminReportReviewScreenState extends State<AdminReportReviewScreen> {
  final _firestoreService = FirestoreService();
  bool _updating = false;

  Future<void> _setStatus(HazardStatus status) async {
    final auth = context.read<AuthProvider>();
    setState(() => _updating = true);
    try {
      await _firestoreService.updateStatus(
        reportId: widget.hazardId,
        status: status,
        updatedByUserId: auth.user?.uid ?? 'admin',
      );
      if (!mounted) return;
      await context.read<HazardProvider>().refreshCommunityOnly();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to "${status.label}".')),
      );
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hazard = context.watch<HazardProvider>().byId(widget.hazardId);
    if (hazard == null) {
      return const Scaffold(body: Center(child: Text('Report not found.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Review Report')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hazard.photoUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: hazard.photoUrl!.startsWith('http')
                          ? Image.network(hazard.photoUrl!, fit: BoxFit.cover)
                          : Image.file(File(hazard.photoUrl!), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Text(hazard.type.label, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(hazard.roadName, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, children: [
                  SeverityChip(severity: hazard.severity),
                  StatusBadge(status: hazard.status),
                ]),
                const SizedBox(height: 18),
                _InfoRow('Report ID', hazard.id),
                _InfoRow('GPS Coordinates', '${hazard.latitude.toStringAsFixed(5)}, ${hazard.longitude.toStringAsFixed(5)}'),
                _InfoRow('Date / Time', DateFormat('d MMM yyyy, h:mm a').format(hazard.dateReported)),
                _InfoRow('Reported By', hazard.reportedByUserId ?? 'Unknown'),
                const SizedBox(height: 14),
                if (hazard.description != null) ...[
                  Text('Description', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(hazard.description!),
                  const SizedBox(height: 18),
                ],
                Text('Community Validation', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(children: [
                  Text('${hazard.communityConfidence.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0B5D3B))),
                  const SizedBox(width: 10),
                  Text('${hazard.confirmationCount} confirmed · ${hazard.disputeCount} disputed', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ]),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, -2))],
              ),
              child: SafeArea(
                top: false,
                child: _updating
                    ? const Center(child: CircularProgressIndicator())
                    : Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _ActionButton(
                            label: 'Acknowledge',
                            color: const Color(0xFF1D4ED8),
                            onPressed: () => _setStatus(HazardStatus.acknowledged),
                          ),
                          _ActionButton(
                            label: 'Mark Repairing',
                            color: const Color(0xFFF97316),
                            onPressed: () => _setStatus(HazardStatus.repairing),
                          ),
                          _ActionButton(
                            label: 'Mark Resolved',
                            color: const Color(0xFF2E9E5B),
                            onPressed: () => _setStatus(HazardStatus.resolved),
                          ),
                          _ActionButton(
                            label: 'Reject',
                            color: const Color(0xFFD1453B),
                            onPressed: () => _setStatus(HazardStatus.rejected),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  const _ActionButton({required this.label, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: const Size(0, 44)),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

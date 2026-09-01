import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/hazard.dart';
import '../../models/validation.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hazard_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/badges.dart';
import '../../widgets/district_population_card.dart';

class HazardDetailsScreen extends StatefulWidget {
  final String hazardId;
  const HazardDetailsScreen({super.key, required this.hazardId});

  @override
  State<HazardDetailsScreen> createState() => _HazardDetailsScreenState();
}

class _HazardDetailsScreenState extends State<HazardDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _submitting = false;

  Future<void> _validate(Hazard hazard, ValidationType type) async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;
    setState(() => _submitting = true);
    try {
      await _firestoreService.submitValidation(
        reportId: hazard.id,
        userId: auth.user!.uid,
        type: type,
      );
      if (!mounted) return;
      await context.read<HazardProvider>().refreshCommunityOnly();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
          type == ValidationType.confirm ? 'Thanks for confirming this hazard.' : 'Thanks — your dispute was recorded.',
        )),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hazard = context.watch<HazardProvider>().byId(widget.hazardId);

    if (hazard == null) {
      return const Scaffold(body: Center(child: Text('Hazard not found.')));
    }

    final isOfficial = hazard.source == HazardSource.officialJkr;

    return Scaffold(
      appBar: AppBar(title: Text(isOfficial ? 'Blackspot Details' : 'Hazard Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SourceBadge(source: hazard.source),
            const SizedBox(height: 10),
            if (hazard.photoUrl != null) _PhotoPreview(path: hazard.photoUrl!),
            if (hazard.photoUrl != null) const SizedBox(height: 14),
            Text(
              isOfficial ? (hazard.blackspotClassification ?? 'Blackspot') : hazard.type.label,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(child: Text(hazard.roadName)),
            ]),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [
              SeverityChip(severity: hazard.severity),
              StatusBadge(status: hazard.status),
            ]),
            const SizedBox(height: 18),
            _InfoRow(label: 'Report ID', value: hazard.id.length > 12 ? hazard.id.substring(0, 12) : hazard.id),
            _InfoRow(label: 'Latitude / Longitude', value: '${hazard.latitude.toStringAsFixed(5)}, ${hazard.longitude.toStringAsFixed(5)}'),
            _InfoRow(label: 'Date Reported', value: DateFormat('d MMM yyyy, h:mm a').format(hazard.dateReported)),
            _InfoRow(label: 'Source', value: isOfficial ? 'JKR Blackspot Dataset' : 'Infra Jejak Community'),
            if (hazard.district != null && hazard.district!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text('District Context', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              DistrictPopulationCard(district: hazard.district!),
            ],
            if (hazard.description != null && hazard.description!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text('Description', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(hazard.description!),
            ],

            if (!isOfficial) ...[
              const SizedBox(height: 22),
              const Divider(),
              const SizedBox(height: 10),
              Text('Community Validation', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _ValidationSummary(hazard: hazard),
              const SizedBox(height: 6),
              const Text(
                'This confidence score reflects community input only — it is '
                'not an official government determination.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _submitting ? null : () => _validate(hazard, ValidationType.confirm),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Confirm'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E9E5B)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _submitting ? null : () => _validate(hazard, ValidationType.dispute),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Dispute'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD1453B),
                        side: const BorderSide(color: Color(0xFFD1453B)),
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFEFF4FF), borderRadius: BorderRadius.circular(10)),
                child: const Text(
                  'This location is listed in the official JKR blackspot dataset. '
                  'It cannot be confirmed/disputed by the community.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF1D4ED8)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ValidationSummary extends StatelessWidget {
  final Hazard hazard;
  const _ValidationSummary({required this.hazard});

  @override
  Widget build(BuildContext context) {
    final confidence = hazard.communityConfidence;
    return Row(
      children: [
        Text('${confidence.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0B5D3B))),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Community Confidence', style: TextStyle(fontWeight: FontWeight.w600)),
              Text('${hazard.confirmationCount} confirmed · ${hazard.disputeCount} disputed', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  final String path;
  const _PhotoPreview({required this.path});

  @override
  Widget build(BuildContext context) {
    final isNetwork = path.startsWith('http');
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: isNetwork
            ? Image.network(path, fit: BoxFit.cover)
            : Image.file(File(path), fit: BoxFit.cover),
      ),
    );
  }
}

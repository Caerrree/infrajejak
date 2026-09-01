import 'package:flutter/material.dart';
import '../models/hazard.dart';
import '../theme/app_theme.dart';

class SeverityChip extends StatelessWidget {
  final HazardSeverity severity;
  const SeverityChip({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forSeverity(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        '${severity.label} Severity',
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final HazardStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class SourceBadge extends StatelessWidget {
  final HazardSource source;
  const SourceBadge({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    final isOfficial = source == HazardSource.officialJkr;
    final color = isOfficial ? AppColors.official : AppColors.community;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(isOfficial ? Icons.verified : Icons.groups, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          isOfficial ? 'JKR Blackspot Dataset · Official' : 'Infra Jejak Community',
          style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ],
    );
  }
}

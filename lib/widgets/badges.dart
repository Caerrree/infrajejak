import 'package:flutter/material.dart';
import '../models/hazard.dart';
import '../theme/app_theme.dart';

/// A small pill showing how severe a hazard is (Low / Medium / High).
///
/// The colour is not hardcoded here — it comes from [AppColors.forSeverity],
/// so severity colours only ever need to be changed in one place (app_theme.dart).
class SeverityChip extends StatelessWidget {
  final HazardSeverity severity;
  const SeverityChip({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forSeverity(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // Same colour used three ways: faint fill, stronger border, solid text.
        // withOpacity keeps the pill readable instead of a solid block of colour.
        color: color.withOpacity(0.12),
        // large radius = fully rounded pill
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

/// A pill showing where a report currently sits in its lifecycle
/// (Reported, Acknowledged, Repairing, Resolved, and so on).
///
/// Visually similar to [SeverityChip] but with no border, so the two badges
/// can sit side by side without competing for attention.
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

/// Shows whether a hazard came from the official JKR blackspot dataset
/// or was submitted by an Infra Jejak user.
///
/// This distinction matters to the user: official records are verified
/// government data, community reports are not.
class SourceBadge extends StatelessWidget {
  final HazardSource source;
  const SourceBadge({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    final isOfficial = source == HazardSource.officialJkr;
    final color = isOfficial ? AppColors.official : AppColors.community;
    return Row(
      // Shrink the Row to fit its children, otherwise it expands to fill
      // the whole width of whatever card it is placed inside.
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tick icon for official data, people icon for community reports.
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
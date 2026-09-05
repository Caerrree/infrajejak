import 'package:flutter/material.dart';
import '../models/hazard.dart';
import '../theme/app_theme.dart';

/// The normal order a hazard report moves through, from submission to repair.
///
/// The order of this list defines the timeline, so the enum values must stay
/// in the sequence a real report actually follows. HazardStatus.rejected is
/// deliberately absent — it is a dead end, not a stage, and is handled
/// separately in build().
const _lifecycleOrder = [
  HazardStatus.reported,
  HazardStatus.communityVerified,
  HazardStatus.acknowledged,
  HazardStatus.repairing,
  HazardStatus.resolved,
];

/// A vertical progress tracker showing how far a hazard report has come.
///
/// Only the stages already reached are shown, with the most recent one
/// highlighted in bold at the bottom.
class StatusTimeline extends StatelessWidget {
  final HazardStatus currentStatus;
  const StatusTimeline({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    // Rejected reports never entered the lifecycle, so a timeline would be
    // misleading. Show a single explanatory line and return early.
    if (currentStatus == HazardStatus.rejected) {
      return Row(
        children: [
          Icon(Icons.cancel, color: AppColors.forStatus(HazardStatus.rejected)),
          const SizedBox(width: 8),
          const Text('This report was reviewed and rejected by an administrator.'),
        ],
      );
    }

    // Find where the current status sits in the lifecycle, then take every
    // stage up to and including it. sublist's end index is exclusive,
    // hence the +1.
    final currentIndex = _lifecycleOrder.indexOf(currentStatus);
    final visibleStages = _lifecycleOrder.sublist(0, currentIndex + 1);

    return Column(
      // List.generate builds one row per completed stage.
      children: List.generate(visibleStages.length, (i) {
        final stage = visibleStages[i];
        // isLast marks the current status
        final isLast = i == visibleStages.length - 1;
        final color = AppColors.forStatus(stage);

        // IntrinsicHeight forces the Row to size itself to its tallest child,
        // which gives the Expanded connector line below a real height to
        // stretch into. Without it the line would have no vertical space.
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column: the dot, plus the line connecting it downward.
              Column(
                children: [
                  Container(
                    width: 14, height: 14,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  // No connector after the final dot — the timeline ends there.
                  if (!isLast) Expanded(child: Container(width: 2, color: color.withOpacity(0.3))),
                ],
              ),
              const SizedBox(width: 12),

              // Right column: the stage name.
              Expanded(
                child: Padding(
                  // Bottom padding creates the vertical gap between stages,
                  // which is also what the connector line runs through.
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    stage.label,
                    style: TextStyle(
                      // The current stage is bold and coloured; earlier
                      // completed stages are plain dark text.
                      fontWeight: isLast ? FontWeight.bold : FontWeight.w500,
                      color: isLast ? color : AppColors.textDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
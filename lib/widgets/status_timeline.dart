import 'package:flutter/material.dart';
import '../models/hazard.dart';
import '../theme/app_theme.dart';

/// The canonical forward order of the report lifecycle. "Rejected" is
/// handled separately since it's a terminal branch, not a forward stage.
const _lifecycleOrder = [
  HazardStatus.reported,
  HazardStatus.communityVerified,
  HazardStatus.acknowledged,
  HazardStatus.repairing,
  HazardStatus.resolved,
];

class StatusTimeline extends StatelessWidget {
  final HazardStatus currentStatus;
  const StatusTimeline({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    if (currentStatus == HazardStatus.rejected) {
      return Row(
        children: [
          Icon(Icons.cancel, color: AppColors.forStatus(HazardStatus.rejected)),
          const SizedBox(width: 8),
          const Text('This report was reviewed and rejected by an administrator.'),
        ],
      );
    }

    final currentIndex = _lifecycleOrder.indexOf(currentStatus);
    // Only render stages up to and including the current one — future
    // stages that haven't happened yet are intentionally omitted.
    final visibleStages = _lifecycleOrder.sublist(0, currentIndex + 1);

    return Column(
      children: List.generate(visibleStages.length, (i) {
        final stage = visibleStages[i];
        final isLast = i == visibleStages.length - 1;
        final color = AppColors.forStatus(stage);
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 14, height: 14,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  if (!isLast) Expanded(child: Container(width: 2, color: color.withOpacity(0.3))),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    stage.label,
                    style: TextStyle(
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

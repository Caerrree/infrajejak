import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The colour key shown on the map screen, explaining what each
/// marker colour means.
///
/// The colours listed here must match the ones [HazardMarkerPin] uses,
/// which is why both read from [AppColors] instead of hardcoding values.
class MapLegend extends StatelessWidget {
  const MapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Without mainAxisSize.min the Column tries to fill the full screen
          // height, stretching the card over the map.
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Legend', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            // Ordered by importance: official data first, then community
            // reports from most to least severe, with resolved last.
            _row(AppColors.official, 'JKR Blackspot (Official)'),
            _row(AppColors.severityHigh, 'Community — High Severity'),
            _row(AppColors.severityMedium, 'Community — Medium Severity'),
            _row(AppColors.severityLow, 'Community — Low Severity'),
            _row(Colors.grey, 'Resolved'),
          ],
        ),
      ),
    );
  }

  /// Builds one legend entry: a coloured dot beside its label.
  ///
  /// Kept as a private helper method so the five rows above stay readable
  /// instead of repeating the same twelve lines of layout code.
  Widget _row(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          // Same size and shape as the map pin, just without the icon.
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
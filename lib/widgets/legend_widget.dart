import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MapLegend extends StatelessWidget {
  const MapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Legend', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
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

  Widget _row(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

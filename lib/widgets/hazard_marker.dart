import 'package:flutter/material.dart';
import '../models/hazard.dart';
import '../theme/app_theme.dart';

IconData iconForHazardType(HazardType type, HazardSource source) {

  if (source == HazardSource.officialJkr) return Icons.warning_amber_rounded;


  switch (type) {
    case HazardType.pothole:
      return Icons.circle;
    case HazardType.damagedRoadSurface:
      return Icons.terrain;
    case HazardType.brokenTrafficLight:
      return Icons.traffic;
    case HazardType.brokenStreetlight:
      return Icons.lightbulb_outline;
    case HazardType.damagedBarrier:
      return Icons.fence;
    case HazardType.fadedRoadMarking:
      return Icons.remove_road;
    case HazardType.floodedRoad:
      return Icons.water_drop;
    case HazardType.roadObstruction:
      return Icons.block;
    case HazardType.others:
      return Icons.report_problem_outlined;
  }
}


class HazardMarkerPin extends StatelessWidget {
  final Hazard hazard;
  final VoidCallback onTap;

  const HazardMarkerPin({super.key, required this.hazard, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isResolved = hazard.status == HazardStatus.resolved;


    final baseColor = hazard.source == HazardSource.officialJkr
        ? AppColors.official
        : AppColors.forSeverity(hazard.severity);


    final color = isResolved ? Colors.grey : baseColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,

          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [

            BoxShadow(color: Colors.black.withValues(alpha: .25), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: Icon(
          iconForHazardType(hazard.type, hazard.source),
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}
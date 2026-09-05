import 'package:flutter/material.dart';
import '../models/hazard.dart';
import '../theme/app_theme.dart';

/// Picks the icon that represents a hazard on the map.
///
/// This is a top-level function rather than a method so other files
/// (legends, detail screens, filter menus) can reuse the same mapping
/// and stay visually consistent with the map.
IconData iconForHazardType(HazardType type, HazardSource source) {
  // Official JKR blackspots all share one warning icon regardless of type,
  // because the dataset marks accident-prone stretches rather than
  // specific physical defects.
  if (source == HazardSource.officialJkr) return Icons.warning_amber_rounded;

  // A switch over an enum with no default clause is deliberate: if a new
  // HazardType is added later, the compiler will flag this switch as
  // incomplete instead of silently falling through to a wrong icon.
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

/// A single circular pin drawn on the map for one hazard.
///
/// The colour encodes two things at once: the data source and the severity,
/// with resolved hazards greyed out so active problems stand out.
class HazardMarkerPin extends StatelessWidget {
  final Hazard hazard;
  final VoidCallback onTap;

  const HazardMarkerPin({super.key, required this.hazard, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isResolved = hazard.status == HazardStatus.resolved;

    // Official blackspots get one fixed colour; community reports are
    // coloured by severity so high-risk ones are obvious at a glance.
    final baseColor = hazard.source == HazardSource.officialJkr
        ? AppColors.official
        : AppColors.forSeverity(hazard.severity);

    // Resolved hazards override everything else and turn grey — they stay
    // on the map as history but should not draw the eye.
    final color = isResolved ? Colors.grey : baseColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          // White ring keeps the pin visible against dark map tiles,
          // roads and satellite imagery.
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            // Slight drop shadow lifts the pin off the map surface.
            BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 4, offset: const Offset(0, 2)),
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
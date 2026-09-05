import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hazard.dart';
import 'badges.dart';

/// A summary card for one hazard, used in list views such as the
/// community reports screen and the admin review queue.
///
/// Tapping the card calls [onTap], which the parent screen uses to
/// navigate to the full hazard details page.
class HazardCard extends StatelessWidget {
  final Hazard hazard;
  final VoidCallback onTap;

  const HazardCard({super.key, required this.hazard, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      // InkWell sits inside the Card so the tap ripple is drawn on top of it.
      // Its borderRadius must match the Card's, or the ripple spills past the corners.
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Row 1: title on the left, status badge on the right ----
              Row(
                children: [
                  Expanded(
                    child: Text(
                      // Official JKR records have a blackspot classification;
                      // community reports have a hazard type instead.
                      // ?? falls back to 'Blackspot' if the classification is null.
                      hazard.source == HazardSource.officialJkr
                          ? (hazard.blackspotClassification ?? 'Blackspot')
                          : hazard.type.label,
                      style: Theme.of(context).textTheme.titleMedium,
                      // Long road names are cut off with "..." rather than
                      // wrapping, so every card keeps the same height.
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(status: hazard.status),
                ],
              ),
              const SizedBox(height: 6),

              // ---- Row 2: location ----
              Row(children: [
                const Icon(Icons.location_on_outlined, size: 15, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(hazard.roadName, style: const TextStyle(fontSize: 13, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 10),

              // ---- Row 3: data source on the left, report date on the right ----
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SourceBadge(source: hazard.source),
                  // DateFormat comes from the intl package.
                  // 'd MMM' renders 2026-09-05 as "5 Sep".
                  Text(DateFormat('d MMM').format(hazard.dateReported), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),

              // ---- Row 4: confirm / dispute counts (community reports only) ----
              // Official JKR data is already verified, so voting is not shown for it.
              // The spread operator (...) inserts these widgets into the Column
              // only when the condition is true.
              if (hazard.source == HazardSource.community) ...[
                const SizedBox(height: 8),
                Row(children: [
                  // Green thumbs up = other users confirming the hazard is real.
                  const Icon(Icons.thumb_up_alt_outlined, size: 14, color: Color(0xFF2E9E5B)),
                  const SizedBox(width: 4),
                  Text('${hazard.confirmationCount}', style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 12),
                  // Red thumbs down = users disputing it (already fixed, or false report).
                  const Icon(Icons.thumb_down_alt_outlined, size: 14, color: Color(0xFFD1453B)),
                  const SizedBox(width: 4),
                  Text('${hazard.disputeCount}', style: const TextStyle(fontSize: 12)),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
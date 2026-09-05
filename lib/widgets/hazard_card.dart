import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hazard.dart';
import 'badges.dart';

class HazardCard extends StatelessWidget {
  final Hazard hazard;
  final VoidCallback onTap;

  const HazardCard({super.key, required this.hazard, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(

      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  Expanded(
                    child: Text(

                      hazard.source == HazardSource.officialJkr
                          ? (hazard.blackspotClassification ?? 'Blackspot')
                          : hazard.type.label,
                      style: Theme.of(context).textTheme.titleMedium,

                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(status: hazard.status),
                ],
              ),
              const SizedBox(height: 6),


              Row(children: [
                const Icon(Icons.location_on_outlined, size: 15, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(hazard.roadName, style: const TextStyle(fontSize: 13, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 10),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SourceBadge(source: hazard.source),

                  Text(DateFormat('d MMM').format(hazard.dateReported), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),


              if (hazard.source == HazardSource.community) ...[
                const SizedBox(height: 8),
                Row(children: [

                  const Icon(Icons.thumb_up_alt_outlined, size: 14, color: Color(0xFF2E9E5B)),
                  const SizedBox(width: 4),
                  Text('${hazard.confirmationCount}', style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 12),

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
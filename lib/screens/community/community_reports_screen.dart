import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hazard.dart';
import '../../providers/hazard_provider.dart';
import '../../widgets/hazard_card.dart';
import '../map/hazard_details_screen.dart';

class CommunityReportsScreen extends StatefulWidget {
  const CommunityReportsScreen({super.key});

  @override
  State<CommunityReportsScreen> createState() => _CommunityReportsScreenState();
}

class _CommunityReportsScreenState extends State<CommunityReportsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HazardProvider>();
    final communityReports = provider.allHazards
        .where((h) => h.source == HazardSource.community)
        .where((h) => _query.isEmpty ||
            h.roadName.toLowerCase().contains(_query.toLowerCase()) ||
            h.type.label.toLowerCase().contains(_query.toLowerCase()))
        .toList()
      ..sort((a, b) => b.dateReported.compareTo(a.dateReported));

    return Scaffold(
      appBar: AppBar(title: const Text('Community Reports')),
      body: RefreshIndicator(
        onRefresh: () => provider.refreshCommunityOnly(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by road or hazard type',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: communityReports.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 80),
                        Center(child: Text('No community reports yet.', style: TextStyle(color: Colors.grey))),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      itemCount: communityReports.length,
                      itemBuilder: (_, i) {
                        final h = communityReports[i];
                        return HazardCard(
                          hazard: h,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => HazardDetailsScreen(hazardId: h.id)),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

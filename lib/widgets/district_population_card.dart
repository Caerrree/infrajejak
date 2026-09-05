import 'package:flutter/material.dart';
import '../services/opendosm_service.dart';
import '../theme/app_theme.dart';

/// Shows the population of a district, fetched from OpenDOSM
/// (the Malaysian government's open data portal).
///
/// This gives context to a hazard report — a blackspot on a road serving
/// 400,000 residents matters more than one serving 5,000.
///
/// It is a StatefulWidget because the data arrives asynchronously over the
/// network, so the widget has to rebuild itself once the response comes back.
class DistrictPopulationCard extends StatefulWidget {
  final String district;
  const DistrictPopulationCard({super.key, required this.district});

  @override
  State<DistrictPopulationCard> createState() => _DistrictPopulationCardState();
}

class _DistrictPopulationCardState extends State<DistrictPopulationCard> {
  final _service = OpenDosmService();

  // Three pieces of state, covering the three things that can happen:
  // the result, once it arrives
  DistrictPopulation? _data;
  // request still in flight
  bool _loading = true;
  // request finished but returned nothing
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    // initState runs once when the widget is first inserted into the tree.
    // The API call is started here rather than in build(), because build()
    // can run many times and would fire a duplicate request each time.
    _load();
  }

  Future<void> _load() async {
    final result = await _service.getLatestDistrictPopulation(widget.district);

    // The user may have navigated away while we were waiting for the network.
    // Calling setState() after that throws an error, so bail out first.
    if (!mounted) return;

    setState(() {
      _data = result;
      _failed = result == null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // State 1 — still loading: show a small spinner as a placeholder.
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          height: 16, width: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    // State 2 — no data available: render nothing at all.
    // SizedBox.shrink() takes up zero space, so the card silently disappears
    // instead of showing an error. Population data is a nice-to-have here,
    // so a failure should not disrupt the rest of the screen.
    if (_failed || _data == null) {
      return const SizedBox.shrink();
    }

    // State 3 — data loaded: show the card.
    final pop = _data!;
    return Card(
      color: AppColors.primaryLight,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.groups_2_outlined, color: AppColors.primary),
            const SizedBox(width: 12),
            // Expanded lets the text column take the remaining width and wrap,
            // instead of overflowing off the right edge of the screen.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // OpenDOSM returns population in thousands, so multiply by 1000.
                    // The RegExp inserts a comma every three digits from the right,
                    // turning 421953 into 421,953. \B(?=(\d{3})+(?!\d)) matches any
                    // position that has a multiple of three digits after it.
                    '${(pop.populationThousands * 1000).round().toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')} residents',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  Text(
                    // Attribution line. State and date are both optional in the API
                    // response, so each is only appended when it is actually present.
                    // split('-').first pulls the year out of a yyyy-MM-dd date string.
                    '${pop.district}${pop.state != null ? ', ${pop.state}' : ''} · OpenDOSM'
                        '${pop.asOfDate != null ? ' (as of ${pop.asOfDate!.split('-').first})' : ''}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../services/opendosm_service.dart';
import '../theme/app_theme.dart';

class DistrictPopulationCard extends StatefulWidget {
  final String district;
  const DistrictPopulationCard({super.key, required this.district});

  @override
  State<DistrictPopulationCard> createState() => _DistrictPopulationCardState();
}

class _DistrictPopulationCardState extends State<DistrictPopulationCard> {
  final _service = OpenDosmService();

  DistrictPopulation? _data;

  bool _loading = true;

  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await _service.getLatestDistrictPopulation(widget.district);

    if (!mounted) return;

    setState(() {
      _data = result;
      _failed = result == null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          height: 16, width: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_failed || _data == null) {
      return const SizedBox.shrink();
    }

    final pop = _data!;
    return Card(
      color: AppColors.primaryLight,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.groups_2_outlined, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(pop.populationThousands * 1000).round().toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')} residents',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  Text(
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
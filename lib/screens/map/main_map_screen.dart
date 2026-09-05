import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../models/hazard.dart';
import '../../providers/hazard_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/hazard_marker.dart';
import '../../widgets/legend_widget.dart';
import 'hazard_details_screen.dart';

//dadadadda
const _klangValleyCenter = LatLng(3.1390, 101.6869);

class MainMapScreen extends StatefulWidget {
  const MainMapScreen({super.key});

  @override
  State<MainMapScreen> createState() => _MainMapScreenState();
}

class _MainMapScreenState extends State<MainMapScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  bool _showLegend = false;
  LatLng? _myLocation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HazardProvider>().loadAll();
    });
  }

  Future<void> _goToCurrentLocation() async {
    try {
      final pos = await _locationService.getCurrentPosition();
      final latLng = LatLng(pos.latitude, pos.longitude);
      setState(() => _myLocation = latLng);
      _mapController.move(latLng, 15);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _openHazard(Hazard hazard) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => HazardDetailsScreen(hazardId: hazard.id)),
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _FilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hazardProvider = context.watch<HazardProvider>();
    final markers = hazardProvider.filteredHazards.map((h) {
      return Marker(
        point: LatLng(h.latitude, h.longitude),
        width: 40,
        height: 40,
        child: HazardMarkerPin(hazard: h, onTap: () => _openHazard(h)),
      );
    }).toList();

    if (_myLocation != null) {
      markers.add(
        Marker(
          point: _myLocation!,
          width: 24,
          height: 24,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Infra Jejak — Hazard Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Filter hazards',
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _klangValleyCenter,
              initialZoom: 12,
              minZoom: 5,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'my.edu.tarumt.infrajejak',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
          if (hazardProvider.isLoading)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black26,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: _StatsStrip(hazardProvider: hazardProvider),
          ),
          if (_showLegend)
            Positioned(bottom: 90, left: 12, child: const MapLegend()),
          Positioned(
            bottom: 90,
            right: 12,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'legend',
                  onPressed: () => setState(() => _showLegend = !_showLegend),
                  child: const Icon(Icons.info_outline),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  heroTag: 'my_location',
                  onPressed: _goToCurrentLocation,
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  final HazardProvider hazardProvider;
  const _StatsStrip({required this.hazardProvider});

  @override
  Widget build(BuildContext context) {
    final total = hazardProvider.filteredHazards.length;
    final official = hazardProvider.filteredHazards.where((h) => h.source == HazardSource.officialJkr).length;
    final community = total - official;
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _stat('$total', 'Shown'),
            _stat('$official', 'Official'),
            _stat('$community', 'Community'),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HazardProvider>();
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter Hazards', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show JKR Blackspots (Official)'),
            value: provider.showOfficial,
            onChanged: provider.setShowOfficial,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show Community Reports'),
            value: provider.showCommunity,
            onChanged: provider.setShowCommunity,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Hide Resolved Hazards'),
            value: provider.hideResolved,
            onChanged: provider.setHideResolved,
          ),
          const Divider(height: 24),
          Text('Community Hazard Categories', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: HazardType.values.map((type) {
              final selected = provider.selectedTypes.contains(type);
              return FilterChip(
                label: Text(type.label, style: const TextStyle(fontSize: 12)),
                selected: selected,
                onSelected: (_) => provider.toggleType(type),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

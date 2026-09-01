import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/hazard.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hazard_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/location_service.dart';
import '../../services/storage_service.dart';

class ReportHazardScreen extends StatefulWidget {
  const ReportHazardScreen({super.key});

  @override
  State<ReportHazardScreen> createState() => _ReportHazardScreenState();
}

class _ReportHazardScreenState extends State<ReportHazardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roadNameCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  HazardType _selectedType = HazardType.pothole;
  HazardSeverity _selectedSeverity = HazardSeverity.medium;
  File? _photo;
  bool _locating = false;
  bool _submitting = false;

  final _locationService = LocationService();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();
  final _picker = ImagePicker();

  @override
  void dispose() {
    _roadNameCtrl.dispose();
    _districtCtrl.dispose();
    _descriptionCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      final pos = await _locationService.getCurrentPosition();
      _latCtrl.text = pos.latitude.toStringAsFixed(6);
      _lngCtrl.text = pos.longitude.toStringAsFixed(6);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 70);
    if (file != null) setState(() => _photo = File(file.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;

    setState(() => _submitting = true);
    try {
      final reportId = DateTime.now().millisecondsSinceEpoch.toString();
      String? photoUrl;
      if (_photo != null) {
        photoUrl = await _storageService.uploadHazardPhoto(file: _photo!, reportId: reportId);
      }

      final hazard = Hazard(
        id: reportId,
        type: _selectedType,
        source: HazardSource.community,
        latitude: double.parse(_latCtrl.text),
        longitude: double.parse(_lngCtrl.text),
        roadName: _roadNameCtrl.text.trim(),
        district: _districtCtrl.text.trim().isEmpty ? null : _districtCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        photoUrl: photoUrl,
        severity: _selectedSeverity,
        status: HazardStatus.reported,
        dateReported: DateTime.now(),
        reportedByUserId: auth.user!.uid,
      );

      await _firestoreService.submitReport(hazard);
      if (!mounted) return;
      await context.read<HazardProvider>().refreshCommunityOnly();

      _formKey.currentState!.reset();
      setState(() {
        _photo = null;
        _roadNameCtrl.clear();
        _districtCtrl.clear();
        _descriptionCtrl.clear();
        _latCtrl.clear();
        _lngCtrl.clear();
        _selectedType = HazardType.pothole;
        _selectedSeverity = HazardSeverity.medium;
      });

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Report Submitted'),
          content: const Text(
            'Thank you. Your report has been submitted and is now visible to the '
            'community for validation and to administrators for review.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report a Hazard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Photo (optional)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _PhotoPicker(
                photo: _photo,
                onCamera: () => _pickPhoto(ImageSource.camera),
                onGallery: () => _pickPhoto(ImageSource.gallery),
                onClear: () => setState(() => _photo = null),
              ),
              const SizedBox(height: 20),

              Text('Hazard Type', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: HazardType.values.map((t) {
                  final selected = _selectedType == t;
                  return ChoiceChip(
                    label: Text(t.label, style: const TextStyle(fontSize: 12)),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedType = t),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              Text('Severity', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<HazardSeverity>(
                segments: HazardSeverity.values
                    .map((s) => ButtonSegment(value: s, label: Text(s.label)))
                    .toList(),
                selected: {_selectedSeverity},
                onSelectionChanged: (v) => setState(() => _selectedSeverity = v.first),
              ),
              const SizedBox(height: 20),

              Text('Location', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _locating ? null : _useCurrentLocation,
                icon: _locating
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.my_location),
                label: const Text('Use Current GPS Location'),
              ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _latCtrl,
                    decoration: const InputDecoration(labelText: 'Latitude'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    validator: (v) => (v == null || double.tryParse(v) == null) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lngCtrl,
                    decoration: const InputDecoration(labelText: 'Longitude'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    validator: (v) => (v == null || double.tryParse(v) == null) ? 'Required' : null,
                  ),
                ),
              ]),
              const SizedBox(height: 4),
              const Text(
                'GPS may be inaccurate indoors — adjust the coordinates manually if needed.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _roadNameCtrl,
                decoration: const InputDecoration(labelText: 'Road / Location Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _districtCtrl,
                decoration: const InputDecoration(
                  labelText: 'District (optional)',
                  hintText: 'e.g. Petaling, Gombak, Kuala Lumpur',
                  helperText: 'Used to show live population context from OpenDOSM (data.gov.my) on the hazard details page.',
                  helperMaxLines: 2,
                ),
              ),
              const SizedBox(height: 20),

              Text('Description', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Describe the hazard in more detail...'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please add a short description' : null,
              ),
              const SizedBox(height: 26),

              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  final File? photo;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onClear;

  const _PhotoPicker({required this.photo, required this.onCamera, required this.onGallery, required this.onClear});

  @override
  Widget build(BuildContext context) {
    if (photo != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(aspectRatio: 16 / 9, child: Image.file(photo!, fit: BoxFit.cover)),
          ),
          Positioned(
            top: 6, right: 6,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 18), onPressed: onClear),
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(onPressed: onCamera, icon: const Icon(Icons.camera_alt_outlined), label: const Text('Camera')),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(onPressed: onGallery, icon: const Icon(Icons.photo_library_outlined), label: const Text('Gallery')),
        ),
      ],
    );
  }
}

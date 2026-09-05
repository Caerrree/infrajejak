import 'package:flutter/foundation.dart';
import '../database/db_helper.dart';
import '../models/hazard.dart';
import '../services/firestore_service.dart';

/// Central data provider for hazards. Combines:
///  - Official/static JKR blackspots (SQLite, prepared offline dataset)
///  - Dynamic community reports (Firestore, live/near-live)

/// Screens read from here rather than talking to SQLite/Firestore directly,
/// so the "official vs community" merge logic lives in exactly one place.
class HazardProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Hazard> _officialHazards = [];
  List<Hazard> _communityHazards = [];
  bool isLoading = false;
  String? errorMessage;

  // Filter state used by the Main Map screen.
  Set<HazardType> selectedTypes = HazardType.values.toSet();
  bool showOfficial = true;
  bool showCommunity = true;
  bool hideResolved = false;

  List<Hazard> get allHazards => [..._officialHazards, ..._communityHazards];

  List<Hazard> get filteredHazards {
    return allHazards.where((h) {
      if (h.source == HazardSource.officialJkr && !showOfficial) return false;
      if (h.source == HazardSource.community && !showCommunity) return false;
      if (h.source == HazardSource.community && !selectedTypes.contains(h.type)) {
        return false;
      }
      if (hideResolved && h.status == HazardStatus.resolved) return false;
      return true;
    }).toList();
  }

  Future<void> loadAll() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await DbHelper.instance.seedJkrDataIfEmpty();
      _officialHazards = await DbHelper.instance.getAllBlackspots();
      _communityHazards = await _firestoreService.getCommunityReports();
    } catch (e) {
      errorMessage = 'Failed to load hazards: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCommunityOnly() async {
    _communityHazards = await _firestoreService.getCommunityReports();
    notifyListeners();
  }

  Hazard? byId(String id) {
    try {
      return allHazards.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  void toggleType(HazardType type) {
    if (selectedTypes.contains(type)) {
      selectedTypes.remove(type);
    } else {
      selectedTypes.add(type);
    }
    notifyListeners();
  }

  void setShowOfficial(bool value) {
    showOfficial = value;
    notifyListeners();
  }

  void setShowCommunity(bool value) {
    showCommunity = value;
    notifyListeners();
  }

  void setHideResolved(bool value) {
    hideResolved = value;
    notifyListeners();
  }
}

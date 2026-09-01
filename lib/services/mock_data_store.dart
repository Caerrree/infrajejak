import 'package:uuid/uuid.dart';
import '../models/app_user.dart';
import '../models/hazard.dart';
import '../models/validation.dart';

/// Simple in-memory stand-in for Firestore/Auth/Storage, used only when
/// [AppConfig.useMockBackend] is true. Keeps the same shapes the real
/// Firebase services return so screens never need to know which one is
/// active.
class MockDataStore {
  MockDataStore._internal() {
    _seedDemoReports();
  }
  static final MockDataStore instance = MockDataStore._internal();

  final _uuid = const Uuid();

  AppUser? currentUser;
  final Map<String, AppUser> users = {};

  final Map<String, Hazard> reports = {};
  final List<HazardValidation> validations = [];

  void _seedDemoReports() {
    final now = DateTime.now();
    final demo = [
      Hazard(
        id: _uuid.v4(),
        type: HazardType.pothole,
        source: HazardSource.community,
        latitude: 3.1875,
        longitude: 101.7250,
        roadName: 'Jalan Danau Saujana, Setapak',
        district: 'Gombak',
        description: 'Large pothole near the traffic light, roughly 40cm wide.',
        severity: HazardSeverity.high,
        status: HazardStatus.communityVerified,
        dateReported: now.subtract(const Duration(days: 3)),
        confirmationCount: 15,
        disputeCount: 2,
        reportedByUserId: 'demo-user-1',
      ),
      Hazard(
        id: _uuid.v4(),
        type: HazardType.floodedRoad,
        source: HazardSource.community,
        latitude: 3.0745,
        longitude: 101.5210,
        roadName: 'Persiaran Kewajipan, Shah Alam',
        district: 'Petaling',
        description: 'Road floods within 20 minutes of heavy rain.',
        severity: HazardSeverity.medium,
        status: HazardStatus.underReview,
        dateReported: now.subtract(const Duration(hours: 20)),
        confirmationCount: 4,
        disputeCount: 1,
        reportedByUserId: 'demo-user-2',
      ),
      Hazard(
        id: _uuid.v4(),
        type: HazardType.brokenStreetlight,
        source: HazardSource.community,
        latitude: 3.1600,
        longitude: 101.7340,
        roadName: 'Jalan Ampang',
        district: 'Kuala Lumpur',
        description: 'Streetlight has been off for over a week, dark at night.',
        severity: HazardSeverity.medium,
        status: HazardStatus.repairing,
        dateReported: now.subtract(const Duration(days: 6)),
        confirmationCount: 9,
        disputeCount: 0,
        reportedByUserId: 'demo-user-1',
      ),
    ];
    for (final h in demo) {
      reports[h.id] = h;
    }
  }

  String newId() => _uuid.v4();
}

/// Category of road infrastructure hazard.
/// Mirrors Section 8 of the project brief.

enum HazardType {
  pothole,
  damagedRoadSurface,
  brokenTrafficLight,
  brokenStreetlight,
  damagedBarrier,
  fadedRoadMarking,
  floodedRoad,
  roadObstruction,
  others,
}

extension HazardTypeX on HazardType {
  String get label {
    switch (this) {
      case HazardType.pothole:
        return 'Pothole';
      case HazardType.damagedRoadSurface:
        return 'Damaged Road Surface';
      case HazardType.brokenTrafficLight:
        return 'Broken Traffic Light';
      case HazardType.brokenStreetlight:
        return 'Broken Streetlight';
      case HazardType.damagedBarrier:
        return 'Damaged Road Barrier';
      case HazardType.fadedRoadMarking:
        return 'Faded Road Markings';
      case HazardType.floodedRoad:
        return 'Flooded Road';
      case HazardType.roadObstruction:
        return 'Road Obstruction';
      case HazardType.others:
        return 'Other Road Infrastructure Issue';
    }
  }
}

enum HazardSeverity { low, medium, high }

extension HazardSeverityX on HazardSeverity {
  String get label {
    switch (this) {
      case HazardSeverity.low:
        return 'Low';
      case HazardSeverity.medium:
        return 'Medium';
      case HazardSeverity.high:
        return 'High';
    }
  }
}

/// Where a hazard marker's information originated from.
/// This distinction MUST remain visible in the UI (Section 23).
enum HazardSource { officialJkr, community }

/// Lifecycle status of a hazard/report (Section 12).
enum HazardStatus {
  reported,
  underReview,
  communityVerified,
  acknowledged,
  repairing,
  resolved,
  rejected,
}

extension HazardStatusX on HazardStatus {
  String get label {
    switch (this) {
      case HazardStatus.reported:
        return 'Reported';
      case HazardStatus.underReview:
        return 'Under Review';
      case HazardStatus.communityVerified:
        return 'Community Verified';
      case HazardStatus.acknowledged:
        return 'Acknowledged';
      case HazardStatus.repairing:
        return 'Repairing';
      case HazardStatus.resolved:
        return 'Resolved';
      case HazardStatus.rejected:
        return 'Rejected';
    }
  }
}

/// Unified hazard entity used by the map, whether it originates from the
/// static JKR/government dataset (SQLite) or a dynamic community report
/// (Firestore). Screens should always branch on [source] before implying
/// any official confirmation.
class Hazard {
  final String id;
  final HazardType type;
  final HazardSource source;
  final double latitude;
  final double longitude;
  final String roadName;
  final String? district;
  final String? description;
  final String? photoUrl;
  final HazardSeverity severity;
  final HazardStatus status;
  final DateTime dateReported;
  final int confirmationCount;
  final int disputeCount;
  final String? reportedByUserId;
  final String? blackspotClassification; // only for official records

  const Hazard({
    required this.id,
    required this.type,
    required this.source,
    required this.latitude,
    required this.longitude,
    required this.roadName,
    this.district,
    this.description,
    this.photoUrl,
    required this.severity,
    required this.status,
    required this.dateReported,
    this.confirmationCount = 0,
    this.disputeCount = 0,
    this.reportedByUserId,
    this.blackspotClassification,
  });

  double get communityConfidence {
    final total = confirmationCount + disputeCount;
    if (total == 0) return 0;
    return (confirmationCount / total) * 100;
  }

  factory Hazard.fromJkrJson(Map<String, dynamic> json) {
    return Hazard(
      id: json['blackspotId'] as String,
      type: HazardType.others,
      source: HazardSource.officialJkr,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      roadName: json['roadName'] as String,
      district: json['district'] as String?,
      severity: HazardSeverity.high,
      status: HazardStatus.acknowledged,
      dateReported: DateTime(2026, 1, 1),
      blackspotClassification: json['classification'] as String?,
    );
  }

  factory Hazard.fromFirestore(String id, Map<String, dynamic> data) {
    return Hazard(
      id: id,
      type: HazardType.values.firstWhere(
        (e) => e.name == data['hazardType'],
        orElse: () => HazardType.others,
      ),
      source: HazardSource.community,
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      roadName: data['locationName'] as String? ?? 'Unknown road',
      district: data['district'] as String?,
      description: data['description'] as String?,
      photoUrl: data['photoUrl'] as String?,
      severity: HazardSeverity.values.firstWhere(
        (e) => e.name == data['severity'],
        orElse: () => HazardSeverity.medium,
      ),
      status: HazardStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => HazardStatus.reported,
      ),
      dateReported: DateTime.fromMillisecondsSinceEpoch(
        (data['createdAt'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      ),
      confirmationCount: (data['confirmationCount'] as num?)?.toInt() ?? 0,
      disputeCount: (data['disputeCount'] as num?)?.toInt() ?? 0,
      reportedByUserId: data['userId'] as String?,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'hazardType': type.name,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': roadName,
      'district': district,
      'description': description,
      'photoUrl': photoUrl,
      'severity': severity.name,
      'status': status.name,
      'createdAt': dateReported.millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'confirmationCount': confirmationCount,
      'disputeCount': disputeCount,
      'userId': reportedByUserId,
    };
  }
}

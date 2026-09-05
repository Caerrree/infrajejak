import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hazard.dart';
import '../models/validation.dart';
import 'app_config.dart';
import 'mock_data_store.dart';

class FirestoreService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Future<List<Hazard>> getCommunityReports() async {
    if (AppConfig.useMockBackend) {
      return MockDataStore.instance.reports.values.toList()
        ..sort((a, b) => b.dateReported.compareTo(a.dateReported));
    }
    final snap = await _db
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => Hazard.fromFirestore(d.id, d.data())).toList();
  }

  Future<List<Hazard>> getReportsByUser(String userId) async {
    if (AppConfig.useMockBackend) {
      return MockDataStore.instance.reports.values
          .where((r) => r.reportedByUserId == userId)
          .toList();
    }
    final snap = await _db
        .collection('reports')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => Hazard.fromFirestore(d.id, d.data())).toList();
  }

  Future<String> submitReport(Hazard hazard) async {
    if (AppConfig.useMockBackend) {
      final id = MockDataStore.instance.newId();
      MockDataStore.instance.reports[id] = Hazard(
        id: id,
        type: hazard.type,
        source: HazardSource.community,
        latitude: hazard.latitude,
        longitude: hazard.longitude,
        roadName: hazard.roadName,
        description: hazard.description,
        photoUrl: hazard.photoUrl,
        severity: hazard.severity,
        status: HazardStatus.reported,
        dateReported: DateTime.now(),
        reportedByUserId: hazard.reportedByUserId,
      );
      return id;
    }
    final ref = await _db.collection('reports').add(hazard.toFirestoreMap());
    await _db.collection('status_history').add({
      'reportId': ref.id,
      'status': HazardStatus.reported.name,
      'updatedBy': hazard.reportedByUserId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    return ref.id;
  }

  Future<void> updateStatus({
    required String reportId,
    required HazardStatus status,
    required String updatedByUserId,
  }) async {
    if (AppConfig.useMockBackend) {
      final existing = MockDataStore.instance.reports[reportId];
      if (existing == null) return;
      MockDataStore.instance.reports[reportId] = Hazard(
        id: existing.id,
        type: existing.type,
        source: existing.source,
        latitude: existing.latitude,
        longitude: existing.longitude,
        roadName: existing.roadName,
        description: existing.description,
        photoUrl: existing.photoUrl,
        severity: existing.severity,
        status: status,
        dateReported: existing.dateReported,
        confirmationCount: existing.confirmationCount,
        disputeCount: existing.disputeCount,
        reportedByUserId: existing.reportedByUserId,
      );
      return;
    }
    await _db.collection('reports').doc(reportId).update({
      'status': status.name,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
    await _db.collection('status_history').add({
      'reportId': reportId,
      'status': status.name,
      'updatedBy': updatedByUserId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<bool> hasUserValidated({
    required String reportId,
    required String userId,
  }) async {
    if (AppConfig.useMockBackend) {
      return MockDataStore.instance.validations
          .any((v) => v.reportId == reportId && v.userId == userId);
    }
    final snap = await _db
        .collection('validations')
        .where('reportId', isEqualTo: reportId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> submitValidation({
    required String reportId,
    required String userId,
    required ValidationType type,
    String? photoUrl,
  }) async {
    final alreadyVoted = await hasUserValidated(reportId: reportId, userId: userId);
    if (alreadyVoted) {
      throw Exception('You have already validated this report.');
    }

    if (AppConfig.useMockBackend) {
      MockDataStore.instance.validations.add(HazardValidation(
        id: MockDataStore.instance.newId(),
        reportId: reportId,
        userId: userId,
        type: type,
        timestamp: DateTime.now(),
        photoUrl: photoUrl,
      ));
      final existing = MockDataStore.instance.reports[reportId];
      if (existing != null) {
        final confirms = existing.confirmationCount + (type == ValidationType.confirm ? 1 : 0);
        final disputes = existing.disputeCount + (type == ValidationType.dispute ? 1 : 0);
        final autoVerified = existing.status == HazardStatus.reported && confirms >= 5;
        MockDataStore.instance.reports[reportId] = Hazard(
          id: existing.id,
          type: existing.type,
          source: existing.source,
          latitude: existing.latitude,
          longitude: existing.longitude,
          roadName: existing.roadName,
          description: existing.description,
          photoUrl: existing.photoUrl,
          severity: existing.severity,
          status: autoVerified ? HazardStatus.communityVerified : existing.status,
          dateReported: existing.dateReported,
          confirmationCount: confirms,
          disputeCount: disputes,
          reportedByUserId: existing.reportedByUserId,
        );
      }
      return;
    }

    final reportRef = _db.collection('reports').doc(reportId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(reportRef);
      final data = snap.data() as Map<String, dynamic>;
      final field = type == ValidationType.confirm ? 'confirmationCount' : 'disputeCount';
      tx.update(reportRef, {
        field: ((data[field] as num?)?.toInt() ?? 0) + 1,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      final validationRef = _db.collection('validations').doc();
      tx.set(validationRef, HazardValidation(
        id: validationRef.id,
        reportId: reportId,
        userId: userId,
        type: type,
        timestamp: DateTime.now(),
        photoUrl: photoUrl,
      ).toFirestoreMap());
    });
  }
}

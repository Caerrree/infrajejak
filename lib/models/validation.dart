enum ValidationType { confirm, dispute }

class HazardValidation {
  final String id;
  final String reportId;
  final String userId;
  final ValidationType type;
  final DateTime timestamp;
  final String? photoUrl;

  const HazardValidation({
    required this.id,
    required this.reportId,
    required this.userId,
    required this.type,
    required this.timestamp,
    this.photoUrl,
  });

  factory HazardValidation.fromFirestore(String id, Map<String, dynamic> data) {
    return HazardValidation(
      id: id,
      reportId: data['reportId'] as String,
      userId: data['userId'] as String,
      type: (data['validationType'] as String) == 'confirm'
          ? ValidationType.confirm
          : ValidationType.dispute,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (data['createdAt'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      ),
      photoUrl: data['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'reportId': reportId,
      'userId': userId,
      'validationType': type == ValidationType.confirm ? 'confirm' : 'dispute',
      'createdAt': timestamp.millisecondsSinceEpoch,
      'photoUrl': photoUrl,
    };
  }
}

enum ActivityType {
  jump,         // Regular jump booking
  hourPurchase, // Purchase of trampoline hours
  extraHour,    // Extra hour on same session
  qrScan,       // QR code scan on return visit
  groupVisit,   // Group visit
  rewardRedemption // Redeeming a reward
}

class ActivityModel {
  final String id;
  final String userId;
  final ActivityType type;
  final int pointsEarned;
  final DateTime timestamp;
  final String? description;
  final int? participants; // For group visits

  ActivityModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.pointsEarned,
    required this.timestamp,
    this.description,
    this.participants,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: ActivityType.values.firstWhere(
        (e) => e.toString() == 'ActivityType.${json['type']}',
        orElse: () => ActivityType.jump,
      ),
      pointsEarned: json['pointsEarned'] as int,
      timestamp: DateTime.parse(json['timestamp']),
      description: json['description'] as String?,
      participants: json['participants'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'pointsEarned': pointsEarned,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'participants': participants,
    };
  }

  // Helper method to generate activity description
  static String getActivityDescription(ActivityType type, int points, {int? participants}) {
    switch (type) {
      case ActivityType.jump:
        return 'Jump booking (+$points points)';
      case ActivityType.hourPurchase:
        return 'Hour purchase (+$points points)';
      case ActivityType.extraHour:
        return 'Extra hour bonus (+$points points)';
      case ActivityType.qrScan:
        return 'Return visit scan (+$points points)';
      case ActivityType.groupVisit:
        return 'Group visit with ${participants ?? 0} people (+$points points)';
      case ActivityType.rewardRedemption:
        return 'Reward redemption (-$points points)';
    }
  }
} 
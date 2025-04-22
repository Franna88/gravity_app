import 'package:gravity_rewards_app/constants/app_constants.dart';

class RewardModel {
  final String id;
  final String name;
  final String description;
  final int pointsCost;
  final String? imageUrl;
  final DateTime expiryDate;
  final bool isActive;
  final Map<String, dynamic>? additionalInfo;

  RewardModel({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsCost,
    this.imageUrl,
    required this.expiryDate,
    required this.isActive,
    this.additionalInfo,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      pointsCost: json['pointsCost'] as int,
      imageUrl: json['imageUrl'] as String?,
      expiryDate: DateTime.parse(json['expiryDate']),
      isActive: json['isActive'] as bool,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pointsCost': pointsCost,
      'imageUrl': imageUrl,
      'expiryDate': expiryDate.toIso8601String(),
      'isActive': isActive,
      'additionalInfo': additionalInfo,
    };
  }

  // Helper method to check if reward is expired
  bool isExpired() {
    return DateTime.now().isAfter(expiryDate);
  }

  // Helper method to check if user has enough points
  bool canBeRedeemed(int userPoints) {
    return userPoints >= pointsCost && isActive && !isExpired();
  }

  // Demo rewards
  static List<RewardModel> getDemoRewards() {
    return [
      RewardModel(
        id: '1',
        name: 'Free Jump Session',
        description: 'Redeem for a free standard jump session (1 hour)',
        pointsCost: RewardsThresholds.freeJump,
        imageUrl: 'https://gravitype.co.za/wp-content/uploads/2015/11/open-jump-arena.jpg',
        expiryDate: DateTime.now().add(const Duration(days: 365)),
        isActive: true,
      ),
      RewardModel(
        id: '2',
        name: '10% Off Merchandise',
        description: 'Get 10% off any merchandise item in our store',
        pointsCost: RewardsThresholds.merchandise10PercentOff,
        imageUrl: 'https://gravitype.co.za/wp-content/uploads/2015/11/kids-group.jpg',
        expiryDate: DateTime.now().add(const Duration(days: 365)),
        isActive: true,
      ),
      RewardModel(
        id: '3',
        name: '20% Off Merchandise',
        description: 'Get 20% off any merchandise item in our store',
        pointsCost: RewardsThresholds.merchandise20PercentOff,
        imageUrl: 'https://gravitype.co.za/wp-content/uploads/2015/11/kids-group.jpg',
        expiryDate: DateTime.now().add(const Duration(days: 365)),
        isActive: true,
      ),
      RewardModel(
        id: '4',
        name: 'Free Party Room Hour',
        description: 'Get 1 hour free in one of our party rooms (Monday-Thursday)',
        pointsCost: RewardsThresholds.freePartyRoomHour,
        imageUrl: 'https://gravitype.co.za/wp-content/uploads/2015/11/home-bg.jpg',
        expiryDate: DateTime.now().add(const Duration(days: 365)),
        isActive: true,
      ),
      RewardModel(
        id: '5',
        name: 'Private Session Discount',
        description: '15% off a private session booking (valid for groups of 10+)',
        pointsCost: RewardsThresholds.privateSessionDiscount,
        imageUrl: 'https://gravitype.co.za/wp-content/uploads/2015/11/open-jump-arena.jpg',
        expiryDate: DateTime.now().add(const Duration(days: 365)),
        isActive: true,
      ),
    ];
  }
} 
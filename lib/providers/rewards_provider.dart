import 'package:flutter/foundation.dart';
import 'package:gravity_rewards_app/constants/app_constants.dart';
import 'package:gravity_rewards_app/models/reward_model.dart';
import 'package:gravity_rewards_app/services/notification_service.dart';

class RewardsProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<RewardModel> _availableRewards = [];
  Map<String, dynamic>? _selectedReward;
  List<Map<String, dynamic>> _redemptionHistory = [];
  bool _isLoading = false;
  String? _error;
  
  List<RewardModel> get availableRewards => _availableRewards;
  Map<String, dynamic>? get selectedReward => _selectedReward;
  List<Map<String, dynamic>> get redemptionHistory => _redemptionHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Helper to set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Helper to set error
  void setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
  
  // Get reward category (keeping for backward compatibility)
  String getRewardCategory(String rewardName) {
    final lowerName = rewardName.toLowerCase();
    if (lowerName.contains('jump') || lowerName.contains('session')) {
      return RewardCategories.freeJumps;
    } else if (lowerName.contains('discount') || lowerName.contains('off') || lowerName.contains('%')) {
      return RewardCategories.discounts;
    } else if (lowerName.contains('merch')) {
      return RewardCategories.merchandise;
    } else if (lowerName.contains('vip')) {
      return RewardCategories.vip;
    } else {
      return RewardCategories.special;
    }
  }
  
  // Get rewards by category
  List<RewardModel> getRewardsByCategory(String category) {
    return _availableRewards.where((reward) => reward.category == category).toList();
  }
  
  // Mock rewards data
  List<RewardModel> _getMockRewards() {
    final now = DateTime.now();
    return [
      RewardModel(
        id: 'reward-1',
        name: 'Free Jump Session',
        description: 'Enjoy a free 1-hour jump session at any Gravity Trampoline Park location.',
        pointsCost: 100,
        imageUrl: 'https://via.placeholder.com/300x200?text=Free+Jump',
        expiryDate: now.add(const Duration(days: 90)),
        isActive: true,
        category: RewardCategories.freeJumps,
        additionalInfo: {'canRedeem': true},
      ),
      RewardModel(
        id: 'reward-2',
        name: '10% Off Merchandise',
        description: 'Get 10% off any merchandise item in our shop.',
        pointsCost: 50,
        imageUrl: 'https://via.placeholder.com/300x200?text=10%+Off',
        expiryDate: now.add(const Duration(days: 60)),
        isActive: true,
        category: RewardCategories.discounts,
        additionalInfo: {'canRedeem': true},
      ),
      RewardModel(
        id: 'reward-3',
        name: 'Party Room Discount',
        description: 'Receive a 25% discount on party room bookings.',
        pointsCost: 250,
        imageUrl: 'https://via.placeholder.com/300x200?text=Party+Room',
        expiryDate: now.add(const Duration(days: 120)),
        isActive: true,
        category: RewardCategories.discounts,
        additionalInfo: {'canRedeem': true},
      ),
      RewardModel(
        id: 'reward-4',
        name: 'VIP Pass',
        description: 'Enjoy a full day of jumping with our exclusive VIP pass.',
        pointsCost: 500,
        imageUrl: 'https://via.placeholder.com/300x200?text=VIP+Pass',
        expiryDate: now.add(const Duration(days: 90)),
        isActive: true,
        category: RewardCategories.vip,
        additionalInfo: {'canRedeem': false},
      ),
      RewardModel(
        id: 'reward-5',
        name: 'Gravity T-Shirt',
        description: 'Get a free Gravity branded t-shirt in your size.',
        pointsCost: 200,
        imageUrl: 'https://via.placeholder.com/300x200?text=Gravity+Shirt',
        expiryDate: now.add(const Duration(days: 90)),
        isActive: true,
        category: RewardCategories.merchandise,
        additionalInfo: {'canRedeem': true},
      ),
      RewardModel(
        id: 'reward-6',
        name: 'Special Event Access',
        description: 'Get exclusive access to our next special event.',
        pointsCost: 300,
        imageUrl: 'https://via.placeholder.com/300x200?text=Special+Event',
        expiryDate: now.add(const Duration(days: 45)),
        isActive: true,
        category: RewardCategories.special,
        additionalInfo: {'canRedeem': false},
      ),
    ];
  }
  
  // Load all available rewards
  Future<void> loadAvailableRewards() async {
    try {
      setLoading(true);
      setError(null);
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      _availableRewards = _getMockRewards();
      
      setLoading(false);
    } catch (e) {
      setLoading(false);
      setError(e.toString());
    }
  }
  
  // Load rewards based on user points
  Future<void> loadRewardsForUser(String userId) async {
    try {
      setLoading(true);
      setError(null);
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      _availableRewards = _getMockRewards();
      
      setLoading(false);
    } catch (e) {
      setLoading(false);
      setError(e.toString());
    }
  }
  
  // Set selected reward
  void selectReward(RewardModel reward) {
    _selectedReward = {
      'id': reward.id,
      'name': reward.name,
      'description': reward.description,
      'pointsCost': reward.pointsCost is int ? reward.pointsCost : int.tryParse(reward.pointsCost.toString()) ?? 0,
      'imageUrl': reward.imageUrl,
      'expiryDate': reward.expiryDate.toIso8601String(),
      'isActive': reward.isActive,
      'category': reward.category,
      'canRedeem': reward.additionalInfo?['canRedeem'] ?? false,
    };
    notifyListeners();
  }
  
  // Clear selected reward
  void clearSelectedReward() {
    _selectedReward = null;
    notifyListeners();
  }
  
  // Redeem reward
  Future<bool> redeemReward(String userId) async {
    try {
      if (_selectedReward == null) {
        return false;
      }
      
      setLoading(true);
      setError(null);
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      final String rewardName = _selectedReward!['name'];
      final String category = _selectedReward!['category'] ?? getRewardCategory(rewardName);
      final int pointsCost = _selectedReward!['pointsCost'] is int 
          ? _selectedReward!['pointsCost'] 
          : int.tryParse(_selectedReward!['pointsCost'].toString()) ?? 0;
      final String expiryDateStr = _selectedReward!['expiryDate'];
      final DateTime expiryDate = DateTime.parse(expiryDateStr);
      
      // Add to redemption history
      _redemptionHistory.add({
        'activityId': 'activity-${DateTime.now().millisecondsSinceEpoch}',
        'timestamp': DateTime.now(),
        'pointsSpent': pointsCost,
        'rewardName': rewardName,
        'category': category,
        'expiryDate': expiryDate.add(const Duration(days: 30)), // Rewards expire after 30 days
      });
      
      // Try to show notification but continue even if it fails
      try {
        await _notificationService.showRewardRedeemedNotification(rewardName);
      } catch (notificationError) {
        // Log the error but don't fail the redemption process
        debugPrint('Failed to show notification: $notificationError');
      }
      
      // For UI testing, always return success
      final bool success = true;
      
      setLoading(false);
      return success;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  // Load redemption history
  Future<void> loadRedemptionHistory(String userId) async {
    try {
      setLoading(true);
      setError(null);
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // If we already have history, don't override it with mock data
      if (_redemptionHistory.isEmpty) {
        // Mock redemption history
        final now = DateTime.now();
        _redemptionHistory = [
          {
            'activityId': 'activity-1',
            'timestamp': now.subtract(const Duration(days: 5)),
            'pointsSpent': 100,
            'rewardName': 'Free Jump Session',
            'category': 'booking',
            'expiryDate': now.add(const Duration(days: 25)),
          },
          {
            'activityId': 'activity-2',
            'timestamp': now.subtract(const Duration(days: 15)),
            'pointsSpent': 50,
            'rewardName': '10% Off Merchandise',
            'category': 'merchandise',
            'expiryDate': now.add(const Duration(days: 15)),
          },
          {
            'activityId': 'activity-3',
            'timestamp': now.subtract(const Duration(days: 30)),
            'pointsSpent': 250,
            'rewardName': 'Party Room Discount',
            'category': 'booking',
            'expiryDate': now.subtract(const Duration(days: 1)), // Expired
          },
        ];
      }
      
      setLoading(false);
    } catch (e) {
      setLoading(false);
      setError(e.toString());
    }
  }
  
  // Check if user is approaching a reward threshold
  Future<void> checkRewardThresholds(int userPoints) async {
    try {
      await _notificationService.checkAndNotifyRewardThresholds(userPoints);
    } catch (e) {
      debugPrint('Check reward thresholds error: $e');
    }
  }
} 
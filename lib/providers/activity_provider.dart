import 'package:flutter/foundation.dart';
import 'package:gravity_rewards_app/models/activity_model.dart';
import 'package:gravity_rewards_app/services/notification_service.dart';
import 'package:gravity_rewards_app/providers/rewards_provider.dart';
import 'package:gravity_rewards_app/constants/app_constants.dart';

class ActivityProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<ActivityModel> _activityHistory = [];
  int _currentPoints = 350; // Starting points for UI development
  bool _isLoading = false;
  String? _error;
  
  List<ActivityModel> get activityHistory => _activityHistory;
  int get currentPoints => _currentPoints;
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
  
  // Generate mock activity history
  List<ActivityModel> _getMockActivityHistory() {
    final now = DateTime.now();
    return [
      ActivityModel(
        id: 'activity1',
        userId: 'mock-user-123',
        type: ActivityType.jump,
        pointsEarned: PointsConstants.pointsPerJump,
        timestamp: now.subtract(const Duration(days: 2)),
        description: 'Jump session',
      ),
      ActivityModel(
        id: 'activity2',
        userId: 'mock-user-123',
        type: ActivityType.hourPurchase,
        pointsEarned: PointsConstants.pointsPerHour * 2,
        timestamp: now.subtract(const Duration(days: 5)),
        description: 'Purchased 2 hours',
      ),
      ActivityModel(
        id: 'activity3',
        userId: 'mock-user-123',
        type: ActivityType.qrScan,
        pointsEarned: PointsConstants.pointsForScan,
        timestamp: now.subtract(const Duration(days: 8)),
        description: 'Scanned QR code',
      ),
      ActivityModel(
        id: 'activity4',
        userId: 'mock-user-123',
        type: ActivityType.rewardRedemption,
        pointsEarned: -100,
        timestamp: now.subtract(const Duration(days: 12)),
        description: 'Redeemed: Free Jump Session',
      ),
      ActivityModel(
        id: 'activity5',
        userId: 'mock-user-123',
        type: ActivityType.groupVisit,
        pointsEarned: PointsConstants.pointsPerGroupMember * 3,
        timestamp: now.subtract(const Duration(days: 15)),
        description: 'Group visit with 3 friends',
      ),
    ];
  }
  
  // Load user's points
  Future<void> loadUserPoints(String userId) async {
    try {
      setLoading(true);
      setError(null);
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // _currentPoints is already set to 350 as default
      
      setLoading(false);
    } catch (e) {
      setLoading(false);
      setError(e.toString());
    }
  }
  
  // Load user's activity history
  Future<void> loadActivityHistory(String userId) async {
    try {
      setLoading(true);
      setError(null);
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      _activityHistory = _getMockActivityHistory();
      
      setLoading(false);
    } catch (e) {
      setLoading(false);
      setError(e.toString());
    }
  }
  
  // Add points for a jump
  Future<bool> addJumpPoints(String userId, RewardsProvider rewardsProvider) async {
    try {
      setLoading(true);
      setError(null);
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Update points
      _currentPoints += PointsConstants.pointsPerJump;
      
      // Add to activity history
      final now = DateTime.now();
      _activityHistory.insert(0, ActivityModel(
        id: 'activity-${now.millisecondsSinceEpoch}',
        userId: userId,
        type: ActivityType.jump,
        pointsEarned: PointsConstants.pointsPerJump,
        timestamp: now,
        description: 'Jump session',
      ));
      
      // Show notification
      await _notificationService.showPointsEarnedNotification(PointsConstants.pointsPerJump);
      
      // Check if user is approaching a reward threshold
      await rewardsProvider.checkRewardThresholds(_currentPoints);
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  // Add points for hours purchased
  Future<bool> addHourPurchasePoints(String userId, int hours, RewardsProvider rewardsProvider) async {
    try {
      setLoading(true);
      setError(null);
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Update points
      final pointsToAdd = PointsConstants.pointsPerHour * hours;
      _currentPoints += pointsToAdd;
      
      // Add to activity history
      final now = DateTime.now();
      _activityHistory.insert(0, ActivityModel(
        id: 'activity-${now.millisecondsSinceEpoch}',
        userId: userId,
        type: ActivityType.hourPurchase,
        pointsEarned: pointsToAdd,
        timestamp: now,
        description: 'Purchased $hours hours',
      ));
      
      // Show notification
      await _notificationService.showPointsEarnedNotification(pointsToAdd);
      
      // Check if user is approaching a reward threshold
      await rewardsProvider.checkRewardThresholds(_currentPoints);
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  // Add bonus points for extra hour
  Future<bool> addExtraHourPoints(String userId, RewardsProvider rewardsProvider) async {
    try {
      setLoading(true);
      setError(null);
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Update points
      _currentPoints += PointsConstants.bonusPointsForExtraHour;
      
      // Add to activity history
      final now = DateTime.now();
      _activityHistory.insert(0, ActivityModel(
        id: 'activity-${now.millisecondsSinceEpoch}',
        userId: userId,
        type: ActivityType.extraHour,
        pointsEarned: PointsConstants.bonusPointsForExtraHour,
        timestamp: now,
        description: 'Bonus for extra hour',
      ));
      
      // Show notification
      await _notificationService.showPointsEarnedNotification(PointsConstants.bonusPointsForExtraHour);
      
      // Check if user is approaching a reward threshold
      await rewardsProvider.checkRewardThresholds(_currentPoints);
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  // Add points for QR code scan
  Future<bool> validateQrCodeAndAddPoints(String userId, String qrCodeData, RewardsProvider rewardsProvider) async {
    try {
      setLoading(true);
      setError(null);
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Update points
      _currentPoints += PointsConstants.pointsForScan;
      
      // Add to activity history
      final now = DateTime.now();
      _activityHistory.insert(0, ActivityModel(
        id: 'activity-${now.millisecondsSinceEpoch}',
        userId: userId,
        type: ActivityType.qrScan,
        pointsEarned: PointsConstants.pointsForScan,
        timestamp: now,
        description: 'Scanned QR code',
      ));
      
      // Show notification
      await _notificationService.showPointsEarnedNotification(PointsConstants.pointsForScan);
      
      // Check if user is approaching a reward threshold
      await rewardsProvider.checkRewardThresholds(_currentPoints);
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  // Add points for group visit
  Future<bool> addGroupVisitPoints(String userId, int participants, RewardsProvider rewardsProvider) async {
    try {
      setLoading(true);
      setError(null);
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Update points
      final pointsToAdd = PointsConstants.pointsPerGroupMember * participants;
      _currentPoints += pointsToAdd;
      
      // Add to activity history
      final now = DateTime.now();
      _activityHistory.insert(0, ActivityModel(
        id: 'activity-${now.millisecondsSinceEpoch}',
        userId: userId,
        type: ActivityType.groupVisit,
        pointsEarned: pointsToAdd,
        timestamp: now,
        description: 'Group visit with $participants friends',
      ));
      
      // Show notification
      await _notificationService.showPointsEarnedNotification(pointsToAdd);
      
      // Check if user is approaching a reward threshold
      await rewardsProvider.checkRewardThresholds(_currentPoints);
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  // Refresh all data
  Future<void> refreshData(String userId, RewardsProvider rewardsProvider) async {
    try {
      setLoading(true);
      setError(null);
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      await loadUserPoints(userId);
      await loadActivityHistory(userId);
      await rewardsProvider.loadRewardsForUser(userId);
      await rewardsProvider.loadRedemptionHistory(userId);
      
      setLoading(false);
    } catch (e) {
      setLoading(false);
      setError(e.toString());
    }
  }
} 
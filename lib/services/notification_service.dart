import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  
  // Initialize notifications
  Future<void> init() async {
    try {
      const AndroidInitializationSettings initSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const DarwinInitializationSettings initSettingsIOS = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );
      
      const InitializationSettings initSettings = InitializationSettings(
        android: initSettingsAndroid,
        iOS: initSettingsIOS,
      );
      
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
          // Handle notification tap based on payload
        },
      );
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
      _isInitialized = false;
    }
  }
  
  // Show a basic notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Skip if not initialized
    if (!_isInitialized) {
      debugPrint('Notification service not initialized. Skipping notification.');
      return;
    }
    
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'gravity_rewards_channel',
        'Gravity Rewards',
        channelDescription: 'Notifications from Gravity Rewards app',
        importance: Importance.high,
        priority: Priority.high,
        color: Color(0xFFF36122), // Primary color
      );
      
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _notifications.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Failed to show notification: $e');
      // Don't rethrow, so calling code continues execution
    }
  }
  
  // Show a notification when points are earned
  Future<void> showPointsEarnedNotification(int points) async {
    await showNotification(
      id: 1,
      title: 'Points Earned!',
      body: 'You just earned $points points at Gravity Indoor Trampoline Park!',
      payload: 'points_earned',
    );
  }
  
  // Show a notification when approaching a reward threshold
  Future<void> showRewardThresholdNotification(int currentPoints, int threshold, String rewardName) async {
    final int pointsNeeded = threshold - currentPoints;
    
    await showNotification(
      id: 2,
      title: 'Almost There!',
      body: 'You\'re only $pointsNeeded points away from earning $rewardName!',
      payload: 'reward_threshold',
    );
  }
  
  // Show a notification when a reward is redeemed
  Future<void> showRewardRedeemedNotification(String rewardName) async {
    await showNotification(
      id: 3,
      title: 'Reward Redeemed!',
      body: 'You\'ve successfully redeemed $rewardName. Enjoy your reward!',
      payload: 'reward_redeemed',
    );
  }
  
  // Show a notification for a special promotion
  Future<void> showPromotionNotification(String promotionTitle, String promotionDetails) async {
    await showNotification(
      id: 4,
      title: 'Special Promotion: $promotionTitle',
      body: promotionDetails,
      payload: 'promotion',
    );
  }
  
  // Check for reward thresholds and notify if close
  Future<void> checkAndNotifyRewardThresholds(int userPoints) async {
    // Import these from app_constants in a real implementation
    const Map<int, String> thresholds = {
      100: 'Free Jump Session',
      200: '10% Off Merchandise',
      350: '20% Off Merchandise',
      500: 'Free Party Room Hour',
      750: 'Private Session Discount',
    };
    
    // Find the next threshold
    int? nextThreshold;
    String? nextRewardName;
    
    for (final entry in thresholds.entries) {
      if (entry.key > userPoints && (nextThreshold == null || entry.key < nextThreshold)) {
        nextThreshold = entry.key;
        nextRewardName = entry.value;
      }
    }
    
    // If within 20 points of the next threshold, send a notification
    if (nextThreshold != null && nextRewardName != null) {
      final int difference = nextThreshold - userPoints;
      if (difference <= 20) {
        await showRewardThresholdNotification(userPoints, nextThreshold, nextRewardName);
      }
    }
  }
} 
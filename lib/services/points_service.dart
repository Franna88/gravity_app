import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gravity_rewards_app/models/activity_model.dart';
import 'package:gravity_rewards_app/constants/app_constants.dart';
import 'package:gravity_rewards_app/models/user_model.dart';
import 'package:uuid/uuid.dart';

class PointsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Add points for a regular jump
  Future<bool> addJumpPoints(String userId) async {
    return await _addPoints(
      userId: userId,
      points: PointsConstants.pointsPerJump,
      type: ActivityType.jump,
      description: 'Jump booking',
    );
  }

  // Add points for purchased hours
  Future<bool> addHourPurchasePoints(String userId, int hours) async {
    return await _addPoints(
      userId: userId,
      points: PointsConstants.pointsPerHour * hours,
      type: ActivityType.hourPurchase,
      description: 'Purchased $hours hours',
    );
  }

  // Add bonus points for extra hour
  Future<bool> addExtraHourPoints(String userId) async {
    return await _addPoints(
      userId: userId,
      points: PointsConstants.bonusPointsForExtraHour,
      type: ActivityType.extraHour,
      description: 'Extra hour bonus',
    );
  }

  // Add points for QR scan (return visit)
  Future<bool> addScanPoints(String userId) async {
    return await _addPoints(
      userId: userId,
      points: PointsConstants.pointsForScan,
      type: ActivityType.qrScan,
      description: 'Return visit QR scan',
    );
  }

  // Add points for group visit
  Future<bool> addGroupVisitPoints(String userId, int participants) async {
    return await _addPoints(
      userId: userId,
      points: PointsConstants.pointsPerGroupMember * participants,
      type: ActivityType.groupVisit,
      description: 'Group visit with $participants people',
      participants: participants,
    );
  }

  // Deduct points when redeeming a reward
  Future<bool> deductRewardPoints(String userId, int pointsCost, String rewardId, String rewardName) async {
    try {
      // Check if user has enough points
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        return false;
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      final int currentPoints = userData['points'] as int;
      
      if (currentPoints < pointsCost) {
        return false;
      }
      
      // Create batch operation
      final batch = _firestore.batch();
      
      // Create activity record
      final String activityId = _uuid.v4();
      final activityRef = _firestore.collection('activities').doc(activityId);
      
      final ActivityModel activity = ActivityModel(
        id: activityId,
        userId: userId,
        type: ActivityType.rewardRedemption,
        pointsEarned: -pointsCost, // Negative value for deduction
        timestamp: DateTime.now(),
        description: 'Redeemed: $rewardName',
      );
      
      batch.set(activityRef, activity.toJson());
      
      // Update user points and add to reward history
      final userRef = _firestore.collection('users').doc(userId);
      
      batch.update(userRef, {
        'points': FieldValue.increment(-pointsCost),
        'rewardHistory': FieldValue.arrayUnion([activityId]),
        'activityHistory': FieldValue.arrayUnion([activityId]),
      });
      
      // Commit batch operation
      await batch.commit();
      
      return true;
    } catch (e) {
      debugPrint('Deduct reward points error: $e');
      return false;
    }
  }

  // Private method to add points
  Future<bool> _addPoints({
    required String userId,
    required int points,
    required ActivityType type,
    required String description,
    int? participants,
  }) async {
    try {
      // Create batch operation
      final batch = _firestore.batch();
      
      // Create activity record
      final String activityId = _uuid.v4();
      final activityRef = _firestore.collection('activities').doc(activityId);
      
      final ActivityModel activity = ActivityModel(
        id: activityId,
        userId: userId,
        type: type,
        pointsEarned: points,
        timestamp: DateTime.now(),
        description: description,
        participants: participants,
      );
      
      batch.set(activityRef, activity.toJson());
      
      // Update user points and add to activity history
      final userRef = _firestore.collection('users').doc(userId);
      
      batch.update(userRef, {
        'points': FieldValue.increment(points),
        'activityHistory': FieldValue.arrayUnion([activityId]),
      });
      
      // Commit batch operation
      await batch.commit();
      
      return true;
    } catch (e) {
      debugPrint('Add points error: $e');
      return false;
    }
  }
  
  // Get user's activity history
  Future<List<ActivityModel>> getUserActivityHistory(String userId) async {
    try {
      final List<ActivityModel> activities = [];
      
      final querySnapshot = await _firestore
          .collection('activities')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();
      
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        activities.add(ActivityModel.fromJson({'id': doc.id, ...data}));
      }
      
      return activities;
    } catch (e) {
      debugPrint('Get activity history error: $e');
      return [];
    }
  }
  
  // Get user's current points
  Future<int> getUserPoints(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        return 0;
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      return userData['points'] as int;
    } catch (e) {
      debugPrint('Get user points error: $e');
      return 0;
    }
  }
  
  // Validate QR code and add points
  Future<bool> validateQrCodeAndAddPoints(String userId, String qrCodeData) async {
    // In a real app, you'd validate the QR code content here
    // For demo purposes, we'll just check if it contains a specific string
    if (qrCodeData.contains('gravity_rewards')) {
      return await addScanPoints(userId);
    }
    return false;
  }
} 
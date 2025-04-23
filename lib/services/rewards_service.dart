import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gravity_rewards_app/models/activity_model.dart';
import 'package:gravity_rewards_app/models/reward_model.dart';
import 'package:gravity_rewards_app/services/points_service.dart';

class RewardsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PointsService _pointsService = PointsService();

  // Get all available rewards
  Future<List<RewardModel>> getAvailableRewards() async {
    try {
      final querySnapshot = await _firestore
          .collection('rewards')
          .where('isActive', isEqualTo: true)
          .orderBy('pointsCost')
          .get();
      
      final List<RewardModel> rewards = [];
      
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        rewards.add(RewardModel.fromJson({'id': doc.id, ...data}));
      }
      
      return rewards;
    } catch (e) {
      debugPrint('Get available rewards error: $e');
      // For demo purposes, return demo rewards
      return RewardModel.getDemoRewards();
    }
  }

  // Get a specific reward by ID
  Future<RewardModel?> getRewardById(String rewardId) async {
    try {
      final docSnapshot = await _firestore.collection('rewards').doc(rewardId).get();
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return RewardModel.fromJson({'id': docSnapshot.id, ...data});
      }
      
      return null;
    } catch (e) {
      debugPrint('Get reward by ID error: $e');
      
      // For demo purposes, find the reward in demo data
      final demoRewards = RewardModel.getDemoRewards();
      return demoRewards.firstWhere(
        (reward) => reward.id == rewardId,
        orElse: () => demoRewards.first,
      );
    }
  }

  // Get rewards based on user's points
  Future<List<RewardModel>> getRewardsForUser(String userId) async {
    try {
      final int userPoints = await _pointsService.getUserPoints(userId);
      final List<RewardModel> availableRewards = await getAvailableRewards();
      
      // Mark which rewards the user can claim
      return availableRewards.map((reward) {
        if (reward.pointsCost <= userPoints) {
          // Create a copy with additional info
          final Map<String, dynamic> additionalInfo = 
              reward.additionalInfo?.cast<String, dynamic>() ?? {};
          additionalInfo['canRedeem'] = true;
          
          return RewardModel(
            id: reward.id,
            name: reward.name,
            description: reward.description,
            pointsCost: reward.pointsCost,
            imageUrl: reward.imageUrl,
            expiryDate: reward.expiryDate,
            isActive: reward.isActive,
            category: reward.category,
            additionalInfo: additionalInfo,
          );
        }
        return reward;
      }).toList();
    } catch (e) {
      debugPrint('Get rewards for user error: $e');
      return RewardModel.getDemoRewards();
    }
  }

  // Redeem a reward
  Future<bool> redeemReward(String userId, String rewardId) async {
    try {
      // Get reward details
      final RewardModel? reward = await getRewardById(rewardId);
      
      if (reward == null || !reward.isActive || reward.isExpired()) {
        return false;
      }
      
      // Check if user has enough points
      final int userPoints = await _pointsService.getUserPoints(userId);
      
      if (userPoints < reward.pointsCost) {
        return false;
      }
      
      // Deduct points and record the redemption
      return await _pointsService.deductRewardPoints(
        userId,
        reward.pointsCost,
        rewardId,
        reward.name,
      );
    } catch (e) {
      debugPrint('Redeem reward error: $e');
      return false;
    }
  }

  // Get user's redemption history
  Future<List<Map<String, dynamic>>> getUserRedemptionHistory(String userId) async {
    try {
      // Get user's activity history
      final activities = await _pointsService.getUserActivityHistory(userId);
      
      // Filter for redemption activities
      final redemptionActivities = activities
          .where((activity) => activity.type == ActivityType.rewardRedemption)
          .toList();
      
      // Create a detailed history with reward info
      final List<Map<String, dynamic>> history = [];
      
      for (final activity in redemptionActivities) {
        final description = activity.description ?? '';
        // Extract reward name from description (format: "Redeemed: Reward Name")
        final rewardName = description.startsWith('Redeemed: ')
            ? description.substring('Redeemed: '.length)
            : description;
        
        history.add({
          'activityId': activity.id,
          'timestamp': activity.timestamp,
          'pointsSpent': -activity.pointsEarned, // Convert negative to positive
          'rewardName': rewardName,
        });
      }
      
      return history;
    } catch (e) {
      debugPrint('Get user redemption history error: $e');
      return [];
    }
  }
} 
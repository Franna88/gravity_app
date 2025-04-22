import 'package:flutter/material.dart';
import 'package:gravity_rewards_app/constants/app_constants.dart';
import 'package:gravity_rewards_app/models/activity_model.dart';
import 'package:intl/intl.dart';

class ActivityListItem extends StatelessWidget {
  final ActivityModel activity;

  const ActivityListItem({Key? key, required this.activity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isRedemption = activity.type == ActivityType.rewardRedemption;
    final String formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(activity.timestamp);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Row(
          children: [
            // Activity icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isRedemption
                    ? Colors.red.withOpacity(0.1)
                    : AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getActivityIcon(activity.type),
                color: isRedemption ? Colors.red : AppColors.accent,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Activity details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getActivityTitle(activity.type),
                    style: AppTextStyles.headline3.copyWith(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.description ?? _getActivityDescription(activity),
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: AppTextStyles.subtitle.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            // Points indicator
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isRedemption
                    ? Colors.red.withOpacity(0.1)
                    : AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isRedemption
                    ? '−${activity.pointsEarned.abs()} pts'
                    : '+${activity.pointsEarned} pts',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isRedemption ? Colors.red : AppColors.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.jump:
        return Icons.sports_gymnastics;
      case ActivityType.hourPurchase:
        return Icons.timer;
      case ActivityType.extraHour:
        return Icons.more_time;
      case ActivityType.qrScan:
        return Icons.qr_code_scanner;
      case ActivityType.groupVisit:
        return Icons.group;
      case ActivityType.rewardRedemption:
        return Icons.redeem;
    }
  }

  String _getActivityTitle(ActivityType type) {
    switch (type) {
      case ActivityType.jump:
        return 'Jump Booking';
      case ActivityType.hourPurchase:
        return 'Hour Purchase';
      case ActivityType.extraHour:
        return 'Extra Hour Bonus';
      case ActivityType.qrScan:
        return 'Return Visit Scan';
      case ActivityType.groupVisit:
        return 'Group Visit';
      case ActivityType.rewardRedemption:
        return 'Reward Redemption';
    }
  }

  String _getActivityDescription(ActivityModel activity) {
    return ActivityModel.getActivityDescription(
      activity.type,
      activity.pointsEarned.abs(),
      participants: activity.participants,
    );
  }
} 
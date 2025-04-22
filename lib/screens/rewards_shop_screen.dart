import 'package:flutter/material.dart';
import 'package:gravity_rewards_app/constants/app_constants.dart';
import 'package:gravity_rewards_app/models/reward_model.dart';
import 'package:gravity_rewards_app/providers/activity_provider.dart';
import 'package:gravity_rewards_app/providers/auth_provider.dart';
import 'package:gravity_rewards_app/providers/rewards_provider.dart';
import 'package:gravity_rewards_app/screens/reward_details_screen.dart';
import 'package:gravity_rewards_app/widgets/reward_card.dart';
import 'package:provider/provider.dart';

class RewardsShopScreen extends StatefulWidget {
  const RewardsShopScreen({Key? key}) : super(key: key);

  @override
  State<RewardsShopScreen> createState() => _RewardsShopScreenState();
}

class _RewardsShopScreenState extends State<RewardsShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRewards();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRewards() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final rewardsProvider = Provider.of<RewardsProvider>(context, listen: false);

    if (authProvider.user != null) {
      await rewardsProvider.loadRewardsForUser(authProvider.user!.id);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshRewards() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final rewardsProvider = Provider.of<RewardsProvider>(context, listen: false);

    if (authProvider.user != null) {
      await rewardsProvider.loadRewardsForUser(authProvider.user!.id);
    }
  }

  void _viewRewardDetails(RewardModel reward) {
    final rewardsProvider = Provider.of<RewardsProvider>(context, listen: false);
    rewardsProvider.selectReward(reward);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RewardDetailsScreen(),
      ),
    ).then((_) => _refreshRewards());
  }

  @override
  Widget build(BuildContext context) {
    final rewardsProvider = Provider.of<RewardsProvider>(context);
    final activityProvider = Provider.of<ActivityProvider>(context);
    final rewards = rewardsProvider.availableRewards;
    
    final rewardsUserCanClaim = rewards.where((reward) => 
      reward.additionalInfo?['canRedeem'] == true).toList();
    
    final rewardsUserCannotClaim = rewards.where((reward) => 
      reward.additionalInfo?['canRedeem'] != true).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rewards Shop'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Rewards'),
            Tab(text: 'Available to Claim'),
          ],
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Points bar
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  color: AppColors.accent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.stars_rounded,
                            color: AppColors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Your Points:',
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${activityProvider.currentPoints}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // All rewards tab
                      RefreshIndicator(
                        onRefresh: _refreshRewards,
                        child: rewards.isEmpty
                            ? _buildEmptyState('No rewards available at the moment. Check back later!')
                            : _buildRewardsList(rewards),
                      ),
                      
                      // Available to claim tab
                      RefreshIndicator(
                        onRefresh: _refreshRewards,
                        child: rewardsUserCanClaim.isEmpty
                            ? _buildEmptyState(
                                'You don\'t have enough points to claim any rewards yet. Keep earning points!')
                            : _buildRewardsList(rewardsUserCanClaim),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.card_giftcard,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Rewards Available',
              style: AppTextStyles.headline2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshRewards,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLarge,
                  vertical: AppDimensions.paddingMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsList(List<RewardModel> rewards) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: RewardCard(
            reward: rewards[index],
            onPressed: () => _viewRewardDetails(rewards[index]),
          ),
        );
      },
    );
  }
} 
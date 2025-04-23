import 'package:flutter/material.dart';
import 'package:gravity_rewards_app/constants/app_constants.dart';
import 'package:gravity_rewards_app/models/reward_model.dart';
import 'package:gravity_rewards_app/providers/activity_provider.dart';
import 'package:gravity_rewards_app/providers/auth_provider.dart';
import 'package:gravity_rewards_app/providers/rewards_provider.dart';
import 'package:gravity_rewards_app/screens/activity_history_screen.dart';
import 'package:gravity_rewards_app/screens/profile_screen.dart';
import 'package:gravity_rewards_app/screens/qr_scanner_screen.dart';
import 'package:gravity_rewards_app/screens/reward_details_screen.dart';
import 'package:gravity_rewards_app/screens/rewards_shop_screen.dart';
import 'package:gravity_rewards_app/widgets/custom_button.dart';
import 'package:gravity_rewards_app/widgets/points_card.dart';
import 'package:gravity_rewards_app/widgets/reward_card.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isLoading = false;
  
  // Animation controllers
  late AnimationController _buttonController;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  
  // For floating bubbles
  late AnimationController _bubblesController;
  final List<_Bubble> _bubbles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    // Initialize animations
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    );
    
    // Create a continuously repeating animation controller for bubbles
    _bubblesController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    // Make sure the animation loops continuously
    _bubblesController.repeat();
    
    // Initialize bubbles after first frame is rendered
    _initBubbles();
    
    // Start the loading animation
    _slideController.forward();
  }
  
  void _initBubbles() {
    // Create some initial bubbles with safe values for immediate rendering
    _bubbles.clear();
    for (int i = 0; i < 12; i++) {
      _bubbles.add(_Bubble(
        position: Offset(
          50.0 + i * 30, // Spread out horizontally
          50.0 + (i % 3) * 100, // Place at different vertical positions
        ),
        size: 15.0 + (i % 5) * 4,
        color: _getRandomColor().withOpacity(0.2),
        speed: 0.3 + (i % 5) * 0.1,
      ));
    }
    
    // Then update bubbles after layout with proper sizing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final width = MediaQuery.of(context).size.width;
      final height = MediaQuery.of(context).size.height;
      
      _bubbles.clear();
      for (int i = 0; i < 12; i++) {
        _bubbles.add(_Bubble(
          position: Offset(
            _random.nextDouble() * width,
            _random.nextDouble() * height,
          ),
          size: _random.nextDouble() * 30 + 10,
          color: _getRandomColor().withOpacity(_random.nextDouble() * 0.2 + 0.1),
          speed: _random.nextDouble() * 0.2 + 0.1,
        ));
      }
      setState(() {}); // Trigger a rebuild with the new bubbles
    });
  }
  
  Color _getRandomColor() {
    final colors = [
      AppColors.primary,
      AppColors.accent,
      Colors.blue,
      Colors.purple,
      Colors.pink,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
    final rewardsProvider = Provider.of<RewardsProvider>(context, listen: false);

    if (authProvider.user != null) {
      await activityProvider.loadUserPoints(authProvider.user!.id);
      await activityProvider.loadActivityHistory(authProvider.user!.id);
      await rewardsProvider.loadRewardsForUser(authProvider.user!.id);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
    final rewardsProvider = Provider.of<RewardsProvider>(context, listen: false);

    if (authProvider.user != null) {
      await activityProvider.refreshData(authProvider.user!.id, rewardsProvider);
    }
  }

  Future<void> _scanQrCode() async {
    _animateButton();
    await Future.delayed(const Duration(milliseconds: 200));
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QrScannerScreen(),
      ),
    );
  }

  void _viewRewards() {
    _animateButton();
    Future.delayed(const Duration(milliseconds: 200), () {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const RewardsShopScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      );
    });
  }

  void _viewProfile() {
    _animateButton();
    Future.delayed(const Duration(milliseconds: 200), () {
      Navigator.pushNamed(context, AppRoutes.profile);
    });
  }

  void _viewClaimedRewards() {
    _animateButton();
    Future.delayed(const Duration(milliseconds: 200), () {
      Navigator.pushNamed(context, AppRoutes.claimedRewards);
    });
  }

  void _viewActivityHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ActivityHistoryScreen(),
      ),
    );
  }

  void _viewRewardDetails(RewardModel reward) {
    final rewardsProvider = Provider.of<RewardsProvider>(context, listen: false);
    rewardsProvider.selectReward(reward);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RewardDetailsScreen(),
      ),
    );
  }
  
  void _animateButton() {
    _buttonController.forward(from: 0.0);
  }
  
  @override
  void dispose() {
    _buttonController.dispose();
    _slideController.dispose();
    _bubblesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final activityProvider = Provider.of<ActivityProvider>(context);
    final rewardsProvider = Provider.of<RewardsProvider>(context);
    final size = MediaQuery.of(context).size;
    
    if (authProvider.user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final user = authProvider.user!;
    final rewards = rewardsProvider.availableRewards;
    final rewardsUserCanClaim = rewards.where((reward) => 
      reward.additionalInfo?['canRedeem'] == true).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1200),
              tween: Tween<double>(begin: 0, end: 1),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Image.asset(
                'images/Gravity-Logo.png',
                height: 32,
              ),
            ),
            const SizedBox(width: 8),
           
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: _viewProfile,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Animated background bubbles
          AnimatedBuilder(
            animation: _bubblesController,
            builder: (context, child) {
              return CustomPaint(
                painter: _BubblesPainter(
                  bubbles: _bubbles,
                  progress: _bubblesController.value,
                ),
                size: size,
              );
            },
          ),
          
          // Main content
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _refreshData,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Welcome section
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, -0.2),
                                end: Offset.zero,
                              ).animate(_slideAnimation),
                              child: FadeTransition(
                                opacity: _slideAnimation,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary.withOpacity(0.9),
                                        AppColors.primary.withOpacity(0.7),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.3),
                                        offset: const Offset(0, 4),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              offset: const Offset(0, 2),
                                              blurRadius: 5,
                                            ),
                                          ],
                                          image: user.profileImageUrl != null
                                              ? DecorationImage(
                                                  image: NetworkImage(user.profileImageUrl!),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: user.profileImageUrl == null
                                            ? Icon(
                                                Icons.person,
                                                size: 30,
                                                color: AppColors.primary,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _getGreeting(),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              user.name,
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Let's earn some rewards today!",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white.withOpacity(0.9),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TweenAnimationBuilder<double>(
                                        duration: const Duration(milliseconds: 1000),
                                        tween: Tween<double>(begin: 0, end: 1),
                                        curve: Curves.elasticOut,
                                        builder: (context, value, child) {
                                          return Transform.scale(
                                            scale: value,
                                            child: child,
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                offset: const Offset(0, 2),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.stars_rounded,
                                                size: 16,
                                                color: AppColors.primary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${user.points} pts',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                            // Points card with sliding animation
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(-0.2, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _slideAnimation,
                                curve: const Interval(0.2, 1.0),
                              )),
                              child: FadeTransition(
                                opacity: CurvedAnimation(
                                  parent: _slideAnimation,
                                  curve: const Interval(0.2, 1.0),
                                ),
                                child: PointsCard(
                                  onTap: () {
                                    Navigator.pushNamed(context, AppRoutes.activityHistory);
                                  },
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Quick actions section
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.2, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _slideAnimation,
                                curve: const Interval(0.4, 1.0),
                              )),
                              child: FadeTransition(
                                opacity: CurvedAnimation(
                                  parent: _slideAnimation,
                                  curve: const Interval(0.4, 1.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Quick Actions',
                                      style: AppTextStyles.headline3,
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildAnimatedButton(
                                            text: 'Scan QR',
                                            icon: Icons.qr_code_scanner,
                                            onPressed: _scanQrCode,
                                            color: Colors.purple,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildAnimatedButton(
                                            text: 'View Rewards',
                                            icon: Icons.card_giftcard,
                                            onPressed: _viewRewards,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 12),
                                    
                                    Container(
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.accent.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: _buildAnimatedButton(
                                        text: 'My Claimed Rewards',
                                        icon: Icons.card_giftcard,
                                        onPressed: _viewClaimedRewards,
                                        isOutlined: false,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Available rewards section
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.2),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _slideAnimation,
                                curve: const Interval(0.6, 1.0),
                              )),
                              child: FadeTransition(
                                opacity: CurvedAnimation(
                                  parent: _slideAnimation,
                                  curve: const Interval(0.6, 1.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Available Rewards',
                                          style: AppTextStyles.headline3,
                                        ),
                                        TextButton.icon(
                                          onPressed: _viewRewards,
                                          icon: const Icon(Icons.visibility),
                                          label: const Text('View All'),
                                          style: TextButton.styleFrom(
                                            foregroundColor: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Available rewards list
                                    rewards.isEmpty
                                        ? const Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(24.0),
                                              child: Text(
                                                'No rewards available at the moment. Check back later!',
                                                textAlign: TextAlign.center,
                                                style: AppTextStyles.bodyText,
                                              ),
                                            ),
                                          )
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: rewards.length > 3 ? 3 : rewards.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: const EdgeInsets.only(bottom: 12.0),
                                                child: TweenAnimationBuilder<double>(
                                                  duration: Duration(milliseconds: 800 + (index * 200)),
                                                  tween: Tween<double>(begin: 0, end: 1),
                                                  curve: Curves.easeOutCubic,
                                                  builder: (context, value, child) {
                                                    return Transform.translate(
                                                      offset: Offset(0, 20 * (1 - value)),
                                                      child: Opacity(
                                                        opacity: value,
                                                        child: child,
                                                      ),
                                                    );
                                                  },
                                                  child: RewardCard(
                                                    reward: rewards[index],
                                                    onPressed: () => _viewRewardDetails(rewards[index]),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                    
                                    // Rewards user can claim section
                                    if (rewardsUserCanClaim.isNotEmpty) ...[
                                      const SizedBox(height: 24),
                                      Row(
                                        children: [
                                          const Text(
                                            'Rewards You Can Claim',
                                            style: AppTextStyles.headline3,
                                          ),
                                          const SizedBox(width: 8),
                                          _buildShinyBadge('New!'),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: rewardsUserCanClaim.length > 2 ? 2 : rewardsUserCanClaim.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 12.0),
                                            child: TweenAnimationBuilder<double>(
                                              duration: Duration(milliseconds: 800 + (index * 200)),
                                              tween: Tween<double>(begin: 0, end: 1),
                                              curve: Curves.easeOutCubic,
                                              builder: (context, value, child) {
                                                return Transform.translate(
                                                  offset: Offset(0, 20 * (1 - value)),
                                                  child: Opacity(
                                                    opacity: value,
                                                    child: child,
                                                  ),
                                                );
                                              },
                                              child: RewardCard(
                                                reward: rewardsUserCanClaim[index],
                                                onPressed: () => _viewRewardDetails(rewardsUserCanClaim[index]),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      _buildAnimatedButton(
                                        text: 'View All Claimable Rewards',
                                        icon: Icons.redeem,
                                        onPressed: _viewRewards,
                                        isOutlined: true,
                                        color: AppColors.accent,
                                      ),
                                    ],
                                    
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    bool isOutlined = false,
    Color color = AppColors.primary,
  }) {
    return AnimatedBuilder(
      animation: _buttonController,
      builder: (context, child) {
        final scale = 1.0 - (_buttonController.value * 0.1);
        
        return Transform.scale(
          scale: scale,
          child: CustomButton(
            text: text,
            icon: icon,
            onPressed: onPressed,
            isOutlined: isOutlined,
            backgroundColor: isOutlined ? Colors.transparent : color,
            textColor: isOutlined ? color : Colors.white,
          ),
        );
      },
    );
  }
  
  Widget _buildShinyBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent,
            Colors.lime,
            AppColors.accent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
  
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning 🌞';
    } else if (hour < 18) {
      return 'Good Afternoon 🌤️';
    } else {
      return 'Good Evening 🌙';
    }
  }
}

// Bubble class for animated background
class _Bubble {
  final Offset position;
  final double size;
  final Color color;
  final double speed;
  
  _Bubble({
    required this.position,
    required this.size,
    required this.color,
    required this.speed,
  });
}

// CustomPainter for drawing bubbles
class _BubblesPainter extends CustomPainter {
  final List<_Bubble> bubbles;
  final double progress;
  
  _BubblesPainter({required this.bubbles, required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    for (var bubble in bubbles) {
      final paint = Paint()..color = bubble.color;
      
      // Calculate positions with floating motion - increase amplitude from 15 to 30
      final double yOffset = math.sin(progress * math.pi * 2 * bubble.speed) * 30;
      // Add horizontal movement as well
      final double xOffset = math.cos(progress * math.pi * 2 * bubble.speed * 0.7) * 20;
      
      final position = Offset(
        bubble.position.dx + xOffset,
        bubble.position.dy + yOffset,
      );
      
      // Draw bubble
      canvas.drawCircle(position, bubble.size, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant _BubblesPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.bubbles != bubbles;
  }
} 
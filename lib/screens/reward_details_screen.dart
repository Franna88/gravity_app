import 'package:flutter/material.dart';
import 'package:gravity_rewards_app/constants/app_constants.dart';
import 'package:gravity_rewards_app/providers/activity_provider.dart';
import 'package:gravity_rewards_app/providers/auth_provider.dart';
import 'package:gravity_rewards_app/providers/rewards_provider.dart';
import 'package:gravity_rewards_app/widgets/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';

class RewardDetailsScreen extends StatefulWidget {
  const RewardDetailsScreen({Key? key}) : super(key: key);

  @override
  State<RewardDetailsScreen> createState() => _RewardDetailsScreenState();
}

class _RewardDetailsScreenState extends State<RewardDetailsScreen> with TickerProviderStateMixin {
  bool _isRedeeming = false;
  bool _redeemed = false;
  
  // Animation controllers
  late AnimationController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  // Confetti particles
  final List<_ConfettiParticle> _particles = [];
  final int _particleCount = 50;
  final math.Random _random = math.Random();
  
  @override
  void initState() {
    super.initState();
    
    // Set up confetti animation
    _confettiController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    
    // Set up scale animation for success message
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    
    // Start animations when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaleController.forward();
      _initializeParticles();
    });
  }
  
  void _initializeParticles() {
    // Ensure we're not accessing MediaQuery during initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      _particles.clear();
      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;
      
      // Increase particle count for a more dramatic effect
      for (int i = 0; i < 100; i++) {
        _particles.add(_ConfettiParticle(
          color: _randomColor(),
          position: Offset(
            _random.nextDouble() * screenWidth, // Start from random x position
            screenHeight * 0.3,
          ),
          velocity: Offset(
            (_random.nextDouble() * 6 - 3),  // x velocity between -3 and 3
            -_random.nextDouble() * 5 - 5, // y velocity between -5 and -10 (stronger upward)
          ),
          size: _random.nextDouble() * 15 + 8, // size between 8 and 23 (larger particles)
          rotation: _random.nextDouble() * 6.28, // rotation between 0 and 2π
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.2, // faster rotation
          lifespan: (_random.nextDouble() * 2) + 3, // between 3 and 5 seconds (longer life)
        ));
      }
      
      if (mounted) {
        setState(() {});
      }
    });
  }
  
  Color _randomColor() {
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.amber,
      Colors.deepOrange,
      Colors.indigoAccent,
      Colors.lightGreenAccent,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _redeemReward() {
    setState(() {
      _isRedeeming = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final rewardsProvider = Provider.of<RewardsProvider>(context, listen: false);

    if (authProvider.user != null && rewardsProvider.selectedReward != null) {
      rewardsProvider.redeemReward(authProvider.user!.id).then((success) {
        if (success && mounted) {
          setState(() {
            _redeemed = true;
          });
          
          // Run celebrations
          _initializeParticles();
          
          // Longer animation for confetti
          _confettiController.duration = const Duration(seconds: 5);
          _confettiController.forward(from: 0);
          
          // Show success dialog with animation
          _showSuccessDialog();
          
          // Add vibration or sound here if needed
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(rewardsProvider.error ?? 'Failed to redeem reward'),
              backgroundColor: Colors.red,
            ),
          );
        }
        
        if (mounted) {
          setState(() {
            _isRedeeming = false;
          });
        }
      });
    } else {
      setState(() {
        _isRedeeming = false;
      });
    }
  }
  
  void _showSuccessDialog() {
    // More dramatic animation for scale effect
    final AnimationController pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    final Animation<double> pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.05), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.05, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: pulseController,
      curve: Curves.easeInOut,
    ));
    
    pulseController.repeat();
    
    // Delayed to allow confetti animation to start first
    Future.delayed(const Duration(milliseconds: 200), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          final rewardsProvider = Provider.of<RewardsProvider>(context, listen: false);
          final rewardName = rewardsProvider.selectedReward?['name'] ?? '';
          final rewardCategory = rewardsProvider.selectedReward?['category'] ?? 
                             rewardsProvider.getRewardCategory(rewardName);
          
          String actionButtonText;
          String actionUrl;
          
          if (rewardCategory == 'booking') {
            actionButtonText = 'Book Your Visit';
            actionUrl = 'https://gravity-trampoline-booking.com';
          } else if (rewardCategory == 'merchandise') {
            actionButtonText = 'Shop Merchandise';
            actionUrl = 'https://gravity-store.com';
          } else {
            actionButtonText = 'Use Reward';
            actionUrl = 'https://gravity-rewards.com';
          }

          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                );
              },
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4CAF50), // Green
                        const Color(0xFF8BC34A), // Light Green
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pulsing success icon
                      AnimatedBuilder(
                        animation: pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: pulseAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Color(0xFF4CAF50),
                                size: 64,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.white.withOpacity(0.8),
                            Colors.white,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          'SUCCESS!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'You have successfully redeemed this reward. Show this screen to a staff member to claim your reward.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      
                      // Responsive button layout
                      Flexible(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // If screen is wide enough for buttons side by side
                            if (constraints.maxWidth > 350) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: CustomButton(
                                      text: actionButtonText,
                                      onPressed: () async {
                                        Navigator.of(context).pop(); // Close dialog
                                        
                                        // Launch the appropriate URL
                                        final Uri uri = Uri.parse(actionUrl);
                                        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Could not launch website. Please try again later.'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      backgroundColor: Colors.white,
                                      textColor: const Color(0xFF4CAF50),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: CustomButton(
                                      text: 'View Claimed',
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close dialog
                                        Navigator.of(context).pop(); // Return to previous screen
                                        Navigator.pushNamed(context, AppRoutes.claimedRewards);
                                      },
                                      backgroundColor: Colors.transparent,
                                      textColor: Colors.white,
                                      isOutlined: true,
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              // Stack buttons vertically if screen is narrow
                              return Column(
                                children: [
                                  CustomButton(
                                    text: actionButtonText,
                                    onPressed: () async {
                                      Navigator.of(context).pop(); // Close dialog
                                      
                                      // Launch the appropriate URL
                                      final Uri uri = Uri.parse(actionUrl);
                                      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Could not launch website. Please try again later.'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    backgroundColor: Colors.white,
                                    textColor: const Color(0xFF4CAF50),
                                  ),
                                  const SizedBox(height: 10),
                                  CustomButton(
                                    text: 'View Claimed Rewards',
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close dialog
                                      Navigator.of(context).pop(); // Return to previous screen
                                      Navigator.pushNamed(context, AppRoutes.claimedRewards);
                                    },
                                    backgroundColor: Colors.transparent,
                                    textColor: Colors.white,
                                    isOutlined: true,
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          Navigator.of(context).pop(); // Return to previous screen
                        },
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
      
      // Start animations
      _scaleController.forward(from: 0);
      pulseController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rewardsProvider = Provider.of<RewardsProvider>(context);
    final activityProvider = Provider.of<ActivityProvider>(context);
    final selectedReward = rewardsProvider.selectedReward;

    if (selectedReward == null) {
      return const Scaffold(
        body: Center(
          child: Text('No reward selected'),
        ),
      );
    }

    final bool canRedeem = selectedReward['canRedeem'] == true && !_redeemed;
    final String? imageUrl = selectedReward['imageUrl'];
    final String expiryDateStr = selectedReward['expiryDate'];
    final DateTime expiryDate = DateTime.parse(expiryDateStr);
    final String formattedExpiryDate = DateFormat('MMM d, yyyy').format(expiryDate);
    final int pointsCost = selectedReward['pointsCost'] is int 
        ? selectedReward['pointsCost'] 
        : int.tryParse(selectedReward['pointsCost'].toString()) ?? 0;
    final int currentPoints = activityProvider.currentPoints;
    final int remainingPoints = canRedeem ? currentPoints - pointsCost : currentPoints;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Reward Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Color.fromARGB(100, 0, 0, 0),
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Animated background decorations
          Positioned(
            top: -60,
            right: -60,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 10),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value * 2 * math.pi,
                  child: child,
                );
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.7),
                      AppColors.primary.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: -100,
            left: -100,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 7),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: -value * 2 * math.pi,
                  child: child,
                );
              },
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withOpacity(0.5),
                      AppColors.accent.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced image header with gradient overlay and animation
                Stack(
                  children: [
                    // Reward Image
                    Hero(
                      tag: 'reward_image_${selectedReward['id']}',
                      child: imageUrl != null
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(24),
                              ),
                              child: ShaderMask(
                                shaderCallback: (rect) {
                                  return LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                    stops: const [0.7, 1.0],
                                  ).createShader(rect);
                                },
                                blendMode: BlendMode.darken,
                                child: imageUrl.startsWith('http')
                                    ? Image.network(
                                        imageUrl,
                                        height: 260,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return _buildDefaultImage();
                                        },
                                      )
                                    : Image.asset(
                                        imageUrl,
                                        height: 260,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            )
                          : _buildDefaultImage(),
                    ),
                    
                    // Reward title overlay at bottom of image
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    selectedReward['name'],
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0, 1),
                                          blurRadius: 3.0,
                                          color: Color.fromARGB(170, 0, 0, 0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 800),
                                  tween: Tween<double>(begin: 0.0, end: 1.0),
                                  curve: Curves.elasticOut,
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: canRedeem
                                          ? AppColors.accent
                                          : Colors.grey,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.stars_rounded,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$pointsCost pts',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Add enhanced content section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description with animated reveal
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _scaleController,
                            curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
                          ),
                        ),
                        child: FadeTransition(
                          opacity: Tween<double>(begin: 0, end: 1).animate(
                            CurvedAnimation(
                              parent: _scaleController,
                              curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.description,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Description',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  selectedReward['description'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),

                      // Info Cards with staggered animation
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _scaleController,
                            curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
                          ),
                        ),
                        child: FadeTransition(
                          opacity: Tween<double>(begin: 0, end: 1).animate(
                            CurvedAnimation(
                              parent: _scaleController,
                              curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  'Expires On',
                                  formattedExpiryDate,
                                  Icons.calendar_today,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInfoCard(
                                  'Your Points',
                                  '$currentPoints pts',
                                  Icons.account_balance_wallet,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      // Terms and Conditions with animation
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _scaleController,
                            curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                          ),
                        ),
                        child: FadeTransition(
                          opacity: Tween<double>(begin: 0, end: 1).animate(
                            CurvedAnimation(
                              parent: _scaleController,
                              curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.gavel,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Terms and Conditions',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...[
                                  _buildTermItem('Reward must be redeemed before the expiry date'),
                                  _buildTermItem('Cannot be combined with other offers'),
                                  _buildTermItem('Valid at Gravity Trampoline Park locations'),
                                  _buildTermItem('Must be shown to staff at time of redemption'),
                                  _buildTermItem('Management reserves the right to change terms'),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),

                      // Redeem Button with animation
                      if (!_redeemed) ...[
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _scaleController,
                              curve: const Interval(0.7, 1.0, curve: Curves.elasticOut),
                            ),
                          ),
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(seconds: 2),
                            tween: Tween<double>(begin: 1.0, end: canRedeem ? 1.05 : 1.0),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: canRedeem ? (value % 1.0) + 1.0 : 1.0,
                                child: child,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: canRedeem ? [
                                  BoxShadow(
                                    color: AppColors.accent.withOpacity(0.3),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ] : null,
                              ),
                              child: CustomButton(
                                text: 'Redeem Reward',
                                onPressed: canRedeem ? _redeemReward : null,
                                isLoading: _isRedeeming,
                                backgroundColor: canRedeem ? AppColors.accent : null,
                                height: 56,
                              ),
                            ),
                          ),
                        ),
                        if (!canRedeem) ...[
                          const SizedBox(height: 12),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.red[200]!,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 18,
                                    color: Colors.red[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'You need ${pointsCost - currentPoints} more points',
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Confetti animation overlay
          if (_redeemed)
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _confettiController.value,
                  ),
                  size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0.95, end: 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add a helper method for the default image
  Widget _buildDefaultImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(24),
      ),
      child: Container(
        height: 260,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.7),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background patterns
            ...List.generate(20, (index) {
              final size = 30.0 + _random.nextDouble() * 20;
              return Positioned(
                left: _random.nextDouble() * 400,
                top: _random.nextDouble() * 260,
                child: Opacity(
                  opacity: 0.15,
                  child: Transform.rotate(
                    angle: _random.nextDouble() * math.pi,
                    child: Icon(
                      Icons.star,
                      size: size,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }),
            
            // Center icon
            Center(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(seconds: 2),
                tween: Tween<double>(begin: 0.9, end: 1.1),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: const Icon(
                  Icons.card_giftcard,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build terms item
  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.accent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper class for confetti particles
class _ConfettiParticle {
  Color color;
  Offset position;
  Offset velocity;
  double size;
  double rotation;
  double rotationSpeed;
  double lifespan;
  
  _ConfettiParticle({
    required this.color,
    required this.position,
    required this.velocity,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.lifespan,
  });
  
  void update(double dt, double gravity) {
    // Update position
    position += velocity * dt;
    
    // Apply gravity
    velocity += Offset(0, gravity) * dt;
    
    // Update rotation
    rotation += rotationSpeed;
    
    // Update lifespan
    lifespan -= dt;
  }
}

// CustomPainter for drawing confetti
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;
  
  _ConfettiPainter({required this.particles, required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    final double dt = 1 / 60; // Simulating at 60fps
    final double gravity = 9.8; // Gravity effect
    
    // Update particles
    for (var particle in particles) {
      if (particle.lifespan > 0) {
        particle.update(dt, gravity);
        
        final paint = Paint()..color = particle.color;
        
        // Draw particle
        canvas.save();
        canvas.translate(
          size.width / 2 + particle.position.dx,
          particle.position.dy,
        );
        canvas.rotate(particle.rotation);
        
        // Draw a rectangle for the confetti piece
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 1.5,
          ),
          paint,
        );
        
        canvas.restore();
      }
    }
  }
  
  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
} 
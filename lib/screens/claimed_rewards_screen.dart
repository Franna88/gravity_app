import 'package:flutter/material.dart';
import 'package:gravity_rewards_app/constants/app_constants.dart';
import 'package:gravity_rewards_app/providers/auth_provider.dart';
import 'package:gravity_rewards_app/providers/rewards_provider.dart';
import 'package:gravity_rewards_app/widgets/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

class ClaimedRewardsScreen extends StatefulWidget {
  const ClaimedRewardsScreen({Key? key}) : super(key: key);

  @override
  State<ClaimedRewardsScreen> createState() => _ClaimedRewardsScreenState();
}

class _ClaimedRewardsScreenState extends State<ClaimedRewardsScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  final List<_ConfettiParticle> _particles = [];
  late AnimationController _confettiController;
  late AnimationController _slideController;
  final math.Random _random = math.Random();
  int _highlightedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadRedemptionHistory();
    
    // Initialize animation controllers
    _confettiController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Initialize some particles
    _initializeParticles();
  }
  
  void _initializeParticles() {
    _particles.clear();
    for (int i = 0; i < 50; i++) {
      _particles.add(_ConfettiParticle(
        color: _getRandomColor(),
        position: Offset(
          _random.nextDouble() * 300,
          -50,
        ),
        velocity: Offset(
          (_random.nextDouble() * 2 - 1) * 2,
          _random.nextDouble() * 3 + 2,
        ),
        size: _random.nextDouble() * 8 + 5,
        rotation: _random.nextDouble() * 6.28,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
      ));
    }
  }
  
  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      AppColors.primary,
      AppColors.accent,
    ];
    return colors[_random.nextInt(colors.length)];
  }
  
  void _playConfettiAnimation(int index) {
    setState(() {
      _highlightedIndex = index;
    });
    
    // Update confetti to start at the position of the tapped card
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      // Reset and play the confetti animation
      _confettiController.reset();
      _confettiController.forward();
    });
  }

  Future<void> _loadRedemptionHistory() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final rewardsProvider = Provider.of<RewardsProvider>(context, listen: false);

    if (authProvider.user != null) {
      await rewardsProvider.loadRedemptionHistory(authProvider.user!.id);
    }

    setState(() {
      _isLoading = false;
    });
    
    // Start the slide animation after data is loaded
    _slideController.forward();
  }

  Future<void> _navigateToExternalSite(String rewardType) async {
    String url;
    
    // Determine the URL based on reward type
    if (rewardType.toLowerCase().contains('jump') || 
        rewardType.toLowerCase().contains('session') ||
        rewardType.toLowerCase().contains('party')) {
      // Booking website for activity-related rewards
      url = 'https://gravity-trampoline-booking.com';
    } else if (rewardType.toLowerCase().contains('merch') || 
               rewardType.toLowerCase().contains('discount')) {
      // Store website for merchandise-related rewards
      url = 'https://gravity-store.com';
    } else {
      // Default website
      url = 'https://gravity-rewards.com';
    }
    
    // Launch URL
    final Uri uri = Uri.parse(url);
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
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
  
  @override
  void dispose() {
    _confettiController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rewardsProvider = Provider.of<RewardsProvider>(context);
    final redemptionHistory = rewardsProvider.redemptionHistory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Claimed Rewards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRedemptionHistory,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(0.1),
              ),
            ),
          ),
          
          // Main content
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : redemptionHistory.isEmpty
                  ? _buildEmptyState()
                  : _buildHistoryList(redemptionHistory),
                  
          // Confetti animation overlay
          if (_highlightedIndex >= 0)
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

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.elasticOut,
              tween: Tween<double>(begin: 0.5, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.card_giftcard,
                  size: 100,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _slideController,
                  curve: const Interval(0.3, 1.0),
                ),
              ),
              child: const Text(
                'No Claimed Rewards Yet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _slideController,
                  curve: const Interval(0.5, 1.0),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'Redeem rewards from the rewards shop to see them here. Earn points by visiting Gravity Trampoline Park!',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _slideController,
                  curve: const Interval(0.7, 1.0, curve: Curves.easeOutCubic),
                ),
              ),
              child: CustomButton(
                text: 'Browse Rewards',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.rewardsShop);
                },
                width: 220,
                icon: Icons.redeem,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(List<Map<String, dynamic>> history) {
    return RefreshIndicator(
      onRefresh: _loadRedemptionHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final reward = history[index];
          final String rewardName = reward['rewardName'];
          final DateTime timestamp = reward['timestamp'];
          final int pointsSpent = reward['pointsSpent'];
          final bool isExpired = reward['expiryDate'] != null && 
                                reward['expiryDate'].isBefore(DateTime.now());
          
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _slideController,
                curve: Interval(
                  index * 0.1 > 0.9 ? 0.9 : index * 0.1,
                  (index * 0.1 + 0.6) > 1.0 ? 1.0 : (index * 0.1 + 0.6),
                  curve: Curves.easeOutCubic,
                ),
              ),
            ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _slideController,
                  curve: Interval(
                    index * 0.1 > 0.9 ? 0.9 : index * 0.1,
                    (index * 0.1 + 0.6) > 1.0 ? 1.0 : (index * 0.1 + 0.6),
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: !isExpired ? () => _playConfettiAnimation(index) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: _highlightedIndex == index && !isExpired
                        ? LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.9),
                              AppColors.primary.withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: _highlightedIndex != index ? Colors.white : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _highlightedIndex == index && !isExpired
                            ? AppColors.primary.withOpacity(0.3)
                            : Colors.black.withOpacity(0.1),
                        blurRadius: _highlightedIndex == index && !isExpired ? 10 : 5,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 500),
                              tween: Tween<double>(
                                begin: 1.0,
                                end: _highlightedIndex == index && !isExpired ? 1.1 : 1.0,
                              ),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: child,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isExpired
                                      ? Colors.grey[200]
                                      : _highlightedIndex == index
                                          ? Colors.white.withOpacity(0.3)
                                          : AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  boxShadow: _highlightedIndex == index && !isExpired
                                      ? [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.5),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          )
                                        ]
                                      : null,
                                ),
                                child: Icon(
                                  _getIconForReward(rewardName),
                                  color: isExpired
                                      ? Colors.grey
                                      : _highlightedIndex == index
                                          ? AppColors.primary
                                          : AppColors.primary,
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          rewardName,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isExpired
                                                ? Colors.grey
                                                : _highlightedIndex == index
                                                    ? Colors.white
                                                    : AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _highlightedIndex == index && !isExpired
                                              ? Colors.white.withOpacity(0.3)
                                              : AppColors.accent.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.stars_rounded,
                                              size: 16,
                                              color: _highlightedIndex == index && !isExpired
                                                  ? Colors.white
                                                  : AppColors.accent,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '$pointsSpent pts',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: _highlightedIndex == index && !isExpired
                                                    ? Colors.white
                                                    : AppColors.accent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: _highlightedIndex == index && !isExpired
                                            ? Colors.white.withOpacity(0.7)
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Claimed on ${_formatDate(timestamp)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _highlightedIndex == index && !isExpired
                                              ? Colors.white.withOpacity(0.9)
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (isExpired)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.red[200]!),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            size: 14,
                                            color: Colors.red[700],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Expired',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (!isExpired) ...[
                          const SizedBox(height: 16),
                          Container(
                            height: 1,
                            color: _highlightedIndex == index
                                ? Colors.white.withOpacity(0.2)
                                : Colors.grey[200],
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: _getActionButtonText(rewardName),
                            onPressed: () => _navigateToExternalSite(rewardName),
                            backgroundColor: _highlightedIndex == index
                                ? Colors.white
                                : null,
                            textColor: _highlightedIndex == index
                                ? AppColors.primary
                                : null,
                            isOutlined: _highlightedIndex != index,
                            icon: _getActionIcon(rewardName),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForReward(String rewardName) {
    if (rewardName.toLowerCase().contains('jump') || 
        rewardName.toLowerCase().contains('session')) {
      return Icons.directions_run;
    } else if (rewardName.toLowerCase().contains('discount') || 
               rewardName.toLowerCase().contains('merch')) {
      return Icons.shopping_bag;
    } else if (rewardName.toLowerCase().contains('party') || 
               rewardName.toLowerCase().contains('room')) {
      return Icons.celebration;
    } else if (rewardName.toLowerCase().contains('pass')) {
      return Icons.badge;
    } else {
      return Icons.card_giftcard;
    }
  }
  
  IconData _getActionIcon(String rewardName) {
    if (rewardName.toLowerCase().contains('jump') || 
        rewardName.toLowerCase().contains('session') ||
        rewardName.toLowerCase().contains('party') ||
        rewardName.toLowerCase().contains('room')) {
      return Icons.calendar_today;
    } else if (rewardName.toLowerCase().contains('discount') || 
               rewardName.toLowerCase().contains('merch')) {
      return Icons.shopping_cart;
    } else {
      return Icons.redeem;
    }
  }

  String _getActionButtonText(String rewardName) {
    if (rewardName.toLowerCase().contains('jump') || 
        rewardName.toLowerCase().contains('session') ||
        rewardName.toLowerCase().contains('party') ||
        rewardName.toLowerCase().contains('room')) {
      return 'Book Your Visit';
    } else if (rewardName.toLowerCase().contains('discount') || 
               rewardName.toLowerCase().contains('merch')) {
      return 'Shop Merchandise';
    } else {
      return 'Use Reward';
    }
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
  
  _ConfettiParticle({
    required this.color,
    required this.position,
    required this.velocity,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });
  
  void update(double dt, double gravity) {
    // Update position
    position += velocity * dt;
    
    // Apply gravity
    velocity += Offset(0, gravity) * dt;
    
    // Update rotation
    rotation += rotationSpeed;
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
      particle.update(dt, gravity);
      
      // Only draw particles that are within view
      if (particle.position.dy < size.height + 50) {
        final paint = Paint()..color = particle.color.withOpacity(1.0 - progress);
        
        // Draw particle
        canvas.save();
        canvas.translate(particle.position.dx, particle.position.dy);
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
import 'package:flutter/material.dart';
import 'package:gravity_rewards_app/constants/app_constants.dart';
import 'package:gravity_rewards_app/providers/activity_provider.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class PointsCard extends StatefulWidget {
  final VoidCallback onTap;
  
  const PointsCard({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  State<PointsCard> createState() => _PointsCardState();
}

class _PointsCardState extends State<PointsCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _pointsAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotateAnimation;
  int _displayPoints = 0;
  int _lastPoints = 0;
  bool _showStar = false;
  final List<_FloatingItem> _floatingItems = [];
  final math.Random _random = math.Random();
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.05), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.05, end: 0.95), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.95, end: 1.02), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.02, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));
    
    _rotateAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    _initializeFloatingItems();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updatePoints();
    });
  }
  
  void _initializeFloatingItems() {
    _floatingItems.clear();
    for (int i = 0; i < 8; i++) {
      _floatingItems.add(
        _FloatingItem(
          icon: _getRandomIcon(),
          position: Offset(
            20 + _random.nextDouble() * 300,
            20 + _random.nextDouble() * 100,
          ),
          size: 8 + _random.nextDouble() * 14,
          rotation: _random.nextDouble() * math.pi * 2,
          speed: 0.5 + _random.nextDouble() * 1.0,
          amplitude: 8 + _random.nextDouble() * 15,
          phase: _random.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  IconData _getRandomIcon() {
    final icons = [
      Icons.star,
      Icons.bubble_chart,
      Icons.sunny,
      Icons.pets,
      Icons.favorite,
      Icons.sports_basketball,
      Icons.sports_soccer,
      Icons.emoji_emotions
    ];
    return icons[_random.nextInt(icons.length)];
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updatePoints();
  }
  
  void _updatePoints() {
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
    final currentPoints = activityProvider.currentPoints;
    
    if (_lastPoints != currentPoints) {
      // Only animate if points have changed and not the first load
      if (_lastPoints > 0) {
        _displayPoints = _lastPoints;
        _pointsAnimation = IntTween(begin: _lastPoints, end: currentPoints).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic),
          ),
        )..addListener(() {
          setState(() {
            _displayPoints = _pointsAnimation.value;
          });
        });
        
        _showCelebration();
      } else {
        _displayPoints = currentPoints;
      }
      
      _lastPoints = currentPoints;
    }
  }
  
  void _showCelebration() {
    _controller.reset();
    _controller.forward();
    setState(() {
      _showStar = true;
    });
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showStar = false;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);
    final currentPoints = activityProvider.currentPoints;
    
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotateAnimation.value,
            child: Transform.scale(
              scale: _bounceAnimation.value,
              child: child,
            ),
          );
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              elevation: 8,
              shadowColor: AppColors.primary.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      Color(0xFFF58442),
                      Color(0xFFF7A454),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Background decorations
                    Positioned(
                      right: -15,
                      top: -15,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    Positioned(
                      left: -25,
                      bottom: -25,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    
                    // Floating decorative items
                    ..._floatingItems.map((item) {
                      final offset = Offset(
                        item.position.dx,
                        item.position.dy + math.sin(_controller.value * math.pi * 2 * item.speed + item.phase) * item.amplitude,
                      );
                      
                      return Positioned(
                        left: offset.dx,
                        top: offset.dy,
                        child: Transform.rotate(
                          angle: item.rotation + _controller.value * math.pi / 2,
                          child: Icon(
                            item.icon,
                            color: Colors.white.withOpacity(0.3),
                            size: item.size,
                          ),
                        ),
                      );
                    }).toList(),
                    
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'My Points',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.history,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'History',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.stars_rounded,
                                color: Colors.yellow,
                                size: 40,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '$_displayPoints',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  height: 0.9,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to view activity history',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Flying star animation
            if (_showStar)
              Positioned(
                top: 20,
                right: 20,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1500),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        -100 * value,
                      ),
                      child: Opacity(
                        opacity: value < 0.8 ? 1.0 : 1 - (value - 0.8) * 5,
                        child: Transform.rotate(
                          angle: value * math.pi * 4,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.star,
                    color: Colors.yellow,
                    size: 40,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FloatingItem {
  final IconData icon;
  final Offset position;
  final double size;
  final double rotation;
  final double speed;
  final double amplitude;
  final double phase;
  
  _FloatingItem({
    required this.icon,
    required this.position,
    required this.size,
    required this.rotation,
    required this.speed,
    required this.amplitude,
    required this.phase,
  });
} 
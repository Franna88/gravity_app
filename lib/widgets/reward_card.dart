import 'package:flutter/material.dart';
import 'package:gravity_rewards_app/constants/app_constants.dart';
import 'package:gravity_rewards_app/models/reward_model.dart';
import 'dart:math' as math;

class RewardCard extends StatefulWidget {
  final RewardModel reward;
  final VoidCallback onPressed;

  const RewardCard({
    Key? key,
    required this.reward,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<RewardCard> createState() => _RewardCardState();
}

class _RewardCardState extends State<RewardCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _bounceAnimation;
  bool _isHovered = false;
  
  final _random = math.Random();
  
  // Color palette for cards
  final List<List<Color>> _colorSchemes = [
    [Color(0xFF6A5AE0), Color(0xFF9087E5)], // Purple
    [Color(0xFF0082CD), Color(0xFF00A3FF)], // Blue
    [Color(0xFFFF8412), Color(0xFFFFAA5B)], // Orange
    [Color(0xFF2CC672), Color(0xFF5AE0A0)], // Green
    [Color(0xFFFF5B7A), Color(0xFFFF8DA3)], // Pink
  ];
  
  late List<Color> _cardColors;

  @override
  void initState() {
    super.initState();
    
    // Choose a random color scheme for variety
    _cardColors = _colorSchemes[_random.nextInt(_colorSchemes.length)];
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);
    
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );
    
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.05), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.05, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool canRedeem = widget.reward.additionalInfo?['canRedeem'] == true;
    int pointsNeeded = widget.reward.pointsCost - (widget.reward.additionalInfo?['userPoints'] as num? ?? 0).toInt();
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _isHovered ? _bounceAnimation.value : 1.0,
          child: GestureDetector(
            onTap: widget.onPressed,
            onTapDown: (_) => setState(() => _isHovered = true),
            onTapUp: (_) => setState(() => _isHovered = false),
            onTapCancel: () => setState(() => _isHovered = false),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _cardColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _cardColors[0].withOpacity(0.3),
                    blurRadius: _isHovered ? 8 : 4,
                    spreadRadius: _isHovered ? 2 : 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                      ],
                      stops: [
                        _shimmerAnimation.value - 0.5,
                        _shimmerAnimation.value,
                        _shimmerAnimation.value + 0.5,
                      ],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcATop,
                  child: Stack(
                    children: [
                      // Decorative circles in background
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        left: 20,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      
                      // Add category badge to the top right
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(widget.reward.category),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.reward.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      // Main content
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Reward image or icon
                            Hero(
                              tag: 'reward_image_${widget.reward.id}',
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: widget.reward.imageUrl != null
                                    ? widget.reward.imageUrl!.startsWith('http')
                                        ? Image.network(
                                            widget.reward.imageUrl!,
                                            fit: BoxFit.cover,
                                            width: 80,
                                            height: 80,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Icon(
                                                Icons.card_giftcard,
                                                size: 32, 
                                                color: _cardColors[0],
                                              );
                                            },
                                          )
                                        : Image.asset(
                                            widget.reward.imageUrl!,
                                            fit: BoxFit.cover,
                                            width: 80,
                                            height: 80,
                                          )
                                    : Icon(
                                        Icons.card_giftcard,
                                        size: 32,
                                        color: _cardColors[0],
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Reward details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Reward title
                                  Text(
                                    widget.reward.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  
                                  // Reward description
                                  Text(
                                    widget.reward.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Points required
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.stars_rounded,
                                              size: 16,
                                              color: _cardColors[0],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${widget.reward.pointsCost} pts',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: _cardColors[0],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      
                                      // Status indicator
                                      if (canRedeem)
                                        _buildStatus(
                                          text: 'Claimable!',
                                          icon: Icons.check_circle,
                                          color: Colors.white,
                                        )
                                      else if (pointsNeeded > 0)
                                        _buildStatus(
                                          text: '$pointsNeeded more',
                                          icon: Icons.hourglass_empty,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // "New" badge if needed
                      if (widget.reward.additionalInfo?['isNew'] == true)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildStatus({
    required String text,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
  
  // Add a method to get colors based on category
  Color _getCategoryColor(String category) {
    switch (category) {
      case RewardCategories.discounts:
        return Colors.purple;
      case RewardCategories.freeJumps:
        return Colors.blue;
      case RewardCategories.merchandise:
        return Colors.orange;
      case RewardCategories.vip:
        return Colors.red;
      case RewardCategories.special:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
} 
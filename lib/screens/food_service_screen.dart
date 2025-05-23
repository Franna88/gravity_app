import 'package:flutter/material.dart';
import 'package:gravity_rewards_app/constants/app_constants.dart';
import 'package:gravity_rewards_app/models/food_item.dart';
import 'package:gravity_rewards_app/providers/food_service_provider.dart';
import 'package:gravity_rewards_app/providers/rewards_provider.dart';
import 'package:gravity_rewards_app/screens/food_cart_screen.dart';
import 'package:gravity_rewards_app/screens/food_detail_screen.dart';
import 'package:gravity_rewards_app/screens/food_order_tracking_screen.dart';
import 'package:gravity_rewards_app/widgets/custom_badge.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

class FoodServiceScreen extends StatefulWidget {
  const FoodServiceScreen({Key? key}) : super(key: key);

  @override
  State<FoodServiceScreen> createState() => _FoodServiceScreenState();
}

class _FoodServiceScreenState extends State<FoodServiceScreen> {
  FoodCategory _selectedCategory = FoodCategory.burgers;
  final _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodServiceProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Menu',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Order tracking icon
          IconButton(
            icon: const Icon(
              Icons.receipt_long_outlined,
              color: Colors.black87,
            ),
            onPressed: () {
              // Show a message that no active orders are available
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No active orders to track'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          // Cart icon with badge
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.black87,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FoodCartScreen(),
                      ),
                    );
                  },
                ),
              ),
              if (foodProvider.cart.items.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      foodProvider.cart.items.fold(
                        0,
                        (sum, item) => sum + item.quantity,
                      ).toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Promotional banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.orange, Colors.deepOrange],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.stars_rounded,
                            color: Colors.white.withOpacity(0.9),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '500 points',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Special Food Discount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Up To 70% Off',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Consumer<RewardsProvider>(
                        builder: (context, rewardsProvider, _) {
                          final userPoints = rewardsProvider.userPoints;
                          final hasEnoughPoints = userPoints >= 500;
                          
                          return ElevatedButton(
                            onPressed: hasEnoughPoints ? () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Claim Discount Voucher'),
                                  content: const Text('Would you like to spend 500 points to claim a 70% discount voucher for your next food order?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // TODO: Implement voucher claiming logic
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Voucher claimed successfully! Check your rewards section.'),
                                          ),
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Claim'),
                                    ),
                                  ],
                                ),
                              );
                            } : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              disabledBackgroundColor: Colors.white.withOpacity(0.4),
                              disabledForegroundColor: Colors.grey[400],
                              elevation: 2,
                              shadowColor: Colors.black.withOpacity(0.3),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              minimumSize: const Size(140, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              hasEnoughPoints ? 'Claim Voucher' : 'Need ${500 - userPoints} more points',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 15,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.1),
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Lottie.asset(
                      'images/animations/food-animation.json',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          
          // Category chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Row(
              children: [
                ...FoodCategory.values.map((category) {
                  final isSelected = category == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ChoiceChip(
                      label: Row(
                        children: [
                          Icon(
                            category.icon,
                            size: 16,
                            color: isSelected ? Colors.white : Colors.orange,
                          ),
                          const SizedBox(width: 6),
                          Text(category.displayName),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        }
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Colors.orange,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : Colors.orange,
                          width: 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          
          // Food items list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: foodProvider.getItemsByCategory(_selectedCategory).length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = foodProvider.getItemsByCategory(_selectedCategory)[index];
                return _FoodItemCard(item: item);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodItemCard extends StatelessWidget {
  final FoodItem item;
  
  const _FoodItemCard({
    Key? key,
    required this.item,
  }) : super(key: key);
  
  String _getImagePath(FoodCategory category, String itemName) {
    final nameLower = itemName.toLowerCase();
    switch (category) {
      case FoodCategory.burgers:
        if (nameLower.contains('veggie')) {
          return 'images/veggie-burger.jpg';
        }
        // Alternate between burger images for variety
        return nameLower.contains('classic') ? 'images/burger.jpg' : 'images/burger2.jpg';
      case FoodCategory.pizza:
        if (nameLower.contains('mixed') || nameLower.contains('special')) {
          return 'images/crispy-mixed-pizza-with-olives-sausage.jpg';
        }
        // Alternate between pizza images for variety
        return nameLower.contains('margherita') ? 'images/pizza.jpg' : 'images/pizza2.jpeg';
      case FoodCategory.sides:
        if (nameLower.contains('fries')) {
          return 'images/fries.jpg';
        } else if (nameLower.contains('onion') || nameLower.contains('rings')) {
          return 'images/tasty-onion-rings-arrangement.jpg';
        }
        return 'images/stick.jpg';
      case FoodCategory.desserts:
        if (nameLower.contains('ice') || nameLower.contains('cream')) {
          return 'images/icecream.jpg';
        } else if (nameLower.contains('brownie')) {
          return 'images/brownie.jpg';
        } else if (nameLower.contains('cheese') || nameLower.contains('cake')) {
          return 'images/cheese-cake.jpg';
        }
        return 'images/brownie.jpg';
      case FoodCategory.drinks:
        if (nameLower.contains('water')) {
          return 'images/bottle-water.jpg';
        } else if (nameLower.contains('shake') || nameLower.contains('milk')) {
          return 'images/milkshake.jpg';
        } else if (nameLower.contains('soda') || nameLower.contains('cola')) {
          return 'images/soda.jpeg';
        }
        return 'images/milkshake.jpg';
      default:
        return 'images/burger.jpg';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodServiceProvider>(context, listen: false);
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailScreen(item: item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Item image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(_getImagePath(item.category, item.name)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < 4 ? Icons.star : Icons.star_border,
                              size: 14,
                              color: Colors.amber,
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Quantity controls
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '1',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.add,
                        size: 18,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        foodProvider.addToCart(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.name} added to cart'),
                            duration: const Duration(seconds: 2),
                            action: SnackBarAction(
                              label: 'VIEW CART',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FoodCartScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
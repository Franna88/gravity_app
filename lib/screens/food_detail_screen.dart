import 'package:flutter/material.dart';
import 'package:gravity_rewards_app/constants/app_constants.dart';
import 'package:gravity_rewards_app/models/food_item.dart';
import 'package:gravity_rewards_app/providers/food_service_provider.dart';
import 'package:gravity_rewards_app/screens/food_cart_screen.dart';
import 'package:provider/provider.dart';

class FoodDetailScreen extends StatelessWidget {
  final FoodItem item;
  
  const FoodDetailScreen({
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
        return nameLower.contains('classic') ? 'images/burger.jpg' : 'images/burger2.jpg';
      case FoodCategory.pizza:
        if (nameLower.contains('mixed') || nameLower.contains('special')) {
          return 'images/crispy-mixed-pizza-with-olives-sausage.jpg';
        }
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
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Item Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item image
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                image: DecorationImage(
                  image: AssetImage(_getImagePath(item.category, item.name)),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (item.isPopular)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Popular',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'R${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Rating
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < 4 ? Icons.star : Icons.star_border,
                          size: 20,
                          color: Colors.amber,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        '4.0',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(120 reviews)',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A delicious ${item.name.toLowerCase()} prepared with the finest ingredients. '
                    'Our chefs prepare each dish with care and attention to detail. '
                    'This item ${item.isPopular ? "is one of our most popular choices and" : ""} '
                    'belongs to our ${item.category.displayName} category.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Ingredients section
                  const Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildIngredientChip('Main ingredient'),
                      _buildIngredientChip('Fresh vegetables'),
                      _buildIngredientChip('Special sauce'),
                      _buildIngredientChip('Spices'),
                      _buildIngredientChip('Premium quality'),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Quantity selector
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _buildQuantityButton(Icons.remove, () {}),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: const Text(
                                '1',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildQuantityButton(Icons.add, () {}),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildIngredientChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 14,
        ),
      ),
    );
  }
  
  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 20,
          color: Colors.grey[700],
        ),
      ),
    );
  }
} 
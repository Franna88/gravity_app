import 'package:flutter/material.dart';
import 'package:gravity_rewards_app/constants/app_constants.dart';
import 'package:gravity_rewards_app/models/food_item.dart';
import 'package:gravity_rewards_app/providers/auth_provider.dart';
import 'package:gravity_rewards_app/providers/food_service_provider.dart';
import 'package:gravity_rewards_app/providers/rewards_provider.dart';
import 'package:gravity_rewards_app/screens/food_payment_screen.dart';
import 'package:gravity_rewards_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class FoodCartScreen extends StatelessWidget {
  const FoodCartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodServiceProvider>(context);
    final rewardsProvider = Provider.of<RewardsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    final cart = foodProvider.cart;
    final loyaltyPoints = rewardsProvider.userPoints;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                _showClearCartDialog(context, foodProvider);
              },
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? _buildEmptyCart(context)
          : _buildCartItems(context, cart),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : _buildCheckoutSection(
              context, 
              cart, 
              loyaltyPoints,
              foodProvider,
              authProvider,
            ),
    );
  }
  
  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some items to get started',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Browse Menu'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCartItems(BuildContext context, Cart cart) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: cart.items.length,
      itemBuilder: (context, index) {
        final cartItem = cart.items[index];
        return _CartItemCard(cartItem: cartItem);
      },
    );
  }
  
  Widget _buildCheckoutSection(
    BuildContext context, 
    Cart cart, 
    int loyaltyPoints,
    FoodServiceProvider foodProvider,
    AuthProvider authProvider,
  ) {
    final subtotal = cart.subtotal;
    final discount = cart.calculateDiscount(loyaltyPoints);
    final total = cart.calculateTotal(loyaltyPoints);
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text('R${subtotal.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Loyalty Discount (${loyaltyPoints} points)'),
              Text('-R${discount.toStringAsFixed(2)}',
                style: TextStyle(color: AppColors.accent),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'R${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Proceed to Payment',
            onPressed: () {
              if (authProvider.user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please log in to continue'),
                  ),
                );
                return;
              }
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodPaymentScreen(
                    subtotal: subtotal,
                    discount: discount,
                    total: total,
                    loyaltyPoints: loyaltyPoints,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  void _showClearCartDialog(BuildContext context, FoodServiceProvider foodProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              foodProvider.clearCart();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  
  const _CartItemCard({
    Key? key,
    required this.cartItem,
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
    
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item image
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                image: DecorationImage(
                  image: AssetImage(_getImagePath(cartItem.item.category, cartItem.item.name)),
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
                    cartItem.item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R${cartItem.item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (cartItem.selectedCustomizations != null &&
                      cartItem.selectedCustomizations!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        cartItem.selectedCustomizations!.join(', '),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Quantity controls
            Column(
              children: [
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onPressed: () {
                        if (cartItem.quantity > 1) {
                          foodProvider.updateCartItemQuantity(
                            cartItem.item.id, 
                            cartItem.quantity - 1,
                          );
                        } else {
                          // Show confirmation dialog for removal
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Remove Item'),
                              content: Text(
                                'Remove ${cartItem.item.name} from your cart?'
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    foodProvider.removeFromCart(cartItem.item.id);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Remove'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                    Container(
                      width: 30,
                      alignment: Alignment.center,
                      child: Text(
                        cartItem.quantity.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      onPressed: () {
                        foodProvider.updateCartItemQuantity(
                          cartItem.item.id, 
                          cartItem.quantity + 1,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'R${(cartItem.item.price * cartItem.quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  
  const _QuantityButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 16,
          color: AppColors.primary,
        ),
      ),
    );
  }
} 
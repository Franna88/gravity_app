import 'package:flutter/material.dart';
import 'package:gravity_rewards_app/models/food_item.dart';
import 'package:uuid/uuid.dart';

class FoodServiceProvider with ChangeNotifier {
  final Cart _cart = Cart();
  List<Order> _orders = [];
  final List<FoodItem> _menuItems = _generateMenuItems();
  
  // Getters
  Cart get cart => _cart;
  List<Order> get orders => _orders;
  List<FoodItem> get menuItems => _menuItems;
  
  List<FoodItem> getItemsByCategory(FoodCategory category) {
    return _menuItems.where((item) => item.category == category).toList();
  }
  
  List<FoodItem> getPopularItems() {
    return _menuItems.where((item) => item.isPopular).toList();
  }
  
  // Cart methods
  void addToCart(FoodItem item, {int quantity = 1, List<String>? customizations}) {
    final cartItem = CartItem(
      item: item, 
      quantity: quantity,
      selectedCustomizations: customizations,
    );
    
    _cart.addItem(cartItem);
    notifyListeners();
  }
  
  void removeFromCart(String itemId) {
    _cart.removeItem(itemId);
    notifyListeners();
  }
  
  void updateCartItemQuantity(String itemId, int quantity) {
    _cart.updateQuantity(itemId, quantity);
    notifyListeners();
  }
  
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
  
  // Order methods
  Future<Order> placeOrder(int loyaltyPoints, {String? notes}) async {
    if (_cart.items.isEmpty) {
      throw Exception('Cannot place an order with an empty cart');
    }
    
    final newOrder = Order(
      id: const Uuid().v4(),
      items: List.from(_cart.items),
      subtotal: _cart.subtotal,
      discount: _cart.calculateDiscount(loyaltyPoints),
      total: _cart.calculateTotal(loyaltyPoints),
      orderTime: DateTime.now(),
      notes: notes,
    );
    
    _orders.add(newOrder);
    clearCart();
    notifyListeners();
    
    // Simulate order status updates
    _simulateOrderProgress(newOrder);
    
    return newOrder;
  }
  
  Future<void> _simulateOrderProgress(Order order) async {
    // Simulate preparing status after 1 minute
    await Future.delayed(const Duration(minutes: 1));
    if (_orders.contains(order)) {
      final index = _orders.indexOf(order);
      _orders[index].status = OrderStatus.preparing;
      notifyListeners();
    }
    
    // Simulate ready status after 3 more minutes
    await Future.delayed(const Duration(minutes: 3));
    if (_orders.contains(order)) {
      final index = _orders.indexOf(order);
      _orders[index].status = OrderStatus.ready;
      notifyListeners();
    }
  }
  
  // Sample menu data
  static List<FoodItem> _generateMenuItems() {
    return [
      // Burgers
      FoodItem(
        id: '1',
        name: 'Classic Cheeseburger',
        description: 'Beef patty with cheese, lettuce, tomato, and special sauce',
        price: 8.99,
        imageUrl: 'assets/images/cheeseburger.jpg',
        category: FoodCategory.burgers,
        isPopular: true,
      ),
      FoodItem(
        id: '2',
        name: 'Gravity Burger',
        description: 'Double beef patty with bacon, cheese, and BBQ sauce',
        price: 12.99,
        imageUrl: 'assets/images/gravity_burger.jpg',
        category: FoodCategory.burgers,
        isPopular: true,
      ),
      FoodItem(
        id: '3',
        name: 'Veggie Burger',
        description: 'Plant-based patty with avocado, lettuce, and vegan mayo',
        price: 9.99,
        imageUrl: 'assets/images/veggie_burger.jpg',
        category: FoodCategory.burgers,
      ),
      
      // Pizza
      FoodItem(
        id: '4',
        name: 'Margherita Pizza',
        description: 'Classic pizza with tomato sauce, mozzarella, and basil',
        price: 10.99,
        imageUrl: 'assets/images/margherita.jpg',
        category: FoodCategory.pizza,
        isPopular: true,
      ),
      FoodItem(
        id: '5',
        name: 'Pepperoni Pizza',
        description: 'Pizza with tomato sauce, mozzarella, and pepperoni',
        price: 12.99,
        imageUrl: 'assets/images/pepperoni.jpg',
        category: FoodCategory.pizza,
      ),
      FoodItem(
        id: '6',
        name: 'BBQ Chicken Pizza',
        description: 'Pizza with BBQ sauce, chicken, red onions, and cilantro',
        price: 14.99,
        imageUrl: 'assets/images/bbq_chicken.jpg',
        category: FoodCategory.pizza,
      ),
      
      // Sides
      FoodItem(
        id: '7',
        name: 'French Fries',
        description: 'Crispy golden fries with seasoning',
        price: 3.99,
        imageUrl: 'assets/images/fries.jpg',
        category: FoodCategory.sides,
        isPopular: true,
      ),
      FoodItem(
        id: '8',
        name: 'Mozzarella Sticks',
        description: 'Crispy breaded mozzarella sticks with marinara sauce',
        price: 5.99,
        imageUrl: 'assets/images/mozzarella_sticks.jpg',
        category: FoodCategory.sides,
      ),
      FoodItem(
        id: '9',
        name: 'Onion Rings',
        description: 'Crispy battered onion rings',
        price: 4.99,
        imageUrl: 'assets/images/onion_rings.jpg',
        category: FoodCategory.sides,
      ),
      
      // Drinks
      FoodItem(
        id: '10',
        name: 'Soft Drink',
        description: 'Your choice of soda (Coke, Sprite, Fanta)',
        price: 2.99,
        imageUrl: 'assets/images/soft_drink.jpg',
        category: FoodCategory.drinks,
      ),
      FoodItem(
        id: '11',
        name: 'Milkshake',
        description: 'Creamy milkshake (Chocolate, Vanilla, or Strawberry)',
        price: 4.99,
        imageUrl: 'assets/images/milkshake.jpg',
        category: FoodCategory.drinks,
        isPopular: true,
      ),
      FoodItem(
        id: '12',
        name: 'Bottled Water',
        description: '500ml bottled water',
        price: 1.99,
        imageUrl: 'assets/images/water.jpg',
        category: FoodCategory.drinks,
      ),
      
      // Desserts
      FoodItem(
        id: '13',
        name: 'Chocolate Brownie',
        description: 'Warm chocolate brownie with ice cream',
        price: 5.99,
        imageUrl: 'assets/images/brownie.jpg',
        category: FoodCategory.desserts,
        isPopular: true,
      ),
      FoodItem(
        id: '14',
        name: 'Ice Cream Sundae',
        description: 'Vanilla ice cream with chocolate sauce and sprinkles',
        price: 4.99,
        imageUrl: 'assets/images/sundae.jpg',
        category: FoodCategory.desserts,
      ),
      FoodItem(
        id: '15',
        name: 'Cheesecake',
        description: 'New York style cheesecake with berry compote',
        price: 6.99,
        imageUrl: 'assets/images/cheesecake.jpg',
        category: FoodCategory.desserts,
      ),
    ];
  }
} 
import 'package:flutter/material.dart';

enum FoodCategory {
  burgers,
  pizza,
  sides,
  drinks,
  desserts,
}

extension FoodCategoryExtension on FoodCategory {
  String get displayName {
    switch (this) {
      case FoodCategory.burgers:
        return 'Burgers';
      case FoodCategory.pizza:
        return 'Pizza';
      case FoodCategory.sides:
        return 'Sides';
      case FoodCategory.drinks:
        return 'Drinks';
      case FoodCategory.desserts:
        return 'Desserts';
    }
  }

  IconData get icon {
    switch (this) {
      case FoodCategory.burgers:
        return Icons.lunch_dining;
      case FoodCategory.pizza:
        return Icons.local_pizza;
      case FoodCategory.sides:
        return Icons.dinner_dining;
      case FoodCategory.drinks:
        return Icons.local_drink;
      case FoodCategory.desserts:
        return Icons.icecream;
    }
  }
}

class FoodItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final FoodCategory category;
  final bool isPopular;
  final List<String>? customizationOptions;

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isPopular = false,
    this.customizationOptions,
  });
}

class CartItem {
  final FoodItem item;
  int quantity;
  final List<String>? selectedCustomizations;

  CartItem({
    required this.item,
    this.quantity = 1,
    this.selectedCustomizations,
  });

  double get totalPrice => item.price * quantity;
}

class Cart {
  List<CartItem> items = [];
  
  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);
  
  double calculateDiscount(int loyaltyPoints) {
    // Apply 5% discount for every 100 points, up to 20%
    final discountPercentage = (loyaltyPoints / 100).floor() * 5;
    final maxDiscountPercentage = 20.0;
    final appliedDiscount = discountPercentage > maxDiscountPercentage 
        ? maxDiscountPercentage 
        : discountPercentage;
    
    return (subtotal * appliedDiscount) / 100;
  }
  
  double calculateTotal(int loyaltyPoints) {
    return subtotal - calculateDiscount(loyaltyPoints);
  }
  
  void addItem(CartItem item) {
    // Check if item already exists in cart
    final existingItemIndex = items.indexWhere(
      (cartItem) => cartItem.item.id == item.item.id && 
        _areCustomizationsSame(cartItem.selectedCustomizations, item.selectedCustomizations)
    );
    
    if (existingItemIndex != -1) {
      // Increment quantity if item already exists
      items[existingItemIndex].quantity += item.quantity;
    } else {
      // Add new item to cart
      items.add(item);
    }
  }
  
  void removeItem(String itemId) {
    items.removeWhere((item) => item.item.id == itemId);
  }
  
  void updateQuantity(String itemId, int quantity) {
    final index = items.indexWhere((item) => item.item.id == itemId);
    if (index != -1) {
      if (quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index].quantity = quantity;
      }
    }
  }
  
  void clear() {
    items.clear();
  }
  
  bool _areCustomizationsSame(List<String>? list1, List<String>? list2) {
    if (list1 == null && list2 == null) return true;
    if (list1 == null || list2 == null) return false;
    if (list1.length != list2.length) return false;
    
    for (var i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    
    return true;
  }
}

enum OrderStatus {
  placed,
  preparing,
  ready,
  collected,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready for Collection';
      case OrderStatus.collected:
        return 'Collected';
    }
  }
}

class Order {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double total;
  final DateTime orderTime;
  OrderStatus status;
  final String? notes;

  Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.orderTime,
    this.status = OrderStatus.placed,
    this.notes,
  });
} 
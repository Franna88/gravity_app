import 'package:flutter/material.dart';
import 'package:gravity_rewards_app/constants/app_constants.dart';
import 'package:gravity_rewards_app/models/food_item.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class FoodOrderTrackingScreen extends StatefulWidget {
  final Order order;
  
  const FoodOrderTrackingScreen({
    Key? key,
    required this.order,
  }) : super(key: key);
  
  @override
  State<FoodOrderTrackingScreen> createState() => _FoodOrderTrackingScreenState();
}

class _FoodOrderTrackingScreenState extends State<FoodOrderTrackingScreen> {
  late OrderStatus currentStatus;
  
  @override
  void initState() {
    super.initState();
    currentStatus = widget.order.status;
  }
  
  void _advanceOrderStatus() {
    setState(() {
      switch (currentStatus) {
        case OrderStatus.placed:
          currentStatus = OrderStatus.preparing;
          widget.order.status = OrderStatus.preparing;
          break;
        case OrderStatus.preparing:
          currentStatus = OrderStatus.ready;
          widget.order.status = OrderStatus.ready;
          break;
        case OrderStatus.ready:
          currentStatus = OrderStatus.collected;
          widget.order.status = OrderStatus.collected;
          break;
        case OrderStatus.collected:
          // Already at final status
          break;
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Status'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _advanceOrderStatus,
        backgroundColor: AppColors.primary,
        tooltip: 'Advance order status (testing only)',
        child: const Icon(Icons.arrow_forward, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderStatusCard(),
            const SizedBox(height: 24),
            _buildAnimationCard(),
            const SizedBox(height: 24),
            _buildOrderDetails(),
            const SizedBox(height: 24),
            _buildOrderItems(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Pop until we reach home screen
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderStatusCard() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusBadge(currentStatus),
              ],
            ),
            const SizedBox(height: 24),
            _buildStatusTimeline(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.placed:
        color = Colors.blue;
        break;
      case OrderStatus.preparing:
        color = Colors.orange;
        break;
      case OrderStatus.ready:
        color = AppColors.accent;
        break;
      case OrderStatus.collected:
        color = Colors.green;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
  
  Widget _buildStatusTimeline() {
    return Column(
      children: [
        _buildTimelineItem(
          OrderStatus.placed,
          'Order Placed',
          DateFormat.jm().format(widget.order.orderTime),
          isCompleted: true,
        ),
        _buildTimelineItem(
          OrderStatus.preparing,
          'Preparing',
          'Est. ${DateFormat.jm().format(widget.order.orderTime.add(const Duration(minutes: 5)))}',
          isCompleted: currentStatus == OrderStatus.preparing || 
                      currentStatus == OrderStatus.ready ||
                      currentStatus == OrderStatus.collected,
        ),
        _buildTimelineItem(
          OrderStatus.ready,
          'Ready for Collection',
          'Est. ${DateFormat.jm().format(widget.order.orderTime.add(const Duration(minutes: 15)))}',
          isCompleted: currentStatus == OrderStatus.ready ||
                      currentStatus == OrderStatus.collected,
          isLast: true,
        ),
      ],
    );
  }
  
  Widget _buildTimelineItem(
    OrderStatus status,
    String title,
    String time, {
    required bool isCompleted,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status indicator
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.accent : Colors.grey[300],
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? AppColors.accent : Colors.grey,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? AppColors.accent : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 12),
        
        // Status info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.black : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: isCompleted ? Colors.black54 : Colors.grey,
                ),
              ),
              if (!isLast) const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildOrderDetails() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Order Number', '#${widget.order.id.substring(0, 8)}'),
            _buildDetailRow('Order Date', DateFormat.yMMMd().format(widget.order.orderTime)),
            _buildDetailRow('Order Time', DateFormat.jm().format(widget.order.orderTime)),
            if (widget.order.notes != null && widget.order.notes!.isNotEmpty)
              _buildDetailRow('Notes', widget.order.notes!),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderItems() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...widget.order.items.map((item) => _buildOrderItem(item)).toList(),
            const Divider(),
            _buildPriceSummary(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderItem(CartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quantity
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${item.quantity}x',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
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
                  item.item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.selectedCustomizations != null &&
                    item.selectedCustomizations!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item.selectedCustomizations!.join(', '),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Price
          Text(
            'R${(item.item.price * item.quantity).toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPriceSummary() {
    return Column(
      children: [
        _buildPriceRow('Subtotal', 'R${widget.order.subtotal.toStringAsFixed(2)}'),
        _buildPriceRow(
          'Loyalty Discount', 
          '-R${widget.order.discount.toStringAsFixed(2)}',
          isDiscount: true,
        ),
        const SizedBox(height: 8),
        _buildPriceRow(
          'Total', 
          'R${widget.order.total.toStringAsFixed(2)}',
          isBold: true,
        ),
      ],
    );
  }
  
  Widget _buildPriceRow(
    String label, 
    String amount, {
    bool isBold = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: isDiscount ? AppColors.accent : null,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnimationCard() {
    // Only show animation for preparing and ready statuses
    if (currentStatus != OrderStatus.preparing && currentStatus != OrderStatus.ready) {
      return const SizedBox.shrink();
    }
    
    String animationPath;
    String statusText;
    
    if (currentStatus == OrderStatus.preparing) {
      animationPath = 'images/animations/Preping-Order.json';
      statusText = 'Your order is being prepared...';
    } else {
      animationPath = 'images/animations/Order-Ready.json';
      statusText = 'Your order is ready for collection!';
    }
    
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              statusText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Lottie.asset(
                animationPath,
                height: 200,
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
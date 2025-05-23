import 'package:flutter/material.dart';
import 'package:gravity_rewards_app/constants/app_constants.dart';
import 'package:gravity_rewards_app/providers/auth_provider.dart';
import 'package:gravity_rewards_app/providers/food_service_provider.dart';
import 'package:gravity_rewards_app/screens/food_order_tracking_screen.dart';
import 'package:gravity_rewards_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class FoodPaymentScreen extends StatefulWidget {
  final double subtotal;
  final double discount;
  final double total;
  final int loyaltyPoints;

  const FoodPaymentScreen({
    Key? key,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.loyaltyPoints,
  }) : super(key: key);

  @override
  State<FoodPaymentScreen> createState() => _FoodPaymentScreenState();
}

class _FoodPaymentScreenState extends State<FoodPaymentScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Form fields
  String _cardNumber = '';
  String _expiryDate = '';
  String _cvv = '';
  String _nameOnCard = '';
  bool _saveCard = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        elevation: 0,
      ),
      body: _isProcessing
          ? _buildProcessingUI()
          : _buildPaymentForm(),
    );
  }
  
  Widget _buildProcessingUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 24),
                Text(
                  'Processing your payment...',
                  style: AppTextStyles.headline3.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait while we confirm your order',
                  style: AppTextStyles.body2,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentForm() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderSummary(),
              const SizedBox(height: 32),
              
              Text(
                'Payment Method',
                style: AppTextStyles.headline2.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              
              // Card details container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardNumberField(),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildExpiryField()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildCVVField()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildNameField(),
                    const SizedBox(height: 16),
                    _buildSaveCardCheckbox(),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              CustomButton(
                text: 'Pay R${widget.total.toStringAsFixed(2)}',
                onPressed: _processPayment,
                height: 56,
                backgroundColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCardNumberField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Card Number',
        hintText: '1234 5678 9012 3456',
        prefixIcon: Icon(Icons.credit_card, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your card number';
        }
        if (value.length < 16) {
          return 'Please enter a valid card number';
        }
        return null;
      },
      onChanged: (value) => setState(() => _cardNumber = value),
    );
  }

  Widget _buildExpiryField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Expiry Date',
        hintText: 'MM/YY',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.text,
      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
      onChanged: (value) => setState(() => _expiryDate = value),
    );
  }

  Widget _buildCVVField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'CVV',
        hintText: '123',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
      onChanged: (value) => setState(() => _cvv = value),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Name on Card',
        hintText: 'John Smith',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the name on your card';
        }
        return null;
      },
      onChanged: (value) => setState(() => _nameOnCard = value),
    );
  }

  Widget _buildSaveCardCheckbox() {
    return Theme(
      data: Theme.of(context).copyWith(
        unselectedWidgetColor: AppColors.textSecondary,
      ),
      child: CheckboxListTile(
        title: Text(
          'Save card for future payments',
          style: AppTextStyles.body1,
        ),
        value: _saveCard,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        activeColor: AppColors.accent,
        onChanged: (value) => setState(() => _saveCard = value ?? false),
      ),
    );
  }
  
  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.accent.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: AppTextStyles.headline2.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          _buildSummaryRow('Subtotal', 'R${widget.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Loyalty Discount', 
            '-R${widget.discount.toStringAsFixed(2)}',
            valueColor: AppColors.accent,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              color: AppColors.divider.withOpacity(0.5),
              thickness: 1,
            ),
          ),
          _buildSummaryRow(
            'Total', 
            'R${widget.total.toStringAsFixed(2)}',
            isBold: true,
            isLarge: true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryRow(
    String label, 
    String value, {
    bool isBold = false,
    bool isLarge = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: (isLarge ? AppTextStyles.headline3 : AppTextStyles.body1).copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: (isLarge ? AppTextStyles.headline3 : AppTextStyles.body1).copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor,
          ),
        ),
      ],
    );
  }
  
  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isProcessing = true);
    
    try {
      await Future.delayed(const Duration(seconds: 2));
      
      final foodProvider = Provider.of<FoodServiceProvider>(context, listen: false);
      final order = await foodProvider.placeOrder(widget.loyaltyPoints);
      
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => FoodOrderTrackingScreen(order: order),
        ),
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      
      setState(() => _isProcessing = false);
    }
  }
} 
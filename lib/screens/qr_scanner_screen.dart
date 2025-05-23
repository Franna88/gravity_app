import 'package:flutter/material.dart';
import 'package:gravity_rewards_app/constants/app_constants.dart';
import 'package:gravity_rewards_app/providers/activity_provider.dart';
import 'package:gravity_rewards_app/providers/auth_provider.dart';
import 'package:gravity_rewards_app/providers/rewards_provider.dart';
import 'package:gravity_rewards_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({Key? key}) : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  String? result;
  bool _isProcessing = false;
  bool _success = false;
  bool _error = false;
  String _message = '';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _processQrCode(String? code) async {
    if (code == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      result = code;
    });

    // Pause camera
    await controller.stop();

    // Process QR code
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
      final rewardsProvider = Provider.of<RewardsProvider>(context, listen: false);

      if (authProvider.user == null) {
        setState(() {
          _error = true;
          _message = 'User not authenticated. Please log in.';
        });
        return;
      }

      final success = await activityProvider.validateQrCodeAndAddPoints(
        authProvider.user!.id,
        code,
        rewardsProvider,
      );

      if (success) {
        setState(() {
          _success = true;
          _message = 'Points added successfully! You earned 10 points.';
        });
      } else {
        setState(() {
          _error = true;
          _message = 'Invalid QR code or points already claimed.';
        });
      }
    } catch (e) {
      setState(() {
        _error = true;
        _message = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _resetScanner() async {
    setState(() {
      result = null;
      _success = false;
      _error = false;
      _message = '';
    });
    await controller.start();
  }

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Stack(
        children: [
          // QR Scanner View
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                _processQrCode(barcode.rawValue);
              }
            },
          ),
          
          // Info Box at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: AppColors.black.withOpacity(0.7),
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: const Text(
                'Scan the QR code at Gravity Trampoline Park to earn rewards points',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Result Overlay
          if (_success || _error)
            Container(
              color: AppColors.black.withOpacity(0.8),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(AppDimensions.paddingLarge),
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _success ? Icons.check_circle : Icons.error,
                        color: _success ? AppColors.accent : Colors.red,
                        size: 80,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _success ? 'Success!' : 'Error',
                        style: AppTextStyles.headline2.copyWith(
                          color: _success ? AppColors.accent : Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _message,
                        style: AppTextStyles.bodyText,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_success)
                            Expanded(
                              child: CustomButton(
                                text: 'Done',
                                onPressed: _goBack,
                              ),
                            )
                          else
                            Expanded(
                              child: CustomButton(
                                text: 'Try Again',
                                onPressed: _resetScanner,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Processing overlay
          if (_isProcessing)
            Container(
              color: AppColors.black.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.accent,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Processing QR Code...',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
} 
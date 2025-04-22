import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gravity_rewards_app/constants/app_constants.dart';
import 'package:gravity_rewards_app/providers/activity_provider.dart';
import 'package:gravity_rewards_app/providers/auth_provider.dart';
import 'package:gravity_rewards_app/providers/rewards_provider.dart';
import 'package:gravity_rewards_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({Key? key}) : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;
  bool _isProcessing = false;
  bool _success = false;
  bool _error = false;
  String _message = '';

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_isProcessing && !_success && !_error) {
        _processQrCode(scanData);
      }
    });
  }

  Future<void> _processQrCode(Barcode scanData) async {
    setState(() {
      _isProcessing = true;
      result = scanData;
    });

    // Pause camera
    await controller?.pauseCamera();

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
        scanData.code ?? '',
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
    await controller?.resumeCamera();
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
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: AppColors.primary,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 300,
            ),
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
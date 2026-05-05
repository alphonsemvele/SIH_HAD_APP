import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../services/qr_service.dart';
import 'visite_realisation_screen.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanning = true;
  bool _isLoading = false;
  double? _currentLat;
  double? _currentLng;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    // Demander la permission caméra
    final cameraStatus = await Permission.camera.request();
    if (!cameraStatus.isGranted) {
      _showPermissionDeniedDialog('Caméra');
      return;
    }

    // Demander la permission de localisation
    final locationStatus = await Permission.locationWhenInUse.request();
    if (!locationStatus.isGranted) {
      _showPermissionDeniedDialog('Localisation');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLat = position.latitude;
        _currentLng = position.longitude;
      });
    } catch (e) {
      // La localisation n'est pas obligatoire pour le scan
      print('Erreur lors de la récupération de la localisation: $e');
    }
  }

  void _showPermissionDeniedDialog(String permission) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission $permission refusée'),
          content: Text('Cette permission est nécessaire pour scanner les QR codes.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Retour à l'écran précédent
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Paramètres'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onBarcodeCapture(BarcodeCapture capture) async {
    if (!_isScanning || _isLoading) return;

    final barcode = capture.barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() {
      _isScanning = false;
      _isLoading = true;
    });

    try {
      final qrService = QrService();
      final result = await qrService.scanQrCode(
        barcode.rawValue!,
        lat: _currentLat,
        lng: _currentLng,
      );

      if (mounted) {
        // En cas de succès, naviguer vers l'écran de réalisation de visite
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VisiteRealisationScreen(visite: result),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() {
          _isScanning = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scanner QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off:
                  case TorchState.unavailable:
                    return const Icon(Icons.flash_off);
                  case TorchState.on:
                    return const Icon(Icons.flash_on);
                  case TorchState.auto:
                    return const Icon(Icons.flash_auto);
                }
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onBarcodeCapture,
          ),
          
          // Overlay de scan
          CustomPaint(
            size: Size.infinite,
            painter: ScannerOverlayPainter(),
          ),
          
          // Instructions
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text(
                    'Scannez le QR code de la prestation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Positionnez le QR code dans le cadre',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Analyse du QR code...',
                      style: TextStyle(
                        color: Colors.white,
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

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFFFF4433)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 250,
      height: 250,
    );

    // Dessiner les coins
    final cornerLength = 30.0;
    final cornerWidth = 4.0;

    // Coin supérieur gauche
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          scanRect.left,
          scanRect.top,
          cornerLength,
          cornerWidth,
        ),
        const Radius.circular(2),
      ),
      borderPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          scanRect.left,
          scanRect.top,
          cornerWidth,
          cornerLength,
        ),
        const Radius.circular(2),
      ),
      borderPaint,
    );

    // Coin supérieur droit
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          scanRect.right - cornerLength,
          scanRect.top,
          cornerLength,
          cornerWidth,
        ),
        const Radius.circular(2),
      ),
      borderPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          scanRect.right - cornerWidth,
          scanRect.top,
          cornerWidth,
          cornerLength,
        ),
        const Radius.circular(2),
      ),
      borderPaint,
    );

    // Coin inférieur gauche
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          scanRect.left,
          scanRect.bottom - cornerWidth,
          cornerLength,
          cornerWidth,
        ),
        const Radius.circular(2),
      ),
      borderPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          scanRect.left,
          scanRect.bottom - cornerLength,
          cornerWidth,
          cornerLength,
        ),
        const Radius.circular(2),
      ),
      borderPaint,
    );

    // Coin inférieur droit
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          scanRect.right - cornerLength,
          scanRect.bottom - cornerWidth,
          cornerLength,
          cornerWidth,
        ),
        const Radius.circular(2),
      ),
      borderPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          scanRect.right - cornerWidth,
          scanRect.bottom - cornerLength,
          cornerWidth,
          cornerLength,
        ),
        const Radius.circular(2),
      ),
      borderPaint,
    );

    // Masquer les zones extérieures
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(scanRect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

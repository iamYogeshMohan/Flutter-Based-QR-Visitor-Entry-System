import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => _isProcessing = true);
        
        try {
          final data = jsonDecode(barcode.rawValue!);
          final visitorId = data['visitorId'];

          if (visitorId != null) {
            bool success = await ApiService.checkInVisitor(visitorId);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(success ? 'Check-in Successful!' : 'Check-in Failed!')),
            );
            Navigator.pop(context);
            return;
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid QR Code')),
          );
        }

        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan Visitor QR')),
      body: MobileScanner(
        onDetect: _onDetect,
      ),
    );
  }
}

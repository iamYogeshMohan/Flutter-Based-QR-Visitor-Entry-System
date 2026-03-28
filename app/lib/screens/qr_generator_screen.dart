import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/visitor_model.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';

class QRGeneratorScreen extends StatelessWidget {
  final VisitorModel visitor;

  QRGeneratorScreen({required this.visitor});

  @override
  Widget build(BuildContext context) {
    // Generate the URL directly into our local Node.js backend
    final String qrImageUrl = '${ApiService.baseUrl}/visitors/${visitor.id}/qrcode.png';

    return Scaffold(
      appBar: AppBar(title: Text('Visitor QR Code')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Share this QR code with the visitor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 30),
              Container(
                width: 250,
                height: 250,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
                ),
                child: Image.network(
                  qrImageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Center(child: Text("QR Failed to load")),
                ),
              ),
              SizedBox(height: 30),
              Text('Name: ${visitor.name}', style: TextStyle(fontSize: 18)),
              Text('Phone: ${visitor.phone}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (context) => DashboardScreen()), 
                    (route) => false,
                  );
                },
                child: Text('Back to Dashboard'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

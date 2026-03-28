import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/visitor_provider.dart';
import '../models/visitor_model.dart';
import 'qr_generator_screen.dart';

class VisitorDashboard extends StatefulWidget {
  @override
  _VisitorDashboardState createState() => _VisitorDashboardState();
}

class _VisitorDashboardState extends State<VisitorDashboard> {
  Timer? _timer;
  String _timeRemaining = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VisitorProvider>(context, listen: false).setupSocketListeners();
      Provider.of<VisitorProvider>(context, listen: false).fetchVisitors();
      
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        _updateCountdown();
      });
    });
  }

  void _updateCountdown() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final visitorProvider = Provider.of<VisitorProvider>(context, listen: false);
    
    // Find my visitor record (assuming user email matches visitor or registered by me)
    // For simplicity, we find the first visitor registered by this user that is checked in
    try {
      final myVisitor = visitorProvider.visitors.firstWhere(
        (v) => v.registeredByName == authProvider.user?.name && v.checkIn != null && v.checkOut == null
      );
      
      final checkInTime = DateTime.parse(myVisitor.checkIn!);
      final expiryTime = checkInTime.add(Duration(hours: 2)); // 2 hours limit
      final now = DateTime.now();
      
      if (now.isAfter(expiryTime)) {
        setState(() { _timeRemaining = "Time Expired!"; });
      } else {
        final duration = expiryTime.difference(now);
        setState(() {
          _timeRemaining = "${duration.inHours}h ${duration.inMinutes.remainder(60)}m ${duration.inSeconds.remainder(60)}s";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _timeRemaining = ""; });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final visitorProvider = Provider.of<VisitorProvider>(context);

    // Filter visitors created by this user
    final myVisits = visitorProvider.visitors.where(
      (v) => v.registeredByName == authProvider.user?.name
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Visitor Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
            },
          )
        ],
      ),
      body: visitorProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_timeRemaining.isNotEmpty)
                  Container(
                    width: double.infinity,
                    color: Colors.redAccent,
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Time until exit: $_timeRemaining',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: myVisits.length,
                    itemBuilder: (context, index) {
                      final visitor = myVisits[index];
                      return Card(
                        margin: EdgeInsets.all(12),
                        child: ListTile(
                          title: Text(visitor.name, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Status: ${visitor.status}\nChecked In: ${visitor.checkIn != null ? "Yes" : "No"}'),
                          trailing: IconButton(
                            icon: Icon(Icons.qr_code, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => QRGeneratorScreen(visitor: visitor)));
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

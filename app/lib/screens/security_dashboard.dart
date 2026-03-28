import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/visitor_provider.dart';
import 'qr_scanner_screen.dart';

class SecurityDashboard extends StatefulWidget {
  @override
  _SecurityDashboardState createState() => _SecurityDashboardState();
}

class _SecurityDashboardState extends State<SecurityDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VisitorProvider>(context, listen: false).setupSocketListeners();
      Provider.of<VisitorProvider>(context, listen: false).fetchVisitors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final visitorProvider = Provider.of<VisitorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Security Guard Post'),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => authProvider.logout(),
          )
        ],
      ),
      body: visitorProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: visitorProvider.visitors.length,
              itemBuilder: (context, index) {
                final visitor = visitorProvider.visitors[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(
                      visitor.checkIn != null && visitor.checkOut == null ? Icons.door_front_door : Icons.person,
                      color: visitor.checkIn != null ? Colors.orange : Colors.grey,
                    ),
                    title: Text(visitor.name, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('ID: ${visitor.id.substring(visitor.id.length - 6)}\nStatus: ${visitor.status}'),
                    trailing: Text(
                      visitor.checkIn != null && visitor.checkOut == null ? "ACTIVE" : (visitor.checkOut != null ? "EXITED" : "WAITING"),
                      style: TextStyle(fontWeight: FontWeight.bold, color: visitor.checkIn != null && visitor.checkOut == null ? Colors.red : Colors.green)
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueGrey,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QRScannerScreen())),
        icon: Icon(Icons.qr_code_scanner),
        label: Text('Scan QR to Check In/Out'),
      ),
    );
  }
}

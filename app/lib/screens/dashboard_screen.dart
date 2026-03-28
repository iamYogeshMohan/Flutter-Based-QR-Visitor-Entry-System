import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'admin_dashboard.dart';
import 'security_dashboard.dart';
import 'visitor_dashboard.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    if (user == null) {
      return Scaffold(body: Center(child: Text("Loading...")));
    }

    if (user.role == 'Admin') {
      return AdminDashboard();
    } else if (user.role == 'Security') {
      return SecurityDashboard();
    } else {
      return VisitorDashboard();
    }
  }
}

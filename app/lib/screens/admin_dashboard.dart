import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/visitor_provider.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'registration_screen.dart';
import 'signup_screen.dart'; // used to add new users

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<UserModel> _usersList = [];
  bool _loadingUsers = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VisitorProvider>(context, listen: false).setupSocketListeners();
      Provider.of<VisitorProvider>(context, listen: false).fetchVisitors();
    });
  }

  void _fetchUsers() async {
    final fetchedUsers = await ApiService.getUsers();
    if (mounted) {
      setState(() {
        _usersList = fetchedUsers;
        _loadingUsers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final visitorProvider = Provider.of<VisitorProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Control Panel'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => authProvider.logout(),
            )
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people), text: "Visitors"),
              Tab(icon: Icon(Icons.security), text: "Users & Staff"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Visitors Tab
            visitorProvider.isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: visitorProvider.visitors.length,
                    itemBuilder: (context, index) {
                      final visitor = visitorProvider.visitors[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(visitor.name, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Status: ${visitor.status}\nAdded By: ${visitor.registeredByName ?? "Unknown"}'),
                          trailing: IconButton(
                            icon: Icon(Icons.check_circle, color: visitor.status == 'Approved' ? Colors.green : Colors.grey),
                            onPressed: () => ApiService.updateVisitorStatus(visitor.id, 'Approved'),
                          ),
                        ),
                      );
                    },
                  ),
            // Users Tab
            _loadingUsers
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _usersList.length,
                    itemBuilder: (context, index) {
                      final u = _usersList[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text(u.name.substring(0,1))),
                        title: Text(u.name),
                        subtitle: Text(u.email),
                        trailing: Text(u.role, style: TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            // Give admin option to add Visitor or User
            showModalBottomSheet(
              context: context,
              builder: (_) => Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Add New Visitor'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrationScreen()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.admin_panel_settings),
                      title: Text('Add New User / Security'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen()));
                      },
                    ),
                  ],
                ),
              )
            );
          },
        ),
      ),
    );
  }
}

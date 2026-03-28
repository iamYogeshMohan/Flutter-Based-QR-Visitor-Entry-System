import 'package:flutter/material.dart';
import '../models/visitor_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class VisitorProvider with ChangeNotifier {
  List<VisitorModel> _visitors = [];
  bool _isLoading = false;

  List<VisitorModel> get visitors => _visitors;
  bool get isLoading => _isLoading;

  Future<void> fetchVisitors() async {
    _isLoading = true;
    notifyListeners();

    _visitors = await ApiService.getVisitors();
    
    _isLoading = false;
    notifyListeners();
  }

  void setupSocketListeners() {
    SocketService.initSocket();

    SocketService.onNewVisitor((data) {
      _visitors.insert(0, VisitorModel.fromJson(data));
      notifyListeners();
    });

    SocketService.onVisitorStatusUpdated((data) {
      _updateVisitorList(data);
    });

    SocketService.onVisitorCheckIn((data) {
      _updateVisitorList(data);
    });

    SocketService.onVisitorCheckOut((data) {
      _updateVisitorList(data);
    });
  }

  void _updateVisitorList(dynamic data) {
    var updatedVisitor = VisitorModel.fromJson(data);
    int index = _visitors.indexWhere((v) => v.id == updatedVisitor.id);
    if (index != -1) {
      _visitors[index] = updatedVisitor;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    SocketService.dispose();
    super.dispose();
  }
}

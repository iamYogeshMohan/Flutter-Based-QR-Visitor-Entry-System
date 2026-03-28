import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketService {
  static IO.Socket? socket;

  static void initSocket() {
    socket = IO.io(kIsWeb ? 'http://localhost:5000' : 'http://10.0.2.2:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    
    socket!.connect();
    
    socket!.onConnect((_) {
      print('Connected to Socket server');
    });

    socket!.onDisconnect((_) {
      print('Disconnected from Socket server');
    });
  }

  static void onNewVisitor(Function(dynamic) callback) {
    socket?.on('new_visitor', callback);
  }

  static void onVisitorStatusUpdated(Function(dynamic) callback) {
    socket?.on('visitor_status_updated', callback);
  }

  static void onVisitorCheckIn(Function(dynamic) callback) {
    socket?.on('visitor_checkin', callback);
  }

  static void onVisitorCheckOut(Function(dynamic) callback) {
    socket?.on('visitor_checkout', callback);
  }
  
  static void onUnauthorizedAccess(Function(dynamic) callback) {
    socket?.on('unauthorized_access', callback);
  }

  static void dispose() {
    socket?.dispose();
  }
}

// socket_io_provider.dart

import 'package:carecompass/constants/global_variables.dart';
import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketIOProvider extends ChangeNotifier {
  final IO.Socket _socket = IO.io(uri, <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': true,
  });
  void initSocket(String userId) {
    _socket.onConnect((_) {
      _socket.emit('subscribe', userId);
    });
    _socket.onDisconnect((_) => print('disconnect'));

    _socket.on('error', (data) {
      print('error: $data');
    });

    _socket.connect();
  }

  void disconnect() {
    _socket.disconnect();
  }

  IO.Socket getSocket() {
    return _socket;
  }
}

// ignore_for_file: avoid_print

import 'package:carecompass/constants/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketIO {
  late IO.Socket socket;

  void initSocket() {
    // Replace 'http://your-server-host:your-server-port' with your Socket.IO server URL
    socket = IO.io(uri, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    socket.onConnect((_) {
      for (int i = 0; i < 100; i++) {
        print('connect $i');
      }
      socket.emit('msg', 'test');
    });
    socket.on('connect', (_) {
      print('Connected to server');
      socket.emit('chat message', 'Hello from Flutter client');
    });

    socket.on('chat message', (data) {
      print('Received message from server: $data');
    });
    socket.onDisconnect((_) => print('disconnect'));

    socket.on('disconnect', (_) => print('Disconnected from server'));

    // socket.on('event', (data) => print(data));
    // socket.on('fromServer', (_) => print(_));
    socket.connect();
  }

  void sendMessage(String message) {
    socket.emit('chat message', message);
  }

  void disconnect() {
    socket.disconnect();
  }

  IO.Socket getSocketClient() {
    return socket;
  }
}
// }
// final SocketIO socketIO = SocketIO();
// socketIO.initSocket();
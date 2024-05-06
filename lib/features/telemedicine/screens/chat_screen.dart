// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:carecompass/constants/global_variables.dart';
import 'package:carecompass/models/appointment.dart';
import 'package:carecompass/providers/socket_provider.dart';
import 'package:carecompass/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:http/http.dart' as http;

import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

// try to adjust according to your need

class ChatScreen extends StatefulWidget {
  final Appointment receiver;

  const ChatScreen({Key? key, required this.receiver}) : super(key: key);
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late types.User _sender;
  final List<types.Message> _messages = [];
  final _socketResponse = StreamController<List<types.Message>>();

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _sender = types.User(
      id: userProvider.user.id,
    );
    fetchMessage(null);
    Provider.of<SocketIOProvider>(context, listen: false)
        .getSocket()
        .on("get_message_response", (data) {
      var messageData = data['messages'];
      print('Received message from server: ');
      print(messageData);
      if (messageData is List && messageData.isNotEmpty) {
        print(1);
        for (var i = 0; i < messageData.length; i++) {
          // @TODO: Add logic to handle different message types
          // @TODO: Add All message to the messages list
          print(messageData[i]);
          _addMessage(types.TextMessage(
              id: const Uuid().v4(),
              author: types.User(id: messageData[i]["sender"].toString()),
              text: messageData[i]["data"],
              createdAt: DateTime.parse(messageData[i]["sentAt"])
                  .millisecondsSinceEpoch));
        }
        _socketResponse.sink.add(_messages);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _socketResponse.close();
  }

  Future<void> fetchMessage(String? dte) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // print(userProvider.user.token);
    final finalUrl = Uri.parse('$uri/telemedicine_api/get_message');

    Map<String, dynamic> requestBody = {
      'receiver': widget.receiver.userId,
    };
    if (dte != null) {
      requestBody['time'] = dte;
    }
    try {
      final response = await http.post(
        finalUrl,
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        var messageData = jsonDecode(response.body)['messages'];
        var serialNumber = jsonDecode(response.body)['serialNumber'];

        // print(new DateTime.fromMicrosecondsSinceEpoch(
        //     DateTime.parse(messageData[0]["sentAt"]).millisecondsSinceEpoch *
        //         1000));
        // DateTime.parse(messageData[0]["sentAt"])
        if (messageData.length > 0) {
          // List<types.Message> messages = [];
          for (var i = 0; i < messageData.length; i++) {
            // @TODO: Add logic to handle different message types
            // @TODO: Add All message to the messages list
            print(messageData[i]);
            _addMessage(types.TextMessage(
                id: const Uuid().v4(),
                author: types.User(id: messageData[i]["sender"].toString()),
                text: messageData[i]["data"],
                createdAt: DateTime.parse(messageData[i]["sentAt"])
                    .millisecondsSinceEpoch));
          }
          _socketResponse.sink.add(_messages);
        }
        // Handle the message data here
      } else {
        print('Failed to fetch messages. Status code: ${response.statusCode}');
        // Handle the error response here
      }
    } catch (e) {
      print('Error: $e');
      // Handle any exceptions that occur during the request
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(_socketResponse.stream.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiver.name),
      ),
      body: StreamBuilder(
          stream: _socketResponse.stream,
          builder: (context, AsyncSnapshot<List<types.Message>> snapshot) {
            return Chat(
                messages: snapshot.data ?? [],
                onSendPressed: (message) {
                  // print(message.text);
                  // Call the sendMessage method here with appropriate parameters
                  sendMessage(context, widget.receiver.userId, message.text);
                },
                user: types.User(
                    id: Provider.of<UserProvider>(context, listen: false)
                        .user
                        .id));
          }),
    );
  }

  Future<void> sendMessage(
      BuildContext context, String receiver, String message) async {
    // Replace with your actual data
    final data = {
      'receiver': receiver, // Replace with the actual receiver's user ID
      'data': message,
      'type': 'TEXT', // Replace with the desired message type
      'authToken': Provider.of<UserProvider>(context, listen: false)
          .user
          .token, // Replace with the actual authentication token
    };
    print(data);
    Provider.of<SocketIOProvider>(context, listen: false)
        .getSocket()
        .emit('send_message', data);
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _sender,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: "id",
      text: message.text,
    );

    _addMessage(textMessage);
  }
}

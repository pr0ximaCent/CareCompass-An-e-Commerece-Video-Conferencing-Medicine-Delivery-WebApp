import 'dart:async';
import 'dart:convert';

import 'package:carecompass/common/service/notification_service.dart';
import 'package:carecompass/constants/global_variables.dart';
import 'package:carecompass/features/telemedicine/screens/video_call_screen.dart';
import 'package:carecompass/features/telemedicine/widget/appointment_card.dart';
import 'package:carecompass/models/appointment.dart';
import 'package:carecompass/providers/socket_provider.dart';
import 'package:carecompass/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class InboxScreen extends StatefulWidget {
  static const String routeName = "/inbox_screen";
  const InboxScreen({Key? key}) : super(key: key);

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  ValueNotifier<bool> specialConditionFlag =
      ValueNotifier(false); // Step 1: Use ValueNotifier
  String _callID = "";
  String _userName = "";
  @override
  void initState() {
    super.initState();

    Provider.of<SocketIOProvider>(context, listen: false)
        .getSocket()
        .on("got_video_call_request", (data) {
      // print("object");
      // print(data);
      _userName = data['userName'];
      _callID = data['callID'];
      if (specialConditionFlag.value != data['startConsultationRequest']) {
        if (data['startConsultationRequest'] == true) {
          showNotificationAndroid('Video Call', "$_userName is Calling you");
        } else {
          showNotificationAndroid(
              'Video Call', "$_userName has ended the call");
        }
      }
      specialConditionFlag.value = data['startConsultationRequest'];
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<Appointment>> fetchData(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final url = Uri.parse('$uri/telemedicine_api/inbox');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'x-auth-token': userProvider.user.token
    });

    final responseData = json.decode(response.body);
    if (responseData.runtimeType == List) {
      return List.generate(responseData.length, (index) {
        if (responseData[index]["start_consultation_request_by_doctor"] ==
            true) {
          specialConditionFlag.value = true;
          _callID = responseData[index]["_id"];
          _userName =
              responseData[index]['user_one']["_id"] == userProvider.user.id
                  ? responseData[index]['user_two']["name"]
                  : responseData[index]['user_one']["name"];
          print(_callID);
        }
        // print(responseData[index]["start_consultation_request_by_doctor"]);
        // print(responseData[index]["_id"]);
        return Appointment(
            id: responseData[index]['_id'],
            serialNumber: responseData[index]['serialNumber'],
            start_consultation_request_by_doctor: responseData[index]
                ['start_consultation_request_by_doctor'],
            userId:
                userProvider.user.id == responseData[index]['user_one']["_id"]
                    ? responseData[index]['user_two']["_id"]
                    : responseData[index]['user_one']["_id"],
            name: userProvider.user.id == responseData[index]['user_one']["_id"]
                ? responseData[index]['user_two']["name"]
                : responseData[index]['user_one']["name"],
            appointmentTime: "2021-09-01T12:00:00.000Z",
            image_url: userProvider.user.id ==
                    responseData[index]['user_one']["_id"]
                ? "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"
                : responseData[index]['user_one']["doctor_data"]["image_url"]);
      });
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
          title: const Text(
            "Inbox",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          actions: <Widget>[
            // Step 3: Use ValueListenableBuilder for Conditional Rendering
            ValueListenableBuilder<bool>(
              valueListenable: specialConditionFlag,
              builder: (context, value, child) {
                if (value) {
                  return Row(
                    children: [
                      Text("$_userName is calling you"),
                      IconButton(
                        icon: const Icon(Icons.video_call),
                        onPressed: () async {
                          final userProvider =
                              Provider.of<UserProvider>(context, listen: false);
                          final url = Uri.parse(
                              '$uri/telemedicine_api/set_start_consultation_request');
                          final response = await http.post(url,
                              headers: {
                                'Content-Type': 'application/json',
                                'x-auth-token': userProvider.user.token
                              },
                              body: json.encode({
                                "chat_id": _callID,
                                "start_consultation_request": false,
                              }));
                          final responseData = json.decode(response.body);
                          // Add logic to handle video calling
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  VideoCallPage(callID: _callID)));
                        },
                      ),
                    ],
                  );
                } else {
                  return const Text("");
                }
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Appointment>>(
        future: fetchData(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(), // Show a loading indicator while fetching data
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No appointments available."),
            );
          } else {
            // Data has been fetched successfully, render the ListView
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final appointment = snapshot.data![index];
                // print(snapshot.data![index].user_one);
                return AppointmentCard(appointment: appointment);
              },
            );
          }
        },
      ),
    );
  }
}

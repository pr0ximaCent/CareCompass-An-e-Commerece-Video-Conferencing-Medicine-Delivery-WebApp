import 'dart:convert';

import 'package:carecompass/constants/global_variables.dart';
import 'package:carecompass/features/telemedicine/screens/inbox.dart';
import 'package:carecompass/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final String name;
  final String picture;
  final String degree;
  final String speciality;
  final String designation;
  final String workplace;
  final String id;

  const DoctorDetailsScreen(
      {Key? key,
      required this.id,
      required this.name,
      required this.picture,
      required this.degree,
      required this.speciality,
      required this.designation,
      required this.workplace})
      : super(key: key);
  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  Future<void> createAppointment(BuildContext context, String doctorId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String apiUrl = "$uri/doctor_api/create_appointment";
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token
      },
      body: jsonEncode(<String, String>{
        'doctor_id': doctorId,
      }),
    );

    if (response.statusCode == 200) {
      // Handle successful response
      print("Appointment created successfully");
      var responseData = json.decode(response.body);
      // Do something with responseData
    } else {

      // Handle error response
      print("Failed to create appointment: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  widget.picture,
                ), // Replace with actual image
              ),
            ),
            const SizedBox(height: 20),
            Text(widget.name,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(widget.degree,
                style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 10),

            Align(
                alignment: Alignment.center,
                child: Text(widget.speciality,
                    style: const TextStyle(fontSize: 20))),
            const SizedBox(height: 20),

            Text(widget.designation,
                style: const TextStyle(fontSize: 18, color: Colors.grey)),
            //  SizedBox(height: 10),

            Align(
              alignment: Alignment.topCenter,
              child: Text(widget.workplace,
                  style: const TextStyle(fontSize: 18, color: Colors.grey)),
            ),

            const SizedBox(height: 100),
            ElevatedButton(
              onPressed: () async {
                print('Book Appointment');
                await createAppointment(context, widget.id);
                Navigator.pushNamed(
                  context,
                  InboxScreen.routeName,
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: const Text('Book Appointment',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

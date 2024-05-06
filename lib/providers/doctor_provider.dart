import 'dart:convert';

import 'package:carecompass/constants/global_variables.dart';
import 'package:carecompass/models/doctor.dart';
import 'package:carecompass/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class DoctorSearchProvider with ChangeNotifier {
  //provider user

  static const List<Map<String, String>> doctorCategories = [
    {
      'title': 'General Practitioner',
      'imageIcon': 'assets/images/general_practitioner.png'
    },
    {'title': 'Pediatrician', 'imageIcon': 'assets/images/pediatrician.png'},
    {'title': 'Cardiologist', 'imageIcon': 'assets/images/cardiologist.png'},
    {'title': 'Neurologist', 'imageIcon': 'assets/images/neurologist.png'},
    {'title': 'Orthopedist', 'imageIcon': 'assets/images/orthopedist.png'},
    {'title': 'Dermatologist', 'imageIcon': 'assets/images/dermatologist.png'},
    {'title': 'Psychiatrist', 'imageIcon': 'assets/images/psychiatrist.png'},
    {'title': 'Oncologist', 'imageIcon': 'assets/images/oncologist.png'},
    {
      'title': 'Gastroenterologist',
      'imageIcon': 'assets/images/gastroenterologist.png'
    },
    {
      'title': 'Endocrinologist',
      'imageIcon': 'assets/images/endocrinologist.png'
    },
    {
      'title': 'Urologist',
      'imageIcon': 'assets/images/general_practitioner.png'
    },
    {
      'title': 'Gynecologist',
      'imageIcon': 'assets/images/general_practitioner.png'
    },
    {
      'title': 'Ophthalmologist',
      'imageIcon': 'assets/images/general_practitioner.png'
    },
    {
      'title': 'ENT Specialist',
      'imageIcon': 'assets/images/general_practitioner.png'
    },
    {'title': 'Dentist', 'imageIcon': 'assets/images/general_practitioner.png'},
    {
      'title': 'Physiotherapist',
      'imageIcon': 'assets/images/general_practitioner.png'
    },
    {
      'title': 'Homeopathic Doctor',
      'imageIcon': 'assets/images/general_practitioner.png'
    },
    {
      'title': 'Sexologist',
      'imageIcon': 'assets/images/general_practitioner.png'
    },
    {
      'title': 'Nutritionist',
      'imageIcon': 'assets/images/general_practitioner.png'
    },
    {
      'title': 'Speech Therapist',
      'imageIcon': 'assets/images/general_practitioner.png'
    },
    {
      'title': 'Acupuncture Specialist',
      'imageIcon': 'assets/images/general_practitioner.png'
    },
    {
      'title': 'Autism & Neuro-Developmental Disorders Specialist',
      'imageIcon': 'assets/images/general_practitioner.png'
    },
    {
      'title':
          'Pain, Paralysis, Disability & Sports Injury Physiotherapy Specialist',
      'imageIcon': 'assets/images/general_practitioner.png'
    },
    {
      'title': 'Pain, Paralysis, Disability & Women’s Health Specialist',
      'imageIcon': 'assets/images/general_practitioner.png'
    },
    {
      'title':
          'Pain, Paralysis, Disability, Urological Health & Sports Injury Physiotherapy Specialist',
      'imageIcon': 'assets/images/general_practitioner.png'
    },
    {
      'title':
          'Pain, Paralysis, Disability & Urological Health Physiotherapy Specialist',
      'imageIcon': 'assets/images/general_practitioner.png'
    },
    {
      'title':
          'Pain, Paralysis, Disability & Sports Injury Physiotherapy Specialist',
      'imageIcon': 'assets/images/general_practitioner.png'
    },
    {
      'title': 'Pain, Paralysis, Disability & Women’s Health Specialist',
      'imageIcon': 'assets/images/general_practitioner.png'
    },
    {
      'title': 'Paralysis',
      'imageIcon': 'assets/images/general_practitioner.png'
    }
  ];
  List<Doctor> _foundItems = [];

  List<Doctor> get foundItems => _foundItems;
  Future<List<Doctor>> getAllDoctors(String query, String token) async {
    final url = Uri.parse('$uri/doctor_api/search_doctor_by_category');
    final response = await http.post(
      url,
      body: json.encode({'category': query}), // Encode the body as JSON
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      },
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      List<Doctor> doctors = [];

      for (var doctor in responseData) {
        doctors.add(Doctor.fromJson(doctor));
      }
      _foundItems = doctors;
      // notifyListeners();
      return doctors;
    } else {
      // print(response);
      // Handle API error here, e.g., throw an exception or return an empty list
      throw Exception('Failed to load doctors: ${response.statusCode}');
    }
  }

  Future<void> searchItems(String query) async {
    print("on search: " + query);
    if (query.isEmpty) {
      // Reset _foundItems to an empty list when the query is empty
      // _foundItems = [];
    } else {
      // Perform a name-based search
      final lowercaseQuery = query.toLowerCase();
      _foundItems = _foundItems
          .where((doctor) => doctor.name.toLowerCase().contains(lowercaseQuery))
          .toList();
    }
    notifyListeners();
  }

  DoctorSearchProvider() {
    searchItems('');
  }
}

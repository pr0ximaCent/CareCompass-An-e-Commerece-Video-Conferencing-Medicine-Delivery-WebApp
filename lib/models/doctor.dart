class Doctor {
  final String userId;
  final String name; // Added the name parameter
  final bool isOnline;
  final bool onConsultation;
  final String? withPatient;
  final List<Appointment> waitingQueue;
  final String image_url;
  final String speciality;
  final String degree;
  final String designation;
  final String workplace;
  final double fees;
  final double rating;

  Doctor({
    required this.userId,
    required this.name, // Added the name parameter
    required this.isOnline,
    required this.onConsultation,
    this.withPatient,
    required this.waitingQueue,
    required this.image_url,
    required this.speciality,
    required this.degree,
    required this.designation,
    required this.workplace,
    required this.fees,
    required this.rating,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      userId: json['userId']['_id'],
      name: json['userId']['name'], // Added the name parameter
      isOnline: json['isOnline'],
      onConsultation: json['onConsultation'],
      withPatient: json['withPatient'],
      waitingQueue: List<Appointment>.from(
          json['waitingQueue'].map((x) => Appointment.fromJson(x))),
      image_url: json['image_url'],
      speciality: json['speciality'],
      degree: json['degree'],
      designation: json['designation'],
      workplace: json['workplace'],
      fees: json['fees'].toDouble(),
      rating: json['rating'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name, // Added the name parameter
      'isOnline': isOnline,
      'onConsultation': onConsultation,
      'withPatient': withPatient,
      'waitingQueue': List<dynamic>.from(waitingQueue.map((x) => x.toJson())),
      'image_url': image_url,
      'speciality': speciality,
      'degree': degree,
      'designation': designation,
      'workplace': workplace,
      'fees': fees,
      'rating': rating,
    };
  }
}

class Appointment {
  final String userId;
  final DateTime appointmentTime;

  Appointment({
    required this.userId,
    required this.appointmentTime,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      userId: json['userId'],
      appointmentTime: DateTime.parse(json['appointmentTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'appointmentTime': appointmentTime.toIso8601String(),
    };
  }
}

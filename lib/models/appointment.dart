class Appointment {
  final String id;
  final String userId;
  final String name;
  final String appointmentTime;
  final int serialNumber;
  final bool start_consultation_request_by_doctor;
  final String image_url;

  Appointment({
    required this.id,
    required this.userId,
    required this.name,
    required this.appointmentTime,
    required this.serialNumber,
    required this.start_consultation_request_by_doctor,
    required this.image_url,
  });
}

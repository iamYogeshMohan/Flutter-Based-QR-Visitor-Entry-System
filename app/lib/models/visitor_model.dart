class VisitorModel {
  final String id;
  final String name;
  final String phone;
  final String purpose;
  final String date;
  final String time;
  final String status;
  final String? checkIn;
  final String? checkOut;
  final String? qrCode;
  final String? registeredByName;

  VisitorModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.purpose,
    required this.date,
    required this.time,
    required this.status,
    this.checkIn,
    this.checkOut,
    this.qrCode,
    this.registeredByName,
  });

  factory VisitorModel.fromJson(Map<String, dynamic> json) {
    return VisitorModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      purpose: json['purpose'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? 'Pending',
      checkIn: json['checkIn'],
      checkOut: json['checkOut'],
      qrCode: json['qrCode'],
      registeredByName: json['registeredBy'] != null ? json['registeredBy']['name'] : 'Unknown',
    );
  }
}

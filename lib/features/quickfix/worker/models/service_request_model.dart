class ServiceRequestModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final String service;
  final String problem;
  final String location;
  final String date;
  final String time;
  final String status;

  ServiceRequestModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.service,
    required this.problem,
    required this.location,
    required this.date,
    required this.time,
    required this.status,
  });
}
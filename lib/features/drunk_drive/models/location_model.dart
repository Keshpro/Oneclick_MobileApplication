class LocationModel {
  final String name;
  final String? address;
  final double? latitude;
  final double? longitude;

  const LocationModel({
    required this.name,
    this.address,
    this.latitude,
    this.longitude,
  });
}
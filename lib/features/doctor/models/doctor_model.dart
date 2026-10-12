class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final String specialtyLabel;
  final String hospital;
  final double rating;
  final int reviews;
  final int experience;
  final int fee;
  final bool available;
  final String nextSlot;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.specialtyLabel,
    required this.hospital,
    required this.rating,
    required this.reviews,
    required this.experience,
    required this.fee,
    required this.available,
    required this.nextSlot,
  });
}
class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.service,
    required this.distance,
    required this.rating,
    required this.about,
    required this.avatarUrl,
  });

  final String id;
  final String name;
  final String specialty;
  final String service;
  final String distance;
  final double rating;
  final String about;
  final String avatarUrl;

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
    id: json['id'] as String,
    name: json['name'] as String,
    specialty: json['specialty'] as String,
    service: json['service'] as String,
    distance: json['distance'] as String,
    rating: (json['rating'] as num).toDouble(),
    about: json['about'] as String,
    avatarUrl: json['avatarUrl'] as String,
  );
}

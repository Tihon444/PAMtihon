import '../models/doctor.dart';

enum DoctorsStatus { loading, success, empty, error }

enum SortOption { name, rating, distance }

class DoctorsState {
  const DoctorsState({
    this.status = DoctorsStatus.loading,
    this.doctors = const [],
    this.query = '',
    this.service,
    this.sort = SortOption.rating,
    this.favorites = const {},
    this.message,
  });
  final DoctorsStatus status;
  final List<Doctor> doctors;
  final String query;
  final String? service;
  final SortOption sort;
  final Set<String> favorites;
  final String? message;

  List<Doctor> get visibleDoctors {
    final result = doctors.where((doctor) {
      final matchesQuery = '${doctor.name} ${doctor.specialty}'
          .toLowerCase()
          .contains(query.toLowerCase());
      return matchesQuery && (service == null || doctor.service == service);
    }).toList();
    result.sort(
      (a, b) => switch (sort) {
        SortOption.name => a.name.compareTo(b.name),
        SortOption.rating => b.rating.compareTo(a.rating),
        SortOption.distance => a.distance.compareTo(b.distance),
      },
    );
    return result;
  }

  DoctorsState copyWith({
    DoctorsStatus? status,
    List<Doctor>? doctors,
    String? query,
    String? service,
    bool clearService = false,
    SortOption? sort,
    Set<String>? favorites,
    String? message,
  }) => DoctorsState(
    status: status ?? this.status,
    doctors: doctors ?? this.doctors,
    query: query ?? this.query,
    service: clearService ? null : service ?? this.service,
    sort: sort ?? this.sort,
    favorites: favorites ?? this.favorites,
    message: message,
  );
}

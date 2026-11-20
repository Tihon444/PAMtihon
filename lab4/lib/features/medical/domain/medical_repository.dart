import 'entities.dart';

abstract interface class MedicalRepository {
  Future<MedicalFeed> getFeed();
  Future<AppointmentDetails> getDetails({String? doctorId});
  Future<String> bookAppointment(BookingRequest request);
}

class MedicalFailure implements Exception {
  const MedicalFailure(this.message);
  final String message;
}

class GetMedicalFeed {
  const GetMedicalFeed(this.repository);
  final MedicalRepository repository;
  Future<MedicalFeed> call() => repository.getFeed();
}

class GetAppointmentDetails {
  const GetAppointmentDetails(this.repository);
  final MedicalRepository repository;
  Future<AppointmentDetails> call({String? doctorId}) =>
      repository.getDetails(doctorId: doctorId);
}

class BookAppointment {
  const BookAppointment(this.repository);
  final MedicalRepository repository;
  Future<String> call(BookingRequest request) =>
      repository.bookAppointment(request);
}

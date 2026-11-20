import '../domain/entities.dart';

typedef Json = Map<String, dynamic>;

class BookingRequestDto {
  const BookingRequestDto(this.request);
  final BookingRequest request;
  Json toJson() => {
    'doctorId': request.doctorId,
    'dateId': request.dateId,
    'hourId': request.hourId,
  };
}

Doctor parseDoctor(Json j) => Doctor(
  j['id'] as String? ?? '',
  j['name'] as String,
  (j['specialty'] ?? j['clinic']) as String,
  j['avatarUrl'] as String,
  j['distance'] as String? ?? '',
  j['isFavorite'] as bool? ?? false,
  rating: (j['rating'] as num?)?.toDouble(),
  about: j['about'] as String?,
  serviceOverride: j['service'] as String?,
);

// DTOs handle the wire format; domain entities have no dependency on JSON.
class FeedDto {
  FeedDto.fromJson(this.json);
  final Json json;
  Json toJson() => json;
  MedicalFeed toEntity() {
    final u = json['user'] as Json;
    final a = json['appointment'] as Json;
    return MedicalFeed(
      u['greeting'] as String,
      u['subtitle'] as String,
      u['avatarUrl'] as String,
      (json['notifications'] as Json)['hasUnread'] as bool,
      (json['search'] as Json)['hint'] as String,
      Appointment(
        a['title'] as String,
        a['date'] as String,
        a['time'] as String,
        parseDoctor(a['doctor'] as Json),
      ),
      List.unmodifiable(
        (json['healthServices'] as List).map((v) {
          final j = v as Json;
          return HealthService(
            j['id'] as String,
            j['name'] as String,
            j['iconUrl'] as String,
          );
        }),
      ),
      List.unmodifiable(
        (json['nearbyDoctors'] as List).map((v) => parseDoctor(v as Json)),
      ),
    );
  }
}

class DetailsDto {
  DetailsDto.fromJson(this.json);
  final Json json;
  Json toJson() => json;
  AppointmentDetails toEntity() {
    final p = json['payment'] as Json;
    final d = json['details'] as Json;
    final h = json['workingHours'] as Json;
    final dates = json['date'] as Json;
    final b = (json['actions'] as Json)['bookAppointment'] as Json;
    return AppointmentDetails(
      json['title'] as String,
      parseDoctor(json['doctor'] as Json),
      p['label'] as String,
      (p['amount'] as num).toDouble(),
      p['currency'] as String,
      p['formatted'] as String,
      d['title'] as String,
      d['description'] as String,
      h['title'] as String,
      _slots(h),
      dates['title'] as String,
      _slots(dates),
      b['label'] as String,
      b['enabled'] as bool,
    );
  }

  List<Slot> _slots(Json section) => List.unmodifiable(
    (section['slots'] as List).map((v) {
      final j = v as Json;
      return Slot(
        j['id'] as String,
        j['label'] as String,
        j['selected'] as bool,
      );
    }),
  );
}

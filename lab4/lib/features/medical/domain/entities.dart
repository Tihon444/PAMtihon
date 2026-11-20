class BookingRequest {
  const BookingRequest({
    required this.doctorId,
    required this.dateId,
    required this.hourId,
  });
  final String doctorId, dateId, hourId;
}

class Doctor {
  const Doctor(
    this.id,
    this.name,
    this.specialty,
    this.avatarUrl,
    this.distance,
    this.isFavorite, {
    this.rating,
    this.about,
    this.serviceOverride,
  });
  final String id, name, specialty, avatarUrl, distance;
  final bool isFavorite;
  final double? rating;
  final String? about;
  final String? serviceOverride;

  // Normalize the API specialty to the category names used by lab3.
  String get service =>
      serviceOverride ??
      switch (specialty.toLowerCase()) {
        'dental specialist' || 'dentist' => 'Tooth',
        'ophthalmologist' => 'Eye',
        'pulmonologist' => 'Lungs',
        'general practitioner' => 'General',
        _ => specialty,
      };
}

class HealthService {
  const HealthService(this.id, this.name, this.iconUrl);
  final String id, name, iconUrl;
}

class Appointment {
  const Appointment(this.title, this.date, this.time, this.doctor);
  final String title, date, time;
  final Doctor doctor;
}

class MedicalFeed {
  const MedicalFeed(
    this.greeting,
    this.subtitle,
    this.avatarUrl,
    this.hasUnread,
    this.searchHint,
    this.appointment,
    this.services,
    this.doctors,
  );
  final String greeting, subtitle, avatarUrl, searchHint;
  final bool hasUnread;
  final Appointment appointment;
  final List<HealthService> services;
  final List<Doctor> doctors;
}

class Slot {
  const Slot(this.id, this.label, this.selected);
  final String id, label;
  final bool selected;
}

class AppointmentDetails {
  const AppointmentDetails(
    this.title,
    this.doctor,
    this.paymentLabel,
    this.amount,
    this.currency,
    this.formattedPayment,
    this.descriptionTitle,
    this.description,
    this.hoursTitle,
    this.hours,
    this.dateTitle,
    this.dates,
    this.bookLabel,
    this.bookEnabled,
  );
  final String title,
      paymentLabel,
      currency,
      formattedPayment,
      descriptionTitle,
      description,
      hoursTitle,
      dateTitle,
      bookLabel;
  final double amount;
  final Doctor doctor;
  final List<Slot> hours, dates;
  final bool bookEnabled;
}

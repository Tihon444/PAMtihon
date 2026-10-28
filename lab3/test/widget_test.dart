import 'package:flutter_test/flutter_test.dart';
import 'package:lab3/cubit/doctors_state.dart';
import 'package:lab3/models/doctor.dart';

void main() {
  test('filtrarea caută după nume', () {
    const doctor = Doctor(
      id: '1',
      name: 'Ana Popescu',
      specialty: 'Dentist',
      service: 'Tooth',
      distance: '1 km',
      rating: 4.8,
      about: 'Test',
      avatarUrl: '',
    );
    const state = DoctorsState(
      status: DoctorsStatus.success,
      doctors: [doctor],
      query: 'ana',
    );
    expect(state.visibleDoctors, hasLength(1));
  });
}

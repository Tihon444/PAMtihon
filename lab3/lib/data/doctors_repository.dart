import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/doctor.dart';

class DoctorsRepository {
  Future<List<Doctor>> loadDoctors() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final source = await rootBundle.loadString('assets/data/doctors.json');
    final decoded = jsonDecode(source) as Map<String, dynamic>;
    return (decoded['doctors'] as List<dynamic>)
        .map((item) => Doctor.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

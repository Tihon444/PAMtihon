import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/medical/presentation/cubit/doctors_cubit.dart';

import 'features/medical/data/medical_api.dart';
import 'features/medical/domain/medical_repository.dart';
import 'features/medical/presentation/home_screen.dart';

void main() => runApp(const HealthCareApp());

class HealthCareApp extends StatefulWidget {
  const HealthCareApp({super.key, this.repository});
  final MedicalRepository? repository;
  @override
  State<HealthCareApp> createState() => _HealthCareAppState();
}

class _HealthCareAppState extends State<HealthCareApp> {
  late final http.Client _client = http.Client();
  late final MedicalRepository _repository =
      widget.repository ?? ApiMedicalRepository(MedicalApi(_client));
  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => DoctorsCubit(_repository)..load(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthCare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2864e5)),
        scaffoldBackgroundColor: const Color(0xfff7f9fd),
        useMaterial3: true,
      ),
      home: HomeScreen(repository: _repository),
    ),
  );
}

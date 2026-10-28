import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/doctors_cubit.dart';
import 'data/doctors_repository.dart';
import 'screens/home_screen.dart';

void main() => runApp(const HealthCareApp());

class HealthCareApp extends StatelessWidget {
  const HealthCareApp({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => DoctorsCubit(DoctorsRepository())..load(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthCare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2864e5)),
        scaffoldBackgroundColor: const Color(0xfff7f9fd),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    ),
  );
}

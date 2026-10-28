import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/doctors_cubit.dart';
import '../models/doctor.dart';

class DoctorDetailsScreen extends StatelessWidget {
  const DoctorDetailsScreen({super.key, required this.doctor});
  final Doctor doctor;
  @override
  Widget build(BuildContext context) {
    final favorite = context.select(
      (DoctorsCubit cubit) => cubit.state.favorites.contains(doctor.id),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalii medic'),
        actions: [
          IconButton(
            onPressed: () =>
                context.read<DoctorsCubit>().toggleFavorite(doctor.id),
            icon: Icon(
              favorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 64,
              backgroundImage: NetworkImage(doctor.avatarUrl),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            doctor.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            doctor.specialty,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Metric(
                    icon: Icons.star_rounded,
                    label: '${doctor.rating}',
                    color: const Color(0xffffb01f),
                  ),
                  _Metric(
                    icon: Icons.location_on_outlined,
                    label: doctor.distance,
                    color: const Color(0xff2864e5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Despre medic',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            doctor.about,
            style: const TextStyle(height: 1.55, fontSize: 15),
          ),
          const SizedBox(height: 30),
          FilledButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cererea de programare a fost trimisă.'),
              ),
            ),
            icon: const Icon(Icons.calendar_month),
            label: const Text('Programează o consultație'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: color),
      const SizedBox(height: 5),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/doctors_cubit.dart';
import '../cubit/doctors_state.dart';
import '../widgets/doctor_card.dart';
import 'doctor_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const services = [
    ('Tooth', Icons.health_and_safety_outlined),
    ('Eye', Icons.visibility_outlined),
    ('Lungs', Icons.air),
    ('General', Icons.medical_services_outlined),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: BlocBuilder<DoctorsCubit, DoctorsState>(
        builder: (context, state) {
          if (state.status == DoctorsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == DoctorsStatus.error) {
            return _Message(
              icon: Icons.error_outline,
              text: state.message!,
              action: () => context.read<DoctorsCubit>().load(),
            );
          }
          if (state.status == DoctorsStatus.empty) {
            return const _Message(
              icon: Icons.folder_off_outlined,
              text: 'Nu există medici disponibili.',
            );
          }
          final doctors = state.visibleDoctors;
          return RefreshIndicator(
            onRefresh: () => context.read<DoctorsCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Row(
                  children: [
                    const CircleAvatar(radius: 25, child: Icon(Icons.person)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bună, Jonathan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Ai grijă de sănătatea ta'),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_none),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const Text(
                  'Găsește medicul potrivit',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                TextField(
                  onChanged: context.read<DoctorsCubit>().search,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Caută după nume sau specialitate',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Servicii medicale',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: services.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final value = index == 0 ? null : services[index - 1].$1;
                      final icon = index == 0
                          ? Icons.apps
                          : services[index - 1].$2;
                      final label = value ?? 'Toate';
                      final selected = state.service == value;
                      return ChoiceChip(
                        avatar: Icon(
                          icon,
                          color: selected
                              ? Colors.white
                              : const Color(0xff2864e5),
                        ),
                        label: Text(label),
                        selected: selected,
                        onSelected: (_) =>
                            context.read<DoctorsCubit>().filter(value),
                        selectedColor: const Color(0xff2864e5),
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 16,
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${doctors.length} medici disponibili',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<SortOption>(
                      onSelected: context.read<DoctorsCubit>().sort,
                      icon: const Icon(Icons.sort),
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: SortOption.rating,
                          child: Text('Rating'),
                        ),
                        PopupMenuItem(
                          value: SortOption.name,
                          child: Text('Nume'),
                        ),
                        PopupMenuItem(
                          value: SortOption.distance,
                          child: Text('Distanță'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (doctors.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: _Message(
                      icon: Icons.search_off,
                      text: 'Nu am găsit rezultate.',
                    ),
                  )
                else
                  ...doctors.map(
                    (doctor) => DoctorCard(
                      doctor: doctor,
                      favorite: state.favorites.contains(doctor.id),
                      onFavorite: () => context
                          .read<DoctorsCubit>()
                          .toggleFavorite(doctor.id),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DoctorDetailsScreen(doctor: doctor),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.action});
  final IconData icon;
  final String text;
  final VoidCallback? action;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 54, color: Colors.grey),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center),
          if (action != null)
            TextButton(onPressed: action, child: const Text('Reîncearcă')),
        ],
      ),
    ),
  );
}

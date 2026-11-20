import 'package:flutter/material.dart';

import '../domain/entities.dart';
import '../domain/medical_repository.dart';
import 'load_controller.dart';
import 'widgets.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.repository, this.doctorId});
  final MedicalRepository repository;
  final String? doctorId;
  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late final controller = LoadController(
    () =>
        GetAppointmentDetails(widget.repository)
            .call(doctorId: widget.doctorId),
  )..load();
  String? hour, date;
  bool saving = false;
  String? bookedId;

  Future<void> book(String doctorId, String dateId, String hourId) async {
    setState(() => saving = true);
    try {
      final id = await BookAppointment(widget.repository)(
        BookingRequest(doctorId: doctorId, dateId: dateId, hourId: hourId),
      );
      if (!mounted) return;
      setState(() => bookedId = id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Programarea a fost salvată pe server.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is MedicalFailure
                ? error.message
                : 'Programarea nu a putut fi salvată.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String? selected(List<Slot> slots, String? selection) {
    if (slots.any((s) => s.id == selection)) return selection;
    for (final s in slots) {
      if (s.selected) return s.id;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: Text(controller.data?.title ?? 'Programare')),
      body: _body(),
    ),
  );
  Widget _body() {
    if (controller.status == LoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.status == LoadStatus.error) {
      return StatusMessage(message: controller.error!, retry: controller.load);
    }
    final d = controller.data!;
    final selectedHour = selected(d.hours, hour);
    final selectedDate = selected(d.dates, date);
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Center(child: RemoteAvatar(url: d.doctor.avatarUrl, size: 128)),
          const SizedBox(height: 18),
          Text(
            d.doctor.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(d.doctor.specialty, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(child: Text(d.paymentLabel)),
                  Text(
                    d.formattedPayment,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SectionTitle(d.descriptionTitle),
          Text(d.description, style: const TextStyle(height: 1.55)),
          SectionTitle(d.hoursTitle),
          _slots(d.hours, selectedHour, (id) => setState(() => hour = id)),
          SectionTitle(d.dateTitle),
          _slots(d.dates, selectedDate, (id) => setState(() => date = id)),
          const SizedBox(height: 30),
          FilledButton.icon(
            onPressed:
                !saving &&
                    bookedId == null &&
                    d.bookEnabled &&
                    selectedHour != null &&
                    selectedDate != null
                ? () => book(
                    widget.doctorId ?? d.doctor.id,
                    selectedDate,
                    selectedHour,
                  )
                : null,
            icon: saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.calendar_month),
            label: Text(
              bookedId != null
                  ? 'Programare confirmată'
                  : saving
                  ? 'Se salvează…'
                  : d.bookLabel,
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slots(
    List<Slot> slots,
    String? selection,
    ValueChanged<String> onSelected,
  ) => slots.isEmpty
      ? const Text('Nu există intervale disponibile.')
      : Wrap(
          spacing: 12,
          runSpacing: 8,
          children: slots
              .map(
                (s) => ChoiceChip(
                  label: Text(s.label),
                  selected: s.id == selection,
                  onSelected: (_) => onSelected(s.id),
                ),
              )
              .toList(),
        );
}

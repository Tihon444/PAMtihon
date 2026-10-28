import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/doctors_repository.dart';
import 'doctors_state.dart';

class DoctorsCubit extends Cubit<DoctorsState> {
  DoctorsCubit(this._repository) : super(const DoctorsState());
  final DoctorsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: DoctorsStatus.loading));
    try {
      final doctors = await _repository.loadDoctors();
      emit(
        state.copyWith(
          status: doctors.isEmpty ? DoctorsStatus.empty : DoctorsStatus.success,
          doctors: doctors,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: DoctorsStatus.error,
          message: 'Datele nu au putut fi încărcate.',
        ),
      );
    }
  }

  void search(String query) => emit(state.copyWith(query: query));
  void filter(String? service) =>
      emit(state.copyWith(service: service, clearService: service == null));
  void sort(SortOption sort) => emit(state.copyWith(sort: sort));
  void toggleFavorite(String id) {
    final values = Set<String>.from(state.favorites);
    values.contains(id) ? values.remove(id) : values.add(id);
    emit(state.copyWith(favorites: values));
  }
}

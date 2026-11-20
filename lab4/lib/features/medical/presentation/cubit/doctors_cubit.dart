import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/medical_repository.dart';
import 'doctors_state.dart';

class DoctorsCubit extends Cubit<DoctorsState> {
  DoctorsCubit(MedicalRepository repository)
    : _getFeed = GetMedicalFeed(repository),
      super(const DoctorsState());
  final GetMedicalFeed _getFeed;
  int _request = 0;
  bool _initializedFavorites = false;
  Future<void> load() async {
    final request = ++_request;
    emit(state.copyWith(status: DoctorsStatus.loading));
    try {
      final feed = await _getFeed();
      if (isClosed || request != _request) return;
      final favorites = _initializedFavorites
          ? state.favorites
          : feed.doctors.where((d) => d.isFavorite).map((d) => d.id).toSet();
      _initializedFavorites = true;
      emit(
        state.copyWith(
          status: feed.doctors.isEmpty
              ? DoctorsStatus.empty
              : DoctorsStatus.success,
          doctors: feed.doctors,
          feed: feed,
          favorites: favorites,
        ),
      );
    } catch (e) {
      if (isClosed || request != _request) return;
      emit(
        state.copyWith(
          status: DoctorsStatus.error,
          message: e is MedicalFailure
              ? e.message
              : 'Datele nu au putut fi încărcate.',
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

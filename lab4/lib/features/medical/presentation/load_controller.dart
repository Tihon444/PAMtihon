import 'package:flutter/foundation.dart';

import '../domain/medical_repository.dart';

enum LoadStatus { loading, success, error }

class LoadController<T> extends ChangeNotifier {
  LoadController(this._load);
  final Future<T> Function() _load;
  LoadStatus status = LoadStatus.loading;
  T? data;
  String? error;
  bool _disposed = false;
  int _request = 0;
  Future<void> load() async {
    final request = ++_request;
    status = LoadStatus.loading;
    error = null;
    notifyListeners();
    try {
      final result = await _load();
      if (_disposed || request != _request) return;
      data = result;
      status = LoadStatus.success;
    } catch (e, stack) {
      if (kDebugMode && e is! MedicalFailure) {
        debugPrint('Încărcarea datelor a eșuat: $e\n$stack');
      }
      if (_disposed || request != _request) return;
      error = e is MedicalFailure
          ? e.message
          : 'A apărut o eroare neașteptată. Reîncearcă.';
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

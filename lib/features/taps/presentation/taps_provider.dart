import 'package:flutter/foundation.dart';
import '../data/taps_repository.dart';
import '../domain/tap_model.dart';

class TapsProvider extends ChangeNotifier {
  final TapsRepository _tapsRepository;

  TapsProvider({required TapsRepository tapsRepository})
      : _tapsRepository = tapsRepository;

  List<TapModel> _taps = [];
  bool _isLoading = false;
  String? _error;

  List<TapModel> get taps => _taps;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTaps() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _taps = await _tapsRepository.getTaps();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

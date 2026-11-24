import 'package:flutter/foundation.dart';
import '../data/admin_repository.dart';
import '../../taps/domain/tap_model.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository _adminRepository;

  AdminProvider({required AdminRepository adminRepository})
      : _adminRepository = adminRepository;

  int _studentCount = 0;
  List<TapModel> _taps = [];
  bool _isLoading = false;
  String? _error;

  int get studentCount => _studentCount;
  List<TapModel> get taps => _taps;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get lowWaterTapsCount =>
      _taps.where((tap) => tap.tankLevel < 20).length;

  Future<void> loadOverview() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _adminRepository.getStudentCount(),
        _adminRepository.getTaps(),
      ]);
      _studentCount = results[0] as int;
      _taps = results[1] as List<TapModel>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMarketplaceItem(String itemId) async {
    await _adminRepository.deleteMarketplaceItem(itemId);
  }
}

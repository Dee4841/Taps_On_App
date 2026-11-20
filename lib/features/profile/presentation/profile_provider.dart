import 'package:flutter/foundation.dart';
import '../domain/student_profile.dart';
import '../data/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;

  StudentProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileProvider(this._repository);

  StudentProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getProfile(userId);
    _isLoading = false;

    if (result.isSuccess) {
      _profile = result.dataOrNull;
    } else {
      _errorMessage = result.failureOrNull?.message;
    }
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String userId,
    required String name,
    required String institution,
    required String studentNumber,
    String? yearOfStudy,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.updateProfile(
      userId: userId,
      name: name,
      institution: institution,
      studentNumber: studentNumber,
      yearOfStudy: yearOfStudy,
    );
    _isLoading = false;

    if (result.isSuccess) {
      _profile = _profile?.copyWith(
        name: name,
        institution: institution,
        studentNumber: studentNumber,
        yearOfStudy: yearOfStudy,
      );
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.failureOrNull?.message ?? 'Update failed';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount(String userId) async {
    final result = await _repository.deleteAccount(userId);
    if (result.isSuccess) {
      _profile = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage =
          result.failureOrNull?.message ?? 'Account deletion failed';
      notifyListeners();
      return false;
    }
  }
}

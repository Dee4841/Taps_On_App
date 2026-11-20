import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/app_user.dart';
import '../data/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  StreamSubscription<AuthState>? _authSubscription;

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._repository) {
    _init();
  }

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _init() {
    final sbUser = _repository.currentSupabaseUser;
    if (sbUser != null) {
      _currentUser = AppUser(
        id: sbUser.id,
        email: sbUser.email ?? '',
      );
      _loadRole(sbUser.id);
    }

    _authSubscription = _repository.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session == null) {
        _currentUser = null;
        notifyListeners();
      } else {
        if (_currentUser?.id != session.user.id) {
          _currentUser = AppUser(
            id: session.user.id,
            email: session.user.email ?? '',
          );
          _loadRole(session.user.id);
        }
      }
    });
  }

  Future<void> _loadRole(String userId) async {
    final role = await _repository.fetchUserRole(userId);
    if (_currentUser?.id == userId) {
      _currentUser = _currentUser!.copyWith(role: role);
      notifyListeners();
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.signIn(email: email, password: password);
    _isLoading = false;

    if (result.isSuccess) {
      _currentUser = result.dataOrNull;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.failureOrNull?.message ?? 'Sign in failed';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpStudent({
    required String email,
    required String password,
    required String name,
    required String surname,
    required DateTime dob,
    required String studentNumber,
    required String institution,
    required String yearOfStudy,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.signUpStudent(
      email: email,
      password: password,
      name: name,
      surname: surname,
      dob: dob,
      studentNumber: studentNumber,
      institution: institution,
      yearOfStudy: yearOfStudy,
    );
    _isLoading = false;

    if (result.isSuccess) {
      _currentUser = result.dataOrNull;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.failureOrNull?.message ?? 'Sign up failed';
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.resetPassword(email);
    _isLoading = false;

    if (result.isSuccess) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.failureOrNull?.message ?? 'Reset password failed';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.updatePassword(newPassword);
    _isLoading = false;

    if (result.isSuccess) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.failureOrNull?.message ?? 'Update password failed';
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _currentUser = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

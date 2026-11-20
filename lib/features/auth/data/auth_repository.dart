import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/error/failure.dart';
import '../domain/app_user.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  User? get currentSupabaseUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        return const Error(AuthFailure('Sign in failed: No user returned.'));
      }

      final role = await fetchUserRole(user.id);
      return Success(
        AppUser(
          id: user.id,
          email: user.email ?? email,
          role: role,
        ),
      );
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Unexpected login error: $e'));
    }
  }

  Future<Result<AppUser>> signUpStudent({
    required String email,
    required String password,
    required String name,
    required String surname,
    required DateTime dob,
    required String studentNumber,
    required String institution,
    required String yearOfStudy,
  }) async {
    try {
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'surname': surname,
          'dob': dob.toIso8601String(),
          'student_number': studentNumber,
          'institution': institution,
          'year_of_study': yearOfStudy,
        },
      );

      final user = authResponse.user;
      if (user == null) {
        return const Error(AuthFailure('Failed to create account.'));
      }

      try {
        await _client.from('students').upsert({
          'id': user.id,
          'name': name,
          'surname': surname,
          'dob': dob.toIso8601String(),
          'student_number': studentNumber,
          'institution': institution,
          'year_of_study': yearOfStudy,
          'role': 'student',
        });
      } catch (_) {
        // Trigger or server may already handle this
      }

      return Success(
        AppUser(
          id: user.id,
          email: user.email ?? email,
          role: 'student',
        ),
      );
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Unexpected sign up error: $e'));
    }
  }

  Future<String> fetchUserRole(String userId) async {
    try {
      final res = await _client
          .from('students')
          .select('role')
          .eq('id', userId)
          .maybeSingle()
          .timeout(const Duration(seconds: 5));

      if (res != null && res['role'] != null) {
        return res['role'] as String;
      }
    } catch (_) {
      // Default to student on network failure
    }
    return 'student';
  }

  Future<Result<void>> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo:
            'https://monvesaedughbmokesuw.supabase.co/reset-password-callback',
      );
      return const Success(null);
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Failed to send reset link: $e'));
    }
  }

  Future<Result<void>> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return const Success(null);
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Failed to update password: $e'));
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (_) {}
  }
}

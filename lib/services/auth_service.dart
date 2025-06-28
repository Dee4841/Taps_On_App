import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Sign up a user with email and password and insert profile data into `students` table.
  Future<String?> signUpStudent({
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
      );

      final user = authResponse.user;
      if (user == null) {
        return 'Failed to create user.';
      }

      await _client.from('students').insert({
        'id': user.id,
        'name': name,
        'surname': surname,
        'dob': dob.toIso8601String(),
        'student_number': studentNumber,
        'institution': institution,
        'year_of_study': yearOfStudy,
      });

      return null; // success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  /// Sign in with email and password
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  /// Sign out the user
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

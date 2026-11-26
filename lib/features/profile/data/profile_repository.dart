import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/error/failure.dart';
import '../domain/student_profile.dart';

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<Result<StudentProfile>> getProfile(String userId) async {
    try {
      final data = await _client
          .from('students')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        return const Error(UnknownFailure('Student profile not found.'));
      }
      return Success(StudentProfile.fromJson(data));
    } catch (e) {
      return Error(UnknownFailure('Error loading profile: $e'));
    }
  }

  Future<Result<void>> updateProfile({
    required String userId,
    required String name,
    required String institution,
    required String studentNumber,
    String? yearOfStudy,
  }) async {
    try {
      await _client.from('students').update({
        'name': name,
        'institution': institution,
        'student_number': studentNumber,
        'year_of_study': yearOfStudy,
      }).eq('id', userId);

      return const Success(null);
    } catch (e) {
      return Error(UnknownFailure('Failed to update profile: $e'));
    }
  }

  Future<Result<void>> deleteAccount() async {
    try {
      await _client.rpc('delete_my_account');
      try {
        await _client.auth.signOut(scope: SignOutScope.local);
      } catch (_) {}
      return const Success(null);
    } catch (e) {
      return Error(UnknownFailure('Failed to delete account: $e'));
    }
  }

}

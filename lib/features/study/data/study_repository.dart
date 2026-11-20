import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/study_session.dart';
import '../domain/journal_entry.dart';

class StudyRepository {
  final SupabaseClient _client;

  StudyRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  // Study Sessions
  Future<List<StudySession>> getSessions(String userId) async {
    final response = await _client
        .from('study_sessions')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);
    return (response as List).map((s) => StudySession.fromMap(s)).toList();
  }

  Future<void> addSession({
    required String userId,
    required String subject,
    required int duration,
    required DateTime date,
  }) async {
    await _client.from('study_sessions').insert({
      'user_id': userId,
      'subject': subject,
      'duration': duration,
      'date': date.toIso8601String().substring(0, 10),
    });
  }

  Future<void> updateSession({
    required String id,
    required String subject,
    required int duration,
    required DateTime date,
  }) async {
    await _client.from('study_sessions').update({
      'subject': subject,
      'duration': duration,
      'date': date.toIso8601String().substring(0, 10),
    }).eq('id', id);
  }

  Future<void> deleteSession(String id) async {
    await _client.from('study_sessions').delete().eq('id', id);
  }

  // Journal Entries
  Future<List<JournalEntry>> getJournalEntries(String userId) async {
    final response = await _client
        .from('time_journal')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);
    return (response as List).map((e) => JournalEntry.fromMap(e)).toList();
  }

  Future<void> addJournalEntry({
    required String userId,
    required String entryText,
    String? category,
    required DateTime date,
  }) async {
    await _client.from('time_journal').insert({
      'user_id': userId,
      'entry_text': entryText,
      'category': category,
      'date': date.toIso8601String().substring(0, 10),
    });
  }

  Future<void> deleteJournalEntry(String id) async {
    await _client.from('time_journal').delete().eq('id', id);
  }
}

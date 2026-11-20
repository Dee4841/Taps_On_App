import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/calendar_event.dart';

class EventRepository {
  final SupabaseClient _client;

  EventRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<List<CalendarEvent>> getEvents(String userId) async {
    final data = await _client
        .from('events')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: true);
    return (data as List).map((e) => CalendarEvent.fromMap(e)).toList();
  }

  Future<CalendarEvent> addEvent({
    required String userId,
    required String title,
    required DateTime date,
    required String category,
  }) async {
    final response = await _client
        .from('events')
        .insert({
          'user_id': userId,
          'title': title,
          'date': date.toIso8601String(),
          'category': category,
        })
        .select()
        .single();
    return CalendarEvent.fromMap(response);
  }

  Future<void> updateEvent({
    required String id,
    required String title,
    required String category,
  }) async {
    await _client.from('events').update({
      'title': title,
      'category': category,
    }).eq('id', id);
  }

  Future<void> deleteEvent(String id) async {
    await _client.from('events').delete().eq('id', id);
  }
}

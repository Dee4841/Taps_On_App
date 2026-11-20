import 'package:flutter/foundation.dart';
import '../data/event_repository.dart';
import '../domain/calendar_event.dart';

class EventProvider extends ChangeNotifier {
  final EventRepository _eventRepository;

  EventProvider({required EventRepository eventRepository})
      : _eventRepository = eventRepository;

  Map<DateTime, List<CalendarEvent>> _eventsByDate = {};
  bool _isLoading = false;
  String? _error;

  Map<DateTime, List<CalendarEvent>> get eventsByDate => _eventsByDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<CalendarEvent> getEventsForDay(DateTime day, [String? categoryFilter]) {
    final key = DateTime(day.year, day.month, day.day);
    final events = _eventsByDate[key] ?? [];
    if (categoryFilter == null) return events;
    return events.where((e) => e.category == categoryFilter).toList();
  }

  Future<void> loadEvents(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _eventRepository.getEvents(userId);
      final map = <DateTime, List<CalendarEvent>>{};
      for (final event in list) {
        final key = DateTime(event.date.year, event.date.month, event.date.day);
        map.putIfAbsent(key, () => []).add(event);
      }
      _eventsByDate = map;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEvent({
    required String userId,
    required String title,
    required DateTime date,
    required String category,
  }) async {
    await _eventRepository.addEvent(
      userId: userId,
      title: title,
      date: date,
      category: category,
    );
    await loadEvents(userId);
  }

  Future<void> updateEvent({
    required String userId,
    required String id,
    required String title,
    required String category,
  }) async {
    await _eventRepository.updateEvent(
      id: id,
      title: title,
      category: category,
    );
    await loadEvents(userId);
  }

  Future<void> deleteEvent({required String userId, required String id}) async {
    await _eventRepository.deleteEvent(id);
    await loadEvents(userId);
  }
}

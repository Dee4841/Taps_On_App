class CalendarEvent {
  final String id;
  final String title;
  final DateTime date;
  final String category;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.category,
  });

  factory CalendarEvent.fromMap(Map<String, dynamic> map) {
    return CalendarEvent(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      category: map['category'],
    );
  }
}

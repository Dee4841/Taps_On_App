class StudySession {
  final String id;
  final String userId;
  final String subject;
  final int duration;
  final DateTime date;

  StudySession({
    required this.id,
    required this.userId,
    required this.subject,
    required this.duration,
    required this.date,
  });

  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['id']?.toString() ?? '',
      userId: map['user_id'] ?? '',
      subject: map['subject'] ?? '',
      duration: map['duration'] is int
          ? map['duration']
          : int.tryParse(map['duration']?.toString() ?? '0') ?? 0,
      date: DateTime.parse(map['date']),
    );
  }
}

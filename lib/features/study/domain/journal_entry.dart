class JournalEntry {
  final String id;
  final String userId;
  final String entryText;
  final String? category;
  final String date;

  JournalEntry({
    required this.id,
    required this.userId,
    required this.entryText,
    this.category,
    required this.date,
  });

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id']?.toString() ?? '',
      userId: map['user_id'] ?? '',
      entryText: map['entry_text'] ?? '',
      category: map['category'],
      date: map['date'] ?? '',
    );
  }
}

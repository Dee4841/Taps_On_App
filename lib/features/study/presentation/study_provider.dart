import 'package:flutter/foundation.dart';
import '../data/study_repository.dart';
import '../domain/study_session.dart';
import '../domain/journal_entry.dart';

class StudyProvider extends ChangeNotifier {
  final StudyRepository _studyRepository;

  StudyProvider({required StudyRepository studyRepository})
      : _studyRepository = studyRepository;

  List<StudySession> _sessions = [];
  List<JournalEntry> _journalEntries = [];
  bool _isLoadingSessions = false;
  bool _isLoadingJournal = false;
  String? _error;

  List<StudySession> get sessions => _sessions;
  List<JournalEntry> get journalEntries => _journalEntries;
  bool get isLoadingSessions => _isLoadingSessions;
  bool get isLoadingJournal => _isLoadingJournal;
  String? get error => _error;

  Future<void> loadSessions(String userId) async {
    _isLoadingSessions = true;
    notifyListeners();
    try {
      _sessions = await _studyRepository.getSessions(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingSessions = false;
      notifyListeners();
    }
  }

  Future<void> addSession({
    required String userId,
    required String subject,
    required int duration,
    required DateTime date,
  }) async {
    await _studyRepository.addSession(
      userId: userId,
      subject: subject,
      duration: duration,
      date: date,
    );
    await loadSessions(userId);
  }

  Future<void> updateSession({
    required String userId,
    required String id,
    required String subject,
    required int duration,
    required DateTime date,
  }) async {
    await _studyRepository.updateSession(
      id: id,
      subject: subject,
      duration: duration,
      date: date,
    );
    await loadSessions(userId);
  }

  Future<void> deleteSession({required String userId, required String id}) async {
    await _studyRepository.deleteSession(id);
    await loadSessions(userId);
  }

  Future<void> loadJournalEntries(String userId) async {
    _isLoadingJournal = true;
    notifyListeners();
    try {
      _journalEntries = await _studyRepository.getJournalEntries(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingJournal = false;
      notifyListeners();
    }
  }

  Future<void> addJournalEntry({
    required String userId,
    required String entryText,
    String? category,
    required DateTime date,
  }) async {
    await _studyRepository.addJournalEntry(
      userId: userId,
      entryText: entryText,
      category: category,
      date: date,
    );
    await loadJournalEntries(userId);
  }

  Future<void> deleteJournalEntry({required String userId, required String id}) async {
    await _studyRepository.deleteJournalEntry(id);
    await loadJournalEntries(userId);
  }
}

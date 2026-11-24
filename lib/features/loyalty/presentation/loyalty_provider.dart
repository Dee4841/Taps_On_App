import 'package:flutter/foundation.dart';
import '../data/loyalty_repository.dart';
import '../domain/loyalty_models.dart';

class LoyaltyProvider extends ChangeNotifier {
  final LoyaltyRepository _loyaltyRepository;

  LoyaltyProvider({required LoyaltyRepository loyaltyRepository})
      : _loyaltyRepository = loyaltyRepository;

  int _tapCount = 0;
  int _points = 0;
  Set<String> _completedMilestones = {};
  bool _isLoading = false;

  int get tapCount => _tapCount;
  int get points => _points;
  Set<String> get completedMilestones => _completedMilestones;
  bool get isLoading => _isLoading;
  List<Milestone> get milestones => defaultMilestones;

  Future<void> loadLoyalty() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _loyaltyRepository.loadLoyaltyData();
      _tapCount = data['tap_count'] as int;
      _points = data['points'] as int;
      _completedMilestones = (data['completed_milestones'] as List<String>).toSet();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Milestone?> recordTap() async {
    _tapCount++;
    Milestone? newlyUnlocked;

    for (final milestone in defaultMilestones) {
      if (_tapCount >= milestone.requiredTaps &&
          !_completedMilestones.contains(milestone.description)) {
        _points += milestone.rewardPoints;
        _completedMilestones.add(milestone.description);
        newlyUnlocked = milestone;
      }
    }

    notifyListeners();

    await _loyaltyRepository.saveLoyaltyData(
      tapCount: _tapCount,
      points: _points,
      completedMilestones: _completedMilestones.toList(),
    );

    return newlyUnlocked;
  }
}

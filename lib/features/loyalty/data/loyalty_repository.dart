import 'package:shared_preferences/shared_preferences.dart';

class LoyaltyRepository {
  static const _keyTapCount = 'loyalty_tap_count';
  static const _keyPoints = 'loyalty_points';
  static const _keyMilestones = 'loyalty_completed_milestones';

  Future<Map<String, dynamic>> loadLoyaltyData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'tap_count': prefs.getInt(_keyTapCount) ?? 0,
      'points': prefs.getInt(_keyPoints) ?? 0,
      'completed_milestones': prefs.getStringList(_keyMilestones) ?? <String>[],
    };
  }

  Future<void> saveLoyaltyData({
    required int tapCount,
    required int points,
    required List<String> completedMilestones,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTapCount, tapCount);
    await prefs.setInt(_keyPoints, points);
    await prefs.setStringList(_keyMilestones, completedMilestones);
  }
}

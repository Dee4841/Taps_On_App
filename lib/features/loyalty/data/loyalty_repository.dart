import 'package:shared_preferences/shared_preferences.dart';

class LoyaltyRepository {
  static const _keyTapCount = 'loyalty_tap_count';
  static const _keyPoints = 'loyalty_points';
  static const _keyMilestones = 'loyalty_completed_milestones';

  String _id(String base, String userId) => '${base}_$userId'; 

  Future<Map<String, dynamic>> loadLoyaltyData(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'tap_count': prefs.getInt(_id(_keyTapCount, userId)) ?? 0,
      'points': prefs.getInt(_id(_keyPoints, userId)) ?? 0,
      'completed_milestones': prefs.getStringList(_id(_keyMilestones, userId)) ?? <String>[],
    };
  }

  Future<void> saveLoyaltyData({
    required String userId,
    required int tapCount,
    required int points,
    required List<String> completedMilestones,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_id(_keyTapCount, userId), tapCount);
    await prefs.setInt(_id(_keyPoints, userId), points);
    await prefs.setStringList(_id(_keyMilestones, userId), completedMilestones);
  }
}

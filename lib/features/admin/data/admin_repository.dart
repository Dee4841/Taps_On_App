import 'package:supabase_flutter/supabase_flutter.dart';
import '../../taps/domain/tap_model.dart';
import '../../taps/data/taps_repository.dart';

class AdminRepository {
  final SupabaseClient _client;

  AdminRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<int> getStudentCount() async {
    try {
      final response = await _client
          .from('students')
          .select('id');
      return (response as List).length;
    } catch (_) {
      return 0;
    }
  }

  Future<List<TapModel>> getTaps() async {
    try {
      final response = await _client.from('taps').select().order('name');
      final list = (response as List).map((t) => TapModel.fromMap(t)).toList();
      return list.isNotEmpty ? list : TapsRepository.defaultCampusTaps;
    } catch (_) {
      return TapsRepository.defaultCampusTaps;
    }
  }

  Future<void> deleteMarketplaceItem(String itemId) async {
    await _client.from('marketplace_items').delete().eq('id', itemId);
  }
}

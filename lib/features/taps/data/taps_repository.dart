import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/tap_model.dart';

class TapsRepository {
  final SupabaseClient _client;

  TapsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  static const List<TapModel> defaultCampusTaps = [
    TapModel(
      id: 'tap-1',
      name: 'Apex Studios',
      latitude: -26.1934578,
      longitude: 28.0282278,
      tankLevel: 100,
    ),
    TapModel(
      id: 'tap-2',
      name: 'Crescent Studios',
      latitude: -26.1940382,
      longitude: 28.0299252,
      tankLevel: 47,
    ),
    TapModel(
      id: 'tap-3',
      name: 'Richmond Central',
      latitude: -26.1844648,
      longitude: 28.0056029,
      tankLevel: 68,
    ),
    TapModel(
      id: 'tap-4',
      name: 'The Richmond',
      latitude: -26.1837441,
      longitude: 28.0030913,
      tankLevel: 29,
    ),
    TapModel(
      id: 'tap-5',
      name: 'Horizon Heights',
      latitude: -26.1847090,
      longitude: 28.0028546,
      tankLevel: 7,
    ),
  ];

  Future<List<TapModel>> getTaps() async {
    try {
      final response = await _client.from('taps').select().order('name');
      final list = (response as List).map((t) => TapModel.fromMap(t)).toList();
      return list.isNotEmpty ? list : defaultCampusTaps;
    } catch (_) {
      // Fallback gracefully to known campus taps if table is not yet provisioned in Supabase
      return defaultCampusTaps;
    }
  }
}

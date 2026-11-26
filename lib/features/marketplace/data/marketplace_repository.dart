import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/marketplace_item.dart';

class MarketplaceRepository {
  final SupabaseClient _client;

  MarketplaceRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<List<MarketplaceItem>> getItems() async {
    final response = await _client
        .from('marketplace_items')
        .select('*, students(name, student_number, institution)')
        .order('created_at', ascending: false);

    return (response as List).map((item) {
      final imagePath = item['image_url'] as String? ?? '';
      final resolvedUrl = imagePath.isNotEmpty
          ? _client.storage.from('items-images').getPublicUrl(imagePath)
          : '';
      return MarketplaceItem.fromMap(item, resolvedUrl);
    }).toList();
  }

  Future<void> createItem({
    required String sellerId,
    required String title,
    required String price,
    required String location,
    required String description,
    required Uint8List imageBytes,
    required String imageFileName,
  }) async {
    final storagePath =
        'marketplace/${DateTime.now().millisecondsSinceEpoch}_$imageFileName';
    await _client.storage
        .from('items-images')
        .uploadBinary(storagePath, imageBytes);

    await _client.from('marketplace_items').insert({
      'seller_id': sellerId,
      'image_url': storagePath,
      'title': title,
      'price': price,
      'location': location,
      'description': description,
    });
  }

  Future<void> deleteItem(String itemId) async {
  final deleted = await _client
      .from('marketplace_items')
      .delete()
      .eq('id', itemId)
      .select('id');
  if (deleted.isEmpty) {
    throw Exception('Listing not found or you are not allowed to delete it.');
  }
}
}


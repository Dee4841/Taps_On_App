class MarketplaceItem {
  final String id;
  final String sellerId;
  final String imageUrl;
  final String title;
  final String price;
  final String location;
  final String description;
  final String sellerName;
  final String studentNumber;
  final String institution;

  MarketplaceItem({
    required this.id,
    required this.sellerId,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.location,
    required this.description,
    required this.sellerName,
    required this.studentNumber,
    required this.institution,
  });

  factory MarketplaceItem.fromMap(
      Map<String, dynamic> map, String resolvedImageUrl) {
    final student = map['students'] as Map<String, dynamic>? ?? {};
    return MarketplaceItem(
      id: map['id']?.toString() ?? '',
      sellerId: map['seller_id'] ?? '',
      imageUrl: resolvedImageUrl,
      title: map['title'] ?? 'No Title',
      price: map['price']?.toString() ?? '0',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      sellerName: student['name'] ?? 'Unknown',
      studentNumber: student['student_number'] ?? 'N/A',
      institution: student['institution'] ?? 'N/A',
    );
  }
}

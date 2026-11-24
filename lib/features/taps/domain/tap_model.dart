class TapModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int tankLevel;
  final String status;

  const TapModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.tankLevel,
    this.status = 'operational',
  });

  factory TapModel.fromMap(Map<String, dynamic> map) {
    return TapModel(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? 'Unknown Tap',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      tankLevel: (map['tank_level'] as num?)?.toInt() ?? 100,
      status: map['status'] ?? 'operational',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'tank_level': tankLevel,
    'status': status,
  };
}

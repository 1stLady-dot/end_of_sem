class SafeZone {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius;
  final bool isDangerZone;

  SafeZone({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.isDangerZone = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'radius': radius,
    'isDangerZone': isDangerZone,
  };

  factory SafeZone.fromMap(Map<String, dynamic> map) {
    return SafeZone(
      id: map['id'],
      name: map['name'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      radius: map['radius'],
      isDangerZone: map['isDangerZone'] ?? false,
    );
  }
}
class Alert {
  final String id;
  final String userId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final bool isActive;
  final String reason;
  final DateTime? resolvedAt;
  
  Alert({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.isActive,
    required this.reason,
    this.resolvedAt,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
      'isActive': isActive,
      'reason': reason,
      'resolvedAt': resolvedAt,
    };
  }
  
  factory Alert.fromMap(String id, Map<String, dynamic> map) {
    return Alert(
      id: id,
      userId: map['userId'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? false,
      reason: map['reason'] ?? 'Emergency',
      resolvedAt: map['resolvedAt'] != null 
          ? (map['resolvedAt'] as Timestamp).toDate()
          : null,
    );
  }
}
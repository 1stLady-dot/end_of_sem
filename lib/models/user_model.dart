class AppUser {
  final String uid;
  final String email;
  final String name;
  final String studentId;
  final String program;
  final int level;
  final String phoneNumber;
  final String profileImageUrl;
  final List<EmergencyContact> emergencyContacts;
  final List<SafeZone> customSafeZones;
  final bool isEmergencyMode;
  final DateTime? lastSOSTriggered;
  final Map<String, dynamic>? biometricSettings;
  
  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.studentId,
    required this.program,
    required this.level,
    required this.phoneNumber,
    this.profileImageUrl = '',
    this.emergencyContacts = const [],
    this.customSafeZones = const [],
    this.isEmergencyMode = false,
    this.lastSOSTriggered,
    this.biometricSettings,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'studentId': studentId,
      'program': program,
      'level': level,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'emergencyContacts': emergencyContacts.map((e) => e.toMap()).toList(),
      'customSafeZones': customSafeZones.map((z) => z.toMap()).toList(),
      'isEmergencyMode': isEmergencyMode,
      'lastSOSTriggered': lastSOSTriggered?.toIso8601String(),
      'biometricSettings': biometricSettings,
    };
  }
  
  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      uid: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      studentId: map['studentId'] ?? '',
      program: map['program'] ?? '',
      level: map['level'] ?? 100,
      phoneNumber: map['phoneNumber'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      emergencyContacts: (map['emergencyContacts'] as List?)
          ?.map((e) => EmergencyContact.fromMap(e))
          .toList() ?? [],
      customSafeZones: (map['customSafeZones'] as List?)
          ?.map((z) => SafeZone.fromMap(z))
          .toList() ?? [],
      isEmergencyMode: map['isEmergencyMode'] ?? false,
      lastSOSTriggered: map['lastSOSTriggered'] != null 
          ? DateTime.parse(map['lastSOSTriggered']) 
          : null,
      biometricSettings: map['biometricSettings'],
    );
  }
}

class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String relationship;
  final bool isPrimary;
  
  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    this.isPrimary = false,
  });
  
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phoneNumber': phoneNumber,
    'relationship': relationship,
    'isPrimary': isPrimary,
  };
  
  factory EmergencyContact.fromMap(Map<String, dynamic> map) => EmergencyContact(
    id: map['id'],
    name: map['name'],
    phoneNumber: map['phoneNumber'],
    relationship: map['relationship'],
    isPrimary: map['isPrimary'] ?? false,
  );
}
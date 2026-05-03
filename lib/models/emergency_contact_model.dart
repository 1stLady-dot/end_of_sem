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

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'],
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      relationship: map['relationship'],
      isPrimary: map['isPrimary'] ?? false,
    );
  }
}
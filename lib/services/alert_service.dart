import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/alert_model.dart';
import '../services/local_storage_service.dart';

class AlertService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Send SOS Alert
  Future<void> sendSOSAlert({
    required String userId,
    required Position position,
    required String reason,
    required List<String> contactIds,
  }) async {
    final alert = Alert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: DateTime.now(),
      isActive: true,
      reason: reason,
    );
    
    // Save to Firestore
    await _firestore.collection('alerts').doc(alert.id).set(alert.toMap());
    
    // Save locally for offline access
    await LocalStorageService.addAlertToHistory(alert.toMap());
    
    // Update user emergency mode
    await _firestore.collection('users').doc(userId).update({
      'isEmergencyMode': true,
      'lastSOSTriggered': FieldValue.serverTimestamp(),
    });
    
    // Get user details for notifications
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data();
    final emergencyContacts = userData?['emergencyContacts'] as List? ?? [];
    
    // Send notifications to emergency contacts
    for (var contact in emergencyContacts) {
      await _sendNotificationToContact(contact, alert, userData?['name'] ?? 'User');
    }
    
    // Notify campus security
    await _notifySecurity(alert, userData?['name'] ?? 'User');
  }
  
  // Send notification to emergency contact
  Future<void> _sendNotificationToContact(Map<String, dynamic> contact, Alert alert, String userName) async {
    // In production, integrate with SMS gateway or Firebase Cloud Messaging
    print('Sending SOS to ${contact['name']} (${contact['phoneNumber']})');
    print('Location: ${alert.latitude}, ${alert.longitude}');
    print('User: $userName needs immediate assistance');
  }
  
  // Notify campus security
  Future<void> _notifySecurity(Alert alert, String userName) async {
    await _firestore.collection('security_alerts').add({
      'alertId': alert.id,
      'userName': userName,
      'location': GeoPoint(alert.latitude, alert.longitude),
      'timestamp': alert.timestamp,
      'status': 'pending',
      'priority': 'high',
    });
  }
  
  // Resolve Alert
  Future<void> resolveAlert(String alertId, String userId) async {
    await _firestore.collection('alerts').doc(alertId).update({
      'isActive': false,
      'resolvedAt': FieldValue.serverTimestamp(),
    });
    
    await _firestore.collection('users').doc(userId).update({
      'isEmergencyMode': false,
    });
  }
  
  // Get Active Alerts Stream
  Stream<List<Alert>> getActiveAlerts() {
    return _firestore
        .collection('alerts')
        .where('isActive', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Alert.fromMap(doc.id, doc.data()))
            .toList());
  }
  
  // Get User Alert History
  Future<List<Alert>> getUserAlertHistory(String userId) async {
    final snapshot = await _firestore
        .collection('alerts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();
    
    return snapshot.docs
        .map((doc) => Alert.fromMap(doc.id, doc.data()))
        .toList();
  }
}

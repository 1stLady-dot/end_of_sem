import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/safe_zone_model.dart';
import '../models/emergency_contact_model.dart';

class LocalStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  // Keys
  static const String _safeZonesKey = 'cached_safe_zones';
  static const String _emergencyContactsKey = 'cached_emergency_contacts';
  static const String _userPreferencesKey = 'user_preferences';
  static const String _alertHistoryKey = 'alert_history';
  
  // Save Safe Zones locally
  static Future<void> cacheSafeZones(List<SafeZone> zones) async {
    final jsonList = zones.map((z) => z.toMap()).toList();
    await _storage.write(key: _safeZonesKey, value: jsonEncode(jsonList));
  }
  
  // Get cached Safe Zones
  static Future<List<SafeZone>> getCachedSafeZones() async {
    final jsonString = await _storage.read(key: _safeZonesKey);
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => SafeZone.fromMap(json)).toList();
  }
  
  // Save Emergency Contacts locally
  static Future<void> cacheEmergencyContacts(List<EmergencyContact> contacts) async {
    final jsonList = contacts.map((c) => c.toMap()).toList();
    await _storage.write(key: _emergencyContactsKey, value: jsonEncode(jsonList));
  }
  
  // Get cached Emergency Contacts
  static Future<List<EmergencyContact>> getCachedEmergencyContacts() async {
    final jsonString = await _storage.read(key: _emergencyContactsKey);
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => EmergencyContact.fromMap(json)).toList();
  }
  
  // Save User Preferences
  static Future<void> saveUserPreferences(Map<String, dynamic> prefs) async {
    await _storage.write(key: _userPreferencesKey, value: jsonEncode(prefs));
  }
  
  // Get User Preferences
  static Future<Map<String, dynamic>> getUserPreferences() async {
    final jsonString = await _storage.read(key: _userPreferencesKey);
    if (jsonString == null) return {};
    return jsonDecode(jsonString);
  }
  
  // Save Alert to History
  static Future<void> addAlertToHistory(Map<String, dynamic> alert) async {
    final history = await getAlertHistory();
    history.insert(0, alert); // Add to beginning
    
    // Keep only last 50 alerts
    if (history.length > 50) history.removeLast();
    
    await _storage.write(key: _alertHistoryKey, value: jsonEncode(history));
  }
  
  // Get Alert History
  static Future<List<Map<String, dynamic>>> getAlertHistory() async {
    final jsonString = await _storage.read(key: _alertHistoryKey);
    if (jsonString == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(jsonString));
  }
  
  // Clear all local data (on logout)
  static Future<void> clearAllData() async {
    await _storage.deleteAll();
  }
}
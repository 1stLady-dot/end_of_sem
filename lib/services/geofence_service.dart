import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../models/safe_zone_model.dart';
import '../services/alert_service.dart';
import '../services/location_service.dart';
import '../utils/constants.dart';

class GeofenceService {
  static final GeofenceService _instance = GeofenceService._internal();
  factory GeofenceService() => _instance;
  GeofenceService._internal();
  
  StreamSubscription<Position>? _positionSubscription;
  List<SafeZone> activeZones = [];
  bool isMonitoring = false;
  String? currentUserId;
  
  // Campus safe zones
  final List<SafeZone> campusZones = AppConstants.safeZones.map((zone) => SafeZone(
    id: zone['name']!.toLowerCase().replaceAll(' ', '_'),
    name: zone['name']!,
    latitude: zone['lat']!,
    longitude: zone['lng']!,
    radius: zone['radius']!,
    isDangerZone: false,
  )).toList();
  
  // Danger zones
  final List<SafeZone> dangerZones = AppConstants.dangerZones.map((zone) => SafeZone(
    id: zone['name']!.toLowerCase().replaceAll(' ', '_'),
    name: zone['name']!,
    latitude: zone['lat']!,
    longitude: zone['lng']!,
    radius: zone['radius']!,
    isDangerZone: true,
  )).toList();
  
  void startMonitoring(List<SafeZone> userZones, String userId) {
    if (isMonitoring) return;
    
    currentUserId = userId;
    activeZones = [...campusZones, ...dangerZones, ...userZones];
    isMonitoring = true;
    
    _positionSubscription = LocationService.getLocationStream().listen((position) {
      _checkGeofences(position);
    });
  }
  
  void stopMonitoring() {
    _positionSubscription?.cancel();
    isMonitoring = false;
    currentUserId = null;
  }
  
  void _checkGeofences(Position position) async {
    for (SafeZone zone in activeZones) {
      double distance = await LocationService.calculateDistance(
        position.latitude, position.longitude,
        zone.latitude, zone.longitude,
      );
      
      bool isInside = distance <= zone.radius;
      
      // Check time (late night = potential danger)
      DateTime now = DateTime.now();
      bool isLateNight = now.hour >= AppConstants.lateNightStartHour || 
                         now.hour <= AppConstants.lateNightEndHour;
      
      // If in danger zone during late night, trigger alert
      if (zone.isDangerZone && isInside && isLateNight && currentUserId != null) {
        await AlertService().sendSOSAlert(
          userId: currentUserId!,
          position: position,
          reason: 'Entered danger zone: ${zone.name}',
          contactIds: [],
        );
      }
      
      // If left safe zone during late night
      if (!zone.isDangerZone && !isInside && isLateNight && currentUserId != null) {
        // Check if user was previously inside
        // This would need state tracking - simplified for demo
        print('User left safe zone: ${zone.name} at late night');
      }
    }
  }
}
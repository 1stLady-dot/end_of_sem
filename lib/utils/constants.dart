import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'CampusGuard';
  static const String appVersion = '1.0.0';
  
  // Campus Locations (Valley View University)
  static const double vvuLatitude = 5.7895;
  static const double vvuLongitude = -0.2567;
  
  // Safe Zones
  static const List<Map<String, dynamic>> safeZones = [
    {'name': 'Main Library', 'lat': 5.7895, 'lng': -0.2567, 'radius': 100},
    {'name': 'Dormitory A', 'lat': 5.7880, 'lng': -0.2580, 'radius': 80},
    {'name': 'Dormitory B', 'lat': 5.7905, 'lng': -0.2555, 'radius': 80},
    {'name': 'Student Center', 'lat': 5.7910, 'lng': -0.2570, 'radius': 120},
    {'name': 'Security Booth', 'lat': 5.7875, 'lng': -0.2590, 'radius': 50},
    {'name': 'Lecture Hall Complex', 'lat': 5.7885, 'lng': -0.2575, 'radius': 150},
  ];
  
  // Danger Zones (High Alert Areas)
  static const List<Map<String, dynamic>> dangerZones = [
    {'name': 'Parking Lot C', 'lat': 5.7860, 'lng': -0.2600, 'radius': 60},
    {'name': 'Behind Science Block', 'lat': 5.7900, 'lng': -0.2585, 'radius': 50},
  ];
  
  // SOS Settings
  static const int sosShakeThreshold = 15;
  static const int sosHoldDuration = 3000; // milliseconds
  static const int locationUpdateInterval = 10; // meters
  static const int lateNightStartHour = 22; // 10 PM
  static const int lateNightEndHour = 5; // 5 AM
}

class AppColors {
  static const Color primaryRed = Color(0xFFE53935);
  static const Color darkRed = Color(0xFFC62828);
  static const Color lightRed = Color(0xFFEF9A9A);
  static const Color safetyGreen = Color(0xFF43A047);
  static const Color warningYellow = Color(0xFFFDD835);
  static const Color backgroundGrey = Color(0xFFF5F5F5);
}
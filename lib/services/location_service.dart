import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/constants.dart';

class LocationService {
  static Future<bool> requestPermissions() async {
    final locationStatus = await Permission.location.request();
    final backgroundStatus = await Permission.locationAlways.request();
    final notificationStatus = await Permission.notification.request();
    
    return locationStatus.isGranted && notificationStatus.isGranted;
  }
  
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
  
  static Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: AppConstants.locationUpdateInterval,
      ),
    );
  }
  
  static Future<double> calculateDistance(
    double lat1, double lon1, double lat2, double lon2
  ) async {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
  
  static Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await Geolocator.placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return '${placemark.street}, ${placemark.locality}';
      }
      return 'Unknown location';
    } catch (e) {
      return 'Location unavailable';
    }
  }
}
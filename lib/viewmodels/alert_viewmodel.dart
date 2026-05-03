import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/alert_model.dart';
import '../services/alert_service.dart';
import '../services/local_storage_service.dart';

class AlertViewModel extends ChangeNotifier {
  final AlertService _alertService = AlertService();
  List<Alert> _alerts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Alert> get alerts => _alerts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> sendSOSAlert({
    required String userId,
    required Position position,
    required String reason,
    required List<String> contacts,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _alertService.sendSOSAlert(
        userId: userId,
        position: position,
        reason: reason,
        contactIds: contacts,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAlertHistory() async {
    _isLoading = true;
    notifyListeners();
    final history = await LocalStorageService.getAlertHistory();
    final loadedAlerts = history.map((map) => Alert.fromMap(map['id'] ?? '', map)).toList();
    _alerts = loadedAlerts;
    _isLoading = false;
    notifyListeners();
  }
}
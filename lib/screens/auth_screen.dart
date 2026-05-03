import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final TextEditingController _pinController = TextEditingController();
  
  bool _isBiometricSupported = false;
  List<BiometricType> _availableBiometrics = [];
  
  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }
  
  Future<void> _checkBiometrics() async {
    final canCheck = await _localAuth.canCheckBiometrics;
    final biometrics = await _localAuth.getAvailableBiometrics();
    
    setState(() {
      _isBiometricSupported = canCheck;
      _availableBiometrics = biometrics;
    });
    
    if (canCheck && biometrics.isNotEmpty) {
      _authenticateWithBiometrics();
    }
  }
  
  Future<void> _authenticateWithBiometrics() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Unlock CampusGuard with your biometric',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      
      if (authenticated && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print('Biometric error: $e');
    }
  }
  
  Future<void> _verifyPin() async {
    final storedHash = await _storage.read(key: 'user_pin_hash');
    
    if (storedHash == null) {
      // First time - set up PIN
      _setupPin();
      return;
    }
    
    final inputHash = sha256.convert(utf8.encode(_pinController.text)).toString();
    
    if (inputHash == storedHash) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wrong PIN. Please try again.')),
      );
      _pinController.clear();
    }
  }
  
  void _setupPin() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Set Security PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Set a 4-6 digit PIN to secure your app.'),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Enter PIN',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_pinController.text.length >= 4) {
                final hash = sha256.convert(utf8.encode(_pinController.text)).toString();
                _storage.write(key: 'user_pin_hash', value: hash);
                Navigator.pop(context);
                _verifyPin();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fingerprint, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Authentication Required',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please verify your identity to access CampusGuard',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            
            if (_isBiometricSupported && _availableBiometrics.isNotEmpty)
              ElevatedButton.icon(
                onPressed: _authenticateWithBiometrics,
                icon: Icon(
                  _availableBiometrics.contains(BiometricType.fingerprint)
                      ? Icons.fingerprint
                      : Icons.face,
                ),
                label: Text(
                  _availableBiometrics.contains(BiometricType.fingerprint)
                      ? 'Use Fingerprint'
                      : 'Use Face ID',
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            
            if (_isBiometricSupported && _availableBiometrics.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('OR'),
              ),
            
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Enter PIN',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _verifyPin,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );
  }
}
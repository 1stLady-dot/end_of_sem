import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../viewmodels/alert_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../services/location_service.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  @override
  Widget build(BuildContext context) {
    final alertVM = Provider.of<AlertViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Alert'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.warning,
                  size: 100,
                  color: Colors.white,
                ),
                onPressed: () async {
                  final authVM = Provider.of<AuthViewModel>(context, listen: false);
                  final user = authVM.currentUser;
                  if (user == null) return;

                  final position = await LocationService.getCurrentLocation();
                  if (position == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Unable to get location')),
                    );
                    return;
                  }

                  await alertVM.sendSOSAlert(
                    userId: user.uid,
                    position: position,
                    reason: 'Manual SOS trigger',
                    contacts: user.emergencyContacts.map((c) => c.phoneNumber).toList(),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('SOS Alert sent!')),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Emergency SOS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tap to send emergency alert',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            if (alertVM.isLoading)
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
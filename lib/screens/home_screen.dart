import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/alert_viewmodel.dart';
import '../viewmodels/location_viewmodel.dart';
import '../services/location_service.dart';
import '../services/geofence_service.dart';
import '../utils/constants.dart';
import '../widgets/quote_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isListeningToShake = true;
  double _lastShakeTime = 0;
  bool _isSOSTriggering = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startShakeDetection();
    _startLocationMonitoring();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    GeofenceService().stopMonitoring();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startLocationMonitoring();
    } else if (state == AppLifecycleState.paused) {
      // Continue background monitoring
    }
  }
  
  void _startLocationMonitoring() async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final user = authVM.currentUser;
    
    if (user != null) {
      GeofenceService().startMonitoring(user.customSafeZones, user.uid);
    }
  }
  
  void _startShakeDetection() {
    accelerometerEventStream().listen((AccelerometerEvent event) {
      if (!_isListeningToShake || _isSOSTriggering) return;
      
      double acceleration = 
          (event.x * event.x + event.y * event.y + event.z * event.z);
      
      double now = DateTime.now().millisecondsSinceEpoch.toDouble();
      
      if (acceleration > AppConstants.sosShakeThreshold && 
          (now - _lastShakeTime) > 2000) {
        _lastShakeTime = now;
        _triggerShakeSOS();
      }
    });
  }
  
  Future<void> _triggerShakeSOS() async {
    setState(() => _isSOSTriggering = true);
    
    final shouldSend = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('SOS Triggered!'),
          ],
        ),
        content: const Text(
          'Emergency shake detected! Would you like to send an SOS alert to your emergency contacts and campus security?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );
    
    if (shouldSend == true) {
      await _sendSOSAlert(reason: 'Shake gesture detected');
    }
    
    setState(() => _isSOSTriggering = false);
  }
  
  Future<void> _sendSOSAlert({required String reason}) async {
    final alertVM = Provider.of<AlertViewModel>(context, listen: false);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final user = authVM.currentUser;
    
    if (user == null) return;
    
    final position = await LocationService.getCurrentLocation();
    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to get location. Please enable GPS.')),
      );
      return;
    }
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    await alertVM.sendSOSAlert(
      userId: user.uid,
      position: position,
      reason: reason,
      contacts: user.emergencyContacts.map((c) => c.phoneNumber).toList(),
    );
    
    if (context.mounted) {
      Navigator.pop(context); // Close loading
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('✅ SOS Sent'),
          content: Text(
            'Emergency alert sent to ${user.emergencyContacts.length} contact(s) and campus security.\n\n'
            'Location: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}\n\n'
            'Help is on the way. Stay where you are if safe to do so.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final user = authVM.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Welcome Message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: AppColors.lightRed,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?.name?.split(' ').first ?? 'Student'}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Stay safe on campus',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              
              // SOS Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onLongPress: () => _sendSOSAlert(reason: 'Manual SOS button'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryRed, AppColors.darkRed],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryRed.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.warning,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'LONG PRESS FOR SOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isSOSTriggering ? 'Sending...' : 'Or shake your phone',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Quote Card
              const QuoteCard(),
              
              // Features Grid
              Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildFeatureCard(
                      icon: Icons.map,
                      title: 'Live Map',
                      subtitle: 'View safe zones',
                      color: Colors.blue,
                      onTap: () => Navigator.pushNamed(context, '/map'),
                    ),
                    _buildFeatureCard(
                      icon: Icons.people,
                      title: 'Emergency',
                      subtitle: 'Manage contacts',
                      color: Colors.green,
                      onTap: () => Navigator.pushNamed(context, '/contacts'),
                    ),
                    _buildFeatureCard(
                      icon: Icons.shield,
                      title: 'Safe Zones',
                      subtitle: 'View campus zones',
                      color: Colors.orange,
                      onTap: () => Navigator.pushNamed(context, '/safe-zones'),
                    ),
                    _buildFeatureCard(
                      icon: Icons.history,
                      title: 'Alert History',
                      subtitle: 'View past alerts',
                      color: Colors.purple,
                      onTap: () => Navigator.pushNamed(context, '/alert-history'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/alert_viewmodel.dart';
import '../models/alert_model.dart';
import '../utils/date_formatter.dart';

class AlertHistoryScreen extends StatefulWidget {
  const AlertHistoryScreen({super.key});

  @override
  State<AlertHistoryScreen> createState() => _AlertHistoryScreenState();
}

class _AlertHistoryScreenState extends State<AlertHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load alerts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AlertViewModel>(context, listen: false).loadAlertHistory();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert History'),
      ),
      body: Consumer<AlertViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (viewModel.alerts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No alerts yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your SOS history will appear here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          // Optimized ListView.builder (Week 10 performance)
          return ListView.builder(
            itemCount: viewModel.alerts.length,
            itemBuilder: (context, index) {
              // Use const for static widgets when possible
              return _buildAlertCard(viewModel.alerts[index]);
            },
          );
        },
      ),
    );
  }
  
  // Extract to separate method for better performance
  Widget _buildAlertCard(Alert alert) {
    final isActive = alert.isActive;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? Colors.red : Colors.grey,
          child: Icon(
            isActive ? Icons.warning : Icons.check,
            color: Colors.white,
          ),
        ),
        title: Text(
          alert.reason,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormatUtil.formatDateTime(alert.timestamp)),
            const SizedBox(height: 4),
            Text(
              '📍 ${alert.latitude.toStringAsFixed(6)}, ${alert.longitude.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: isActive
            ? const Chip(
                label: Text('ACTIVE'),
                backgroundColor: Colors.red,
                labelStyle: TextStyle(color: Colors.white, fontSize: 10),
              )
            : const Chip(
                label: Text('RESOLVED'),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white, fontSize: 10),
              ),
        isThreeLine: true,
      ),
    );
  }
}
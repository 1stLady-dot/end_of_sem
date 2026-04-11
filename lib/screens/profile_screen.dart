import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final user = authVM.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Professional Profile'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section (Week 2 requirement)
            _buildHeaderSection(user),
            const SizedBox(height: 16),
            
            // Bio Section
            _buildBioSection(),
            const SizedBox(height: 16),
            
            // Skills Section (Week 2 requirement)
            _buildSkillsSection(),
            const SizedBox(height: 16),
            
            // Academic History (Week 2 requirement)
            _buildAcademicSection(user),
            const SizedBox(height: 16),
            
            // Emergency Contacts Preview
            _buildEmergencyContactsSection(user, context),
            const SizedBox(height: 16),
            
            // App Settings
            _buildSettingsSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeaderSection(AppUser? user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryRed, AppColors.darkRed],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 50,
              color: AppColors.primaryRed,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'Student Name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user?.program ?? 'BSc. Computer Science',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email, size: 16, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                user?.email ?? 'student@vvu.edu.gh',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(width: 16),
              Icon(Icons.phone, size: 16, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                user?.phoneNumber ?? 'Not set',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildBioSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About Me',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'I am a 300-level Computer Science student at Valley View University, '
              'passionate about mobile application development and creating solutions '
              'that enhance campus safety and student well-being. CampusGuard is my '
              'capstone project focused on leveraging technology for personal security.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSkillsSection() {
    final List<String> skills = [
      'Flutter & Dart',
      'Firebase',
      'REST APIs',
      'Git & GitHub',
      'UI/UX Design',
      'Problem Solving',
    ];
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Technical Skills',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((skill) {
                return Chip(
                  label: Text(skill),
                  backgroundColor: AppColors.lightRed,
                  labelStyle: const TextStyle(color: Colors.black87),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAcademicSection(AppUser? user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Academic History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.school, color: Colors.blue),
              title: const Text('Valley View University'),
              subtitle: Text('${user?.program ?? 'Computer Science'} (Level ${user?.level ?? 300})'),
              trailing: const Text('2023 - Present'),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.code, color: Colors.green),
              title: Text('Relevant Courses'),
              subtitle: Text('• Mobile App Development\n• Database Systems\n• Software Engineering\n• Data Structures & Algorithms'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmergencyContactsSection(AppUser? user, BuildContext context) {
    final contacts = user?.emergencyContacts ?? [];
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Emergency Contacts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/contacts');
                  },
                  child: const Text('Manage'),
                ),
              ],
            ),
            if (contacts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No emergency contacts added yet'),
              )
            else
              ...contacts.take(3).map((contact) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.lightRed,
                  child: Icon(Icons.person, color: AppColors.primaryRed),
                ),
                title: Text(contact.name),
                subtitle: Text('${contact.relationship} • ${contact.phoneNumber}'),
                trailing: contact.isPrimary 
                    ? const Icon(Icons.star, color: Colors.amber)
                    : null,
              )),
            if (contacts.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('+ ${contacts.length - 3} more contacts'),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettingsSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.biometric),
            title: const Text('Biometric Authentication'),
            subtitle: const Text('Unlock app with fingerprint/face ID'),
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: AppColors.primaryRed,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive safety alerts'),
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: AppColors.primaryRed,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Background Location'),
            subtitle: const Text('Enable geofencing monitoring'),
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: AppColors.primaryRed,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: false,
              onChanged: (value) {},
              activeColor: AppColors.primaryRed,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }
  
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<AuthViewModel>(context, listen: false).signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
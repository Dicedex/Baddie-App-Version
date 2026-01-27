import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _onlineStatus = true;
  String _distanceFilter = '50 km';
  String _ageRange = '18 - 40';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          _buildSection('Notifications', [
            _buildSwitchTile(
              title: 'Push Notifications',
              subtitle: 'New messages and matches',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
              },
            ),
          ]),
          _buildSection('Privacy', [
            _buildSwitchTile(
              title: 'Show Online Status',
              subtitle: 'Let others see when you\'re active',
              value: _onlineStatus,
              onChanged: (value) {
                setState(() => _onlineStatus = value);
              },
            ),
            _buildSwitchTile(
              title: 'Share Location',
              subtitle: 'Help find matches near you',
              value: _locationEnabled,
              onChanged: (value) {
                setState(() => _locationEnabled = value);
              },
            ),
          ]),
          _buildSection('Discovery Settings', [
            _buildDropdownTile(
              title: 'Maximum Distance',
              value: _distanceFilter,
              options: ['10 km', '25 km', '50 km', '100 km', '200+ km'],
              onChanged: (value) {
                setState(() => _distanceFilter = value);
              },
            ),
            _buildDropdownTile(
              title: 'Age Range',
              value: _ageRange,
              options: ['18 - 25', '18 - 30', '18 - 40', '25 - 50'],
              onChanged: (value) {
                setState(() => _ageRange = value);
              },
            ),
          ]),
          _buildSection('Account', [
            _buildSettingsTile(
              title: 'Blocked Users',
              subtitle: 'Manage blocked profiles',
              icon: Icons.block,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Blocked users: None')),
                );
              },
            ),
            _buildSettingsTile(
              title: 'Safety Tips',
              subtitle: 'Learn how to stay safe',
              icon: Icons.security,
              onTap: () {
                _showSafetyTips(context);
              },
            ),
          ]),
          _buildSection('About', [
            _buildSettingsTile(
              title: 'App Version',
              subtitle: '1.0.0',
              icon: Icons.info,
            ),
            _buildSettingsTile(
              title: 'Terms of Service',
              subtitle: 'View our terms',
              icon: Icons.description,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Terms of Service')),
                );
              },
            ),
            _buildSettingsTile(
              title: 'Privacy Policy',
              subtitle: 'View our privacy policy',
              icon: Icons.privacy_tip,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy Policy')),
                );
              },
            ),
          ]),
          _buildSection('Danger Zone', [
            _buildDangerTile(
              title: 'Logout',
              icon: Icons.logout,
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
            _buildDangerTile(
              title: 'Delete Account',
              subtitle: 'Permanently delete your account',
              icon: Icons.delete_forever,
              onTap: () {
                _showDeleteDialog(context);
              },
            ),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFF06595),
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required List<String> options,
    required Function(String) onChanged,
  }) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: options
            .map((option) => DropdownMenuItem(
                  value: option,
                  child: Text(option),
                ))
            .toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required IconData icon,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)) : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDangerTile({
    required String title,
    required IconData icon,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(
        title,
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.red.shade200),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.red),
      onTap: onTap,
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
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion requested')),
              );
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSafetyTips(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Safety Tips'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                '✅ Stay Safe on Baddie',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                '• Don\'t share personal information like your address or phone number\n'
                '• Meet in public places for the first time\n'
                '• Tell a friend where you\'re going\n'
                '• Trust your instincts\n'
                '• Block and report suspicious profiles\n'
                '• Use the app\'s messaging system',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../../models/hazard.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hazard_provider.dart';
import '../auth/login_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final hazardProvider = context.watch<HazardProvider>();
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    final myReports = hazardProvider.allHazards
        .where((h) => h.source == HazardSource.community && h.reportedByUserId == user.uid)
        .toList();
    final resolved = myReports.where((h) => h.status == HazardStatus.resolved).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFF0B5D3B),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 14),
          Center(child: Text(user.name, style: Theme.of(context).textTheme.titleLarge)),
          Center(child: Text(user.email, style: const TextStyle(color: Colors.grey))),
          const SizedBox(height: 6),
          Center(
            child: Chip(
              label: Text(user.role == UserRole.admin ? 'Administrator' : 'Public Contributor'),
              backgroundColor: user.role == UserRole.admin ? const Color(0xFFEFF4FF) : const Color(0xFFE7F3EC),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _StatTile(value: '${myReports.length}', label: 'Reports Submitted')),
              const SizedBox(width: 12),
              Expanded(child: _StatTile(value: '$resolved', label: 'Resolved')),
            ],
          ),
          const SizedBox(height: 24),
          if (user.role == UserRole.admin)
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: const Text('Admin Dashboard'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log out', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0B5D3B))),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../admin/admin_dashboard_screen.dart';
import '../community/community_reports_screen.dart';
import '../map/main_map_screen.dart';
import '../profile/profile_screen.dart';
import '../report/report_hazard_screen.dart';
import '../tracking/tracking_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  static const _screens = [
    MainMapScreen(),
    CommunityReportsScreen(),
    ReportHazardScreen(),
    TrackingScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
              ),
              icon: const Icon(Icons.admin_panel_settings_outlined),
              label: const Text('Admin'),
              backgroundColor: const Color(0xFF1D4ED8),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.forum_outlined), activeIcon: Icon(Icons.forum), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.add_a_photo_outlined), activeIcon: Icon(Icons.add_a_photo), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.timeline_outlined), activeIcon: Icon(Icons.timeline), label: 'Tracking'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

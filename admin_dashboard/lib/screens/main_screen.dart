import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'projects_screen.dart';
import 'press_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ProjectsScreen(),
    const PressScreen(),
    const ProfileScreen(),
  ];

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            leading: Column(
              children: [
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _signOut,
                  tooltip: 'Logout',
                ),
                const SizedBox(height: 20),
              ],
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.work_outline),
                selectedIcon: Icon(Icons.work),
                label: Text('Projects'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.newspaper_outlined),
                selectedIcon: Icon(Icons.newspaper),
                label: Text('Press'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Profile'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

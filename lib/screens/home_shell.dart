import 'package:flutter/material.dart';

import '../widgets/auth_background.dart';
import 'food_tracker_page.dart';
import 'settings_page.dart';
import 'statistics_page.dart';
import 'workout_home_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const AuthBackground(child: SizedBox.expand()),
          SafeArea(
            child: IndexedStack(
              index: _currentIndex,
              children: const [
                WorkoutHomePage(),
                FoodTrackerPage(),
                StatisticsPage(),
                SettingsPage(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        onChanged: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavItem(
              icon: Icons.grid_view_rounded,
              index: 0,
              currentIndex: currentIndex,
              onTap: onChanged,
            ),
            _NavItem(
              icon: Icons.restaurant_rounded,
              index: 1,
              currentIndex: currentIndex,
              onTap: onChanged,
            ),
            _NavItem(
              icon: Icons.bar_chart_rounded,
              index: 2,
              currentIndex: currentIndex,
              onTap: onChanged,
            ),
            _NavItem(
              icon: Icons.settings_rounded,
              index: 3,
              currentIndex: currentIndex,
              onTap: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  final IconData icon;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        width: 56,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.black : Colors.white70,
          size: 22,
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/onboarding_controller.dart';
import '../widgets/auth_background.dart';
import '../widgets/calorie_line_chart.dart';
import '../widgets/schedule_timeline.dart';
import 'dumbbell_workout_screen.dart';

class WorkoutHomePage extends StatelessWidget {
  const WorkoutHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final name = context.watch<OnboardingController>().displayName;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(name: name),
                const SizedBox(height: 24),
                const CalorieLineChart(),
                const SizedBox(height: 24),
                _ScheduleSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi!,',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/avatar_placeholder.png'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      ScheduleItem(
        title: 'WarmUp',
        subtitle: 'Run 02 km',
        isFirst: true,
      ),
      ScheduleItem(
        title: 'Muscle Up',
        subtitle: '10 reps, 3 sets with 20 sec rest',
        isLast: true,
      ),
    ];

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your\nSchedule',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: const Icon(Icons.filter_list, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Today's Activity",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ScheduleTimeline(
              items: items,
              onStartTap: (item) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DumbbellWorkoutScreen(
                      title: item.title,
                      targetReps: item.title == 'Muscle Up' ? 10 : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'calendar_planner.dart';
import 'create_task.dart';
import 'pamodoro_timer.dart';
import 'goals_page.dart';
import 'study_time_tracker.dart';
import 'study_jounal.dart';

class TimeManagementOptionsPage extends StatelessWidget {
  const TimeManagementOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time Management')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children:  [
          _FeatureCard(
            title: '📅 Calendar & Planner',
            subtitle: 'View and organize your events and study sessions.',
            icon: Icons.calendar_today,
             destinationBuilder: () => const CalendarPlannerPage(),
          ),
          _FeatureCard(
            title: '📝 To-Do List',
            subtitle: 'Tasks, deadlines, and priorities in one place.',
            icon: Icons.check_circle_outline,
            destinationBuilder: () => const TaskPage(),
          ),
          _FeatureCard(
            title: '⏲️ Pomodoro Timer',
            subtitle: 'Stay focused with 1 hour focus sessions.',
            icon: Icons.timer,
            destinationBuilder: () => const PomodoroTimerPage(),
          ),
          _FeatureCard(
            title: '🎯 Goals',
            subtitle: 'Track weekly/daily academic goals.',
            icon: Icons.flag_outlined,
            destinationBuilder: () => const GoalsPage(),
          ),
          _FeatureCard(
            title: '📊 Study Time Tracker',
            subtitle: 'Log and visualize how you spend study time.',
            icon: Icons.bar_chart,
            destinationBuilder: () => const StudyTimeTrackerPage(),
          ),
          _FeatureCard(
            title: '📓 Time Journal',
            subtitle: 'Reflect on your day and categorize time spent.',
            icon: Icons.menu_book,
            destinationBuilder: () => const TimeJournalPage(),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget Function()? destinationBuilder;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.destinationBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          if (destinationBuilder !=null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => destinationBuilder!()),
            );
          }
        },
      ),
    );
  }
}

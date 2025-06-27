import 'package:flutter/material.dart';


class TimeManagementOptionsPage extends StatelessWidget {
  const TimeManagementOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time Management')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _FeatureCard(
            title: '📅 Calendar & Planner',
            subtitle: 'View and organize your events and study sessions.',
            icon: Icons.calendar_today,
            routeToCanvasCalendar: true,
          ),
          _FeatureCard(
            title: '📝 To-Do List',
            subtitle: 'Tasks, deadlines, and priorities in one place.',
            icon: Icons.check_circle_outline,
          ),
          _FeatureCard(
            title: '⏲️ Pomodoro Timer',
            subtitle: 'Stay focused with 25-minute focus sessions.',
            icon: Icons.timer,
          ),
          _FeatureCard(
            title: '🎯 Goals',
            subtitle: 'Track weekly/daily academic goals.',
            icon: Icons.flag_outlined,
          ),
          _FeatureCard(
            title: '📊 Study Time Tracker',
            subtitle: 'Log and visualize how you spend study time.',
            icon: Icons.bar_chart,
          ),
          _FeatureCard(
            title: '📓 Time Journal',
            subtitle: 'Reflect on your day and categorize time spent.',
            icon: Icons.menu_book,
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
  final bool routeToCanvasCalendar;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.routeToCanvasCalendar = false,
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
     
      ),
    );
  }
}

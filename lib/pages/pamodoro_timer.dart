import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PomodoroTimerPage extends StatefulWidget {
  const PomodoroTimerPage({super.key});

  @override
  State<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends State<PomodoroTimerPage> {
  int focusDuration = 0;
  int breakDuration = 0;

  late int _secondsRemaining;
  late bool _isFocusMode;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _startFocus();
  }

  void _startFocus() {
    setState(() {
      _isFocusMode = true;
      _secondsRemaining = focusDuration;
      _isRunning = true;
    });
    _startTimer();
  }

  void _startBreak() {
    setState(() {
      _isFocusMode = false;
      _secondsRemaining = breakDuration;
      _isRunning = true;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) 
      {
         _playAlert();
        _timer?.cancel();
        _isFocusMode ? _startBreak() : _startFocus();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void _playAlert() async {
  
  if (await Vibration.hasVibrator() ?? false) {
    Vibration.vibrate(duration: 500);
  }

  // Play sound
  final player = AssetsAudioPlayer();
  await player.open(
    Audio("assets/sounds/alert.mp3"),
    autoStart: true,
  );
}


  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resumeTimer() {
    setState(() {
      _isRunning = true;
    });
    _startTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isFocusMode = true;
      _secondsRemaining = focusDuration;
      _isRunning = false;
    });
  }


  Future<void> _showSettingsDialog() async {
  final prefs = await SharedPreferences.getInstance();
  int focusMin = prefs.getInt('focusMinutes') ?? 60;
  int breakMin = prefs.getInt('breakMinutes') ?? 15;

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Customize Pomodoro"),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text("Focus Duration:"),
                    const Spacer(),
                    DropdownButton<int>(
                      value: focusMin,
                      items: [25, 50, 60]
                          .map((m) => DropdownMenuItem(value: m, child: Text("$m min")))
                          .toList(),
                      onChanged: (val) => setState(() => focusMin = val!),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text("Break Duration:"),
                    const Spacer(),
                    DropdownButton<int>(
                      value: breakMin,
                      items: [5, 10, 15]
                          .map((m) => DropdownMenuItem(value: m, child: Text("$m min")))
                          .toList(),
                      onChanged: (val) => setState(() => breakMin = val!),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await prefs.setInt('focusMinutes', focusMin);
              await prefs.setInt('breakMinutes', breakMin);
              if (context.mounted) Navigator.pop(context);
              setState(() {
                focusDuration = focusMin * 60;
                breakDuration = breakMin * 60;
              });
            },
            child: const Text("Save"),
          ),
        ],
      );
    },
  );
}

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
 Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text("Pomodoro Timer")),
    body: Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isFocusMode ? "Focus Time" : "Break Time",
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            _formatTime(_secondsRemaining),
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isRunning)
                ElevatedButton.icon(
                  onPressed: _pauseTimer,
                  icon: const Icon(Icons.pause),
                  label: const Text("Pause"),
                )
              else
                ElevatedButton.icon(
                  onPressed: _resumeTimer,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Resume"),
                ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _resetTimer,
                icon: const Icon(Icons.refresh),
                label: const Text("Reset"),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showSettingsDialog, // <-- Add this function in your class
            icon: const Icon(Icons.settings),
            label: const Text("Customize Durations"),
          ),
        ],
      ),
    ),
  );
}
}
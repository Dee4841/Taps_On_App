import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class PomodoroTimerPage extends StatefulWidget {
  const PomodoroTimerPage({super.key});

  @override
  State<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends State<PomodoroTimerPage> with WidgetsBindingObserver {
  int focusDuration = 0;
  int breakDuration = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  DateTime? _startTime;
  int _duration = 0; // in seconds
  Timer? _timer;
  Timer? _vibrationTimer;
  bool _isFocusMode = true;
  bool _isRunning = false;
  late int _secondsRemaining;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDurationsAndStart();
  }

  Future<void> _loadDurationsAndStart() async {
    final prefs = await SharedPreferences.getInstance();
    final focusMin = prefs.getInt('focusMinutes') ?? 30;
    final breakMin = prefs.getInt('breakMinutes') ?? 15;

    setState(() {
      focusDuration = focusMin * 60;
      breakDuration = breakMin * 60;
    });

    _startFocus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final elapsed = DateTime.now().difference(_startTime ?? DateTime.now()).inSeconds;
      final remaining = _duration - elapsed;

      if (!_isRunning && remaining <= 0 && !_isFocusMode) {
        _playAlert();
      }
    }
  }

  void _startFocus() {
    _duration = focusDuration;
    _startTimer(isFocus: true);
  }

  void _startBreak() {
    _duration = breakDuration;
    _startTimer(isFocus: false);
  }

  void _startTimer({required bool isFocus}) async{
     await WakelockPlus.enable();
    _isFocusMode = isFocus;
    _startTime = DateTime.now();
    _isRunning = true;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final elapsed = DateTime.now().difference(_startTime!).inSeconds;
      final remaining = _duration - elapsed;

      if (remaining <= 0) {
        _timer?.cancel();
        if (_isFocusMode) {
          _startBreak();
        } else {
          _isRunning = false;
          _playAlert();
          setState(() {});
        }
      } else {
        setState(() {});
      }
    });
  }

  void _playAlert() async {
    if (await Vibrate.canVibrate) {
      _vibrationTimer?.cancel();

      _vibrationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        Vibrate.vibrateWithPauses([
          const Duration(milliseconds: 500),
          const Duration(milliseconds: 200),
        ]);
      });

      try {
        await _audioPlayer.setAsset('assets/sounds/alert.mp3');
        await _audioPlayer.play();
      } catch (e) {
        debugPrint('Audio error: $e');
      }
    }
  }

  void _pauseTimer() async {
     await WakelockPlus.disable();
    final elapsed = DateTime.now().difference(_startTime!).inSeconds;
    _duration = _duration - elapsed;
    _isRunning = false;
    _timer?.cancel();
  }

  void _resumeTimer() {
    _startTime = DateTime.now();
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final elapsed = DateTime.now().difference(_startTime!).inSeconds;
      final remaining = _duration - elapsed;

      if (remaining <= 0) {
        _timer?.cancel();
        _playAlert();
        _isFocusMode ? _startBreak() : _startFocus();
      } else {
        setState(() {});
      }
    });
  }

  void _resetTimer() async {
     await WakelockPlus.disable();
    _timer?.cancel();
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
    _audioPlayer.stop();
    setState(() {
      _isFocusMode = true;
      _secondsRemaining = focusDuration;
      _isRunning = false;
    });
  }

  Future<void> _showSettingsDialog() async {
    final prefs = await SharedPreferences.getInstance();
    int focusMin = prefs.getInt('focusMinutes') ?? 30;
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
                        items: [30, 60, 90, 120]
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
                        items: [15, 30, 45]
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
                if (!_isRunning) {
                  _startFocus(); // restart with new settings if not running
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  String _formatTime() {
    if (!_isRunning || _startTime == null) return _formatSeconds(_duration);
    final elapsed = DateTime.now().difference(_startTime!).inSeconds;
    final remaining = _duration - elapsed;
    return _formatSeconds(remaining > 0 ? remaining : 0);
  }

  String _formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _vibrationTimer?.cancel();
    _audioPlayer.dispose();
    WidgetsBinding.instance.removeObserver(this);
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
              _formatTime(),
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
              onPressed: _showSettingsDialog,
              icon: const Icon(Icons.settings),
              label: const Text("Customize Durations"),
            ),
          ],
        ),
      ),
    );
  }
}

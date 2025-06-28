import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// For NFC (uncomment below and add dependency if needed)
// import 'package:nfc_manager/nfc_manager.dart';

class Milestone {
  final String description;
  final int requiredTaps;
  final int rewardPoints;

  Milestone({
    required this.description,
    required this.requiredTaps,
    required this.rewardPoints,
  });
}

class LoyaltyPointsPage extends StatefulWidget {
  const LoyaltyPointsPage({super.key});

  @override
  State<LoyaltyPointsPage> createState() => _LoyaltyPointsPageState();
}

class _LoyaltyPointsPageState extends State<LoyaltyPointsPage> {
  int tapCount = 0;
  int loyaltyPoints = 0;

  final List<Milestone> milestones = [
    Milestone(description: 'First Tap!', requiredTaps: 1, rewardPoints: 10),
    Milestone(description: '5 Taps', requiredTaps: 5, rewardPoints: 20),
    Milestone(description: '10 Taps', requiredTaps: 10, rewardPoints: 30),
    Milestone(description: '25 Taps', requiredTaps: 25, rewardPoints: 50),
  ];

  final Set<String> completedMilestones = {};

  void _simulateNfcTap() {
    // This is a simulated tap — replace with real NFC logic below when using NFC
    _handleTap();

    // Example NFC logic using `nfc_manager` (requires real device):
    /*
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      NfcManager.instance.stopSession();
      _handleTap();
    });
    */
  }

  void _handleTap() {
    setState(() {
      tapCount++;
      for (final milestone in milestones) {
        if (tapCount >= milestone.requiredTaps &&
            !completedMilestones.contains(milestone.description)) {
          loyaltyPoints += milestone.rewardPoints;
          completedMilestones.add(milestone.description);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 ${milestone.description} achieved! +${milestone.rewardPoints} points'),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Loyalty Points System',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '💧 Tap Count: $tapCount',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '⭐ Loyalty Points: $loyaltyPoints',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _simulateNfcTap,
                  icon: const Icon(Icons.nfc),
                  label: const Text('Tap to Acquire Water (NFC)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFF0077B6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Milestones:', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: milestones.map((m) {
                      final achieved = completedMilestones.contains(m.description);
                      return Card(
                        color: Colors.white.withOpacity(0.9),
                        child: ListTile(
                          leading: Icon(
                            achieved ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: achieved ? Colors.green : Colors.grey,
                          ),
                          title: Text(m.description),
                          subtitle: Text('${m.requiredTaps} taps — ${m.rewardPoints} points'),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

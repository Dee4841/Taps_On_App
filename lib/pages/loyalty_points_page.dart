import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/loyalty/presentation/loyalty_provider.dart';

class LoyaltyPointsPage extends StatefulWidget {
  const LoyaltyPointsPage({super.key});

  @override
  State<LoyaltyPointsPage> createState() => _LoyaltyPointsPageState();
}

class _LoyaltyPointsPageState extends State<LoyaltyPointsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoyaltyProvider>().loadLoyalty();
    });
  }

  Future<void> _simulateNfcTap() async {
    final unlocked = await context.read<LoyaltyProvider>().recordTap();
    if (unlocked != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 ${unlocked.description} achieved! +${unlocked.rewardPoints} points'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loyaltyProvider = context.watch<LoyaltyProvider>();
    final tapCount = loyaltyProvider.tapCount;
    final loyaltyPoints = loyaltyProvider.points;
    final completedMilestones = loyaltyProvider.completedMilestones;
    final milestones = loyaltyProvider.milestones;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loyalty Points'),
      ),
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
                const Text(
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
                    foregroundColor: const Color(0xFF0077B6),
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
                        color: Colors.white.withAlpha((0.95 * 255).toInt()),
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

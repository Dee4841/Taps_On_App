import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/loyalty/presentation/loyalty_provider.dart';
import '../features/auth/presentation/auth_provider.dart';
class LoyaltyPointsPage extends StatefulWidget {
  const LoyaltyPointsPage({super.key});

  @override
  State<LoyaltyPointsPage> createState() => _LoyaltyPointsPageState();
}

class _LoyaltyPointsPageState extends State<LoyaltyPointsPage> {
  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthProvider>().currentUser?.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userId != null) context.read<LoyaltyProvider>().loadLoyalty(userId);
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
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: 
            [
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
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
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Milestones:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: milestones.map((m) {
                    final achieved = completedMilestones.contains(m.description);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: ListTile(
                        leading: Icon(
                          achieved ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: achieved ? Colors.green : Colors.grey,
                        ),
                        title: Text(
                          m.description,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
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
    );
  }
}

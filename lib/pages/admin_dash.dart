import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/presentation/auth_provider.dart';
import '../features/admin/presentation/admin_provider.dart';
import '../features/marketplace/presentation/marketplace_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadOverview();
      context.read<MarketplaceProvider>().loadItems();
    });
  }

  Color _getTankColor(int level) {
    if (level > 50) return Colors.green;
    if (level >= 20) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final marketplace = context.watch<MarketplaceProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: Colors.indigo,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<AdminProvider>().loadOverview();
                context.read<MarketplaceProvider>().loadItems();
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out',
              onPressed: () => context.read<AuthProvider>().signOut(),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.analytics), text: 'Overview & Taps'),
              Tab(icon: Icon(Icons.storefront), text: 'Marketplace'),
            ],
          ),
        ),
        body: admin.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // Tab 1: Telemetry & Taps
                  RefreshIndicator(
                    onRefresh: () =>
                        context.read<AdminProvider>().loadOverview(),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Metric Cards Row
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                title: 'Students',
                                value: '${admin.studentCount}',
                                icon: Icons.people,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MetricCard(
                                title: 'Campus Taps',
                                value: '${admin.taps.length}',
                                icon: Icons.water_drop,
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MetricCard(
                                title: 'Low Level (<20%)',
                                value: '${admin.lowWaterTapsCount}',
                                icon: Icons.warning_amber_rounded,
                                color: admin.lowWaterTapsCount > 0
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Water Taps Telemetry',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...admin.taps.map((tap) {
                          final color = _getTankColor(tap.tankLevel);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        tap.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: color.withAlpha((0.15 * 255).toInt()),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${tap.tankLevel}% Tank',
                                          style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: tap.tankLevel / 100,
                                      minHeight: 8,
                                      backgroundColor: Colors.grey[200],
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Status: ${tap.status.toUpperCase()}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // Tab 2: Marketplace Moderation
                  RefreshIndicator(
                    onRefresh: () =>
                        context.read<MarketplaceProvider>().loadItems(),
                    child: marketplace.items.isEmpty
                        ? const Center(child: Text('No marketplace items to moderate.'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: marketplace.items.length,
                            itemBuilder: (context, index) {
                              final item = marketplace.items[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  title: Text(item.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                      'Seller: ${item.sellerName} (${item.studentNumber})\nPrice: ${item.price} • ${item.location}'),
                                  isThreeLine: true,
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    tooltip: 'Remove Listing',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('Remove Listing'),
                                          content: Text(
                                              'Remove "${item.title}" from marketplace?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Delete',
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true && context.mounted) {
                                        await context
                                            .read<AdminProvider>()
                                            .deleteMarketplaceItem(item.id);
                                        if (context.mounted) {
                                          await context
                                              .read<MarketplaceProvider>()
                                              .loadItems();
                                        }
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

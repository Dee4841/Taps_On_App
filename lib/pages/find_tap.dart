import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../features/taps/domain/tap_model.dart';
import '../features/taps/presentation/taps_provider.dart';

class FindTapPage extends StatefulWidget {
  const FindTapPage({super.key});

  @override
  State<FindTapPage> createState() => _FindTapPageState();
}

class _FindTapPageState extends State<FindTapPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TapsProvider>().loadTaps();
    });
  }

  Color _getTankColor(int level) {
    if (level > 50) return Colors.green;
    if (level >= 20) return Colors.orange;
    return Colors.red;
  }

  void _showTapDetails(BuildContext context, TapModel tap) {
    final color = _getTankColor(tap.tankLevel);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tap.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.water_drop, color: color),
                const SizedBox(width: 8),
                Text(
                  'Tank: ${tap.tankLevel}% capacity',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Status: ${tap.status.toUpperCase()}'),
            const SizedBox(height: 4),
            Text('Coordinates: ${tap.latitude.toStringAsFixed(4)}, ${tap.longitude.toStringAsFixed(4)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tapsProvider = context.watch<TapsProvider>();
    final taps = tapsProvider.taps;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Tap'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<TapsProvider>().loadTaps(),
          ),
        ],
      ),
      body: tapsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(-26.1900, 28.0180),
                initialZoom: 13.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.tapsonapp.app',
                ),
                MarkerLayer(
                  markers: taps.map((tap) {
                    final color = _getTankColor(tap.tankLevel);
                    return Marker(
                      width: 50,
                      height: 50,
                      point: LatLng(tap.latitude, tap.longitude),
                      child: GestureDetector(
                        onTap: () => _showTapDetails(context, tap),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/icons/tap_icon.png',
                              width: 40,
                              height: 40,
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: CircleAvatar(
                                radius: 5,
                                backgroundColor: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}

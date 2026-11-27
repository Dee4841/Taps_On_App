import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../features/taps/domain/tap_model.dart';
import '../features/taps/presentation/taps_provider.dart';

class FindTapPage extends StatefulWidget {
  final bool showAppBar;
  const FindTapPage({super.key, this.showAppBar = true});

  @override
  State<FindTapPage> createState() => _FindTapPageState();
}

class _FindTapPageState extends State<FindTapPage> {
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  TapModel? _selectedTap;
  bool _cardVisible = false;

  static const LatLng _defaultCenter = LatLng(-26.1900, 28.0180);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TapsProvider>().loadTaps();
      _fetchLocation();
    });
  }

  Future<void> _fetchLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) return;

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;
      setState(() => _userLocation = LatLng(pos.latitude, pos.longitude));
      _mapController.move(_userLocation!, 15);
    } catch (_) {
      // No GPS — map stays at default center
    }
  }


  Color _levelColor(int level) {
    if (level > 50) return Colors.green;
    if (level >= 20) return Colors.orange;
    return Colors.red;
  }

  double _distanceKm(TapModel tap) {
    if (_userLocation == null) return double.infinity;
    final d = const Distance();
    return d.as(LengthUnit.Kilometer, _userLocation!, LatLng(tap.latitude, tap.longitude));
  }

  TapModel? _nearestTap(List<TapModel> taps) {
    if (_userLocation == null || taps.isEmpty) return null;
    return taps.reduce((a, b) => _distanceKm(a) < _distanceKm(b) ? a : b);
  }

  void _selectTap(TapModel tap) {
    setState(() {
      _selectedTap = tap;
      _cardVisible = true;
    });
  }

  void _dismissCard() => setState(() => _cardVisible = false);

  Future<void> _openDirections(TapModel tap) async {
    final lat = tap.latitude;
    final lng = tap.longitude;
    final name = Uri.encodeComponent(tap.name);

    final Uri uri;
    if (Platform.isIOS) {
      uri = Uri.parse('https://maps.apple.com/?daddr=$lat,$lng&dirflg=w');
    } else {
      uri = Uri.parse('geo:$lat,$lng?q=$lat,$lng($name)');
    }

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Fallback to Google Maps web
      await launchUrl(
        Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng'),
        mode: LaunchMode.externalApplication,
      );
    }
  }


  void _showTapList(List<TapModel> taps) {
    final sorted = [...taps]..sort((a, b) => _distanceKm(a).compareTo(_distanceKm(b)));

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Taps near you', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sorted.length,
              itemBuilder: (_, i) {
                final tap = sorted[i];
                final dist = _distanceKm(tap);
                final color = _levelColor(tap.tankLevel);
                return ListTile(
                  leading: CircleAvatar(
                    radius: 10,
                    backgroundColor: color,
                  ),
                  title: Text(tap.name),
                  subtitle: Text('${tap.tankLevel}% · ${tap.status.toUpperCase()}'),
                  trailing: dist.isFinite
                      ? Text('${dist.toStringAsFixed(1)} km', style: const TextStyle(color: Colors.grey))
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    _mapController.move(LatLng(tap.latitude, tap.longitude), 16);
                    _selectTap(tap);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _floatingCard(TapModel tap) {
    final color = _levelColor(tap.tankLevel);
    final dist = _distanceKm(tap);

    return AnimatedSlide(
      offset: _cardVisible ? Offset.zero : const Offset(0, 1.5),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: _cardVisible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      const Icon(Icons.water_drop, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tap.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color),
                        ),
                        child: Text(
                          tap.status.toUpperCase(),
                          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: _dismissCard,
                        child: const Icon(Icons.close, size: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Tank level bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: tap.tankLevel / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${tap.tankLevel}%',
                        style: TextStyle(fontWeight: FontWeight.w600, color: color),
                      ),
                    ],
                  ),
                  if (dist.isFinite) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.place, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${dist.toStringAsFixed(2)} km away',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Directions button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openDirections(tap),
                      icon: const Icon(Icons.directions),
                      label: const Text('Get Directions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tapsProvider = context.watch<TapsProvider>();
    final taps = tapsProvider.taps;
    final nearest = _nearestTap(taps);

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Find Tap'),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => context.read<TapsProvider>().loadTaps(),
                ),
              ],
            )
          : null,
      body: tapsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // ── Map ───────────────────────────────────────────────────
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _userLocation ?? _defaultCenter,
                    initialZoom: 14,
                    onTap: (_, _) => _dismissCard(),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.tapsonapp.app',
                    ),
                    // Nearest tap pulse ring
                    if (nearest != null)
                      CircleLayer(circles: [
                        CircleMarker(
                          point: LatLng(nearest.latitude, nearest.longitude),
                          radius: 28,
                          color: Colors.green.withAlpha(40),
                          borderColor: Colors.green,
                          borderStrokeWidth: 2,
                          useRadiusInMeter: false,
                        ),
                      ]),
                    // User blue dot
                    if (_userLocation != null)
                      CircleLayer(circles: [
                        CircleMarker(
                          point: _userLocation!,
                          radius: 10,
                          color: Colors.blue.withAlpha(60),
                          borderColor: Colors.blue,
                          borderStrokeWidth: 2,
                          useRadiusInMeter: false,
                        ),
                        CircleMarker(
                          point: _userLocation!,
                          radius: 5,
                          color: Colors.blue,
                          useRadiusInMeter: false,
                        ),
                      ]),
                    // Tap markers
                    MarkerLayer(
                      markers: taps.map((tap) {
                        final color = _levelColor(tap.tankLevel);
                        final isSelected = _selectedTap?.id == tap.id;
                        return Marker(
                          width: 50,
                          height: 50,
                          point: LatLng(tap.latitude, tap.longitude),
                          child: GestureDetector(
                            onTap: () => _selectTap(tap),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (isSelected)
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color.withAlpha(40),
                                      border: Border.all(color: color, width: 2),
                                    ),
                                  ),
                                Image.asset('assets/icons/tap_icon.png', width: 32, height: 32),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: CircleAvatar(radius: 5, backgroundColor: color),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // ── Floating card (bottom, slides in) ─────────────────────
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _selectedTap != null
                      ? _floatingCard(_selectedTap!)
                      : const SizedBox.shrink(),
                ),

                // ── FABs (my location + tap list) ─────────────────────────
                Positioned(
                  right: 16,
                  bottom: _cardVisible ? 210 : 80,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOut,
                    child: Column(
                      children: [
                        if (_userLocation != null)
                          FloatingActionButton.small(
                            heroTag: 'my_location',
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue,
                            onPressed: () => _mapController.move(_userLocation!, 15),
                            child: const Icon(Icons.my_location),
                          ),
                        const SizedBox(height: 8),
                        FloatingActionButton(
                          heroTag: 'tap_list',
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          onPressed: () => _showTapList(taps),
                          child: const Icon(Icons.format_list_bulleted),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

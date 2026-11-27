import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/location_model.dart';
import '../../services/gps_policy.dart';

/// Choose an actual map coordinate for a pickup or destination.
/// Selecting a point does not share live GPS location with Firestore.
class LocationPickerScreen extends StatefulWidget {
  final String title;
  final LocationModel? initialSelection;
  final LocationModel? centerNear;
  final bool useGpsOnOpen;

  const LocationPickerScreen({
    super.key,
    required this.title,
    this.initialSelection,
    this.centerNear,
    this.useGpsOnOpen = false,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  // Initial map view (Colombo), not the device's actual location.
  static const LatLng _initialCenter = LatLng(6.9271, 79.8612);

  final MapController _mapController = MapController();
  LatLng? _selected;
  bool _locating = false;
  bool _mapReady = false;
  int _selectionVersion = 0;
  String? _gpsMessage;
  double? _gpsAccuracy;

  LatLng? _pointFor(LocationModel? location) {
    if (location == null ||
        !GpsPolicy.validCoordinates(location.latitude, location.longitude)) {
      return null;
    }
    return LatLng(location.latitude!, location.longitude!);
  }

  @override
  void initState() {
    super.initState();
    _selected = _pointFor(widget.initialSelection);
  }

  void _onMapReady() {
    if (!mounted) return;
    setState(() => _mapReady = true);
    if (widget.useGpsOnOpen && _selected == null) {
      unawaited(_useCurrentLocation());
    }
  }

  void _selectOnMap(LatLng point) {
    _selectionVersion++;
    setState(() {
      _selected = point;
      _gpsAccuracy = null;
      _gpsMessage =
          'Map pin selected manually. Check that it is at the correct place.';
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    if (_locating || !_mapReady) return;
    final version = ++_selectionVersion;
    setState(() {
      _locating = true;
      _gpsMessage = 'Getting a fresh GPS location...';
    });
    try {
      final position = await GpsPolicy.currentPosition();
      if (!mounted || version != _selectionVersion) return;
      final point = LatLng(position.latitude, position.longitude);
      if (!GpsPolicy.usable(
        position,
        maxAccuracy: GpsPolicy.maxPickupAccuracyMeters,
      )) {
        setState(() {
          _gpsAccuracy = null;
          _gpsMessage =
              'GPS is too imprecise (${position.accuracy.toStringAsFixed(0)} m). Enable precise location, retry, or tap the correct point on the map.';
        });
        _mapController.move(point, 16);
        return;
      }
      setState(() {
        _selected = point;
        _gpsAccuracy = position.accuracy;
        _gpsMessage = position.isMocked
            ? 'Device is supplying a simulated location. Verify the pin before confirming.'
            : 'GPS location selected. Check the pin before confirming.';
      });
      _mapController.move(point, 17);
    } catch (error) {
      if (!mounted || version != _selectionVersion) return;
      final message = error is StateError
          ? error.message
          : error is TimeoutException
          ? 'GPS timed out. Try again outdoors or tap the map.'
          : 'GPS unavailable. Check location permissions, then retry or tap the map.';
      setState(() => _gpsMessage = message);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _confirmSelection() {
    final point = _selected;
    if (point == null || _locating) return;

    // Coordinates are accurate, but a reverse-geocoding service is needed
    // to show a human-readable street address.
    final label =
        '${point.latitude.toStringAsFixed(5)}, '
        '${point.longitude.toStringAsFixed(5)}';
    Navigator.pop(
      context,
      LocationModel(
        name: label,
        address: null,
        latitude: point.latitude,
        longitude: point.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Tap the exact pickup or destination on the map, or use the GPS button.',
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Use my current location',
                    onPressed: _locating || !_mapReady
                        ? null
                        : _useCurrentLocation,
                    icon: _locating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter:
                          _selected ??
                          _pointFor(widget.centerNear) ??
                          _initialCenter,
                      initialZoom:
                          _selected != null ||
                              _pointFor(widget.centerNear) != null
                          ? 16
                          : 12,
                      onMapReady: _onMapReady,
                      onTap: (_, point) => _selectOnMap(point),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'oneclick',
                      ),
                      if (_selected != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selected!,
                              width: 34,
                              height: 34,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.gps_fixed_rounded,
                                size: 32,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface
                            .withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        child: Text(
                          '© OpenStreetMap contributors · openstreetmap.org/copyright',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _selected == null
                        ? 'No location selected'
                        : 'Selected: ${_selected!.latitude.toStringAsFixed(5)}, '
                              '${_selected!.longitude.toStringAsFixed(5)}',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  if (_gpsAccuracy != null)
                    Text(
                      'GPS accuracy: ±${_gpsAccuracy!.toStringAsFixed(0)} m',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  if (_gpsMessage != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _gpsMessage!,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _selected == null || _locating
                        ? null
                        : _confirmSelection,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Confirm Location'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

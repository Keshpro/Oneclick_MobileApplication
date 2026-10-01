import 'package:flutter/material.dart';

import '../../models/location_model.dart';
import '../../services/location_service.dart';
import '../../theme/drunk_drive_colors.dart';

class LocationPickerScreen extends StatefulWidget {
  final String title;

  const LocationPickerScreen({super.key, required this.title});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();

  List<LocationModel> _results = [];

  @override
  void initState() {
    super.initState();
    _results = _locationService.getMockLocations();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _results = _locationService.searchLocations(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DrunkDriveColors.background,
      appBar: AppBar(
        backgroundColor: DrunkDriveColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search for a location',
                  hintStyle: const TextStyle(color: DrunkDriveColors.textMuted),
                  prefixIcon: const Icon(Icons.search_rounded, color: DrunkDriveColors.textMuted),
                  filled: true,
                  fillColor: DrunkDriveColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _results.isEmpty
                  ? const Center(
                      child: Text(
                        'No matching locations.',
                        style: TextStyle(color: DrunkDriveColors.textMuted),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _results.length,
                      separatorBuilder: (_, _) =>
                          const Divider(color: DrunkDriveColors.surfaceBorder, height: 1),
                      itemBuilder: (context, index) {
                        final location = _results[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.location_on_outlined, color: DrunkDriveColors.accent),
                          title: Text(
                            location.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          subtitle: location.address != null
                              ? Text(
                                  location.address!,
                                  style: const TextStyle(color: DrunkDriveColors.textMuted, fontSize: 12),
                                )
                              : null,
                          onTap: () => Navigator.pop(context, location),
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
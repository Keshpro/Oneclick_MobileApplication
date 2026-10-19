import 'package:flutter/material.dart';

import '../../models/location_model.dart';
import '../../services/location_service.dart';

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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? const Color(0xFF101418) : Colors.white;

    final surfaceColor = isDark
        ? const Color(0xFF1B2329)
        : const Color(0xFFF4F7F7);

    final textColor = isDark ? Colors.white : const Color(0xFF17252A);

    final mutedColor = isDark ? Colors.white70 : const Color(0xFF60747A);

    final borderColor = isDark
        ? const Color(0xFF35444A)
        : const Color(0xFFE1E8E8);

    final accentColor = colors.primary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        title: Text(
          widget.title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: textColor),
                cursorColor: accentColor,
                decoration: InputDecoration(
                  hintText: 'Search for a location',
                  hintStyle: TextStyle(color: mutedColor),
                  prefixIcon: Icon(Icons.search_rounded, color: mutedColor),
                  filled: true,
                  fillColor: surfaceColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: accentColor, width: 1.5),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Text(
                        'No matching locations.',
                        style: TextStyle(color: mutedColor),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _results.length,
                      separatorBuilder: (_, _) =>
                          Divider(color: borderColor, height: 1),
                      itemBuilder: (context, index) {
                        final location = _results[index];

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 5,
                          ),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.location_on_outlined,
                              color: accentColor,
                            ),
                          ),
                          title: Text(
                            location.name,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: location.address != null
                              ? Text(
                                  location.address!,
                                  style: TextStyle(
                                    color: mutedColor,
                                    fontSize: 12,
                                  ),
                                )
                              : null,
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: mutedColor,
                          ),
                          onTap: () {
                            Navigator.pop(context, location);
                          },
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

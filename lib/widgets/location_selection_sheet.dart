import 'dart:async';
import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../helpers/font_helper.dart';
import '../services/location_service.dart';

class LocationSelectionSheet extends StatefulWidget {
  final LocationService locationService;
  final String initialLocation;
  final ValueChanged<String?> onLocationSelected;

  const LocationSelectionSheet({
    super.key,
    required this.locationService,
    required this.initialLocation,
    required this.onLocationSelected,
  });

  @override
  State<LocationSelectionSheet> createState() => _LocationSelectionSheetState();
}

class _LocationSelectionSheetState extends State<LocationSelectionSheet> {
  late final TextEditingController _searchController;
  bool _isDetecting = false;
  bool _isLoadingSuggestions = false;
  List<String> _suggestions = [];
  Timer? _debounceTimer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialLocation);
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    final query = _searchController.text;
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      if (query.trim().isEmpty) {
        setState(() {
          _suggestions = const [];
          _isLoadingSuggestions = false;
        });
        return;
      }

      setState(() {
        _isLoadingSuggestions = true;
        _errorMessage = null;
      });

      try {
        final results = await widget.locationService.getAddressSuggestions(
          query,
        );
        if (mounted) {
          setState(() {
            _suggestions = results;
            _isLoadingSuggestions = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingSuggestions = false;
            _errorMessage = 'Failed to fetch suggestions';
          });
        }
      }
    });
  }

  Future<void> _detectLocation() async {
    setState(() {
      _isDetecting = true;
      _errorMessage = null;
    });

    try {
      final name = await widget.locationService.getCurrentLocationName();
      if (mounted) {
        if (name != null && name.isNotEmpty) {
          _searchController.text = name;
        } else {
          setState(() {
            _errorMessage = 'Could not detect location. Please type manually.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error detecting location.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDetecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Material(
      color: colorScheme.surface,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(AppTheme.borderRadiusLarge),
        topRight: Radius.circular(AppTheme.borderRadiusLarge),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: AppTheme.spacingMedium,
          right: AppTheme.spacingMedium,
          top: AppTheme.spacingSmall,
          bottom: viewInsets.bottom + AppTheme.spacingLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Center(
              child: Text(
                'Add Location',
                style: safeGoogleFont(
                  'IBM Plex Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),

            // Search Field
            TextField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                widget.onLocationSelected(_searchController.text.trim());
                Navigator.of(context).pop();
              },
              decoration: InputDecoration(
                hintText: 'Search or enter address...',
                hintStyle: safeGoogleFont(
                  'IBM Plex Sans',
                  color: colorScheme.onSurface.withValues(
                    alpha: AppTheme.opacityHint,
                  ),
                ),
                prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _suggestions = const [];
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMedium,
                  vertical: AppTheme.spacingSmall,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusMedium,
                  ),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusMedium,
                  ),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
              style: safeGoogleFont(
                'IBM Plex Sans',
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSmall),

            // Error Message
            if (_errorMessage != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  _errorMessage!,
                  style: safeGoogleFont(
                    'IBM Plex Sans',
                    fontSize: 12,
                    color: colorScheme.error,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
            ],

            // GPS Detection Button
            InkWell(
              onTap: _isDetecting ? null : _detectLocation,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: Row(
                  children: [
                    _isDetecting
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.my_location,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                    const SizedBox(width: AppTheme.spacingSmall),
                    Expanded(
                      child: Text(
                        _isDetecting
                            ? 'Detecting location...'
                            : 'Use current location',
                        style: safeGoogleFont(
                          'IBM Plex Sans',
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 16),

            // Suggestions list / loader
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: _isLoadingSuggestions
                  ? const Padding(
                      padding: EdgeInsets.all(AppTheme.spacingMedium),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      ),
                    )
                  : _suggestions.isEmpty
                  ? (widget.initialLocation.isEmpty &&
                            _searchController.text.trim().isEmpty
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.all(
                              AppTheme.spacingSmall,
                            ),
                            child: Text(
                              _searchController.text.isEmpty
                                  ? 'Type to search for location suggestions'
                                  : 'No suggestions found. Press Save to use typed address.',
                              style: safeGoogleFont(
                                'IBM Plex Sans',
                                fontSize: 13,
                                color: colorScheme.onSurface.withValues(
                                  alpha: AppTheme.opacitySubtle,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        return ListTile(
                          leading: Icon(
                            Icons.location_on_outlined,
                            color: colorScheme.onSurface.withValues(
                              alpha: AppTheme.opacityMedium,
                            ),
                            size: 18,
                          ),
                          title: Text(
                            suggestion,
                            style: safeGoogleFont(
                              'IBM Plex Sans',
                              fontSize: 14,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingSmall,
                          ),
                          onTap: () {
                            setState(() {
                              _searchController.text = suggestion;
                              _suggestions = const [];
                            });
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    widget.onLocationSelected(null);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Clear',
                    style: safeGoogleFont(
                      'IBM Plex Sans',
                      color: colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSmall),
                ElevatedButton(
                  onPressed: () {
                    final text = _searchController.text.trim();
                    widget.onLocationSelected(text.isEmpty ? null : text);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

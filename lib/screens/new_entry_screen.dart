import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../helpers/font_helper.dart';
import '../models/diary_entry.dart';
import '../config/app_theme.dart';
import '../services/location_service.dart';
import '../widgets/location_selection_sheet.dart';

class NewEntryScreen extends StatefulWidget {
  final DiaryEntry? entry;
  final LocationService? locationService;

  const NewEntryScreen({super.key, this.entry, this.locationService});

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  late final TextEditingController _controller;
  late final TextEditingController _locationController;
  late DateTime _entryDate;
  late String _mood;
  late final LocationService _locationService;

  @override
  void initState() {
    super.initState();
    _locationService = widget.locationService ?? GeolocatorLocationService();
    _controller = TextEditingController(text: widget.entry?.content);
    _locationController = TextEditingController(text: widget.entry?.location);
    _entryDate = widget.entry?.date ?? DateTime.now();
    _mood = widget.entry?.mood ?? '📝';
  }

  @override
  void dispose() {
    _controller.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.entry == null ? 'New Entry' : '',
          style: safeGoogleFont(
            'IBM Plex Sans',
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(_buildEntry());
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
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppTheme.spacingMedium),
                  Text(
                    DateFormat('MMM dd, yyyy').format(_entryDate),
                    style: safeGoogleFont(
                      'IBM Plex Sans',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingExtraSmall),
                  InkWell(
                    onTap: _pickDateTime,
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusSmall,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            DateFormat('h:mm a').format(_entryDate),
                            style: safeGoogleFont(
                              'IBM Plex Sans',
                              fontSize: 18,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '•',
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          Text(
                            DateFormat('EEEE').format(_entryDate),
                            style: safeGoogleFont(
                              'IBM Plex Sans',
                              fontSize: 18,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.edit_calendar_outlined,
                            size: 18,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_locationController.text.trim().isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacingSmall),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _locationController.text.trim(),
                            style: safeGoogleFont(
                              'IBM Plex Sans',
                              fontSize: 14,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppTheme.spacingLarge),
                  TextField(
                    controller: _controller,
                    maxLines: null,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Write your heart out...',
                      hintStyle: safeGoogleFont(
                        'IBM Plex Sans',
                        fontSize: 18,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      border: InputBorder.none,
                    ),
                    style: safeGoogleFont(
                      'IBM Plex Sans',
                      fontSize: 18,
                      color: colorScheme.onSurface,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: colorScheme.background.withValues(alpha: 0.9),
              border: Border(
                top: BorderSide(
                  color: colorScheme.onSurface.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => _showUnavailableMessage(
                          'Image attachments are not available yet.',
                        ),
                        child: Icon(
                          Icons.image_outlined,
                          color: colorScheme.primary,
                        ),
                      ),
                      InkWell(
                        onTap: () => _showUnavailableMessage(
                          'Tags are not available yet.',
                        ),
                        child: Icon(
                          Icons.label_outlined,
                          color: colorScheme.primary,
                        ),
                      ),
                      InkWell(
                        onTap: _pickMood,
                        child: Icon(
                          Icons.mood_outlined,
                          color: colorScheme.primary,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                      InkWell(
                        onTap: _editLocation,
                        child: Icon(
                          Icons.location_on_outlined,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Saved locally',
                      key: const ValueKey('entry-save-status'),
                      style: safeGoogleFont(
                        'IBM Plex Sans',
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DiaryEntry _buildEntry() {
    final content = _controller.text.trim();
    final existingEntry = widget.entry;

    return DiaryEntry(
      id: existingEntry?.id ?? const Uuid().v4(),
      date: _entryDate,
      title: _titleFromContent(content),
      content: content,
      mood: _mood,
      location: _emptyToNull(_locationController.text),
      imageUrls: existingEntry?.imageUrls ?? const [],
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _entryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_entryDate),
    );
    if (pickedTime == null || !mounted) return;

    setState(() {
      _entryDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _pickMood() async {
    final selectedMood = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        const moods = ['📝', '☕', '🚀', '😊', '😌', '😢', '😤', '🎉'];
        return GridView.count(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          crossAxisCount: 4,
          shrinkWrap: true,
          children: [
            for (final mood in moods)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => Navigator.of(context).pop(mood),
                child: Center(
                  child: Text(mood, style: const TextStyle(fontSize: 32)),
                ),
              ),
          ],
        );
      },
    );
    if (selectedMood == null) return;
    setState(() {
      _mood = selectedMood;
    });
  }

  Future<void> _editLocation() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return LocationSelectionSheet(
          locationService: _locationService,
          initialLocation: _locationController.text,
          onLocationSelected: (result) {
            if (mounted) {
              setState(() {
                _locationController.text = result ?? '';
              });
            }
          },
        );
      },
    );
  }

  void _showUnavailableMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _titleFromContent(String content) {
    if (content.isEmpty) {
      return 'Untitled Entry';
    }

    return content.split('\n').first.trim();
  }
}

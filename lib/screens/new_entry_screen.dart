import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../helpers/font_helper.dart';
import '../helpers/page_transitions.dart';
import '../models/diary_entry.dart';
import '../config/app_theme.dart';
import '../services/location_service.dart';
import '../widgets/location_selection_sheet.dart';

class NewEntryScreen extends StatefulWidget {
  final DiaryEntry? entry;
  final List<String> existingTags;
  final LocationService? locationService;
  final DateTime? initialDate;

  const NewEntryScreen({
    super.key,
    this.entry,
    this.existingTags = const [],
    this.locationService,
    this.initialDate,
  });

  static const String routeName = '/new-entry';

  static Route<DiaryEntry> route({
    DiaryEntry? entry,
    List<String> existingTags = const [],
    LocationService? locationService,
  }) {
    return SmoothPageRoute<DiaryEntry>(
      child: NewEntryScreen(
        entry: entry,
        existingTags: existingTags,
        locationService: locationService,
      ),
      direction: SlideDirection.bottomToTop,
      settings: const RouteSettings(name: routeName),
    );
  }

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  static const String _defaultMood = '📝';

  late final TextEditingController _controller;
  late final TextEditingController _locationController;
  late final TextEditingController _tagInputController;
  late final DateTime _initialEntryDate;
  late DateTime _entryDate;
  late String _mood;
  late List<String> _tags;
  late final LocationService _locationService;
  bool _isSavingOrDiscarding = false;

  @override
  void initState() {
    super.initState();
    _locationService = widget.locationService ?? GeolocatorLocationService();
    _controller = TextEditingController(text: widget.entry?.content);
    _locationController = TextEditingController(text: widget.entry?.location);
    _tagInputController = TextEditingController();
    _initialEntryDate =
        widget.entry?.date ?? widget.initialDate ?? DateTime.now();
    _entryDate = _initialEntryDate;
    _mood = widget.entry?.mood ?? _defaultMood;
    _tags = List.from(widget.entry?.tags ?? []);

    _controller.addListener(_onFieldChanged);
    _locationController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onFieldChanged);
    _locationController.removeListener(_onFieldChanged);
    _controller.dispose();
    _locationController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: !_hasUnsavedChanges(),
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldDiscard = await _showUnsavedChangesDialog();
        if (shouldDiscard && context.mounted) {
          setState(() {
            _isSavingOrDiscarding = true;
          });
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () => Navigator.of(context).maybePop(),
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
                  setState(() {
                    _isSavingOrDiscarding = true;
                  });
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
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
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
                    if (_tags.isNotEmpty) ...[
                      const SizedBox(height: AppTheme.spacingSmall),
                      Wrap(
                        spacing: AppTheme.spacingSmall,
                        runSpacing: AppTheme.spacingSmall,
                        children: _tags.map((tag) {
                          return InputChip(
                            label: Text(
                              tag,
                              style:
                                  (Theme.of(context).textTheme.labelMedium ??
                                          const TextStyle())
                                      .copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                            ),
                            backgroundColor: colorScheme.primaryContainer,
                            deleteIcon: Icon(
                              Icons.close,
                              size: 14,
                              color: colorScheme.onPrimaryContainer,
                            ),
                            onDeleted: () {
                              setState(() {
                                _tags.remove(tag);
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusLarge,
                              ),
                              side: BorderSide.none,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingExtraSmall,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
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
                color: colorScheme.surface.withValues(alpha: 0.9),
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
                          onTap: _editTags,
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
      tags: _tags,
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

  Future<void> _editTags() async {
    _tagInputController.clear();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;

            final suggestedTags = widget.existingTags
                .where((tag) => !_tags.contains(tag))
                .toList();

            void addTag(String value) {
              final trimmed = value.trim();
              if (trimmed.isNotEmpty && !_tags.contains(trimmed)) {
                setState(() {
                  _tags.add(trimmed);
                });
                setSheetState(() {});
                _tagInputController.clear();
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: AppTheme.spacingLarge,
                right: AppTheme.spacingLarge,
                top: AppTheme.spacingSmall,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom +
                    AppTheme.spacingLarge,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Tags',
                    style: (theme.textTheme.titleLarge ?? const TextStyle())
                        .copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tagInputController,
                          decoration: InputDecoration(
                            hintText: 'Enter tag name...',
                            hintStyle:
                                (theme.textTheme.bodyMedium ??
                                        const TextStyle())
                                    .copyWith(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusMedium,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingMedium,
                              vertical:
                                  AppTheme.spacingSmall +
                                  AppTheme.spacingExtraSmall,
                            ),
                          ),
                          onSubmitted: addTag,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMedium),
                      ElevatedButton(
                        onPressed: () => addTag(_tagInputController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusMedium,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingMedium,
                            vertical:
                                AppTheme.spacingSmall +
                                AppTheme.spacingExtraSmall,
                          ),
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  if (_tags.isNotEmpty) ...[
                    Text(
                      'Selected Tags',
                      style: (theme.textTheme.titleSmall ?? const TextStyle())
                          .copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingSmall),
                    Wrap(
                      spacing: AppTheme.spacingSmall,
                      runSpacing: AppTheme.spacingSmall,
                      children: _tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          onDeleted: () {
                            setState(() {
                              _tags.remove(tag);
                            });
                            setSheetState(() {});
                          },
                          backgroundColor: colorScheme.primaryContainer,
                          labelStyle:
                              (theme.textTheme.labelMedium ?? const TextStyle())
                                  .copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                          deleteIconColor: colorScheme.onPrimaryContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusLarge,
                            ),
                            side: BorderSide.none,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppTheme.spacingLarge),
                  ],
                  if (suggestedTags.isNotEmpty) ...[
                    Text(
                      'Suggested Tags',
                      style: (theme.textTheme.titleSmall ?? const TextStyle())
                          .copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingSmall),
                    Wrap(
                      spacing: AppTheme.spacingSmall,
                      runSpacing: AppTheme.spacingSmall,
                      children: suggestedTags.map((tag) {
                        return ActionChip(
                          label: Text(tag),
                          onPressed: () {
                            setState(() {
                              _tags.add(tag);
                            });
                            setSheetState(() {});
                          },
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          labelStyle:
                              (theme.textTheme.labelMedium ?? const TextStyle())
                                  .copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusLarge,
                            ),
                            side: BorderSide.none,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppTheme.spacingLarge),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Done',
                          style:
                              (theme.textTheme.labelLarge ?? const TextStyle())
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  bool _hasUnsavedChanges() {
    if (_isSavingOrDiscarding) return false;
    final currentContent = _controller.text;
    final currentLocation = _locationController.text;
    final currentMood = _mood;
    final currentTags = _tags;
    final currentDate = _entryDate;

    if (widget.entry == null) {
      final isDateChanged = currentDate != _initialEntryDate;
      final isContentNotEmpty = currentContent.trim().isNotEmpty;
      final isLocationNotEmpty = currentLocation.trim().isNotEmpty;
      final isTagsNotEmpty = currentTags.isNotEmpty;
      final isMoodChanged = currentMood != _defaultMood;

      return isContentNotEmpty ||
          isLocationNotEmpty ||
          isTagsNotEmpty ||
          isMoodChanged ||
          isDateChanged;
    } else {
      final existingEntry = widget.entry!;
      final isContentChanged =
          currentContent.trim() != existingEntry.content.trim();
      final existingLocation = existingEntry.location ?? '';
      final isLocationChanged =
          currentLocation.trim() != existingLocation.trim();
      final isMoodChanged = currentMood != existingEntry.mood;
      final isDateChanged = currentDate != existingEntry.date;
      final isTagsChanged = !_areTagsEqual(currentTags, existingEntry.tags);

      return isContentChanged ||
          isLocationChanged ||
          isMoodChanged ||
          isDateChanged ||
          isTagsChanged;
    }
  }

  bool _areTagsEqual(List<String> list1, List<String> list2) {
    final set1 = list1.toSet();
    final set2 = list2.toSet();
    return set1.length == set2.length && set1.containsAll(set2);
  }

  Future<bool> _showUnsavedChangesDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final textTheme = theme.textTheme;

        return AlertDialog(
          title: Text(
            'Unsaved Changes',
            style: (textTheme.titleLarge ?? const TextStyle()).copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            'You have unsaved changes. Are you sure you want to discard them?',
            style: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Keep Editing',
                style: (textTheme.labelLarge ?? const TextStyle()).copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Discard',
                style: (textTheme.labelLarge ?? const TextStyle()).copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}

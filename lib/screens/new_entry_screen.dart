import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../helpers/font_helper.dart';
import '../helpers/page_transitions.dart';
import '../models/diary_entry.dart';
import '../config/app_theme.dart';
import '../config/app_strings.dart';
import '../services/location_service.dart';
import '../services/speech_service.dart';
import '../widgets/location_selection_sheet.dart';

class NewEntryScreen extends StatefulWidget {
  final DiaryEntry? entry;
  final List<String> existingTags;
  final LocationService? locationService;
  final SpeechService? speechService;
  final DateTime? initialDate;

  const NewEntryScreen({
    super.key,
    this.entry,
    this.existingTags = const [],
    this.locationService,
    this.speechService,
    this.initialDate,
  });

  static const String routeName = '/new-entry';

  static Route<DiaryEntry> route({
    DiaryEntry? entry,
    List<String> existingTags = const [],
    LocationService? locationService,
    SpeechService? speechService,
  }) {
    return SmoothPageRoute<DiaryEntry>(
      child: NewEntryScreen(
        entry: entry,
        existingTags: existingTags,
        locationService: locationService,
        speechService: speechService,
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

  late final TextEditingController _titleController;
  late final TextEditingController _controller;
  late final TextEditingController _locationController;
  late final TextEditingController _tagInputController;
  late final DateTime _initialEntryDate;
  late DateTime _entryDate;
  late String _mood;
  late List<String> _tags;
  late List<String> _imageUrls;
  late final LocationService _locationService;
  late final SpeechService _speechService;
  bool _isSavingOrDiscarding = false;

  // Dictation variables
  bool _isListening = false;
  bool _isDictating = false;
  double _soundLevel = 0.0;
  int _dictationStartIndex = 0;
  int _lastRecognizedLength = 0;
  int _dictationSessionId = 0;

  @override
  void initState() {
    super.initState();
    _locationService = widget.locationService ?? GeolocatorLocationService();
    _speechService = widget.speechService ?? SpeechToTextService();
    _titleController = TextEditingController(text: widget.entry?.title);
    _controller = TextEditingController(text: widget.entry?.content);
    _locationController = TextEditingController(text: widget.entry?.location);
    _tagInputController = TextEditingController();
    _initialEntryDate =
        widget.entry?.date ?? widget.initialDate ?? DateTime.now();
    _entryDate = _initialEntryDate;
    _mood = widget.entry?.mood ?? _defaultMood;
    _tags = List.from(widget.entry?.tags ?? []);
    _imageUrls = List.from(widget.entry?.imageUrls ?? []);

    _titleController.addListener(_onFieldChanged);
    _controller.addListener(_onFieldChanged);
    _locationController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    if (_isListening || _isDictating) {
      _isDictating = false;
      _speechService.stopListening();
    }
    _titleController.removeListener(_onFieldChanged);
    _controller.removeListener(_onFieldChanged);
    _locationController.removeListener(_onFieldChanged);
    _titleController.dispose();
    _controller.dispose();
    _locationController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final colorScheme = theme.colorScheme;
    final primary = colorScheme.primary;

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
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Custom Compose Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppTheme.getCardBackground(
                            brightness,
                            'lilac',
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_back,
                            size: 18,
                            color: AppTheme.getMutedColor(brightness),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          widget.entry == null ? 'New Entry' : '',
                          style: safeGoogleFont(
                            'Quicksand',
                            color: AppTheme.getHeadingColor(brightness),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Saved locally',
                          style: safeGoogleFont(
                            'Quicksand',
                            fontSize: 11,
                            color: AppTheme.getFaintColor(brightness),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSavingOrDiscarding = true;
                        });
                        Navigator.of(context).pop(_buildEntry());
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppTheme.getAccentGradient('lilac'),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Text(
                          'Save',
                          style: safeGoogleFont(
                            'Quicksand',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mood selection block
                      Text(
                        "HOW ARE YOU FEELING?",
                        style: safeGoogleFont(
                          'Space Mono',
                          color: AppTheme.getFaintColor(brightness),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMoodButton('😊', 'happy'),
                          _buildMoodButton('😌', 'calm'),
                          _buildMoodButton('😍', 'love'),
                          _buildMoodButton('😔', 'down'),
                          _buildMoodButton('😴', 'tired'),
                          _buildMoodButton('🥳', 'proud'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Formatting Toolbar (Visual Placeholder)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 2,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppTheme.getHairlineColor(brightness),
                            ),
                          ),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            _buildToolbarIcon('B', true, false),
                            const SizedBox(width: 6),
                            _buildToolbarIcon('I', false, true),
                            const SizedBox(width: 6),
                            _buildToolbarIcon(
                              'U',
                              false,
                              false,
                              underline: true,
                            ),
                            const SizedBox(width: 6),
                            _buildToolbarIcon('•', false, false),
                            const SizedBox(width: 6),
                            _buildToolbarIcon('“”', false, false),
                          ],
                        ),
                      ),

                      // Content Body
                      TextField(
                        controller: _controller,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: safeGoogleFont(
                          'Quicksand',
                          color: AppTheme.getHeadingColor(brightness),
                          fontSize: 14.5,
                          height: 1.55,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Write your heart out...',
                          hintStyle: TextStyle(
                            color: AppTheme.getFaintColor(brightness),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Dictation Section
                      if (_isListening || _isDictating)
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEFE9FF), Color(0xFFFBE9F6)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE0517A),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Listening...',
                                        style: safeGoogleFont(
                                          'Quicksand',
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF7A63C9),
                                        ),
                                      ),
                                      Text(
                                        'Speak now to dictate your entry',
                                        style: safeGoogleFont(
                                          'Quicksand',
                                          fontSize: 12,
                                          color: const Color(0xFF7A63C9),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    '0:14',
                                    style: safeGoogleFont(
                                      'Space Mono',
                                      fontSize: 12,
                                      color: AppTheme.getMutedColor(brightness),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 34,
                                child: VoiceWaveformAnimation(
                                  soundLevel: _soundLevel,
                                ),
                              ),
                              const SizedBox(height: 14),
                              ElevatedButton(
                                onPressed: _toggleDictation,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE0517A),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                  minimumSize: const Size(double.infinity, 44),
                                ),
                                child: Text(
                                  'Stop',
                                  style: safeGoogleFont(
                                    'Quicksand',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: _toggleDictation,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.getCardBackground(
                                brightness,
                                'lilac',
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              border: Border.all(
                                color: AppTheme.getHairlineColor(brightness),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.getAccentGradient(
                                      'lilac',
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '🎙️',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Dictate',
                                        style: safeGoogleFont(
                                          'Quicksand',
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.getHeadingColor(
                                            brightness,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Speak and we\'ll transcribe it in',
                                        style: safeGoogleFont(
                                          'Quicksand',
                                          fontSize: 12,
                                          color: AppTheme.getMutedColor(
                                            brightness,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Media Section
                      Text(
                        "MEDIA",
                        style: safeGoogleFont(
                          'Space Mono',
                          color: AppTheme.getFaintColor(brightness),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (_imageUrls.isNotEmpty)
                            Container(
                              width: 78,
                              height: 78,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: _imageUrls.first.startsWith('http')
                                        ? Image.network(
                                            _imageUrls.first,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                CustomPaint(
                                                  painter:
                                                      DiagonalStripesPainter(
                                                        color1: const Color(
                                                          0xFFE7E0F7,
                                                        ),
                                                        color2: const Color(
                                                          0xFFEFE9FB,
                                                        ),
                                                        stripeWidth: 8,
                                                      ),
                                                ),
                                          )
                                        : Image.file(
                                            File(_imageUrls.first),
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                CustomPaint(
                                                  painter:
                                                      DiagonalStripesPainter(
                                                        color1: const Color(
                                                          0xFFE7E0F7,
                                                        ),
                                                        color2: const Color(
                                                          0xFFEFE9FB,
                                                        ),
                                                        stripeWidth: 8,
                                                      ),
                                                ),
                                          ),
                                  ),
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _imageUrls.clear();
                                        });
                                      },
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: const Color(0x992B2540),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Text(
                                            '✕',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 78,
                              height: 78,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppTheme.getDottedLineColor(
                                    brightness,
                                  ),
                                  style: BorderStyle.solid,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    '🖼️',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Photo',
                                    style: safeGoogleFont(
                                      'Quicksand',
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.getFaintColor(brightness),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppTheme.getDottedLineColor(brightness),
                                style: BorderStyle.solid,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '🎬',
                                  style: TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Video',
                                  style: safeGoogleFont(
                                    'Quicksand',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.getFaintColor(brightness),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Tag Section
                      Text(
                        "TAG",
                        style: safeGoogleFont(
                          'Space Mono',
                          color: AppTheme.getFaintColor(brightness),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags.map((t) => _buildTagPill(t)).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Metadata block
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.getCardBackground(
                            brightness,
                            'lilac',
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(
                            color: AppTheme.getHairlineColor(brightness),
                          ),
                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _pickDateTime,
                              child: _buildMetaRow(
                                '📅',
                                'Date',
                                DateFormat('EEEE, MMM d').format(_entryDate),
                              ),
                            ),
                            Divider(
                              height: 1,
                              color: AppTheme.getHairlineColor(brightness),
                            ),
                            GestureDetector(
                              onTap: _pickDateTime,
                              child: _buildMetaRow(
                                '🕙',
                                'Time',
                                DateFormat('HH:mm').format(_entryDate),
                              ),
                            ),
                            Divider(
                              height: 1,
                              color: AppTheme.getHairlineColor(brightness),
                            ),
                            GestureDetector(
                              onTap: _editLocation,
                              child: _buildMetaRow(
                                '📍',
                                'Location',
                                _locationController.text.trim().isEmpty
                                    ? 'Add location'
                                    : _locationController.text.trim(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.getCardBackground(brightness, 'lilac'),
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.getHairlineColor(brightness),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.mood_outlined),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.location_on_outlined),
                      onPressed: _editLocation,
                    ),
                    IconButton(
                      icon: const Icon(Icons.label_outlined),
                      onPressed: _editTags,
                    ),
                    IconButton(
                      icon: const Icon(Icons.image_outlined),
                      onPressed: _pickImage,
                    ),
                    IconButton(
                      key: const Key('dictation-button'),
                      icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                      onPressed: _toggleDictation,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodButton(String emoji, String key) {
    final theme = Theme.of(context);
    final isSelected =
        _mood == emoji ||
        (key == 'happy' && _mood == '😊') ||
        (key == 'calm' && _mood == '😌') ||
        (key == 'love' && _mood == '😍') ||
        (key == 'down' && _mood == '😔') ||
        (key == 'tired' && _mood == '😴') ||
        (key == 'proud' && _mood == '🥳');

    return GestureDetector(
      onTap: () {
        setState(() {
          _mood = emoji;
        });
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEFE9FF)
              : AppTheme.getCardBackground(theme.brightness, 'lilac'),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B6CFF) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 23))),
      ),
    );
  }

  Widget _buildToolbarIcon(
    String label,
    bool isBold,
    bool isItalic, {
    bool underline = false,
  }) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.getChipColor(brightness),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Center(
        child: Text(
          label,
          style:
              safeGoogleFont(
                'Quicksand',
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                color: AppTheme.getMutedColor(brightness),
              ).copyWith(
                decoration: underline
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
        ),
      ),
    );
  }

  Widget _buildTagPill(String tag) {
    final isSelected = _tags.contains(tag);
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _tags.remove(tag);
          } else {
            _tags.add(tag);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? _getTagBg(tag)
              : AppTheme.getChipColor(brightness),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _getTagColor(tag) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          tag,
          style: safeGoogleFont(
            'Quicksand',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? _getTagColor(tag)
                : AppTheme.getMutedColor(brightness),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(dynamic icon, String title, String val) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      child: Row(
        children: [
          if (icon is IconData)
            Icon(icon, size: 18, color: AppTheme.getMutedColor(brightness))
          else if (icon is String)
            Text(icon, style: const TextStyle(fontSize: 17)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: safeGoogleFont(
                'Quicksand',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getHeadingColor(brightness),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            val,
            style: safeGoogleFont(
              'Quicksand',
              fontSize: 13,
              color: AppTheme.getFaintColor(brightness),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right,
            size: 16,
            color: AppTheme.getFaintColor(brightness),
          ),
        ],
      ),
    );
  }

  Color _getTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'work':
        return const Color(0xFF7A63C9);
      case 'reading':
        return const Color(0xFFB06CA6);
      case 'friends':
        return const Color(0xFFA86BC9);
      case 'outdoors':
        return const Color(0xFF6B9C5A);
      case 'travel':
        return const Color(0xFFC78B3C);
      default:
        return const Color(0xFF8B6CFF);
    }
  }

  Color _getTagBg(String tag) {
    switch (tag.toLowerCase()) {
      case 'work':
        return const Color(0xFFEFE9FF);
      case 'reading':
        return const Color(0xFFFBE9F6);
      case 'friends':
        return const Color(0xFFF3E9FB);
      case 'outdoors':
        return const Color(0xFFE6F2E2);
      case 'travel':
        return const Color(0xFFF6EDDC);
      default:
        return const Color(0xFFEFE9FF);
    }
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
      imageUrls: _imageUrls,
      tags: _tags,
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: colorScheme.primary),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: Icon(Icons.photo_camera, color: colorScheme.primary),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final appDocDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(appDocDir.path, 'entry_images'));
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${p.basename(pickedFile.path)}';
      final localPath = p.join(imagesDir.path, fileName);
      await File(pickedFile.path).copy(localPath);

      if (mounted) {
        setState(() {
          _imageUrls.add(localPath);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _entryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 5),
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
    final currentImages = _imageUrls;
    final currentDate = _entryDate;

    if (widget.entry == null) {
      final isDateChanged = !_isSameDateTime(currentDate, _initialEntryDate);
      final isContentNotEmpty = currentContent.trim().isNotEmpty;
      final isLocationNotEmpty = currentLocation.trim().isNotEmpty;
      final isTagsNotEmpty = currentTags.isNotEmpty;
      final isImagesNotEmpty = currentImages.isNotEmpty;
      final isMoodChanged = currentMood != _defaultMood;

      return isContentNotEmpty ||
          isLocationNotEmpty ||
          isTagsNotEmpty ||
          isImagesNotEmpty ||
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
      final isDateChanged = !_isSameDateTime(currentDate, existingEntry.date);
      final isTagsChanged = !_areTagsEqual(currentTags, existingEntry.tags);
      final isImagesChanged = !_areListsEqual(
        currentImages,
        existingEntry.imageUrls,
      );

      return isContentChanged ||
          isLocationChanged ||
          isMoodChanged ||
          isDateChanged ||
          isTagsChanged ||
          isImagesChanged;
    }
  }

  bool _areListsEqual(List<String> list1, List<String> list2) {
    return listEquals(list1, list2);
  }

  bool _areTagsEqual(List<String> list1, List<String> list2) {
    final set1 = list1.toSet();
    final set2 = list2.toSet();
    return set1.length == set2.length && set1.containsAll(set2);
  }

  bool _isSameDateTime(DateTime dt1, DateTime dt2) {
    return dt1.year == dt2.year &&
        dt1.month == dt2.month &&
        dt1.day == dt2.day &&
        dt1.hour == dt2.hour &&
        dt1.minute == dt2.minute;
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

  Future<void> _startListeningSession(int sessionId) async {
    if (!mounted || !_isDictating || sessionId != _dictationSessionId) return;

    final selection = _controller.selection;
    _dictationStartIndex = selection.start >= 0
        ? selection.start
        : _controller.text.length;
    _lastRecognizedLength = 0;

    try {
      await _speechService.startListening(
        onResult: (text) {
          if (!mounted || !_isDictating || sessionId != _dictationSessionId) {
            return;
          }
          setState(() {
            final currentText = _controller.text;

            // Validate and clamp indices to avoid RangeError if manual edits happen during dictation
            final safeStart = _dictationStartIndex.clamp(0, currentText.length);
            final safeEnd = (_dictationStartIndex + _lastRecognizedLength)
                .clamp(safeStart, currentText.length);

            final newText = currentText.replaceRange(safeStart, safeEnd, text);

            _controller.value = TextEditingValue(
              text: newText,
              selection: TextSelection.collapsed(
                offset: safeStart + text.length,
              ),
            );

            _lastRecognizedLength = text.length;
          });
        },
        onError: (error) {
          if (!mounted || sessionId != _dictationSessionId) return;
          setState(() {
            _isDictating = false;
            _isListening = false;
            _soundLevel = 0.0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.dictationError(error)),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
        onStatusChange: (isListening) {
          if (!mounted || sessionId != _dictationSessionId) return;
          setState(() {
            _isListening = isListening;
            if (!isListening) {
              _soundLevel = 0.0;

              // Silence timeout triggered auto-restart
              if (_isDictating) {
                Future.delayed(AppTheme.dictationRestartDelay, () {
                  if (_isDictating &&
                      mounted &&
                      sessionId == _dictationSessionId) {
                    _startListeningSession(sessionId);
                  }
                });
              }
            }
          });
        },
        onSoundLevelChange: (level) {
          if (!mounted || !_isDictating || sessionId != _dictationSessionId) {
            return;
          }
          setState(() {
            _soundLevel = level;
          });
        },
      );
    } catch (e) {
      if (!mounted || sessionId != _dictationSessionId) return;
      setState(() {
        _isDictating = false;
        _isListening = false;
        _soundLevel = 0.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.dictationFailed(e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _toggleDictation() async {
    if (_isDictating) {
      setState(() {
        _isDictating = false;
        _isListening = false;
        _soundLevel = 0.0;
        _dictationSessionId++; // Invalidate any pending restarts
      });
      await _speechService.stopListening();
    } else {
      setState(() {
        _dictationSessionId++; // Start fresh session
        _isDictating = true;
      });
      await _startListeningSession(_dictationSessionId);
    }
  }
}

class VoiceWaveformAnimation extends StatefulWidget {
  final double soundLevel;
  const VoiceWaveformAnimation({super.key, required this.soundLevel});

  @override
  State<VoiceWaveformAnimation> createState() => _VoiceWaveformAnimationState();
}

class _VoiceWaveformAnimationState extends State<VoiceWaveformAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(22, (index) {
            final double animVal = _controller.value;
            final double offset = index * 0.15;
            final double waveVal =
                (math.sin(animVal * 2 * math.pi + offset) + 1) / 2.0;
            final double scale =
                0.2 +
                (waveVal * 0.5) +
                (widget.soundLevel * 0.05).clamp(0.0, 0.3);

            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                height: 34 * scale,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class DiagonalStripesPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final double stripeWidth;

  DiagonalStripesPainter({
    required this.color1,
    required this.color2,
    this.stripeWidth = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw background
    paint.color = color1;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw diagonal stripes
    paint.color = color2;
    final path = Path();

    final double step = stripeWidth * 2;
    for (double i = -size.height; i < size.width; i += step) {
      path.reset();
      path.moveTo(i, 0);
      path.lineTo(i + stripeWidth, 0);
      path.lineTo(i + stripeWidth + size.height, size.height);
      path.lineTo(i + size.height, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

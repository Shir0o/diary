import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/font_helper.dart';
import '../models/diary_entry.dart';

class NewEntryScreen extends StatefulWidget {
  final DiaryEntry? entry;
  final Future<void> Function()? onDelete;

  const NewEntryScreen({super.key, this.entry, this.onDelete});

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  late final TextEditingController _controller;
  late final TextEditingController _locationController;
  late DateTime _entryDate;
  late String _mood;

  @override
  void initState() {
    super.initState();
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
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF7FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.entry == null ? 'New Entry' : 'Edit Entry',
          style: safeGoogleFont(
            'IBM Plex Sans',
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (widget.entry != null && widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFF6750A4)),
              tooltip: 'Delete entry',
              onPressed: _confirmDelete,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(_buildEntry());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6750A4),
                foregroundColor: Colors.white,
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
                  const SizedBox(height: 16),
                  Text(
                    DateFormat('MMM dd, yyyy').format(_entryDate),
                    style: safeGoogleFont(
                      'IBM Plex Sans',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: _pickDateTime,
                    borderRadius: BorderRadius.circular(8),
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
                              color: const Color(0xFF79747E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(
                            '•',
                            style: TextStyle(color: Color(0xFF79747E)),
                          ),
                          Text(
                            DateFormat('EEEE').format(_entryDate),
                            style: safeGoogleFont(
                              'IBM Plex Sans',
                              fontSize: 18,
                              color: const Color(0xFF79747E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Icon(
                            Icons.edit_calendar_outlined,
                            size: 18,
                            color: Color(0xFF79747E),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_locationController.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: Color(0xFF6750A4),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _locationController.text.trim(),
                            style: safeGoogleFont(
                              'IBM Plex Sans',
                              fontSize: 14,
                              color: const Color(0xFF6750A4),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    maxLines: null,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Write your heart out...',
                      hintStyle: safeGoogleFont(
                        'IBM Plex Sans',
                        fontSize: 18,
                        color: const Color(0xFF79747E).withValues(alpha: 0.6),
                      ),
                      border: InputBorder.none,
                    ),
                    style: safeGoogleFont(
                      'IBM Plex Sans',
                      fontSize: 18,
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
              color: const Color(0xFFFEF7FF).withValues(alpha: 0.9),
              border: Border(
                top: BorderSide(
                  color: const Color(0xFF79747E).withValues(alpha: 0.1),
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
                        child: const Icon(
                          Icons.image_outlined,
                          color: Color(0xFF6750A4),
                        ),
                      ),
                      InkWell(
                        onTap: () => _showUnavailableMessage(
                          'Tags are not available yet.',
                        ),
                        child: const Icon(
                          Icons.label_outlined,
                          color: Color(0xFF6750A4),
                        ),
                      ),
                      InkWell(
                        onTap: _pickMood,
                        child: const Icon(
                          Icons.mood_outlined,
                          color: Color(0xFF6750A4),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: const Color(0xFF79747E).withValues(alpha: 0.2),
                      ),
                      InkWell(
                        onTap: _editLocation,
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF79747E),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: Color(0xFF79747E),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Saved locally',
                      key: const ValueKey('entry-save-status'),
                      style: safeGoogleFont(
                        'IBM Plex Sans',
                        fontSize: 12,
                        color: const Color(0xFF79747E),
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
      id: existingEntry?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      date: _entryDate,
      title: _titleFromContent(content),
      content: content,
      mood: _mood,
      location: _emptyToNull(_locationController.text),
      imageUrls: existingEntry?.imageUrls ?? const [],
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
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(
          text: _locationController.text,
        );
        return AlertDialog(
          title: const Text('Entry location'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Add a location'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(''),
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (result == null) return;
    setState(() {
      _locationController.text = result.trim();
    });
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete entry?'),
          content: const Text('This entry will be permanently deleted.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    await widget.onDelete!();
    if (!mounted) return;
    Navigator.of(context).pop();
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

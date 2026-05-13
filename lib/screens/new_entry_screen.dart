import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/font_helper.dart';
import '../models/diary_entry.dart';

class NewEntryScreen extends StatefulWidget {
  final DiaryEntry? entry;

  const NewEntryScreen({super.key, this.entry});

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  late final TextEditingController _controller;
  late final DateTime _entryDate;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.entry?.content);
    _entryDate = widget.entry?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _controller.dispose();
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
          'New Entry',
          style: safeGoogleFont(
            'IBM Plex Sans',
            color: Colors.black,
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
                  Row(
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
                      const SizedBox(width: 8),
                      const Text(
                        '•',
                        style: TextStyle(color: Color(0xFF79747E)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE').format(_entryDate),
                        style: safeGoogleFont(
                          'IBM Plex Sans',
                          fontSize: 18,
                          color: const Color(0xFF79747E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: const Icon(
                          Icons.image_outlined,
                          color: Color(0xFF6750A4),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () {},
                        child: const Icon(
                          Icons.label_outlined,
                          color: Color(0xFF6750A4),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () {},
                        child: const Icon(
                          Icons.mood_outlined,
                          color: Color(0xFF6750A4),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 1,
                        height: 24,
                        color: const Color(0xFF79747E).withValues(alpha: 0.2),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () {},
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
                      Icons.cloud_upload_outlined,
                      size: 16,
                      color: Color(0xFF79747E),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Saving...',
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
      date: existingEntry?.date ?? _entryDate,
      title: _titleFromContent(content),
      content: content,
      mood: existingEntry?.mood ?? '📝',
      location: existingEntry?.location,
      imageUrls: existingEntry?.imageUrls ?? const [],
    );
  }

  String _titleFromContent(String content) {
    if (content.isEmpty) {
      return 'Untitled Entry';
    }

    return content.split('\n').first.trim();
  }
}

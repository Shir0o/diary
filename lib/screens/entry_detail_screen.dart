import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/diary_entry.dart';
import '../helpers/font_helper.dart';
import '../providers/diary_provider.dart';
import 'new_entry_screen.dart';

class EntryDetailScreen extends StatelessWidget {
  final DiaryEntry entry;

  const EntryDetailScreen({super.key, required this.entry});

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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => NewEntryScreen(entry: entry),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              DateFormat('MMM dd, yyyy').format(entry.date),
              style: safeGoogleFont(
                'IBM Plex Sans',
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  DateFormat('h:mm a').format(entry.date),
                  style: safeGoogleFont(
                    'IBM Plex Sans',
                    fontSize: 18,
                    color: const Color(0xFF79747E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(color: Color(0xFF79747E))),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE').format(entry.date),
                  style: safeGoogleFont(
                    'IBM Plex Sans',
                    fontSize: 18,
                    color: const Color(0xFF79747E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(entry.mood, style: const TextStyle(fontSize: 32)),
              ],
            ),
            if (entry.location != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Color(0xFF79747E),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry.location!,
                      style: safeGoogleFont(
                        'IBM Plex Sans',
                        fontSize: 14,
                        color: const Color(0xFF79747E),
                      ),
                    ),
                  ],
                ),
              ),
            if (entry.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 4,
                  children: entry.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6750A4).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '#$tag',
                        style: safeGoogleFont(
                          'IBM Plex Sans',
                          fontSize: 12,
                          color: const Color(0xFF6750A4),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              entry.content,
              style: safeGoogleFont('IBM Plex Sans', fontSize: 18, height: 1.6),
            ),
            if (entry.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 24),
              ...entry.imageUrls.map(
                (path) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(path),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text('This entry will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;

    await Provider.of<DiaryProvider>(
      context,
      listen: false,
    ).deleteEntry(entry.id);

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

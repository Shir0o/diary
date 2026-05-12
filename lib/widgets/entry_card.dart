import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/diary_entry.dart';
import '../helpers/font_helper.dart';
import '../screens/entry_detail_screen.dart';

class EntryCard extends StatelessWidget {
  final DiaryEntry entry;

  const EntryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EntryDetailScreen(entry: entry),
          ),
        );
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('h:mm a').format(entry.date),
                    style: safeGoogleFont(
                      'Inter',
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  Text(entry.mood, style: const TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.title,
                style: safeGoogleFont(
                  'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.content,
                style: safeGoogleFont(
                  'Inter',
                  color: Colors.black87,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: entry.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6751a4).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '#$tag',
                        style: safeGoogleFont(
                          'Inter',
                          color: const Color(0xFF6751a4),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              if (entry.location != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Color(0xFF6751a4),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry.location!,
                      style: safeGoogleFont(
                        'Inter',
                        color: const Color(0xFF6751a4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
              if (entry.imageUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: entry.imageUrls.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(entry.imageUrls[index]),
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

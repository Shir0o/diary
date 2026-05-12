import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../helpers/font_helper.dart';

class EntryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback? onTap;

  const EntryCard({super.key, required this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
            ],
          ),
        ),
      ),
    );
  }
}

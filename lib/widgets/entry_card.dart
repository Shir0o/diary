import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/diary_entry.dart';

class EntryCard extends StatelessWidget {
  final DiaryEntry entry;

  const EntryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
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
                  style: _safeInter(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Text(
                  entry.mood,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              entry.title,
              style: _safeInter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              entry.content,
              style: _safeInter(
                color: Colors.black87,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (entry.location != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Color(0xFF6751a4)),
                  const SizedBox(width: 4),
                  Text(
                    entry.location!,
                    style: _safeInter(
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
    );
  }

  TextStyle _safeInter({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
  }) {
    // If in test environment, return default TextStyle
    if (RegExp(r'_test.dart$').hasMatch(Platform.script.path) || Platform.environment.containsKey('FLUTTER_TEST')) {
      return TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
      );
    }
    
    try {
      return GoogleFonts.inter(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
      );
    } catch (e) {
      return TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
      );
    }
  }
}

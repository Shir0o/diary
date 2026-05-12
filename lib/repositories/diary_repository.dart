import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry.dart';

class DiaryRepository {
  static const String _key = 'diary_entries';

  Future<List<DiaryEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => DiaryEntry.fromJson(json)).toList();
  }

  Future<void> saveEntries(List<DiaryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(
      entries.map((entry) => entry.toJson()).toList(),
    );
    await prefs.setString(_key, jsonString);
  }
}

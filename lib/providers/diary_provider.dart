import 'package:flutter/foundation.dart';
import '../models/diary_entry.dart';
import '../repositories/diary_repository.dart';

class DiaryProvider with ChangeNotifier {
  final DiaryRepository _repository = DiaryRepository();
  List<DiaryEntry> _entries = [];
  bool _isLoading = true;

  List<DiaryEntry> get entries => List.unmodifiable(_entries);
  bool get isLoading => _isLoading;

  DiaryProvider() {
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    _isLoading = true;
    notifyListeners();
    
    _entries = await _repository.loadEntries();
    
    // Sort entries by date descending
    _sortEntries();
    
    _isLoading = false;
    notifyListeners();
  }

  void _sortEntries() {
    _entries.sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addEntry(DiaryEntry entry) async {
    _entries.add(entry);
    _sortEntries();
    notifyListeners();
    await _repository.saveEntries(_entries);
  }

  Future<void> updateEntry(DiaryEntry updatedEntry) async {
    final index = _entries.indexWhere((e) => e.id == updatedEntry.id);
    if (index != -1) {
      _entries[index] = updatedEntry;
      _sortEntries();
      notifyListeners();
      await _repository.saveEntries(_entries);
    }
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
    await _repository.saveEntries(_entries);
  }
}

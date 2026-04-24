import 'package:flutter_test/flutter_test.dart';
import 'package:diary/models/diary_entry.dart';

void main() {
  group('DiaryEntry', () {
    final testDate = DateTime(2023, 10, 24, 10, 30);
    
    test('should create a DiaryEntry instance', () {
      final entry = DiaryEntry(
        id: '1',
        date: testDate,
        title: 'Morning Walk',
        content: 'Beautiful morning at the park.',
        mood: '😊',
        location: 'Central Park',
      );

      expect(entry.id, '1');
      expect(entry.date, testDate);
      expect(entry.title, 'Morning Walk');
      expect(entry.content, 'Beautiful morning at the park.');
      expect(entry.mood, '😊');
      expect(entry.location, 'Central Park');
    });

    test('should serialize to JSON map', () {
      final entry = DiaryEntry(
        id: '1',
        date: testDate,
        title: 'Morning Walk',
        content: 'Beautiful morning at the park.',
        mood: '😊',
      );

      final json = entry.toJson();

      expect(json['id'], '1');
      expect(json['date'], testDate.toIso8601String());
      expect(json['title'], 'Morning Walk');
      expect(json['content'], 'Beautiful morning at the park.');
      expect(json['mood'], '😊');
    });

    test('should deserialize from JSON map', () {
      final json = {
        'id': '1',
        'date': testDate.toIso8601String(),
        'title': 'Morning Walk',
        'content': 'Beautiful morning at the park.',
        'mood': '😊',
        'location': 'Central Park',
      };

      final entry = DiaryEntry.fromJson(json);

      expect(entry.id, '1');
      expect(entry.date, testDate);
      expect(entry.title, 'Morning Walk');
      expect(entry.content, 'Beautiful morning at the park.');
      expect(entry.mood, '😊');
      expect(entry.location, 'Central Park');
    });
  });
}

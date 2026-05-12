class DiaryEntry {
  final String id;
  final DateTime date;
  final String title;
  final String content;
  final String mood;
  final String? location;
  final List<String> imageUrls;
  final List<String> tags;

  DiaryEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    required this.mood,
    this.location,
    this.imageUrls = const [],
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'content': content,
      'mood': mood,
      'location': location,
      'imageUrls': imageUrls,
      'tags': tags,
    };
  }

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String,
      content: json['content'] as String,
      mood: json['mood'] as String,
      location: json['location'] as String?,
      imageUrls:
          (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
    );
  }
}

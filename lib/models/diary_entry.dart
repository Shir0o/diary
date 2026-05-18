class DiaryEntry {
  final String id;
  final DateTime date;
  final String title;
  final String content;
  final String mood;
  final String? location;
  final List<String> imageUrls;
  final bool isArchived;
  final bool isDeleted;

  DiaryEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    required this.mood,
    this.location,
    this.imageUrls = const [],
    this.isArchived = false,
    this.isDeleted = false,
  });

  DiaryEntry copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? content,
    String? mood,
    String? location,
    List<String>? imageUrls,
    bool? isArchived,
    bool? isDeleted,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      location: location ?? this.location,
      imageUrls: imageUrls ?? this.imageUrls,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'content': content,
      'mood': mood,
      'location': location,
      'imageUrls': imageUrls,
      'isArchived': isArchived,
      'isDeleted': isDeleted,
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
      isArchived: json['isArchived'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }
}

class Vocabulary {
  final String id;
  final String word;
  final String meaning;
  final String? pronunciation;
  final String? example;
  final String? level;
  final String? category;

  Vocabulary({
    required this.id,
    required this.word,
    required this.meaning,
    this.pronunciation,
    this.example,
    this.level,
    this.category,
  });

  factory Vocabulary.fromFirestore(Map<String, dynamic>? data, String id) {
    return Vocabulary(
      id: id,
      word: data?['word'] ?? '',
      meaning: data?['meaning'] ?? '',
      pronunciation: data?['pronunciation'],
      example: data?['example'],
      level: data?['level'],
      category: data?['category'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'word': word,
      'meaning': meaning,
      'pronunciation': pronunciation,
      'example': example,
      'level': level,
      'category': category,
    };
  }
}
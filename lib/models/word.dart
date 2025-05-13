class Word {
  final int id;
  final String english;
  final String chinese;
  final String pronunciation;
  final String exampleSentence;
  final String difficultyLevel;
  final String category;

  Word({
    required this.id,
    required this.english,
    required this.chinese,
    required this.pronunciation,
    required this.exampleSentence,
    required this.difficultyLevel,
    required this.category,
  });

  // 只接收一个 map 参数
  factory Word.fromMap(Map<String, dynamic> data) {
    return Word(
      id: data['id'] as int, // 直接从 map 中获取 id
      english: data['english'] ?? '',
      chinese: data['chinese'] ?? '',
      pronunciation: data['pronunciation'] ?? '',
      exampleSentence: data['exampleSentence'] ?? '',
      difficultyLevel: data['difficultyLevel'] ?? 'beginner',
      category: data['category'] ?? 'general',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'english': english,
      'chinese': chinese,
      'pronunciation': pronunciation,
      'exampleSentence': exampleSentence,
      'difficultyLevel': difficultyLevel,
      'category': category,
    };
  }
}
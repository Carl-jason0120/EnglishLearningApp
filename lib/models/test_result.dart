class TestResult {
  final int id;
  final int userId;
  final String testDate;
  final int score;
  final int totalQuestions;
  final String testType;
  final String difficultyLevel;

  TestResult({
    required this.id,
    required this.userId,
    required this.testDate,
    required this.score,
    required this.totalQuestions,
    required this.testType,
    required this.difficultyLevel,
  });

  factory TestResult.fromMap(Map<String, dynamic> map) {
    return TestResult(
      id: map['id'],
      userId: map['userId'],
      testDate: map['testDate'],
      score: map['score'],
      totalQuestions: map['totalQuestions'],
      testType: map['testType'],
      difficultyLevel: map['difficultyLevel'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'testDate': testDate,
      'score': score,
      'totalQuestions': totalQuestions,
      'testType': testType,
      'difficultyLevel': difficultyLevel,
    };
  }
}
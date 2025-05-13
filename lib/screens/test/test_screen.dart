import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/db_operations.dart';
import '../../models/word.dart';
import '../../models/test_result.dart';
import '../../utils/constants.dart';

class TestScreen extends StatefulWidget {
  final int userId;
  final String difficulty;

  const TestScreen({
    required this.userId,
    required this.difficulty,
  });

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late Future<List<Word>> _wordsFuture;
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _isSubmitted = false;
  List<Word> _words = [];
  List<String> _options = [];

  @override
  void initState() {
    super.initState();
    _wordsFuture = _loadTestWords();
  }

  Future<List<Word>> _loadTestWords() async {
    final dbOps = Provider.of<DBOperations>(context, listen: false);
    final words = await dbOps.getWordsByLevel(widget.difficulty);
    // 随机选择10个单词
    words.shuffle();
    return words.take(10).toList();
  }

  void _generateOptions() {
    if (_words.isEmpty || _currentIndex >= _words.length) return;

    final currentWord = _words[_currentIndex];
    _options = [currentWord.chinese];

    // 从其他单词中随机选择3个中文释义作为干扰项
    final otherWords = _words.where((w) => w.id != currentWord.id).toList();
    otherWords.shuffle();

    for (var word in otherWords.take(3)) {
      if (!_options.contains(word.chinese)) {
        _options.add(word.chinese);
      }
    }

    _options.shuffle();
  }

  void _submitAnswer(String correctAnswer) {
    setState(() {
      _isSubmitted = true;
      if (_selectedAnswer == correctAnswer) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentIndex++;
      _selectedAnswer = null;
      _isSubmitted = false;
      _generateOptions();
    });
  }

  Future<void> _finishTest() async {
    final dbOps = Provider.of<DBOperations>(context, listen: false);

    final result = TestResult(
      id: 0,
      userId: widget.userId,
      testDate: DateTime.now().toString(),
      score: _score,
      totalQuestions: _words.length,
      testType: 'vocabulary',
      difficultyLevel: widget.difficulty,
    );

    await dbOps.saveTestResult(result);

    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('测试完成'),
        content: Text('你的得分: $_score/${_words.length}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppConstants.difficultyLevelNames[widget.difficulty]}测试'),
      ),
      body: FutureBuilder<List<Word>>(
        future: _wordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('加载测试失败'));
          }

          if (_words.isEmpty) {
            _words = snapshot.data!;
            _generateOptions();
          }

          if (_currentIndex >= _words.length) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '测试完成!',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '你的得分: $_score/${_words.length}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _finishTest,
                    child: Text('完成'),
                  ),
                ],
              ),
            );
          }

          final currentWord = _words[_currentIndex];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / _words.length,
                ),
                SizedBox(height: 16),
                Text(
                  '问题 ${_currentIndex + 1}/${_words.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 24),
                Text(
                  currentWord.english,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                SizedBox(height: 8),
                Text(
                  currentWord.pronunciation,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 32),
                Column(
                  children: _options.map((option) {
                    final isCorrect = option == currentWord.chinese;
                    final isSelected = option == _selectedAnswer;

                    Color? color;
                    if (_isSubmitted) {
                      if (isCorrect) {
                        color = Colors.green;
                      } else if (isSelected && !isCorrect) {
                        color = Colors.red;
                      }
                    }

                    return Card(
                      color: color?.withOpacity(0.1),
                      child: ListTile(
                        title: Text(option),
                        onTap: _isSubmitted ? null : () {
                          setState(() => _selectedAnswer = option);
                        },
                        trailing: _isSubmitted && isCorrect
                            ? Icon(Icons.check, color: Colors.green)
                            : null,
                        tileColor: isSelected
                            ? Colors.blue.withOpacity(0.1)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                Spacer(),
                if (_isSubmitted)
                  Center(
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      child: Text('下一题'),
                    ),
                  )
                else if (_selectedAnswer != null)
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _submitAnswer(currentWord.chinese),
                      child: Text('提交'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
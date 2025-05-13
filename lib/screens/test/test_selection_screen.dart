import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'test_screen.dart';

class TestSelectionScreen extends StatelessWidget {
  final int userId;

  const TestSelectionScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('选择测试难度')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: AppConstants.difficultyLevels.map((level) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildTestOption(
                context,
                '${AppConstants.difficultyLevelNames[level]}测试',
                _getTestDescription(level),
                _getTestColor(level),
                level,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getTestDescription(String level) {
    switch (level) {
      case 'beginner': return '适合初学者，包含基础词汇';
      case 'intermediate': return '适合有一定基础的学习者';
      case 'advanced': return '挑战你的词汇量';
      default: return '';
    }
  }

  Color _getTestColor(String level) {
    switch (level) {
      case 'beginner': return Colors.green;
      case 'intermediate': return Colors.orange;
      case 'advanced': return Colors.red;
      default: return Colors.blue;
    }
  }

  Widget _buildTestOption(
      BuildContext context,
      String title,
      String description,
      Color color,
      String difficulty,
      ) {
    return Card(
      elevation: 4,
      color: color.withOpacity(0.1),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TestScreen(
                userId: userId,
                difficulty: difficulty,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                ),
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.arrow_forward, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
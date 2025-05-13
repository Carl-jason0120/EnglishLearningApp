import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../database/db_operations.dart';
import '../../models/word.dart';

class RecordsScreen extends StatelessWidget {
  final int userId;

  const RecordsScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    final dbOps = Provider.of<DBOperations>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('学习记录'),
          bottom: TabBar(
            tabs: [
              Tab(text: '已学单词'),
              Tab(text: '测试记录'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLearnedWordsTab(dbOps),
            _buildTestHistoryTab(dbOps),
          ],
        ),
      ),
    );
  }

  Widget _buildLearnedWordsTab(DBOperations dbOps) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: dbOps.getLearningRecords(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('暂无学习记录'));
        }

        final records = snapshot.data!;

        return ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            final word = Word.fromMap(record);
            final learnedAt = DateTime.parse(record['learnedAt']);

            return ListTile(
              title: Text(word.english),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(word.chinese),
                  SizedBox(height: 4),
                  Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(learnedAt),
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              trailing: Icon(Icons.book, color: Colors.green),
            );
          },
        );
      },
    );
  }

  Widget _buildTestHistoryTab(DBOperations dbOps) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: dbOps.getTestHistory(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('暂无测试记录'));
        }

        final records = snapshot.data!;

        return ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            final testDate = DateTime.parse(record['testDate']);
            final score = record['score'];
            final total = record['totalQuestions'];
            final level = record['difficultyLevel'];

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text('${_getLevelText(level)} 测试'),
                subtitle: Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(testDate),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$score/$total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(score / total),
                      ),
                    ),
                    Text(
                      '${(score / total * 100).toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getLevelText(String level) {
    switch (level) {
      case 'beginner': return '初级';
      case 'intermediate': return '中级';
      case 'advanced': return '高级';
      default: return level;
    }
  }

  Color _getScoreColor(double ratio) {
    if (ratio >= 0.8) return Colors.green;
    if (ratio >= 0.5) return Colors.orange;
    return Colors.red;
  }
}
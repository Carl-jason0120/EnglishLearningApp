import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/db_operations.dart';
import '../../models/word.dart';
import 'word_detail_screen.dart';
import '../../utils/constants.dart';

class WordListScreen extends StatelessWidget {
  final int userId;

  const WordListScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    final dbOps = Provider.of<DBOperations>(context);

    return DefaultTabController(
      length: AppConstants.difficultyLevels.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('单词学习'),
          bottom: TabBar(
            tabs: AppConstants.difficultyLevels
                .map((level) => Tab(text: AppConstants.difficultyLevelNames[level]))
                .toList(),
          ),
        ),
        body: TabBarView(
          children: AppConstants.difficultyLevels
              .map((level) => _buildWordList(dbOps.getWordsByLevel(level)))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildWordList(Future<List<Word>> wordFuture) {
    return FutureBuilder<List<Word>>(
      future: wordFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text('加载单词失败'));
        }

        final words = snapshot.data!;

        return ListView.builder(
          itemCount: words.length,
          itemBuilder: (context, index) {
            final word = words[index];
            return ListTile(
              title: Text(word.english),
              subtitle: Text(word.chinese),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WordDetailScreen(
                      userId: userId,
                      word: word,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
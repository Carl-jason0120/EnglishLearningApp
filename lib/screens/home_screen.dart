import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/db_operations.dart';
import 'learn/word_list_screen.dart';
import 'test/test_selection_screen.dart';
import 'settings_screen.dart';
import 'records_screen.dart';
import '../utils/widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  final int userId;

  const HomeScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    final dbOps = Provider.of<DBOperations>(context);

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Map<String, dynamic>?>(
          future: dbOps.getUserById(userId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text('欢迎, ${snapshot.data!['displayName']}');
            }
            return Text('英语单词学习');
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(userId: userId),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFeatureCard(
              context,
              '学习单词',
              Icons.book,
              Colors.blue,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WordListScreen(userId: userId),
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            _buildFeatureCard(
              context,
              '单词测试',
              Icons.quiz,
              Colors.green,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TestSelectionScreen(userId: userId),
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            _buildFeatureCard(
              context,
              '学习记录',
              Icons.history,
              Colors.purple,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecordsScreen(userId: userId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 48, color: color),
              SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
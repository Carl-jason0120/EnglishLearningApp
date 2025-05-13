import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/db_operations.dart';
import '../../models/word.dart';
import '../../utils/constants.dart';

class WordDetailScreen extends StatefulWidget {
  final int userId;
  final Word word;

  const WordDetailScreen({
    required this.userId,
    required this.word,
  });

  @override
  _WordDetailScreenState createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final dbOps = Provider.of<DBOperations>(context, listen: false);
    _isFavorite = await dbOps.isFavorite(widget.userId, widget.word.id);
    setState(() => _isLoading = false);
  }

  Future<void> _toggleFavorite() async {
    final dbOps = Provider.of<DBOperations>(context, listen: false);
    setState(() => _isLoading = true);

    if (_isFavorite) {
      await dbOps.removeFromFavorites(widget.userId, widget.word.id);
    } else {
      await dbOps.addToFavorites(widget.userId, widget.word.id);
    }

    setState(() {
      _isFavorite = !_isFavorite;
      _isLoading = false;
    });
  }

  Future<void> _markAsLearned() async {
    final dbOps = Provider.of<DBOperations>(context, listen: false);
    await dbOps.markWordAsLearned(widget.userId, widget.word.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已标记为学习')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.word.english)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.word.english,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            SizedBox(height: 8),
            Text(
              widget.word.pronunciation,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            Text(
              '中文释义: ${widget.word.chinese}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16),
            Text(
              '例句: ${widget.word.exampleSentence}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16),
            Text(
              '难度: ${AppConstants.difficultyLevelNames[widget.word.difficultyLevel]}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16),
            Text(
              '分类: ${widget.word.category}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _markAsLearned,
                    child: Text('标记为已学'),
                  ),
                ),
                SizedBox(width: 16),
                IconButton(
                  icon: _isLoading
                      ? CircularProgressIndicator()
                      : Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : null,
                  ),
                  onPressed: _isLoading ? null : _toggleFavorite,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
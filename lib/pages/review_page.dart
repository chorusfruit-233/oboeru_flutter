import 'package:flutter/material.dart';
import '../models/word.dart';
import '../widgets/word_card.dart';

class ReviewPage extends StatefulWidget {
  final List<Word> words;
  final String title;

  const ReviewPage({
    super.key,
    required this.words,
    this.title = '复习',
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late List<Word> _remaining;
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _complete = false;

  @override
  void initState() {
    super.initState();
    _remaining = List.from(widget.words);
  }

  Word? get _currentWord =>
      _currentIndex < _remaining.length ? _remaining[_currentIndex] : null;

  double get _fontSize => 16.0;

  @override
  Widget build(BuildContext context) {
    if (_complete || _remaining.isEmpty) {
      return _buildComplete();
    }

    final word = _currentWord!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                '${_currentIndex + 1}/${_remaining.length}',
                style: TextStyle(fontSize: _fontSize * 0.85),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: WordCard(
                word: word,
                isFlipped: _isFlipped,
                fontSize: _fontSize,
                onTap: () => setState(() => _isFlipped = !_isFlipped),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _currentIndex > 0
                          ? () => setState(() {
                                _currentIndex--;
                                _isFlipped = false;
                              })
                          : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('上一个'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: () => _markReviewed(),
                      icon: const Icon(Icons.check),
                      label: const Text('已掌握'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _skip(),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('跳过'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _markReviewed() {
    _remaining.removeAt(_currentIndex);
    if (_remaining.isEmpty) {
      setState(() => _complete = true);
    } else {
      if (_currentIndex >= _remaining.length) {
        _currentIndex = _remaining.length - 1;
      }
      _isFlipped = false;
      setState(() {});
    }
  }

  void _skip() {
    if (_currentIndex < _remaining.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }
    _isFlipped = false;
    setState(() {});
  }

  Widget _buildComplete() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                '复习完成！',
                style: TextStyle(
                  fontSize: _fontSize * 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '本次复习了 ${widget.words.length} 个单词',
                style: TextStyle(fontSize: _fontSize),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.home),
                  label: Text(
                    '返回',
                    style: TextStyle(fontSize: _fontSize * 1.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

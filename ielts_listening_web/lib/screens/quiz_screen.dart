
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/vocabulary.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Random _random = Random();

  List<Vocabulary> _vocabList = [];


  List<Vocabulary> _quizQuestions = [];
  List<List<String>> _optionsPerQuestion = [];
  int _numQuestions = 0;
  int _currentQuestion = 0;
  final List<Map<String, dynamic>> _answers = [];


  bool _loading = true;
  bool _quizStarted = false;
  bool _showResults = false;
  Map<String, dynamic>? _quizResults;


  Timer? _timer;
  final int questionDuration = 30;
  int _timeLeft = 30;

  @override
  void initState() {
    super.initState();
    _fetchVocabulary();
  }

  Future<void> _fetchVocabulary() async {
    setState(() => _loading = true);
    try {
      final snapshot = await _firestore.collection('vocabulary').get();
      final list = snapshot.docs
          .map((d) => Vocabulary.fromFirestore(d.data(), d.id))
          .toList();

      if (!mounted) return;
      setState(() {
        _vocabList = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading vocabulary: $e')),
      );
    }
  }


  void _startQuiz(int count) {
    if (_vocabList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No vocabulary available to start quiz.')),
      );
      return;
    }


    final pool = List<Vocabulary>.from(_vocabList);
    pool.shuffle(_random);


    final actualCount = count > pool.length ? pool.length : count;
    _quizQuestions = pool.take(actualCount).toList();
    _numQuestions = _quizQuestions.length;


    _optionsPerQuestion = _quizQuestions.map((v) => _prepareOptionsFor(v, pool)).toList();


    setState(() {
      _quizStarted = true;
      _showResults = false;
      _currentQuestion = 0;
      _answers.clear();
      _quizResults = null;
    });

    // Start timer for first question
    _startTimer();
  }


  List<String> _prepareOptionsFor(Vocabulary vocab, List<Vocabulary> pool) {
    final correct = vocab.meaning ?? '';
    final Set<String> options = {correct};


    final otherMeanings = pool
        .where((v) => v.id != vocab.id && (v.meaning?.isNotEmpty ?? false))
        .map((v) => v.meaning!)
        .toList();


    otherMeanings.shuffle(_random);
    for (var m in otherMeanings) {
      if (options.length >= 4) break;
      options.add(m);
    }


    const fallback = [
      "A type of material",
      "A kind of animal",
      "A small device",
      "A place or location",
      "A concept or idea",
      "A tool used for cutting",
    ];
    int i = 0;
    while (options.length < 4 && i < fallback.length) {
      options.add(fallback[i]);
      i++;
    }

    final result = options.toList();
    result.shuffle(_random);
    return result;
  }

  void _startTimer() {
    _stopTimer();
    setState(() => _timeLeft = questionDuration);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {

        t.cancel();
        _handleAnswerSubmit(false, "(timeout)");
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }


  void _handleAnswerSubmit(bool isCorrect, String userAnswer) {

    _stopTimer();

    if (_currentQuestion >= _quizQuestions.length) return;

    final vocab = _quizQuestions[_currentQuestion];
    _answers.add({
      'vocabularyId': vocab.id,
      'userAnswer': userAnswer,
      'isCorrect': isCorrect,
    });


    if (_currentQuestion < _numQuestions - 1) {
      setState(() => _currentQuestion++);
      _startTimer();
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    _stopTimer();

    final correctCount = _answers.where((a) => a['isCorrect'] == true).length;
    final total = _answers.length;
    final score = total > 0 ? ((correctCount / total) * 100).round() : 0;

    final results = {
      'correctAnswers': correctCount,
      'totalQuestions': total,
      'score': score,
      'timeSpent': 0,
    };

    setState(() {
      _quizResults = results;
      _showResults = true;
      _quizStarted = false;
    });


    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('quiz_attempts').add({
          'userId': user.uid,
          'vocabularyIds': _answers.map((a) => a['vocabularyId']).toList(),
          'answers': _answers,
          'score': score,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving quiz attempt: $e')),
          );
        }
      }
    }
  }

  void _retryQuiz() {
    _stopTimer();
    setState(() {
      _quizStarted = false;
      _showResults = false;
      _currentQuestion = 0;
      _answers.clear();
      _quizQuestions.clear();
      _optionsPerQuestion.clear();
      _quizResults = null;
    });
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }


    if (_vocabList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vocabulary Quiz')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No vocabulary available.'),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _fetchVocabulary, child: const Text('Reload')),
            ],
          ),
        ),
      );
    }


    if (!_quizStarted && !_showResults) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vocabulary Quiz')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Icon(Icons.quiz, size: 36, color: Colors.blue),
                SizedBox(width: 8),
                Text('Vocabulary Quiz', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 12),
              const Text('Pick number of questions (questions are chosen randomly each attempt).'),
              const SizedBox(height: 18),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildQuizCard(3, 'Quick', '~2-3 mins'),
                    _buildQuizCard(5, 'Short', '~5 mins'),
                    _buildQuizCard(10, 'Standard', '~10 mins'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text('Total vocabulary available: ${_vocabList.length}'),
            ],
          ),
        ),
      );
    }


    if (_showResults && _quizResults != null) {
      return QuizResults(results: _quizResults!, onRetry: _retryQuiz);
    }


    if (!_quizStarted || _currentQuestion >= _quizQuestions.length || _quizQuestions.isEmpty) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(onPressed: _retryQuiz, child: const Text('Back')),
        ),
      );
    }


    final vocab = _quizQuestions[_currentQuestion];
    final options = _optionsPerQuestion[_currentQuestion];


    final bool submittedForThisQuestion = _answers.length > _currentQuestion;
    String? userAnswer;
    bool isCorrect = false;
    if (submittedForThisQuestion) {
      final stored = _answers[_currentQuestion];
      userAnswer = stored['userAnswer'] as String?;
      isCorrect = stored['isCorrect'] == true;
    }

    return Scaffold(
      appBar: AppBar(title: Text('Question ${_currentQuestion + 1} / $_numQuestions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            LinearProgressIndicator(
              value: _timeLeft / questionDuration,
              color: _timeLeft < 8 ? Colors.red : Colors.green,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time left: $_timeLeft s', style: TextStyle(color: _timeLeft < 8 ? Colors.red : Colors.black)),
                Text('Q ${_currentQuestion + 1} / $_numQuestions', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 14.0),
                child: Column(
                  children: [
                    const Text('Choose the correct meaning', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(vocab.word, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('/${vocab.pronunciation ?? 'no pronunciation'}/', style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 16),


                    ...options.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final option = entry.value;
                      final label = String.fromCharCode(65 + idx);

                      Color? bgColor;
                      if (submittedForThisQuestion) {
                        final isThisCorrect = option == vocab.meaning;
                        final isSelected = userAnswer == option;
                        if (isThisCorrect) bgColor = Colors.green[300];
                        else if (isSelected && !isThisCorrect) bgColor = Colors.red[300];
                        else bgColor = Colors.grey[200];
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: ElevatedButton(
                          onPressed: submittedForThisQuestion ? null : () => _handleAnswerSubmit(option == vocab.meaning, option),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bgColor,
                            minimumSize: const Size.fromHeight(52),
                            foregroundColor: Colors.black87,
                          ),
                          child: Row(
                            children: [
                              Text('$label)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 12),
                              Expanded(child: Text(option, style: const TextStyle(fontSize: 16))),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 12),
                    if (submittedForThisQuestion)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCorrect ? Colors.green[50] : Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isCorrect ? '✓ Correct!' : '✗ Incorrect. Correct answer: ${vocab.meaning}',
                          style: TextStyle(fontSize: 16, color: isCorrect ? Colors.green[800] : Colors.red[800]),
                        ),
                      ),

                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: submittedForThisQuestion
                              ? () {
                            if (_currentQuestion < _numQuestions - 1) {
                              setState(() {
                                _currentQuestion++;
                              });
                              _startTimer();
                            } else {
                              _finishQuiz();
                            }
                          }
                              : null,
                          child: Text(submittedForThisQuestion ? (_currentQuestion < _numQuestions - 1 ? 'Next' : 'Finish') : 'Submit an answer'),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCard(int count, String title, String duration) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () => _startQuiz(count),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('$count', style: const TextStyle(fontSize: 28, color: Colors.blue)),
            const SizedBox(height: 6),
            Text(duration, style: const TextStyle(color: Colors.grey)),
          ]),
        ),
      ),
    );
  }
}

class QuizResults extends StatelessWidget {
  final Map<String, dynamic> results;
  final VoidCallback onRetry;

  const QuizResults({super.key, required this.results, required this.onRetry});

  Color _scoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.amber;
    return Colors.red;
  }

  Color _scoreBg(int score) {
    if (score >= 80) return Colors.green[50]!;
    if (score >= 60) return Colors.amber[50]!;
    return Colors.red[50]!;
  }

  @override
  Widget build(BuildContext context) {
    final score = results['score'] as int? ?? 0;
    final correct = results['correctAnswers'] as int? ?? 0;
    final total = results['totalQuestions'] as int? ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Results')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
            Icon(Icons.emoji_events, size: 36, color: Colors.amber),
            SizedBox(width: 8),
            Text('Quiz Complete', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 18),
          Card(
            color: _scoreBg(score),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(children: [
                Text('$score%', style: TextStyle(fontSize: 46, fontWeight: FontWeight.bold, color: _scoreColor(score))),
                const SizedBox(height: 8),
                Text('$correct out of $total correct', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(score >= 80 ? 'Excellent! 🎉' : (score >= 60 ? 'Good job!' : 'Keep practicing!'), style: const TextStyle(fontSize: 16, color: Colors.grey)),
              ]),
            ),
          ),
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.replay), label: const Text('Try another')),
            ElevatedButton.icon(onPressed: () => Navigator.pushReplacementNamed(context, '/flashcards'), icon: const Icon(Icons.menu_book), label: const Text('Review')),
            ElevatedButton.icon(onPressed: () => Navigator.pushReplacementNamed(context, '/home'), icon: const Icon(Icons.home), label: const Text('Home')),
          ]),
        ]),
      ),
    );
  }
}



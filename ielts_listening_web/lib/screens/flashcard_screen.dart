import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/vocabulary.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterTts _flutterTts = FlutterTts();

  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  bool _isFront = true;
  bool _isLoading = true;
  bool _ttsInitialized = false;

  int _currentIndex = 0;
  List<Vocabulary> _vocabList = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _initializeTts();
    _fetchVocabulary();
  }

  Future<void> _initializeTts() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.45);
      setState(() => _ttsInitialized = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('TTS error: $e')),
      );
    }
  }

  Future<void> _fetchVocabulary() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await _firestore.collection('vocabulary').get();
      setState(() {
        _vocabList = snapshot.docs
            .map((doc) => Vocabulary.fromFirestore(doc.data(), doc.id))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _speak(String text) async {
    if (!_ttsInitialized || text.isEmpty) return;
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _isFront = !_isFront);
  }

  void _nextCard() {
    if (_currentIndex < _vocabList.length - 1) {
      setState(() {
        _currentIndex++;
        _isFront = true;
        _controller.reset();
      });
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFront = true;
        _controller.reset();
      });
    }
  }

  Future<void> _markAsLearned() async {
    final vocab = _vocabList[_currentIndex];
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('progress')
          .doc(vocab.id)
          .set({
        'word': vocab.word,
        'learnedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(' Marked as learned')),
      );
      _nextCard();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_vocabList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flashcards')),
        body: const Center(
          child: Text('No vocabulary available.'),
        ),
      );
    }

    final vocab = _vocabList[_currentIndex];
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcard ${_currentIndex + 1}/${_vocabList.length}'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: _markAsLearned,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7F7FD5), Color(0xFF86A8E7), Color(0xFF91EAE4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0) _previousCard();
            if (details.primaryVelocity! < 0) _nextCard();
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    double angle = _controller.value * pi;
                    bool isFront = angle <= pi / 2;
                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      alignment: Alignment.center,
                      child: isFront
                          ? _buildFrontCard(vocab, screenWidth, screenHeight)
                          : Transform(
                        transform: Matrix4.identity()..rotateY(pi),
                        alignment: Alignment.center,
                        child: _buildBackCard(vocab),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                _buildActionButtons(),
                const SizedBox(height: 10),
                Text(
                  'Card ${_currentIndex + 1} / ${_vocabList.length}',
                  style: const TextStyle(
                      fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard(Vocabulary vocab, double w, double h) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.95),
      elevation: 8,
      shadowColor: Colors.black38,
      child: Container(
        width: w * 0.85,
        height: h * 0.45,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Tap to flip", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Text(
              vocab.word,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.deepPurple),
                  onPressed: () => _speak(vocab.word),
                ),
                Text(
                  '/${vocab.pronunciation ?? '---'}/',
                  style: const TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard(Vocabulary vocab) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      elevation: 8,
      shadowColor: Colors.black45,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Tap to flip back",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 16),
              _buildDetail('Word', vocab.word),
              _buildDetail('Meaning', vocab.meaning),
              _buildDetail('Example', vocab.example ?? "No example", italic: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(String label, String value, {bool italic = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(
                  color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontStyle: italic ? FontStyle.italic : FontStyle.normal,
              )),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _circleButton(Icons.arrow_back, _previousCard),
        const SizedBox(width: 16),
        _circleButton(Icons.flip, _flipCard),
        const SizedBox(width: 16),
        _circleButton(Icons.arrow_forward, _nextCard),
      ],
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.deepPurple,
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}

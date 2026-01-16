import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/vocabulary.dart';

class VocabularyDetailScreen extends StatelessWidget {
  final Vocabulary vocab;

  VocabularyDetailScreen({required this.vocab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(vocab.word.isEmpty ? 'Vocabulary' : vocab.word),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                vocab.word.isEmpty ? 'N/A' : vocab.word,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              if (vocab.pronunciation != null && vocab.pronunciation!.isNotEmpty)
                Text(
                  'Pronunciation: ${vocab.pronunciation}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              const SizedBox(height: 10),

              Text(
                'Meaning: ${vocab.meaning.isEmpty ? 'N/A' : vocab.meaning}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),

              if (vocab.example != null && vocab.example!.isNotEmpty)
                Text(
                  'Example: ${vocab.example}',
                  style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.black54),
                ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: '${vocab.word}\n${vocab.meaning}\n${vocab.example ?? ''}'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard!')),
                  );
                },
                child: const Text('Copy to Clipboard'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
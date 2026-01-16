import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/vocabulary_detail_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/flashcard_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/vocabulary.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English Vocabulary App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/quiz': (context) => const QuizScreen(),
        '/vocabulary': (context) {
          final vocab = ModalRoute.of(context)!.settings.arguments as Vocabulary;
          return VocabularyDetailScreen(vocab: vocab);
        },
        '/admin': (context) => AdminScreen(),
        '/flashcards': (context) => FlashcardScreen(),
        '/profile': (context) => ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/quiz_results') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null || !args.containsKey('results') || !args.containsKey('onRetry')) {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(child: Text('Invalid quiz results data')),
              ),
            );
          }
          return MaterialPageRoute(
            builder: (context) => QuizResults(
              results: args['results'] as Map<String, dynamic>,
              onRetry: args['onRetry'] as VoidCallback,
            ),
          );
        }
        return null;
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final role = userDoc.data()?['role'] as String? ?? 'user';
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushReplacementNamed(context, role == 'admin' ? '/admin' : '/home');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error checking role: $e')));
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
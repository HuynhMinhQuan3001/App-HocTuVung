//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'flashcard_screen.dart';
//
// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   bool _isGrammarTableExpanded = false;
//
//   int _currentStreak = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadStreak();
//   }
//
//   // 🔹 Load streak từ SharedPreferences
//   Future<void> _loadStreak() async {
//     final prefs = await SharedPreferences.getInstance();
//     final lastDateStr = prefs.getString('lastQuizDate');
//     final streak = prefs.getInt('streak') ?? 0;
//
//     if (lastDateStr != null) {
//       final lastDate = DateTime.parse(lastDateStr);
//       final today = DateTime.now();
//
//       if (_isSameDay(today, lastDate)) {
//         // Cùng ngày -> giữ nguyên streak
//         _currentStreak = streak;
//       } else if (today.difference(lastDate).inDays == 1) {
//         // Hôm qua có học -> tăng streak
//         _currentStreak = streak;
//       } else if (today.difference(lastDate).inDays > 1) {
//         // Bỏ qua 1 ngày -> reset streak
//         _currentStreak = streak;
//       }
//     } else {
//       _currentStreak = 0;
//     }
//
//     setState(() {});
//   }
//
//   bool _isSameDay(DateTime a, DateTime b) =>
//       a.year == b.year && a.month == b.month && a.day == b.day;
//
//   @override
//   Widget build(BuildContext context) {
//     if (_auth.currentUser == null) {
//       Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
//       return const SizedBox.shrink();
//     }
//
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FF),
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: const Color(0xFF5E5CE6),
//         title: const Text('VocaMaster', style: TextStyle(fontWeight: FontWeight.bold)),
//         actions: [
//           IconButton(icon: const Icon(Icons.home), onPressed: () {}),
//           IconButton(
//             icon: const Icon(Icons.flash_on),
//             onPressed: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => FlashcardScreen()),
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.quiz),
//             onPressed: () async {
//               // Khi người dùng làm quiz xong -> tăng streak
//               await Navigator.pushNamed(context, '/quiz');
//               await _updateStreakAfterQuiz();
//             },
//           ),
//           IconButton(
//               icon: const Icon(Icons.person),
//               onPressed: () => Navigator.pushNamed(context, '/profile')),
//           IconButton(
//               icon: const Icon(Icons.logout),
//               onPressed: () => _performLogout(context)),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildWelcomeBanner(context),
//             const SizedBox(height: 20),
//             _buildStatsSection(),
//             const SizedBox(height: 20),
//             screenWidth > 600
//                 ? Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(child: _buildGrammarCard()),
//                 const SizedBox(width: 16),
//                 Expanded(child: _buildQuickStartCard(context)),
//               ],
//             )
//                 : Column(
//               children: [
//                 _buildGrammarCard(),
//                 const SizedBox(height: 16),
//                 _buildQuickStartCard(context),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // 🔹 Cập nhật streak sau khi hoàn thành quiz
//   Future<void> _updateStreakAfterQuiz() async {
//     final prefs = await SharedPreferences.getInstance();
//     final lastDateStr = prefs.getString('lastQuizDate');
//     final today = DateTime.now();
//     int streak = prefs.getInt('streak') ?? 0;
//
//     if (lastDateStr != null) {
//       final lastDate = DateTime.parse(lastDateStr);
//
//       if (_isSameDay(today, lastDate)) {
//         // Cùng ngày -> không tăng
//       } else if (today.difference(lastDate).inDays == 1) {
//         // Hôm qua có học -> tăng streak
//         streak++;
//       } else {
//         // Bỏ qua 1 ngày -> reset streak
//         streak = 1;
//       }
//     } else {
//       streak = 1; // lần đầu tiên
//     }
//
//     await prefs.setInt('streak', streak);
//     await prefs.setString('lastQuizDate', today.toIso8601String());
//
//     setState(() => _currentStreak = streak);
//   }
//
//   // 🔹 WELCOME BANNER
//   Widget _buildWelcomeBanner(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF5E5CE6), Color(0xFF7A77FF)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       padding: const EdgeInsets.all(20),
//       child: Row(
//         children: [
//           const Icon(Icons.school, color: Colors.white, size: 48),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Welcome back, Learner! ",
//                   style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   "You are on a ${_currentStreak.toString()}-day streak! Keep it up 🔥",
//                   style: const TextStyle(color: Colors.white70, fontSize: 13),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 🔹 STATS SECTION
//   Widget _buildStatsSection() {
//     final stats = [
//       {
//         'title': 'Current Streak',
//         'value': '$_currentStreak 🔥',
//         'desc': 'Days learning',
//         'color': Colors.orange[100]
//       },
//       {
//         'title': 'Words Learned',
//         'value': '120',
//         'desc': 'Total vocabulary',
//         'color': Colors.blue[50]
//       },
//       {
//         'title': 'Study Time',
//         'value': '4h',
//         'desc': 'Total time',
//         'color': Colors.green[50]
//       },
//     ];
//
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         bool isWide = constraints.maxWidth > 600;
//         return Wrap(
//           spacing: 10,
//           runSpacing: 10,
//           children: stats.map((item) {
//             return SizedBox(
//               width: isWide
//                   ? (constraints.maxWidth / 3) - 12
//                   : (constraints.maxWidth / 1.05),
//               child: _buildStatCard(
//                 item['title'] as String,
//                 item['value'] as String,
//                 item['desc'] as String,
//                 item['color'] as Color,
//               ),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }
//
//   Widget _buildStatCard(
//       String title, String value, String subtitle, Color color) {
//     return Card(
//       elevation: 3,
//       color: color,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(14),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title,
//                 style:
//                 const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//             const SizedBox(height: 4),
//             Text(value,
//                 style:
//                 const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
//             const SizedBox(height: 4),
//             Text(subtitle,
//                 style: const TextStyle(color: Colors.grey, fontSize: 12)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // 🔹 GRAMMAR CARD
//   Widget _buildGrammarCard() {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 3,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: const [
//                 Icon(Icons.menu_book, color: Colors.green),
//                 SizedBox(width: 8),
//                 Text("12 English Tenses",
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//               ],
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton.icon(
//               onPressed: () =>
//                   setState(() => _isGrammarTableExpanded = !_isGrammarTableExpanded),
//               icon: Icon(_isGrammarTableExpanded
//                   ? Icons.keyboard_arrow_up
//                   : Icons.keyboard_arrow_down),
//               label: Text(
//                   _isGrammarTableExpanded ? "Hide Table" : "Show Table"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF5E5CE6),
//                 foregroundColor: Colors.white,
//                 shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//             ),
//             AnimatedCrossFade(
//               duration: const Duration(milliseconds: 300),
//               crossFadeState: _isGrammarTableExpanded
//                   ? CrossFadeState.showFirst
//                   : CrossFadeState.showSecond,
//               firstChild: Padding(
//                 padding: const EdgeInsets.only(top: 12),
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: DataTable(
//                     headingRowColor:
//                     MaterialStateProperty.all(const Color(0xFFE8EAF6)),
//                     columns: const [
//                       DataColumn(label: Text('Tense')),
//                       DataColumn(label: Text('Structure')),
//                       DataColumn(label: Text('Example')),
//                     ],
//                     rows: [
//                       _buildRow('Present Simple', 'S + V(s/es)', 'I play football.'),
//                       _buildRow('Present Continuous', 'S + am/is/are + V-ing', 'I am playing football.'),
//                       _buildRow('Present Perfect', 'S + have/has + V3', 'I have played football.'),
//                       _buildRow('Present Perfect Continuous', 'S + have/has + been + V-ing', 'I have been playing football.'),
//                       _buildRow('Past Simple', 'S + V2', 'I played football.'),
//                       _buildRow('Past Continuous', 'S + was/were + V-ing', 'I was playing football.'),
//                       _buildRow('Past Perfect', 'S + had + V3', 'I had played football.'),
//                       _buildRow('Past Perfect Continuous', 'S + had + been + V-ing', 'I had been playing football.'),
//                       _buildRow('Future Simple', 'S + will + V', 'I will play football.'),
//                       _buildRow('Future Continuous', 'S + will + be + V-ing', 'I will be playing football.'),
//                       _buildRow('Future Perfect', 'S + will + have + V3', 'I will have played football.'),
//                       _buildRow('Future Perfect Continuous', 'S + will + have + been + V-ing', 'I will have been playing football.'),
//                     ],
//                   ),
//                 ),
//               ),
//               secondChild: const SizedBox.shrink(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   DataRow _buildRow(String tense, String structure, String example) {
//     return DataRow(cells: [
//       DataCell(Text(tense)),
//       DataCell(Text(structure)),
//       DataCell(Text(example)),
//     ]);
//   }
//
//   // 🔹 QUICK START CARD
//   Widget _buildQuickStartCard(BuildContext context) {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Row(children: const [
//             Icon(Icons.play_arrow, color: Colors.purple),
//             SizedBox(width: 8),
//             Text("Quick Start", style: TextStyle(fontWeight: FontWeight.bold)),
//           ]),
//           const SizedBox(height: 10),
//           ListTile(
//             leading: const Icon(Icons.card_giftcard, color: Colors.deepPurple),
//             title: const Text("Study Flashcards"),
//             subtitle: const Text("Learn with interactive cards"),
//             onTap: () => Navigator.push(
//                 context, MaterialPageRoute(builder: (_) => FlashcardScreen())),
//           ),
//           ListTile(
//             leading: const Icon(Icons.quiz, color: Colors.orange),
//             title: const Text("Take a Quiz"),
//             subtitle: const Text("Test your vocabulary knowledge"),
//             onTap: () async {
//               await Navigator.pushNamed(context, '/quiz');
//               await _updateStreakAfterQuiz();
//             },
//           ),
//         ]),
//       ),
//     );
//   }
//
//   Future<void> _performLogout(BuildContext context) async {
//     try {
//       if (_googleSignIn.currentUser != null) {
//         await _googleSignIn.signOut();
//         await _googleSignIn.disconnect();
//       }
//       await _auth.signOut();
//       if (mounted) Navigator.pushReplacementNamed(context, '/login');
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('Logout failed: $e')));
//       }
//     }
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flashcard_screen.dart';
import 'chat_bot_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isGrammarTableExpanded = false;

  int _currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString('lastQuizDate');
    final streak = prefs.getInt('streak') ?? 0;

    if (lastDateStr != null) {
      final lastDate = DateTime.parse(lastDateStr);
      final today = DateTime.now();

      if (_isSameDay(today, lastDate)) {
        _currentStreak = streak;
      } else if (today.difference(lastDate).inDays == 1) {
        _currentStreak = streak;
      } else if (today.difference(lastDate).inDays > 1) {
        _currentStreak = 0;
      }
    } else {
      _currentStreak = 0;
    }

    setState(() {});
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser == null) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF5E5CE6),
        title: const Text(
          'VocaMaster',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.home), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FlashcardScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.quiz),
            onPressed: () async {
              await Navigator.pushNamed(context, '/quiz');
              await _updateStreakAfterQuiz();
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Chat with AI Tutor',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatBotScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _performLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeBanner(),
            const SizedBox(height: 20),
            _buildStatsSection(),
            const SizedBox(height: 20),
            screenWidth > 600
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildGrammarCard()),
                const SizedBox(width: 16),
                Expanded(child: _buildQuickStartCard(context)),
              ],
            )
                : Column(
              children: [
                _buildGrammarCard(),
                const SizedBox(height: 16),
                _buildQuickStartCard(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStreakAfterQuiz() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString('lastQuizDate');
    final today = DateTime.now();
    int streak = prefs.getInt('streak') ?? 0;

    if (lastDateStr != null) {
      final lastDate = DateTime.parse(lastDateStr);

      if (_isSameDay(today, lastDate)) {
        // same day, no change
      } else if (today.difference(lastDate).inDays == 1) {
        streak++;
      } else {
        streak = 1;
      }
    } else {
      streak = 1;
    }

    await prefs.setInt('streak', streak);
    await prefs.setString('lastQuizDate', today.toIso8601String());

    setState(() => _currentStreak = streak);
  }

  Widget _buildWelcomeBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5E5CE6), Color(0xFF7A77FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.school, color: Colors.white, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back, ${_auth.currentUser?.displayName ?? 'Learner'}!",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  "You are on a $_currentStreak-day streak! Keep it up 🔥",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final stats = [
      {
        'title': 'Current Streak',
        'value': '$_currentStreak 🔥',
        'desc': 'Days learning',
        'color': Colors.orange[100]
      },
      {
        'title': 'Words Learned',
        'value': '120',
        'desc': 'Total vocabulary',
        'color': Colors.blue[50]
      },
      {
        'title': 'Study Time',
        'value': '4h',
        'desc': 'Total time',
        'color': Colors.green[50]
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 600;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: stats.map((item) {
            return SizedBox(
              width: isWide
                  ? (constraints.maxWidth / 3) - 12
                  : (constraints.maxWidth / 1.05),
              child: _buildStatCard(
                item['title'] as String,
                item['value'] as String,
                item['desc'] as String,
                item['color'] as Color,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, String subtitle, Color color) {
    return Card(
      elevation: 3,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(value,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildGrammarCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.menu_book, color: Colors.green),
                SizedBox(width: 8),
                Text("12 English Tenses",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => setState(
                      () => _isGrammarTableExpanded = !_isGrammarTableExpanded),
              icon: Icon(_isGrammarTableExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down),
              label: Text(
                  _isGrammarTableExpanded ? "Hide Table" : "Show Table"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5E5CE6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _isGrammarTableExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                    MaterialStateProperty.all(const Color(0xFFE8EAF6)),
                    columns: const [
                      DataColumn(label: Text('Tense')),
                      DataColumn(label: Text('Structure')),
                      DataColumn(label: Text('Example')),
                    ],
                      rows: [
                      _buildRow('Present Simple', 'S + V(s/es)', 'I play football.'),
                      _buildRow('Present Continuous', 'S + am/is/are + V-ing', 'I am playing football.'),
                      _buildRow('Present Perfect', 'S + have/has + V3', 'I have played football.'),
                      _buildRow('Present Perfect Continuous', 'S + have/has + been + V-ing', 'I have been playing football.'),
                      _buildRow('Past Simple', 'S + V2', 'I played football.'),
                      _buildRow('Past Continuous', 'S + was/were + V-ing', 'I was playing football.'),
                      _buildRow('Past Perfect', 'S + had + V3', 'I had played football.'),
                      _buildRow('Past Perfect Continuous', 'S + had + been + V-ing', 'I had been playing football.'),
                      _buildRow('Future Simple', 'S + will + V', 'I will play football.'),
                      _buildRow('Future Continuous', 'S + will + be + V-ing', 'I will be playing football.'),
                      _buildRow('Future Perfect', 'S + will + have + V3', 'I will have played football.'),
                      _buildRow('Future Perfect Continuous', 'S + will + have + been + V-ing', 'I will have been playing football.'),
                    ],
                  ),
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildRow(String tense, String structure, String example) {
    return DataRow(cells: [
      DataCell(Text(tense)),
      DataCell(Text(structure)),
      DataCell(Text(example)),
    ]);
  }

  Widget _buildQuickStartCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [
            Icon(Icons.play_arrow, color: Colors.purple),
            SizedBox(width: 8),
            Text("Quick Start", style: TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.card_giftcard, color: Colors.deepPurple),
            title: const Text("Study Flashcards"),
            subtitle: const Text("Learn with interactive cards"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FlashcardScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.quiz, color: Colors.orange),
            title: const Text("Take a Quiz"),
            subtitle: const Text("Test your vocabulary knowledge"),
            onTap: () async {
              await Navigator.pushNamed(context, '/quiz');
              await _updateStreakAfterQuiz();
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline, color: Colors.blue),
            title: const Text("Chat with AI Tutor"),
            subtitle: const Text("Practice English with AI Assistant"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatBotScreen()),
              );
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    try {
      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.signOut();
        await _googleSignIn.disconnect();
      }
      await _auth.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Logout failed: $e')));
      }
    }
  }
}

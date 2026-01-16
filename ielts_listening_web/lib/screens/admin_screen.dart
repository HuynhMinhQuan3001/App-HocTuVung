import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();
  final _exampleController = TextEditingController();
  final _searchUserController = TextEditingController();

  String _message = '';
  List<UserRecord> _users = [];
  List<Map<String, dynamic>> _vocabulary = [];
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _currentPage = 0;
  final int _itemsPerPage = 5;

  Future<void> _fetchUsers() async {
    setState(() => _message = 'Loading users...');
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        _users = snapshot.docs.map((doc) {
          return UserRecord(
            uid: doc.id,
            email: doc['email'] ?? 'No email',
            displayName: doc['displayName'],
          );
        }).toList();
        _message = _users.isEmpty ? 'No users found' : '';
      });
    } catch (e) {
      setState(() => _message = 'Error fetching users: $e');
    }
  }

  Future<void> _fetchVocabulary() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('vocabulary').get();
      setState(() {
        _vocabulary = snapshot.docs.map((doc) => doc.data()..['id'] = doc.id).toList();
      });
    } catch (e) {
      setState(() => _message = 'Error fetching vocabulary: $e');
    }
  }


  Future<void> _addVocabulary() async {
    if (_wordController.text.isEmpty || _meaningController.text.isEmpty) {
      setState(() => _message = 'Please fill word and meaning');
      return;
    }
    try {
      String id = DateTime.now().millisecondsSinceEpoch.toString();
      await FirebaseFirestore.instance.collection('vocabulary').doc(id).set({
        'word': _wordController.text.trim(),
        'meaning': _meaningController.text.trim(),
        'example': _exampleController.text.trim().isEmpty
            ? 'No example'
            : _exampleController.text.trim(),
      });
      setState(() {
        _message = 'Vocabulary added successfully';
      });
      _fetchVocabulary();
      _wordController.clear();
      _meaningController.clear();
      _exampleController.clear();
    } catch (e) {
      setState(() => _message = 'Error: $e');
    }
  }

  Future<void> _updateVocabulary(String id, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection('vocabulary').doc(id).update(data);
      setState(() => _message = 'Vocabulary updated successfully');
      _fetchVocabulary();
    } catch (e) {
      setState(() => _message = 'Error updating vocabulary: $e');
    }
  }

  Future<void> _deleteVocabulary(String id) async {
    try {
      await FirebaseFirestore.instance.collection('vocabulary').doc(id).delete();
      setState(() => _message = 'Vocabulary deleted successfully');
      _fetchVocabulary();
    } catch (e) {
      setState(() => _message = 'Error deleting vocabulary: $e');
    }
  }


  Future<void> _deleteUser(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      setState(() {
        _users.removeWhere((user) => user.uid == uid);
        _message = 'User data deleted successfully (account not deleted)';
      });
    } catch (e) {
      setState(() => _message = 'Error deleting user data: $e');
    }
  }

  void _searchUsers(String query) {
    _fetchUsers().then((_) {
      setState(() {
        _users = _users
            .where((user) =>
            user.email.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    });
  }


  Future<void> _performLogout() async {
    if (!mounted) return;

    try {
      await FirebaseAuth.instance.signOut();
      print('Firebase sign out completed');

      try {
        final bool googleSignedIn = await _googleSignIn.isSignedIn();
        if (googleSignedIn) {
          await _googleSignIn.signOut();
          try {
            await _googleSignIn.disconnect();
          } catch (_) {}
        }
      } catch (_) {}

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      print('Navigated to login (logged out)');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }


  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _fetchVocabulary();
    _searchUserController.addListener(() => _searchUsers(_searchUserController.text));
  }

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    _exampleController.dispose();
    _searchUserController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final totalPages = (_vocabulary.length / _itemsPerPage).ceil();
    final start = _currentPage * _itemsPerPage;
    final end = (_currentPage + 1) * _itemsPerPage;
    final currentPageItems = _vocabulary.sublist(
      start,
      end > _vocabulary.length ? _vocabulary.length : end,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _performLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(' Vocabulary Management',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _wordController,
                      decoration: const InputDecoration(labelText: 'Word', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _meaningController,
                      decoration: const InputDecoration(labelText: 'Meaning', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _exampleController,
                      decoration: const InputDecoration(labelText: 'Example', border: OutlineInputBorder()),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _addVocabulary,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Vocabulary'),
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    const Text('Vocabulary List',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: currentPageItems.length,
                      itemBuilder: (context, index) {
                        final vocab = currentPageItems[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(vocab['word'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(vocab['meaning']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    _wordController.text = vocab['word'];
                                    _meaningController.text = vocab['meaning'];
                                    _exampleController.text = vocab['example'] ?? '';
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Edit Vocabulary'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(controller: _wordController, decoration: const InputDecoration(labelText: 'Word')),
                                            TextField(controller: _meaningController, decoration: const InputDecoration(labelText: 'Meaning')),
                                            TextField(controller: _exampleController, decoration: const InputDecoration(labelText: 'Example'), maxLines: 2),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                          TextButton(
                                            onPressed: () {
                                              _updateVocabulary(vocab['id'], {
                                                'word': _wordController.text.trim(),
                                                'meaning': _meaningController.text.trim(),
                                                'example': _exampleController.text.trim().isEmpty ? 'No example' : _exampleController.text.trim(),
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Save'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteVocabulary(vocab['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: _currentPage > 0
                              ? () => setState(() => _currentPage--)
                              : null,
                        ),
                        Text('Page ${_currentPage + 1} / $totalPages'),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: _currentPage < totalPages - 1
                              ? () => setState(() => _currentPage++)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),


            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('👤 User Management',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _searchUserController,
                      decoration: const InputDecoration(labelText: 'Search by email', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    if (_message.isNotEmpty)
                      Text(
                        _message,
                        style: TextStyle(color: _message.contains('Error') ? Colors.red : Colors.green),
                      ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(user.email),
                              subtitle: Text('UID: ${user.uid}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteUser(user.uid),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserRecord {
  final String uid;
  final String email;
  final String? displayName;

  UserRecord({required this.uid, required this.email, this.displayName});
}

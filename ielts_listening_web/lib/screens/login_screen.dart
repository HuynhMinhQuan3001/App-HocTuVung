// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_sign_in/google_sign_in.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _auth = FirebaseAuth.instance;
//   final _firestore = FirebaseFirestore.instance;
//   final _googleSignIn = GoogleSignIn();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   String _message = '';
//   bool _isLoading = false;
//
//   // ✅ Login bằng Email + Password
//   Future<void> _signIn() async {
//     if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
//       _setMessage('Please fill in both email and password', isError: true);
//       return;
//     }
//
//     _setLoading(true);
//     try {
//       final userCredential = await _auth.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//
//       await _handleUserRole(userCredential.user!.uid, _emailController.text.trim());
//     } on FirebaseAuthException catch (e) {
//       _setMessage(_handleFirebaseError(e.code), isError: true);
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   // ✅ Đăng ký tài khoản mới
//   Future<void> _signUp() async {
//     if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
//       _setMessage('Please fill in both email and password', isError: true);
//       return;
//     }
//
//     _setLoading(true);
//     try {
//       final userCredential = await _auth.createUserWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//
//       await _firestore.collection('users').doc(userCredential.user!.uid).set({
//         'email': _emailController.text.trim(),
//         'displayName': 'User',
//         'role': 'user',
//       });
//
//       if (mounted) {
//         Navigator.pushReplacementNamed(context, '/home');
//       }
//       _setMessage('Sign up successful!');
//     } on FirebaseAuthException catch (e) {
//       _setMessage(_handleFirebaseError(e.code), isError: true);
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   // ✅ Đăng nhập bằng Google
//   Future<void> _signInWithGoogle() async {
//     try {
//       _setLoading(true);
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) {
//         _setLoading(false);
//         return; // người dùng hủy đăng nhập
//       }
//
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//       final credential = GoogleAuthProvider.credential(
//         idToken: googleAuth.idToken,
//         accessToken: googleAuth.accessToken,
//       );
//
//       final userCredential = await _auth.signInWithCredential(credential);
//       await _handleUserRole(userCredential.user!.uid, userCredential.user!.email ?? '');
//       _setMessage('Login successful!');
//     } catch (e) {
//       _setMessage('Google sign-in failed: $e', isError: true);
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   // ✅ Kiểm tra role & điều hướng
//   Future<void> _handleUserRole(String uid, String email) async {
//     final userDoc = await _firestore.collection('users').doc(uid).get();
//     final roleData = userDoc.data();
//     final role = roleData != null && roleData.containsKey('role')
//         ? (roleData['role'] as String).toLowerCase()
//         : 'user';
//
//     if (!userDoc.exists) {
//       await _firestore.collection('users').doc(uid).set({
//         'email': email,
//         'displayName': 'User',
//         'role': 'user',
//       });
//     }
//
//     if (mounted) {
//       Navigator.pushReplacementNamed(context, role == 'admin' ? '/admin' : '/home');
//     }
//   }
//
//   // ✅ Xử lý thông báo
//   void _setMessage(String msg, {bool isError = false}) {
//     setState(() {
//       _message = msg;
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: isError ? Colors.redAccent : Colors.green,
//       ),
//     );
//   }
//
//   void _setLoading(bool value) {
//     setState(() {
//       _isLoading = value;
//     });
//   }
//
//   // ✅ Xử lý lỗi Firebase
//   String _handleFirebaseError(String code) {
//     switch (code) {
//       case 'invalid-email':
//         return 'Invalid email format';
//       case 'user-not-found':
//         return 'No account found with that email';
//       case 'wrong-password':
//         return 'Incorrect password';
//       case 'email-already-in-use':
//         return 'Email already in use';
//       case 'weak-password':
//         return 'Password should be at least 6 characters';
//       default:
//         return 'Authentication failed: $code';
//     }
//   }
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   // ✅ Giao diện đẹp hơn
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FF),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Card(
//             elevation: 6,
//             shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//             child: Padding(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(Icons.school, color: Color(0xFF5E5CE6), size: 60),
//                   const SizedBox(height: 12),
//                   const Text("VocaMaster",
//                       style:
//                       TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 30),
//
//                   // Email
//                   TextField(
//                     controller: _emailController,
//                     decoration: InputDecoration(
//                       labelText: 'Email',
//                       prefixIcon: const Icon(Icons.email),
//                       filled: true,
//                       fillColor: Colors.grey[100],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//
//                   // Password
//                   TextField(
//                     controller: _passwordController,
//                     decoration: InputDecoration(
//                       labelText: 'Password',
//                       prefixIcon: const Icon(Icons.lock),
//                       filled: true,
//                       fillColor: Colors.grey[100],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     obscureText: true,
//                   ),
//                   const SizedBox(height: 20),
//
//                   // Nút login
//                   _isLoading
//                       ? const CircularProgressIndicator()
//                       : ElevatedButton(
//                     onPressed: _signIn,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF5E5CE6),
//                       minimumSize: const Size(double.infinity, 48),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                     ),
//                     child: const Text('Login',
//                         style: TextStyle(fontSize: 18)),
//                   ),
//
//                   const SizedBox(height: 10),
//
//                   // Nút signup
//                   TextButton(
//                     onPressed: _signUp,
//                     child: const Text("Don't have an account? Sign Up"),
//                   ),
//
//                   const Divider(height: 30),
//
//                   // Nút Google login
//                   OutlinedButton.icon(
//                     onPressed: _signInWithGoogle,
//                     icon: Image.network(
//                       'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
//                       height: 24,
//                     ),
//                     label: const Text('Sign in with Google'),
//                     style: OutlinedButton.styleFrom(
//                       minimumSize: const Size(double.infinity, 48),
//                       side: const BorderSide(color: Color(0xFF5E5CE6)),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//
//                   if (_message.isNotEmpty) ...[
//                     const SizedBox(height: 10),
//                     Text(
//                       _message,
//                       style: TextStyle(
//                         color: _message.contains('fail')
//                             ? Colors.red
//                             : Colors.green,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _message = '';


  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '983635513077-npn3ehg3s74ppom2e6jsfpnti15aakh0.apps.googleusercontent.com'
        : null,
  );


  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('Please fill in both email and password', isError: true);
      return;
    }

    _setLoading(true);
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await _handleUserRole(userCredential.user!.uid, _emailController.text.trim());
    } on FirebaseAuthException catch (e) {
      _showMessage(_handleFirebaseError(e.code), isError: true);
    } finally {
      _setLoading(false);
    }
  }


  Future<void> _signUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('Please fill in both email and password', isError: true);
      return;
    }

    _setLoading(true);
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': _emailController.text.trim(),
        'displayName': 'User',
        'role': 'user',
      });

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
      _showMessage('Sign up successful!');
    } on FirebaseAuthException catch (e) {
      _showMessage(_handleFirebaseError(e.code), isError: true);
    } finally {
      _setLoading(false);
    }
  }
  Future<void> _signInWithGoogle() async {
    try {
      _setLoading(true);

      if (kIsWeb) {

        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        final userCredential = await _auth.signInWithPopup(googleProvider);
        final user = userCredential.user;

        if (user != null) {
          await _handleUserRole(user.uid, user.email ?? '');
          _showMessage('Login successful!');
        } else {
          _showMessage('Login failed', isError: true);
        }
      } else {

        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          _setLoading(false);
          return;
        }

        final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        final userCredential =
        await _auth.signInWithCredential(credential);
        await _handleUserRole(
          userCredential.user!.uid,
          userCredential.user!.email ?? '',
        );
        _showMessage('Login successful!');
      }
    } on FirebaseAuthException catch (e) {
      _showMessage('Google sign-in failed: ${e.message}', isError: true);
    } catch (e) {
      _showMessage('Google sign-in error: $e', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  // Đăng nhập bằng Google
  // Future<void> _signInWithGoogle() async {
  //   try {
  //     _setLoading(true);
  //
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) {
  //       _setLoading(false);
  //       return; // Hủy đăng nhập
  //     }
  //
  //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  //
  //     final credential = GoogleAuthProvider.credential(
  //       idToken: googleAuth.idToken,
  //       accessToken: googleAuth.accessToken,
  //     );
  //
  //     final userCredential = await _auth.signInWithCredential(credential);
  //     await _handleUserRole(
  //       userCredential.user!.uid,
  //       userCredential.user!.email ?? '',
  //     );
  //     _showMessage('Login successful!');
  //   } on FirebaseAuthException catch (e) {
  //     _showMessage('Google sign-in failed: ${e.message}', isError: true);
  //   } catch (e) {
  //     _showMessage('Google sign-in error: $e', isError: true);
  //   } finally {
  //     _setLoading(false);
  //   }
  // }


  Future<void> _handleUserRole(String uid, String email) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final roleData = userDoc.data();
    final role = roleData != null && roleData.containsKey('role')
        ? (roleData['role'] as String).toLowerCase()
        : 'user';

    if (!userDoc.exists) {
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'displayName': 'User',
        'role': 'user',
      });
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, role == 'admin' ? '/admin' : '/home');
    }
  }


  void _showMessage(String msg, {bool isError = false}) {
    setState(() => _message = msg);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  void _setLoading(bool value) => setState(() => _isLoading = value);


  String _handleFirebaseError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Invalid email format';
      case 'user-not-found':
        return 'No account found with that email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'weak-password':
        return 'Password should be at least 6 characters';
      default:
        return 'Authentication failed: $code';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.school, color: Color(0xFF5E5CE6), size: 60),
                  const SizedBox(height: 12),
                  const Text(
                    "VocaMaster",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),


                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),


                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),


                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E5CE6),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Login', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 10),

                  // Nút signup
                  TextButton(
                    onPressed: _signUp,
                    child: const Text("Don't have an account? Sign Up"),
                  ),

                  const Divider(height: 30),

                  // Google Login
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    icon: Image.network(
                      'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                      height: 24,
                    ),
                    label: Text(
                      _isLoading ? 'Logging in...' : 'Sign in with Google',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      side: const BorderSide(color: Color(0xFF5E5CE6)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  if (_message.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      _message,
                      style: TextStyle(
                        color: _message.contains('fail') ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  final String apiKey = 'AIzaSyDd8C_vZYeLwKfITJcjoNGRKELhwgyk-rE';
  final String modelName = 'models/gemini-2.0-flash-lite-001';

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': message});
      _isLoading = true;
    });

    _scrollToBottom();

    final endpoint =
        'https://generativelanguage.googleapis.com/v1beta/$modelName:generateContent?key=$apiKey';

    final body = {
      "contents": [
        {
          "parts": [
            {"text": message}
          ]
        }
      ],
      "generationConfig": {"temperature": 0.7, "maxOutputTokens": 512}
    };

    Future<void> callApi() async {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print(' Status: ${response.statusCode}');
      print(' Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
            'Không có phản hồi từ AI.';
        setState(() {
          _messages.add({'role': 'bot', 'text': reply});
        });
        _scrollToBottom();
      } else if (response.statusCode == 503) {
        await Future.delayed(const Duration(seconds: 2));
        await callApi();
      } else {
        String msg = 'Lỗi ${response.statusCode}';
        try {
          final err = jsonDecode(response.body);
          msg = err['error']?['message'] ?? msg;
        } catch (_) {}
        setState(() {
          _messages.add({'role': 'bot', 'text': 'API Error: $msg'});
        });
        _scrollToBottom();
      }
    }

    try {
      await callApi();
    } catch (e) {
      setState(() {
        _messages.add({'role': 'bot', 'text': 'Lỗi: $e'});
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('💬ChatBot'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return _buildMessageBubble(msg['text']!, isUser);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(width: 12),
                  Text('AI đang suy nghĩ...',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.android, color: Colors.white, size: 18),
            ),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color:
                isUser ? Colors.blueAccent : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft:
                  isUser ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight:
                  isUser ? const Radius.circular(4) : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border:
        Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Nhập câu hỏi cho AI...',
                prefixIcon: const Icon(Icons.chat_bubble_outline,
                    color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (text) {
                if (text.trim().isNotEmpty && !_isLoading) {
                  final msg = text.trim();
                  _controller.clear();
                  sendMessage(msg);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isLoading
                ? null
                : () {
              final text = _controller.text.trim();
              if (text.isNotEmpty) {
                _controller.clear();
                sendMessage(text);
              }
            },
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.deepPurple,
              child: Icon(
                _isLoading ? Icons.hourglass_bottom : Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _Message {
  final String text;
  final bool isMe;
  final String time;
  const _Message(
      {required this.text, required this.isMe, required this.time});
}

const List<_Message> _messages = [
  _Message(
      text: 'Lorem Ipsum is simply dummy\ntext of the printing',
      isMe: false,
      time: ''),
  _Message(text: 'Lorem Ipsum', isMe: true, time: ''),
  _Message(
      text: 'Lorem Ipsum is simply dummy\ntext of the printing',
      isMe: false,
      time: ''),
  _Message(
      text: 'Lorem Ipsum is simply dummy\ntext of the printing',
      isMe: false,
      time: '05:52 PM'),
];

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final _msgCtrl = TextEditingController();
  final List<_Message> _msgs = List.from(_messages);

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _msgs.add(_Message(text: text, isMe: true, time: ''));
      _msgCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFEAF4FB), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _msgs.length,
                  itemBuilder: (context, index) =>
                      _buildBubble(_msgs[index]),
                ),
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.menu, size: 24, color: Colors.black87),
          const SizedBox(width: 14),
          Text('Message',
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w700)),
          const Spacer(),
          const Icon(Icons.email_outlined, size: 22, color: Colors.black87),
          const SizedBox(width: 12),
          Stack(
            children: [
              const Icon(Icons.notifications_none,
                  size: 26, color: Colors.black87),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      color: Colors.orange, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          const CircleAvatar(
            radius: 17,
            backgroundImage: NetworkImage(
                'https://randomuser.me/api/portraits/men/32.jpg'),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(_Message msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!msg.isMe)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: const CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(
                    'https://randomuser.me/api/portraits/men/45.jpg'),
              ),
            ),
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: const BoxConstraints(maxWidth: 260),
            decoration: BoxDecoration(
              color: msg.isMe ? Colors.green : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(msg.isMe ? 18 : 4),
                bottomRight: Radius.circular(msg.isMe ? 4 : 18),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Text(
              msg.text,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: msg.isMe ? Colors.white : Colors.black87,
                  height: 1.5),
            ),
          ),
          if (msg.time.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(msg.time,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: Colors.grey[400])),
            ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          // Attachment icon
          GestureDetector(
            onTap: () {},
            child: Icon(Icons.home_outlined, color: Colors.grey[400], size: 24),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {},
            child: Icon(Icons.person_outline, color: Colors.grey[400], size: 24),
          ),
          const SizedBox(width: 12),

          // Text input
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Enter message',
                hintStyle: GoogleFonts.inter(
                    fontSize: 13, color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Send
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                  color: Colors.green, shape: BoxShape.circle),
              child: const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

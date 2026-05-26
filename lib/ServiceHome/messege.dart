import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../profile/myProfile.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      body: SafeArea(
        child: Column(
          children: [

            /// 🔝 HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.to(() => const MyProfileScreen()),
                    child: const CircleAvatar(
                      backgroundImage: NetworkImage(
                          "https://randomuser.me/api/portraits/men/32.jpg"),
                    ),
                  ),

                  const Spacer(),

                  const Text(
                    "Message",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),

                  const Spacer(),

                  const Icon(Icons.notifications_none),
                  const SizedBox(width: 10),
                  const Icon(Icons.menu),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// 💬 CHAT LIST
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [

                  /// LEFT MESSAGE
                  _leftMessage(
                    "Lorem Ipsum is simply dummy text of the printing",
                  ),

                  const SizedBox(height: 10),

                  /// RIGHT MESSAGE
                  _rightMessage("Lorem Ipsum"),

                  const SizedBox(height: 10),

                  /// LEFT SMALL
                  _leftMessage("Lorem Ipsum"),

                  const SizedBox(height: 10),

                  /// LEFT BIG + TIME
                  _leftMessageWithTime(
                      "Lorem Ipsum is simply dummy text of the printing"),
                ],
              ),
            ),

            /// ✍️ INPUT BAR
            _inputBar(),
          ],
        ),
      ),
    );
  }

  /// 🔹 LEFT MESSAGE
  Widget _leftMessage(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 14,
          backgroundImage: NetworkImage(
              "https://randomuser.me/api/portraits/men/32.jpg"),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          constraints: const BoxConstraints(maxWidth: 250),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(text),
        ),
      ],
    );
  }

  /// 🔹 RIGHT MESSAGE
  Widget _rightMessage(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 14,
          backgroundImage: NetworkImage(
              "https://randomuser.me/api/portraits/men/32.jpg"),
        ),
      ],
    );
  }

  /// 🔹 LEFT WITH TIME
  Widget _leftMessageWithTime(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _leftMessage(text),
        const SizedBox(height: 4),
        Row(
          children: const [
            SizedBox(width: 40),
            Icon(Icons.done_all, size: 16, color: Colors.grey),
            SizedBox(width: 5),
            Text("6:52 PM",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        )
      ],
    );
  }

  /// 🔹 INPUT BAR
  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [

          /// 📷 CAMERA
          const Icon(Icons.camera_alt, color: Colors.grey),

          const SizedBox(width: 10),

          /// 🖼️ GALLERY
          const Icon(Icons.image, color: Colors.grey),

          const SizedBox(width: 10),

          /// ✍️ TEXT FIELD
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Enter message...",
                border: InputBorder.none,
              ),
            ),
          ),

          /// 📤 SEND
          const Icon(Icons.send, color: Colors.green),
        ],
      ),
    );
  }
}
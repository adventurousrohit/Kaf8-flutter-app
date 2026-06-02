import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../profile/myProfile.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

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

                  Text(
                    "Message",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.textTheme.titleLarge?.color),
                  ),

                  const Spacer(),

                  Icon(Icons.notifications_none, color: theme.iconTheme.color),
                  const SizedBox(width: 10),
                  Icon(Icons.menu, color: theme.iconTheme.color),
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
                    theme,
                  ),

                  const SizedBox(height: 10),

                  /// RIGHT MESSAGE
                  _rightMessage("Lorem Ipsum"),

                  const SizedBox(height: 10),

                  /// LEFT SMALL
                  _leftMessage("Lorem Ipsum", theme),

                  const SizedBox(height: 10),

                  /// LEFT BIG + TIME
                  _leftMessageWithTime(
                      "Lorem Ipsum is simply dummy text of the printing", theme),
                ],
              ),
            ),

            /// ✍️ INPUT BAR
            _inputBar(theme),
          ],
        ),
      ),
    );
  }

  /// 🔹 LEFT MESSAGE
  Widget _leftMessage(String text, ThemeData theme) {
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
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(text, style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
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
  Widget _leftMessageWithTime(String text, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _leftMessage(text, theme),
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
  Widget _inputBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: theme.cardColor,
      child: Row(
        children: [

          /// 📷 CAMERA
          const Icon(Icons.camera_alt, color: Colors.grey),

          const SizedBox(width: 10),

          /// 🖼️ GALLERY
          const Icon(Icons.image, color: Colors.grey),

          const SizedBox(width: 10),

          /// ✍️ TEXT FIELD
          Expanded(
            child: TextField(
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: "Enter message...",
                hintStyle: TextStyle(color: Colors.grey[400]),
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
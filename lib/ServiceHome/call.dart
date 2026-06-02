import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios_new,size: 15, color: theme.iconTheme.color),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 0,),
                        Text(
                          "Back",
                          style: GoogleFonts.inter(
                            fontSize: 15 ,
                            fontWeight: FontWeight.w700,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),

                      ],
                    ),
                  ),

                  const Spacer(),

                  Text("Call",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.textTheme.titleLarge?.color)),

                  const Spacer(),

                  const SizedBox(width: 50), // balance
                ],
              ),
            ),

            const SizedBox(height: 40),

            /// 🔥 PROFILE + ANIMATION
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [

                    /// OUTER RING
                    _buildRing(150, _controller.value, 0.2),

                    /// MID RING
                    _buildRing(110, _controller.value, 0.3),

                    /// INNER RING
                    _buildRing(80, _controller.value, 0.4),

                    /// PROFILE IMAGE
                    const CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(
                          "https://randomuser.me/api/portraits/men/32.jpg"),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),

            /// NAME
            Text(
              "Cliff Rogers",
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
            ),

            const SizedBox(height: 8),

            /// TIMER
            const Text(
              "02:35",
              style: TextStyle(color: Colors.grey),
            ),

            const Spacer(),

            /// 🔘 BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                /// VOLUME
                _circleButton(Icons.volume_up, theme),

                /// MIC
                _circleButton(Icons.mic, theme),

                /// END CALL
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.call_end,
                        color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// 🔥 RING BUILDER
  Widget _buildRing(double size, double value, double opacity) {
    return Container(
      width: size + (value * 30),
      height: size + (value * 30),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green.withOpacity(opacity * (1 - value)),
      ),
    );
  }

  /// 🔘 COMMON BUTTON
  Widget _circleButton(IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: theme.iconTheme.color),
    );
  }
}
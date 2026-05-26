import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// NOTE: Add google_maps_flutter to pubspec.yaml for a real map.
// This screen uses a placeholder map image and the exact design from the mockup.

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Full-screen map placeholder ──────────────────────────────
          SizedBox.expand(
            child: Container(
              color: const Color(0xFFE8EFE8),
              child: CustomPaint(
                painter: _FakeMapPainter(),
              ),
            ),
          ),

          // ── Distance badge (top-center) ──────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Text(
                    'Distance: 6.652 km',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ),

          // ── Home pin icon (center-right) ─────────────────────────────
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            right: MediaQuery.of(context).size.width * 0.22,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.home, color: Colors.white, size: 22),
            ),
          ),

          // ── Destination pin ──────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).size.height * 0.55,
            left: MediaQuery.of(context).size.width * 0.3,
            child: const Icon(Icons.location_on,
                color: Colors.black87, size: 32),
          ),

          // ── Bottom driver panel ──────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(
                        'https://randomuser.me/api/portraits/men/45.jpg'),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Wade Warren',
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  // Message
                  _actionBtn(Icons.email_outlined, Colors.green),
                  const SizedBox(width: 12),
                  // Call
                  _actionBtn(Icons.call, Colors.green),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color color) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FAKE MAP PAINTER (replace with google_maps_flutter in production)
// ─────────────────────────────────────────────────────────────────────────────

class _FakeMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routePaint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final bgPaint = Paint()..color = const Color(0xFFE8EFE8);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw some fake roads
    final path1 = Path()
      ..moveTo(0, size.height * 0.3)
      ..lineTo(size.width, size.height * 0.28);
    canvas.drawPath(path1, roadPaint);

    final path2 = Path()
      ..moveTo(size.width * 0.4, 0)
      ..lineTo(size.width * 0.42, size.height);
    canvas.drawPath(path2, roadPaint);

    final path3 = Path()
      ..moveTo(0, size.height * 0.55)
      ..lineTo(size.width, size.height * 0.6);
    canvas.drawPath(path3, roadPaint);

    final path4 = Path()
      ..moveTo(size.width * 0.65, 0)
      ..lineTo(size.width * 0.63, size.height);
    canvas.drawPath(path4, roadPaint);

    // Route path
    final route = Path()
      ..moveTo(size.width * 0.7, size.height * 0.3)
      ..cubicTo(
        size.width * 0.65, size.height * 0.38,
        size.width * 0.5, size.height * 0.42,
        size.width * 0.42, size.height * 0.55,
      );
    canvas.drawPath(route, routePaint);

    // Orange highway
    final highway = Paint()
      ..color = Colors.orange.shade400
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;
    final hPath = Path()
      ..moveTo(size.width * 0.8, 0)
      ..lineTo(size.width * 0.75, size.height);
    canvas.drawPath(hPath, highway);
  }

  @override
  bool shouldRepaint(_) => false;
}

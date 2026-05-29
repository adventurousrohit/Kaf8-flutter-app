import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final double radius;
  final VoidCallback? onEdit;

  const AvatarWidget({
    super.key,
    this.avatarUrl,
    required this.name,
    this.radius = 44,
    this.onEdit,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || name.trim().isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasUrl = avatarUrl != null && avatarUrl!.isNotEmpty;
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.green.shade600,
      backgroundImage: hasUrl ? NetworkImage(avatarUrl!) : null,
      child: hasUrl
          ? null
          : Text(
              _initials,
              style: GoogleFonts.inter(
                fontSize: radius * 0.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
    );

    if (onEdit == null) return avatar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: onEdit,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Service/api_service.dart';
import '../Utils/avatar_widget.dart';
import '../Utils/responsiveUtils.dart';

class FavoriteList extends StatefulWidget {
  const FavoriteList({super.key});
  @override
  State<FavoriteList> createState() => _FavoriteListState();
}

class _FavoriteListState extends State<FavoriteList> {
  bool _loading = true;
  List<Map<String, dynamic>> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _loading = true);
    final res = await ApiService.getFavorites();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res['success'] == true && res['data'] is List) {
        _favorites = List<Map<String, dynamic>>.from(
          (res['data'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
        );
      }
    });
  }

  Future<void> _removeFavorite(int index) async {
    final fav = _favorites[index];
    final transporterId = fav['transporterId']?.toString() ?? '';
    final res = await ApiService.removeFavorite(transporterId);
    if (!mounted) return;
    if (res['success'] == true) {
      setState(() => _favorites.removeAt(index));
    } else {
      Get.snackbar('error'.tr,
          res['message']?.toString() ?? 'Failed to remove',
          backgroundColor: Colors.red, colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  String _name(Map<String, dynamic> fav) {
    final profile = fav['TransporterProfile'];
    if (profile is! Map) return '—';
    final user = profile['User'];
    if (user is! Map) return '—';
    final first = user['firstName']?.toString() ?? '';
    final last  = user['lastName']?.toString() ?? '';
    return '$first $last'.trim();
  }

  String? _avatar(Map<String, dynamic> fav) {
    final profile = fav['TransporterProfile'];
    if (profile is! Map) return null;
    final user = profile['User'];
    if (user is! Map) return null;
    return user['avatar']?.toString();
  }

  String _rating(Map<String, dynamic> fav) {
    final profile = fav['TransporterProfile'];
    if (profile is! Map) return '—';
    final r = profile['averageRating'];
    if (r == null) return '—';
    return double.tryParse(r.toString())?.toStringAsFixed(1) ?? r.toString();
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveUtils.fontScale(context);
    final size      = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Background shapes ──────────────────────────────────────
          Positioned(top: 0, left: 0,
              child: Image.asset('assets/images/bg_top_left.png',
                  width: size.width * 0.62, fit: BoxFit.contain,
                  opacity: AlwaysStoppedAnimation(isDark ? 0.05 : 0.20))),
          Positioned(top: 0, right: 0,
              child: Transform(alignment: Alignment.center,
                  transform: Matrix4.rotationY(3.14159),
                  child: Image.asset('assets/images/bg_bottom_right.png',
                      width: size.width * 0.36, fit: BoxFit.contain,
                      opacity: AlwaysStoppedAnimation(isDark ? 0.04 : 0.13)))),
          Positioned(bottom: 0, right: 0,
              child: Image.asset('assets/images/bg_bottom_right.png',
                  width: size.width * 0.55, fit: BoxFit.contain,
                  opacity: AlwaysStoppedAnimation(isDark ? 0.08 : 0.30))),
          Positioned(bottom: 0, left: 0,
              child: Transform(alignment: Alignment.center,
                  transform: Matrix4.rotationY(3.14159),
                  child: Image.asset('assets/images/bg_bottom_right.png',
                      width: size.width * 0.32, fit: BoxFit.contain,
                      opacity: AlwaysStoppedAnimation(isDark ? 0.03 : 0.14)))),

          SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────
                Container(
                  color: theme.appBarTheme.backgroundColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: isDark ? Colors.white24 : Colors.grey[800]!, width: 1.8)),
                          child: Icon(Icons.arrow_back_ios_new,
                              size: 15, color: theme.iconTheme.color),
                        ),
                      ),
                      const Spacer(),
                      Text('favourite_list_title'.tr,
                          style: GoogleFonts.inter(
                              fontSize: 17 * fontScale,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.titleLarge?.color)),
                      const Spacer(),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Body ─────────────────────────────────────────────
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _favorites.isEmpty
                          ? _emptyState(fontScale)
                          : RefreshIndicator(
                              onRefresh: _loadFavorites,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                                itemCount: _favorites.length,
                                itemBuilder: (_, i) =>
                                    _buildCard(i, fontScale, theme),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(double fontScale) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('no_favourites'.tr,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 14 * fontScale,
                    color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(int index, double fontScale, ThemeData theme) {
    final fav  = _favorites[index];
    final name   = _name(fav);
    final avatar = _avatar(fav);
    final rating = _rating(fav);

    return Dismissible(
      key: Key(fav['id']?.toString() ?? index.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => _removeFavorite(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor, width: 1),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: label + remove button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('delivery_driver'.tr,
                    style: GoogleFonts.inter(
                        fontSize: 11 * fontScale,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.87))),
                GestureDetector(
                  onTap: () => _removeFavorite(index),
                  child: Container(
                    width: 28, height: 28,
                    decoration: const BoxDecoration(
                        color: Colors.green, shape: BoxShape.circle),
                    child: const Icon(Icons.favorite,
                        size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Profile row
            Row(
              children: [
                AvatarWidget(
                  avatarUrl: avatar,
                  name: name,
                  radius: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: GoogleFonts.inter(
                              fontSize: 15 * fontScale,
                              fontWeight: FontWeight.w700,
                              color: theme.textTheme.bodyLarge?.color)),
                      const SizedBox(height: 4),
                      if (rating != '—')
                        Row(children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          const SizedBox(width: 3),
                          Text(rating,
                              style: GoogleFonts.inter(
                                  fontSize: 11 * fontScale,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textTheme.bodySmall?.color)),
                        ]),
                    ],
                  ),
                ),
                Row(children: [
                  _greenBtn(Icons.graphic_eq),
                  const SizedBox(width: 8),
                  _greenBtn(Icons.call),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _greenBtn(IconData icon) => Container(
    width: 34, height: 34,
    decoration: const BoxDecoration(
        color: Colors.green, shape: BoxShape.circle),
    child: Icon(icon, size: 16, color: Colors.white),
  );
}

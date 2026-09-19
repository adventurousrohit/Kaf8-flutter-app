import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Service/api_service.dart';

// NOTE: Add fl_chart to pubspec.yaml for a production chart.
// This screen uses a custom painter for the bar/line charts.

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _earningsFilter = 'Weekly';
  String _ordersFilter = 'Weekly';
  bool _isLoading = false;
  int _totalOrders = 0;
  double _totalEarnings = 0;

  // Fake earnings data (Mon–Sun)
  final List<double> _earningsData = [
    20, 45, 30, 80, 55, 70, 90,
    40, 60, 35, 75, 50, 65, 85
  ];

  // Fake orders data (Mon–Sun) — smaller values
  final List<double> _ordersData = [
    8, 22, 14, 35, 20, 28, 38,
    15, 25, 12, 30, 18, 24, 33
  ];

  List<String> _xLabels = List.generate(24, (i) => '$i:00');

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final period = _earningsFilter == "Weekly" ? "last7days" : "last30days";
    final summary = await ApiService.getStatistics(period: period);
    final earnings = await ApiService.getEarningsStats(period: period);
    final orders = await ApiService.getOrdersStats(period: period);

    if (!mounted) return;

    if (summary['success'] == true && summary['data'] is Map<String, dynamic>) {
      final summaryData = summary['data']['summary'] ?? {};
      _totalOrders = int.tryParse("${summaryData['totalOrders'] ?? 0}") ?? 0;
      _totalEarnings = double.tryParse("${summaryData['totalEarnings'] ?? 0}") ?? 0;
    }
    if (earnings['success'] == true && earnings['data'] is List) {
      final list = earnings['data'] as List;
      _earningsData
        ..clear()
        ..addAll(list.map((e) => double.tryParse("${e['value'] ?? 0}") ?? 0));
      _xLabels
        ..clear()
        ..addAll(list.map((e) => "${e['hour'] ?? ''}"));
    }
    if (orders['success'] == true && orders['data'] is List) {
      _ordersData
        ..clear()
        ..addAll((orders['data'] as List)
            .map((e) => double.tryParse("${e['value'] ?? 0}") ?? 0));
    }
    setState(() => _isLoading = false);
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
            _buildAppBar(theme),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildSummaryRow(theme),
                  const SizedBox(height: 20),
                  _buildChartCard(
                    title: 'Earnings',
                    value: '€ ${_totalEarnings.toStringAsFixed(2)}',
                    filter: _earningsFilter,
                    onFilterChange: (v) {
                      setState(() => _earningsFilter = v);
                      _loadStats();
                    },
                    data: _earningsData,
                    labels: _xLabels,
                    isBar: true,
                    color: Colors.green,
                    theme: theme,
                  ),
                  const SizedBox(height: 20),
                  _buildChartCard(
                    title: 'Orders',
                    value: '$_totalOrders',
                    filter: _ordersFilter,
                    onFilterChange: (v) {
                      setState(() => _ordersFilter = v);
                      _loadStats();
                    },
                    data: _ordersData,
                    labels: _xLabels,
                    isBar: false,
                    color: Colors.green,
                    theme: theme,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios_new,
                size: 20, color: theme.iconTheme.color),
          ),
          const SizedBox(width: 14),
          Text('Statistics',
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w700, color: theme.textTheme.titleLarge?.color)),
          const Spacer(),
          Stack(
            children: [
              Icon(Icons.notifications_none,
                  size: 26, color: isDark ? Colors.white70 : Colors.black87),
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

  Widget _buildSummaryRow(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
              label: 'Total Orders', value: '$_totalOrders', icon: Icons.list_alt, theme: theme),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _summaryCard(
              label: 'Total Earnings',
              value: '€ ${_totalEarnings.toStringAsFixed(2)}',
              icon: Icons.attach_money,
              theme: theme),
        ),
      ],
    );
  }

  Widget _summaryCard(
      {required String label,
      required String value,
      required IconData icon,
      required ThemeData theme}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12, color: theme.textTheme.bodySmall?.color)),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 22, fontWeight: FontWeight.w800, color: theme.textTheme.titleLarge?.color)),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required String value,
    required String filter,
    required ValueChanged<String> onFilterChange,
    required List<double> data,
    required List<String> labels,
    required bool isBar,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w700, color: theme.textTheme.titleLarge?.color)),
              const Spacer(),
              _filterChip(filter, onFilterChange),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: isBar
                ? _BarChartPainterWidget(data: data, labels: labels, color: color, theme: theme)
                : _LineChartPainterWidget(data: data, labels: labels, color: color, theme: theme),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String current, ValueChanged<String> onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: GestureDetector(
        onTap: () =>
            onChange(current == 'Weekly' ? 'Monthly' : 'Weekly'),
        child: Text(current,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BAR CHART PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _BarChartPainterWidget extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final Color color;
  final ThemeData theme;
  const _BarChartPainterWidget(
      {required this.data, required this.labels, required this.color, required this.theme});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarChartPainter(data: data, labels: labels, color: color, theme: theme),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final Color color;
  final ThemeData theme;
  _BarChartPainter(
      {required this.data, required this.labels, required this.color, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final max = data.reduce((a, b) => a > b ? a : b);
    final barWidth = (size.width - 20) / data.length - 4;
    final paint = Paint()..color = color;
    final dimPaint = Paint()..color = color.withOpacity(0.3);

    for (int i = 0; i < data.length; i++) {
      final x = 10.0 + i * ((size.width - 20) / data.length);
      final barH = (data[i] / (max == 0 ? 1 : max)) * (size.height - 24);
      final isHigh = data[i] == max;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              x, size.height - 24 - barH, barWidth, barH),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        isHigh ? paint : dimPaint,
      );
    }

    // X labels
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < labels.length && i < data.length; i += 2) {
      final x = 10.0 + i * ((size.width - 20) / data.length);
      tp.text = TextSpan(
        text: labels[i],
        style: TextStyle(fontSize: 9, color: theme.textTheme.bodySmall?.color),
      );
      tp.layout();
      tp.paint(canvas,
          Offset(x + barWidth / 2 - tp.width / 2, size.height - 18));
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// LINE CHART PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _LineChartPainterWidget extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final Color color;
  final ThemeData theme;
  const _LineChartPainterWidget(
      {required this.data, required this.labels, required this.color, required this.theme});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter:
          _LineChartPainter(data: data, labels: labels, color: color, theme: theme),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final Color color;
  final ThemeData theme;
  _LineChartPainter(
      {required this.data, required this.labels, required this.color, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final max = data.reduce((a, b) => a > b ? a : b);
    final stepX = (size.width - 20) / (data.length == 1 ? 1 : (data.length - 1));
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withOpacity(0.2), color.withOpacity(0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height - 20));

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = 10.0 + i * stepX;
      final y = (size.height - 24) -
          (data[i] / (max == 0 ? 1 : max)) * (size.height - 24);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height - 24);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(
        10.0 + (data.length - 1) * stepX, size.height - 24);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // X labels
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < labels.length && i < data.length; i += 2) {
      final x = 10.0 + i * stepX;
      tp.text = TextSpan(
        text: labels[i],
        style: TextStyle(fontSize: 9, color: theme.textTheme.bodySmall?.color),
      );
      tp.layout();
      tp.paint(canvas,
          Offset(x - tp.width / 2, size.height - 18));
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

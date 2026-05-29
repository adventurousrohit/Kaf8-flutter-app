import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Service/api_service.dart';
import '../profile/myProfile.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isLoading = false;
  int _totalOrders = 0;
  double _totalEarnings = 0;
  String _period = 'last7days';

  List<double> earningsData = List.filled(24, 0);
  List<double> ordersData = List.filled(24, 0);

  final List<String> timeLabels = [
    "0:00","2:00","4:00","6:00","8:00","10:00",
    "12:00","14:00","16:00","18:00","20:00","22:00"
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final summary  = await ApiService.getStatistics(period: _period);
    final earnings = await ApiService.getEarningsStats(period: _period);
    final orders   = await ApiService.getOrdersStats(period: _period);

    if (!mounted) return;

    if (summary['success'] == true && summary['data'] is Map) {
      final s = (summary['data'] as Map)['summary'] ?? {};
      _totalOrders   = int.tryParse("${s['totalOrders'] ?? 0}") ?? 0;
      _totalEarnings = double.tryParse("${s['totalEarnings'] ?? 0}") ?? 0;
    }
    if (earnings['success'] == true && earnings['data'] is List) {
      earningsData = (earnings['data'] as List)
          .map((e) => double.tryParse("${e['value'] ?? 0}") ?? 0)
          .toList();
    }
    if (orders['success'] == true && orders['data'] is List) {
      ordersData = (orders['data'] as List)
          .map((e) => double.tryParse("${e['value'] ?? 0}") ?? 0)
          .toList();
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                  const Text("Statistics",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() => _period = _period == 'last7days' ? 'last30days' : 'last7days');
                      _loadStats();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _period == 'last7days' ? 'Last 7 Days' : 'Last 30 Days',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.notifications_none),
                  const SizedBox(width: 10),
                  const Icon(Icons.menu),
                ],
              ),
            ),

            // Summary
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Summary(title: "Total Orders",   value: "$_totalOrders"),
                  _Summary(title: "Total Earnings", value: "€ ${_totalEarnings.toStringAsFixed(2)}"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children: [
                        _chartCard(
                          title: "Earnings",
                          child: BarChart(_barChartData()),
                        ),
                        const SizedBox(height: 20),
                        _chartCard(
                          title: "Orders",
                          child: LineChart(_lineChartData()),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartData _barChartData() {
    final maxY = earningsData.isEmpty ? 10.0 : (earningsData.reduce((a, b) => a > b ? a : b) * 1.2).clamp(1.0, double.infinity);
    return BarChartData(
      minY: 0,
      maxY: maxY,
      alignment: BarChartAlignment.spaceBetween,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: Colors.grey.shade300, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        topTitles:    AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:  AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxY / 4,
            reservedSize: 36,
            getTitlesWidget: (value, _) =>
                Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 30,
            getTitlesWidget: (value, _) {
              final i = value.toInt();
              if (i % 4 == 0 && i ~/ 2 < timeLabels.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(timeLabels[i ~/ 2], style: const TextStyle(fontSize: 9)),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(earningsData.length, (i) {
        return BarChartGroupData(x: i, barRods: [
          BarChartRodData(
            toY: earningsData[i],
            width: 6,
            borderRadius: BorderRadius.circular(3),
            color: Colors.green,
          ),
        ]);
      }),
    );
  }

  LineChartData _lineChartData() {
    final maxY = ordersData.isEmpty ? 10.0 : (ordersData.reduce((a, b) => a > b ? a : b) * 1.2).clamp(1.0, double.infinity);
    return LineChartData(
      minX: 0,
      maxX: (ordersData.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: Colors.grey.shade300, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        topTitles:   AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxY / 4,
            reservedSize: 36,
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 30,
            getTitlesWidget: (value, _) {
              final i = value.toInt();
              if (i % 4 == 0 && i ~/ 2 < timeLabels.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(timeLabels[i ~/ 2], style: const TextStyle(fontSize: 9)),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          curveSmoothness: 0.35,
          color: Colors.green.shade700,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.green.withOpacity(0.08),
          ),
          spots: List.generate(ordersData.length,
              (i) => FlSpot(i.toDouble(), ordersData[i])),
        ),
      ],
    );
  }

  Widget _chartCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text("Hourly",
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(height: 200, child: child),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final String title;
  final String value;
  const _Summary({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 5),
        Text(value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../profile/myProfile.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {

  /// 🔥 DATA (24 HOURS)
  final List<double> earningsData = [
    5, 10, 20, 5, 25, 5, 48, 5, 35, 10, 15, 10,
    15, 20, 30, 20, 25, 35, 10, 50, 10, 35, 15, 5
  ];

  final List<double> ordersData = [
    22, 25, 30, 32, 21, 26, 40, 38, 18, 25, 20, 28,
    42, 30, 32, 18, 38, 20, 35, 37, 28, 24, 22, 21
  ];

  final List<String> timeLabels = [
    "1am","3am","5am","7am","9am","11am",
    "1pm","3pm","5pm","7pm","9pm","11pm"
  ];

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
                  const Text("Statistics",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  const Icon(Icons.notifications_none),
                  const SizedBox(width: 10),
                  const Icon(Icons.menu),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🔥 SUMMARY
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Summary(title: "Total Orders", value: "250"),
                  _Summary(title: "Total Earnings", value: "₹ 1,23,456"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: [

                  /// 📊 BAR CHART
                  _chartCard(
                    title: "Earnings",
                    child: BarChart(_barChartData()),
                  ),

                  const SizedBox(height: 20),

                  /// 📈 LINE CHART
                  _chartCard(
                    title: "Orders",
                    child: LineChart(_lineChartData()),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// ================= BAR CHART =================
  BarChartData _barChartData() {
    return BarChartData(
      minY: 0,
      maxY: 60,
      alignment: BarChartAlignment.spaceBetween,

      /// GRID
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 10,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: Colors.grey.shade300, strokeWidth: 1),
        getDrawingVerticalLine: (value) =>
            FlLine(color: Colors.grey.shade200, strokeWidth: 1),
      ),

      /// TITLES FIXED HERE ✅
      titlesData: FlTitlesData(

        /// ❌ REMOVE TOP
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),

        /// ❌ REMOVE RIGHT
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),

        /// ✅ LEFT SIDE
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 10,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              return Text(
                "${value.toInt()}",
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),

        /// ✅ BOTTOM TIME
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();

              if (index % 2 == 0 && index ~/ 2 < timeLabels.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    timeLabels[index ~/ 2],
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),

      borderData: FlBorderData(show: false),

      /// DATA
      barGroups: List.generate(24, (i) {
        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: earningsData[i],
              width: 6,
              borderRadius: BorderRadius.circular(3),
              color: Colors.green,
            ),
          ],
        );
      }),
    );
  }

  /// ================= LINE CHART =================
  LineChartData _lineChartData() {
    return LineChartData(
      minX: 0,
      maxX: 23,
      minY: 0,
      maxY: 60,

      /// GRID
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 10,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: Colors.grey.shade300, strokeWidth: 1),
        getDrawingVerticalLine: (value) =>
            FlLine(color: Colors.grey.shade200, strokeWidth: 1),
      ),

      /// TITLES FIXED HERE ✅
      titlesData: FlTitlesData(

        /// ❌ REMOVE TOP
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),

        /// ❌ REMOVE RIGHT
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),

        /// ✅ LEFT
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 10,
            reservedSize: 30,
          ),
        ),

        /// ✅ BOTTOM
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();

              if (index % 2 == 0 && index ~/ 2 < timeLabels.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    timeLabels[index ~/ 2],
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),

      borderData: FlBorderData(show: false),

      /// LINE
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          curveSmoothness: 0.35,
          color: Colors.green.shade700,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),

          spots: List.generate(
            24,
                (i) => FlSpot(i.toDouble(), ordersData[i]),
          ),
        ),
      ],
    );
  }

  /// ================= CARD =================
  Widget _chartCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
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
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text("Last 10 Days",
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              )
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(height: 200, child: child),
        ],
      ),
    );
  }
}

/// 🔹 SUMMARY
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
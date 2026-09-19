import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🌟 ফায়ারবেস ইমপোর্ট করা হয়েছে

class DashboardPage extends StatefulWidget { // 🌟 StatelessWidget থেকে StatefulWidget করা হয়েছে
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // ডেটা ফেচ করার জন্য ফিউচার ভেরিয়েবল
  late Future<Map<String, int>> _summaryDataFuture;

  @override
  void initState() {
    super.initState();
    _summaryDataFuture = _fetchSummaryData();
  }

  Future<Map<String, int>> _fetchSummaryData() async {
    final firestore = FirebaseFirestore.instance;

    try {
      // 🌟 নতুন: Daily Active Users (গত ২৪ ঘণ্টার ইউজার)
      final yesterday = DateTime.now().subtract(const Duration(hours: 24));
      final dailyActiveUsersSnap = await firestore.collection('users')
          .where('lastActive', isGreaterThanOrEqualTo: yesterday.toIso8601String())
          .count().get();

      // Total Users (ছোট ব্যাজে দেখানোর জন্য)
      final totalUsersSnap = await firestore.collection('users').count().get();

      // ২. Active Requests এবং Ongoing Donations (আগের মতোই থাকবে)
      final activeRequestsSnap = await firestore.collection('requests')
          .where('status', isEqualTo: 'Active')
          .get();

      int activeRequestsCount = activeRequestsSnap.docs.length;
      int activeBagsCount = 0;
      int ongoingDonationsCount = 0;

      for (var doc in activeRequestsSnap.docs) {
        final data = doc.data();
        activeBagsCount += (data['bags'] as num?)?.toInt() ?? 0;
        ongoingDonationsCount += (data['acceptedBags'] as num?)?.toInt() ?? 0;
      }

      return {
        'dailyActiveUsers': dailyActiveUsersSnap.count ?? 0, // 👈 নতুন ডেটা
        'totalUsers': totalUsersSnap.count ?? 0,             // 👈 টোটাল ইউজার
        'requests': activeRequestsCount,
        'activeBags': activeBagsCount,
        'donations': ongoingDonationsCount,
      };
    } catch (e) {
      debugPrint("Error fetching data: $e");
      return {'dailyActiveUsers': 0, 'totalUsers': 0, 'requests': 0, 'activeBags': 0, 'donations': 0};
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message & Date Filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Welcome back, Admin', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                  SizedBox(height: 4),
                  Text("Here's what's happening with Jibon today.", style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                  child: Row(
                    children: const [
                      Text('20 Aug - 26 Aug 2026', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600, fontSize: 13)),
                      SizedBox(width: 8),
                      Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF475569)),
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 24),

          // 🌟 FutureBuilder দিয়ে Cards-এ রিয়েল ডেটা বসানো হয়েছে
          FutureBuilder<Map<String, int>>(
            future: _summaryDataFuture,
            builder: (context, snapshot) {
              // ডেটা লোড হওয়ার সময় লোডিং আইকন দেখাবে
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator(color: Color(0xFFE63946)))
                );
              }

              // ডেটা ফায়ারবেস থেকে আসার পর ভেরিয়েবলে রাখা হচ্ছে
              final data = snapshot.data ?? {'users': 0, 'requests': 0, 'donations': 0};

              return Row(
                children: [
                  _buildSummaryCard(
                      title: 'Daily Active Users', // 👈 কার্ডের নতুন নাম
                      value: data['dailyActiveUsers'].toString(), // 👈 লাইভ ইউজার কাউন্ট
                      extraText: 'Total ${data['totalUsers']}',   // 👈 ছোট ব্যাজে টোটাল ইউজার
                      growth: '+12%', // চাইলে এটিও ডায়নামিক করতে পারেন ভবিষ্যতে
                      icon: Icons.people,
                      iconColor: Colors.blue,
                      iconBgColor: Colors.blue.withOpacity(0.1)
                  ),
                  const SizedBox(width: 24),
                  _buildSummaryCard(
                      title: 'Active Requests',
                      value: data['requests'].toString(), // 👈 রিয়েল ডেটা
                      extraText: 'Need ${data['activeBags']} Bags',
                      growth: '+6%',
                      icon: Icons.bloodtype,
                      iconColor: const Color(0xFFE63946),
                      iconBgColor: const Color(0xFFFFF5F5)
                  ),
                  const SizedBox(width: 24),
                  _buildSummaryCard(
                      title: 'Ongoing Donations',
                      value: data['donations'].toString(), // 👈 রিয়েল ডেটা
                      growth: '+18%',
                      icon: Icons.favorite,
                      iconColor: Colors.green,
                      iconBgColor: Colors.green.withOpacity(0.1)
                  ),
                  const SizedBox(width: 24),
                  _buildSummaryCard(
                      title: 'Available Credits (+)',
                      value: '14,500', // 👈 এটি ডাইনামিক করতে চাইলে sum() ব্যবহার করতে হবে
                      extraText: '-3,200 Debt',
                      growth: '+5%',
                      icon: Icons.star,
                      iconColor: Colors.amber,
                      iconBgColor: Colors.amber.withOpacity(0.1)
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Charts
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: _buildLineChartCard()),
              const SizedBox(width: 24),
              Expanded(flex: 3, child: _buildDonutChartCard()),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: _buildCityWiseUsersCard()),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ================= Helper Functions for Dashboard =================

  Widget _buildSummaryCard({required String title, required String value, required String growth, required IconData icon, required Color iconColor, required Color iconBgColor, String? extraText}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(value, style: const TextStyle(color: Colors.black87, fontSize: 28, fontWeight: FontWeight.bold)),
                      if (extraText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(8)),
                          child: Text(extraText, style: const TextStyle(color: const Color(0xFFE63946), fontSize: 11, fontWeight: FontWeight.bold)),
                        )
                      ]
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.arrow_upward, color: Colors.green, size: 14),
                      const SizedBox(width: 4),
                      Text(growth, style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 6),
                      const Text('vs. 30 days', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChartCard() {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Blood Requests & Donations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(children: [_buildLegendIndicator(const Color(0xFFE63946), 'Requests'), const SizedBox(width: 16), _buildLegendIndicator(Colors.blue, 'Donations')])
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 20),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1, reservedSize: 30, getTitlesWidget: (value, meta) {
                    const days = ['7 Sep', '8 Sep', '9 Sep', '10 Sep', '11 Sep', '12 Sep', '13 Sep', '14 Sep'];
                    if (value.toInt() >= 0 && value.toInt() < days.length) { return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(days[value.toInt()], style: const TextStyle(color: Colors.grey, fontSize: 12))); }
                    return const Text('');
                  })),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 20, reservedSize: 40, getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: const TextStyle(color: Colors.grey, fontSize: 12)))),
                ),
                borderData: FlBorderData(show: false), minX: 0, maxX: 7, minY: 0, maxY: 80,
                lineBarsData: [
                  LineChartBarData(spots: const [FlSpot(0, 30), FlSpot(1, 32), FlSpot(2, 50), FlSpot(3, 38), FlSpot(4, 46), FlSpot(5, 60), FlSpot(6, 45), FlSpot(7, 55)], isCurved: true, color: const Color(0xFFE63946), barWidth: 3, dotData: const FlDotData(show: true), belowBarData: BarAreaData(show: true, color: const Color(0xFFE63946).withOpacity(0.1))),
                  LineChartBarData(spots: const [FlSpot(0, 15), FlSpot(1, 16), FlSpot(2, 30), FlSpot(3, 12), FlSpot(4, 24), FlSpot(5, 40), FlSpot(6, 25), FlSpot(7, 30)], isCurved: true, color: Colors.blue, barWidth: 3, dotData: const FlDotData(show: true), belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonutChartCard() {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Blood Group Wise Users', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 45, sections: [
                        PieChartSectionData(color: const Color(0xFFE63946), value: 37, title: '', radius: 25),
                        PieChartSectionData(color: const Color(0xFF3B82F6), value: 28, title: '', radius: 25),
                        PieChartSectionData(color: const Color(0xFF22C55E), value: 13, title: '', radius: 25),
                        PieChartSectionData(color: const Color(0xFF8D6E63), value: 8, title: '', radius: 25),
                        PieChartSectionData(color: const Color(0xFF6366F1), value: 7, title: '', radius: 25),
                        PieChartSectionData(color: const Color(0xFF0EA5E9), value: 5, title: '', radius: 25),
                        PieChartSectionData(color: const Color(0xFF78909C), value: 2, title: '', radius: 25),
                        PieChartSectionData(color: const Color(0xFF546E7A), value: 1, title: '', radius: 25),
                      ])),
                      Column(mainAxisSize: MainAxisSize.min, children: const [Text('Total', style: TextStyle(color: Colors.grey, fontSize: 12)), Text('6,320', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text('Users', style: TextStyle(color: Colors.grey, fontSize: 12))]),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendRow(const Color(0xFFE63946), 'O+', '37%', '(2,339)'), _buildLegendRow(const Color(0xFF3B82F6), 'A+', '28%', '(1,769)'), _buildLegendRow(const Color(0xFF22C55E), 'B+', '13%', '(822)'), _buildLegendRow(const Color(0xFF8D6E63), 'O-', '8%', '(506)'), _buildLegendRow(const Color(0xFF6366F1), 'A-', '7%', '(443)'), _buildLegendRow(const Color(0xFF0EA5E9), 'B-', '5%', '(316)'), _buildLegendRow(const Color(0xFF78909C), 'AB+', '2%', '(126)'), _buildLegendRow(const Color(0xFF546E7A), 'AB-', '1%', '(63)'),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendIndicator(Color color, String text) {
    return Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 6), Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12))]);
  }

  Widget _buildLegendRow(Color color, String title, String percentage, String count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87))]),
          Row(children: [Text(percentage, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)), const SizedBox(width: 6), SizedBox(width: 45, child: Text(count, style: const TextStyle(color: Colors.grey, fontSize: 12)))]),
        ],
      ),
    );
  }

  Widget _buildCityWiseUsersCard() {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('City-wise Users', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('View All →', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold))
              ]
          ),
          const SizedBox(height: 16),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('City', style: TextStyle(fontSize: 11, color: Colors.grey)),
                Text('Total Users', style: TextStyle(fontSize: 11, color: Colors.grey))
              ]
          ),
          const SizedBox(height: 12),

          _buildCityRow('Dhaka', '5,420'),
          _buildCityRow('Chattogram', '2,840'),
          _buildCityRow('Sylhet', '1,250'),
          _buildCityRow('Rajshahi', '1,100'),
          _buildCityRow('Khulna', '980'),
          _buildCityRow('Others', '868'),
        ],
      ),
    );
  }

  Widget _buildCityRow(String city, String count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(city, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
          Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }
}
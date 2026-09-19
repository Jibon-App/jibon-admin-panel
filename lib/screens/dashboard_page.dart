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

      final usersSnap = await firestore.collection('users').get();

      int totalPositiveCredits = 0;
      int totalNegativeCredits = 0;

      for (var doc in usersSnap.docs) {
        final data = doc.data();
        final int userCredits = (data['availableCredits'] as num?)?.toInt() ?? 0;

        if (userCredits > 0) {
          totalPositiveCredits += userCredits;
        } else if (userCredits < 0) {
          totalNegativeCredits += userCredits;
        }
      }

      return {
        'dailyActiveUsers': dailyActiveUsersSnap.count ?? 0,
        'totalUsers': totalUsersSnap.count ?? 0,
        'requests': activeRequestsCount,
        'activeBags': activeBagsCount,
        'donations': ongoingDonationsCount,
        'totalPositiveCredits': totalPositiveCredits,
        'totalNegativeCredits': totalNegativeCredits,
      };
    } catch (e) {
      debugPrint("Error fetching data: $e");
      return {'dailyActiveUsers': 0, 'totalUsers': 0, 'requests': 0, 'activeBags': 0, 'donations': 0, 'totalPositiveCredits': 0, 'totalNegativeCredits': 0};
    }
  }

  // এই ফাংশনটি আপনার _DashboardPageState ক্লাসের ভেতরে রাখুন
  Future<Map<String, dynamic>> _fetchChartData() async {
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();
    final sevenDaysAgo = DateTime(now.year, now.month, now.day - 6); // আজ সহ গত ৭ দিন

    // গত ৭ দিনের রিকোয়েস্টগুলো ফেচ করা হচ্ছে (মাত্র ৭ দিনের ডেটা রিড হবে)
    final snapshot = await firestore.collection('requests')
        .where('createdAt', isGreaterThanOrEqualTo: sevenDaysAgo)
        .get();

    // ৭ দিনের জন্য ডেটা জিরো (0) দিয়ে ইনিশিয়ালাইজ করা
    Map<String, int> dailyRequests = {};
    Map<String, int> dailyDonations = {};
    List<String> daysList = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = '${date.day} ${_getMonthName(date.month)}'; // e.g. "14 Sep"
      daysList.add(dateStr);
      dailyRequests[dateStr] = 0;
      dailyDonations[dateStr] = 0;
    }

    // ফায়ারবেস থেকে পাওয়া ডেটাগুলোকে দিনের হিসেবে ভাগ করা
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      final bags = int.tryParse(data['bags']?.toString() ?? '0') ?? 0;
      final completedBags = (data['completedDonors'] as List?)?.length ?? 0;

      if (createdAt != null) {
        final dateStr = '${createdAt.day} ${_getMonthName(createdAt.month)}';
        if (dailyRequests.containsKey(dateStr)) {
          // রিকোয়েস্ট হওয়া ব্যাগের সংখ্যা যোগ
          dailyRequests[dateStr] = dailyRequests[dateStr]! + bags;
          // কমপ্লিট হওয়া ব্যাগের সংখ্যা যোগ
          dailyDonations[dateStr] = dailyDonations[dateStr]! + completedBags;
        }
      }
    }

    // FlSpot (গ্রাফের পয়েন্ট) তৈরি করা
    List<FlSpot> requestSpots = [];
    List<FlSpot> donationSpots = [];

    for (int i = 0; i < daysList.length; i++) {
      final dateStr = daysList[i];
      requestSpots.add(FlSpot(i.toDouble(), dailyRequests[dateStr]!.toDouble()));
      donationSpots.add(FlSpot(i.toDouble(), dailyDonations[dateStr]!.toDouble()));
    }

    return {
      'days': daysList,
      'requestSpots': requestSpots,
      'donationSpots': donationSpots,
    };
  }

  // 🌟 Pie Chart এর জন্য কোটা-বান্ধব ডেটা ফেচিং 🌟
  Future<Map<String, int>> _fetchBloodGroupData() async {
    final firestore = FirebaseFirestore.instance;
    final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
    final Map<String, int> counts = {};

    try {
      // Future.wait দিয়ে সবগুলো count query একসাথে ফায়ার করা হচ্ছে (অত্যন্ত ফাস্ট)
      final futures = bloodGroups.map((bg) =>
          firestore.collection('users').where('bloodGroup', isEqualTo: bg).count().get()
      );

      final results = await Future.wait(futures);

      int total = 0;
      for (int i = 0; i < bloodGroups.length; i++) {
        final count = results[i].count ?? 0;
        counts[bloodGroups[i]] = count;
        total += count;
      }

      counts['Total'] = total;
      return counts;

    } catch (e) {
      debugPrint("Error fetching blood groups: $e");
      return {'Total': 0};
    }
  }

  // মাসের নাম পাওয়ার হেল্পার ফাংশন
  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message & Date
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

              // 🌟 ড্রপডাউনের বদলে ডায়নামিক আজকের তারিখ 🌟
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300)
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Color(0xFF475569)),
                    const SizedBox(width: 8),
                    Text(
                        _getFormattedTodayDate(), // 👈 ডায়নামিক ফাংশন
                        style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600, fontSize: 13)
                    ),
                  ],
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
                    value: (data['totalPositiveCredits'] ?? 0).toString(), // 👈 রিয়েল পজিটিভ ক্রেডিট
                    extraText: (data['totalNegativeCredits'] != null && data['totalNegativeCredits']! < 0)
                        ? '${data['totalNegativeCredits']} Debt'
                        : null, // 👈 মাইনাস থাকলে শুধু তখনই লাল ব্যাজ দেখাবে
                    growth: '+5%',
                    icon: Icons.star,
                    iconColor: Colors.amber,
                    iconBgColor: Colors.amber.withOpacity(0.1),
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
      child: FutureBuilder<Map<String, dynamic>>(
          future: _fetchChartData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFE63946)));
            }

            if (!snapshot.hasData) return const Center(child: Text('No data available'));

            final days = snapshot.data!['days'] as List<String>;
            final requestSpots = snapshot.data!['requestSpots'] as List<FlSpot>;
            final donationSpots = snapshot.data!['donationSpots'] as List<FlSpot>;

            // গ্রাফের সর্বোচ্চ Y ভ্যালু নির্ধারণ (যাতে গ্রাফ সুন্দরভাবে ফিট হয়)
            double maxY = 20;
            for (var spot in requestSpots) { if (spot.y > maxY) maxY = spot.y; }
            maxY = maxY + 10; // গ্রাফের ওপরে একটু ফাঁকা জায়গা রাখার জন্য

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Blood Requests & Donations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Row(children: [
                      _buildLegendIndicator(const Color(0xFFE63946), 'Requested Bags'),
                      const SizedBox(width: 16),
                      // 🌟 নীল থেকে সবুজ করা হলো
                      _buildLegendIndicator(Colors.green, 'Completed Donations')
                    ])
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 10),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1, reservedSize: 30, getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < days.length) {
                            return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(days[index], style: const TextStyle(color: Colors.grey, fontSize: 11)));
                          }
                          return const Text('');
                        })),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: (maxY / 4).roundToDouble(), reservedSize: 35, getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: const TextStyle(color: Colors.grey, fontSize: 11)))),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0, maxX: 6,
                      minY: 0, maxY: maxY,
                      lineBarsData: [
                        // লাল লাইন (Requests)
                        LineChartBarData(
                            spots: requestSpots,
                            isCurved: true, color: const Color(0xFFE63946), barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(show: true, color: const Color(0xFFE63946).withOpacity(0.1))
                        ),
                        // 🌟 সবুজ লাইন (Donations)
                        LineChartBarData(
                            spots: donationSpots,
                            isCurved: true, color: Colors.green, barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.1))
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
      ),
    );
  }

  Widget _buildDonutChartCard() {
    // 🌟 ব্লাড গ্রুপের জন্য নির্দিষ্ট কালার কোড
    final bgColors = {
      'O+': const Color(0xFFE63946),
      'A+': const Color(0xFF3B82F6),
      'B+': const Color(0xFF22C55E),
      'O-': const Color(0xFF8D6E63),
      'A-': const Color(0xFF6366F1),
      'B-': const Color(0xFF0EA5E9),
      'AB+': const Color(0xFF78909C),
      'AB-': const Color(0xFF546E7A),
    };

    return Container(
      height: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: FutureBuilder<Map<String, int>>(
          future: _fetchBloodGroupData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFE63946)));
            }

            final data = snapshot.data ?? {'Total': 0};
            final int totalUsers = data['Total'] ?? 0;

            // 🌟 স্ক্রিনশটের মতো বেশি থেকে কম (Descending) অনুযায়ী সাজানো হচ্ছে
            var sortedEntries = data.entries.where((e) => e.key != 'Total').toList();
            sortedEntries.sort((a, b) => b.value.compareTo(a.value));

            // পাই চার্টের সেকশন তৈরি
            List<PieChartSectionData> pieSections = [];
            if (totalUsers == 0) {
              // ডেটা না থাকলে ডিফল্ট গ্রে কালারের রিং দেখাবে
              pieSections.add(PieChartSectionData(color: Colors.grey.shade200, value: 1, title: '', radius: 25));
            } else {
              for (var entry in sortedEntries) {
                if (entry.value > 0) {
                  pieSections.add(PieChartSectionData(
                    color: bgColors[entry.key] ?? Colors.grey,
                    value: entry.value.toDouble(),
                    title: '',
                    radius: 25,
                  ));
                }
              }
            }

            return Column(
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
                            PieChart(
                                PieChartData(
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 45,
                                    sections: pieSections
                                )
                            ),
                            Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Total', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  Text(totalUsers.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  const Text('Users', style: TextStyle(color: Colors.grey, fontSize: 12))
                                ]
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: totalUsers == 0
                            ? const Center(child: Text("No users found", style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: sortedEntries.length,
                          itemBuilder: (context, index) {
                            final entry = sortedEntries[index];
                            if (entry.value == 0) return const SizedBox.shrink(); // ০ ভ্যালু হলে লিস্টে দেখাবে না

                            // পার্সেন্টেজ হিসাব
                            final percentage = ((entry.value / totalUsers) * 100).round();

                            return _buildLegendRow(
                                bgColors[entry.key] ?? Colors.grey,
                                entry.key,
                                '$percentage%',
                                '(${entry.value})'
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          }
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

  String _getFormattedTodayDate() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${now.day} ${months[now.month - 1]}, ${now.year}';
  }
}
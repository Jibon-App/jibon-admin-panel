import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<bool> selectedNotifs = List.generate(5, (index) => false);
  bool selectAll = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= ১. পেজ হেডার =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                    child: const Icon(Icons.notifications_active_outlined, color: Color(0xFFE63946)),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Push Notifications', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                      SizedBox(height: 4),
                      Text('Send emergency alerts, updates, and track notification history.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.send, size: 18, color: Colors.white),
                label: const Text('Send New Alert', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE63946),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              )
            ],
          ),
          const SizedBox(height: 24),

          // ================= ২. টপ ৪টি সামারি কার্ড =================
          Row(
            children: [
              _buildStatCard('Total Sent', '4,250', '+12%', Icons.send_to_mobile, Colors.blue),
              const SizedBox(width: 20),
              _buildStatCard('Average Open Rate', '76%', '+5%', Icons.visibility_outlined, Colors.green),
              const SizedBox(width: 20),
              _buildStatCard('Scheduled', '3', '-', Icons.schedule_send, Colors.orange),
              const SizedBox(width: 20),
              _buildStatCard('Failed Deliveries', '12', '-2%', Icons.error_outline, Colors.red, isNegative: true),
            ],
          ),
          const SizedBox(height: 24),

          // ================= ৩. ফিল্টার এবং সার্চ =================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search alerts by title or keywords...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildDropdownFilter('Target Audience', 'All'),
                const SizedBox(width: 16),
                _buildDropdownFilter('Status', 'All'),
                const SizedBox(width: 16),
                Container(
                  height: 42, padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                  child: Row(children: const [Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey), SizedBox(width: 8), Text('This Month', style: TextStyle(fontSize: 13))]),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {}, icon: const Icon(Icons.search, size: 16, color: Colors.white), label: const Text('Search', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ================= ৪. মেইন ডেটা টেবিল =================
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent Alerts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),

                // টেবিল উইথ স্ট্রেচ লজিক
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: constraints.maxWidth),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.grey.shade50),
                          horizontalMargin: 20, columnSpacing: 25, dataRowMinHeight: 75, dataRowMaxHeight: 75,
                          columns: [
                            DataColumn(label: Checkbox(value: selectAll, onChanged: (v) { setState(() { selectAll = v!; for (int i = 0; i < selectedNotifs.length; i++) { selectedNotifs[i] = v; } }); }, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)))),
                            const DataColumn(label: Text('Notification Content', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Target Audience', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Date & Time', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Open Rate', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Status', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Actions', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                          ],
                          rows: [
                            _buildDataRow(0, 'NT-892', 'Emergency: O+ Blood Needed!', 'Patient in critical condition at Dhaka Medical.', 'O+ Users (Dhaka)', 'Today, 10:45 AM', '82%', 'Sent'),
                            _buildDataRow(1, 'NT-891', 'System Maintenance Notice', 'App will be offline tonight from 2 AM to 4 AM.', 'All Users', 'Today, 11:30 PM', '-', 'Scheduled'),
                            _buildDataRow(2, 'NT-890', 'Thank you for your donation 💖', 'Your recent donation helped save a life.', 'Recent Donors', 'Yesterday, 05:00 PM', '95%', 'Sent'),
                            _buildDataRow(3, 'NT-889', 'Urgent: AB- Blood Required', 'Accident case at Square Hospital. Pls respond.', 'AB- Users', '14 Sep 2026', '65%', 'Sent'),
                            _buildDataRow(4, 'NT-888', 'Complete Your Profile', 'You can now add your location to get local alerts.', 'Inactive Users', '10 Sep 2026', '45%', 'Sent'),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const Divider(height: 1, color: Color(0xFFEEEEEE)),

                // প্যাজিনেশন
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Showing 1 to 5 of 4,250 Alerts', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Row(
                        children: [
                          _buildPageButton(Icons.chevron_left), const SizedBox(width: 8),
                          _buildPageNumber('1', true), const SizedBox(width: 8),
                          _buildPageNumber('2', false), const SizedBox(width: 8),
                          const Text('...', style: TextStyle(color: Colors.grey)), const SizedBox(width: 8),
                          _buildPageButton(Icons.chevron_right),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ================= হেল্পার ফাংশনস =================

  Widget _buildStatCard(String title, String count, String growth, IconData icon, Color color, {bool isNegative = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(count, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(isNegative ? Icons.arrow_downward : Icons.arrow_upward, color: isNegative ? Colors.red : Colors.green, size: 14),
                      const SizedBox(width: 4),
                      Text(growth, style: TextStyle(color: isNegative ? Colors.red : Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFilter(String label, String value) {
    return Expanded(
      flex: 1,
      child: Container(
        height: 42, padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(value, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)), const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey)])
          ],
        ),
      ),
    );
  }

  // 🌟 ডেটা রো
  DataRow _buildDataRow(int index, String id, String title, String body, String target, String date, String openRate, String status) {
    return DataRow(
      cells: [
        DataCell(Checkbox(value: selectedNotifs[index], onChanged: (v) { setState(() { selectedNotifs[index] = v!; }); }, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)))),

        // Notification Title & Body
        DataCell(
            SizedBox(
              width: 250,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(body, style: const TextStyle(color: Colors.grey, fontSize: 11), overflow: TextOverflow.ellipsis, maxLines: 1),
                ],
              ),
            )
        ),

        // Target Audience Badge
        DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(target, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11)),
            )
        ),

        DataCell(Text(date, style: const TextStyle(color: Colors.black54, fontSize: 12))),
        DataCell(Text(openRate, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold))),
        DataCell(_buildStatusBadge(status)),

        // থ্রি-ডট মেনু
        DataCell(
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
              splashRadius: 20, tooltip: 'Manage Alert', color: const Color(0xFFFFF9F9), elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), offset: const Offset(0, 40),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.visibility_outlined, size: 18, color: Colors.blue), SizedBox(width: 12), Text('View Stats', style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500))])),
                if (status == 'Scheduled') const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18, color: Colors.orange), SizedBox(width: 12), Text('Edit Scheduled', style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500))])),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 12), Text('Delete Alert', style: TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.w600))])),
              ],
              onSelected: (action) { debugPrint('Clicked $action on $id'); },
            )
        ),
      ],
    );
  }

  // Status Badge Logic
  Widget _buildStatusBadge(String status) {
    Color bgColor, textColor;
    if (status == 'Sent') { bgColor = Colors.green.withOpacity(0.1); textColor = Colors.green; }
    else if (status == 'Scheduled') { bgColor = Colors.orange.withOpacity(0.1); textColor = Colors.orange.shade700; }
    else { bgColor = Colors.red.withOpacity(0.1); textColor = Colors.red; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPageButton(IconData icon) { return Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)), child: Icon(icon, size: 16, color: Colors.black54)); }
  Widget _buildPageNumber(String number, bool isActive) { return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: isActive ? const Color(0xFF0F172A) : Colors.transparent, border: Border.all(color: isActive ? const Color(0xFF0F172A) : Colors.transparent), borderRadius: BorderRadius.circular(4)), child: Text(number, style: TextStyle(color: isActive ? Colors.white : Colors.black54, fontSize: 13, fontWeight: FontWeight.bold))); }
}
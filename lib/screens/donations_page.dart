import 'package:flutter/material.dart';

class DonationsPage extends StatefulWidget {
  const DonationsPage({super.key});

  @override
  State<DonationsPage> createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage> {
  List<bool> selectedDonations = List.generate(6, (index) => false);
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
                    child: const Icon(Icons.favorite_border, color: Color(0xFFE63946)),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Donation Records', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                      SizedBox(height: 4),
                      Text('Track successful donations, verify pending ones, and manage credits.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text('Manual Entry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              _buildStatCard('Total Donations', '6,320', '+18%', Icons.volunteer_activism, Colors.blue),
              const SizedBox(width: 20),
              _buildStatCard('Verified', '6,150', '+22%', Icons.verified_user_outlined, Colors.green),
              const SizedBox(width: 20),
              _buildStatCard('Pending Verification', '170', '-5%', Icons.pending_actions, Colors.orange),
              const SizedBox(width: 20),
              _buildStatCard('Credits Rewarded', '307K', '+12%', Icons.stars, Colors.amber),
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
                        hintText: 'Search by donor name, hospital, or ID...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildDropdownFilter('Blood Group', 'All'),
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
                      const Text('Recent Donations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      OutlinedButton.icon(
                        onPressed: () {}, icon: const Icon(Icons.file_download_outlined, size: 16, color: Colors.black87), label: const Text('Export', style: TextStyle(color: Colors.black87)),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      ),
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
                            DataColumn(label: Checkbox(value: selectAll, onChanged: (v) { setState(() { selectAll = v!; for (int i = 0; i < selectedDonations.length; i++) { selectedDonations[i] = v; } }); }, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)))),
                            const DataColumn(label: Text('Record ID', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Donor Details', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Blood Group', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Location / Hospital', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Date & Time', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Credits', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Status', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Actions', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                          ],
                          rows: [
                            // 🌟 সব ডোনেশনে রিকোয়েস্ট রেফারেন্স যুক্ত করা হয়েছে (Voluntary বাদ)
                            _buildDataRow(0, '#DN-5021', 'Req: #RQ-9819', 'Rafiqul Hasan', 'USR-2931', 'O+', 'Dhaka Medical College', 'Today, 10:30 AM', '+50', 'Verified'),
                            _buildDataRow(1, '#DN-5020', 'Req: #RQ-9818', 'Sadia Akter', 'USR-8820', 'A+', 'Square Hospital, Dhaka', 'Today, 09:15 AM', '+50', 'Verified'),
                            _buildDataRow(2, '#DN-5019', 'Req: #RQ-9815', 'Mehedi Hasan', 'USR-1193', 'B+', 'Sylhet MAG Osmani', 'Yesterday, 04:45 PM', '0', 'Pending'),
                            _buildDataRow(3, '#DN-5018', 'Req: #RQ-9710', 'Nusrat Jahan', 'USR-2910', 'O-', 'Evercare Hospital', '14 Sep 2026', '+50', 'Verified'),
                            _buildDataRow(4, '#DN-5017', 'Req: #RQ-9705', 'Kamrul Hasan', 'USR-4421', 'A-', 'Rajshahi Medical', '13 Sep 2026', '0', 'Rejected'),
                            _buildDataRow(5, '#DN-5016', 'Req: #RQ-9699', 'Farzana Islam', 'USR-9932', 'AB+', 'Khulna City Hospital', '12 Sep 2026', '+50', 'Verified'),
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
                      const Text('Showing 1 to 6 of 6,320 Donations', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Row(
                        children: [
                          _buildPageButton(Icons.chevron_left), const SizedBox(width: 8),
                          _buildPageNumber('1', true), const SizedBox(width: 8),
                          _buildPageNumber('2', false), const SizedBox(width: 8),
                          _buildPageNumber('3', false), const SizedBox(width: 8),
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

  Widget _buildStatCard(String title, String count, String growth, IconData icon, Color color) {
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
                      Icon(Icons.arrow_upward, color: Colors.green, size: 14),
                      const SizedBox(width: 4),
                      Text(growth, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
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

  // 🌟 আপডেটেড ডেটা রো (Req Ref সহ ১০টি প্যারামিটার)
  DataRow _buildDataRow(int index, String recordId, String reqRef, String donorName, String donorId, String bloodGroup, String hospital, String date, String credits, String status) {
    return DataRow(
      cells: [
        DataCell(Checkbox(value: selectedDonations[index], onChanged: (v) { setState(() { selectedDonations[index] = v!; }); }, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)))),

        // 🌟 Record ID এবং Req Ref একসাথে
        DataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(recordId, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(reqRef, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            )
        ),

        // Donor Details (Avatar, Name, ID)
        DataCell(
            Row(
              children: [
                CircleAvatar(radius: 16, backgroundColor: Colors.blue.withOpacity(0.1), child: Text(donorName[0], style: const TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold))),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(donorName, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(donorId, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                )
              ],
            )
        ),

        DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFE63946).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(bloodGroup, style: const TextStyle(color: Color(0xFFE63946), fontWeight: FontWeight.bold, fontSize: 13)),
            )
        ),
        DataCell(
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                SizedBox(width: 140, child: Text(hospital, style: const TextStyle(color: Colors.black87, fontSize: 12), overflow: TextOverflow.ellipsis)),
              ],
            )
        ),
        DataCell(Text(date, style: const TextStyle(color: Colors.black54, fontSize: 12))),

        // Credits Earned
        DataCell(
            Row(
              children: [
                if (credits != '0') const Icon(Icons.star, color: Colors.amber, size: 16),
                if (credits != '0') const SizedBox(width: 4),
                Text(credits == '0' ? '-' : credits, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            )
        ),

        DataCell(_buildStatusBadge(status)),

        // থ্রি-ডট মেনু
        DataCell(
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
              splashRadius: 20, tooltip: 'Manage Record', color: const Color(0xFFFFF9F9), elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), offset: const Offset(0, 40),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.visibility_outlined, size: 18, color: Colors.blue), SizedBox(width: 12), Text('View Proof', style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500))])),
                if (status == 'Pending') const PopupMenuItem(value: 'verify', child: Row(children: [Icon(Icons.verified_outlined, size: 18, color: Colors.green), SizedBox(width: 12), Text('Verify & Reward', style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500))])),
                if (status == 'Pending') const PopupMenuItem(value: 'reject', child: Row(children: [Icon(Icons.cancel_outlined, size: 18, color: Colors.orange), SizedBox(width: 12), Text('Reject Entry', style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500))])),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 12), Text('Delete Record', style: TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.w600))])),
              ],
              onSelected: (action) { debugPrint('Clicked $action on $recordId'); },
            )
        ),
      ],
    );
  }

  // 🌟 Status Badge Logic
  Widget _buildStatusBadge(String status) {
    Color bgColor, textColor;
    if (status == 'Verified') { bgColor = Colors.green.withOpacity(0.1); textColor = Colors.green; }
    else if (status == 'Pending') { bgColor = Colors.orange.withOpacity(0.1); textColor = Colors.orange.shade700; }
    else { bgColor = Colors.red.withOpacity(0.1); textColor = Colors.red; } // Rejected

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPageButton(IconData icon) { return Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)), child: Icon(icon, size: 16, color: Colors.black54)); }
  Widget _buildPageNumber(String number, bool isActive) { return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: isActive ? const Color(0xFF0F172A) : Colors.transparent, border: Border.all(color: isActive ? const Color(0xFF0F172A) : Colors.transparent), borderRadius: BorderRadius.circular(4)), child: Text(number, style: TextStyle(color: isActive ? Colors.white : Colors.black54, fontSize: 13, fontWeight: FontWeight.bold))); }
}
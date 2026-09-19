import 'package:flutter/material.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  // চেক বক্সের স্টেট ধরে রাখার জন্য একটি লিস্ট (ডামি ডেটার জন্য)
  List<bool> selectedUsers = List.generate(10, (index) => false);
  bool selectAll = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= ১. পেজ হেডার এবং Add User বাটন =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                    child: const Icon(Icons.people_outline, color: Colors.black87),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Users', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                      SizedBox(height: 4),
                      Text('Manage all users, view details and take necessary actions.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text('Add New User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              _buildStatCard('Total Users', '12,458', '+12%', Icons.people, Colors.blue),
              const SizedBox(width: 20),
              _buildStatCard('Active Users', '11,892', '+10%', Icons.verified_user_outlined, Colors.green),
              const SizedBox(width: 20),
              _buildStatCard('Total Donors', '6,320', '+15%', Icons.volunteer_activism, Colors.purple),
              const SizedBox(width: 20),
              _buildStatCard('Blocked Users', '23', '-4%', Icons.gpp_bad_outlined, Colors.red, isNegative: true),
            ],
          ),
          const SizedBox(height: 24),

          // ================= ৩. ফিল্টার এবং সার্চ সেকশন =================
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
                        hintText: 'Search by name, phone, or user ID...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildDropdownFilter('Gender', 'All'),
                const SizedBox(width: 16),
                _buildDropdownFilter('Status', 'All'),
                const SizedBox(width: 16),
                _buildDropdownFilter('Blood Group', 'All'),
                const SizedBox(width: 16),
                Container(
                  height: 42, padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                  child: Row(children: const [Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey), SizedBox(width: 8), Text('All Dates', style: TextStyle(fontSize: 13))]),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {}, icon: const Icon(Icons.refresh, size: 16, color: Colors.black87), label: const Text('Reset', style: TextStyle(color: Colors.black87)),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {}, icon: const Icon(Icons.search, size: 16, color: Colors.white), label: const Text('Search', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ================= ৪. ডেটা টেবিল সেকশন =================
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // টেবিল হেডার (Title & Export Button)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Users (12,458)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      OutlinedButton.icon(
                        onPressed: () {}, icon: const Icon(Icons.file_download_outlined, size: 16, color: Colors.black87), label: const Text('Export', style: TextStyle(color: Colors.black87)),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),

                // মেইন টেবিল
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: constraints.maxWidth), // 🌟 ডানদিকের ফাঁকা জায়গা পূরণ করবে
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.grey.shade50),
                          horizontalMargin: 20,
                          columnSpacing: 20,
                          dataRowMinHeight: 70,
                          dataRowMaxHeight: 70,
                          columns: [
                            DataColumn(label: Checkbox(value: selectAll, onChanged: (v) { setState(() { selectAll = v!; for (int i = 0; i < selectedUsers.length; i++) { selectedUsers[i] = v; } }); }, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)))),
                            const DataColumn(label: Text('User ID', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Name', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Phone', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Gender', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Blood Group', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Donations', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Credits', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Status', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Joined Date', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Actions', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                          ],
                          rows: [
                            _buildDataRow(0, '1', 'Rafiqul Hasan', '+8801712345678', 'Male', 'O+', '5', '50', 'Active', '12 Sep 2026'),
                            _buildDataRow(1, '2', 'Sadia Akter', '+8801811122233', 'Female', 'A+', '2', '20', 'Active', '10 Sep 2026'),
                            _buildDataRow(2, '3', 'Tanim Ahmed', '+8801822233344', 'Male', 'B+', '0', '0', 'Active', '08 Sep 2026'),
                            _buildDataRow(3, '4', 'Nusrat Jahan', '+8801911112211', 'Female', 'O-', '8', '80', 'Active', '06 Sep 2026'),
                            _buildDataRow(4, '5', 'Mehedi Hasan', '+8801700001122', 'Male', 'A-', '0', '-10', 'Active', '05 Sep 2026'),
                            _buildDataRow(5, '6', 'Farzana Islam', '+8801833334455', 'Female', 'AB+', '3', '30', 'Active', '03 Sep 2026'),
                            _buildDataRow(6, '7', 'Shakib Al Hasan', '+8801819988776', 'Male', 'B+', '1', '10', 'Active', '01 Sep 2026'),
                            _buildDataRow(7, '8', 'Lina Akther', '+8801988877665', 'Female', 'AB-', '4', '40', 'Blocked', '20 Aug 2026'),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const Divider(height: 1, color: Color(0xFFEEEEEE)),

                // ================= প্যাজিনেশন =================
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Showing 1 to 8 of 12,458 users', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Row(
                        children: [
                          _buildPageButton(Icons.chevron_left),
                          const SizedBox(width: 8),
                          _buildPageNumber('1', true),
                          const SizedBox(width: 8),
                          _buildPageNumber('2', false),
                          const SizedBox(width: 8),
                          _buildPageNumber('3', false),
                          const SizedBox(width: 8),
                          const Text('...', style: TextStyle(color: Colors.grey)),
                          const SizedBox(width: 8),
                          _buildPageNumber('5', false),
                          const SizedBox(width: 8),
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

  // টপ কার্ড ডিজাইন
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
                      const SizedBox(width: 4),
                      const Text('vs. last 30 days', style: TextStyle(color: Colors.grey, fontSize: 11)),
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

  // ফিল্টার ড্রপডাউন
  Widget _buildDropdownFilter(String label, String value) {
    return Expanded(
      flex: 1,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ================= 🌟 আপডেটেড ডেটা টেবিল রো (থ্রি-ডট মেনুসহ) =================
  DataRow _buildDataRow(int index, String id, String name, String phone, String gender, String bloodGroup, String donations, String credits, String status, String joinedDate) {
    bool isActive = status == 'Active';
    return DataRow(
      cells: [
        DataCell(Checkbox(value: selectedUsers[index], onChanged: (v) { setState(() { selectedUsers[index] = v!; }); }, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)))),
        DataCell(Text(id, style: const TextStyle(color: Colors.grey, fontSize: 13))),
        DataCell(
            Row(
              children: [
                CircleAvatar(radius: 16, backgroundColor: Colors.blue.withOpacity(0.1), child: Text(name[0], style: const TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold))),
                const SizedBox(width: 12),
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 13)),
              ],
            )
        ),
        DataCell(Text(phone, style: const TextStyle(color: Colors.black54, fontSize: 13))),
        DataCell(Text(gender, style: const TextStyle(color: Colors.black54, fontSize: 13))),
        DataCell(Text(bloodGroup, style: const TextStyle(color: const Color(0xFFE63946), fontWeight: FontWeight.bold, fontSize: 13))),
        DataCell(Text(donations, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold))),
        DataCell(
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(credits, style: TextStyle(color: credits.startsWith('-') ? Colors.red : Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            )
        ),
        DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: isActive ? Colors.green : Colors.red, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(status, style: TextStyle(color: isActive ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            )
        ),
        DataCell(Text(joinedDate, style: const TextStyle(color: Colors.black54, fontSize: 13))),

        // ================= 🌟 নতুন থ্রি-ডট (Actions) মেনু =================
        DataCell(
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
              splashRadius: 20,
              tooltip: 'User Actions',
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // মেনুর বর্ডার রাউন্ডেড
              offset: const Offset(0, 40), // মেনুটি আইকনের একটু নিচে ওপেন হবে
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'view',
                  child: Row(children: const [Icon(Icons.visibility_outlined, size: 18, color: Colors.blue), SizedBox(width: 12), Text('View Details', style: TextStyle(fontSize: 13))]),
                ),
                PopupMenuItem(
                  value: 'edit',
                  child: Row(children: const [Icon(Icons.edit_outlined, size: 18, color: Colors.green), SizedBox(width: 12), Text('Edit User', style: TextStyle(fontSize: 13))]),
                ),
                PopupMenuItem(
                  value: 'block',
                  // ইউজার অ্যাক্টিভ থাকলে Block দেখাবে, না হলে Unblock দেখাবে
                  child: Row(children: [Icon(isActive ? Icons.block_outlined : Icons.check_circle_outline, size: 18, color: Colors.orange), const SizedBox(width: 12), Text(isActive ? 'Block User' : 'Unblock User', style: const TextStyle(fontSize: 13))]),
                ),
                const PopupMenuDivider(), // একটি হালকা বর্ডার লাইন
                PopupMenuItem(
                  value: 'delete',
                  child: Row(children: const [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 12), Text('Delete', style: TextStyle(fontSize: 13, color: Colors.red))]),
                ),
              ],
              onSelected: (String action) {
                // অ্যাডমিন মেনুতে ক্লিক করলে এই প্রিন্টটি টার্মিনালে দেখাবে (পরে এখানে ডায়ালগ বা পেজ ওপেন হবে)
                debugPrint('Clicked $action on User: $name');
              },
            )
        ),
      ],
    );
  }

  // প্যাজিনেশন বাটন
  Widget _buildPageButton(IconData icon) {
    return Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)), child: Icon(icon, size: 16, color: Colors.black54));
  }
  Widget _buildPageNumber(String number, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: isActive ? const Color(0xFF0F172A) : Colors.transparent, border: Border.all(color: isActive ? const Color(0xFF0F172A) : Colors.transparent), borderRadius: BorderRadius.circular(4)),
      child: Text(number, style: TextStyle(color: isActive ? Colors.white : Colors.black54, fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }
}
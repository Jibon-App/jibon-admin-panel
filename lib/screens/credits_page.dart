import 'package:flutter/material.dart';

class CreditsPage extends StatefulWidget {
  const CreditsPage({super.key});

  @override
  State<CreditsPage> createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> {
  List<bool> selectedTransactions = List.generate(6, (index) => false);
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
                    child: const Icon(Icons.stars, color: Colors.amber),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Credit Ledger (P2P)', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                      SizedBox(height: 4),
                      Text('Track automated peer-to-peer credit transfers, loans, and system rewards.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text('Issue System Credit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
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
              _buildStatCard('Total Auto-Transfers', '42,100', '+12%', Icons.swap_horiz, Colors.amber),
              const SizedBox(width: 20),
              _buildStatCard('Credits in Circulation', '307,500', '+8%', Icons.stars, Colors.blue),
              const SizedBox(width: 20),
              _buildStatCard('Zero-Credit Loans', '342', '+5%', Icons.health_and_safety_outlined, const Color(0xFFE63946)),
              const SizedBox(width: 20),
              _buildStatCard('Disputed Transfers', '5', '-2%', Icons.warning_amber_rounded, Colors.orange, isNegative: true),
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
                        hintText: 'Search by user name, ID, or Request Ref...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildDropdownFilter('Transfer Type', 'All'),
                const SizedBox(width: 16),
                _buildDropdownFilter('Status', 'Completed'),
                const SizedBox(width: 16),
                Container(
                  height: 42, padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                  child: Row(children: const [Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey), SizedBox(width: 8), Text('This Week', style: TextStyle(fontSize: 13))]),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {}, icon: const Icon(Icons.search, size: 16, color: Colors.white), label: const Text('Search', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE63946), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
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
                      const Text('Recent Credit Transfers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      OutlinedButton.icon(
                        onPressed: () {}, icon: const Icon(Icons.file_download_outlined, size: 16, color: Colors.black87), label: const Text('Export Ledger', style: TextStyle(color: Colors.black87)),
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
                            DataColumn(label: Checkbox(value: selectAll, onChanged: (v) { setState(() { selectAll = v!; for (int i = 0; i < selectedTransactions.length; i++) { selectedTransactions[i] = v; } }); }, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)))),
                            // 🌟 Trx ID বাদ দেওয়া হয়েছে
                            const DataColumn(label: Text('User / Account', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Type', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Source / Reference', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Amount', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Date & Time', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Status', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Actions', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                          ],
                          rows: [
                            _buildDataRow(0, 'Rafiqul Hasan', 'USR-2931', 'Earned', 'From Req: #RQ-9819\n(Abdul Kader)', '+50', 'Today, 10:30 AM', 'Completed'),
                            _buildDataRow(1, 'Sadia Akter', 'USR-8820', 'Spent', 'Auto-Transferred to\nDonor: USR-1092', '-20', 'Today, 09:15 AM', 'Completed'),

                            // 🌟 আপনার নতুন লজিক: আংশিক বা এক্সপায়ার্ড রিফান্ড
                            _buildDataRow(2, 'Tanim Ahmed', 'USR-3344', 'Refund', 'Unused Reserve\nFrom Req: #RQ-9750', '+10', 'Yesterday, 02:15 PM', 'Completed'),

                            _buildDataRow(3, 'Mehedi Hasan', 'USR-1193', 'Emergency Loan', 'System Loan (1 Bag)\nFor Req: #RQ-9815', '-50 Debt', 'Yesterday, 04:45 PM', 'Active Loan'),
                            _buildDataRow(4, 'Kamrul Hasan', 'USR-4421', 'Bonus', 'Welcome Bonus\nSystem Reward', '+20', '13 Sep 2026', 'Completed'),
                            _buildDataRow(5, 'Farzana Islam', 'USR-9932', 'Earned', 'From Req: #RQ-9699\n(Patient: Tariq Zia)', '+50', '12 Sep 2026', 'On Hold'),
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
                      const Text('Showing 1 to 6 of 42,100 Auto-Transfers', style: TextStyle(color: Colors.grey, fontSize: 13)),
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

  // 🌟 আপডেটেড ডেটা রো (Trx ID নেই, P2P রেফারেন্স আছে)
  DataRow _buildDataRow(int index, String userName, String userId, String type, String reference, String amount, String date, String status) {
    return DataRow(
      cells: [
        DataCell(Checkbox(value: selectedTransactions[index], onChanged: (v) { setState(() { selectedTransactions[index] = v!; }); }, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)))),

        DataCell(
            Row(
              children: [
                CircleAvatar(radius: 16, backgroundColor: Colors.blue.withOpacity(0.1), child: Text(userName[0], style: const TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold))),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(userName, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(userId, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                )
              ],
            )
        ),

        DataCell(_buildTypeBadge(type)),

        // 🌟 Source / Reference Column
        DataCell(
            SizedBox(
                width: 160,
                child: Text(reference, style: const TextStyle(color: Colors.black54, fontSize: 12, height: 1.3))
            )
        ),

        // Amount Logic (Green for +, Red for -)
        DataCell(
            Text(amount, style: TextStyle(color: amount.startsWith('+') ? Colors.green : const Color(0xFFE63946), fontSize: 14, fontWeight: FontWeight.bold))
        ),

        DataCell(Text(date, style: const TextStyle(color: Colors.black54, fontSize: 12))),
        DataCell(_buildStatusBadge(status)),

        DataCell(
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
              splashRadius: 20, tooltip: 'Manage Transfer', color: const Color(0xFFFFF9F9), elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), offset: const Offset(0, 40),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.visibility_outlined, size: 18, color: Colors.blue), SizedBox(width: 12), Text('View Context', style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500))])),
                if (type == 'Emergency Loan') const PopupMenuItem(value: 'waive', child: Row(children: [Icon(Icons.money_off, size: 18, color: Colors.orange), SizedBox(width: 12), Text('Waive Loan', style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500))])),
                const PopupMenuDivider(),
                // 🌟 Revert Transfer (for automated P2P disputes)
                const PopupMenuItem(value: 'revert', child: Row(children: [Icon(Icons.settings_backup_restore_rounded, size: 18, color: Colors.red), SizedBox(width: 12), Text('Revert Transfer', style: TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.w600))])),
              ],
              onSelected: (action) { debugPrint('Clicked $action for User: $userId'); },
            )
        ),
      ],
    );
  }

  // 🌟 Type Badge Logic (Earned, Spent, Loan, Bonus, Refund)
  Widget _buildTypeBadge(String type) {
    Color bgColor, textColor;
    // 🌟 Refund যুক্ত করা হয়েছে
    if (type == 'Earned' || type == 'Bonus' || type == 'Refund') {
      bgColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green;
    }
    else if (type == 'Emergency Loan') {
      bgColor = const Color(0xFFE63946).withOpacity(0.1);
      textColor = const Color(0xFFE63946);
    }
    else {
      bgColor = Colors.blue.withOpacity(0.1);
      textColor = Colors.blue;
    } // Spent

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Text(type, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  // Status Badge Logic
  Widget _buildStatusBadge(String status) {
    Color bgColor, textColor;
    if (status == 'Completed') { bgColor = Colors.green.withOpacity(0.1); textColor = Colors.green; }
    else if (status == 'On Hold') { bgColor = Colors.orange.withOpacity(0.1); textColor = Colors.orange.shade700; }
    else { bgColor = const Color(0xFFE63946).withOpacity(0.1); textColor = const Color(0xFFE63946); } // Active Loan

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPageButton(IconData icon) { return Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)), child: Icon(icon, size: 16, color: Colors.black54)); }
  Widget _buildPageNumber(String number, bool isActive) { return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: isActive ? const Color(0xFF0F172A) : Colors.transparent, border: Border.all(color: isActive ? const Color(0xFF0F172A) : Colors.transparent), borderRadius: BorderRadius.circular(4)), child: Text(number, style: TextStyle(color: isActive ? Colors.white : Colors.black54, fontSize: 13, fontWeight: FontWeight.bold))); }
}
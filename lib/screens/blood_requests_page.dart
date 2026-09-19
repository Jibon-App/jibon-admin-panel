import 'package:flutter/material.dart';

class BloodRequestsPage extends StatefulWidget {
  const BloodRequestsPage({super.key});

  @override
  State<BloodRequestsPage> createState() => _BloodRequestsPageState();
}

class _BloodRequestsPageState extends State<BloodRequestsPage> {
  List<bool> selectedRequests = List.generate(8, (index) => false);
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
                    child: const Icon(Icons.bloodtype_outlined, color: Color(0xFFE63946)),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Blood Requests', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                      SizedBox(height: 4),
                      Text('Manage all blood requests, urgencies, and hospital details.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_alert, size: 18, color: Colors.white),
                label: const Text('Create Request', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

          // ================= ২. টপ ৫টি সামারি কার্ড =================
          Row(
            children: [
              _buildStatCard('Total Requests', '248', '+12%', Icons.bloodtype, const Color(0xFFE63946)),
              const SizedBox(width: 16), // 🌟 ৫টি কার্ডের জন্য স্পেসিং কমানো হয়েছে
              _buildStatCard('Pending', '86', '+8%', Icons.schedule, Colors.orange),
              const SizedBox(width: 16),
              _buildStatCard('In Progress', '104', '+15%', Icons.verified, Colors.blue),
              const SizedBox(width: 16),
              _buildStatCard('Completed', '52', '+20%', Icons.check_circle, Colors.green),
              const SizedBox(width: 16),
              _buildStatCard('Cancelled', '6', '-14%', Icons.cancel, Colors.red, isNegative: true),
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
                        hintText: 'Search patient, hospital, or request ID...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildDropdownFilter('Urgency', 'All'),
                const SizedBox(width: 16),
                _buildDropdownFilter('Status', 'Pending'),
                const SizedBox(width: 16),
                _buildDropdownFilter('Blood Group', 'All'),
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
                      const Text('Recent Requests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
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
                            DataColumn(label: Checkbox(value: selectAll, onChanged: (v) { setState(() { selectAll = v!; for (int i = 0; i < selectedRequests.length; i++) { selectedRequests[i] = v; } }); }, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)))),
                            const DataColumn(label: Text('Req ID', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            // 🌟 নতুন কলাম: Requester
                            const DataColumn(label: Text('Requester', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Contact Person', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Group', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Bags', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Hospital / Location', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Urgency', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Status', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Actions', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
                          ],
                          rows: [
                            // ডামি ডেটায় Requester Name এবং User ID যুক্ত করা হয়েছে
                            _buildDataRow(0, '#RQ-9821', 'Faisal Ahmed', 'USR-8492', 'Abdul Kader', '+8801711223344', 'O+', '2', 'Dhaka Medical College', 'Emergency', 'Pending'),
                            _buildDataRow(1, '#RQ-9820', 'Nusrat Jahan', 'USR-2910', 'Sumaiya Akter', '+8801922334455', 'A-', '1', 'Square Hospital, Dhaka', 'Urgent', 'Pending'),
                            _buildDataRow(2, '#RQ-9819', 'Karim Hasan', 'USR-5581', 'Rashedul Islam', '+8801833445566', 'B+', '3', 'Sylhet MAG Osmani', 'Normal', 'Completed'),
                            _buildDataRow(3, '#RQ-9818', 'Sadia Islam', 'USR-3092', 'Kamrul Hasan', '+8801744556677', 'O-', '1', 'Rajshahi Medical', 'Emergency', 'Completed'),
                            _buildDataRow(4, '#RQ-9817', 'Rafiqul Islam', 'USR-7742', 'Jannatul Ferdous', '+8801555667788', 'AB+', '2', 'Evercare Hospital', 'Normal', 'Pending'),
                            _buildDataRow(5, '#RQ-9816', 'Mehedi Hasan', 'USR-1193', 'Tariq Zia', '+8801666778899', 'A+', '1', 'Khulna City Hospital', 'Urgent', 'Expired'),
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
                      const Text('Showing 1 to 6 of 184 Pending Requests', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Row(
                        children: [
                          _buildPageButton(Icons.chevron_left), const SizedBox(width: 8),
                          _buildPageNumber('1', true), const SizedBox(width: 8),
                          _buildPageNumber('2', false), const SizedBox(width: 8),
                          _buildPageNumber('3', false), const SizedBox(width: 8),
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

  // 🌟 আপডেটেড ৫টি কার্ডের ডিজাইন (স্ক্রিনশটের মতো)
  Widget _buildStatCard(String title, String count, String growth, IconData icon, Color color, {bool isNegative = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16), // 🌟 ৫টি কার্ড যেন সুন্দরভাবে ফিট হয়
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌟 আইকনের ব্যাকগ্রাউন্ড এখন গোল (Circle)
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24)
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(count, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(isNegative ? Icons.arrow_downward : Icons.arrow_upward, color: isNegative ? Colors.red : Colors.green, size: 14),
                      const SizedBox(width: 4),
                      Text(growth, style: TextStyle(color: isNegative ? Colors.red : Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // 🌟 লেখাটি এখন নতুন লাইনে
                  const Text('vs. last 30 days', style: TextStyle(color: Colors.grey, fontSize: 11)),
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

  // 🌟 আপডেটেড ডেটা রো (Requester কলামসহ)
  DataRow _buildDataRow(int index, String reqId, String requesterName, String requesterId, String patientName, String phone, String bloodGroup, String bags, String hospital, String urgency, String status) {
    return DataRow(
      cells: [
        DataCell(Checkbox(value: selectedRequests[index], onChanged: (v) { setState(() { selectedRequests[index] = v!; }); }, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)))),
        DataCell(Text(reqId, style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.bold))),

        // 🌟 নতুন Requester সেল (প্রোফাইল পিকচার, নাম এবং User ID)
        DataCell(
            Row(
              children: [
                CircleAvatar(radius: 16, backgroundColor: Colors.blue.withOpacity(0.1), child: Text(requesterName[0], style: const TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold))),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(requesterName, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(requesterId, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                )
              ],
            )
        ),

        DataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(patientName, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 13)),
                const SizedBox(height: 2),
                Text(phone, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            )
        ),
        DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFE63946).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(bloodGroup, style: const TextStyle(color: const Color(0xFFE63946), fontWeight: FontWeight.bold, fontSize: 13)),
            )
        ),
        DataCell(Text('$bags Bags', style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold))),
        DataCell(
            Row(
              children: [
                const Icon(Icons.local_hospital_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                SizedBox(width: 140, child: Text(hospital, style: const TextStyle(color: Colors.black87, fontSize: 12), overflow: TextOverflow.ellipsis)),
              ],
            )
        ),
        DataCell(_buildUrgencyBadge(urgency)),
        DataCell(_buildStatusBadge(status)),
        DataCell(
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
              splashRadius: 20, tooltip: 'Manage Request', shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), offset: const Offset(0, 40),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.visibility_outlined, size: 18, color: Colors.blue), SizedBox(width: 12), Text('View Details', style: TextStyle(fontSize: 13))])),
                if (status == 'Pending') const PopupMenuItem(value: 'complete', child: Row(children: [Icon(Icons.check_circle_outline, size: 18, color: Colors.green), SizedBox(width: 12), Text('Mark Completed', style: TextStyle(fontSize: 13))])),
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18, color: Colors.orange), SizedBox(width: 12), Text('Edit Request', style: TextStyle(fontSize: 13))])),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 12), Text('Delete', style: TextStyle(fontSize: 13, color: Colors.red))])),
              ],
              onSelected: (action) { debugPrint('Clicked $action on $reqId'); },
            )
        ),
      ],
    );
  }

  // 🌟 Urgency Badge Logic
  Widget _buildUrgencyBadge(String urgency) {
    Color bgColor, textColor;
    if (urgency == 'Emergency') { bgColor = Colors.red.withOpacity(0.1); textColor = Colors.red; }
    else if (urgency == 'Urgent') { bgColor = Colors.orange.withOpacity(0.1); textColor = Colors.orange.shade700; }
    else { bgColor = Colors.blue.withOpacity(0.1); textColor = Colors.blue; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(urgency, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  // 🌟 Status Badge Logic
  Widget _buildStatusBadge(String status) {
    Color bgColor, textColor;
    if (status == 'Completed') { bgColor = Colors.green.withOpacity(0.1); textColor = Colors.green; }
    else if (status == 'Pending') { bgColor = Colors.amber.withOpacity(0.2); textColor = Colors.amber.shade800; }
    else { bgColor = Colors.grey.withOpacity(0.1); textColor = Colors.grey.shade700; } // Expired

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPageButton(IconData icon) { return Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)), child: Icon(icon, size: 16, color: Colors.black54)); }
  Widget _buildPageNumber(String number, bool isActive) { return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: isActive ? const Color(0xFF0F172A) : Colors.transparent, border: Border.all(color: isActive ? const Color(0xFF0F172A) : Colors.transparent), borderRadius: BorderRadius.circular(4)), child: Text(number, style: TextStyle(color: isActive ? Colors.white : Colors.black54, fontSize: 13, fontWeight: FontWeight.bold))); }
}
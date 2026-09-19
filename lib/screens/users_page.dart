import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  // পেজিনেশনের জন্য ভেরিয়েবল
  int _rowsPerPage = 10;
  DocumentSnapshot? _lastDocument;
  List<DocumentSnapshot> _usersData = [];
  bool _isLoading = true;
  bool _hasMoreData = true;

  // চেক বক্সের স্টেট (ডায়নামিক লিস্টের জন্য)
  List<bool> selectedUsers = [];
  bool selectAll = false;

  // 🌟 নতুন: সার্চ ও ফিল্টারের জন্য ভেরিয়েবল 🌟
  final TextEditingController _searchController = TextEditingController();
  String _selectedGender = 'All';
  String _selectedStatus = 'All';
  String _selectedBloodGroup = 'All';

  @override
  void initState() {
    super.initState();
    _fetchInitialUsers();
  }

  Query _buildQuery() {
    Query query = FirebaseFirestore.instance.collection('users');

    String searchTerm = _searchController.text.trim();
    if (searchTerm.isNotEmpty) {
      if (searchTerm.toUpperCase().contains('USR') || searchTerm.startsWith('#')) {
        // ইউজার আইডি দিয়ে সার্চ এবং ওই ফিল্ড অনুযায়ী সর্টিং
        query = query
            .where('user_id', isGreaterThanOrEqualTo: searchTerm)
            .where('user_id', isLessThanOrEqualTo: searchTerm + '\uf8ff')
            .orderBy('user_id');
      } else {
        String formattedPhone = searchTerm;
        if (searchTerm.startsWith('0')) {
          formattedPhone = '+880' + searchTerm.substring(1);
        } else if (!searchTerm.startsWith('+')) {
          formattedPhone = '+880' + searchTerm;
        }

        // ফোন নম্বর দিয়ে সার্চ এবং ওই ফিল্ড অনুযায়ী সর্টিং
        query = query
            .where('phone', isGreaterThanOrEqualTo: formattedPhone)
            .where('phone', isLessThanOrEqualTo: formattedPhone + '\uf8ff')
            .orderBy('phone');
      }
    } else {
      // সার্চ বক্স খালি থাকলে নতুন ইউজার আগে দেখাবে
      query = query.orderBy('createdAt', descending: true);
    }

    return query;
  }

  Future<void> _fetchInitialUsers() async {
    setState(() => _isLoading = true);
    try {
      final querySnapshot = await _buildQuery().limit(_rowsPerPage).get();

      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
        _usersData = List<DocumentSnapshot>.from(querySnapshot.docs);
        selectedUsers = List.generate(_usersData.length, (index) => false);
        _hasMoreData = querySnapshot.docs.length == _rowsPerPage;
      } else {
        _usersData = [];
        _hasMoreData = false;
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMoreUsers() async {
    if (!_hasMoreData || _isLoading || _lastDocument == null) return;
    setState(() => _isLoading = true);
    try {
      final querySnapshot = await _buildQuery()
          .startAfterDocument(_lastDocument!)
          .limit(_rowsPerPage)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
        _usersData.addAll(List<DocumentSnapshot>.from(querySnapshot.docs));
        selectedUsers.addAll(List.generate(querySnapshot.docs.length, (index) => false));
        _hasMoreData = querySnapshot.docs.length == _rowsPerPage;
      } else {
        _hasMoreData = false;
      }
    } catch (e) {
      debugPrint("Error fetching more users: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearch() {
    _lastDocument = null;
    _fetchInitialUsers();
  }

  void _onReset() {
    _searchController.clear();
    _onSearch();
  }

  // ================= 🌟 ব্লাড গ্রুপ এডিট ডায়ালগ 🌟 =================
  Future<void> _showEditBloodGroupDialog(String userId, String currentBloodGroup) async {
    String? selectedBloodGroup = currentBloodGroup;
    final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Text('Edit Blood Group', style: TextStyle(fontWeight: FontWeight.bold)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Select the correct blood group for this user:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: bloodGroups.contains(selectedBloodGroup) ? selectedBloodGroup : null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: bloodGroups.map((bg) {
                        return DropdownMenuItem(value: bg, child: Text(bg));
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedBloodGroup = value;
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedBloodGroup != null) {
                        Navigator.pop(context, true);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE63946)),
                    child: const Text('UPDATE', style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            }
        );
      },
    );

    if (confirm == true && selectedBloodGroup != null && selectedBloodGroup != currentBloodGroup) {
      _updateBloodGroupInFirebase(userId, selectedBloodGroup!);
    }
  }

  // ================= 🌟 ফায়ারবেসে ব্লাড গ্রুপ আপডেট 🌟 =================
  Future<void> _updateBloodGroupInFirebase(String userId, String newBloodGroup) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'bloodGroup': newBloodGroup,
      });

      // লোকাল লিস্ট আপডেট করা যাতে সাথে সাথে UI তে পরিবর্তন দেখা যায়
      int userIndex = _usersData.indexWhere((doc) => doc.id == userId);
      if (userIndex != -1) {
        // DocumentSnapshot মিউটেবল না, তাই আমরা লোকালি UI আপডেট করার জন্য ডেটা রিফ্রেশ করতে পারি
        // অথবা একটি সহজ উপায় হলো, ওই নির্দিষ্ট ডকুমেন্টটি আবার ফেচ করা:
        final updatedDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        setState(() {
          _usersData[userIndex] = updatedDoc;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Blood group updated successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating blood group: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ... (বাকি কোড আগের মতোই থাকবে)

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
          // (এখানে ড্যাশবোর্ডের মতো FutureBuilder দিয়ে ডেটা আনতে পারেন, আপাতত হার্ডকোড রাখছি)
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

          // ================= ৩. ক্লিন সার্চ সেকশন =================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Type phone number (e.g. +88017) or User ID (e.g. #USR)...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (value) => _onSearch(), // কীবোর্ডের এন্টার চাপলে সার্চ হবে
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _onReset,
                  icon: const Icon(Icons.refresh, size: 16, color: Colors.black87),
                  label: const Text('Reset', style: TextStyle(color: Colors.black87)),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _onSearch,
                  icon: const Icon(Icons.search, size: 16, color: Colors.white),
                  label: const Text('Search', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ================= ৪. ডেটা টেবিল সেকশন (ডায়নামিক) =================
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // টেবিল হেডার
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Users', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      OutlinedButton.icon(
                        onPressed: () {}, icon: const Icon(Icons.file_download_outlined, size: 16, color: Colors.black87), label: const Text('Export', style: TextStyle(color: Colors.black87)),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),

                // মেইন টেবিল
                if (_isLoading && _usersData.isEmpty)
                  const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
                else if (_usersData.isEmpty)
                  const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('No users found.')))
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
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
                            rows: List.generate(_usersData.length, (index) {
                              final doc = _usersData[index];
                              final data = doc.data() as Map<String, dynamic>;
                              return _buildDataRow(index, doc.id, data);
                            }),
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
                      Text('Showing ${_usersData.length} users', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      Row(
                        children: [
                          if (_hasMoreData)
                            ElevatedButton(
                              onPressed: _isLoading ? null : _fetchMoreUsers,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                side: BorderSide(color: Colors.grey.shade300),
                                elevation: 0,
                              ),
                              child: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Load More'),
                            ),
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

  // 🌟 রিয়েল ড্রপডাউন উইজেট 🌟
  Widget _buildRealDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
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
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: value,
                  iconSize: 16,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
                  items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: onChanged,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ================= 🌟 আপডেটেড ডেটা টেবিল রো (রিয়েল ডেটা) 🌟 =================
  DataRow _buildDataRow(int index, String id, Map<String, dynamic> data) {
    final String name = data['name'] ?? 'Unknown';
    final String phone = data['phone'] ?? 'N/A';
    final String gender = data['gender'] ?? 'Not Specified';
    final String bloodGroup = data['bloodGroup'] ?? 'Unknown';
    final int donations = data['totalDonations'] ?? 0;
    final int credits = data['availableCredits'] ?? 0;

    final String dbStatus = data['status'] ?? 'active'; // ডাটাবেস থেকে স্ট্যাটাস আনলাম
    bool isActive = dbStatus.toLowerCase() == 'active'; // ছোট হাতের করে চেক করলাম
    String displayStatus = isActive ? 'Active' : 'Blocked'; // UI-তে সুন্দরভাবে দেখানোর জন্য

    // তারিখ ফরম্যাটিং
    String joinedDate = 'Unknown';
    if (data['createdAt'] != null) {
      final date = (data['createdAt'] as Timestamp).toDate();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      joinedDate = '${date.day} ${months[date.month - 1]} ${date.year}';
    }

    String shortId = data['user_id'] ?? 'N/A';

    return DataRow(
      cells: [
        DataCell(Checkbox(value: selectedUsers[index], onChanged: (v) { setState(() { selectedUsers[index] = v!; }); }, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)))),
        DataCell(Text(shortId, style: const TextStyle(color: Colors.grey, fontSize: 13))),
        DataCell(
            Row(
              children: [
                CircleAvatar(radius: 16, backgroundColor: Colors.blue.withOpacity(0.1), child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold))),
                const SizedBox(width: 12),
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 13)),
              ],
            )
        ),
        DataCell(Text(phone, style: const TextStyle(color: Colors.black54, fontSize: 13))),
        DataCell(Text(gender, style: const TextStyle(color: Colors.black54, fontSize: 13))),
        DataCell(Text(bloodGroup, style: const TextStyle(color: const Color(0xFFE63946), fontWeight: FontWeight.bold, fontSize: 13))),
        DataCell(Text(donations.toString(), style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold))),
        DataCell(
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(credits.toString(), style: TextStyle(color: credits < 0 ? Colors.red : Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
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
                  Text(displayStatus, style: TextStyle(color: isActive ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold)), // 👈 এখানে displayStatus বসালাম
                ],
              ),
            )
        ),
        DataCell(Text(joinedDate, style: const TextStyle(color: Colors.black54, fontSize: 13))),

        // ================= 🌟 থ্রি-ডট (Actions) মেনু 🌟 =================
        DataCell(
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
              splashRadius: 20,
              tooltip: 'User Actions',
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              offset: const Offset(0, 40),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'view',
                  child: Row(children: const [Icon(Icons.visibility_outlined, size: 18, color: Colors.blue), SizedBox(width: 12), Text('View Details', style: TextStyle(fontSize: 13))]),
                ),
                PopupMenuItem(
                  value: 'edit_blood',
                  child: Row(children: const [Icon(Icons.bloodtype_outlined, size: 18, color: Colors.redAccent), SizedBox(width: 12), Text('Edit Blood Group', style: TextStyle(fontSize: 13))]),
                ),
                PopupMenuItem(
                  value: 'block',
                  child: Row(children: [Icon(isActive ? Icons.block_outlined : Icons.check_circle_outline, size: 18, color: Colors.orange), const SizedBox(width: 12), Text(isActive ? 'Block User' : 'Unblock User', style: const TextStyle(fontSize: 13))]),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(children: const [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 12), Text('Delete', style: TextStyle(fontSize: 13, color: Colors.red))]),
                ),
              ],
              onSelected: (String action) {
                if (action == 'edit_blood') {
                  _showEditBloodGroupDialog(id, bloodGroup);
                } else {
                  debugPrint('Clicked $action on User: $name');
                  // অন্যান্য অ্যাকশনগুলো এখানে যোগ করবেন
                }
              },
            )
        ),
      ],
    );
  }
}
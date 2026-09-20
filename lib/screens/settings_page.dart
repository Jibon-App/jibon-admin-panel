import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // সুইচের স্টেটগুলো
  bool maintenanceMode = false;
  bool allowZeroCredit = false; // 🌟 ডিফল্টভাবে false রাখা হলো
  bool autoApproveDonation = false;
  bool adminNotifications = true;

  bool isLoading = true; // 🌟 ডেটা ফেচিংয়ের জন্য লোডিং স্টেট

  @override
  void initState() {
    super.initState();
    _fetchSettings(); // 🌟 পেজ লোড হওয়ার সময় ফায়ারবেস থেকে ডেটা আনবে
  }

  // ================= 🌟 ফায়ারবেস থেকে ডেটা আনা 🌟 =================
  Future<void> _fetchSettings() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('app_settings')
          .doc('configs')
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && mounted) {
          setState(() {
            allowZeroCredit = data['isZeroCreditOfferActive'] ?? false;
            // 💡 আপনি চাইলে maintenanceMode বা অন্য ফিল্ডগুলোও ফায়ারবেস থেকে আনতে পারেন
            isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching settings: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ================= 🌟 ফায়ারবেসে ডেটা আপডেট করা 🌟 =================
  Future<void> _updateZeroCreditStatus(bool newValue) async {
    // ১. সাথে সাথে UI আপডেট করা
    setState(() {
      allowZeroCredit = newValue;
    });

    try {
      // ২. ফায়ারবেসে আপডেট করা
      await FirebaseFirestore.instance
          .collection('app_settings')
          .doc('configs')
          .set({
        'isZeroCreditOfferActive': newValue,
      }, SetOptions(merge: true)); // merge: true দিলে অন্য ফিল্ডগুলো মুছে যাবে না

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newValue ? 'Zero-Credit Offer is now ACTIVE.' : 'Zero-Credit Offer is now DISABLED.'),
            backgroundColor: newValue ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // ৩. ফায়ারবেসে আপডেট ফেইল হলে আগের অবস্থায় ফিরে যাওয়া
      setState(() {
        allowZeroCredit = !newValue;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update setting.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFE63946)));
    }

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
                    child: const Icon(Icons.settings_outlined, color: Color(0xFFE63946)),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('System Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                      SizedBox(height: 4),
                      Text('Manage admin profile, app preferences, and security configurations.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings Saved Successfully!'), backgroundColor: Colors.green));
                },
                icon: const Icon(Icons.save, size: 18, color: Colors.white),
                label: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A), // ডার্ক নেভি ব্লু
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              )
            ],
          ),
          const SizedBox(height: 32),

          // ================= ২. সেটিংস কন্টেন্ট (২টি কলামে বিভক্ত) =================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🌟 বাম কলাম (Profile & Security)
              Expanded(
                child: Column(
                  children: [
                    _buildProfileCard(),
                    const SizedBox(height: 24),
                    _buildSecurityCard(),
                  ],
                ),
              ),

              const SizedBox(width: 24), // দুই কলামের মাঝখানের স্পেস

              // 🌟 ডান কলাম (App Preferences & Danger Zone)
              Expanded(
                child: Column(
                  children: [
                    _buildPreferencesCard(),
                    const SizedBox(height: 24),
                    _buildDangerZoneCard(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ================= 🌟 কার্ড ১: Admin Profile =================
  Widget _buildProfileCard() {
    return _buildSettingCard(
      title: 'Admin Profile',
      icon: Icons.person_outline,
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(radius: 30, backgroundColor: const Color(0xFFE63946).withOpacity(0.1), child: const Icon(Icons.admin_panel_settings, color: Color(0xFFE63946), size: 30)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Super Admin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  SizedBox(height: 4),
                  Text('admin@jibonapp.com', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), side: BorderSide(color: Colors.grey.shade300)),
                child: const Text('Edit Profile', style: TextStyle(color: Colors.black87, fontSize: 13)),
              )
            ],
          ),
          const SizedBox(height: 24),
          _buildTextField('Full Name', 'Super Admin'),
          const SizedBox(height: 16),
          _buildTextField('Email Address', 'admin@jibonapp.com'),
          const SizedBox(height: 16),
          _buildTextField('Phone Number', '+880 1700 000000'),
        ],
      ),
    );
  }

  // ================= 🌟 কার্ড ২: Security Settings =================
  Widget _buildSecurityCard() {
    return _buildSettingCard(
      title: 'Security',
      icon: Icons.lock_outline,
      child: Column(
        children: [
          _buildTextField('Current Password', '********', isPassword: true),
          const SizedBox(height: 16),
          _buildTextField('New Password', '', isPassword: true),
          const SizedBox(height: 16),
          _buildTextField('Confirm New Password', '', isPassword: true),
        ],
      ),
    );
  }

  // ================= 🌟 কার্ড ৩: App Preferences =================
  Widget _buildPreferencesCard() {
    return _buildSettingCard(
      title: 'App Preferences',
      icon: Icons.tune,
      child: Column(
        children: [
          _buildSwitchRow('Maintenance Mode', 'Show "App is under maintenance" to all users.', maintenanceMode, (val) => setState(() => maintenanceMode = val)),
          const Divider(height: 32, color: Color(0xFFEEEEEE)),
          _buildSwitchRow(
              'Zero-Credit Loans',
              'Allow emergency requests for users with 0 credits.',
              allowZeroCredit,
                  (val) => _updateZeroCreditStatus(val) // 🌟 ফায়ারবেস আপডেট ফাংশন কল করা হলো
          ),
          const Divider(height: 32, color: Color(0xFFEEEEEE)),
          _buildSwitchRow('Auto-Approve Donations', 'Automatically verify donations submitted by hospitals.', autoApproveDonation, (val) => setState(() => autoApproveDonation = val)),
          const Divider(height: 32, color: Color(0xFFEEEEEE)),
          _buildSwitchRow('Admin Email Alerts', 'Get email alerts for emergency blood requests.', adminNotifications, (val) => setState(() => adminNotifications = val)),
        ],
      ),
    );
  }

  // ================= 🌟 কার্ড ৪: Danger Zone =================
  Widget _buildDangerZoneCard() {
    return _buildSettingCard(
      title: 'Danger Zone',
      icon: Icons.warning_amber_rounded,
      titleColor: Colors.red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Actions here can permanently affect the system. Proceed with caution.', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Clear System Cache', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 14)),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), side: const BorderSide(color: Colors.orange)),
                child: const Text('Clear Cache', style: TextStyle(color: Colors.orange, fontSize: 13)),
              )
            ],
          ),
          const Divider(height: 32, color: Color(0xFFEEEEEE)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Logout from Dashboard', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 14)),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout, size: 16, color: Colors.white),
                label: const Text('Logout', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
              )
            ],
          ),
        ],
      ),
    );
  }

  // ================= হেল্পার ফাংশনস =================

  // কার্ডের বডি ডিজাইন
  Widget _buildSettingCard({required String title, required IconData icon, required Widget child, Color titleColor = Colors.black87}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: titleColor, size: 20),
              const SizedBox(width: 12),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor)),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  // টেক্সট ফিল্ড ডিজাইন
  Widget _buildTextField(String label, String placeholder, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          height: 45,
          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
          child: TextField(
            obscureText: isPassword,
            decoration: InputDecoration(hintText: placeholder, hintStyle: TextStyle(color: Colors.black87, fontSize: 14), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          ),
        ),
      ],
    );
  }

  // অন/অফ সুইচ ডিজাইন
  Widget _buildSwitchRow(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 14)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: const Color(0xFFE63946),
        )
      ],
    );
  }
}
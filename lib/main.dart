import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/dashboard_page.dart';
import 'screens/users_page.dart';
import 'screens/blood_requests_page.dart';
import 'screens/donations_page.dart';
import 'screens/credits_page.dart';
import 'screens/notifications_page.dart';
import 'screens/settings_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // ১. ফ্লাটার বাইন্ডিং নিশ্চিত করা
  WidgetsFlutterBinding.ensureInitialized();

  // ২. ফায়ারবেস ইনিশিয়ালাইজ করা
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const JibonAdminApp());
}

class JibonAdminApp extends StatelessWidget {
  const JibonAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jibon Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF4F7FE),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE63946)),
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // কোন পেজ সিলেক্ট করা আছে সেটা মনে রাখার ভ্যারিয়েবল
  String _selectedPage = 'Dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ================= ১. বাম পাশের সাইডবার (Dark Theme) =================
          Container(
            width: 260,
            color: const Color(0xFF0F172A),
            child: Column(
              children: [
                SizedBox(
                  height: 70,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: const [
                            Icon(Icons.water_drop, color: Color(0xFFE63946), size: 36),
                            Positioned(top: 14, child: Icon(Icons.favorite, color: Colors.white, size: 12)),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Jibon', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text('Admin Panel', style: TextStyle(fontSize: 12, color: Colors.white54)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // সাইডবারের মেনু আইটেমগুলো
                _buildMenuItem(Icons.home, 'Dashboard'),
                _buildMenuItem(Icons.people_alt_outlined, 'Users'),
                _buildMenuItem(Icons.bloodtype_outlined, 'Blood Requests'),
                _buildMenuItem(Icons.favorite_outline, 'Donations'),
                _buildMenuItem(Icons.account_balance_wallet_outlined, 'Credits'),
                _buildMenuItem(Icons.notifications_none, 'Notifications'),
                _buildMenuItem(Icons.settings_outlined, 'Settings'),

                const Spacer(),

                // ব্র্যান্ডিং
                Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.favorite, color: Color(0xFFE63946)),
                      SizedBox(height: 8),
                      Text('Together\nWe Save Lives', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ================= ২. ডান পাশের মেইন কন্টেন্ট এরিয়া =================
          Expanded(
            child: Column(
              children: [
                // Top Header (Fixed)
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Stack(
                        children: [
                          const Icon(Icons.notifications_none, size: 28, color: Colors.black87),
                          Positioned(
                            right: 2, top: 2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Color(0xFFE63946), shape: BoxShape.circle),
                              child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(width: 24),
                      Row(
                        children: const [
                          Icon(Icons.account_circle_outlined, size: 32, color: Colors.black54),
                          SizedBox(width: 8),
                          Text('Admin', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                        ],
                      ),
                    ],
                  ),
                ),

                // 🌟 ডায়নামিক পেজ রেন্ডারিং (Switch Logic)
                Expanded(
                  child: _getPageContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= 🌟 Page Router Logic =================
  Widget _getPageContent() {
    switch (_selectedPage) {
      case 'Dashboard':
        return const DashboardPage();
      case 'Users':
        return const UsersPage();
      case 'Blood Requests':
        return const BloodRequestsPage();
      case 'Donations':
        return const DonationsPage();
      case 'Credits':
        return const CreditsPage();
      case 'Notifications':
        return const NotificationsPage();
      case 'Settings':
        return const SettingsPage();
      default:
        return _buildPlaceholderPage(); // বাকি সব মেনুর জন্য Coming Soon পেজ
    }
  }

  // ================= Helper Functions =================

  // সাইডবার মেনু ডিজাইন
  Widget _buildMenuItem(IconData icon, String title) {
    bool isActive = _selectedPage == title;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: isActive ? const Color(0xFFE63946) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedPage = title;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            leading: Icon(icon, color: isActive ? Colors.white : Colors.white70, size: 22),
            title: Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // আন্ডার কনস্ট্রাকশন পেজ
  Widget _buildPlaceholderPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('$_selectedPage Page', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          const Text('This module is under development.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
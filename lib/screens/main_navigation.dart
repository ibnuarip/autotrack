import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/custom_toast.dart';
import '../services/notification_service.dart';
import 'home_screen.dart';
import 'vehicle/vehicle_list_screen.dart';
import 'service/service_history_screen.dart';
import 'service/add_service_screen.dart';
import 'vehicle/add_vehicle_screen.dart';
import 'settings/settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Berlangganan ke notifikasi login sukses agar muncul secara real-time
    CustomToast.loginSuccessNotifier.addListener(_handleLoginSuccess);
    
    // Sinkronisasi notifikasi pengingat servis saat aplikasi dibuka dalam kondisi login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncNotifications();
      _handleLoginSuccess();
    });
  }

  Future<void> _syncNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await NotificationService().rescheduleUserNotifications(user.uid);
    }
  }

  void _handleLoginSuccess() {
    if (CustomToast.loginSuccessNotifier.value != null && mounted) {
      CustomToast.showSuccess(
        context,
        title: 'Berhasil',
        message: CustomToast.loginSuccessNotifier.value!,
      );
      // Reset notifier agar tidak muncul berulang kali
      CustomToast.loginSuccessNotifier.value = null;
    }
  }

  @override
  void dispose() {
    CustomToast.loginSuccessNotifier.removeListener(_handleLoginSuccess);
    super.dispose();
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const VehicleListScreen(),
    const ServiceHistoryScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      extendBody: false, // Prevents body from scrolling behind the transparent bottom bar area
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOutBack,
        switchOutCurve: Curves.easeInOut,
        child: KeyedSubtree(
          key: ValueKey<int>(_selectedIndex),
          child: _screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: _buildCustomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildAddButton(),
    );
  }

  Widget _buildAddButton() {
    return Container(
      height: 52,
      width: 52,
      margin: const EdgeInsets.only(top: 36),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8100D1), Color(0xFFB500B2)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8100D1).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAddMenu(context),
          customBorder: const CircleBorder(),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pilih Aksi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildMenuOption(
                  context,
                  title: 'Data Servis',
                  subtitle: 'Catat riwayat baru',
                  icon: Icons.build_circle_rounded,
                  color: const Color(0xFF8100D1),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddServiceScreen()),
                    );
                  },
                ),
                const SizedBox(width: 16),
                _buildMenuOption(
                  context,
                  title: 'Kendaraan',
                  subtitle: 'Daftarkan mobil/motor',
                  icon: Icons.directions_car_filled_rounded,
                  color: const Color(0xFFB500B2),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.1), width: 1.5),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 9, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      height: 76,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 25,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(child: _buildNavItem(0, Icons.home_rounded, 'Home')),
                Expanded(child: _buildNavItem(1, Icons.minor_crash_rounded, 'Kendaraan')),
                const SizedBox(width: 56), // Fixed gap for central FAB (prevents crowding)
                Expanded(child: _buildNavItem(2, Icons.receipt_long_rounded, 'Riwayat')),
                Expanded(child: _buildNavItem(3, Icons.settings_rounded, 'Pengaturan')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        padding: const EdgeInsets.symmetric(vertical: 2), // Tighter padding to prevent overflow
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center contents vertically
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF8100D1) : Colors.grey[400],
              size: isSelected ? 26 : 22, // Size adjusted for selection pop
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF8100D1) : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

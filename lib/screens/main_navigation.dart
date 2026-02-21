import 'package:flutter/material.dart';
import '../utils/custom_toast.dart';
import 'home_screen.dart';
import 'vehicle/vehicle_list_screen.dart';
import 'service/service_history_screen.dart';
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
    // Show success toast if coming from login/register
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (CustomToast.showLoginSuccessToast) {
        CustomToast.showSuccess(
          context,
          title: 'Berhasil',
          message: CustomToast.successMessage ?? 'Selamat datang kembali di AutoTrack!',
        );
        // Reset flag
        CustomToast.showLoginSuccessToast = false;
        CustomToast.successMessage = null;
      }
    });
  }

  static const List<Widget> _screens = [
    HomeScreen(),
    VehicleListScreen(),
    ServiceHistoryScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF8100D1),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Kendaraan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

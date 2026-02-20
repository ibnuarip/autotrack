import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/custom_toast.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Show success toast if coming from login/register
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (CustomToast.showLoginSuccessToast) {
        CustomToast.showSuccess(
          context,
          title: 'Berhasil',
          message: CustomToast.successMessage ?? 'Selamat datang di AutoTrack!',
        );
        // Reset flag
        CustomToast.showLoginSuccessToast = false;
        CustomToast.successMessage = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoTrack'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/autotrack-logo.png',
              height: 120,
            ),
            const SizedBox(height: 20),
            Text(
              'Halo, ${user?.displayName ?? "User"}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Selamat datang di AutoTrack\nCatatan service kendaraan kamu.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

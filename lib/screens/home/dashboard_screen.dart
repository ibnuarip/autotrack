import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoTrack Dashboard'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 64, color: Color(0xFF8100D1)),
            SizedBox(height: 16),
            Text(
              'Selamat Datang di AutoTrack',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Ringkasan servis dan kendaraan Anda akan muncul di sini.'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action for Add Service
        },
        backgroundColor: const Color(0xFF8100D1),
        foregroundColor: Colors.white,
        tooltip: 'Tambah Servis',
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class VehicleListScreen extends StatelessWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kendaraan'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car, size: 64, color: Color(0xFF8100D1)),
            SizedBox(height: 16),
            Text(
              'Kendaraan Anda',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Daftar motor dan mobil Anda akan muncul di sini.'),
          ],
        ),
      ),
    );
  }
}

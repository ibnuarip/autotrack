import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../utils/custom_toast.dart';
import 'add_service_screen.dart';

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month - 1];
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  bool _isUsingFallbackQuery = false;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Silakan login terlebih dahulu')));
    }

    Query<Map<String, dynamic>> query = _firestore.collection('services').where('userId', isEqualTo: user.uid);
    if (!_isUsingFallbackQuery) {
      // Kembali menggunakan descending: true agar servis terbaru muncul di paling atas (Cara 2)
      query = query.orderBy('serviceDate', descending: true);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Servis'),
        centerTitle: true,
        backgroundColor: const Color(0xFF8100D1),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            final errorString = snapshot.error.toString();
            // Handle index error gracefully
            if (errorString.contains('requires an index') || errorString.contains('failed-precondition')) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline, size: 60, color: Colors.blue),
                      const SizedBox(height: 16),
                      const Text(
                        'Mengoptimalkan Database...',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Kami sedang mengaktifkan fitur pencarian cepat. Sementara itu, Anda tetap bisa melihat data Anda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          setState(() {
                            _isUsingFallbackQuery = true;
                          });
                        },
                        label: const Text('Tampilkan Data Sekarang'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.history, size: 80, color: Colors.grey[300]),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Belum ada riwayat servis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Catatan servis kendaraan Anda\nakan muncul di sini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 15),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/add-service'),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Servis Pertama'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          final serviceDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: serviceDocs.length,
            itemBuilder: (context, index) {
              final doc = serviceDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              final date = (data['serviceDate'] as Timestamp).toDate();
              final vehicleId = data['vehicleId'] as String;
              final reminderTime = data['reminderTime'] as String?;
              final serviceType = data['serviceType'] ?? 'Servis';
              final cost = (data['cost'] ?? 0).toDouble();

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8100D1).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.build_circle_rounded, color: Color(0xFF8100D1), size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FutureBuilder<DocumentSnapshot>(
                                    future: _firestore.collection('vehicles').doc(vehicleId).get(),
                                    builder: (context, vehSnapshot) {
                                      if (vehSnapshot.hasData && vehSnapshot.data!.exists) {
                                        final vehData = vehSnapshot.data!.data() as Map<String, dynamic>;
                                        return Text(
                                          vehData['name'] ?? 'Kendaraan',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Color(0xFF1A1A1A),
                                          ),
                                        );
                                      }
                                      return const Text('...', style: TextStyle(color: Colors.grey, fontSize: 14));
                                    },
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    serviceType,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _formatCurrency(cost),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2E7D32),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AddServiceScreen(
                                                serviceId: doc.id,
                                                initialData: data,
                                              ),
                                            ),
                                          );
                                        } else if (value == 'delete') {
                                          _showDeleteConfirmation(context, doc.id);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit_outlined, size: 18),
                                              SizedBox(width: 12),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                              SizedBox(width: 12),
                                              Text('Hapus', style: TextStyle(color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Lunas',
                                    style: TextStyle(color: Colors.blue[700], fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        color: Colors.grey[50],
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              '${date.day} ${_getMonth(date.month)} ${date.year}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            if (reminderTime != null) ...[
                              Icon(Icons.notifications_active_outlined, size: 12, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text(
                                reminderTime,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (data['description'] != null && (data['description'] as String).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Catatan: ${data['description']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String serviceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Riwayat?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan. Apakah Anda yakin ingin menghapus data servis ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestore.collection('services').doc(serviceId).delete();
                if (context.mounted) {
                  CustomToast.showSuccess(
                    context,
                    title: 'Berhasil',
                    message: 'Data servis berhasil dihapus.',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  CustomToast.showError(
                    context,
                    title: 'Gagal Menghapus',
                    message: e.toString(),
                  );
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

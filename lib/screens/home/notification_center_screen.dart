import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../service/service_history_screen.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('Silakan login')));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          'Pusat Notifikasi',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            tooltip: 'Tandai semua telah dibaca',
            icon: const Icon(Icons.done_all_rounded),
            onPressed: () => _showConfirmModal(context, user.uid),
          ),
        ],
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF2D3436),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('services')
            .where('userId', isEqualTo: user.uid)
            .where('nextServiceDate', isGreaterThanOrEqualTo: Timestamp.now())
            .orderBy('nextServiceDate', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF8100D1)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final nextDate = (data['nextServiceDate'] as Timestamp).toDate();
              final diff = nextDate.difference(DateTime.now()).inDays;
              final isRead = data['isNotificationRead'] ?? false;
              
              String statusText = '';
              Color statusColor = Colors.grey;
              IconData icon = Icons.notifications_rounded;

              if (diff <= 0) {
                statusText = 'WAKTUNYA SERVIS HARI INI!';
                statusColor = Colors.red;
                icon = Icons.priority_high_rounded;
              } else if (diff <= 2) {
                statusText = 'PENGINGAT H-2';
                statusColor = Colors.orange;
                icon = Icons.notification_important_rounded;
              } else {
                statusText = 'JADWAL TERDEKAT';
                statusColor = const Color(0xFF8100D1);
                icon = Icons.calendar_month_rounded;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isRead ? Colors.white.withOpacity(0.6) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isRead ? Colors.transparent : statusColor.withOpacity(0.1), 
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    // Mark this one as read when tapped
                    FirebaseFirestore.instance
                        .collection('services')
                        .doc(docs[index].id)
                        .update({'isNotificationRead': true});
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isRead ? Colors.grey[100] : statusColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                icon, 
                                color: isRead ? Colors.grey[400] : statusColor, 
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        statusText,
                                        style: TextStyle(
                                          color: isRead ? Colors.grey[400] : statusColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        '${nextDate.day}/${nextDate.month}',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection('vehicles')
                                        .doc(data['vehicleId'])
                                        .get(),
                                    builder: (context, vSnap) {
                                      String vName = 'Kendaraan';
                                      if (vSnap.hasData && vSnap.data!.exists) {
                                        vName = (vSnap.data!.data() as Map<String, dynamic>)['name'] ?? 'Kendaraan';
                                      }
                                      return Text(
                                        'Pengingat Servis Untuk $vName',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isRead ? Colors.grey[600] : const Color(0xFF2D3436),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Jadwal servis Anda direncanakan pada ${_formatDate(nextDate)}. Jangan lupa melakukan perawatan berkala agar performa tetap prima.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isRead ? Colors.grey[400] : Colors.grey[600],
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (!isRead)
                          Positioned(
                            right: 0,
                            top: 15,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF8100D1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showConfirmModal(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tandai Semua?'),
        content: const Text('Apakah Anda yakin ingin menandai semua notifikasi sebagai telah dibaca?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _markAllAsRead(userId);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF8100D1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ya, Yakin'),
          ),
        ],
      ),
    );
  }

  Future<void> _markAllAsRead(String userId) async {
    final snapshots = await FirebaseFirestore.instance
        .collection('services')
        .where('userId', isEqualTo: userId)
        .where('nextServiceDate', isGreaterThanOrEqualTo: Timestamp.now())
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (var doc in snapshots.docs) {
      batch.update(doc.reference, {'isNotificationRead': true});
    }
    await batch.commit();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20),
              ],
            ),
            child: Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey[200]),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum Ada Notifikasi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Semua pemberitahuan servis akan muncul di sini.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }
}

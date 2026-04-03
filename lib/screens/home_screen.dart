import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'service/add_service_screen.dart';
import 'vehicle/add_vehicle_screen.dart';
import 'settings/profile_screen.dart';
import 'home/notification_center_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  
  // User? get _currentUser => _authService.currentUser;

  User? get _currentUser => _authService.currentUser;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeInAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatisticsGrid(),
                        const SizedBox(height: 24),
                        _buildSectionHeader('Tips Perawatan'),
                        const SizedBox(height: 12),
                        _buildMaintenanceTips(),
                        const SizedBox(height: 24),
                        _buildSectionHeader('Servis Selanjutnya'),
                        const SizedBox(height: 12),
                        _buildUpcomingServicesSection(),
                        const SizedBox(height: 120), // Extra space to prevent overlap with floating navigation bar
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
           // Floating Add menu is handled by MainNavigation
        ],
      ),
    );
  }



  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF8100D1),
      elevation: 0,
      actions: [
        StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('services')
              .where('userId', isEqualTo: _currentUser!.uid)
              .where('nextServiceDate', isGreaterThanOrEqualTo: Timestamp.now())
              .where('nextServiceDate', isLessThanOrEqualTo: Timestamp.fromDate(DateTime.now().add(const Duration(days: 2))))
              .snapshots(),
          builder: (context, snapshot) {
            bool hasUpcoming = false;
            if (snapshot.hasData) {
              // Check for at least one unread notification
              hasUpcoming = snapshot.data!.docs.any((doc) => (doc.data() as Map<String, dynamic>)['isNotificationRead'] != true);
            }
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationCenterScreen()),
                    );
                  },
                ),
                if (hasUpcoming)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                    ),
                  ),
              ],
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.person_outline_rounded, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF8100D1), Color(0xFFB500B2)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white.withOpacity(0.05),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: _firestore.collection('users').doc(_currentUser!.uid).snapshots(),
                      builder: (context, snapshot) {
                        String name = 'User';
                        if (snapshot.hasData && snapshot.data!.exists) {
                          name = (snapshot.data!.data() as Map<String, dynamic>)['name'] ?? 'User';
                        }
                        return Text(
                          'Halo, $name!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        );
                      },
                    ),
                    const Text(
                      'Selamat datang kembali di AutoTrack',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3142),
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return Column(
      children: [
        // FEATURE CARD: MONTHLY SUMMARY
        _buildMonthlyFeatureCard(),
        const SizedBox(height: 16),
        // SUPPORTING METRICS ROW
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Kendaraan',
                _firestore
                    .collection('vehicles')
                    .where('userId', isEqualTo: _currentUser!.uid)
                    .snapshots(),
                (s) => '${s.docs.length} Unit',
                Icons.directions_car_filled_rounded,
                Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Riwayat Servis',
                _firestore
                    .collection('services')
                    .where('userId', isEqualTo: _currentUser!.uid)
                    .snapshots(),
                (s) => '${s.docs.length} Kali',
                Icons.checklist_rtl_rounded,
                Colors.purpleAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthlyFeatureCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getMonthlyServicesQuery().snapshots(),
      builder: (context, snapshot) {
        double totalCost = 0;
        int count = 0;
        if (snapshot.hasData) {
          count = snapshot.data!.docs.length;
          for (var doc in snapshot.data!.docs) {
            totalCost += ((doc.data() as Map<String, dynamic>)['cost'] ?? 0).toDouble();
          }
        }

        final formattedCost = 'Rp ${totalCost.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8100D1), Color(0xFFB500B2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8100D1).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    'Pengeluaran ${_getMonth(DateTime.now().month)} ${DateTime.now().year}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count Servis',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                formattedCost,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMaintenanceTips() {
    final tips = [
      {'title': 'Cek Tekanan Ban', 'desc': 'Lakukan setiap 2 minggu agar ban awet dan irit BBM.', 'icon': Icons.tire_repair},
      {'title': 'Ganti Oli Rutin', 'desc': 'Pastikan ganti oli setiap 5.000 - 10.000 km.', 'icon': Icons.oil_barrel},
      {'title': 'Kebersihan Filter', 'desc': 'Filter udara yang bersih menjaga performa mesin.', 'icon': Icons.air_rounded},
    ];

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tips.length,
        itemBuilder: (context, index) {
          final tip = tips[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(tip['icon'] as IconData, color: const Color(0xFF8100D1), size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tip['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tip['desc'] as String,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    Stream<QuerySnapshot> stream,
    String Function(QuerySnapshot) formatter,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          String value = '...';
          if (snapshot.hasData) {
            value = formatter(snapshot.data!);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUpcomingServicesSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('services')
          .where('userId', isEqualTo: _currentUser!.uid)
          .where('nextServiceDate', isGreaterThanOrEqualTo: Timestamp.now())
          .where('nextServiceDate', isLessThanOrEqualTo: Timestamp.fromDate(DateTime.now().add(const Duration(days: 2))))
          .orderBy('nextServiceDate', descending: false)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState('Tidak ada servis dalam 2 hari ke depan', Icons.calendar_today_outlined);
        }

        final docs = snapshot.data!.docs;
        return Column(
          children: docs.map((doc) => _buildServiceItem(context, doc)).toList(),
        );
      },
    );
  }

  Widget _buildServiceItem(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final nextDate = (data['nextServiceDate'] as Timestamp).toDate();
    final vehicleId = data['vehicleId'] as String;
    final isRecurring = data['isRecurring'] ?? false;

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _showServiceDetailSheet(context, doc),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isRecurring ? const Color(0xFF8100D1).withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isRecurring ? Icons.cached_rounded : Icons.event_note_rounded,
                    color: isRecurring ? const Color(0xFF8100D1) : Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<DocumentSnapshot>(
                        future: _firestore.collection('vehicles').doc(vehicleId).get(),
                        builder: (context, snapshot) {
                          String name = 'Memuat...';
                          if (snapshot.hasData && snapshot.data!.exists) {
                            name = (snapshot.data!.data() as Map<String, dynamic>)['name'] ?? 'Kendaraan';
                          }
                          return Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          );
                        },
                      ),
                      Text(
                        'Jadwal: ${nextDate.day} ${_getMonth(nextDate.month)} ${nextDate.year}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleCompleteRecurringService(BuildContext context, DocumentSnapshot doc) async {
    final messenger = ScaffoldMessenger.of(context);
    final data = doc.data() as Map<String, dynamic>;
    final DateTime serviceDate = (data['serviceDate'] as Timestamp).toDate();
    final DateTime nextPlanDate = (data['nextServiceDate'] as Timestamp).toDate();
    
    // Hitung interval
    final duration = nextPlanDate.difference(serviceDate);
    final today = DateTime.now();
    
    // Hitung tanggal berikutnya (Gunakan plan terakhir sebagai basis)
    DateTime nextScheduleDate = nextPlanDate.add(duration);
    
    // Failsafe: Jika interval terlalu pendek (kurang dari 1 hari) atau tanggal jadi masa lalu,
    // maka jadwalkan otomatis 1 bulan dari rencana terakhir.
    if (nextScheduleDate.isBefore(today.add(const Duration(hours: 1)))) {
      nextScheduleDate = DateTime(nextPlanDate.year, nextPlanDate.month + 1, nextPlanDate.day);
    }

    try {
      // 1. BUAT CATATAN RIWAYAT BARU (History)
      final historyData = Map<String, dynamic>.from(data);
      historyData['isRecurring'] = false;
      historyData['serviceDate'] = Timestamp.fromDate(today);
      historyData['nextServiceDate'] = null;
      historyData['createdAt'] = FieldValue.serverTimestamp();
      historyData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection('services').add(historyData);

      // 2. UPDATE JADWAL BERIKUTNYA (Reschedule)
      await _firestore.collection('services').doc(doc.id).update({
        'serviceDate': Timestamp.fromDate(today),
        'nextServiceDate': Timestamp.fromDate(nextScheduleDate),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      final formattedNextDate = "${nextScheduleDate.day} ${_getMonth(nextScheduleDate.month)} ${nextScheduleDate.year}";
      
      messenger.showSnackBar(
        SnackBar(
          content: Text('Berhasil! Jadwal berikutnya diset ke: $formattedNextDate'),
          backgroundColor: const Color(0xFF8100D1),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _showServiceDetailSheet(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final serviceDate = (data['serviceDate'] as Timestamp).toDate();
    final nextDate = (data['nextServiceDate'] as Timestamp).toDate();
    final vehicleId = data['vehicleId'] as String;
    final serviceType = data['serviceType'] ?? '-';
    final description = data['description'] ?? '-';
    final cost = (data['cost'] ?? 0).toDouble();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8100D1).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.build_rounded, color: Color(0xFF8100D1)),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Rencana Servis',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        Text(
                          'Informasi lengkap jadwal servis Anda',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildDetailItem(
                    'Kendaraan',
                    FutureBuilder<DocumentSnapshot>(
                      future: _firestore.collection('vehicles').doc(vehicleId).get(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.exists) {
                          final vData = snapshot.data!.data() as Map<String, dynamic>;
                          return Text(
                            '${vData['name']} (${vData['plateNumber']})',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          );
                        }
                        return const Text('Memuat...');
                      },
                    ),
                    Icons.directions_car_rounded,
                  ),
                  _buildDetailItem(
                    'Jenis Servis',
                    Text(serviceType, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    Icons.handyman_rounded,
                  ),
                  _buildDetailItem(
                    'Terakhir Servis',
                    Text(
                      '${serviceDate.day} ${_getMonth(serviceDate.month)} ${serviceDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    Icons.history_rounded,
                  ),
                  _buildDetailItem(
                    'Jadwal Servis Berikutnya',
                    Text(
                      '${nextDate.day} ${_getMonth(nextDate.month)} ${nextDate.year}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.orange,
                      ),
                    ),
                    Icons.event_available_rounded,
                  ),
                  _buildDetailItem(
                    'Estimasi Biaya',
                    Text(
                      'Rp ${cost.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.green),
                    ),
                    Icons.payments_rounded,
                  ),
                  _buildDetailItem(
                    'Catatan / Deskripsi',
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[700], fontSize: 14, height: 1.5),
                    ),
                    Icons.description_rounded,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      if (data['isRecurring'] == true) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context); // Tutup sheet dulu
                              _handleCompleteRecurringService(context, doc);
                            },
                            icon: const Icon(Icons.check_circle_rounded, size: 18),
                            label: const Text('Selesaikan', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8100D1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[600],
                            side: BorderSide(color: Colors.grey[300]!),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, Widget content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[400]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                content,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Query _getMonthlyServicesQuery() {
    final now = DateTime.now();
    return _firestore
        .collection('services')
        .where('userId', isEqualTo: _currentUser!.uid)
        .where('serviceDate', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(now.year, now.month, 1)));
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month - 1];
  }
}

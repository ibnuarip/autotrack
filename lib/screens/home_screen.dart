import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'service/add_service_screen.dart';
import 'vehicle/add_vehicle_screen.dart';

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
  
  // For Expandable FAB
  bool _isFabExpanded = false;

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
                        _buildSectionHeader('Servis Terjadwal'),
                        const SizedBox(height: 12),
                        _buildUpcomingServicesSection(),
                        const SizedBox(height: 100), // Space for FAB
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isFabExpanded)
            GestureDetector(
              onTap: () => setState(() => _isFabExpanded = false),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
        ],
      ),
      floatingActionButton: _buildExpandableFab(),
    );
  }

  Widget _buildExpandableFab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isFabExpanded) ...[
          _buildFabOption(
            icon: Icons.directions_car_filled_rounded,
            label: 'Tambah Kendaraan',
            onPressed: () {
              setState(() => _isFabExpanded = false);
              _navigateTo(const AddVehicleScreen());
            },
          ),
          const SizedBox(height: 12),
          _buildFabOption(
            icon: Icons.build_circle_rounded,
            label: 'Tambah Servis',
            onPressed: () async {
              setState(() => _isFabExpanded = false);
              
              // Cek apakah user sudah punya kendaraan
              final vehicleSnapshot = await _firestore
                  .collection('vehicles')
                  .where('userId', isEqualTo: _currentUser!.uid)
                  .get();

              if (vehicleSnapshot.docs.isEmpty) {
                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Belum Ada Kendaraan'),
                      content: const Text('Anda belum memiliki kendaraan. Silakan tambah kendaraan terlebih dahulu.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _navigateTo(const AddVehicleScreen());
                          },
                          child: const Text('Tambah Kendaraan'),
                        ),
                      ],
                    ),
                  );
                }
              } else {
                _navigateTo(const AddServiceScreen());
              }
            },
          ),
          const SizedBox(height: 12),
        ],
        FloatingActionButton(
          onPressed: () {
            setState(() => _isFabExpanded = !_isFabExpanded);
          },
          backgroundColor: const Color(0xFF8100D1),
          foregroundColor: Colors.white,
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 300),
            turns: _isFabExpanded ? 0.125 : 0,
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildFabOption({required IconData icon, required String label, required VoidCallback onPressed}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.small(
          onPressed: onPressed,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF8100D1),
          child: Icon(icon),
        ),
      ],
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
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () => _authService.signOut(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF8100D1), Color(0xFF4B0082)],
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
                padding: const EdgeInsets.only(left: 20, bottom: 30),
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
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Kendaraan',
                _firestore
                    .collection('vehicles')
                    .where('userId', isEqualTo: _currentUser!.uid)
                    .snapshots(),
                (s) => s.docs.length.toString(),
                Icons.directions_car_filled_rounded,
                Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Servis Bulan Ini',
                _getMonthlyServicesQuery().snapshots(),
                (s) => s.docs.length.toString(),
                Icons.handyman_rounded,
                Colors.orangeAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Servis',
                _firestore
                    .collection('services')
                    .where('userId', isEqualTo: _currentUser!.uid)
                    .snapshots(),
                (s) => s.docs.length.toString(),
                Icons.checklist_rtl_rounded,
                Colors.purpleAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Biaya (Bulan Ini)',
                _getMonthlyServicesQuery().snapshots(),
                (snapshot) {
                  double total = 0;
                  for (var doc in snapshot.docs) {
                    total += ((doc.data() as Map<String, dynamic>)['cost'] ?? 0).toDouble();
                  }
                  return 'Rp ${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
                },
                Icons.account_balance_wallet_rounded,
                Colors.greenAccent[700]!,
              ),
            ),
          ],
        ),
      ],
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
      padding: const EdgeInsets.all(16),
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
          .orderBy('nextServiceDate', descending: false)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState('Tidak ada servis terjadwal', Icons.calendar_today_outlined);
        }

        final docs = snapshot.data!.docs;
        return Column(
          children: docs.map((doc) => _buildServiceItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildServiceItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final nextDate = (data['nextServiceDate'] as Timestamp).toDate();
    final vehicleId = data['vehicleId'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event_note_rounded, color: Colors.orange),
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
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
          const Icon(Icons.chevron_right, color: Colors.grey),
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

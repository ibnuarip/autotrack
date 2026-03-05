import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      body: CustomScrollView(
        slivers: [
          // PREMIUM HEADER
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF8100D1),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF8100D1), Color(0xFFB500B2)],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/autotrack-logo.png',
                          width: 40,
                          height: 40,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'AutoTrack',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'Versi 1.0.0',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ABOUT SECTION (Original Content)
                  _buildSectionTitle('Tentang AutoTrack'),
                  const SizedBox(height: 16),
                  _buildContentCard(
                    child: Column(
                      children: [
                        _buildParagraph(
                          'AutoTrack adalah solusi cerdas untuk memantau kesehatan kendaraan Anda secara real-time. Kami percaya bahwa perawatan yang terjadwal bukan hanya soal kenyamanan, tetapi juga kunci utama keselamatan Anda di jalan raya.',
                        ),
                        const SizedBox(height: 12),
                        _buildParagraph(
                          'Dengan fitur pencatatan servis yang detail, Anda dapat memantau pengeluaran perawatan berkala dan mendapatkan estimasi waktu servis berikutnya. Ini membantu Anda menghindari biaya perbaikan yang tak terduga akibat kerusakan berat.',
                        ),
                        const SizedBox(height: 12),
                        _buildParagraph(
                          'Antarmuka yang premium dan intuitif memastikan setiap pengguna dapat mengelola riwayat kendaraan mereka dengan mudah, memberikan ketenangan pikiran dalam setiap perjalanan.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // FEATURES SECTION
                  _buildSectionTitle('Fitur Unggulan'),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    Icons.history_edu_rounded,
                    'Pencatatan Servis',
                    'Simpan riwayat lengkap setiap kali kendaraan Anda masuk bengkel.',
                  ),
                  _buildFeatureItem(
                    Icons.notifications_active_rounded,
                    'Pengingat Pintar',
                    'Notifikasi otomatis agar Anda tidak pernah melewatkan jadwal service.',
                  ),
                  _buildFeatureItem(
                    Icons.analytics_rounded,
                    'Analisis Biaya',
                    'Pantau pengeluaran perawatan kendaraan Anda secara mendetail.',
                  ),
                  const SizedBox(height: 32),

                  // DEVELOPER INFO
                  _buildSectionTitle('Informasi Aplikasi'),
                  const SizedBox(height: 16),
                  _buildContentCard(
                    child: Column(
                      children: [
                        _buildInfoRow('Developer', 'Alghifari', Icons.person_outline_rounded),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        _buildInfoRow('Email', 'alghifari@autotrack.app', Icons.mail_outline_rounded),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        _buildInfoRow('Tahun Rilis', '2026', Icons.calendar_today_rounded),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // FOOTER
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '© 2026 AutoTrack Teams',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Made with ❤️ for car enthusiasts',
                          style: TextStyle(
                            color: Color(0xFFB500B2),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3142),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      textAlign: TextAlign.justify,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[700],
        height: 1.6,
      ),
    );
  }

  Widget _buildContentCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF8100D1).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF8100D1), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3142),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

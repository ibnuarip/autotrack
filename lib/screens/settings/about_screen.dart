import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // Standard list background color
      appBar: AppBar(
        title: const Text(
          'Tentang AutoTrack',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF2F2F7), // Match background for seamless look
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 36),
          // HEADER: Logo & App Info
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white, // Latar belakang putih bersih
                borderRadius: BorderRadius.circular(18), // Sudut melengkung halus membulat
                border: Border.all(
                  color: Colors.black.withOpacity(0.04), // Border super tipis
                  width: 1,
                ),
                boxShadow: [ // Bayangan natural iOS
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 14,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: Image.asset(
                  'assets/images/autotrack-logo.png',
                  fit: BoxFit.cover, 
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.directions_car, size: 36, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'AutoTrack',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Versi 1.0.0 (Build 12)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 36),

          // GROUP 1: Feedback & Community
          _buildGroup(
            children: [
              _buildListTile(
                icon: Icons.star_border_rounded,
                iconColor: Colors.orange,
                title: 'Beri Nilai AutoTrack',
                onTap: () {
                  // Navigate to App Store / Play Store (placeholder)
                },
              ),
              _buildDivider(),
              _buildListTile(
                icon: Icons.mail_outline_rounded,
                iconColor: Colors.blue,
                title: 'Kirim Masukan',
                onTap: () {
                  // Open Email client (placeholder)
                },
              ),
              _buildDivider(),
              _buildListTile(
                icon: Icons.bug_report_outlined,
                iconColor: Colors.red,
                title: 'Laporkan Masalah',
                onTap: () {
                  // Open Issue Report tracker (placeholder)
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // GROUP 2: Info & Legal
          _buildGroup(
            children: [
               _buildListTile(
                icon: Icons.public,
                iconColor: Colors.green,
                title: 'Kunjungi Website',
                onTap: () {
                  // Open Website (placeholder)
                },
              ),
              _buildDivider(),
              _buildListTile(
                icon: Icons.description_outlined,
                iconColor: Colors.grey[700]!,
                title: 'Syarat & Ketentuan',
                onTap: () {
                  // Open Terms (placeholder)
                },
              ),
              _buildDivider(),
              _buildListTile(
                icon: Icons.privacy_tip_outlined,
                iconColor: Colors.grey[700]!,
                title: 'Kebijakan Privasi',
                onTap: () {
                  // Open Privacy Policies (placeholder)
                },
              ),
              _buildDivider(),
              _buildListTile(
                icon: Icons.info_outline_rounded,
                iconColor: Colors.grey[700]!,
                title: 'Lisensi Open Source',
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'AutoTrack',
                    applicationVersion: '1.0.0',
                    applicationLegalese: 'Hak Cipta © 2026\nAutoTrack Teams',
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 48),

          // FOOTER: Copyright
          const Center(
            child: Text(
              'AutoTrack Teams',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black45,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Hak Cipta © 2026 Dilindungi Undang-Undang',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black38,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGroup({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10), // Matches group radius if it's top/bot child
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 56),
      child: Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5EA)),
    );
  }
}

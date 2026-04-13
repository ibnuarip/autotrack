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
          const SizedBox(height: 48),
          // HEADER: Logo & App Info (Premium Redesign)
          Center(
            child: Column(
              children: [
                // Minimalist Logo Presentation
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF8100D1).withOpacity(0.05),
                        const Color(0xFFB500B2).withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Hero(
                      tag: 'app_logo',
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8100D1).withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/autotrack-logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.directions_car_filled_rounded,
                              size: 40,
                              color: Color(0xFF8100D1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'AutoTrack',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Versi 1.0.1 • Build 24',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),

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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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
      padding: EdgeInsets.only(left: 68),
      child: Divider(height: 1, thickness: 0.5, color: Color(0xFFF2F2F7)),
    );
  }
}

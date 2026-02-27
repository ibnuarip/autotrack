import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<Map<String, String>> _faqs = [
    {
      'question': 'Bagaimana cara menambah kendaraan?',
      'answer': 'Buka halaman Dashboard, lalu tekan tombol "+" atau "Tambah Kendaraan". Isi detail kendaraan Anda seperti nama, tipe, dan plat nomor.'
    },
    {
      'question': 'Bagaimana cara mencatat servis baru?',
      'answer': 'Pilih kendaraan yang ingin diservis di halaman Utama, lalu klik tombol "Tambah Servis". Masukkan tanggal, jenis servis, biaya, dan catatan lainnya.'
    },
    {
      'question': 'Apakah data saya aman?',
      'answer': 'Tentu! Semua data Anda disimpan secara aman di Cloud Firestore dan hanya dapat diakses melalui akun Anda yang sudah terverifikasi.'
    },
    {
      'question': 'Bagaimana cara mengganti kata sandi?',
      'answer': 'Buka Pengaturan > Profil Saya, lalu scroll ke bawah dan pilih tombol "Ganti Kata Sandi".'
    },
    {
      'question': 'Bagaimana cara kerja pengingat servis?',
      'answer': 'Aplikasi akan menghitung estimasi servis berikutnya berdasarkan riwayat servis Anda dan mengirimkan notifikasi saat waktunya tiba.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Pusat Bantuan'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // COMPACT HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    'Apa yang bisa kami bantu?',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Temukan jawaban cepat untuk pertanyaan Anda di sini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // FAQ SECTION
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'Pertanyaan Sering Diajukan (FAQ)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
              ),
            ),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _faqs.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ExpansionTile(
                    title: Text(
                      _faqs[index]['question']!,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF2D2D2D)),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    iconColor: const Color(0xFF8100D1),
                    collapsedIconColor: Colors.grey,
                    shape: const Border(),
                    children: [
                      Text(
                        _faqs[index]['answer']!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // CONTACT SECTION
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'Masih butuh bantuan?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8100D1), Color(0xFFB500B2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'Hubungi Tim Dukungan Kami',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kami siap membantu Anda kapan saja melalui saluran di bawah ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildContactButton(
                          Icons.email_outlined,
                          'Email',
                          () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildContactButton(
                          Icons.chat_bubble_outline_rounded,
                          'WhatsApp',
                          () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF8100D1),
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

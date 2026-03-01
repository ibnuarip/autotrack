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
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Bantuan'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PREMIUM GRADIENT HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 120, 24, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8100D1), Color(0xFF6A00AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: const Column(
                children: [
                   Icon(Icons.help_center_rounded, size: 64, color: Colors.white24),
                   SizedBox(height: 16),
                   Text(
                    'Pusat Informasi AutoTrack',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Kelola kendaraan Anda dengan lebih cerdas dan efisien.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

            // INTRODUCTORY SECTION
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tentang AutoTrack',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                  ),
                  const SizedBox(height: 16),
                  _buildIntroParagraph(
                    'AutoTrack adalah solusi cerdas untuk memantau kesehatan kendaraan Anda secara real-time. Kami percaya bahwa perawatan yang terjadwal bukan hanya soal kenyamanan, tetapi juga kunci utama keselamatan Anda di jalan raya.',
                  ),
                  _buildIntroParagraph(
                    'Dengan fitur pencatatan servis yang detail, Anda dapat memantau pengeluaran perawatan berkala dan mendapatkan estimasi waktu servis berikutnya. Ini membantu Anda menghindari biaya perbaikan yang tak terduga akibat kerusakan berat.',
                  ),
                  _buildIntroParagraph(
                    'Antarmuka yang premium dan intuitif memastikan setiap pengguna dapat mengelola riwayat kendaraan mereka dengan mudah, memberikan ketenangan pikiran dalam setiap perjalanan.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // FAQ SECTION
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.question_answer_rounded, color: Color(0xFF8100D1), size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Pertanyaan Populer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                  ),
                ],
              ),
            ),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _faqs.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[100]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text(
                        _faqs[index]['question']!,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF2D2D2D)),
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      iconColor: const Color(0xFF8100D1),
                      collapsedIconColor: Colors.grey[400],
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8100D1).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _faqs[index]['answer']!,
                            style: TextStyle(color: Colors.grey[700], fontSize: 14, height: 1.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 15,
          height: 1.6,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

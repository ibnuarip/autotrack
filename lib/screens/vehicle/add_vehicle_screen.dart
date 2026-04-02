import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddVehicleScreen extends StatefulWidget {
  final String? vehicleId;
  final Map<String, dynamic>? vehicleData;

  const AddVehicleScreen({
    super.key,
    this.vehicleId,
    this.vehicleData,
  });

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _plateController;
  
  late String _selectedType;
  late String _selectedBrand;
  late TextEditingController _customBrandController;
  bool _isLoading = false;

  final List<String> _brands = [
    'Honda',
    'Yamaha',
    'Toyota',
    'Suzuki',
    'Kawasaki',
    'Mitsubishi',
    'Daihatsu',
    'BMW',
    'Mercedes-Benz',
    'Nissan',
    'Lainnya',
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get _isEditing => widget.vehicleId != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.vehicleData?['name'] ?? '');
    _plateController = TextEditingController(text: widget.vehicleData?['plateNumber'] ?? '');
    _customBrandController = TextEditingController();
    _selectedType = widget.vehicleData?['type'] ?? 'Motor';
    
    final existingBrand = widget.vehicleData?['brand'];
    if (existingBrand != null) {
      if (_brands.contains(existingBrand)) {
        _selectedBrand = existingBrand;
      } else {
        _selectedBrand = 'Lainnya';
        _customBrandController.text = existingBrand;
      }
    } else {
      _selectedBrand = 'Honda';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _plateController.dispose();
    _customBrandController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final String uid = _auth.currentUser!.uid;
      final String finalBrand = _selectedBrand == 'Lainnya' 
          ? _customBrandController.text.trim()
          : _selectedBrand;
          
      final vehicleData = {
        'userId': uid,
        'name': _nameController.text.trim(),
        'brand': finalBrand,
        'plateNumber': _plateController.text.trim().toUpperCase(),
        'type': _selectedType,
        if (!_isEditing) 'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_isEditing) {
        await _firestore.collection('vehicles').doc(widget.vehicleId).update(vehicleData);
      } else {
        await _firestore.collection('vehicles').add(vehicleData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Data kendaraan diperbarui' : 'Kendaraan berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF8100D1)),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Pilih Jenis Kendaraan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF636E72),
            ),
          ),
        ),
        Row(
          children: [
            _buildTypeCard('Motor', Icons.motorcycle_rounded),
            const SizedBox(width: 12),
            _buildTypeCard('Mobil', Icons.directions_car_rounded),
            const SizedBox(width: 12),
            _buildTypeCard('Roda Tiga', Icons.electric_rickshaw_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeCard(String type, IconData icon) {
    bool isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF8100D1) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF8100D1) : Colors.grey[200]!,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF8100D1).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                type,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _getInputDecoration(String label, IconData icon, [String? hint]) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Colors.grey[600]),
      prefixIcon: Icon(icon, color: const Color(0xFF8100D1)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[100]!, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[100]!, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF8100D1), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      filled: true,
      fillColor: const Color(0xFFFBFBFE),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Kendaraan' : 'Tambah Kendaraan Baru',
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF2D3436),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8100D1)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- SECTION 1: IDENTITAS ---
                    _buildSectionHeader('Identitas Kendaraan', Icons.badge_rounded),
                    _buildCard([
                      _buildTypeSelector(),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        decoration: _getInputDecoration('Nama Kendaraan', Icons.edit_rounded, 'Contoh: Honda Beat FI'),
                        validator: (value) => (value == null || value.isEmpty) ? 'Nama kendaraan wajib diisi' : null,
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedBrand,
                        isExpanded: true,
                        decoration: _getInputDecoration('Merek / Brand', Icons.branding_watermark_rounded),
                        items: _brands.map((brand) {
                          return DropdownMenuItem(value: brand, child: Text(brand));
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _selectedBrand = value);
                        },
                        validator: (value) => (value == null || value.isEmpty) ? 'Pilih merek kendaraan' : null,
                      ),
                      if (_selectedBrand == 'Lainnya') ...[
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _customBrandController,
                          decoration: _getInputDecoration('Tulis Merek Anda', Icons.edit_note_rounded, 'Contoh: Vespa / Tesla'),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (_selectedBrand == 'Lainnya' && (value == null || value.trim().isEmpty)) {
                              return 'Merek wajib diisi';
                            }
                            return null;
                          },
                        ),
                      ],
                    ]),

                    const SizedBox(height: 24),

                    // --- SECTION 2: ADMNISTRASI ---
                    _buildSectionHeader('Data Registrasi', Icons.assignment_rounded),
                    _buildCard([
                      TextFormField(
                        controller: _plateController,
                        decoration: _getInputDecoration('Nomor Polisi', Icons.pin_rounded, 'B 1234 ABC'),
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                        inputFormatters: [
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            return newValue.copyWith(text: newValue.text.toUpperCase());
                          }),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Nomor polisi wajib diisi';
                          if (value.length < 5) return 'Nomor polisi minimal 5 karakter';
                          return null;
                        },
                      ),
                    ]),

                    const SizedBox(height: 48),

                    // --- TOMBOL SIMPAN ---
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8100D1).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveVehicle,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8100D1), Color(0xFFB500B2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              _isEditing ? 'SIMPAN PERUBAHAN' : 'TAMBAHKAN KENDARAAN',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}

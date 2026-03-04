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
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get _isEditing => widget.vehicleId != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.vehicleData?['name'] ?? '');
    _plateController = TextEditingController(text: widget.vehicleData?['plateNumber'] ?? '');
    _selectedType = widget.vehicleData?['type'] ?? 'Motor';
    
    final existingBrand = widget.vehicleData?['brand'];
    if (existingBrand != null && _brands.contains(existingBrand)) {
      _selectedBrand = existingBrand;
    } else {
      _selectedBrand = 'Honda';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final String uid = _auth.currentUser!.uid;
      final vehicleData = {
        'userId': uid,
        'name': _nameController.text.trim(),
        'brand': _selectedBrand,
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

  Widget _buildShadowContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
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
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF8100D1), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.transparent, // Let the container's white color show
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Modern off-white background
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Kendaraan' : 'Tambah Kendaraan',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF8100D1), Color(0xFF4B0082)],
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildShadowContainer(
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: _getInputDecoration('Jenis Kendaraan', Icons.category),
                        items: const [
                          DropdownMenuItem(value: 'Motor', child: Text('Motor')),
                          DropdownMenuItem(value: 'Mobil', child: Text('Mobil')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedType = value);
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pilih jenis kendaraan';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildShadowContainer(
                      TextFormField(
                        controller: _nameController,
                        decoration: _getInputDecoration('Nama Kendaraan', Icons.directions_car, '(Contoh: Beat)'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama kendaraan wajib diisi';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildShadowContainer(
                      DropdownButtonFormField<String>(
                        value: _selectedBrand,
                        decoration: _getInputDecoration('Merek / Brand', Icons.branding_watermark),
                        items: _brands.map((brand) {
                          return DropdownMenuItem(value: brand, child: Text(brand));
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedBrand = value);
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pilih merek kendaraan';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildShadowContainer(
                      TextFormField(
                        controller: _plateController,
                        decoration: _getInputDecoration('Nomor Polisi', Icons.pin, 'B 1234 ABC'),
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            return newValue.copyWith(text: newValue.text.toUpperCase());
                          }),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nomor polisi wajib diisi';
                          }
                          if (value.length < 5) {
                            return 'Nomor polisi minimal 5 karakter';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8100D1).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _saveVehicle,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xFF8100D1), Color(0xFF4B0082)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            constraints: const BoxConstraints(minHeight: 56),
                            child: Text(
                              _isEditing ? 'Simpan Perubahan' : 'Simpan Kendaraan',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}

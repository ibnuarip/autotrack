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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Kendaraan' : 'Tambah Kendaraan'),
        backgroundColor: const Color(0xFF8100D1),
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Kendaraan',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Kendaraan',
                        hintText: '( Contoh Beat)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.directions_car),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama kendaraan wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedBrand,
                      decoration: const InputDecoration(
                        labelText: 'Merek / Brand',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.branding_watermark),
                      ),
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _plateController,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Polisi',
                        hintText: 'XX XXXX XXX',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pin),
                      ),
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
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveVehicle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8100D1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isEditing ? 'Simpan Perubahan' : 'Simpan Kendaraan',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

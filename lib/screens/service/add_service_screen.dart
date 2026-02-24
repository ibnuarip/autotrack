import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _selectedVehicleId;
  DateTime _serviceDate = DateTime.now();
  DateTime? _nextServiceDate;
  TimeOfDay? _reminderTime;
  
  final TextEditingController _serviceTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _serviceTypeController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _selectServiceDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _serviceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _serviceDate) {
      setState(() {
        _serviceDate = picked;
      });
    }
  }

  Future<void> _selectNextServiceDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _nextServiceDate ?? DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _nextServiceDate) {
      setState(() {
        _nextServiceDate = picked;
      });
    }
  }

  Future<void> _selectReminderTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate() || _selectedVehicleId == null) {
      if (_selectedVehicleId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih kendaraan')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String uid = _auth.currentUser!.uid;
      
      await _firestore.collection('services').add({
        'userId': uid,
        'vehicleId': _selectedVehicleId,
        'serviceDate': Timestamp.fromDate(_serviceDate),
        'serviceType': _serviceTypeController.text.trim(),
        'description': _descriptionController.text.trim(),
        'cost': double.parse(_costController.text),
        'nextServiceDate': _nextServiceDate != null ? Timestamp.fromDate(_nextServiceDate!) : null,
        'reminderTime': _reminderTime != null ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}' : null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service berhasil ditambahkan'),
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
        title: const Text('Tambah Servis'),
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
                    // Dropdown Pilih Kendaraan
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('vehicles')
                          .where('userId', isEqualTo: _auth.currentUser?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text('Tidak ada kendaraan ditemukan');
                        }
                        
                        var vehicleDocs = snapshot.data!.docs;
                        
                        return DropdownButtonFormField<String>(
                          value: _selectedVehicleId,
                          decoration: const InputDecoration(
                            labelText: 'Pilih Kendaraan',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.directions_car),
                          ),
                          items: vehicleDocs.map((doc) {
                            var data = doc.data() as Map<String, dynamic>;
                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text('${data['name']} - ${data['plateNumber']}'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedVehicleId = value);
                          },
                          validator: (value) => value == null ? 'Kendaraan wajib dipilih' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Tanggal Servis
                    InkWell(
                      onTap: () => _selectServiceDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Servis',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          '${_serviceDate.day}/${_serviceDate.month}/${_serviceDate.year}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Jenis Servis
                    TextFormField(
                      controller: _serviceTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Servis',
                        hintText: 'Ganti Oli, Servis Rutin, dll',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.build),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jenis servis wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Deskripsi
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi (Opsional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Biaya
                    TextFormField(
                      controller: _costController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Biaya (Rp)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.payments),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Biaya wajib diisi';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Biaya harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tanggal Servis Berikutnya (Opsional)
                    InkWell(
                      onTap: () => _selectNextServiceDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Servis Berikutnya (Opsional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.event_repeat),
                        ),
                        child: Text(
                          _nextServiceDate == null
                              ? 'Pilih tanggal (jika ada)'
                              : '${_nextServiceDate!.day}/${_nextServiceDate!.month}/${_nextServiceDate!.year}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Waktu Pengingat (Opsional)
                    InkWell(
                      onTap: () => _selectReminderTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Waktu Pengingat (Opsional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          _reminderTime == null
                              ? 'Pilih waktu pengingat'
                              : _reminderTime!.format(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tombol Simpan
                    ElevatedButton(
                      onPressed: _saveService,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8100D1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Simpan Servis',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

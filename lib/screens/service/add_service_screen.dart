import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class AddServiceScreen extends StatefulWidget {
  final String? serviceId;
  final Map<String, dynamic>? initialData;

  const AddServiceScreen({
    super.key,
    this.serviceId,
    this.initialData,
  });

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _selectedVehicleId;
  late DateTime _serviceDate;
  DateTime? _nextServiceDate;
  TimeOfDay? _reminderTime;
  
  final TextEditingController _serviceTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  
  bool _isLoading = false;
  bool get _isEditMode => widget.serviceId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode && widget.initialData != null) {
      final data = widget.initialData!;
      _selectedVehicleId = data['vehicleId'];
      _serviceDate = (data['serviceDate'] as Timestamp).toDate();
      _serviceTypeController.text = data['serviceType'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _costController.text = (data['cost'] ?? 0).toString();
      
      if (data['nextServiceDate'] != null) {
        _nextServiceDate = (data['nextServiceDate'] as Timestamp).toDate();
      }
      
      if (data['reminderTime'] != null) {
        final timeParts = (data['reminderTime'] as String).split(':');
        if (timeParts.length == 2) {
          _reminderTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
        }
      }
    } else {
      _serviceDate = DateTime.now();
    }
  }

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
          const SnackBar(
            content: Text('Silakan pilih kendaraan terlebih dahulu.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String uid = _auth.currentUser!.uid;
      final Map<String, dynamic> serviceData = {
        'userId': uid,
        'vehicleId': _selectedVehicleId,
        'serviceDate': Timestamp.fromDate(_serviceDate),
        'serviceType': _serviceTypeController.text.trim(),
        'description': _descriptionController.text.trim(),
        'cost': double.parse(_costController.text),
        'nextServiceDate': _nextServiceDate != null ? Timestamp.fromDate(_nextServiceDate!) : null,
        'reminderTime': _reminderTime != null ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}' : null,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      String docId;
      if (!_isEditMode) {
        serviceData['createdAt'] = FieldValue.serverTimestamp();
        final result = await _firestore.collection('services').add(serviceData);
        docId = result.id;
      } else {
        docId = widget.serviceId!;
        await _firestore.collection('services').doc(docId).update(serviceData);
      }

      // Schedule notification if nextServiceDate exists
      if (_nextServiceDate != null) {
        try {
          final vehicleDoc = await _firestore.collection('vehicles').doc(_selectedVehicleId).get();
          if (vehicleDoc.exists) {
            final vehicleName = (vehicleDoc.data() as Map<String, dynamic>)['name'] ?? 'Kendaraan';
            await NotificationService().scheduleServiceReminder(
              id: docId.hashCode,
              vehicleName: vehicleName,
              nextServiceDate: _nextServiceDate!,
            );
          }
        } catch (e) {
          debugPrint('Notification scheduling failed: $e');
          // We don't rethrow here so the user still sees a success message for the Firestore save
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Data servis berhasil diperbarui.' : 'Data servis kendaraan Anda telah disimpan.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Gagal Memperbarui Data: $e' : 'Gagal Menyimpan Data: $e'),
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
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Modern off-white background
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Servis' : 'Tambah Servis',
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
                          return _buildShadowContainer(
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Tidak ada kendaraan ditemukan. Silakan tambah kendaraan terlebih dahulu.',
                                style: TextStyle(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        
                        var vehicleDocs = snapshot.data!.docs;
                        
                        return _buildShadowContainer(
                          DropdownButtonFormField<String>(
                            value: _selectedVehicleId,
                            decoration: _getInputDecoration('Pilih Kendaraan', Icons.directions_car),
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
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Tanggal Servis
                    _buildShadowContainer(
                      InkWell(
                        onTap: () => _selectServiceDate(context),
                        borderRadius: BorderRadius.circular(16),
                        child: InputDecorator(
                          decoration: _getInputDecoration('Tanggal Servis', Icons.calendar_today),
                          child: Text(
                            '${_serviceDate.day}/${_serviceDate.month}/${_serviceDate.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Jenis Servis
                    _buildShadowContainer(
                      TextFormField(
                        controller: _serviceTypeController,
                        decoration: _getInputDecoration('Jenis Servis', Icons.build, 'Ganti Oli, Servis Rutin, dll'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jenis servis wajib diisi';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Deskripsi
                    _buildShadowContainer(
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: _getInputDecoration('Deskripsi (Opsional)', Icons.description),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Biaya
                    _buildShadowContainer(
                      TextFormField(
                        controller: _costController,
                        keyboardType: TextInputType.number,
                        decoration: _getInputDecoration('Biaya (Rp)', Icons.payments),
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
                    ),
                    const SizedBox(height: 20),

                    // Tanggal Servis Berikutnya (Opsional)
                    _buildShadowContainer(
                      InkWell(
                        onTap: () => _selectNextServiceDate(context),
                        borderRadius: BorderRadius.circular(16),
                        child: InputDecorator(
                          decoration: _getInputDecoration('Servis Berikutnya (Opsional)', Icons.event_repeat),
                          child: Text(
                            _nextServiceDate == null
                                ? 'Pilih tanggal (jika ada)'
                                : '${_nextServiceDate!.day}/${_nextServiceDate!.month}/${_nextServiceDate!.year}',
                            style: TextStyle(
                              fontSize: 16, 
                              color: _nextServiceDate == null ? Colors.grey[600] : Colors.black87
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Waktu Pengingat (Opsional)
                    _buildShadowContainer(
                      InkWell(
                        onTap: () => _selectReminderTime(context),
                        borderRadius: BorderRadius.circular(16),
                        child: InputDecorator(
                          decoration: _getInputDecoration('Waktu Pengingat (Opsional)', Icons.access_time),
                          child: Text(
                            _reminderTime == null
                                ? 'Pilih waktu pengingat'
                                : _reminderTime!.format(context),
                            style: TextStyle(
                              fontSize: 16, 
                              color: _reminderTime == null ? Colors.grey[600] : Colors.black87
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Tombol Simpan
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
                        onPressed: _isLoading ? null : _saveService,
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
                              _isEditMode ? 'Update Servis' : 'Simpan Servis',
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

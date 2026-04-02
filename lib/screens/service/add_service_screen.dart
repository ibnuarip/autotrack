import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  
  late Stream<QuerySnapshot> _vehicleStream;
  bool _isRecurring = false;
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
      _isRecurring = data['isRecurring'] ?? false;
      
      // Format existing cost with dots on load
      String costStr = (data['cost'] ?? 0).toString().split('.').first;
      _costController.text = _formatExistingCost(costStr);
      
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

    // Listener untuk update status button chip saat user ngetik manual
    _serviceTypeController.addListener(() {
      if (mounted) setState(() {});
    });

    // Inisialisasi stream di initState agar tidak kedip-kedip saat setState panggil build
    _vehicleStream = _firestore
        .collection('vehicles')
        .where('userId', isEqualTo: _auth.currentUser?.uid)
        .snapshots();
  }

  @override
  void dispose() {
    _serviceTypeController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  String _formatExistingCost(String s) {
    if (s.isEmpty) return '';
    return s.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
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
      initialDate: _nextServiceDate ?? _serviceDate,
      firstDate: _serviceDate,
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
        'cost': double.parse(_costController.text.replaceAll('.', '')),
        'nextServiceDate': _nextServiceDate != null ? Timestamp.fromDate(_nextServiceDate!) : null,
        'reminderTime': _reminderTime != null ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}' : null,
        'isRecurring': _isRecurring,
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
              hour: _reminderTime?.hour ?? 8,
              minute: _reminderTime?.minute ?? 0,
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
              colors: [Color(0xFF8100D1), Color(0xFFB500B2)],
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
                    // --- SECTION 1: KENDARAAN ---
                    _buildSectionHeader('Informasi Kendaraan', Icons.directions_car_filled_rounded),
                    _buildCard([
                      StreamBuilder<QuerySnapshot>(
                        stream: _vehicleStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                                  SizedBox(width: 12),
                                  Expanded(child: Text('Belum ada kendaraan. Tambah kendaraan dulu ya!', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))),
                                ],
                              ),
                            );
                          }
                          
                          var vehicleDocs = snapshot.data!.docs;
                          
                          return DropdownButtonFormField<String>(
                            value: _selectedVehicleId,
                            isExpanded: true,
                            decoration: _getInputDecoration('Pilih Kendaraan', Icons.minor_crash_rounded),
                            items: vehicleDocs.map((doc) {
                              var data = doc.data() as Map<String, dynamic>;
                              return DropdownMenuItem<String>(
                                value: doc.id,
                                child: Text('${data['name']} (${data['plateNumber']})'),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedVehicleId = value),
                            validator: (value) => value == null ? 'Pilih kendaraan Anda' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectServiceDate(context),
                        borderRadius: BorderRadius.circular(16),
                        child: InputDecorator(
                          decoration: _getInputDecoration('Tanggal Pelaksanaan', Icons.calendar_month_rounded),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_serviceDate.day} ${_getMonthName(_serviceDate.month)} ${_serviceDate.year}',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                              const Icon(Icons.edit_calendar_rounded, size: 20, color: Color(0xFF8100D1)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isRecurring ? const Color(0xFF8100D1).withOpacity(0.05) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isRecurring ? const Color(0xFF8100D1).withOpacity(0.2) : Colors.grey[100]!,
                            width: 1.5,
                          ),
                        ),
                        child: SwitchListTile(
                          title: const Text(
                            'Jadikan Rutinitas (Ulangi)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: const Text(
                            'Aktifkan fitur ini jika servis ini dilakukan berkala.',
                            style: TextStyle(fontSize: 11),
                          ),
                          value: _isRecurring,
                          onChanged: (bool value) => setState(() => _isRecurring = value),
                          activeColor: const Color(0xFF8100D1),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // --- SECTION 2: DETAIL SERVIS ---
                    _buildSectionHeader('Detail Pekerjaan', Icons.handyman_rounded),
                    _buildCard([
                      TextFormField(
                        controller: _serviceTypeController,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D3436)),
                        decoration: _getInputDecoration('Jenis Servis / Item', Icons.settings_suggest_rounded, 'Contoh: Ganti Oli Mesin'),
                        validator: (value) => (value == null || value.isEmpty) ? 'Apa yang diservis?' : null,
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _buildQuickChip('Ganti Oli'),
                            _buildQuickChip('Servis Rutin'),
                            _buildQuickChip('Rem'),
                            _buildQuickChip('Ban'),
                            _buildQuickChip('Aki'),
                            _buildQuickChip('Lampu'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _costController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
                        decoration: _getInputDecoration('Total Biaya (Rp)', Icons.account_balance_wallet_rounded, '0').copyWith(
                          prefixIcon: const Icon(Icons.payments_rounded, color: Color(0xFF8100D1)),
                          prefixText: 'Rp ',
                          prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Biaya tidak boleh kosong';
                          if (double.tryParse(value) == null) return 'Masukkan angka saja';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: _getInputDecoration('Catatan (Opsional)', Icons.notes_rounded, 'Detail pengerjaan atau kondisi...'),
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // --- SECTION 3: RENCANA MENDATANG ---
                    _buildSectionHeader('Jadwal & Pengingat', Icons.notification_add_rounded),
                    _buildCard([
                      InkWell(
                        onTap: () => _selectNextServiceDate(context),
                        borderRadius: BorderRadius.circular(16),
                        child: InputDecorator(
                          decoration: _getInputDecoration('Servis Berikutnya', Icons.event_repeat_rounded),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _nextServiceDate == null
                                    ? 'Klik untuk jadwalkan'
                                    : '${_nextServiceDate!.day} ${_getMonthName(_nextServiceDate!.month)} ${_nextServiceDate!.year}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: _nextServiceDate == null ? FontWeight.normal : FontWeight.w600,
                                  color: _nextServiceDate == null ? Colors.grey[600] : Colors.black87,
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_nextServiceDate != null)
                        InkWell(
                          onTap: () => _selectReminderTime(context),
                          borderRadius: BorderRadius.circular(16),
                          child: InputDecorator(
                            decoration: _getInputDecoration('Waktu Pengingat', Icons.alarm_rounded),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _reminderTime == null
                                      ? 'Pilih Jam Notifikasi'
                                      : _reminderTime!.format(context),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: _reminderTime == null ? FontWeight.normal : FontWeight.w600,
                                    color: _reminderTime == null ? Colors.grey[600] : Colors.black87,
                                  ),
                                ),
                                const Icon(Icons.access_time_filled_rounded, size: 20, color: Color(0xFF8100D1)),
                              ],
                            ),
                          ),
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
                        onPressed: _isLoading ? null : _saveService,
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
                              _isEditMode ? 'PERBARUI RIWAYAT' : 'SIMPAN RIWAYAT SERVIS',
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

  Widget _buildQuickChip(String label) {
    bool isSelected = _serviceTypeController.text == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 12, 
          fontWeight: FontWeight.bold, 
          color: isSelected ? Colors.white : const Color(0xFF8100D1),
        ),
        selected: isSelected,
        selectedColor: const Color(0xFF8100D1),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: const Color(0xFF8100D1), 
          width: isSelected ? 0 : 0.5,
        ),
        showCheckmark: false,
        onSelected: (bool selected) {
          setState(() {
            _serviceTypeController.text = label;
          });
        },
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Ambil angka saja
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (newText.isEmpty) return newValue.copyWith(text: '');

    // Format dengan titik sebagai pemisah ribuan
    String formatted = _formatNumber(newText);

    return newValue.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length));
  }

  String _formatNumber(String s) {
    return s.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}

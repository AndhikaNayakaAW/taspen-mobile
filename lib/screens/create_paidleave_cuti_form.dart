// lib/screens/create_paidleave_cuti_form.dart

import 'package:flutter/material.dart';
import '../widgets/custom_bottom_app_bar.dart'; // Import the CustomBottomAppBar
import 'saved_paidleave_cuti_screen.dart';
import 'send_paidleave_cuti_screen.dart';
import 'paidleave_cuti_detail_screen.dart'; // Ensure this is used elsewhere if needed
import 'package:intl/intl.dart'; // Import intl for date formatting
// Import file picker package (Add to pubspec.yaml)
import 'package:file_picker/file_picker.dart';

class CreatePaidLeaveCutiForm extends StatefulWidget {
  /// We pass the entire paidLeaves list so we can add a new draft or waiting item
  final List<Map<String, dynamic>> paidLeaves;

  const CreatePaidLeaveCutiForm({
    Key? key,
    required this.paidLeaves,
  }) : super(key: key);

  @override
  _CreatePaidLeaveCutiFormState createState() =>
      _CreatePaidLeaveCutiFormState();
}

class _CreatePaidLeaveCutiFormState extends State<CreatePaidLeaveCutiForm> {
  // ----- DUMMY DATA (for approvers) -----
  final List<Map<String, String>> _approverList = [
    {"id": "60001", "name": "John Doe (CEO)"},
    {"id": "60002", "name": "Jane Smith (CFO)"},
    {"id": "60003", "name": "Robert Brown (COO)"},
  ];

  // ----- FORM FIELDS -----
  String _selectedLeaveType = "Cuti Tahunan"; // Default leave type
  // ----- Cuti Tahunan -----
  int _totalQuotaTahunan = 12;
  int _usedQuotaTahunan = 5; // Example, should be calculated based on previous data
  // ----- Cuti Alasan Penting -----
  int _maxCutiAlasan = 12;
  // ----- Izin -----
  int _maxIzinMendadak = 5;
  // ----- Izin Sakit -----
  PlatformFile? _buktiIzinSakit; // Requires file_picker package
  String _alamatIzinSakit = "";
  // ----- Izin Ibadah -----
  PlatformFile? _buktiIzinIbadah; // Requires file_picker package
  String _alamatIzinIbadah = "";
  // ----- Common Fields -----
  DateTime? _selectedFromDate;
  DateTime? _selectedToDate;
  String _deskripsi = "";
  // ----- Approvers -----
  List<String> _selectedApproverIds = [];
  // ----- Status -----
  String _status = "Draft";

  // Consistent TextStyle
  final TextStyle _labelStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  final TextStyle _inputStyle = const TextStyle(
    fontSize: 16,
  );

  // ========== PICKERS ==========
  Future<void> _pickFromDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedFromDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (result != null) {
      setState(() {
        _selectedFromDate = result;
        // If toDate is before fromDate, reset toDate
        if (_selectedToDate != null && _selectedToDate!.isBefore(result)) {
          _selectedToDate = null;
        }
      });
    }
  }

  Future<void> _pickToDate() async {
    final now = DateTime.now();
    final initialDate = _selectedFromDate ?? now;
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedToDate ?? initialDate,
      firstDate: _selectedFromDate ?? DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (result != null) {
      setState(() {
        _selectedToDate = result;
      });
    }
  }

  Future<void> _pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
      withData: true,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.size > 2 * 1024 * 1024) { // 2 MB
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("File size must be <= 2 MB")),
        );
        return;
      }
      setState(() {
        if (type == "Izin Sakit") {
          _buktiIzinSakit = file;
        } else if (type == "Izin Ibadah") {
          _buktiIzinIbadah = file;
        }
      });
    }
  }

  // ========== BUTTON HANDLERS ==========

  /// Reset the entire form
  void _resetForm() {
    setState(() {
      _selectedLeaveType = "Cuti Tahunan";
      _selectedFromDate = null;
      _selectedToDate = null;
      _deskripsi = "";
      _selectedApproverIds = [];
      _status = "Draft";
      _alamatIzinSakit = "";
      _alamatIzinIbadah = "";
      _buktiIzinSakit = null;
      _buktiIzinIbadah = null;
    });
  }

  /// Save as Draft
  void _saveForm() {
    // Validate form before saving
    if (_validateForm()) {
      final leaveData = {
        "createdBy": "andhika.nayaka",
        "jenisCuti": _selectedLeaveType,
        "fromDate": _selectedFromDate?.toIso8601String() ?? "",
        "toDate": _selectedToDate?.toIso8601String() ?? "",
        "deskripsi": _deskripsi,
        "approverIds": _selectedApproverIds,
        "status": "Draft",
        // Additional fields like uploaded files can be added here
        "buktiIzinSakit": _buktiIzinSakit != null ? _buktiIzinSakit!.name : "",
        "buktiIzinIbadah": _buktiIzinIbadah != null ? _buktiIzinIbadah!.name : "",
        "alamatIzinSakit": _alamatIzinSakit,
        "alamatIzinIbadah": _alamatIzinIbadah,
      };

      widget.paidLeaves.add(leaveData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paid Leave Form Saved! (Draft)")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SavedPaidLeaveCutiScreen(paidLeaves: widget.paidLeaves),
        ),
      );
    }
  }

  /// Send to Approver -> status=Waiting
  void _sendToApprover() {
    // Validate form before sending
    if (_validateForm()) {
      final leaveData = {
        "createdBy": "andhika.nayaka",
        "jenisCuti": _selectedLeaveType,
        "fromDate": _selectedFromDate?.toIso8601String() ?? "",
        "toDate": _selectedToDate?.toIso8601String() ?? "",
        "deskripsi": _deskripsi,
        "approverIds": _selectedApproverIds,
        "status": "Waiting",
        // Additional fields like uploaded files can be added here
        "buktiIzinSakit": _buktiIzinSakit != null ? _buktiIzinSakit!.name : "",
        "buktiIzinIbadah": _buktiIzinIbadah != null ? _buktiIzinIbadah!.name : "",
        "alamatIzinSakit": _alamatIzinSakit,
        "alamatIzinIbadah": _alamatIzinIbadah,
      };

      widget.paidLeaves.add(leaveData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paid Leave Form Sent to Approver! (Waiting)")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SendPaidLeaveCutiScreen(paidLeaves: widget.paidLeaves),
        ),
      );
    }
  }

  /// Validate the form fields
  bool _validateForm() {
    // Common validations
    if (_selectedLeaveType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a leave type.")),
      );
      return false;
    }

    if (_selectedFromDate == null || _selectedToDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select from and to dates.")),
      );
      return false;
    }

    if (_selectedToDate!.isBefore(_selectedFromDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("To Date cannot be before From Date.")),
      );
      return false;
    }

    if (_deskripsi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a description.")),
      );
      return false;
    }

    if (_selectedApproverIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one approver.")),
      );
      return false;
    }

    // Specific validations based on leave type
    switch (_selectedLeaveType) {
      case "Cuti Tahunan":
        if (_calculateUsedCutiTahunan() + _calculateNewCutiDays() > _totalQuotaTahunan) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Exceeded Cuti Tahunan quota.")),
          );
          return false;
        }
        break;
      case "Cuti Alasan Penting":
        if (_calculateNewCutiDays() > _maxCutiAlasan) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Maximum 12 days for Cuti Alasan Penting.")),
          );
          return false;
        }
        break;
      case "Izin":
        if (_calculateIzinMendadak() >= _maxIzinMendadak) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Maximum 5 izin mendadak.")),
          );
          return false;
        }
        break;
      case "Izin Sakit":
        if (_buktiIzinSakit == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please upload bukti izin sakit.")),
          );
          return false;
        }
        if (_alamatIzinSakit.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please provide alamat selama izin sakit.")),
          );
          return false;
        }
        break;
      case "Izin Ibadah":
        if (_buktiIzinIbadah == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please upload bukti izin ibadah.")),
          );
          return false;
        }
        if (_alamatIzinIbadah.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please provide alamat selama izin ibadah.")),
          );
          return false;
        }
        // Check if already taken once
        if (_hasTakenIzinIbadah()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Izin Ibadah can only be taken once during employment.")),
          );
          return false;
        }
        break;
      default:
        break;
    }

    // File size validations can be added here if using file_picker

    // Additional validations can be added here

    return true;
  }

  // ----- QUOTA AND COUNTING METHODS -----
  int _calculateUsedCutiTahunan() {
    // Calculate used Cuti Tahunan based on previous data
    // This is a placeholder. You need to implement actual calculation based on your data.
    return _usedQuotaTahunan;
  }

  int _calculateNewCutiDays() {
    if (_selectedFromDate != null && _selectedToDate != null) {
      return _selectedToDate!.difference(_selectedFromDate!).inDays + 1;
    }
    return 0;
  }

  int _calculateIzinMendadak() {
    // Calculate the number of mendadak izin based on previous data
    // This is a placeholder. Implement actual counting based on your data.
    return widget.paidLeaves
        .where((leave) =>
            leave["jenisCuti"] == "Izin" &&
            leave["status"].toString().toLowerCase() == "waiting")
        .length;
  }

  bool _hasTakenIzinIbadah() {
    // Check if Izin Ibadah has been taken before
    return widget.paidLeaves.any((leave) =>
        leave["jenisCuti"] == "Izin Ibadah" &&
        leave["status"].toString().toLowerCase() == "approved");
  }

  // ========== UI BUILD WITH BOTTOM APP BAR ==========
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Paid Leave/Cuti Form"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // =========== LEAVE TYPE SECTION ===========
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Jenis Cuti:",
                style: _labelStyle,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedLeaveType,
              items: const [
                DropdownMenuItem(
                  value: "Cuti Tahunan",
                  child: Text("Cuti Tahunan"),
                ),
                DropdownMenuItem(
                  value: "Cuti Alasan Penting",
                  child: Text("Cuti Alasan Penting"),
                ),
                DropdownMenuItem(
                  value: "Izin",
                  child: Text("Izin"),
                ),
                DropdownMenuItem(
                  value: "Izin Sakit",
                  child: Text("Izin Sakit"),
                ),
                DropdownMenuItem(
                  value: "Izin Ibadah",
                  child: Text("Izin Ibadah"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedLeaveType = value!;
                  // Reset specific fields when leave type changes
                  _resetSpecificFields();
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
              ),
            ),
            const SizedBox(height: 20),

            // =========== SPECIFIC FIELDS BASED ON LEAVE TYPE ===========
            _buildSpecificFields(),
            const SizedBox(height: 20),

            // =========== APPROVER SECTION ===========
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Approver(s):",
                style: _labelStyle,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: null,
              items: _approverList.map((item) {
                return DropdownMenuItem<String>(
                  value: item["id"],
                  child: Text(item["name"]!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  if (value != null && !_selectedApproverIds.contains(value)) {
                    if (_selectedApproverIds.length < 3) {
                      _selectedApproverIds.add(value);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Maximum 3 approvers allowed.")),
                      );
                    }
                  }
                });
              },
              decoration: const InputDecoration(
                labelText: "Select Approver",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: _selectedApproverIds.map((id) {
                final approver = _approverList.firstWhere((item) => item["id"] == id);
                return Chip(
                  label: Text(approver["name"]!),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      _selectedApproverIds.remove(id);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // =========== COMMON FIELDS ===========
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Deskripsi:",
                style: _labelStyle,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _deskripsi,
              onChanged: (val) {
                _deskripsi = val;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Masukkan deskripsi singkat",
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // =========== BUTTONS ===========
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Reset Button
                ElevatedButton(
                  onPressed: _resetForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  child: const Text(
                    "Reset",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 20),
                // Save Button
                ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 20),
                // Send to Approver Button
                ElevatedButton(
                  onPressed: _sendToApprover,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  child: const Text(
                    "Send to Approver",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomAppBar(),
    );
  }

  /// Reset specific fields when leave type changes
  void _resetSpecificFields() {
    setState(() {
      _selectedFromDate = null;
      _selectedToDate = null;
      _alamatIzinSakit = "";
      _alamatIzinIbadah = "";
      _buktiIzinSakit = null;
      _buktiIzinIbadah = null;
    });
  }

  // ========== SPECIFIC FIELDS BUILDER ==========
  Widget _buildSpecificFields() {
    switch (_selectedLeaveType) {
      case "Cuti Tahunan":
        return _buildCutiTahunanFields();
      case "Cuti Alasan Penting":
        return _buildCutiAlasanPentingFields();
      case "Izin":
        return _buildIzinFields();
      case "Izin Sakit":
        return _buildIzinSakitFields();
      case "Izin Ibadah":
        return _buildIzinIbadahFields();
      default:
        return const SizedBox.shrink();
    }
  }

  // ----- Cuti Tahunan Fields -----
  Widget _buildCutiTahunanFields() {
    int sisaQuota = _totalQuotaTahunan - _calculateUsedCutiTahunan();
    int requestedDays = _calculateNewCutiDays();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Cuti Tahunan:",
            style: _labelStyle,
          ),
        ),
        const SizedBox(height: 8),
        Text("Kuota: $_totalQuotaTahunan hari"),
        Text("Sudah digunakan: $_usedQuotaTahunan hari"),
        Text("Sisa kuota: $sisaQuota hari"),
        const SizedBox(height: 20),
        // ----- Tanggal Cuti Tahunan -----
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tanggal Cuti Tahunan:",
                    style: _labelStyle,
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickFromDate,
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _selectedFromDate == null
                            ? "From Date"
                            : DateFormat('dd-MM-yyyy').format(_selectedFromDate!),
                        style: _inputStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickToDate,
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _selectedToDate == null
                            ? "To Date"
                            : DateFormat('dd-MM-yyyy').format(_selectedToDate!),
                        style: _inputStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ----- Cuti Alasan Penting Fields -----
  Widget _buildCutiAlasanPentingFields() {
    int requestedDays = _calculateNewCutiDays();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Cuti Alasan Penting:",
            style: _labelStyle,
          ),
        ),
        const SizedBox(height: 8),
        Text("Maksimum: $_maxCutiAlasan hari kerja"),
        Text("Diajukan: $requestedDays hari"),
        const SizedBox(height: 20),
        // ----- Tanggal Cuti Alasan Penting -----
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tanggal Cuti Alasan Penting:",
                    style: _labelStyle,
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickFromDate,
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _selectedFromDate == null
                            ? "From Date"
                            : DateFormat('dd-MM-yyyy').format(_selectedFromDate!),
                        style: _inputStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickToDate,
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _selectedToDate == null
                            ? "To Date"
                            : DateFormat('dd-MM-yyyy').format(_selectedToDate!),
                        style: _inputStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ----- Izin Fields -----
  Widget _buildIzinFields() {
    int currentIzin = _calculateIzinMendadak();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Izin:",
            style: _labelStyle,
          ),
        ),
        const SizedBox(height: 8),
        Text("Maksimum pengajuan mendadak: $_maxIzinMendadak kali"),
        const SizedBox(height: 20),
        // ----- Tanggal Izin -----
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tanggal Izin:",
                    style: _labelStyle,
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickFromDate,
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _selectedFromDate == null
                            ? "From Date"
                            : DateFormat('dd-MM-yyyy').format(_selectedFromDate!),
                        style: _inputStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickToDate,
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _selectedToDate == null
                            ? "To Date"
                            : DateFormat('dd-MM-yyyy').format(_selectedToDate!),
                        style: _inputStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ----- Izin Sakit Fields -----
  Widget _buildIzinSakitFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Izin Sakit:",
            style: _labelStyle,
          ),
        ),
        const SizedBox(height: 8),
        // ----- Bukti Upload -----
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                _pickFile("Izin Sakit");
              },
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload Bukti"),
            ),
            const SizedBox(width: 10),
            Text(
              _buktiIzinSakit != null
                  ? "Berkas Terpilih: ${_buktiIzinSakit!.name}"
                  : "Tidak ada berkas terpilih",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // ----- Alamat Selama Izin -----
        TextFormField(
          initialValue: _alamatIzinSakit,
          onChanged: (val) {
            _alamatIzinSakit = val;
          },
          decoration: const InputDecoration(
            labelText: "Alamat selama izin sakit",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        // ----- Tanggal Izin -----
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tanggal Izin Sakit:",
                    style: _labelStyle,
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickFromDate,
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _selectedFromDate == null
                            ? "From Date"
                            : DateFormat('dd-MM-yyyy').format(_selectedFromDate!),
                        style: _inputStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickToDate,
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _selectedToDate == null
                            ? "To Date"
                            : DateFormat('dd-MM-yyyy').format(_selectedToDate!),
                        style: _inputStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // ----- Deskripsi Singkat -----
        TextFormField(
          initialValue: _deskripsi,
          onChanged: (val) {
            _deskripsi = val;
          },
          decoration: const InputDecoration(
            labelText: "Deskripsi Singkat",
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ----- Izin Ibadah Fields -----
  Widget _buildIzinIbadahFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Izin Ibadah:",
            style: _labelStyle,
          ),
        ),
        const SizedBox(height: 8),
        // ----- Bukti Upload -----
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                _pickFile("Izin Ibadah");
              },
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload Bukti"),
            ),
            const SizedBox(width: 10),
            Text(
              _buktiIzinIbadah != null
                  ? "Berkas Terpilih: ${_buktiIzinIbadah!.name}"
                  : "Tidak ada berkas terpilih",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // ----- Alamat Selama Izin -----
        TextFormField(
          initialValue: _alamatIzinIbadah,
          onChanged: (val) {
            _alamatIzinIbadah = val;
          },
          decoration: const InputDecoration(
            labelText: "Alamat selama izin ibadah",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        // ----- Tanggal Izin -----
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tanggal Izin Ibadah:",
                    style: _labelStyle,
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickFromDate,
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _selectedFromDate == null
                            ? "From Date"
                            : DateFormat('dd-MM-yyyy').format(_selectedFromDate!),
                        style: _inputStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickToDate,
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _selectedToDate == null
                            ? "To Date"
                            : DateFormat('dd-MM-yyyy').format(_selectedToDate!),
                        style: _inputStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // ----- Catatan Singkat -----
        TextFormField(
          initialValue: _deskripsi,
          onChanged: (val) {
            _deskripsi = val;
          },
          decoration: const InputDecoration(
            labelText: "Catatan Singkat",
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

}

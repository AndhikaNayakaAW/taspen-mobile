// lib/screens/create_paidleave_cuti_form.dart

import 'package:flutter/material.dart';
import '../widgets/custom_bottom_app_bar.dart'; // Import the CustomBottomAppBar
import 'package:intl/intl.dart'; // Import intl for date formatting
import 'package:file_picker/file_picker.dart'; // Import file picker package
import 'package:uuid/uuid.dart'; // Import UUID package for unique IDs

class CreatePaidLeaveCutiForm extends StatefulWidget {
  /// The entire paidLeaves list to add or update entries
  final List<Map<String, dynamic>> paidLeaves;

  /// Optional parameters for editing existing entries
  final Map<String, dynamic>? existingLeave;
  final int? leaveIndex;

  const CreatePaidLeaveCutiForm({
    Key? key,
    required this.paidLeaves,
    this.existingLeave,
    this.leaveIndex,
  }) : super(key: key);

  @override
  _CreatePaidLeaveCutiFormState createState() =>
      _CreatePaidLeaveCutiFormState();
}

/// Parses a date string in 'dd MMMM yyyy' format to a DateTime object
DateTime _parseDate(String dateString) {
  return DateFormat('dd MMMM yyyy').parse(dateString);
}

class _CreatePaidLeaveCutiFormState extends State<CreatePaidLeaveCutiForm> {
  // Initialize UUID generator
  final Uuid _uuid = Uuid();

  // ----- DUMMY DATA (for approvers) -----
  final List<Map<String, String>> _approverList = [
    {"id": "60001", "name": "John Doe (CEO)"},
    {"id": "60002", "name": "Jane Smith (CFO)"},
    {"id": "60003", "name": "Robert Brown (COO)"},
  ];

  // ----- FORM FIELDS -----
  String _selectedLeaveType = "Cuti Tahunan"; // Default leave type

  // ----- Cuti Tahunan -----
  final int _totalQuotaTahunan = 12;
  int _usedQuotaTahunan = 0; // To be calculated based on existing data

  // ----- Cuti Alasan Penting -----
  final int _maxCutiAlasan = 12;

  // ----- Izin -----
  final int _maxIzinMendadak = 5;

  // ----- Izin Sakit -----
  PlatformFile? _buktiIzinSakit; // Requires file_picker package
  String _alamatIzinSakit = "";
  String _deskripsiIzinSakit = "";

  // ----- Izin Ibadah -----
  PlatformFile? _buktiIzinIbadah; // Requires file_picker package
  String _alamatIzinIbadah = "";
  String _deskripsiIzinIbadah = "";

  // ----- Common Fields -----
  DateTime? _selectedFromDate;
  DateTime? _selectedToDate;
  String _deskripsiCommon = "";

  // ----- Approvers -----
  List<String> _selectedApproverIds = [];

  // ----- Status -----
  String _status = "Draft";

  // ----- Unique ID -----
  String _uniqueId = ""; // Ensured to always be a non-null String

  // Consistent TextStyle
  final TextStyle _labelStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  final TextStyle _inputStyle = const TextStyle(
    fontSize: 16,
  );

  // ----- TextEditingControllers -----
  final TextEditingController _deskripsiCommonController =
      TextEditingController();
  final TextEditingController _alamatIzinSakitController =
      TextEditingController();
  final TextEditingController _deskripsiIzinSakitController =
      TextEditingController();
  final TextEditingController _alamatIzinIbadahController =
      TextEditingController();
  final TextEditingController _deskripsiIzinIbadahController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  /// Helper function to normalize 'jenisCuti' values to match DropdownMenuItem values
  String _normalizeJenisCuti(String value) {
    switch (value.toLowerCase()) {
      case "cuti tahunan":
        return "Cuti Tahunan";
      case "cuti alasan penting":
        return "Cuti Alasan Penting";
      case "izin":
        return "Izin";
      case "izin sakit":
        return "Izin Sakit";
      case "izin ibadah":
        return "Izin Ibadah";
      default:
        return "Cuti Tahunan"; // default value
    }
  }

  /// Initialize form fields based on whether it's creating or editing
  void _initializeForm() {
    if (widget.existingLeave != null && widget.leaveIndex != null) {
      // Editing existing leave
      final leave = widget.existingLeave!;
      _selectedLeaveType =
          _normalizeJenisCuti(leave["jenisCuti"] ?? "Cuti Tahunan");
      _selectedFromDate =
          (leave["fromDate"] != null && leave["fromDate"].toString().isNotEmpty)
              ? _parseDate(leave["fromDate"])
              : null;
      _selectedToDate =
          (leave["toDate"] != null && leave["toDate"].toString().isNotEmpty)
              ? _parseDate(leave["toDate"])
              : null;
      _deskripsiCommon = leave["deskripsi"] ?? "";
      _selectedApproverIds =
          List<String>.from(leave["approverIds"] ?? <String>[]);
      _status = leave["status"] ?? "Draft";
      _alamatIzinSakit = leave["alamatIzinSakit"] ?? "";
      _deskripsiIzinSakit = leave["deskripsiIzinSakit"] ?? "";
      _alamatIzinIbadah = leave["alamatIzinIbadah"] ?? "";
      _deskripsiIzinIbadah = leave["deskripsiIzinIbadah"] ?? "";
      _buktiIzinSakit = (leave["buktiIzinSakit"] != null &&
              leave["buktiIzinSakit"].toString().isNotEmpty)
          ? PlatformFile(
              name: leave["buktiIzinSakit"],
              size: 0,
              bytes: null,
            )
          : null;
      _buktiIzinIbadah = (leave["buktiIzinIbadah"] != null &&
              leave["buktiIzinIbadah"].toString().isNotEmpty)
          ? PlatformFile(
              name: leave["buktiIzinIbadah"],
              size: 0,
              bytes: null,
            )
          : null;

      _deskripsiCommonController.text = _deskripsiCommon;
      _alamatIzinSakitController.text = _alamatIzinSakit;
      _deskripsiIzinSakitController.text = _deskripsiIzinSakit;
      _alamatIzinIbadahController.text = _alamatIzinIbadah;
      _deskripsiIzinIbadahController.text = _deskripsiIzinIbadah;

      // Preserve the unique ID if editing
      _uniqueId = leave["id"] ?? _uuid.v4();
    } else {
      // Creating new leave
      _selectedLeaveType = "Cuti Tahunan";
      _status = "Draft";
      _selectedApproverIds = [];
      _deskripsiCommonController.text = "";
      _alamatIzinSakitController.text = "";
      _deskripsiIzinSakitController.text = "";
      _alamatIzinIbadahController.text = "";
      _deskripsiIzinIbadahController.text = "";

      // Generate a unique ID for the new entry
      _uniqueId = _uuid.v4();
    }

    // Calculate used Cuti Tahunan based on existing data
    _usedQuotaTahunan = _calculateUsedCutiTahunan();
  }

  @override
  void dispose() {
    // Dispose controllers
    _deskripsiCommonController.dispose();
    _alamatIzinSakitController.dispose();
    _deskripsiIzinSakitController.dispose();
    _alamatIzinIbadahController.dispose();
    _deskripsiIzinIbadahController.dispose();
    super.dispose();
  }

  // ========== PICKERS ==========
  Future<void> _pickFromDate() async {
    final now = DateTime.now();
    final initialDate = _selectedFromDate ?? now;
    final result = await showDatePicker(
      context: context,
      initialDate: initialDate,
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
    final initialDate = _selectedToDate ?? (_selectedFromDate ?? now);
    final firstDate = _selectedFromDate ?? DateTime(now.year - 1);
    final result = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
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
      if (file.size > 2 * 1024 * 1024) {
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
      _deskripsiCommon = "";
      _deskripsiIzinSakit = "";
      _deskripsiIzinIbadah = "";
      _alamatIzinSakit = "";
      _alamatIzinIbadah = "";
      _buktiIzinSakit = null;
      _buktiIzinIbadah = null;

      // Clear controllers
      _deskripsiCommonController.clear();
      _alamatIzinSakitController.clear();
      _deskripsiIzinSakitController.clear();
      _alamatIzinIbadahController.clear();
      _deskripsiIzinIbadahController.clear();

      // Reset approvers
      _selectedApproverIds = [];

      // Reset status
      _status = "Draft";

      // Recalculate quotas
      _usedQuotaTahunan = _calculateUsedCutiTahunan();
    });
  }

  /// Save as Draft or Update
  void _saveForm() {
    // Validate form before saving
    if (_validateForm(isSaving: true)) {
      final leaveData = _collectFormData(isSending: false);

      if (widget.existingLeave != null && widget.leaveIndex != null) {
        // Update existing leave
        widget.paidLeaves[widget.leaveIndex!] = leaveData;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Paid Leave Form Updated! (Draft)")),
        );
      } else {
        // Add new leave
        widget.paidLeaves.add(leaveData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Paid Leave Form Saved! (Draft)")),
        );
      }

      // **Modified Navigation: Pop twice to return to main screen**
      Navigator.pop(context); // Pop form screen
      Navigator.pop(context, leaveData); // Pop previous screen (e.g., detail screen) and pass data
    }
  }

  /// Send to Approver -> status=Waiting or Update to Waiting
  void _sendToApprover() {
    // Validate form before sending
    if (_validateForm(isSaving: false)) {
      final leaveData = _collectFormData(isSending: true);

      if (widget.existingLeave != null && widget.leaveIndex != null) {
        // Update existing leave
        widget.paidLeaves[widget.leaveIndex!] = leaveData;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("Paid Leave Form Sent to Approver! (Waiting)")),
        );
      } else {
        // Add new leave
        widget.paidLeaves.add(leaveData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("Paid Leave Form Sent to Approver! (Waiting)")),
        );
      }

      // **Modified Navigation: Pop twice to return to main screen**
      Navigator.pop(context); // Pop form screen
      Navigator.pop(context, leaveData); // Pop previous screen (e.g., detail screen) and pass data
    }
  }

  /// Collects form data into a Map
  Map<String, dynamic> _collectFormData({required bool isSending}) {
    return {
      "id": _uniqueId, // Already ensured to be a non-null String
      "createdBy": "andhika.nayaka", // Replace with actual user data
      "jenisCuti": _selectedLeaveType,
      "fromDate": _selectedFromDate != null
          ? DateFormat('dd MMMM yyyy').format(_selectedFromDate!)
          : "",
      "toDate": _selectedToDate != null
          ? DateFormat('dd MMMM yyyy').format(_selectedToDate!)
          : "",
      "deskripsi": _selectedLeaveType == "Izin Sakit" ||
              _selectedLeaveType == "Izin Ibadah"
          ? (_selectedLeaveType == "Izin Sakit"
              ? _deskripsiIzinSakit
              : _deskripsiIzinIbadah)
          : _deskripsiCommon,
      "approverIds": _selectedApproverIds,
      "status": isSending ? "Waiting" : _status,
      // Additional fields like uploaded files can be added here
      "buktiIzinSakit":
          _buktiIzinSakit != null ? _buktiIzinSakit!.name : "",
      "buktiIzinIbadah":
          _buktiIzinIbadah != null ? _buktiIzinIbadah!.name : "",
      "alamatIzinSakit": _alamatIzinSakit,
      "alamatIzinIbadah": _alamatIzinIbadah,
      // Specific descriptions
      "deskripsiIzinSakit": _deskripsiIzinSakit,
      "deskripsiIzinIbadah": _deskripsiIzinIbadah,
      // Submission datetime
      "datetime": widget.existingLeave != null
          ? widget.existingLeave!["datetime"] ??
              DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())
          : DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    };
  }

  /// Validate the form fields
  bool _validateForm({required bool isSaving}) {
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

    if (_selectedLeaveType != "Izin Sakit" &&
        _selectedLeaveType != "Izin Ibadah") {
      if (_deskripsiCommonController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please provide a description.")),
        );
        return false;
      }
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
        if (_calculateUsedCutiTahunan() + _calculateNewCutiDays() >
            _totalQuotaTahunan) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Exceeded Cuti Tahunan quota.")),
          );
          return false;
        }
        break;
      case "Cuti Alasan Penting":
        if (_calculateNewCutiDays() > _maxCutiAlasan) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text("Maximum 12 days for Cuti Alasan Penting.")),
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
        if (_alamatIzinSakitController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text("Please provide alamat selama izin sakit.")),
          );
          return false;
        }
        if (_deskripsiIzinSakitController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please provide deskripsi singkat.")),
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
        if (_alamatIzinIbadahController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Please provide alamat selama izin ibadah.")),
          );
          return false;
        }
        // Check if already taken once
        if (_hasTakenIzinIbadah()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    "Izin Ibadah can only be taken once during employment.")),
          );
          return false;
        }
        if (_deskripsiIzinIbadahController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please provide catatan singkat.")),
          );
          return false;
        }
        break;
      default:
        break;
    }

    // Additional validations can be added here

    return true;
  }

  // ----- QUOTA AND COUNTING METHODS -----
  int _calculateUsedCutiTahunan() {
    // Calculate used Cuti Tahunan based on existing data
    // This assumes 'fromDate' and 'toDate' are in 'dd MMMM yyyy' format
    int used = 0;
    for (var leave in widget.paidLeaves) {
      if (leave["jenisCuti"] == "Cuti Tahunan" &&
          (leave["status"].toString().toLowerCase() == "approved" ||
              leave["status"].toString().toLowerCase() == "waiting")) {
        if (leave["fromDate"] != null &&
            leave["fromDate"].toString().isNotEmpty &&
            leave["toDate"] != null &&
            leave["toDate"].toString().isNotEmpty) {
          try {
            DateTime from = _parseDate(leave["fromDate"]);
            DateTime to = _parseDate(leave["toDate"]);
            used += to.difference(from).inDays + 1;
          } catch (e) {
            // Handle parsing errors if any
            continue;
          }
        }
      }
    }
    return used;
  }

  int _calculateNewCutiDays() {
    if (_selectedFromDate != null && _selectedToDate != null) {
      return _selectedToDate!.difference(_selectedFromDate!).inDays + 1;
    }
    return 0;
  }

  int _calculateIzinMendadak() {
    // Calculate the number of mendadak izin based on previous data
    // Assuming 'Izin' type with status 'waiting' or similar indicates ongoing izin
    return widget.paidLeaves
        .where((leave) =>
            leave["jenisCuti"] == "Izin" &&
            (leave["status"].toString().toLowerCase() == "waiting" ||
                leave["status"].toString().toLowerCase() ==
                    "wait approve approval"))
        .length;
  }

  bool _hasTakenIzinIbadah() {
    // Check if Izin Ibadah has been taken before
    return widget.paidLeaves.any((leave) =>
        leave["jenisCuti"] == "Izin Ibadah" &&
        leave["status"].toString().toLowerCase() == "approved");
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
    int sisaQuota = _totalQuotaTahunan - _usedQuotaTahunan;
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
                  const SizedBox(height: 24), // To align with the from date label
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
                  const SizedBox(height: 24), // To align with the from date label
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
                  const SizedBox(height: 24), // To align with the from date label
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
            Expanded(
              child: Text(
                _buktiIzinSakit != null
                    ? "Berkas Terpilih: ${_buktiIzinSakit!.name}"
                    : "Tidak ada berkas terpilih",
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // ----- Alamat Selama Izin -----
        TextFormField(
          controller: _alamatIzinSakitController,
          onChanged: (val) {
            _alamatIzinSakit = val.trim();
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
                  const SizedBox(height: 24), // To align with the from date label
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
          controller: _deskripsiIzinSakitController,
          onChanged: (val) {
            _deskripsiIzinSakit = val.trim();
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
            Expanded(
              child: Text(
                _buktiIzinIbadah != null
                    ? "Berkas Terpilih: ${_buktiIzinIbadah!.name}"
                    : "Tidak ada berkas terpilih",
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // ----- Alamat Selama Izin -----
        TextFormField(
          controller: _alamatIzinIbadahController,
          onChanged: (val) {
            _alamatIzinIbadah = val.trim();
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
                  const SizedBox(height: 24), // To align with the from date label
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
          controller: _deskripsiIzinIbadahController,
          onChanged: (val) {
            _deskripsiIzinIbadah = val.trim();
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

  // ========== APPROVER SECTION ===========
  Widget _buildApproverSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    const SnackBar(
                        content: Text("Maximum 3 approvers allowed.")),
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
            final approver =
                _approverList.firstWhere((item) => item["id"] == id);
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
      ],
    );
  }

  // ========== COMMON DESKRIPSI SECTION ===========
  Widget _buildDeskripsiSection() {
    String labelText;
    if (_selectedLeaveType == "Izin Sakit") {
      labelText = "Deskripsi Izin Sakit";
    } else if (_selectedLeaveType == "Izin Ibadah") {
      labelText = "Catatan Singkat Izin Ibadah";
    } else {
      labelText = "Deskripsi:";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            labelText,
            style: _labelStyle,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _selectedLeaveType == "Izin Sakit"
              ? _deskripsiIzinSakitController
              : _selectedLeaveType == "Izin Ibadah"
                  ? _deskripsiIzinIbadahController
                  : _deskripsiCommonController,
          onChanged: (val) {
            if (_selectedLeaveType == "Izin Sakit") {
              _deskripsiIzinSakit = val.trim();
            } else if (_selectedLeaveType == "Izin Ibadah") {
              _deskripsiIzinIbadah = val.trim();
            } else {
              _deskripsiCommon = val.trim();
            }
          },
          decoration: InputDecoration(
            labelText: labelText,
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  // ========== BUTTONS SECTION ===========
  Widget _buildButtonsSection() {
    return Row(
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
    );
  }

  // ========== FORM BUILD ===========
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingLeave != null
            ? "Edit Paid Leave/Cuti Form"
            : "Create Paid Leave/Cuti Form"),
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
            _buildApproverSection(),
            const SizedBox(height: 20),

            // =========== COMMON DESKRIPSI SECTION ===========
            _buildDeskripsiSection(),
            const SizedBox(height: 20),

            // =========== BUTTONS ===========
            _buildButtonsSection(),
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
      _deskripsiCommon = "";
      _deskripsiIzinSakit = "";
      _deskripsiIzinIbadah = "";
      _alamatIzinSakit = "";
      _alamatIzinIbadah = "";
      _buktiIzinSakit = null;
      _buktiIzinIbadah = null;

      // Clear controllers
      _deskripsiCommonController.clear();
      _alamatIzinSakitController.clear();
      _deskripsiIzinSakitController.clear();
      _alamatIzinIbadahController.clear();
      _deskripsiIzinIbadahController.clear();
    });
  }
}
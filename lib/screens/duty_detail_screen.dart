// lib/screens/duty_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:mobileapp/model/duty.dart';
import '../widgets/custom_bottom_app_bar.dart'; // Import the CustomBottomAppBar
import 'create_duty_form.dart'; // We'll use this for "edit" button if Draft or Returned
import 'main_screen.dart';
import 'paidleave_cuti_screen.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data'; // Import for Uint8List

class DutyDetailScreen extends StatefulWidget {
  final Duty duty;
  final List<Duty> allDuties;

  const DutyDetailScreen({
    super.key,
    required this.duty,
    required this.allDuties,
  });

  @override
  State<DutyDetailScreen> createState() => _DutyDetailScreenState();
}

class _DutyDetailScreenState extends State<DutyDetailScreen> {
  late Duty _currentDuty; // Mutable copy of a duty

  // Updated to dynamically set the created and modified times
  late String _createdAt;
  late String _modifiedAt;
  late String _status;
  late String _rejectionReason;

  // Flags to determine the status
  bool isDraft = false;
  bool isWaiting = false;
  bool isApproved = false;
  bool isReturned = false;
  bool isRejected = false;

  @override
  void initState() {
    super.initState();
    // Initialize _currentDuty with the duty passed to the widget
    _currentDuty = widget.duty;

    // Initialize createdAt and modifiedAt based on existing data or current time
    _createdAt =
        DateFormat('MMM dd, yyyy hh:mm a').format(_currentDuty.createdAt);
    _modifiedAt =
        DateFormat('MMM dd, yyyy hh:mm a').format(_currentDuty.updatedAt);

    _status = _currentDuty.status.toLowerCase();

    // Determine the status flags
    isDraft = _status == "draft";
    isWaiting = _status == "waiting";
    isApproved = _status == "approved";
    isReturned = _status == "returned";
    isRejected = _status == "rejected";

    _rejectionReason = _currentDuty.rejectionReason ?? "";
  }

  // ========== ACTION HANDLERS ==========

  void _onEdit() async {
    // Navigate to CreateDutyForm with the duty to edit
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateDutyForm(
          duties: widget.allDuties,
          dutyToEdit: _currentDuty, // Pass the duty to edit
        ),
      ),
    );

    if (result != null) {
      if (result == 'sent' || result == 'updated') {
        // After sending or updating, navigate back to Duty List Screen
        Navigator.pop(context); // Pop DutyDetailScreen to go back to DutySPTScreen
      } else if (result == 'saved') {
        // After saving/updating as draft, refresh the detail screen
        setState(() {
          // Refresh the createdAt and modifiedAt in case they were updated
          _createdAt =
              DateFormat('MMM dd, yyyy hh:mm a').format(_currentDuty.createdAt);
          _modifiedAt =
              DateFormat('MMM dd, yyyy hh:mm a').format(_currentDuty.updatedAt);
          _status = _currentDuty.status.toLowerCase();
          isDraft = _status == "draft";
          isWaiting = _status == "waiting";
          isApproved = _status == "approved";
          isReturned = _status == "returned";
          isRejected = _status == "rejected";
          _rejectionReason = _currentDuty.rejectionReason ?? "";
        });
      }
    }
  }

  void _onSend() {
    // Update the duty status to "Waiting"
    Duty updatedDuty = _currentDuty.copyWith(
      status: "Waiting",
      updatedAt: DateTime.now(),
      rejectionReason: null, // Clear rejection reason if any
    );

    // Replace the old duty with the updated one in allDuties
    int index =
        widget.allDuties.indexWhere((duty) => duty.id == _currentDuty.id);
    if (index != -1) {
      setState(() {
        widget.allDuties[index] = updatedDuty;
        _currentDuty = updatedDuty; // Update the mutable duty reference
        // Update state variables
        _modifiedAt =
            DateFormat('MMM dd, yyyy hh:mm a').format(_currentDuty.updatedAt);
        _status = _currentDuty.status.toLowerCase();
        isDraft = _status == "draft";
        isWaiting = _status == "waiting";
        isApproved = _status == "approved";
        isReturned = _status == "returned";
        isRejected = _status == "rejected";
        _rejectionReason = _currentDuty.rejectionReason ?? "";
      });
    }

    // Show confirmation SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Duty Sent! Status=Waiting")),
    );

    // Navigate back to DutySPTScreen
    Navigator.pop(context);
  }

  void _onDelete() {
    // Confirm deletion with the user
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Duty"),
          content: const Text("Are you sure you want to delete this duty?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Perform deletion
                setState(() {
                  widget.allDuties
                      .removeWhere((duty) => duty.id == _currentDuty.id);
                });
                Navigator.of(context).pop(); // Dismiss dialog
                Navigator.pop(context); // Navigate back to DutySPTScreen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Duty Deleted!")),
                );
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onPrint() async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => await _generatePdf(format),
      );
    } catch (e) {
      // Handle any errors during PDF generation or printing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to generate PDF: $e")),
      );
    }
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    final duty = _currentDuty;
    final approverName = _getApproverName(duty.approverId);
    final createdBy = duty.createdBy ?? "Unknown";

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Duty Details',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Description: ${duty.description ?? "No Description"}',
                  style: pw.TextStyle(fontSize: 18),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Date: ${_formatDate(duty.dutyDate.toIso8601String())}',
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.Text(
                  'Time: ${_formatTime(duty.startTime)} - ${_formatTime(duty.endTime)}',
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Created:',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                    fontSize: 16,
                  ),
                ),
                pw.Text(
                  _createdAt,
                  style: pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  'Modified:',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                    fontSize: 16,
                  ),
                ),
                pw.Text(
                  _modifiedAt,
                  style: pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Created By:',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                pw.Text(
                  'Name: $createdBy',
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.Text(
                  'NIK: 4163 (dummy)',
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.Text(
                  'Position: Application Support Staff',
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Approver:',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                pw.Text(
                  'Name: $approverName',
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.Text(
                  'NIK: 3713',
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.Text(
                  'Position: Senior Programmer',
                  style: pw.TextStyle(fontSize: 16),
                ),
                if (isRejected) ...[
                  pw.SizedBox(height: 20),
                  pw.Divider(),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Rejection Reason:',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red700,
                      fontSize: 16,
                    ),
                  ),
                  pw.Text(
                    _rejectionReason.isNotEmpty
                        ? _rejectionReason
                        : "No reason provided.",
                    style: pw.TextStyle(
                      color: PdfColors.red,
                      fontStyle: pw.FontStyle.italic,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Duty Detail"),
        backgroundColor: Colors.teal,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            // Desktop with left sidebar
            return Row(
              children: [
                Container(
                  width: 250,
                  color: Colors.teal.shade50,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text("Edit Duty Form"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: _onEdit,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.home),
                        label: const Text("Home"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          // Navigate to Home Screen
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainScreen(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.airline_seat_flat),
                        label: const Text("Paid Leave (Cuti)"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          // Navigate to Paid Leave (Cuti) Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PaidLeaveCutiScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: _buildDetailContent(),
                  ),
                ),
              ],
            );
          } else {
            // Mobile
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildDetailContent(isMobile: true),
            );
          }
        },
      ),
      bottomNavigationBar: const CustomBottomAppBar(),
    );
  }

  Widget _buildDetailContent({bool isMobile = false}) {
    final duty = _currentDuty;
    final description = duty.description ?? "No Description";
    final status = duty.status;
    final dateStr = duty.dutyDate.toIso8601String();
    final startTimeStr = duty.startTime;
    final endTimeStr = duty.endTime;

    // If createdBy or user info is not set, let's default to "Unknown"
    final createdBy = duty.createdBy ?? "Unknown";
    final approverName = _getApproverName(duty.approverId); // Fetch dynamically based on approverId

    // We'll parse status and format dates
    final displayedDate = _formatDate(duty.dutyDate.toIso8601String());
    final displayedStart = _formatTime(duty.startTime);
    final displayedEnd = _formatTime(duty.endTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Duty Details",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description and Timestamps
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 500) {
                      // Desktop-like horizontal layout
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  description,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Date: $displayedDate",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  "Time: $displayedStart - $displayedEnd",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 40),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Created:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _createdAt,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Modified:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _modifiedAt,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      // Mobile-like vertical layout
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Date: $displayedDate",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            "Time: $displayedStart - $displayedEnd",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Created:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _createdAt,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Modified:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _modifiedAt,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),

                // Created By Section
                Row(
                  children: const [
                    Icon(Icons.person, color: Colors.teal),
                    SizedBox(width: 8),
                    Text(
                      "Created By:",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Name: $createdBy",
                  style: const TextStyle(fontSize: 16),
                ),
                const Text(
                  "NIK: 4163 (dummy)",
                  style: TextStyle(fontSize: 16),
                ),
                const Text(
                  "Position: Application Support Staff",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),

                // Approver Section
                Row(
                  children: const [
                    Icon(Icons.approval, color: Colors.teal),
                    SizedBox(width: 8),
                    Text(
                      "Approver:",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Name: $approverName",
                  style: const TextStyle(fontSize: 16),
                ),
                const Text(
                  "NIK: 3713",
                  style: TextStyle(fontSize: 16),
                ),
                const Text(
                  "Position: Senior Programmer",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),

                // Action Buttons
                _buildActionButtons(status),
                // Display Rejection Reason if status is Rejected
                if (isRejected) _buildRejectionReason(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Fetch approver's name based on approverId
  String _getApproverName(String? approverId) {
    if (approverId == null || approverId.isEmpty) return "N/A";

    // Define the approver list here or fetch from a data source
    final List<Map<String, String>> _approverList = [
      {"id": "60001", "name": "John Doe (CEO)"},
      {"id": "60002", "name": "Jane Smith (CFO)"},
      {"id": "60003", "name": "Robert Brown (COO)"},
    ];

    final approver = _approverList.firstWhere(
      (element) => element["id"] == approverId,
      orElse: () => {"id": "", "name": "Unknown Approver"},
    );

    return approver["name"]!;
  }

  /// Build the bottom row of Action Buttons
  Widget _buildActionButtons(String status) {
    // Define colors based on status
    Color statusColor = Colors.grey;
    if (status.toLowerCase() == "approved")
      statusColor = Colors.green;
    else if (status.toLowerCase() == "waiting")
      statusColor = Colors.orange;
    else if (status.toLowerCase() == "returned")
      statusColor = Colors.blue;
    else if (status.toLowerCase() == "rejected") statusColor = Colors.red;

    // If it's a DRAFT -> We can Edit, Send, or Delete
    if (isDraft) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text("Edit"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: _onEdit,
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text("Send"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: _onSend,
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text("Delete"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: _onDelete,
          ),
        ],
      );
    }
    // If it's RETURNED -> We can Edit and Send, but not Delete
    else if (isReturned) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text("Edit"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: _onEdit,
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text("Send"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: _onSend,
          ),
        ],
      );
    }
    // If it's WAITING or APPROVED -> we can only Print
    else if (isWaiting || isApproved) {
      return Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.print),
          label: Text("Print (${capitalize(status)})"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            textStyle: const TextStyle(fontSize: 16),
          ),
          onPressed: _onPrint,
        ),
      );
    }
    // If it's REJECTED -> we can only Print and view Rejection Reason
    else if (isRejected) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.print),
            label: Text("Print (${capitalize(status)})"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: _onPrint,
          ),
          const SizedBox(height: 10),
          Text(
            "Rejection Reason:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _rejectionReason.isNotEmpty
                ? _rejectionReason
                : "No reason provided.",
            style: const TextStyle(
              color: Colors.red,
              fontStyle: FontStyle.italic,
              fontSize: 14,
            ),
          ),
        ],
      );
    }
    // Default case
    else {
      return Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.print),
          label: Text("Print (${capitalize(status)})"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            textStyle: const TextStyle(fontSize: 16),
          ),
          onPressed: _onPrint,
        ),
      );
    }
  }

  /// Build the Rejection Reason section
  Widget _buildRejectionReason() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Rejection Reason:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _rejectionReason.isNotEmpty
                ? _rejectionReason
                : "No reason provided.",
            style: const TextStyle(
              color: Colors.red,
              fontStyle: FontStyle.italic,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Capitalize the first letter of the status
  String capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1).toLowerCase() : s;

  /// Helper method to format time from "HH:mm:ss" to "hh:mm a"
  String _formatTime(String time) {
    try {
      // Assuming time is in "HH:mm:ss" format
      DateTime parsedTime = DateTime.parse("1970-01-01T$time");
      return DateFormat('hh:mm a').format(parsedTime);
    } catch (e) {
      return time;
    }
  }

  /// Helper method to format date from ISO string to "dd-MM-yyyy"
  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }
}

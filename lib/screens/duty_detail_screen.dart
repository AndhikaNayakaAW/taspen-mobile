// lib/screens/duty_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:mobileapp/dto/get_duty_detail.dart';
import 'package:mobileapp/dto/duty_detail_data.dart';
import 'package:mobileapp/dto/base_response.dart';
import 'package:mobileapp/model/duty.dart';
import 'package:mobileapp/model/user.dart';
import 'package:mobileapp/model/approval.dart';
import 'package:mobileapp/services/api_service_easy_taspen.dart';
import 'package:mobileapp/services/auth_service.dart';
import '../widgets/custom_bottom_app_bar.dart';
import 'create_duty_form.dart';
import 'main_screen.dart';
import 'paidleave_cuti_screen.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class DutyDetailScreen extends StatefulWidget {
  final int dutyId;

  const DutyDetailScreen({
    super.key,
    required this.dutyId,
  });

  @override
  State<DutyDetailScreen> createState() => _DutyDetailScreenState();
}

class _DutyDetailScreenState extends State<DutyDetailScreen> {
  late Future<DutyDetailData> _dutyDetailDataFuture;

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _dutyDetailDataFuture = fetchDutyDetailData(widget.dutyId);
  }

  Future<DutyDetailData> fetchDutyDetailData(int dutyId) async {
    try {
      // Fetch User Information
      User user = await _authService.loadUserInfo();

      // Fetch Duty Detail from API
      BaseResponse<GetDutyDetail> apiResponse =
          await _apiService.fetchDutyDetailById(dutyId, user.nik);

      // Check if the API call was successful and response is not null
      if (apiResponse.metadata.code == 200) {
        GetDutyDetail dutyDetail = apiResponse.response!;
        return DutyDetailData(user: user, dutyDetail: dutyDetail);
      } else {
        // Handle the case where the API call was not successful
        throw Exception(apiResponse.metadata.message);
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  // Action Handlers
  void _onEdit(Duty duty) async {
    // Navigate to CreateDutyForm with the duty to edit
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateDutyForm(
          dutyToEdit: duty,
        ),
      ),
    );

    if (result != null) {
      if (result == 'sent' || result == 'updated' || result == 'saved') {
        // After any action, refetch the duty details
        setState(() {
          _dutyDetailDataFuture = fetchDutyDetailData(widget.dutyId);
        });
      }
    }
  }

  void _onSend(Duty duty) async {
    // Implement the send functionality
    final String url =
        'http://easy-route-easy.apps.dev.taspen.co.id/api/no_token/duty/${duty.id}/send';

    try {
      final response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        // Successfully sent, refetch duty details
        setState(() {
          _dutyDetailDataFuture = fetchDutyDetailData(widget.dutyId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Duty Sent! Status=Waiting")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Failed to send duty. Status Code: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending duty: $e")),
      );
    }
  }

  void _onDelete(Duty duty) async {
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
              onPressed: () async {
                try {
                  final response = await _apiService.deleteDuty(duty.id);

                  if (response.metadata.code == 200) {
                    // Successfully deleted, navigate back
                    Navigator.of(context).pop(); // Dismiss dialog
                    Navigator.pop(context, 'deleted');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response.response.toString())),
                    );
                  } else {
                    Navigator.of(context).pop(); // Dismiss dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              "Failed to delete duty. Status Code: ${response.metadata.code}")),
                    );
                  }
                } catch (e) {
                  Navigator.of(context).pop(); // Dismiss dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error deleting duty: $e")),
                  );
                }
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

  void _onPrint(DutyDetailData dutyDetailData) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async =>
            await _generatePdf(format, dutyDetailData),
      );
    } catch (e) {
      // Handle any errors during PDF generation or printing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to generate PDF: $e")),
      );
    }
  }

  Future<Uint8List> _generatePdf(
      PdfPageFormat format, DutyDetailData dutyDetailData) async {
    final pdf = pw.Document();

    User user = dutyDetailData.user;
    GetDutyDetail dutyDetail = dutyDetailData.dutyDetail;
    Duty duty = dutyDetail.duty;
    Approval approval = dutyDetail.approval;
    String approverName = _getApproverName(approval.id);
    String createdBy = user.nama;
    String rejectionReason = approval.note ?? "";

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
                  _formatDateTime(duty.createdAt),
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
                  _formatDateTime(duty.updatedAt),
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
                  'NIK: ${approval.nik ?? "N/A"}',
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.Text(
                  'Position: Senior Programmer',
                  style: pw.TextStyle(fontSize: 16),
                ),
                if (duty.status.desc.toLowerCase() == "rejected") ...[
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
                    rejectionReason.isNotEmpty
                        ? rejectionReason
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

  /// Fetch approver's name based on approval.id
  String _getApproverName(int approverId) {
    // Define the approver list here or fetch from a data source
    final List<Map<String, String>> _approverList = [
      {"id": "60001", "name": "John Doe (CEO)"},
      {"id": "60002", "name": "Jane Smith (CFO)"},
      {"id": "60003", "name": "Robert Brown (COO)"},
    ];

    final approver = _approverList.firstWhere(
      (element) => element["id"] == approverId.toString(),
      orElse: () => {"id": "", "name": "Unknown Approver"},
    );

    return approver["name"]!;
  }

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

  /// Helper method to format DateTime to "MMM dd, yyyy hh:mm a"
  String _formatDateTime(DateTime dateTime) {
    try {
      return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
    } catch (e) {
      return dateTime.toIso8601String();
    }
  }

  /// Capitalize the first letter of the status
  String capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1).toLowerCase() : s;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Duty Detail"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<DutyDetailData>(
        future: _dutyDetailDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while fetching data
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show error message if any
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (snapshot.hasData) {
            // Once data is fetched, display it
            final dutyDetailData = snapshot.data!;
            final User user = dutyDetailData.user;
            final GetDutyDetail dutyDetail = dutyDetailData.dutyDetail;
            final Duty duty = dutyDetail.duty;
            final Approval approval = dutyDetail.approval;

            return LayoutBuilder(
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
                              onPressed: () => _onEdit(duty),
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
                          child: _buildDetailContent(
                            user: user,
                            duty: duty,
                            approval: approval,
                            isMobile: false,
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Mobile
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _buildDetailContent(
                      user: user,
                      duty: duty,
                      approval: approval,
                      isMobile: true,
                    ),
                  );
                }
              },
            );
          } else {
            // Handle unexpected cases
            return const Center(child: Text("No data available."));
          }
        },
      ),
      bottomNavigationBar: const CustomBottomAppBar(),
    );
  }

  Widget _buildDetailContent({
    required User user,
    required Duty duty,
    required Approval approval,
    bool isMobile = false,
  }) {
    final String description = duty.description ?? "No Description";
    final String status = duty.status.desc;
    final String dateStr = duty.dutyDate.toIso8601String();
    final String startTimeStr = duty.startTime;
    final String endTimeStr = duty.endTime;

    final String createdBy = user.nama;
    final String approverName = _getApproverName(approval.id);

    final String displayedDate = _formatDate(duty.dutyDate.toIso8601String());
    final String displayedStart = _formatTime(duty.startTime);
    final String displayedEnd = _formatTime(duty.endTime);
    final String rejectionReason = approval.note ?? "";

    // Determine status flags
    bool isDraft = status.toLowerCase() == "draft";
    bool isWaiting = status.toLowerCase() == "waiting";
    bool isApproved = status.toLowerCase() == "approved";
    bool isReturned = status.toLowerCase() == "returned";
    bool isRejected = status.toLowerCase() == "rejected";

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
                                _formatDateTime(duty.createdAt),
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
                                _formatDateTime(duty.updatedAt),
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
                            _formatDateTime(duty.createdAt),
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
                            _formatDateTime(duty.updatedAt),
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
                Text(
                  "NIK: ${approval.nik ?? "N/A"}",
                  style: const TextStyle(fontSize: 16),
                ),
                const Text(
                  "Position: Senior Programmer",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),

                // Action Buttons
                _buildActionButtons(
                  duty,
                  isDraft: isDraft,
                  isReturned: isReturned,
                  isWaiting: isWaiting,
                  isApproved: isApproved,
                  isRejected: isRejected,
                  rejectionReason: rejectionReason,
                  dutyDetailData: DutyDetailData(
                      user: user,
                      dutyDetail: GetDutyDetail(
                          duty: duty,
                          approval: approval,
                          transport: {})), // Pass combined data
                ),
                // Display Rejection Reason if status is Rejected
                if (isRejected)
                  _buildRejectionReason(
                      rejectionReason: rejectionReason, isMobile: isMobile),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build the Action Buttons based on duty status
  Widget _buildActionButtons(
    Duty duty, {
    required bool isDraft,
    required bool isReturned,
    required bool isWaiting,
    required bool isApproved,
    required bool isRejected,
    required String rejectionReason,
    required DutyDetailData dutyDetailData,
  }) {
    String status = duty.status.desc;
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
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: () => _onEdit(duty),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text("Send"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: () => _onSend(duty),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text("Delete"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: () => _onDelete(duty),
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
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: () => _onEdit(duty),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text("Send"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: () => _onSend(duty),
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
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            textStyle: const TextStyle(fontSize: 16),
          ),
          onPressed: () {
            _onPrint(dutyDetailData);
          },
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
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: () => _onPrint(dutyDetailData),
          ),
          const SizedBox(height: 10),
          // Rejection Reason is already handled separately
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
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            textStyle: const TextStyle(fontSize: 16),
          ),
          onPressed: () => _onPrint(dutyDetailData),
        ),
      );
    }
  }

  /// Build the Rejection Reason section
  Widget _buildRejectionReason({
    required String rejectionReason,
    bool isMobile = false,
  }) {
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
            rejectionReason.isNotEmpty
                ? rejectionReason
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
}

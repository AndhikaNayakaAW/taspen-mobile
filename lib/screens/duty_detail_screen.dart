// lib/screens/duty_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:mobileapp/model/duty.dart';
import '../widgets/custom_bottom_app_bar.dart'; // Import the CustomBottomAppBar
import 'create_duty_form.dart'; // We'll use this for "edit" button if Draft or Returned
import 'main_screen.dart';
import 'paidleave_cuti_screen.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting

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
  late Duty _currentDuty; // Mutable copy of duty

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
        DateFormat('MMM dd yyyy hh:mm a').format(_currentDuty.createdAt);
    _modifiedAt =
        DateFormat('MMM dd yyyy hh:mm a').format(_currentDuty.updatedAt);

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
        Navigator.pop(
            context); // Pop DutyDetailScreen to go back to DutySPTScreen
      } else if (result == 'saved') {
        // After saving/updating as draft, refresh the detail screen
        setState(() {
          // Refresh the createdAt and modifiedAt in case they were updated
          _createdAt =
              DateFormat('MMM dd yyyy hh:mm a').format(_currentDuty.createdAt);
          _modifiedAt =
              DateFormat('MMM dd yyyy hh:mm a').format(_currentDuty.updatedAt);
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
            DateFormat('MMM dd yyyy hh:mm a').format(_currentDuty.updatedAt);
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

  void _onPrint() {
    final status = _currentDuty.status;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Print Duty (status = $status) - dummy!")),
    );
    // Implement actual print functionality here if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Duty Detail"),
        backgroundColor: Colors.teal,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            // Desktop with left sidebar
            return Row(
              children: [
                Container(
                  width: 250,
                  color: const Color(0xFFf8f9fa),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                        ),
                        onPressed: _onEdit,
                        child: const Text("Edit Duty Form"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
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
                        child: const Text("Home"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
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
                        child: const Text("Paid Leave (Cuti)"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildDetailContent(),
                  ),
                ),
              ],
            );
          } else {
            // Mobile
            return SingleChildScrollView(
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
    final description = duty.description ?? "No Title";
    final status = duty.status;
    final dateStr = duty.dutyDate.toIso8601String();
    final startTimeStr = duty.startTime;
    final endTimeStr = duty.endTime;

    // If createdBy or user info is not set, let's default to "Unknown"
    final createdBy = duty.createdBy;
    final approverName = _getApproverName(
        duty.approverId); // Fetch dynamically based on approverId

    // We'll parse status and format dates
    final displayedDate = _formatDate(duty.dutyDate.toIso8601String());
    final displayedStart = _formatTime(duty.startTime);
    final displayedEnd = _formatTime(duty.endTime);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Detail Duty",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Timestamps
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 300) {
                      // Desktop-like horizontal layout
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Description
                          Expanded(
                            child: Text(
                              description,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Created and Modified
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Created: $_createdAt",
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                "Modified: $_modifiedAt",
                                style: const TextStyle(fontSize: 12),
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
                          const SizedBox(height: 8),
                          Text(
                            "Created: $_createdAt",
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            "Modified: $_modifiedAt",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
                Text("Date: $displayedDate"),
                Text("Time: $displayedStart - $displayedEnd"),
                const SizedBox(height: 10),
                const Divider(),

                // Created By
                const Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 4),
                    Text(
                      "User Created By:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Nama : $createdBy"),
                const Text("NIK : 4163 (dummy)"),
                const Text("Jabatan : APPLICATION SUPPORT STAFF"),
                const Divider(),

                // Approver
                const Row(
                  children: [
                    Icon(Icons.approval),
                    SizedBox(width: 4),
                    Text(
                      "Approver",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Nama : $approverName"),
                const Text("NIK : 3713"),
                const Text("Jabatan : SENIOR PROGRAMMER"),

                const SizedBox(height: 20),
                _buildActionButtons(status),
                // Display Rejection Reason if status is Rejected
                if (isRejected) _buildRejectionReason(),
              ],
            ),
          ),
        ],
      ),
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
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text("Edit"),
            onPressed: _onEdit,
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text("Send"),
            onPressed: _onSend,
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text("Delete"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: _onDelete,
          ),
        ],
      );
    }
    // If it's RETURNED -> We can Edit and Send, but not Delete
    else if (isReturned) {
      return Row(
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text("Edit"),
            onPressed: _onEdit,
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text("Send"),
            onPressed: _onSend,
          ),
        ],
      );
    }
    // If it's WAITING or APPROVED -> we can only Print
    else if (isWaiting || isApproved) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.print),
        label: Text("Print (${capitalize(status)})"),
        onPressed: _onPrint,
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
            onPressed: _onPrint,
          ),
          const SizedBox(height: 10),
          Text(
            "Rejection Reason:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
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
            ),
          ),
        ],
      );
    }
    // Default case
    else {
      return ElevatedButton.icon(
        icon: const Icon(Icons.print),
        label: Text("Print (${capitalize(status)})"),
        onPressed: _onPrint,
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

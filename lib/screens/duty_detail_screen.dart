// lib/screens/duty_detail_screen.dart
import 'package:flutter/material.dart';
import '../widgets/custom_bottom_app_bar.dart'; // Import the CustomBottomAppBar
import 'duty_spt_screen.dart';
import 'create_duty_form.dart'; // We'll use this for "edit" button if Draft
import 'main_screen.dart';
import 'paidleave_cuti_screen.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting

class DutyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> duty;
  final List<Map<String, dynamic>> allDuties;

  const DutyDetailScreen({
    Key? key,
    required this.duty,
    required this.allDuties,
  }) : super(key: key);

  @override
  State<DutyDetailScreen> createState() => _DutyDetailScreenState();
}

class _DutyDetailScreenState extends State<DutyDetailScreen> {
  // Updated to dynamically set the created and modified times
  late String _createdAt;
  late String _modifiedAt;

  @override
  void initState() {
    super.initState();
    // Initialize createdAt and modifiedAt based on existing data or current time
    _createdAt = widget.duty["createdAt"] != null
        ? DateFormat('MMM dd yyyy hh:mm a')
            .format(DateTime.parse(widget.duty["createdAt"]))
        : DateFormat('MMM dd yyyy hh:mm a').format(DateTime.now());
    _modifiedAt = widget.duty["modifiedAt"] != null
        ? DateFormat('MMM dd yyyy hh:mm a')
            .format(DateTime.parse(widget.duty["modifiedAt"]))
        : _createdAt;
  }

  // ========== ACTION HANDLERS ==========
  void _onEdit() {
    // Navigate to CreateDutyForm with the duty to edit
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateDutyForm(
          duties: widget.allDuties,
          dutyToEdit: widget.duty, // Pass the duty to edit
        ),
      ),
    ).then((result) {
      if (result == 'sent' || result == 'updated') {
        // After sending or updating, navigate back to Duty List Screen
        Navigator.pop(context); // Pop DutyDetailScreen to go back to DutySPTScreen
      } else if (result == 'saved') {
        // After saving/updating as draft, refresh the detail screen
        setState(() {
          // Refresh the createdAt and modifiedAt in case they were updated
          _createdAt = widget.duty["createdAt"] != null
              ? DateFormat('MMM dd yyyy hh:mm a')
                  .format(DateTime.parse(widget.duty["createdAt"]))
              : DateFormat('MMM dd yyyy hh:mm a').format(DateTime.now());
          _modifiedAt = widget.duty["modifiedAt"] != null
              ? DateFormat('MMM dd yyyy hh:mm a')
                  .format(DateTime.parse(widget.duty["modifiedAt"]))
              : _createdAt;
        });
      }
    });
  }

  void _onSend() {
    // Update the duty status to "Waiting"
    setState(() {
      widget.duty["status"] = "Waiting";
      widget.duty["modifiedAt"] = DateTime.now().toIso8601String();
      _modifiedAt = DateFormat('MMM dd yyyy hh:mm a').format(DateTime.now());
    });

    // Show confirmation SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Duty Sent! Status=Waiting")),
    );

    // Navigate back to duty_spt_screen.dart
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
                  widget.allDuties.remove(widget.duty);
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
    final status = (widget.duty["status"] ?? "").toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Print Duty (status = $status) - dummy!")),
    );
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateDutyForm(
                                duties: widget.allDuties,
                              ),
                            ),
                          ).then((result) {
                            if (result == 'sent' || result == 'updated') {
                              Navigator.pop(context); // Pop DutyDetailScreen
                            } else if (result == 'saved') {
                              setState(() {
                                // Refresh the state if needed
                                _createdAt = widget.duty["createdAt"] != null
                                    ? DateFormat('MMM dd yyyy hh:mm a').format(
                                        DateTime.parse(
                                            widget.duty["createdAt"]))
                                    : DateFormat('MMM dd yyyy hh:mm a')
                                        .format(DateTime.now());
                                _modifiedAt = widget.duty["modifiedAt"] != null
                                    ? DateFormat('MMM dd yyyy hh:mm a').format(
                                        DateTime.parse(
                                            widget.duty["modifiedAt"]))
                                    : _createdAt;
                              });
                            }
                          });
                        },
                        child: const Text("Create Duty Form"),
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
                              builder: (_) => MainScreen(),
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
              child: _buildDetailContent(),
            );
          }
        },
      ),
      bottomNavigationBar: const CustomBottomAppBar(),
    );
  }

  Widget _buildDetailContent() {
    final duty = widget.duty;
    final description = duty["description"] ?? "No Title";
    final status = duty["status"] ?? "Draft";
    final dateStr = duty["date"] ?? "";
    final startTimeStr = duty["startTime"] ?? "";
    final endTimeStr = duty["endTime"] ?? "";

    // If createdBy or user info is not set, let's default to "andhika.nayaka"
    final createdBy = duty["createdBy"] ?? "andhika.nayaka";
    final approverName = _getApproverName(duty["approverId"]); // Fetch dynamically based on approverId

    // We'll parse "Waiting" or "Approved" or "Draft" ...
    final displayedDate =
        dateStr.isEmpty ? "20 December 2024" : _formatDate(dateStr);
    final displayedStart =
        startTimeStr.isEmpty ? "09:31:32" : _formatTime(startTimeStr);
    final displayedEnd =
        endTimeStr.isEmpty ? "16:30:00" : _formatTime(endTimeStr);

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
                // Title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                ),
                const SizedBox(height: 8),
                Text("Date: $displayedDate"),
                Text("Time: $displayedStart - $displayedEnd"),
                const SizedBox(height: 10),
                const Divider(),

                // Created By
                Row(
                  children: const [
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
                Text("NIK : 4163 (dummy)"),
                Text("Jabatan : APPLICATION SUPPORT STAFF"),
                const Divider(),

                // Approver
                Row(
                  children: const [
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
                Text("NIK : 3713"),
                Text("Jabatan : SENIOR PROGRAMMER"),

                const SizedBox(height: 20),
                _buildActionButtons(status),
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
    // If it's a DRAFT -> We can Edit, Send, or Delete
    if (status.toLowerCase() == "draft") {
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
    // If it's WAITING or APPROVED -> we can only Print
    else if (status.toLowerCase() == "waiting" ||
        status.toLowerCase() == "approved") {
      return ElevatedButton.icon(
        icon: const Icon(Icons.print),
        label: Text("Print ($status)"),
        onPressed: _onPrint,
      );
    }
    // If it's any other status (like REJECTED, RETURNED, etc.)
    else {
      return ElevatedButton.icon(
        icon: const Icon(Icons.print),
        label: Text("Print ($status)"),
        onPressed: _onPrint,
      );
    }
  }

  /// Helper method to format time from "HH:mm:ss" to "hh:mm a"
  String _formatTime(String time) {
    try {
      DateTime parsedTime = DateTime.parse("1970-01-01T$time");
      return DateFormat('hh:mm a').format(parsedTime);
    } catch (e) {
      return time;
    }
  }

  /// Helper method to format date from "YYYY-MM-DD" to "dd-MM-yyyy"
  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }
}

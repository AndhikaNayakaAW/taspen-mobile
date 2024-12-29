// lib/screens/duty_detail_screen.dart
import 'package:flutter/material.dart';
import '../widgets/custom_bottom_app_bar.dart'; // Import the CustomBottomAppBar
import 'duty_spt_screen.dart';
import 'create_duty_form.dart'; // We'll use this for "edit" button if Draft
import 'main_screen.dart';
import 'paidleave_cuti_screen.dart';

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
  // We'll use "andhika.nayaka" as the user if the duty is newly created
  // or "syahrizal" if the duty is approved or so. But let's do it simple:

  final String _createdAt = "Dec 25 2024 9:32AM";
  String _modifiedAt = "Dec 25 2024 9:32AM";

  // ========== ACTION HANDLERS ==========
  void _onEdit() {
    // 1) We'll pop back, then navigate to the CreateDutyForm to let user re-edit
    // For demo, let's simulate a direct "edit" by re-creating the draft in the form.
    final dutyIndex = widget.allDuties.indexOf(widget.duty);
    if (dutyIndex < 0) return; // not found

    // We'll remove it from the list, so we can re-add after editing
    // Or we can pass it to CreateDutyForm so user can edit
    final currentDuty = widget.duty;
    widget.allDuties.remove(currentDuty);

    Navigator.pop(context); // close detail screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateDutyForm(duties: widget.allDuties),
      ),
    );
  }

  void _onSend() {
    setState(() {
      widget.duty["status"] = "Waiting";
      _modifiedAt = "Dec 28 2024 10:00AM"; // example of updated time
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Duty Sent! Status=Waiting")),
    );
  }

  void _onDelete() {
    widget.allDuties.remove(widget.duty);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Duty Deleted!")),
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
      // Removed the Drawer to eliminate the hamburger menu
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
                              builder: (_) => const CreateDutyForm(duties: []),
                            ),
                          ).then((_) {
                            setState(() {});
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
                              builder: (_) =>  MainScreen(),
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
    final approverName = "syahrizal";

    // We'll parse "Waiting" or "Approved" or "Draft" ...
    final displayedDate = dateStr.isEmpty ? "20 December 2024" : dateStr;
    final displayedStart = startTimeStr.isEmpty ? "09:31:32" : startTimeStr;
    final displayedEnd = endTimeStr.isEmpty ? "16:30:00" : endTimeStr;

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
}

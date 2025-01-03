// lib/screens/paidleave_cuti_detail_screen.dart

import 'package:flutter/material.dart';
import '../widgets/custom_bottom_app_bar.dart'; // Import the CustomBottomAppBar
import 'package:intl/intl.dart'; // Import the intl package for DateFormat
import 'create_paidleave_cuti_form.dart'; // Import for "Edit" functionality

class PaidLeaveCutiDetailScreen extends StatefulWidget {
  final Map<String, dynamic> paidLeave;
  final List<Map<String, dynamic>> allPaidLeaves;

  const PaidLeaveCutiDetailScreen({
    Key? key,
    required this.paidLeave,
    required this.allPaidLeaves,
  }) : super(key: key);

  @override
  State<PaidLeaveCutiDetailScreen> createState() =>
      _PaidLeaveCutiDetailScreenState();
}

class _PaidLeaveCutiDetailScreenState
    extends State<PaidLeaveCutiDetailScreen> {
  // Variables to hold createdAt and modifiedAt timestamps
  late String _createdAt;
  late String _modifiedAt;

  // Variable to hold the selected status
  String _selectedStatus = "All";

  @override
  void initState() {
    super.initState();
    // Initialize createdAt and modifiedAt from paidLeave map
    _createdAt = widget.paidLeave["createdAt"] ??
        widget.paidLeave["datetime"] ??
        "N/A";
    _modifiedAt = widget.paidLeave["modifiedAt"] ?? "N/A";
  }

  // Action Handlers

  void _onEdit() {
    // Ensure that 'id' is treated as String
    final String leaveId = widget.paidLeave["id"];
    final paidLeaveIndex =
        widget.allPaidLeaves.indexWhere((leave) => leave["id"] == leaveId);
    if (paidLeaveIndex < 0) return; // Leave not found

    // Navigate to the form with existing data without awaiting a result
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePaidLeaveCutiForm(
          paidLeaves: widget.allPaidLeaves,
          existingLeave: widget.paidLeave,
          leaveIndex: paidLeaveIndex,
        ),
      ),
    );

    // No need to await and handle the result since the form screen redirects to the main screen
  }

  /// Sends the draft leave by updating its status to "Waiting" and passing it back
  void _onSend() {
    setState(() {
      // Update the status and modifiedAt fields
      widget.paidLeave["status"] = "Waiting";
      widget.paidLeave["modifiedAt"] =
          DateFormat('MMM d yyyy h:mm a').format(DateTime.now());
    });

    // Navigate back and pass the updated leave
    Navigator.pop(context, widget.paidLeave);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Paid Leave/Cuti Sent! Status=Waiting")),
    );
  }

  void _onDelete() {
    setState(() {
      // Remove the leave from allPaidLeaves by id
      widget.allPaidLeaves.removeWhere(
          (leave) => leave["id"] == widget.paidLeave["id"]);
    });

    // Navigate back and pass null or a status
    Navigator.pop(context, null);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Paid Leave/Cuti Deleted!")),
    );
  }

  void _onPrint() {
    final status = (widget.paidLeave["status"] ?? "").toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              "Print Paid Leave/Cuti (status = $status) - dummy!")),
    );
    // Implement actual print functionality if needed
  }

  /// Helper method to format date from 'dd MMMM yyyy' or 'yyyy-MM-dd' to 'dd-MM-yyyy'
  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateFormat('dd MMMM yyyy').parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      try {
        DateTime parsedDate = DateTime.parse(date);
        return DateFormat('dd-MM-yyyy').format(parsedDate);
      } catch (e) {
        return date;
      }
    }
  }

  /// Helper method to format datetime
  String _formatDateTime(String datetime) {
    try {
      DateTime parsedDate = DateTime.parse(datetime);
      return DateFormat('dd-MM-yyyy HH:mm').format(parsedDate);
    } catch (e) {
      try {
        DateTime parsedDate = DateFormat('dd MMMM yyyy').parse(datetime);
        return DateFormat('dd-MM-yyyy').format(parsedDate);
      } catch (e) {
        return datetime;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paid Leave/Cuti Detail"),
        backgroundColor: Colors.teal,
      ),
      // Removing Drawer to eliminate the hamburger button
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 600;
          return isDesktop
              ? Row(
                  children: [
                    SizedBox(
                      width: 250,
                      child: _buildSidebar(),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildDetailContent(isMobile: false),
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Sidebar remains on top for mobile users
                      Container(
                        width: double.infinity,
                        color: const Color(0xFFf8f9fa),
                        padding: const EdgeInsets.all(16.0),
                        child: _buildSidebar(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildDetailContent(isMobile: true),
                      ),
                    ],
                  ),
                );
        },
      ),
      bottomNavigationBar: const CustomBottomAppBar(),
    );
  }

  Widget _buildDetailContent({required bool isMobile}) {
    final paidLeave = widget.paidLeave;
    final jenisCuti = paidLeave["jenisCuti"] ?? "Jenis Cuti Tidak Diketahui";
    final nama = paidLeave["nama"] ?? "Nama Tidak Diketahui";
    final nik = paidLeave["nik"] ?? "NIK Tidak Diketahui";
    final fromDateStr = paidLeave["fromDate"] ?? "";
    final toDateStr = paidLeave["toDate"] ?? "";
    final status = paidLeave["status"] ?? "Draft";
    final sap = paidLeave["sap"] ?? "";
    final act = paidLeave["act"] ?? "";
    final alamatIzinSakit = paidLeave["alamatIzinSakit"] ?? "";
    final deskripsiIzinSakit = paidLeave["deskripsiIzinSakit"] ?? "";
    final alamatIzinIbadah = paidLeave["alamatIzinIbadah"] ?? "";
    final deskripsiIzinIbadah = paidLeave["deskripsiIzinIbadah"] ?? "";
    final buktiIzinSakit = paidLeave["buktiIzinSakit"] ?? "";
    final buktiIzinIbadah = paidLeave["buktiIzinIbadah"] ?? "";
    final approverIds = List<String>.from(paidLeave["approverIds"] ?? []);
    final approverNames = approverIds
        .map((id) => _getApproverNameById(id))
        .where((name) => name != null)
        .cast<String>()
        .toList();
    final createdBy = paidLeave["createdBy"] ?? "andhika.nayaka";

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =========== LEAVE DETAILS ===========
          Text(
            "$jenisCuti oleh $createdBy",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Created At: $_createdAt",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            "Modified At: $_modifiedAt",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),

          // NIK and Submission Date
          Row(
            children: [
              const Icon(Icons.badge, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                "NIK: $nik",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.date_range, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                "From: ${_formatDate(fromDateStr)}",
                style:
                    const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(width: 10),
              Text(
                "To: ${_formatDate(toDateStr)}",
                style:
                    const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.description, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "Deskripsi: ${paidLeave["deskripsi"] ?? "Tidak Ada Deskripsi"}",
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Specific fields based on leave type
          if (jenisCuti == "Izin Sakit") ...[
            Row(
              children: [
                const Icon(Icons.home, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Alamat Selama Izin Sakit: $alamatIzinSakit",
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.text_fields, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Deskripsi Izin Sakit: $deskripsiIzinSakit",
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_file, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Bukti Izin Sakit: $buktiIzinSakit",
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ] else if (jenisCuti == "Izin Ibadah") ...[
            Row(
              children: [
                const Icon(Icons.home, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Alamat Selama Izin Ibadah: $alamatIzinIbadah",
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.text_fields, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Deskripsi Izin Ibadah: $deskripsiIzinIbadah",
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_file, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Bukti Izin Ibadah: $buktiIzinIbadah",
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          const Divider(),
          const SizedBox(height: 10),

          // Approver Section
          Row(
            children: [
              const Icon(Icons.approval, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "Approver(s): ${approverNames.isNotEmpty ? approverNames.join(', ') : "Tidak Ada Approver"}",
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Status
          Row(
            children: [
              const Icon(Icons.info, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Container(
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Text(
                  status,
                  style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // =========== ACTION BUTTONS ===========
          _buildActionButtons(status),
        ],
      ),
    );
  }

  /// Builds action buttons based on the status of the leave
  Widget _buildActionButtons(String status) {
    // If status is DRAFT -> Can Edit, Send, or Delete
    if (status.toLowerCase() == "draft") {
      return Column(
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text("Edit"),
            onPressed: _onEdit,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50), // Make buttons full width
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text("Send"),
            onPressed: _onSend,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: const Size.fromHeight(50),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text("Delete"),
            onPressed: () {
              // Confirmation dialog before deleting
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Confirm Delete"),
                  content: const Text("Are you sure you want to delete this leave?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), // Cancel
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        _onDelete();
                      },
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size.fromHeight(50),
            ),
          ),
        ],
      );
    }
    // If status is WAITING or APPROVED -> Only Print
    else if (status.toLowerCase() == "waiting" ||
        status.toLowerCase() == "approved") {
      return ElevatedButton.icon(
        icon: const Icon(Icons.print),
        label: Text("Print ($status)"),
        onPressed: _onPrint,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
        ),
      );
    }
    // For other statuses like REJECTED, RETURNED, etc. -> Only Print
    else {
      return ElevatedButton.icon(
        icon: const Icon(Icons.print),
        label: Text("Print ($status)"),
        onPressed: _onPrint,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
        ),
      );
    }
  }

  /// Retrieves the approver's name based on their ID
  String? _getApproverNameById(String id) {
    // Define the same approver list as in CreatePaidLeaveCutiForm
    final List<Map<String, String>> approverList = [
      {"id": "60001", "name": "John Doe (CEO)"},
      {"id": "60002", "name": "Jane Smith (CFO)"},
      {"id": "60003", "name": "Robert Brown (COO)"},
    ];

    try {
      return approverList.firstWhere((item) => item["id"] == id)["name"];
    } catch (e) {
      return null;
    }
  }

  /// Retrieves the color based on the status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "draft":
        return Colors.grey;
      case "waiting":
        return Colors.orange;
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      case "returned":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// Sidebar widget displaying various statuses and their counts
  Widget _buildSidebar() {
    final allCount = widget.allPaidLeaves.length;
    final draftCount = widget.allPaidLeaves
        .where((leave) =>
            (leave["status"] ?? "").toString().toLowerCase() == "draft")
        .length;
    final waitingCount = widget.allPaidLeaves
        .where((leave) =>
            (leave["status"] ?? "").toString().toLowerCase() == "waiting")
        .length;
    final approvedCount = widget.allPaidLeaves
        .where((leave) =>
            (leave["status"] ?? "").toString().toLowerCase() == "approved")
        .length;
    final rejectedCount = widget.allPaidLeaves
        .where((leave) =>
            (leave["status"] ?? "").toString().toLowerCase() == "rejected")
        .length;

    return Container(
      color: const Color(0xFFf8f9fa),
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Button to Create Paid Leave/Cuti Form
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
              onPressed: () async {
                // Navigate to CreatePaidLeaveCutiForm
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreatePaidLeaveCutiForm(
                      paidLeaves: widget.allPaidLeaves,
                    ),
                  ),
                ).then((updatedLeave) {
                  if (updatedLeave != null && updatedLeave is Map<String, dynamic>) {
                    setState(() {
                      // Check if it's an update or a new entry
                      int existingIndex = widget.allPaidLeaves.indexWhere(
                          (leave) => leave["id"] == updatedLeave["id"]);
                      if (existingIndex != -1) {
                        // Update existing leave
                        widget.allPaidLeaves[existingIndex] = updatedLeave;
                      } else {
                        // Add new leave
                        widget.allPaidLeaves.add(updatedLeave);
                      }
                      // Optionally, you can update the current detail screen if it's the same leave
                      if (existingIndex == widget.allPaidLeaves.indexWhere(
                          (leave) => leave["id"] == widget.paidLeave["id"])) {
                        widget.paidLeave.addAll(updatedLeave);
                        _createdAt = widget.paidLeave["createdAt"] ??
                            widget.paidLeave["datetime"] ??
                            _createdAt;
                        _modifiedAt = widget.paidLeave["modifiedAt"] ?? _modifiedAt;
                      }
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Paid Leave/Cuti Added Successfully!")),
                    );
                  }
                });
              },
              child: const Text("Create Paid Leave/Cuti Form"),
            ),
            const SizedBox(height: 20),
            const Text("ALL LEAVE",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _buildStatusItem("All", allCount, Colors.teal),
            const Divider(),
            const Text("AS A CONCEPTOR / MAKER",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _buildStatusItem("Draft", draftCount, Colors.grey),
            _buildStatusItem("Waiting", waitingCount, Colors.orange),
            _buildStatusItem("Returned", 0, Colors.blue),
            _buildStatusItem("Approved", approvedCount, Colors.green),
            _buildStatusItem("Rejected", rejectedCount, Colors.red),
            const Divider(),
            const Text("AS AN APPROVAL",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _buildStatusItem("Need Approve", 0, Colors.orange),
            _buildStatusItem("Return", 0, Colors.blue),
            _buildStatusItem("Approve", 0, Colors.green),
            _buildStatusItem("Reject", 0, Colors.red),
          ],
        ),
      ),
    );
  }

  /// Widget for each status item in the sidebar
  Widget _buildStatusItem(String status, int count, Color color) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatus = status;
          // Implement filter functionality if needed
          // For example, navigate back to the main screen with a filter applied
          // Since this is the detail screen, this might not be necessary
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(
              status,
              style: TextStyle(
                color: _selectedStatus == status ? Colors.teal : Colors.black,
                fontWeight:
                    _selectedStatus == status ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            CircleAvatar(
              backgroundColor: color,
              radius: 10,
              child: Text(
                count.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

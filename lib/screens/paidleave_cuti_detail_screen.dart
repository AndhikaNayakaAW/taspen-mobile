// lib/screens/paidleave_cuti_detail_screen.dart

import 'package:flutter/material.dart';
import '../widgets/custom_bottom_app_bar.dart'; // Import the CustomBottomAppBar
import 'package:intl/intl.dart'; // Import the intl package for DateFormat
import 'duty_spt_screen.dart';
import 'create_paidleave_cuti_form.dart'; // We'll use this for "edit" button if Draft
import 'main_screen.dart';
import 'paidleave_cuti_screen.dart';

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

class _PaidLeaveCutiDetailScreenState extends State<PaidLeaveCutiDetailScreen> {
  // Tanggal dibuat dan dimodifikasi
  final String _createdAt = "Dec 25 2024 9:32AM";
  String _modifiedAt = "Dec 25 2024 9:32AM";

  String _selectedStatus = "All";
  int _currentPage = 1;

  // Missing definitions
  String _sortColumn = "fromDate";
  bool _ascending = true;
  int _recordsPerPage = 10;
  String _searchQuery = "";

  void _sortPaidLeaves(String column) {
    setState(() {
      _sortColumn = column;
      // Implement your custom sorting logic here if needed
    });
  }

  // ========== HANDLER AKSI ==========
  void _onEdit() {
    // Mendapatkan indeks pengajuan dari daftar semua pengajuan
    final paidLeaveIndex = widget.allPaidLeaves.indexOf(widget.paidLeave);
    if (paidLeaveIndex < 0) return; // Tidak ditemukan

    // Menghapus pengajuan saat ini dari daftar
    final currentPaidLeave = widget.paidLeave;
    widget.allPaidLeaves.remove(currentPaidLeave);

    // Menavigasi kembali dan membuka form edit
    Navigator.pop(context); // Menutup layar detail
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePaidLeaveCutiForm(paidLeaves: widget.allPaidLeaves),
      ),
    );
  }

  void _onSend() {
    setState(() {
      widget.paidLeave["status"] = "Waiting";
      _modifiedAt = "Dec 28 2024 10:00AM"; // Contoh waktu yang diperbarui
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Paid Leave/Cuti Sent! Status=Waiting")),
    );
  }

  void _onDelete() {
    widget.allPaidLeaves.remove(widget.paidLeave);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Paid Leave/Cuti Deleted!")),
    );
  }

  void _onPrint() {
    final status = (widget.paidLeave["status"] ?? "").toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Print Paid Leave/Cuti (status = $status) - dummy!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paid Leave/Cuti Detail"),
        backgroundColor: Colors.teal,
      ),
      // Menghapus Drawer untuk menghilangkan tombol hamburger
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
                      // Sidebar atas tetap untuk pengguna mobile
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
    final description = paidLeave["jenisCuti"] ?? "No Title";
    final status = paidLeave["status"] ?? "Draft";
    final fromDateStr = paidLeave["fromDate"] ?? "";
    final toDateStr = paidLeave["toDate"] ?? "";
    final jenisCuti = paidLeave["jenisCuti"] ?? "Jenis Cuti Tidak Diketahui";
    final alamat = paidLeave["alamat"] ?? "Tidak Ada Alamat";
    final bukti = paidLeave["bukti"] ?? "Tidak Ada Bukti";

    // Jika createdBy atau info pengguna tidak diset, default ke "andhika.nayaka"
    final createdBy = paidLeave["createdBy"] ?? "andhika.nayaka";
    final approverName = paidLeave["approverName"] ?? "syahrizal";

    // Parsing tanggal dan waktu
    final displayedFromDate = fromDateStr.isEmpty ? "20 December 2024" : fromDateStr;
    final displayedToDate = toDateStr.isEmpty ? "25 December 2024" : toDateStr;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Detail Paid Leave/Cuti",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris Judul dan Timestamps
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$jenisCuti oleh $createdBy",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
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
                ),
                const SizedBox(height: 8),
                Text("From Date: ${_formatDate(fromDateStr)}"),
                Text("To Date: ${_formatDate(toDateStr)}"),
                const SizedBox(height: 10),
                const Divider(),

                // Created By
                Row(
                  children: const [
                    Icon(Icons.person),
                    SizedBox(width: 4),
                    Text(
                      "Created By:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Nama : $createdBy"),
                Text("NIK : 4163 (dummy)"),
                Text("Jabatan : APPLICATION SUPPORT STAFF"),
                const Divider(),

                // Alamat Selama Cuti
                Row(
                  children: const [
                    Icon(Icons.home),
                    SizedBox(width: 4),
                    Text(
                      "Alamat Selama Cuti:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Alamat : $alamat"),
                const SizedBox(height: 10),
                const Divider(),

                // Bukti Cuti
                Row(
                  children: const [
                    Icon(Icons.upload_file),
                    SizedBox(width: 4),
                    Text(
                      "Bukti Cuti:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Bukti : $bukti"),
                const SizedBox(height: 10),
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
                _buildActionButtons(status, isMobile: isMobile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun aksi tombol berdasarkan status pengajuan
  Widget _buildActionButtons(String status, {required bool isMobile}) {
    // Jika status adalah DRAFT -> Bisa Edit, Send, atau Delete
    if (status.toLowerCase() == "draft") {
      return isMobile
          ? Column(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit"),
                  onPressed: _onEdit,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text("Send"),
                  onPressed: _onSend,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text("Delete"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _onDelete,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit"),
                    onPressed: _onEdit,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text("Send"),
                    onPressed: _onSend,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text("Delete"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: _onDelete,
                  ),
                ),
              ],
            );
    }
    // Jika status adalah WAITING atau APPROVED -> Hanya bisa Print
    else if (status.toLowerCase() == "waiting" ||
        status.toLowerCase() == "approved") {
      return ElevatedButton.icon(
        icon: const Icon(Icons.print),
        label: Text("Print ($status)"),
        onPressed: _onPrint,
      );
    }
    // Jika status lainnya (seperti REJECTED, RETURNED, dll.) -> Hanya bisa Print
    else {
      return ElevatedButton.icon(
        icon: const Icon(Icons.print),
        label: Text("Print ($status)"),
        onPressed: _onPrint,
      );
    }
  }

  /// Sidebar widget menampilkan berbagai status dan jumlahnya
  Widget _buildSidebar() {
    final allCount = widget.allPaidLeaves.length;
    final draftCount = widget.allPaidLeaves
        .where((leave) => (leave["status"] ?? "").toString().toLowerCase() == "draft")
        .length;
    final waitingCount = widget.allPaidLeaves
        .where((leave) => (leave["status"] ?? "").toString().toLowerCase() == "waiting")
        .length;
    final approvedCount = widget.allPaidLeaves
        .where((leave) => (leave["status"] ?? "").toString().toLowerCase() == "approved")
        .length;
    final rejectedCount = widget.allPaidLeaves
        .where((leave) => (leave["status"] ?? "").toString().toLowerCase() == "rejected")
        .length;

    return Container(
      color: const Color(0xFFf8f9fa),
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tombol Create Paid Leave/Cuti Form
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
              onPressed: () {
                // Navigasi ke CreatePaidLeaveCutiForm
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreatePaidLeaveCutiForm(paidLeaves: widget.allPaidLeaves),
                  ),
                ).then((_) {
                  setState(() {});
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

  /// Widget untuk setiap item status di sidebar
  Widget _buildStatusItem(String status, int count, Color color) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatus = status;
          _currentPage = 1;
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

  /// Membuat kartu untuk setiap pengajuan Paid Leave/Cuti
  Widget _buildPaidLeaveCard({
    required String jenisCuti,
    required String nama,
    required String fromDate,
    required String toDate,
    required String status,
    required String sap,
    required String act,
    required String datetime,
  }) {
    // Memilih warna berdasarkan status
    Color statusColor = Colors.grey;
    switch (status.toLowerCase()) {
      case "approved":
        statusColor = Colors.green;
        break;
      case "waiting":
      case "need approve":
        statusColor = Colors.orange;
        break;
      case "rejected":
        statusColor = Colors.red;
        break;
      case "draft":
        statusColor = Colors.blueGrey;
        break;
      case "returned":
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 2,
      child: InkWell(
        onTap: () {
          final leaveData = {
            "jenisCuti": jenisCuti,
            "nama": nama,
            "fromDate": fromDate,
            "toDate": toDate,
            "status": status,
            "sap": sap,
            "act": act,
            "datetime": datetime,
          };
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaidLeaveCutiDetailScreen(
                paidLeave: leaveData,
                allPaidLeaves: widget.allPaidLeaves,
              ),
            ),
          ).then((_) {
            setState(() {});
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Jenis Cuti dan Nama
              Text(
                "$jenisCuti oleh $nama",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              // Rentang Tanggal dan Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Rentang Tanggal
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.date_range,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            "From ${_formatDate(fromDate)} To ${_formatDate(toDate)}",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Status
                  Container(
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Text(
                      status,
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // SAP dan Act
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (sap.isNotEmpty)
                    Chip(
                      label: Text("SAP: $sap"),
                      backgroundColor: Colors.blue.shade100,
                    ),
                  if (act.isNotEmpty)
                    Chip(
                      label: Text("Act: $act"),
                      backgroundColor: Colors.orange.shade100,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method untuk memformat tanggal dari "YYYY-MM-DD" ke "dd-MM-yyyy"
  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }
}

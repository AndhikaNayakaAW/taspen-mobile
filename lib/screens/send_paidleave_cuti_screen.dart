// lib/screens/send_paidleave_cuti_screen.dart
import 'package:flutter/material.dart';
import '../widgets/custom_bottom_app_bar.dart';
import 'main_screen.dart';
import 'duty_spt_screen.dart';
import 'duty_detail_screen.dart';
import 'paidleave_cuti_screen.dart'; // Ensure this import exists
import 'package:intl/intl.dart'; // Import intl for date formatting
import 'create_paidleave_cuti_form.dart'; // Import the CreatePaidLeaveCutiForm class
import 'paidleave_cuti_detail_screen.dart';

class SendPaidLeaveCutiScreen extends StatefulWidget {
  final List<Map<String, dynamic>> paidLeaves;

  const SendPaidLeaveCutiScreen({
    Key? key,
    required this.paidLeaves,
  }) : super(key: key);

  @override
  _SendPaidLeaveCutiScreenState createState() => _SendPaidLeaveCutiScreenState();
}
// Removed top-level _filterPaidLeaves

class _SendPaidLeaveCutiScreenState extends State<SendPaidLeaveCutiScreen> {
  /// Filters the paid leaves based on search query, selected status, and date range
  void _filterPaidLeaves() {
    setState(() {});
  }
  // Sorting
  String _sortColumn = "fromDate";
  bool _ascending = true;

  // Search + Pagination
  String _searchQuery = "";
  int _recordsPerPage = 10;
  int _currentPage = 1;

  // Filter state variables
  String _selectedStatus = "Waiting";
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  @override
  void initState() {
    super.initState();
    // Initially, filter based on default status
    _filterPaidLeaves();
  }

  /// Filters the paid leaves based on search query, selected status, and date range
  List<Map<String, dynamic>> get _filteredPaidLeaves {
    return widget.paidLeaves.where((leave) {
      // Status Filter
      bool matchesStatus = _selectedStatus == "All"
          ? true
          : leave["status"].toString().toLowerCase() == _selectedStatus.toLowerCase();

      // Search Filter
      bool matchesSearch = leave["jenisCuti"]
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          leave["nama"]
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          leave["status"]
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      // Date Range Filter
      bool matchesStartDate = _filterStartDate == null
          ? true
          : _parseDate(leave["fromDate"]).isAfter(
              _filterStartDate!.subtract(const Duration(days: 1)),
            );
      bool matchesEndDate = _filterEndDate == null
          ? true
          : _parseDate(leave["toDate"]).isBefore(
              _filterEndDate!.add(const Duration(days: 1)),
            );

      return matchesStatus && matchesSearch && matchesStartDate && matchesEndDate;
    }).toList();
  }

  /// Sorts the paid leaves based on the selected column
  void _sortPaidLeaves(String columnKey) {
    setState(() {
      if (_sortColumn == columnKey) {
        _ascending = !_ascending;
      } else {
        _sortColumn = columnKey;
        _ascending = true;
      }

      widget.paidLeaves.sort((a, b) {
        var aValue = a[_sortColumn];
        var bValue = b[_sortColumn];
        if (_sortColumn == "fromDate" || _sortColumn == "toDate") {
          return _ascending
              ? _parseDate(aValue).compareTo(_parseDate(bValue))
              : _parseDate(bValue).compareTo(_parseDate(aValue));
        } else {
          return _ascending
              ? aValue.toString().compareTo(bValue.toString())
              : bValue.toString().compareTo(aValue.toString());
        }
      });
    });
  }

  /// Opens the date picker and sets the start or end date
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime initialDate = isStart
        ? (_filterStartDate ?? DateTime.now())
        : (_filterEndDate ?? DateTime.now());

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _filterStartDate = picked;
          // Ensure start date is before end date
          if (_filterEndDate != null && _filterStartDate!.isAfter(_filterEndDate!)) {
            _filterEndDate = null;
          }
        } else {
          _filterEndDate = picked;
          // Ensure end date is after start date
          if (_filterStartDate != null && _filterEndDate!.isBefore(_filterStartDate!)) {
            _filterStartDate = null;
          }
        }
      });
    }
  }

  /// Clears all filters
  void _clearFilters() {
    setState(() {
      _selectedStatus = "All";
      _filterStartDate = null;
      _filterEndDate = null;
      _searchQuery = "";
    });
  }

  /// Helper method to parse date from "dd MMMM yyyy" to DateTime
  DateTime _parseDate(String dateStr) {
    try {
      return DateFormat('dd MMMM yyyy').parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredPaidLeaves;
    final totalPages = (filteredList.length / _recordsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _recordsPerPage;
    final endIndex = startIndex + _recordsPerPage;
    final visiblePaidLeaves = filteredList.sublist(
      startIndex,
      endIndex > filteredList.length ? filteredList.length : endIndex,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Paid Leave/Cuti Screen"),
        backgroundColor: Colors.teal,
      ),
      // Removed the drawer property to eliminate the hamburger button
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            width: double.infinity,
            color: Colors.green[100],
            padding: const EdgeInsets.all(8),
            child: const Text(
              "Successfully Sent to Approver!",
              style: TextStyle(color: Colors.black87),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  // Desktop Layout
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Sidebar
                      SizedBox(
                        width: 250,
                        child: _buildSidebar(),
                      ),
                      /// Main Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildCardSection(
                            visiblePaidLeaves,
                            filteredList.length,
                            startIndex,
                            endIndex,
                            totalPages,
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Mobile Layout
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Sidebar top remains for mobile users
                        Container(
                          width: double.infinity,
                          color: const Color(0xFFf8f9fa),
                          padding: const EdgeInsets.all(16.0),
                          child: _buildSidebar(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildCardSection(
                            visiblePaidLeaves,
                            filteredList.length,
                            startIndex,
                            endIndex,
                            totalPages,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomAppBar(),
    );
  }

  Widget _buildSidebarDuplicate() {
    final allCount = widget.paidLeaves.length;
    final draftCount = widget.paidLeaves
        .where((leave) => (leave["status"] ?? "").toString().toLowerCase() == "draft")
        .length;
    final waitingCount = widget.paidLeaves
        .where((leave) => (leave["status"] ?? "").toString().toLowerCase() == "waiting")
        .length;
    final approvedCount = widget.paidLeaves
        .where((leave) => (leave["status"] ?? "").toString().toLowerCase() == "approved")
        .length;
    final rejectedCount = widget.paidLeaves
        .where((leave) => (leave["status"] ?? "").toString().toLowerCase() == "rejected")
        .length;

    return Container(
      color: const Color(0xFFf8f9fa),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            ),
            onPressed: () {
              // Navigate to CreatePaidLeaveCutiForm or any other relevant screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreatePaidLeaveCutiForm(paidLeaves: widget.paidLeaves),
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
    );
  }

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
                "$count",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSection(
    List<Map<String, dynamic>> visiblePaidLeaves,
    int totalCount,
    int startIndex,
    int endIndex,
    int totalPages,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Title
        Text(
          _selectedStatus == "All"
              ? "All Paid Leaves in 2024"
              : "All $_selectedStatus Paid Leaves in 2024",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // Filter and Sort Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Status Filter
            Row(
              children: [
                const Text(
                  "Status:",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                      _currentPage = 1;
                    });
                  },
                  items: const [
                    DropdownMenuItem(
                      value: "All",
                      child: Text("All"),
                    ),
                    DropdownMenuItem(
                      value: "Draft",
                      child: Text("Draft"),
                    ),
                    DropdownMenuItem(
                      value: "Waiting",
                      child: Text("Waiting"),
                    ),
                    DropdownMenuItem(
                      value: "Approved",
                      child: Text("Approved"),
                    ),
                    DropdownMenuItem(
                      value: "Rejected",
                      child: Text("Rejected"),
                    ),
                    DropdownMenuItem(
                      value: "Returned",
                      child: Text("Returned"),
                    ),
                    DropdownMenuItem(
                      value: "Need Approve",
                      child: Text("Need Approve"),
                    ),
                    DropdownMenuItem(
                      value: "Return",
                      child: Text("Return"),
                    ),
                    DropdownMenuItem(
                      value: "Approve",
                      child: Text("Approve"),
                    ),
                    DropdownMenuItem(
                      value: "Reject",
                      child: Text("Reject"),
                    ),
                  ],
                ),
              ],
            ),

            // Sort Controls
            Row(
              children: [
                const Text(
                  "Sort by:",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _sortColumn,
                  onChanged: (value) {
                    if (value != null) {
                      _sortPaidLeaves(value);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: "fromDate",
                      child: Text("From Date"),
                    ),
                    DropdownMenuItem(
                      value: "toDate",
                      child: Text("To Date"),
                    ),
                    DropdownMenuItem(
                      value: "jenisCuti",
                      child: Text("Jenis Cuti"),
                    ),
                    DropdownMenuItem(
                      value: "status",
                      child: Text("Status"),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                  ),
                  onPressed: () {
                    setState(() {
                      _ascending = !_ascending;
                      _sortPaidLeaves(_sortColumn);
                    });
                  },
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Search and Records Per Page
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Records Per Page
            DropdownButton<String>(
              value: _recordsPerPage.toString(),
              onChanged: (value) {
                setState(() {
                  _recordsPerPage = int.parse(value!);
                  _currentPage = 1; // reset
                });
              },
              items: const [
                DropdownMenuItem(
                  value: "10",
                  child: Text("10 records per page"),
                ),
                DropdownMenuItem(
                  value: "25",
                  child: Text("25 records per page"),
                ),
                DropdownMenuItem(
                  value: "50",
                  child: Text("50 records per page"),
                ),
                DropdownMenuItem(
                  value: "100",
                  child: Text("100 records per page"),
                ),
              ],
            ),
            // Search Field
            SizedBox(
              width: 200,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _currentPage = 1;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Paid Leave Cards
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visiblePaidLeaves.length,
          itemBuilder: (context, index) {
            final leave = visiblePaidLeaves[index];
            return _buildPaidLeaveCard(
              jenisCuti: leave["jenisCuti"],
              nama: leave["nama"],
              fromDate: leave["fromDate"],
              toDate: leave["toDate"],
              status: leave["status"],
              sap: leave["sap"],
              act: leave["act"],
              datetime: leave["datetime"],
            );
          },
        ),

        const SizedBox(height: 10),

        // Pagination
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Showing ${startIndex + 1} to "
              "${endIndex > totalCount ? totalCount : endIndex} "
              "of $totalCount entries",
              style: const TextStyle(fontSize: 14),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: _currentPage > 1
                      ? () {
                          setState(() {
                            _currentPage--;
                          });
                        }
                      : null,
                  child: const Text("Previous"),
                ),
                Text(
                  "Page $_currentPage of $totalPages",
                  style: const TextStyle(fontSize: 14),
                ),
                TextButton(
                  onPressed: _currentPage < totalPages
                      ? () {
                          setState(() {
                            _currentPage++;
                          });
                        }
                      : null,
                  child: const Text("Next"),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Card-like paid leave item for both desktop and mobile screens
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
    // Choose color based on status
    Color statusColor = Colors.grey;
    switch (status.toLowerCase()) {
      case "approved":
        statusColor = Colors.green;
        break;
      case "waiting":
      case "need approve approval":
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
      paidLeave: leaveData,          // Updated parameter name
      allPaidLeaves: widget.paidLeaves, // Updated parameter name
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
              // Jenis Cuti and Nama
              Text(
                "$jenisCuti by $nama",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              // Date Range and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date Range
                  Row(
                    children: [
                      const Icon(Icons.date_range,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "From ${_formatDate(fromDate)} To ${_formatDate(toDate)}",
                        style: const TextStyle(
                            fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
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
              // SAP and Act
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  /// Helper method to format date from "dd MMMM yyyy" to "dd-MM-yyyy"
  String _formatDate(String date) {
    try {
      DateTime parsedDate = _parseDate(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  /// Sidebar widget displaying different statuses and counts
  Widget _buildSidebar() {
    final allCount = widget.paidLeaves.length;
    final draftCount = widget.paidLeaves
        .where((leave) => (leave["status"] ?? "").toString().toLowerCase() == "draft")
        .length;
    final waitingCount = widget.paidLeaves
        .where((leave) => (leave["status"] ?? "").toString().toLowerCase() == "waiting")
        .length;
    final approvedCount = widget.paidLeaves
        .where((leave) => (leave["status"] ?? "").toString().toLowerCase() == "approved")
        .length;
    final rejectedCount = widget.paidLeaves
        .where((leave) => (leave["status"] ?? "").toString().toLowerCase() == "rejected")
        .length;

    return Container(
      color: const Color(0xFFf8f9fa),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create Paid Leave/Cuti Form Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            ),
            onPressed: () {
              // Navigate to CreatePaidLeaveCutiForm
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreatePaidLeaveCutiForm(paidLeaves: widget.paidLeaves),
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
    );
  }
}

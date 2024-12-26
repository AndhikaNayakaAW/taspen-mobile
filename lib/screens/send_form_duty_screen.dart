// lib/screens/send_form_duty_screen.dart
import 'package:flutter/material.dart';

class SendFormDutyScreen extends StatefulWidget {
  /// The full list of duties (including newly sent ones).
  final List<Map<String, dynamic>> duties;

  const SendFormDutyScreen({
    Key? key,
    required this.duties,
  }) : super(key: key);

  @override
  _SendFormDutyScreenState createState() => _SendFormDutyScreenState();
}

class _SendFormDutyScreenState extends State<SendFormDutyScreen> {
  // Default to "Waiting" so it matches your "All Waiting Duty in 2024"
  String _selectedStatus = "Waiting";

  // Sorting
  String _sortColumn = "date";
  bool _ascending = true;

  // For pagination + search
  String _searchQuery = "";
  int _recordsPerPage = 10;
  int _currentPage = 1;

  // Filter + sort
  List<Map<String, dynamic>> get _filteredDuties {
    // 1) Filter by selected status
    final statusFiltered = widget.duties.where((duty) {
      if (_selectedStatus == "All") return true; 
      // e.g. if we want only "Waiting"
      return (duty["status"] ?? "").toString().toLowerCase() ==
          _selectedStatus.toLowerCase();
    }).toList();

    // 2) Search
    final searched = statusFiltered.where((duty) {
      final desc = (duty["description"] ?? "").toLowerCase();
      return desc.contains(_searchQuery.toLowerCase());
    }).toList();

    // 3) Sort
    searched.sort((a, b) {
      final aVal = a[_sortColumn] ?? "";
      final bVal = b[_sortColumn] ?? "";
      if (_ascending) {
        return aVal.compareTo(bVal);
      } else {
        return bVal.compareTo(aVal);
      }
    });

    return searched;
  }

  @override
  Widget build(BuildContext context) {
    final allDuties = _filteredDuties;
    final totalPages = (allDuties.length / _recordsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _recordsPerPage;
    final endIndex = startIndex + _recordsPerPage;
    final visibleDuties = allDuties.sublist(
      startIndex,
      endIndex > allDuties.length ? allDuties.length : endIndex,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Form Duty Screen"),
        backgroundColor: Colors.teal,
      ),
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
                  // Desktop/tablet layout
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sidebar
                      SizedBox(
                        width: 250,
                        child: _buildSidebar(),
                      ),
                      // Table area
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildTableSection(
                            visibleDuties,
                            allDuties.length,
                            startIndex,
                            endIndex,
                            totalPages,
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Mobile layout (stack sidebar above table)
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Sidebar on top
                        Container(
                          width: double.infinity,
                          color: const Color(0xFFf8f9fa),
                          child: _buildSidebar(),
                        ),
                        // Table section
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildTableSection(
                            visibleDuties,
                            allDuties.length,
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
    );
  }

  // Sidebar with statuses
  Widget _buildSidebar() {
    final allCount = widget.duties.length;
    final draftCount = widget.duties
        .where((d) => (d["status"] ?? "").toString().toLowerCase() == "draft")
        .length;
    final waitingCount = widget.duties
        .where((d) => (d["status"] ?? "").toString().toLowerCase() == "waiting")
        .length;
    final approvedCount = widget.duties
        .where((d) => (d["status"] ?? "").toString().toLowerCase() == "approved")
        .length;
    final rejectedCount = widget.duties
        .where((d) => (d["status"] ?? "").toString().toLowerCase() == "rejected")
        .length;
    // Returned if you want, etc.

    return Container(
      color: const Color(0xFFf8f9fa),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Example "Create Duty Form" button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 20,
              ),
            ),
            onPressed: () {
              // Possibly navigate to CreateDutyForm again
            },
            child: const Text("Create Duty Form"),
          ),
          const SizedBox(height: 20),
          const Text("ALL DUTY", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildStatusItem("All", allCount, Colors.teal),
          const Divider(),
          const Text(
            "AS A CONCEPTOR / MAKER",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildStatusItem("Draft", draftCount, Colors.grey),
          _buildStatusItem("Waiting", waitingCount, Colors.orange),
          _buildStatusItem("Returned", 0, Colors.blue), // example
          _buildStatusItem("Approved", approvedCount, Colors.green),
          _buildStatusItem("Rejected", rejectedCount, Colors.red),
          const Divider(),
          const Text(
            "AS AN APPROVAL",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildStatusItem("Need Approve", 0, Colors.orange),
          _buildStatusItem("Return", 0, Colors.blue),
          _buildStatusItem("Approve", 0, Colors.green),
          _buildStatusItem("Reject", 0, Colors.red),
        ],
      ),
    );
  }

  // A single row in the sidebar
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
            Text(status),
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

  // Table section with search, pagination, etc.
  Widget _buildTableSection(
    List<Map<String, dynamic>> visibleDuties,
    int totalCount,
    int startIndex,
    int endIndex,
    int totalPages,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title depends on status
        Text(
          _selectedStatus == "All"
              ? "All Duty in 2024"
              : "All $_selectedStatus Duty in 2024",
          style: const TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 20),

        // Records per page + search
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DropdownButton<String>(
              value: _recordsPerPage.toString(),
              onChanged: (val) {
                setState(() {
                  _recordsPerPage = int.parse(val!);
                  _currentPage = 1;
                });
              },
              items: const [
                DropdownMenuItem(value: "10", child: Text("10 records per page")),
                DropdownMenuItem(value: "25", child: Text("25 records per page")),
                DropdownMenuItem(value: "50", child: Text("50 records per page")),
                DropdownMenuItem(value: "100", child: Text("100 records per page")),
              ],
            ),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Horizontal scroll for table
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 800,
            child: Column(
              children: [
                // Table headers
                Row(
                  children: [
                    _buildSortableHeader("Keterangan", "description", 200),
                    _buildSortableHeader("Tanggal Tugas", "date", 150),
                    _buildSortableHeader("Status", "status", 120),
                    _buildSortableHeader("Jam Mulai", "startTime", 100),
                    _buildSortableHeader("Jam Selesai", "endTime", 100),
                  ],
                ),
                const Divider(),
                // Table rows
                Column(
                  children: visibleDuties.map((duty) {
                    return _buildTableRow(duty);
                  }).toList(),
                ),
              ],
            ),
          ),
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
                Text("Page $_currentPage of $totalPages"),
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

  // Sortable header
  Widget _buildSortableHeader(String title, String columnKey, double width) {
    return InkWell(
      onTap: () {
        setState(() {
          if (_sortColumn == columnKey) {
            _ascending = !_ascending;
          } else {
            _sortColumn = columnKey;
            _ascending = true;
          }
        });
      },
      child: SizedBox(
        width: width,
        child: Row(
          children: [
            Text(title),
            const SizedBox(width: 4),
            Icon(
              _sortColumn == columnKey
                  ? (_ascending ? Icons.arrow_upward : Icons.arrow_downward)
                  : Icons.arrow_downward,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // Single row
  Widget _buildTableRow(Map<String, dynamic> duty) {
    final description = duty["description"] ?? "";
    final date = duty["date"] ?? "";
    final status = duty["status"] ?? "Waiting";
    final startTime = duty["startTime"] ?? "";
    final endTime = duty["endTime"] ?? "";

    // Color by status
    Color statusColor = Colors.grey;
    if (status.toLowerCase() == "approved") {
      statusColor = Colors.green;
    } else if (status.toLowerCase() == "waiting") {
      statusColor = Colors.orange;
    } else if (status.toLowerCase() == "rejected") {
      statusColor = Colors.red;
    } else if (status.toLowerCase() == "draft") {
      statusColor = Colors.blueGrey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 200, child: Text(description)),
          SizedBox(width: 150, child: Text(date)),
          SizedBox(
            width: 120,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Text(
                status,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          SizedBox(width: 100, child: Text(startTime)),
          SizedBox(width: 100, child: Text(endTime)),
        ],
      ),
    );
  }
}

// lib/screens/saved_form_duty_screen.dart
import 'package:flutter/material.dart';
import 'duty_detail_screen.dart';
import 'main_screen.dart';      // For the Home button
import 'duty_spt_screen.dart'; // For the Request Duty Status

class SavedFormDutyScreen extends StatefulWidget {
  final List<Map<String, dynamic>> duties;

  const SavedFormDutyScreen({
    Key? key,
    required this.duties,
  }) : super(key: key);

  @override
  _SavedFormDutyScreenState createState() => _SavedFormDutyScreenState();
}

class _SavedFormDutyScreenState extends State<SavedFormDutyScreen> {
  // Sorting
  String _sortColumn = "date";
  bool _ascending = true;

  // For pagination + search
  String _searchQuery = "";
  int _recordsPerPage = 10;
  int _currentPage = 1;

  // Filter by status in the sidebar
  String _selectedStatus = "Draft"; // or "All"

  List<Map<String, dynamic>> get _filteredDuties {
    // Filter by status
    final statusFiltered = widget.duties.where((duty) {
      if (_selectedStatus == "All") return true;
      return (duty["status"] ?? "").toLowerCase() ==
          _selectedStatus.toLowerCase();
    }).toList();

    // Then search
    final searched = statusFiltered.where((duty) {
      final desc = (duty["description"] ?? "").toLowerCase();
      return desc.contains(_searchQuery.toLowerCase());
    }).toList();

    // Sort
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
    final list = _filteredDuties;
    final totalPages = (list.length / _recordsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _recordsPerPage;
    final endIndex = startIndex + _recordsPerPage;
    final visible = list.sublist(
      startIndex,
      endIndex > list.length ? list.length : endIndex,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Form Duty Screen"),
        backgroundColor: Colors.teal,
      ),
      drawer: _buildHamburgerDrawer(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            width: double.infinity,
            color: Colors.green[100],
            padding: const EdgeInsets.all(8),
            child: const Text(
              "Successfully Executed",
              style: TextStyle(color: Colors.black87),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  // Desktop
                  return Row(
                    children: [
                      SizedBox(
                        width: 250,
                        child: _buildSidebar(),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildTableSection(
                            visible,
                            list.length,
                            startIndex,
                            endIndex,
                            totalPages,
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Mobile
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          color: const Color(0xFFf8f9fa),
                          child: _buildSidebar(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildTableSection(
                            visible,
                            list.length,
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

  Widget _buildHamburgerDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.teal),
            child: const Text(
              "Saved Duty Menu",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.arrow_back),
            title: const Text("Back"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt_outlined),
            title: const Text("Request Duty Status"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => DutySPTScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final allCount = widget.duties.length;
    final draftCount = widget.duties
        .where((d) => (d["status"] ?? "").toLowerCase() == "draft")
        .length;
    final waitingCount = widget.duties
        .where((d) => (d["status"] ?? "").toLowerCase() == "waiting")
        .length;
    final approvedCount = widget.duties
        .where((d) => (d["status"] ?? "").toLowerCase() == "approved")
        .length;
    final rejectedCount = widget.duties
        .where((d) => (d["status"] ?? "").toLowerCase() == "rejected")
        .length;

    return Container(
      color: const Color(0xFFf8f9fa),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text("ALL DUTY", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildSidebarItem("All", allCount, Colors.teal),
          const Divider(),
          const Text("AS A CONCEPTOR / MAKER",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildSidebarItem("Draft", draftCount, Colors.grey),
          _buildSidebarItem("Waiting", waitingCount, Colors.orange),
          _buildSidebarItem("Returned", 0, Colors.blue),
          _buildSidebarItem("Approved", approvedCount, Colors.green),
          _buildSidebarItem("Rejected", rejectedCount, Colors.red),
          const Divider(),
          const Text("AS AN APPROVAL",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildSidebarItem("Need Approve", 0, Colors.orange),
          _buildSidebarItem("Return", 0, Colors.blue),
          _buildSidebarItem("Approve", 0, Colors.green),
          _buildSidebarItem("Reject", 0, Colors.red),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(String status, int count, Color color) {
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

  Widget _buildTableSection(
    List<Map<String, dynamic>> visible,
    int totalCount,
    int startIndex,
    int endIndex,
    int totalPages,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedStatus == "All"
              ? "All Duty"
              : "Duty - $_selectedStatus Status",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        // header
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
                DropdownMenuItem(
                  value: "10",
                  child: Text("10 records / page"),
                ),
                DropdownMenuItem(
                  value: "25",
                  child: Text("25 records / page"),
                ),
                DropdownMenuItem(
                  value: "50",
                  child: Text("50 records / page"),
                ),
                DropdownMenuItem(
                  value: "100",
                  child: Text("100 records / page"),
                ),
              ],
            ),
            SizedBox(
              width: 200,
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                    _currentPage = 1;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search Keterangan",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // table
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 800,
            child: Column(
              children: [
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
                Column(
                  children: visible.map(_buildTableRow).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // pagination
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
                      ? () => setState(() => _currentPage--)
                      : null,
                  child: const Text("Previous"),
                ),
                Text("Page $_currentPage of $totalPages"),
                TextButton(
                  onPressed: _currentPage < totalPages
                      ? () => setState(() => _currentPage++)
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

  Widget _buildTableRow(Map<String, dynamic> duty) {
    final description = duty["description"] ?? "";
    final date = duty["date"] ?? "";
    final status = duty["status"] ?? "";
    final startTime = duty["startTime"] ?? "";
    final endTime = duty["endTime"] ?? "";

    // For color
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

    return InkWell(
      onTap: () {
        // Show detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DutyDetailScreen(duty: duty, allDuties: widget.duties),
          ),
        ).then((_) {
          setState(() {});
        });
      },
      child: Padding(
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
                child: Text(status, style: const TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(width: 100, child: Text(startTime)),
            SizedBox(width: 100, child: Text(endTime)),
          ],
        ),
      ),
    );
  }
}

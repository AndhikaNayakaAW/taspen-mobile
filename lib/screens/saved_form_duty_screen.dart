// lib/screens/saved_form_duty_screen.dart
import 'package:flutter/material.dart';
import 'duty_detail_screen.dart';
import 'main_screen.dart';      // For the Home button
import 'duty_spt_screen.dart'; // For the Request Duty Status
import 'package:intl/intl.dart'; // For date formatting

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

  // Filter state variables
  String _selectedStatus = "All";
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  @override
  void initState() {
    super.initState();
    // Initially, all duties are displayed
  }

  /// Filters the duties based on search query, selected status, and date range
  List<Map<String, dynamic>> get _filteredDuties {
    return widget.duties.where((duty) {
      // Search Filter
      bool matchesSearch = duty["description"]
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());

      // Status Filter
      bool matchesStatus = _selectedStatus == "All"
          ? true
          : duty["status"].toString().toLowerCase() ==
              _selectedStatus.toLowerCase();

      // Date Range Filter
      bool matchesStartDate = _filterStartDate == null
          ? true
          : DateTime.parse(duty["date"]).isAfter(
              _filterStartDate!.subtract(Duration(days: 1)),
            );
      bool matchesEndDate = _filterEndDate == null
          ? true
          : DateTime.parse(duty["date"]).isBefore(
              _filterEndDate!.add(Duration(days: 1)),
            );

      return matchesSearch && matchesStatus && matchesStartDate && matchesEndDate;
    }).toList();
  }

  /// Sorts the duties based on the selected column
  void _sortDuties(String columnKey) {
    setState(() {
      if (_sortColumn == columnKey) {
        _ascending = !_ascending;
      } else {
        _sortColumn = columnKey;
        _ascending = true;
      }

      widget.duties.sort((a, b) {
        var aValue = a[_sortColumn];
        var bValue = b[_sortColumn];
        if (_sortColumn == "date") {
          return _ascending
              ? DateTime.parse(aValue).compareTo(DateTime.parse(bValue))
              : DateTime.parse(bValue).compareTo(DateTime.parse(aValue));
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
          if (_filterEndDate != null &&
              _filterStartDate!.isAfter(_filterEndDate!)) {
            _filterEndDate = null;
          }
        } else {
          _filterEndDate = picked;
          // Ensure end date is after start date
          if (_filterStartDate != null &&
              _filterEndDate!.isBefore(_filterStartDate!)) {
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

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredDuties;
    final totalPages = (filteredList.length / _recordsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _recordsPerPage;
    final endIndex = startIndex + _recordsPerPage;
    final visibleDuties = filteredList.sublist(
      startIndex,
      endIndex > filteredList.length ? filteredList.length : endIndex,
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
                      /// Sidebar
                      SizedBox(
                        width: 250,
                        child: _buildSidebar(),
                      ),
                      /// Main Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildTableSection(
                            visibleDuties,
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
                  // Mobile
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Sidebar top (can be collapsed or hidden on mobile)
                        Container(
                          width: double.infinity,
                          color: const Color(0xFFf8f9fa),
                          padding: const EdgeInsets.all(16.0),
                          child: _buildSidebar(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildTableSection(
                            visibleDuties,
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
        .where((d) =>
            (d["status"] ?? "").toString().toLowerCase() == "draft")
        .length;
    final waitingCount = widget.duties
        .where((d) =>
            (d["status"] ?? "").toString().toLowerCase() == "waiting")
        .length;
    final approvedCount = widget.duties
        .where((d) =>
            (d["status"] ?? "").toString().toLowerCase() == "approved")
        .length;
    final rejectedCount = widget.duties
        .where((d) =>
            (d["status"] ?? "").toString().toLowerCase() == "rejected")
        .length;

    return Container(
      color: const Color(0xFFf8f9fa),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("ALL DUTY",
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _buildSidebarItem("All", allCount, Colors.teal),
          const Divider(),
          const Text("AS A CONCEPTOR / MAKER",
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _buildSidebarItem("Draft", draftCount, Colors.grey),
          _buildSidebarItem("Waiting", waitingCount, Colors.orange),
          _buildSidebarItem("Returned", 0, Colors.blue),
          _buildSidebarItem("Approved", approvedCount, Colors.green),
          _buildSidebarItem("Rejected", rejectedCount, Colors.red),
          const Divider(),
          const Text("AS AN APPROVAL",
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
        // Header: Title
        Text(
          _selectedStatus == "All"
              ? "All Duty"
              : "Duty - $_selectedStatus Status",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // Filter Controls (for Desktop)
        if (MediaQuery.of(context).size.width > 600)
          _buildFilterControlsDesktop(),

        // Search and Records Per Page
        if (MediaQuery.of(context).size.width > 600)
          const SizedBox(height: 10),

        // Table
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            constraints: const BoxConstraints(
              minWidth: 600, // Minimum width to prevent collapsing
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Headers
                Row(
                  children: [
                    _buildSortableHeader("Keterangan", "description", 200),
                    _buildSortableHeader("Tanggal Tugas", "date", 150),
                    _buildSortableHeader("Status", "status", 120),
                    // Removed "Jam Mulai" and "Jam Selesai" headers
                  ],
                ),
                const Divider(thickness: 1.5),
                // Rows
                // Replace ListView.builder with Column to prevent unbounded width error
                Column(
                  children: visibleDuties.map((duty) => _buildTableRow(duty)).toList(),
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

  Widget _buildFilterControlsDesktop() {
    return Row(
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

        // Date Range Filter
        Row(
          children: [
            // Start Date
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4),
                Text(
                  _filterStartDate == null
                      ? "Start Date"
                      : DateFormat('dd-MM-yyyy').format(_filterStartDate!),
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () {
                    _selectDate(context, true);
                  },
                ),
              ],
            ),
            const SizedBox(width: 10),
            // End Date
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4),
                Text(
                  _filterEndDate == null
                      ? "End Date"
                      : DateFormat('dd-MM-yyyy').format(_filterEndDate!),
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () {
                    _selectDate(context, false);
                  },
                ),
              ],
            ),
          ],
        ),

        // Clear Filters Button
        ElevatedButton(
          onPressed: _clearFilters,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
          ),
          child: const Text(
            "Clear Filters",
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildSortableHeaderDesktop(String title, String columnKey, double width) {
    return InkWell(
      onTap: () {
        _sortDuties(columnKey);
      },
      child: SizedBox(
        width: width,
        child: Row(
          children: [
            Text(
              title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Icon(
              _sortColumn == columnKey
                  ? (_ascending ? Icons.arrow_upward : Icons.arrow_downward)
                  : Icons.unfold_more,
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
    if (status.toString().toLowerCase() == "approved") {
      statusColor = Colors.green;
    } else if (status.toString().toLowerCase() == "waiting") {
      statusColor = Colors.orange;
    } else if (status.toString().toLowerCase() == "rejected") {
      statusColor = Colors.red;
    } else if (status.toString().toLowerCase() == "draft") {
      statusColor = Colors.blueGrey;
    }

    return InkWell(
      onTap: () {
        // Show detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DutyDetailScreen(
              duty: duty,
              allDuties: widget.duties,
            ),
          ),
        ).then((_) {
          setState(() {});
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            // Keterangan with time range
            SizedBox(
              width: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${_formatTime(startTime)} - ${_formatTime(endTime)}",
                    style:
                        const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Tanggal Tugas
            SizedBox(
              width: 150,
              child: Text(
                _formatDate(date),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            // Status
            SizedBox(
              width: 120,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Text(
                  status,
                  style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to format time from "HH:mm:ss" to "HH:mm"
  String _formatTime(String time) {
    try {
      DateTime parsedTime = DateTime.parse("1970-01-01T$time");
      return "${parsedTime.hour.toString().padLeft(2, '0')}:${parsedTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return time;
    }
  }

  /// Helper method to format date from "YYYY-MM-DD" to a more readable format
  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  /// Sortable column for large screens
  Widget _buildSortableHeader(String title, String columnKey, double width) {
    return InkWell(
      onTap: () {
        _sortDuties(columnKey);
      },
      child: SizedBox(
        width: width,
        child: Row(
          children: [
            Text(
              title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Icon(
              _sortColumn == columnKey
                  ? (_ascending ? Icons.arrow_upward : Icons.arrow_downward)
                  : Icons.unfold_more,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// Card-like duty item for mobile screens
  Widget _buildMobileDutyCard({
    required String description,
    required String date,
    required String status,
    required String startTime,
    required String endTime,
  }) {
    // Choose color
    Color statusColor = Colors.grey;
    if (status.toString().toLowerCase() == "approved") {
      statusColor = Colors.green;
    } else if (status.toString().toLowerCase() == "waiting") {
      statusColor = Colors.orange;
    } else if (status.toString().toLowerCase() == "rejected") {
      statusColor = Colors.red;
    } else if (status.toString().toLowerCase() == "draft") {
      statusColor = Colors.blueGrey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 2,
      child: InkWell(
        onTap: () {
          final dutyData = {
            "description": description,
            "date": date,
            "status": status,
            "startTime": startTime,
            "endTime": endTime,
          };
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DutyDetailScreen(
                duty: dutyData,
                allDuties: widget.duties,
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
              // Description
              Text(
                description,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              // Time Range
              Text(
                "${_formatTime(startTime)} - ${_formatTime(endTime)}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              // Date and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(date),
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
            ],
          ),
        ),
      ),
    );
  }

  /// Opens the filter modal for mobile screens
  void _openFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding:
              const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status Filter
              Row(
                children: [
                  const Text(
                    "Status:",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                          _currentPage = 1;
                        });
                        Navigator.pop(context);
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
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Date Range Filter
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _filterStartDate == null
                        ? "Start Date"
                        : DateFormat('dd-MM-yyyy').format(_filterStartDate!),
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () {
                      _selectDate(context, true);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _filterEndDate == null
                        ? "End Date"
                        : DateFormat('dd-MM-yyyy').format(_filterEndDate!),
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () {
                      _selectDate(context, false);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Clear Filters Button
              ElevatedButton(
                onPressed: () {
                  _clearFilters();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                ),
                child: const Text("Clear Filters"),
              ),
            ],
          ),
        );
      },
    );
  }
}

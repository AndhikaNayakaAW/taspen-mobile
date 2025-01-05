// lib/screens/duty_spt_screen.dart
import 'package:flutter/material.dart';
import '../widgets/custom_bottom_app_bar.dart'; // Import the CustomBottomAppBar
import 'create_duty_form.dart';
import 'duty_detail_screen.dart';
import 'package:intl/intl.dart';
import 'main_screen.dart';
import 'paidleave_cuti_screen.dart';
import 'package:mobileapp/dummies/duty_list.dart';

class DutySPTScreen extends StatefulWidget {
  const DutySPTScreen({Key? key}) : super(key: key);

  @override
  _DutySPTScreenState createState() => _DutySPTScreenState();
}

class _DutySPTScreenState extends State<DutySPTScreen> {

  List<Map<String, dynamic>> filteredDuties = [];
  String sortColumn = "date";
  bool ascending = true;
  String searchQuery = "";
  int recordsPerPage = 10;
  int currentPage = 1;

  // Filter state variables
  String selectedStatus = "All";
  DateTime? filterStartDate;
  DateTime? filterEndDate;

  @override
  void initState() {
    super.initState();
    filteredDuties = duties; // Show all initially
  }

  /// Filters the duties based on search query, selected status, and date range
  void filterDuties() {
    setState(() {
      filteredDuties = duties.where((duty) {
        bool matchesSearch = duty["description"]
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase());

        bool matchesStatus = selectedStatus == "All"
            ? true
            : duty["status"].toString().toLowerCase() ==
                selectedStatus.toLowerCase();

        bool matchesStartDate = filterStartDate == null
            ? true
            : DateTime.parse(duty["date"])
                .isAfter(filterStartDate!.subtract(const Duration(days: 1)));

        bool matchesEndDate = filterEndDate == null
            ? true
            : DateTime.parse(duty["date"])
                .isBefore(filterEndDate!.add(const Duration(days: 1)));

        return matchesSearch &&
            matchesStatus &&
            matchesStartDate &&
            matchesEndDate;
      }).toList();

      currentPage = 1; // Reset to first page on filter
    });
  }

  /// Sorts the duties based on the selected column
  void sortDuties(String columnKey) {
    setState(() {
      if (sortColumn == columnKey) {
        ascending = !ascending;
      } else {
        sortColumn = columnKey;
        ascending = true;
      }
      duties.sort((a, b) {
        var aValue = a[columnKey];
        var bValue = b[columnKey];
        if (columnKey == "date") {
          return ascending
              ? DateTime.parse(aValue).compareTo(DateTime.parse(bValue))
              : DateTime.parse(bValue).compareTo(DateTime.parse(aValue));
        } else {
          return ascending
              ? aValue.toString().compareTo(bValue.toString())
              : bValue.toString().compareTo(aValue.toString());
        }
      });
      filterDuties(); // Re-apply filter after sorting
    });
  }

  /// Opens the date picker and sets the start or end date
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime initialDate = isStart
        ? (filterStartDate ?? DateTime.now())
        : (filterEndDate ?? DateTime.now());

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          filterStartDate = picked;
          // Ensure start date is before end date
          if (filterEndDate != null &&
              filterStartDate!.isAfter(filterEndDate!)) {
            filterEndDate = null;
          }
        } else {
          filterEndDate = picked;
          // Ensure end date is after start date
          if (filterStartDate != null &&
              filterEndDate!.isBefore(filterStartDate!)) {
            filterStartDate = null;
          }
        }
        filterDuties();
      });
    }
  }

  /// Clears all filters
  void _clearFilters() {
    setState(() {
      selectedStatus = "All";
      filterStartDate = null;
      filterEndDate = null;
      searchQuery = "";
      filterDuties();
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (filteredDuties.length / recordsPerPage).ceil();
    int startIndex = (currentPage - 1) * recordsPerPage;
    int endIndex = startIndex + recordsPerPage;
    List<Map<String, dynamic>> visibleDuties = filteredDuties.sublist(
      startIndex,
      endIndex > filteredDuties.length ? filteredDuties.length : endIndex,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Request Duty Status",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Large screen
          if (constraints.maxWidth > 600) {
            return Row(
              children: [
                /// Sidebar
                Container(
                  width: 250,
                  color: const Color(0xFFf8f9fa),
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Create Duty Form Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                          ),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CreateDutyForm(duties: duties),
                              ),
                            );
                            setState(() {
                              filterDuties();
                            });
                          },
                          child: const Text("Create Duty Form"),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "ALL DUTY",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        _buildStatusItem(
                            "All", filteredDuties.length, Colors.teal),
                        const Divider(),
                        const Text(
                          "AS A CONCEPTOR / MAKER",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        _buildStatusItem(
                            "Draft",
                            duties
                                .where((duty) => duty["status"] == "Draft")
                                .length,
                            Colors.grey),
                        _buildStatusItem(
                          "Waiting",
                          duties
                              .where((duty) => duty["status"] == "Waiting")
                              .length,
                          Colors.orange,
                        ),
                        _buildStatusItem(
                            "Returned",
                            duties
                                .where((duty) => duty["status"] == "Returned")
                                .length,
                            Colors.blue),
                        _buildStatusItem(
                          "Approved",
                          duties
                              .where((duty) => duty["status"] == "Approved")
                              .length,
                          Colors.green,
                        ),
                        _buildStatusItem(
                            "Rejected",
                            duties
                                .where((duty) => duty["status"] == "Rejected")
                                .length,
                            Colors.red),
                        const Divider(),
                        const Text(
                          "AS AN APPROVAL",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        _buildStatusItem(
                            "Need Approve",
                            duties
                                .where(
                                    (duty) => duty["status"] == "Need Approve")
                                .length,
                            Colors.orange),
                        _buildStatusItem(
                            "Return",
                            duties
                                .where((duty) => duty["status"] == "Return")
                                .length,
                            Colors.blue),
                        _buildStatusItem(
                            "Approve",
                            duties
                                .where((duty) => duty["status"] == "Approve")
                                .length,
                            Colors.green),
                        _buildStatusItem(
                            "Reject",
                            duties
                                .where((duty) => duty["status"] == "Reject")
                                .length,
                            Colors.red),
                      ],
                    ),
                  ),
                ),

                /// Main Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        const Text(
                          "All Duty in 2024",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Filter Controls
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
                                  value: selectedStatus,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedStatus = value!;
                                      filterDuties();
                                    });
                                  },
                                  items: const [
                                    DropdownMenuItem(
                                      value: "All",
                                      child: Text("All"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Approved",
                                      child: Text("Approved"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Waiting",
                                      child: Text("Waiting"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Rejected",
                                      child: Text("Rejected"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Draft",
                                      child: Text("Draft"),
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
                                      filterStartDate == null
                                          ? "Start Date"
                                          : DateFormat('dd-MM-yyyy')
                                              .format(filterStartDate!),
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
                                      filterEndDate == null
                                          ? "End Date"
                                          : DateFormat('dd-MM-yyyy')
                                              .format(filterEndDate!),
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
                        ),

                        const SizedBox(height: 20),

                        // Header: records & search
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DropdownButton<String>(
                              value: recordsPerPage.toString(),
                              onChanged: (value) {
                                setState(() {
                                  recordsPerPage = int.parse(value!);
                                  currentPage = 1; // reset
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
                            SizedBox(
                              width: 200,
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    searchQuery = value;
                                    filterDuties();
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

                        // Table
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              // Make the table width responsive
                              constraints: const BoxConstraints(
                                minWidth:
                                    600, // Minimum width to prevent collapsing
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Headers
                                  Row(
                                    children: [
                                      _buildSortableColumn(
                                          "Keterangan", "description"),
                                      _buildSortableColumn(
                                          "Tanggal Tugas", "date"),
                                      _buildSortableColumn("Status", "status"),
                                      // Removed "Jam Mulai" and "Jam Selesai" headers
                                    ],
                                  ),
                                  const Divider(
                                    thickness: 1.5,
                                  ),
                                  // Rows
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: visibleDuties.length,
                                    itemBuilder: (context, index) {
                                      final duty = visibleDuties[index];
                                      return _buildTableRow(
                                        description: duty["description"],
                                        date: duty["date"],
                                        status: duty["status"],
                                        startTime: duty["startTime"],
                                        endTime: duty["endTime"],
                                        rejectionReason:
                                            duty["rejectionReason"] ?? "",
                                      );
                                    },
                                  ),
                                ],
                              ),
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
                              "${endIndex > filteredDuties.length ? filteredDuties.length : endIndex} "
                              "of ${filteredDuties.length} entries",
                              style: const TextStyle(fontSize: 14),
                            ),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: currentPage > 1
                                      ? () {
                                          setState(() {
                                            currentPage--;
                                          });
                                        }
                                      : null,
                                  child: const Text("Previous"),
                                ),
                                Text(
                                  "Page $currentPage of $totalPages",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                TextButton(
                                  onPressed: currentPage < totalPages
                                      ? () {
                                          setState(() {
                                            currentPage++;
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
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Mobile
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Create Duty Form Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CreateDutyForm(duties: duties),
                          ),
                        );
                        setState(() {
                          filterDuties();
                        });
                      },
                      child: const Text("Create Duty Form"),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "ALL DUTY",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Divider(),
                    const Text(
                      "AS A CONCEPTOR / MAKER",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    _buildStatusItem(
                        "Draft",
                        duties
                            .where((duty) => duty["status"] == "Draft")
                            .length,
                        Colors.grey),
                    _buildStatusItem(
                      "Waiting",
                      duties
                          .where((duty) => duty["status"] == "Waiting")
                          .length,
                      Colors.orange,
                    ),
                    _buildStatusItem(
                        "Returned",
                        duties
                            .where((duty) => duty["status"] == "Returned")
                            .length,
                        Colors.blue),
                    _buildStatusItem(
                      "Approved",
                      duties
                          .where((duty) => duty["status"] == "Approved")
                          .length,
                      Colors.green,
                    ),
                    _buildStatusItem(
                        "Rejected",
                        duties
                            .where((duty) => duty["status"] == "Rejected")
                            .length,
                        Colors.red),
                    const Divider(),
                    const Text(
                      "AS AN APPROVAL",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    _buildStatusItem(
                        "Need Approve",
                        duties
                            .where((duty) => duty["status"] == "Need Approve")
                            .length,
                        Colors.orange),
                    _buildStatusItem(
                        "Return",
                        duties
                            .where((duty) => duty["status"] == "Return")
                            .length,
                        Colors.blue),
                    _buildStatusItem(
                        "Approve",
                        duties
                            .where((duty) => duty["status"] == "Approve")
                            .length,
                        Colors.green),
                    _buildStatusItem(
                        "Reject",
                        duties
                            .where((duty) => duty["status"] == "Reject")
                            .length,
                        Colors.red),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      "All Duty in 2024",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Filter and Search Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Filter Button
                        ElevatedButton.icon(
                          onPressed: () {
                            _openFilterModal(context);
                          },
                          icon: const Icon(Icons.filter_list),
                          label: const Text("Filter"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                          ),
                        ),

                        // Dropdown and Search
                        Row(
                          children: [
                            DropdownButton<String>(
                              value: recordsPerPage.toString(),
                              onChanged: (value) {
                                setState(() {
                                  recordsPerPage = int.parse(value!);
                                  currentPage = 1; // reset
                                });
                              },
                              items: const [
                                DropdownMenuItem(
                                  value: "10",
                                  child: Text("10"),
                                ),
                                DropdownMenuItem(
                                  value: "25",
                                  child: Text("25"),
                                ),
                                DropdownMenuItem(
                                  value: "50",
                                  child: Text("50"),
                                ),
                                DropdownMenuItem(
                                  value: "100",
                                  child: Text("100"),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 150,
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    searchQuery = value;
                                    filterDuties();
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
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Duty List
                    Column(
                      children: visibleDuties.map((duty) {
                        return _buildMobileDutyCard(
                          description: duty["description"],
                          date: duty["date"],
                          status: duty["status"],
                          startTime: duty["startTime"],
                          endTime: duty["endTime"],
                          rejectionReason: duty["rejectionReason"] ?? "",
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 10),

                    // Pagination
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Showing ${startIndex + 1} to "
                          "${endIndex > filteredDuties.length ? filteredDuties.length : endIndex} "
                          "of ${filteredDuties.length} entries",
                          style: const TextStyle(fontSize: 14),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: currentPage > 1
                                  ? () {
                                      setState(() {
                                        currentPage--;
                                      });
                                    }
                                  : null,
                              child: const Text("Previous"),
                            ),
                            Text(
                              "Page $currentPage of $totalPages",
                              style: const TextStyle(fontSize: 14),
                            ),
                            TextButton(
                              onPressed: currentPage < totalPages
                                  ? () {
                                      setState(() {
                                        currentPage++;
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
                ),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: const CustomBottomAppBar(),
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
                      value: selectedStatus,
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                          filterDuties();
                        });
                        Navigator.pop(context);
                      },
                      items: const [
                        DropdownMenuItem(
                          value: "All",
                          child: Text("All"),
                        ),
                        DropdownMenuItem(
                          value: "Approved",
                          child: Text("Approved"),
                        ),
                        DropdownMenuItem(
                          value: "Waiting",
                          child: Text("Waiting"),
                        ),
                        DropdownMenuItem(
                          value: "Rejected",
                          child: Text("Rejected"),
                        ),
                        DropdownMenuItem(
                          value: "Draft",
                          child: Text("Draft"),
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
                    filterStartDate == null
                        ? "Start Date"
                        : DateFormat('dd-MM-yyyy').format(filterStartDate!),
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
                    filterEndDate == null
                        ? "End Date"
                        : DateFormat('dd-MM-yyyy').format(filterEndDate!),
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

  /// Show sidebar status item
  Widget _buildStatusItem(String status, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              status,
              style: const TextStyle(fontSize: 14),
            ),
          ),
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
    );
  }

  /// Table row for large screens
  Widget _buildTableRow({
    required String description,
    required String date,
    required String status,
    required String startTime,
    required String endTime,
    String rejectionReason = "",
  }) {
    // Choose color
    Color statusColor = Colors.grey;
    if (status == "Approved")
      statusColor = Colors.green;
    else if (status == "Waiting")
      statusColor = Colors.orange;
    else if (status == "Returned")
      statusColor = Colors.blue;
    else if (status == "Rejected") statusColor = Colors.red;

    // Find the duty with the given details to get its unique ID
    Map<String, dynamic>? duty = duties.firstWhere(
        (duty) =>
            duty["description"] == description &&
            duty["date"] == date &&
            duty["status"] == status &&
            duty["startTime"] == startTime &&
            duty["endTime"] == endTime,
        orElse: () => {});

    // If duty not found, do not build the row
    if (duty.isEmpty) {
      return Container();
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DutyDetailScreen(duty: duty, allDuties: duties),
          ),
        ).then((_) {
          setState(() {});
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
          ),
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Keterangan with time range
            Expanded(
              flex: 3,
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
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Tanggal Tugas
            Expanded(
              flex: 2,
              child: Text(
                _formatDate(date),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            // Status
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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

  /// Sortable column for large screens
  Widget _buildSortableColumn(String title, String columnKey) {
    return Expanded(
      flex: columnKey == "description" ? 3 : 2, // Adjust flex based on column
      child: InkWell(
        onTap: () => sortDuties(columnKey),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Icon(
              sortColumn == columnKey
                  ? (ascending ? Icons.arrow_upward : Icons.arrow_downward)
                  : Icons.unfold_more, // default icon
              size: 16,
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

  /// Card-like duty item for mobile screens
  Widget _buildMobileDutyCard({
    required String description,
    required String date,
    required String status,
    required String startTime,
    required String endTime,
    String rejectionReason = "",
  }) {
    // Choose color
    Color statusColor = Colors.grey;
    if (status == "Approved")
      statusColor = Colors.green;
    else if (status == "Waiting")
      statusColor = Colors.orange;
    else if (status == "Returned")
      statusColor = Colors.blue;
    else if (status == "Rejected") statusColor = Colors.red;

    // Find the duty with the given details to get its unique ID
    Map<String, dynamic>? duty = duties.firstWhere(
        (duty) =>
            duty["description"] == description &&
            duty["date"] == date &&
            duty["status"] == status &&
            duty["startTime"] == startTime &&
            duty["endTime"] == endTime,
        orElse: () => {});

    // If duty not found, do not build the card
    if (duty.isEmpty) {
      return Container();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DutyDetailScreen(duty: duty, allDuties: duties),
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
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
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
              // Rejection Reason for Rejected Status
              if (status == "Rejected")
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Reason: ${duty["rejectionReason"]}",
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontStyle: FontStyle.italic),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

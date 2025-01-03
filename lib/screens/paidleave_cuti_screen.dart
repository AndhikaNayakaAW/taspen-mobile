// lib/screens/paidleave_cuti_screen.dart

import 'package:flutter/material.dart';
import '../widgets/custom_bottom_app_bar.dart'; // Ensure this path is correct
import 'package:intl/intl.dart';
import 'paidleave_cuti_detail_screen.dart'; // Import detail screen
import 'create_paidleave_cuti_form.dart'; // Import create/edit form screen
import 'main_screen.dart';
import 'duty_spt_screen.dart';
import 'package:uuid/uuid.dart'; // Import UUID package

class PaidLeaveCutiScreen extends StatefulWidget {
  const PaidLeaveCutiScreen({Key? key}) : super(key: key);

  @override
  State<PaidLeaveCutiScreen> createState() => _PaidLeaveCutiScreenState();
}

class _PaidLeaveCutiScreenState extends State<PaidLeaveCutiScreen> {
  // Initialize UUID generator
  final Uuid _uuid = Uuid();

  // Dummy data for paid leaves with unique IDs
  List<Map<String, dynamic>> paidLeaves = [
    {
      "id": "1",
      "datetime": "2024-12-24 09:14:00",
      "nik": "4163",
      "nama": "andhika.nayaka",
      "jenisCuti": "IZIN SAKIT",
      "fromDate": "24 December 2024",
      "toDate": "24 December 2024",
      "status": "Returned",
      "sap": "",
      "act": "",
    },
    {
      "id": "2",
      "datetime": "2024-12-18 08:07:00",
      "nik": "4163",
      "nama": "andhika.nayaka",
      "jenisCuti": "IZIN SAKIT TANPA SERTIFIKAT",
      "fromDate": "17 December 2024",
      "toDate": "17 December 2024",
      "status": "Wait Approve Approval",
      "sap": "",
      "act": "",
    },
    {
      "id": "3",
      "datetime": "2024-12-04 14:57:00",
      "nik": "4163",
      "nama": "andhika.nayaka",
      "jenisCuti": "IZIN SAKIT OPNAME",
      "fromDate": "27 December 2024",
      "toDate": "27 December 2024",
      "status": "Approved",
      "sap": "YES",
      "act": "",
    },
    {
      "id": "4",
      "datetime": "2024-09-02 16:08:00",
      "nik": "4163",
      "nama": "andhika.nayaka",
      "jenisCuti": "IZIN IBADAH",
      "fromDate": "14 October 2024",
      "toDate": "16 October 2024",
      "status": "Approved",
      "sap": "YES",
      "act": "",
    },
    {
      "id": "5",
      "datetime": "2024-02-24 14:27:00",
      "nik": "4163",
      "nama": "andhika.nayaka",
      "jenisCuti": "IZIN SAKIT",
      "fromDate": "26 February 2024",
      "toDate": "26 February 2024",
      "status": "Approved",
      "sap": "YES",
      "act": "",
    },
    {
      "id": "6",
      "datetime": "2024-02-07 16:48:00",
      "nik": "4163",
      "nama": "andhika.nayaka",
      "jenisCuti": "IZIN SAKIT TANPA SERTIFIKAT",
      "fromDate": "04 March 2024",
      "toDate": "08 March 2024",
      "status": "Approved",
      "sap": "YES",
      "act": "",
    },
    {
      "id": "7",
      "datetime": "2024-01-04 09:19:00",
      "nik": "4163",
      "nama": "andhika.nayaka",
      "jenisCuti": "IZIN SAKIT OPNAME",
      "fromDate": "22 January 2024",
      "toDate": "24 January 2024",
      "status": "Approved",
      "sap": "YES",
      "act": "",
    },
    {
      "id": "8",
      "datetime": "2023-11-10 05:51:00",
      "nik": "4163",
      "nama": "andhika.nayaka",
      "jenisCuti": "IZIN SAKIT TANPA SERTIFIKAT",
      "fromDate": "10 November 2023",
      "toDate": "10 November 2023",
      "status": "Approved",
      "sap": "NO ",
      "act": "Kirim SAP",
    },
    {
      "id": "9",
      "datetime": "2022-11-28 08:36:00",
      "nik": "4163",
      "nama": "andhika.nayaka",
      "jenisCuti": "IZIN SAKIT",
      "fromDate": "12 December 2022",
      "toDate": "12 December 2022",
      "status": "Approved",
      "sap": "YES",
      "act": "",
    },
    // Additional entries to make total 15 data
    {
      "id": "10",
      "datetime": "2024-05-01 10:00:00",
      "nik": "4163",
      "nama": "andhika.nayaka",
      "jenisCuti": "IZIN SAKIT",
      "fromDate": "01 May 2024",
      "toDate": "02 May 2024",
      "status": "Draft",
      "sap": "",
      "act": "",
    },
    {
      "id": "11",
      "datetime": "2024-06-12 09:30:00",
      "nik": "4163",
      "nama": "andhika.nayaka",
      "jenisCuti": "IZIN IBADAH",
      "fromDate": "12 June 2024",
      "toDate": "12 June 2024",
      "status": "Draft",
      "sap": "",
      "act": "",
    },
    {
      "id": "12",
      "datetime": "2024-07-25 08:15:00",
      "nik": "4163",
      "nama": "andhika.nayaka",
      "jenisCuti": "IZIN SAKIT TANPA SERTIFIKAT",
      "fromDate": "25 July 2024",
      "toDate": "25 July 2024",
      "status": "Waiting",
      "sap": "",
      "act": "",
    },
    {
      "id": "13",
      "datetime": "2024-08-20 13:40:00",
      "nik": "4163",
      "nama": "andhika.nayaka",
      "jenisCuti": "IZIN SAKIT OPNAME",
      "fromDate": "20 August 2024",
      "toDate": "23 August 2024",
      "status": "Returned",
      "sap": "",
      "act": "",
    },
    {
      "id": "14",
      "datetime": "2023-12-10 07:55:00",
      "nik": "4163",
      "nama": "andhika.nayaka",
      "jenisCuti": "IZIN IBADAH",
      "fromDate": "10 December 2023",
      "toDate": "10 December 2023",
      "status": "Approved",
      "sap": "YES",
      "act": "",
    },
    {
      "id": "15",
      "datetime": "2023-10-05 15:00:00",
      "nik": "4163",
      "nama": "andhika.nayaka",
      "jenisCuti": "IZIN SAKIT TANPA SERTIFIKAT",
      "fromDate": "05 October 2023",
      "toDate": "06 October 2023",
      "status": "Rejected",
      "sap": "",
      "act": "",
    },
  ];

  // Variables for filtering, sorting, and pagination
  String sortColumn = "datetime"; // Initialized to 'datetime'
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
    filterPaidLeaves(); // Apply initial filter
  }

  /// Filters the paid leaves based on search query, selected status, and date range
  void filterPaidLeaves() {
    setState(() {
      // Apply filtering
      List<Map<String, dynamic>> tempFiltered = paidLeaves.where((leave) {
        bool matchesSearch = leave["jenisCuti"]
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            leave["nama"]
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            leave["status"]
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase());

        bool matchesStatus = selectedStatus == "All"
            ? true
            : leave["status"].toString().toLowerCase() == selectedStatus.toLowerCase();

        bool matchesStartDate = filterStartDate == null
            ? true
            : _parseDate(leave["fromDate"]).isAfter(
                filterStartDate!.subtract(const Duration(days: 1)),
              );

        bool matchesEndDate = filterEndDate == null
            ? true
            : _parseDate(leave["toDate"]).isBefore(
                filterEndDate!.add(const Duration(days: 1)),
              );

        return matchesSearch && matchesStatus && matchesStartDate && matchesEndDate;
      }).toList();

      // Apply sorting
      tempFiltered.sort((a, b) {
        var aValue = a[sortColumn];
        var bValue = b[sortColumn];
        if (sortColumn == "datetime" ||
            sortColumn == "fromDate" ||
            sortColumn == "toDate") {
          DateTime aDate = _parseDateTimeOrDate(aValue);
          DateTime bDate = _parseDateTimeOrDate(bValue);
          return ascending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
        } else {
          return ascending
              ? aValue.toString().compareTo(bValue.toString())
              : bValue.toString().compareTo(aValue.toString());
        }
      });

      // Update filtered list
      filteredPaidLeaves = tempFiltered;

      // Reset to first page if current page exceeds total pages
      int totalPages = (filteredPaidLeaves.length / recordsPerPage).ceil();
      if (currentPage > totalPages && totalPages > 0) {
        currentPage = totalPages;
      }
    });
  }

  /// Sorts the paid leaves based on the selected column
  void sortPaidLeaves(String columnKey) {
    setState(() {
      if (sortColumn == columnKey) {
        ascending = !ascending;
      } else {
        sortColumn = columnKey;
        ascending = true;
      }
      filterPaidLeaves(); // Re-apply filter after sorting
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
          if (filterEndDate != null && filterStartDate!.isAfter(filterEndDate!)) {
            filterEndDate = null;
          }
        } else {
          filterEndDate = picked;
          // Ensure end date is after start date
          if (filterStartDate != null && filterEndDate!.isBefore(filterStartDate!)) {
            filterStartDate = null;
          }
        }
        filterPaidLeaves();
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
      filterPaidLeaves();
    });
  }

  /// Helper method to parse date from "dd MMMM yyyy" or "yyyy-MM-dd" to DateTime
  DateTime _parseDate(String dateStr) {
    try {
      return DateFormat('dd MMMM yyyy').parse(dateStr);
    } catch (e) {
      try {
        return DateFormat('yyyy-MM-dd').parse(dateStr);
      } catch (e) {
        return DateTime.now();
      }
    }
  }

  /// Helper method to parse datetime or date
  DateTime _parseDateTimeOrDate(dynamic value) {
    if (value is String) {
      // Try parsing as datetime
      try {
        return DateFormat('yyyy-MM-dd HH:mm:ss').parse(value);
      } catch (e) {
        // If fails, try as date
        try {
          return _parseDate(value);
        } catch (e) {
          return DateTime.now();
        }
      }
    } else if (value is DateTime) {
      return value;
    } else {
      return DateTime.now();
    }
  }

  // Filtered list after applying search, filter, and sort
  List<Map<String, dynamic>> filteredPaidLeaves = [];

  @override
  Widget build(BuildContext context) {
    // Calculate pagination
    int totalPages = (filteredPaidLeaves.length / recordsPerPage).ceil();
    int startIndex = (currentPage - 1) * recordsPerPage;
    int endIndex = startIndex + recordsPerPage;
    if (endIndex > filteredPaidLeaves.length) endIndex = filteredPaidLeaves.length;
    List<Map<String, dynamic>> visibleLeaves =
        filteredPaidLeaves.sublist(startIndex, endIndex);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Paid Leave/Cuti"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner and Main Content
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isDesktop = constraints.maxWidth > 600;
                return isDesktop
                    ? Row(
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
                                visibleLeaves,
                                filteredPaidLeaves.length,
                                startIndex,
                                endIndex,
                                totalPages,
                                isMobile: false,
                              ),
                            ),
                          ),
                        ],
                      )
                    : SingleChildScrollView(
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
                                visibleLeaves,
                                filteredPaidLeaves.length,
                                startIndex,
                                endIndex,
                                totalPages,
                                isMobile: true,
                              ),
                            ),
                          ],
                        ),
                      );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomAppBar(),
    );
  }

  /// Sidebar widget displaying different statuses and counts
  Widget _buildSidebar() {
    final allCount = paidLeaves.length;
    final draftCount = paidLeaves
        .where((leave) =>
            (leave["status"] ?? "").toString().toLowerCase() == "draft")
        .length;
    final waitingCount = paidLeaves
        .where((leave) =>
            (leave["status"] ?? "").toString().toLowerCase() == "waiting")
        .length;
    final approvedCount = paidLeaves
        .where((leave) =>
            (leave["status"] ?? "").toString().toLowerCase() == "approved")
        .length;
    final rejectedCount = paidLeaves
        .where((leave) =>
            (leave["status"] ?? "").toString().toLowerCase() == "rejected")
        .length;
    final returnedCount = paidLeaves
        .where((leave) =>
            (leave["status"] ?? "").toString().toLowerCase() == "returned")
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
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreatePaidLeaveCutiForm(
                      paidLeaves: paidLeaves,
                    ),
                  ),
                );

                if (result != null && result is Map<String, dynamic>) {
                  setState(() {
                    // Check if it's an update or a new entry
                    int existingIndex = paidLeaves.indexWhere(
                        (leave) => leave["id"] == result["id"]);
                    if (existingIndex != -1) {
                      // Update existing leave
                      paidLeaves[existingIndex] = result;
                    } else {
                      // Add new leave
                      paidLeaves.add(result);
                    }
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Paid Leave/Cuti Added Successfully!")),
                  );
                }
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
            _buildStatusItem("Returned", returnedCount, Colors.blue),
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
            const Divider(),
            const SizedBox(height: 20),

            // Leave Quota Section (Optional, you can customize it)
            const Text(
              "LEAVE QUOTA",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildQuotaItem("Quota Cuti Tahunan", 10, 5),
            _buildQuotaItem("Quota Cuti Alasan Penting", 5, 2),
            _buildQuotaItem("Quota Cuti Sakit", 15, 10),
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
          selectedStatus = status;
          currentPage = 1;
          filterPaidLeaves();
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                status,
                style: TextStyle(
                  color: selectedStatus == status ? Colors.teal : Colors.black,
                  fontWeight:
                      selectedStatus == status ? FontWeight.bold : FontWeight.normal,
                ),
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
      ),
    );
  }

  /// Widget for each leave quota item in the sidebar
  Widget _buildQuotaItem(String label, int totalQuota, int usedQuota) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Expanded(
            child: Text(label),
          ),
          Text("$usedQuota/$totalQuota"),
        ],
      ),
    );
  }

  /// Builds the main card section with the list of paid leaves
  Widget _buildCardSection(
    List<Map<String, dynamic>> visibleLeaves,
    int totalCount,
    int startIndex,
    int endIndex,
    int totalPages, {
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Title
        Text(
          selectedStatus == "All"
              ? "All Paid Leaves in 2024"
              : "All $selectedStatus Paid Leaves in 2024",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // Filter and Sort Controls
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value!;
                              currentPage = 1;
                              filterPaidLeaves();
                            });
                          },
                          isExpanded: true,
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
                            DropdownMenuItem(
                              value: "Wait Approve Approval", // Added to match dummy data
                              child: Text("Wait Approve Approval"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Sort Controls
                  Row(
                    children: [
                      const Text(
                        "Sort by:",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<String>(
                          value: sortColumn,
                          onChanged: (value) {
                            if (value != null) {
                              sortPaidLeaves(value);
                            }
                          },
                          isExpanded: true,
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
                            DropdownMenuItem(
                              value: "nama",
                              child: Text("Nama"),
                            ),
                            DropdownMenuItem(
                              value: "datetime",
                              child: Text("Date and Time"),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          ascending ? Icons.arrow_upward : Icons.arrow_downward,
                        ),
                        onPressed: () {
                          setState(() {
                            ascending = !ascending;
                            sortPaidLeaves(sortColumn);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              )
            : Row(
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
                            currentPage = 1;
                            filterPaidLeaves();
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
                          DropdownMenuItem(
                            value: "Wait Approve Approval", // Added to match dummy data
                            child: Text("Wait Approve Approval"),
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
                        value: sortColumn,
                        onChanged: (value) {
                          if (value != null) {
                            sortPaidLeaves(value);
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
                          DropdownMenuItem(
                            value: "nama",
                            child: Text("Nama"),
                          ),
                          DropdownMenuItem(
                            value: "datetime",
                            child: Text("Date and Time"),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          ascending ? Icons.arrow_upward : Icons.arrow_downward,
                        ),
                        onPressed: () {
                          setState(() {
                            ascending = !ascending;
                            sortPaidLeaves(sortColumn);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),

        const SizedBox(height: 10),

        // Search and Records Per Page
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Records Per Page
                  DropdownButton<String>(
                    value: recordsPerPage.toString(),
                    onChanged: (value) {
                      setState(() {
                        recordsPerPage = int.parse(value!);
                        currentPage = 1; // reset
                        filterPaidLeaves();
                      });
                    },
                    isExpanded: true,
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
                  const SizedBox(height: 10),
                  // Search Field
                  SizedBox(
                    width: double.infinity,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                          filterPaidLeaves();
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
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Records Per Page
                  DropdownButton<String>(
                    value: recordsPerPage.toString(),
                    onChanged: (value) {
                      setState(() {
                        recordsPerPage = int.parse(value!);
                        currentPage = 1; // reset
                        filterPaidLeaves();
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
                          searchQuery = value;
                          filterPaidLeaves();
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

        // Paid Leave/Cuti Cards
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleLeaves.length,
          itemBuilder: (context, index) {
            final leave = visibleLeaves[index];
            return _buildPaidLeaveCard(leave);
          },
        ),

        const SizedBox(height: 10),

        // Pagination
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Showing ${startIndex + 1} to "
              "${endIndex > filteredPaidLeaves.length ? filteredPaidLeaves.length : endIndex} "
              "of ${filteredPaidLeaves.length} entries",
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
    );
  }

  /// Card-like leave item for both desktop and mobile
  Widget _buildPaidLeaveCard(Map<String, dynamic> leave) {
    // Determine status color
    Color statusColor;
    switch (leave["status"].toString().toLowerCase()) {
      case "draft":
        statusColor = Colors.grey;
        break;
      case "waiting":
      case "wait approve approval":
        statusColor = Colors.orange;
        break;
      case "returned":
        statusColor = Colors.blue;
        break;
      case "approved":
        statusColor = Colors.green;
        break;
      case "rejected":
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 2,
      child: InkWell(
        onTap: () async {
          // Navigate to PaidLeaveCutiDetailScreen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaidLeaveCutiDetailScreen(
                paidLeave: leave,
                allPaidLeaves: paidLeaves,
              ),
            ),
          );

          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              // Find the index based on 'id'
              int updatedIndex =
                  paidLeaves.indexWhere((l) => l["id"] == result["id"]);
              if (updatedIndex != -1) {
                paidLeaves[updatedIndex] = result;
              }
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Paid Leave/Cuti Updated Successfully!")),
            );
          }
          // If result is null, it might have been deleted; handle accordingly if needed
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Jenis Cuti and Nama
              Text(
                "${leave["jenisCuti"]} by ${leave["nama"]}",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              // NIK and Submission Date/Time
              Text(
                "NIK: ${leave["nik"]} | Submitted: ${_formatDateTime(leave["datetime"])}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              // Date Range
              Row(
                children: [
                  const Icon(Icons.date_range, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "From ${_formatDate(leave["fromDate"])} To ${_formatDate(leave["toDate"])}",
                      style:
                          const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Status and SAP/Act
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status
                  Container(
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Text(
                      leave["status"],
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                  // SAP and Act
                  Wrap(
                    spacing: 4.0,
                    runSpacing: -8.0,
                    children: [
                      if (leave["sap"].trim().isNotEmpty)
                        Chip(
                          label: Text("SAP: ${leave["sap"]}"),
                          backgroundColor: Colors.blue.shade100,
                        ),
                      if (leave["act"].trim().isNotEmpty)
                        Chip(
                          label: Text("Act: ${leave["act"]}"),
                          backgroundColor: Colors.orange.shade100,
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method to format datetime from "yyyy-MM-dd HH:mm:ss" to "dd-MM-yyyy HH:mm"
  String _formatDateTime(String datetime) {
    try {
      DateTime parsedDate = DateTime.parse(datetime);
      return DateFormat('dd-MM-yyyy HH:mm').format(parsedDate);
    } catch (e) {
      return datetime;
    }
  }

  /// Helper method to format date from "dd MMMM yyyy" or "yyyy-MM-dd" to "dd-MM-yyyy"
  String _formatDate(String date) {
    try {
      DateTime parsedDate = _parseDate(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }
}

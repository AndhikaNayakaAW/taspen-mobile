// lib/screens/paidleave_cuti_screen.dart

import 'package:flutter/material.dart';
import '../widgets/custom_bottom_app_bar.dart'; // Ensure the path is correct
import 'package:intl/intl.dart';
// import 'paidleave_detail_screen.dart'; // Create this screen for detail view
// import 'create_paid_leave_form.dart'; // Create this screen for creating leave forms

class PaidLeaveCutiScreen extends StatefulWidget {
  const PaidLeaveCutiScreen({Key? key}) : super(key: key);

  @override
  State<PaidLeaveCutiScreen> createState() => _PaidLeaveCutiScreenState();
}

class _PaidLeaveCutiScreenState extends State<PaidLeaveCutiScreen> {
  // Sample data for paid leaves
  List<Map<String, dynamic>> paidLeaves = [
    {
      "datetime": "2024-12-24 09:14:00",
      "nik": "4163",
      "nama": "PRITA NUR RIZKY FARIDIANI",
      "jenisCuti": "IZIN SAKIT",
      "fromDate": "24 December 2024",
      "toDate": "24 December 2024",
      "status": "Returned",
      "sap": "",
      "act": "",
    },
    {
      "datetime": "2024-12-18 08:07:00",
      "nik": "4163",
      "nama": "PRITA NUR RIZKY FARIDIANI",
      "jenisCuti": "IZIN SAKIT TANPA SERTIFIKAT",
      "fromDate": "17 December 2024",
      "toDate": "17 December 2024",
      "status": "Wait Approve Approval",
      "sap": "",
      "act": "",
    },
    {
      "datetime": "2024-12-04 14:57:00",
      "nik": "4163",
      "nama": "PRITA NUR RIZKY FARIDIANI",
      "jenisCuti": "IZIN SAKIT OPNAME",
      "fromDate": "27 December 2024",
      "toDate": "27 December 2024",
      "status": "Approved",
      "sap": "YES",
      "act": "",
    },
    {
      "datetime": "2024-09-02 16:08:00",
      "nik": "4163",
      "nama": "PRITA NUR RIZKY FARIDIANI",
      "jenisCuti": "IZIN IBADAH",
      "fromDate": "14 October 2024",
      "toDate": "16 October 2024",
      "status": "Approved",
      "sap": "YES",
      "act": "",
    },
    {
      "datetime": "2024-02-24 14:27:00",
      "nik": "4163",
      "nama": "PRITA NUR RIZKY FARIDIANI",
      "jenisCuti": "IZIN SAKIT",
      "fromDate": "26 February 2024",
      "toDate": "26 February 2024",
      "status": "Approved",
      "sap": "YES",
      "act": "",
    },
    {
      "datetime": "2024-02-07 16:48:00",
      "nik": "4163",
      "nama": "PRITA NUR RIZKY FARIDIANI",
      "jenisCuti": "IZIN SAKIT TANPA SERTIFIKAT",
      "fromDate": "04 March 2024",
      "toDate": "08 March 2024",
      "status": "Approved",
      "sap": "YES",
      "act": "",
    },
    {
      "datetime": "2024-01-04 09:19:00",
      "nik": "4163",
      "nama": "PRITA NUR RIZKY FARIDIANI",
      "jenisCuti": "IZIN SAKIT OPNAME",
      "fromDate": "22 January 2024",
      "toDate": "24 January 2024",
      "status": "Approved",
      "sap": "YES",
      "act": "",
    },
    {
      "datetime": "2023-11-10 05:51:00",
      "nik": "4163",
      "nama": "PRITA NUR RIZKY FARIDIANI",
      "jenisCuti": "IZIN SAKIT TANPA SERTIFIKAT",
      "fromDate": "10 November 2023",
      "toDate": "10 November 2023",
      "status": "Approved",
      "sap": "NO ",
      "act": "Kirim SAP",
    },
    {
      "datetime": "2022-11-28 08:36:00",
      "nik": "4163",
      "nama": "PRITA NUR RIZKY FARIDIANI",
      "jenisCuti": "IZIN SAKIT",
      "fromDate": "12 December 2022",
      "toDate": "12 December 2022",
      "status": "Approved",
      "sap": "YES",
      "act": "",
    },

    // Tambahan agar total 15 data
    {
      "datetime": "2024-05-01 10:00:00",
      "nik": "4163",
      "nama": "PRITA NUR RIZKY FARIDIANI",
      "jenisCuti": "IZIN SAKIT",
      "fromDate": "01 May 2024",
      "toDate": "02 May 2024",
      "status": "Draft",
      "sap": "",
      "act": "",
    },
    {
      "datetime": "2024-06-12 09:30:00",
      "nik": "4163",
      "nama": "PRITA NUR RIZKY FARIDIANI",
      "jenisCuti": "IZIN IBADAH",
      "fromDate": "12 June 2024",
      "toDate": "12 June 2024",
      "status": "Draft",
      "sap": "",
      "act": "",
    },
    {
      "datetime": "2024-07-25 08:15:00",
      "nik": "4163",
      "nama": "PRITA NUR RIZKY FARIDIANI",
      "jenisCuti": "IZIN SAKIT TANPA SERTIFIKAT",
      "fromDate": "25 July 2024",
      "toDate": "25 July 2024",
      "status": "Waiting",
      "sap": "",
      "act": "",
    },
    {
      "datetime": "2024-08-20 13:40:00",
      "nik": "4163",
      "nama": "PRITA NUR RIZKY FARIDIANI",
      "jenisCuti": "IZIN SAKIT OPNAME",
      "fromDate": "20 August 2024",
      "toDate": "23 August 2024",
      "status": "Returned",
      "sap": "",
      "act": "",
    },
    {
      "datetime": "2023-12-10 07:55:00",
      "nik": "4163",
      "nama": "PRITA NUR RIZKY FARIDIANI",
      "jenisCuti": "IZIN IBADAH",
      "fromDate": "10 December 2023",
      "toDate": "10 December 2023",
      "status": "Approved",
      "sap": "YES",
      "act": "",
    },
    {
      "datetime": "2023-10-05 15:00:00",
      "nik": "4163",
      "nama": "PRITA NUR RIZKY FARIDIANI",
      "jenisCuti": "IZIN SAKIT TANPA SERTIFIKAT",
      "fromDate": "05 October 2023",
      "toDate": "06 October 2023",
      "status": "Rejected",
      "sap": "",
      "act": "",
    },
  ];

  // Variables for filtering, sorting, and pagination
  List<Map<String, dynamic>> filteredPaidLeaves = [];
  String sortColumn = "datetime";
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
    filteredPaidLeaves = paidLeaves; // Display all data initially
  }

  /// Filters the paid leaves based on search query, selected status, and date range
  void filterPaidLeaves() {
    setState(() {
      filteredPaidLeaves = paidLeaves.where((leave) {
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
            : leave["status"].toString() == selectedStatus;

        bool matchesStartDate = filterStartDate == null
            ? true
            : _parseDate(leave["fromDate"]).isAfter(
                filterStartDate!.subtract(const Duration(days: 1)));

        bool matchesEndDate = filterEndDate == null
            ? true
            : _parseDate(leave["toDate"]).isBefore(
                filterEndDate!.add(const Duration(days: 1)));

        return matchesSearch && matchesStatus && matchesStartDate && matchesEndDate;
      }).toList();

      currentPage = 1; // Reset to first page on filter
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
      filteredPaidLeaves.sort((a, b) {
        var aValue = a[columnKey];
        var bValue = b[columnKey];
        if (columnKey == "datetime" ||
            columnKey == "fromDate" ||
            columnKey == "toDate") {
          DateTime aDate = _parseDate(aValue);
          DateTime bDate = _parseDate(bValue);
          return ascending
              ? aDate.compareTo(bDate)
              : bDate.compareTo(aDate);
        } else {
          return ascending
              ? aValue.toString().compareTo(bValue.toString())
              : bValue.toString().compareTo(aValue.toString());
        }
      });
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
                          filterPaidLeaves();
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
                  Expanded(
                    child: Text(
                      filterStartDate == null
                          ? "Start Date"
                          : DateFormat('dd-MM-yyyy').format(filterStartDate!),
                      style: const TextStyle(fontSize: 16),
                    ),
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
                  Expanded(
                    child: Text(
                      filterEndDate == null
                          ? "End Date"
                          : DateFormat('dd-MM-yyyy').format(filterEndDate!),
                      style: const TextStyle(fontSize: 16),
                    ),
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


  /// Helper method to format date from "dd MMMM yyyy" to DateTime
  DateTime _parseDate(String dateStr) {
    try {
      return DateFormat('dd MMMM yyyy').parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

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
      // Removed appBar and drawer to eliminate Navbar and hamburger button

      body: LayoutBuilder(
        builder: (context, constraints) {
          // Large screens (Desktop/Tablet)
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
                        // Create Leave Form Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                          ),
                          onPressed: () {
                            // TODO: Implement navigation to Create Leave Form
                            /*
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CreatePaidLeaveForm(),
                              ),
                            ).then((_) {
                              setState(() {
                                filterPaidLeaves();
                              });
                            });
                            */
                            // Since CreatePaidLeaveForm is not yet created, show a snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("CreatePaidLeaveForm screen not implemented yet."),
                              ),
                            );
                          },
                          child: const Text("Create Leave Form"),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "ALL LEAVE",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        _buildStatusItem("All", filteredPaidLeaves.length, Colors.teal),
                        const Divider(),
                        const Text(
                          "AS A CONCEPTOR / MAKER",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        _buildStatusItem(
                            "Draft",
                            paidLeaves.where((leave) => leave["status"] == "Draft").length,
                            Colors.grey),
                        _buildStatusItem(
                          "Waiting",
                          paidLeaves.where((leave) => leave["status"] == "Waiting").length,
                          Colors.orange,
                        ),
                        _buildStatusItem(
                          "Returned",
                          paidLeaves.where((leave) => leave["status"] == "Returned").length,
                          Colors.blue,
                        ),
                        _buildStatusItem(
                          "Approved",
                          paidLeaves.where((leave) => leave["status"] == "Approved").length,
                          Colors.green,
                        ),
                        _buildStatusItem(
                          "Rejected",
                          paidLeaves.where((leave) => leave["status"] == "Rejected").length,
                          Colors.red,
                        ),
                        const Divider(),
                        const Text(
                          "AS AN APPROVAL",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        _buildStatusItem("Need Approve", 0, Colors.orange),
                        _buildStatusItem("Return", 0, Colors.blue),
                        _buildStatusItem("Approve", 0, Colors.green),
                        _buildStatusItem("Reject", 0, Colors.red),
                        const Divider(),
                        const SizedBox(height: 20),

                        // Leave Quota Section
                        const Text(
                          "LEAVE QUOTA",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        _buildQuotaItem("Quota Cuti Tahunan", 10, 5),
                        _buildQuotaItem("Quota Cuti Alasan Penting", 5, 2),
                        _buildQuotaItem("Quota Cuti Sakit", 15, 10),
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
                          "All Paid Leaves in 2024",
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
                                      filterPaidLeaves();
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
                                const SizedBox(width: 10),
                                // End Date
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
                            // Records Per Page Dropdown
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

                        // List of Cards
                        Expanded(
                          child: ListView.builder(
                            itemCount: visibleLeaves.length,
                            itemBuilder: (context, index) {
                              final leave = visibleLeaves[index];
                              return _buildLeaveCard(leave);
                            },
                          ),
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
                    ),
                  ),
                ),
                ],
              );
          } else {
            // Mobile Layout
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sidebar (Displayed on top for mobile)
                    Container(
                      width: double.infinity,
                      color: const Color(0xFFf8f9fa),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Request Paid Leave Status",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                            ),
                            onPressed: () {
                              // TODO: Implement navigation to Create Leave Form
                              /*
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CreatePaidLeaveForm(),
                                ),
                              ).then((_) {
                                setState(() {
                                  filterPaidLeaves();
                                });
                              });
                              */
                              // Since CreatePaidLeaveForm is not yet created, show a snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("CreatePaidLeaveForm screen not implemented yet."),
                                ),
                              );
                            },
                            child: const Text("Create Leave Form"),
                          ),
                          const SizedBox(height: 20),
                          const Text("All leave",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          _buildStatusItem("All", filteredPaidLeaves.length, Colors.teal),
                          const SizedBox(height: 20),
                          const Text("As A Conceptor / Maker",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          _buildStatusItem(
                            "Draft",
                            paidLeaves.where((leave) => leave["status"] == "Draft").length,
                            Colors.grey,
                          ),
                          _buildStatusItem(
                            "Waiting",
                            paidLeaves.where((leave) => leave["status"] == "Waiting").length,
                            Colors.orange,
                          ),
                          _buildStatusItem(
                            "Returned",
                            paidLeaves.where((leave) => leave["status"] == "Returned").length,
                            Colors.blue,
                          ),
                          _buildStatusItem(
                            "Approved",
                            paidLeaves.where((leave) => leave["status"] == "Approved").length,
                            Colors.green,
                          ),
                          _buildStatusItem(
                            "Rejected",
                            paidLeaves.where((leave) => leave["status"] == "Rejected").length,
                            Colors.red,
                          ),
                          const SizedBox(height: 20),
                          const Text("As A Approval",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          _buildStatusItem("Need Approve", 0, Colors.orange),
                          _buildStatusItem("Return", 0, Colors.blue),
                          _buildStatusItem("Approve", 0, Colors.green),
                          _buildStatusItem("Reject", 0, Colors.red),
                          const SizedBox(height: 20),

                          // Leave Quota Section
                          const Text(
                            "LEAVE QUOTA",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          _buildQuotaItem("Quota Cuti Tahunan", 10, 5),
                          _buildQuotaItem("Quota Cuti Alasan Penting", 5, 2),
                          _buildQuotaItem("Quota Cuti Sakit", 15, 10),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      "All Paid Leaves in 2024",
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Filter and Search Controls
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(height: 10),

                        // Dropdown and Search
                        Row(
                          children: [
                            // Records Per Page Dropdown
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
                            // Search Field
                            Expanded(
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
                      ],
                    ),
                    const SizedBox(height: 10),

                    // List of Cards
                    Column(
                      children: visibleLeaves.map((leave) {
                        return _buildLeaveCard(leave);
                      }).toList(),
                    ),

                    const SizedBox(height: 10),

                    // Pagination
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "Showing ${startIndex + 1} to $endIndex of ${filteredPaidLeaves.length} entries"),
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
                            Text("Page $currentPage of $totalPages"),
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

/// Helper Widget: Status Item in Sidebar
Widget _buildStatusItem(String label, int count, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3.0),
    child: Row(
      children: [
        Text(label),
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
  );
}

/// Helper Widget: Leave Quota Item in Sidebar
Widget _buildQuotaItem(String label, int totalQuota, int usedQuota) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3.0),
    child: Row(
      children: [
        Text(label),
        const Spacer(),
        Text("$usedQuota/$totalQuota"),
      ],
    ),
  );
}

/// Card-like leave item for both desktop and mobile
Widget _buildLeaveCard(Map<String, dynamic> leave) {
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
      onTap: () {
        // TODO: Implement navigation to PaidLeaveDetailScreen
        /*
        final leaveData = {
          "datetime": leave["datetime"],
          "nik": leave["nik"],
          "nama": leave["nama"],
          "jenisCuti": leave["jenisCuti"],
          "fromDate": leave["fromDate"],
          "toDate": leave["toDate"],
          "status": leave["status"],
          "sap": leave["sap"],
          "act": leave["act"],
        };
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaidLeaveDetailScreen(
              leave: leaveData,
              allLeaves: paidLeaves,
            ),
          ),
        ).then((_) {
          setState(() {});
        });
        */
        // Since PaidLeaveDetailScreen is not yet created, show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("PaidLeaveDetailScreen not implemented yet."),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Text(
              "${leave["jenisCuti"]} by ${leave["nama"]}",
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            // NIK and DateTime
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
                    "From ${leave["fromDate"]} To ${leave["toDate"]}",
                    style:
                        const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Status and SAP
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
                    if (leave["sap"].isNotEmpty)
                      Chip(
                        label: Text("SAP: ${leave["sap"]}"),
                        backgroundColor: Colors.blue.shade100,
                      ),
                    if (leave["act"].isNotEmpty)
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

/// Helper method to format datetime
String _formatDateTime(String datetime) {
  try {
    DateTime parsedDate = DateTime.parse(datetime);
    return DateFormat('dd-MM-yyyy HH:mm').format(parsedDate);
  } catch (e) {
    return datetime;
  }
}
}

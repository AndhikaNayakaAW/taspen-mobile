// lib/screens/paidleave_cuti_screen.dart

import 'package:flutter/material.dart';
import '../widgets/custom_bottom_app_bar.dart'; // Ensure the path is correct
import '../widgets/navbar.dart'; // Ensure the path is correct

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
      "sap": "NO | MAKSIMAL PERUBAHAN DATA 14.11.2023",
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

  // Sorting and filtering variables
  String sortColumn = "datetime";
  bool ascending = true;
  String searchQuery = "";
  int recordsPerPage = 10; // Default records per page
  int currentPage = 1;
  List<Map<String, dynamic>> filteredPaidLeaves = [];

  @override
  void initState() {
    super.initState();
    filteredPaidLeaves = paidLeaves; // Display all data initially
  }

  // Function to filter paid leaves based on search query
  void filterPaidLeaves(String query) {
    setState(() {
      searchQuery = query;
      filteredPaidLeaves = paidLeaves.where((leave) {
        return leave["jenisCuti"]
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            leave["nama"].toString().toLowerCase().contains(query.toLowerCase()) ||
            leave["status"].toString().toLowerCase().contains(query.toLowerCase());
      }).toList();
      currentPage = 1; // Reset to first page on filter
    });
  }

  // Function to sort paid leaves based on column key
  void sortPaidLeaves(String columnKey) {
    setState(() {
      if (sortColumn == columnKey) {
        ascending = !ascending; // Toggle sort order
      } else {
        sortColumn = columnKey;
        ascending = true;
      }
      filteredPaidLeaves.sort((a, b) {
        var aValue = a[columnKey];
        var bValue = b[columnKey];
        if (aValue is String && bValue is String) {
          return ascending
              ? aValue.compareTo(bValue)
              : bValue.compareTo(aValue);
        } else if (aValue is DateTime && bValue is DateTime) {
          return ascending
              ? aValue.compareTo(bValue)
              : bValue.compareTo(aValue);
        } else {
          return 0;
        }
      });
    });
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Navbar(
          username: "andhika.nayaka",
          position: "Human Capital PT TASPEN (PERSERO)",
          notificationCount: 0,
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.teal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Welcome !! andhika.nayaka",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Human Capital PT TASPEN (PERSERO)",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Spacer(),
                  Text(
                    "0  ",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Log out"),
              onTap: () {
                // TODO: Implement logout functionality
              },
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Desktop/Tablet Layout
          if (constraints.maxWidth > 600) {
            return Row(
              children: [
                // Sidebar on the left
                SizedBox(
                  width: 250,
                  child: SingleChildScrollView(
                    child: Container(
                      color: const Color(0xFFf8f9fa),
                      padding: const EdgeInsets.all(16.0),
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
                          const SizedBox(height: 20),
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
                            },
                            child: const Text("Create Leave Form"),
                          ),
                          const SizedBox(height: 30),
                          // All Leave Section
                          const Text(
                            "All leave",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          _buildStatusItem(
                              "All", filteredPaidLeaves.length, Colors.teal),
                          const SizedBox(height: 20),
                          // As A Conceptor / Maker Section
                          const Text(
                            "As A Conceptor / Maker",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          _buildStatusItem(
                            "Draft",
                            filteredPaidLeaves
                                .where((item) => item["status"] == "Draft")
                                .length,
                            Colors.grey,
                          ),
                          _buildStatusItem(
                            "Waiting",
                            filteredPaidLeaves
                                .where((item) => item["status"] == "Waiting")
                                .length,
                            Colors.orange,
                          ),
                          _buildStatusItem(
                            "Returned",
                            filteredPaidLeaves
                                .where((item) => item["status"] == "Returned")
                                .length,
                            Colors.blue,
                          ),
                          _buildStatusItem(
                            "Approved",
                            filteredPaidLeaves
                                .where((item) => item["status"] == "Approved")
                                .length,
                            Colors.green,
                          ),
                          _buildStatusItem(
                            "Rejected",
                            filteredPaidLeaves
                                .where((item) => item["status"] == "Rejected")
                                .length,
                            Colors.red,
                          ),
                          const SizedBox(height: 20),
                          // As A Approval Section
                          const Text(
                            "As A Approval",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          _buildStatusItem("Need Approve", 0, Colors.orange),
                          _buildStatusItem("Return", 0, Colors.blue),
                          _buildStatusItem("Approve", 0, Colors.green),
                          _buildStatusItem("Reject", 0, Colors.red),
                        ],
                      ),
                    ),
                  ),
                ),
                // Main Content Area
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Controls
                        Row(
                          children: [
                            // Quota Table
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                color: const Color(0xFFf8f9fa),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Leave Type\tQuota\tUse\tRemaining",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: const [
                                        Text("Quota Cuti Alasan Penting  "),
                                        Text("12"),
                                        Text("0"),
                                        Text("12"),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: const [
                                        Text("Quota Cuti Tahunan"),
                                        Text("18"),
                                        Text("12"),
                                        Text("6"),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Records Per Page and Search
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  DropdownButton<int>(
                                    value: recordsPerPage,
                                    onChanged: (value) {
                                      setState(() {
                                        recordsPerPage = value!;
                                        currentPage = 1;
                                      });
                                    },
                                    items: const [
                                      DropdownMenuItem(
                                        value: 10,
                                        child: Text("10 records per page"),
                                      ),
                                      DropdownMenuItem(
                                        value: 25,
                                        child: Text("25 records per page"),
                                      ),
                                      DropdownMenuItem(
                                        value: 50,
                                        child: Text("50 records per page"),
                                      ),
                                      DropdownMenuItem(
                                        value: 100,
                                        child: Text("100 records per page"),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: 150,
                                    child: TextField(
                                      onChanged: filterPaidLeaves,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        hintText: "Search",
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Main Table
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: 1000, // Adjust as needed
                              child: Column(
                                children: [
                                  // Table Header
                                  Row(
                                    children: [
                                      _buildSortableHeader(
                                          "Description", "datetime", 350),
                                      _buildSortableHeader(
                                          "Status", "status", 150),
                                      _buildSortableHeader("SAP", "sap", 230),
                                      const SizedBox(
                                        width: 100,
                                        child: Text(
                                          "Act",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                      height: 2, color: Colors.black54),
                                  // Table Rows
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: visibleLeaves.length,
                                      itemBuilder: (context, index) {
                                        final item = visibleLeaves[index];
                                        return _buildTableRow(item);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Pagination Controls
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
                ),
              ],
            );
          } else {
            // Mobile Layout
            return SingleChildScrollView(
              child: Column(
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
                          },
                          child: const Text("Create Leave Form"),
                        ),
                        const SizedBox(height: 20),
                        const Text("All leave",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        _buildStatusItem(
                            "All", filteredPaidLeaves.length, Colors.teal),
                        const SizedBox(height: 20),
                        const Text("As A Conceptor / Maker",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        _buildStatusItem(
                          "Draft",
                          filteredPaidLeaves
                              .where((item) => item["status"] == "Draft")
                              .length,
                          Colors.grey,
                        ),
                        _buildStatusItem(
                          "Waiting",
                          filteredPaidLeaves
                              .where((item) => item["status"] == "Waiting")
                              .length,
                          Colors.orange,
                        ),
                        _buildStatusItem(
                          "Returned",
                          filteredPaidLeaves
                              .where((item) => item["status"] == "Returned")
                              .length,
                          Colors.blue,
                        ),
                        _buildStatusItem(
                          "Approved",
                          filteredPaidLeaves
                              .where((item) => item["status"] == "Approved")
                              .length,
                          Colors.green,
                        ),
                        _buildStatusItem(
                          "Rejected",
                          filteredPaidLeaves
                              .where((item) => item["status"] == "Rejected")
                              .length,
                          Colors.red,
                        ),
                        const SizedBox(height: 20),
                        const Text("As A Approval",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        _buildStatusItem("Need Approve", 0, Colors.orange),
                        _buildStatusItem("Return", 0, Colors.blue),
                        _buildStatusItem("Approve", 0, Colors.green),
                        _buildStatusItem("Reject", 0, Colors.red),
                      ],
                    ),
                  ),
                  // Main Content Area
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Quota and Controls
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          color: const Color(0xFFf8f9fa),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Leave Type\tQuota\tUse\tRemaining",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text("Quota Cuti Alasan Penting"),
                                  Text("12"),
                                  Text("0"),
                                  Text("12"),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text("Quota Cuti Tahunan"),
                                  Text("18"),
                                  Text("12"),
                                  Text("6"),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Records Per Page and Search
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DropdownButton<int>(
                              value: recordsPerPage,
                              onChanged: (value) {
                                setState(() {
                                  recordsPerPage = value!;
                                  currentPage = 1;
                                });
                              },
                              items: const [
                                DropdownMenuItem(
                                  value: 10,
                                  child: Text("10 records per page"),
                                ),
                                DropdownMenuItem(
                                  value: 25,
                                  child: Text("25 records per page"),
                                ),
                                DropdownMenuItem(
                                  value: 50,
                                  child: Text("50 records per page"),
                                ),
                                DropdownMenuItem(
                                  value: 100,
                                  child: Text("100 records per page"),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 150,
                              child: TextField(
                                onChanged: filterPaidLeaves,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
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
                        // Main Table
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: 1000, // Adjust as needed
                            child: Column(
                              children: [
                                // Table Header
                                Row(
                                  children: [
                                    _buildSortableHeader(
                                        "Description", "datetime", 350),
                                    _buildSortableHeader(
                                        "Status", "status", 150),
                                    _buildSortableHeader("SAP", "sap", 230),
                                    const SizedBox(
                                      width: 100,
                                      child: Text(
                                        "Act",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                    height: 2, color: Colors.black54),
                                // Table Rows
                                Column(
                                  children: visibleLeaves
                                      .map((item) => _buildTableRow(item))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Pagination Controls
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
                ],
              )
              );
            }
          },
        ),
      // Integrate the Custom Bottom App Bar
      bottomNavigationBar: const CustomBottomAppBar(),
    );
  }

  // Helper Widget: Status Item in Sidebar
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

  // Helper Widget: Sortable Table Header
  Widget _buildSortableHeader(String title, String columnKey, double width) {
    return InkWell(
      onTap: () => sortPaidLeaves(columnKey),
      child: SizedBox(
        width: width,
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Icon(
              sortColumn == columnKey
                  ? (ascending ? Icons.arrow_upward : Icons.arrow_downward)
                  : Icons.arrow_downward,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget: Table Row
  Widget _buildTableRow(Map<String, dynamic> item) {
    // Description combines datetime, NIK, name, leave type, and date range
    final descWidget = RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black),
        children: [
          TextSpan(
              text:
                  "${item["datetime"]} ${item["nik"]} | ${item["nama"]} |\n"),
          TextSpan(
            text: "${item["jenisCuti"]}\n",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
              text: "From ${item["fromDate"]} To ${item["toDate"]}"),
        ],
      ),
    );

    // Determine status color
    Color statusColor;
    switch (item["status"].toString().toLowerCase()) {
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

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          SizedBox(width: 350, child: descWidget),
          // Status
          SizedBox(
            width: 150,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(5),
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Text(
                item["status"].toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          // SAP
          SizedBox(
            width: 230,
            child: Text(item["sap"].toString()),
          ),
          // Act
          SizedBox(
            width: 100,
            child: Text(item["act"].toString()),
          ),
        ],
      ),
    );
  }
}

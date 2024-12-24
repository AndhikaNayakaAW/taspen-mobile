import 'package:flutter/material.dart';

class DutySPTScreen extends StatefulWidget {
  @override
  _DutySPTScreenState createState() => _DutySPTScreenState();
}

class _DutySPTScreenState extends State<DutySPTScreen> {
  // Dummy Data
  List<Map<String, dynamic>> duties = [
    {
      "description": "Meeting with HR",
      "date": "2024-12-24",
      "status": "Waiting",
      "startTime": "09:00:00",
      "endTime": "17:00:00"
    },
    {
      "description": "Project Discussion",
      "date": "2024-12-15",
      "status": "Approved",
      "startTime": "10:00:00",
      "endTime": "16:00:00"
    },
    {
      "description": "Annual Report Review",
      "date": "2024-11-30",
      "status": "Waiting",
      "startTime": "08:00:00",
      "endTime": "15:00:00"
    },
    {
      "description": "Client Visit",
      "date": "2024-11-29",
      "status": "Approved",
      "startTime": "11:00:00",
      "endTime": "18:00:00"
    },
    {
      "description": "Training Session",
      "date": "2024-11-20",
      "status": "Waiting",
      "startTime": "09:30:00",
      "endTime": "14:00:00"
    },
    {
      "description": "Team Meeting",
      "date": "2024-11-15",
      "status": "Approved",
      "startTime": "10:15:00",
      "endTime": "16:30:00"
    },
    {
      "description": "System Update Review",
      "date": "2024-11-10",
      "status": "Waiting",
      "startTime": "08:45:00",
      "endTime": "12:15:00"
    },
    {
      "description": "Policy Discussion",
      "date": "2024-10-25",
      "status": "Approved",
      "startTime": "09:10:00",
      "endTime": "17:10:00"
    },
    {
      "description": "Department Sync",
      "date": "2024-10-15",
      "status": "Waiting",
      "startTime": "10:00:00",
      "endTime": "12:30:00"
    },
    {
      "description": "Budget Planning",
      "date": "2024-10-01",
      "status": "Approved",
      "startTime": "08:00:00",
      "endTime": "17:00:00"
    },
    {
      "description": "IT Maintenance",
      "date": "2024-09-20",
      "status": "Waiting",
      "startTime": "09:00:00",
      "endTime": "12:00:00"
    },
    {
      "description": "Internal Audit",
      "date": "2024-09-15",
      "status": "Approved",
      "startTime": "13:00:00",
      "endTime": "15:30:00"
    },
    {
      "description": "Leadership Training",
      "date": "2024-08-25",
      "status": "Waiting",
      "startTime": "08:30:00",
      "endTime": "16:30:00"
    },
    {
      "description": "Marketing Strategy Meeting",
      "date": "2024-08-10",
      "status": "Approved",
      "startTime": "09:30:00",
      "endTime": "15:00:00"
    },
    {
      "description": "Financial Report Review",
      "date": "2024-07-15",
      "status": "Waiting",
      "startTime": "08:45:00",
      "endTime": "14:15:00"
    },
  ];

  List<Map<String, dynamic>> filteredDuties = [];
  String sortColumn = "date";
  bool ascending = true;
  String searchQuery = "";
  int recordsPerPage = 10;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    filteredDuties = duties; // Initially show all duties
  }

  void filterDuties(String query) {
    setState(() {
      searchQuery = query;
      filteredDuties = duties
          .where((duty) =>
              duty["description"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void sortDuties(String columnKey) {
    setState(() {
      if (sortColumn == columnKey) {
        ascending = !ascending;
      } else {
        sortColumn = columnKey;
        ascending = true;
      }
      duties.sort((a, b) => ascending
          ? a[columnKey].compareTo(b[columnKey])
          : b[columnKey].compareTo(a[columnKey]));
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
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.teal),
        title: const Text(
          "Request Duty Status",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // If large screen (tablet/desktop)
          if (constraints.maxWidth > 600) {
            return Row(
              children: [
                /// SIDEBAR - fixed width, bounded height
                SizedBox(
                  width: 250,
                  height: constraints.maxHeight,
                  child: SingleChildScrollView(
                    child: Container(
                      color: const Color(0xFFf8f9fa),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
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
                            onPressed: () {
                              // Add functionality for creating duty form
                            },
                            child: const Text("Create Duty Form"),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "ALL DUTY",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          _buildStatusItem("All", duties.length, Colors.teal),
                          const Divider(),
                          const Text(
                            "AS A CONCEPTOR / MAKER",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          _buildStatusItem("Draft", 0, Colors.grey),
                          _buildStatusItem(
                            "Waiting",
                            duties
                                .where((duty) => duty["status"] == "Waiting")
                                .length,
                            Colors.orange,
                          ),
                          _buildStatusItem("Returned", 0, Colors.blue),
                          _buildStatusItem(
                            "Approved",
                            duties
                                .where((duty) => duty["status"] == "Approved")
                                .length,
                            Colors.green,
                          ),
                          _buildStatusItem("Rejected", 0, Colors.red),
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
                    ),
                  ),
                ),

                /// MAIN CONTENT
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Header: records dropdown + search
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DropdownButton<String>(
                              value: recordsPerPage.toString(),
                              onChanged: (value) {
                                setState(() {
                                  recordsPerPage = int.parse(value!);
                                  currentPage = 1; // Reset to first page
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
                                onChanged: filterDuties,
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
                        // Table Headers
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildSortableColumn("Keterangan", "description"),
                              _buildSortableColumn("Tanggal Tugas", "date"),
                              _buildSortableColumn("Status", "status"),
                              _buildSortableColumn("Jam Mulai", "startTime"),
                              _buildSortableColumn("Jam Selesai", "endTime"),
                            ],
                          ),
                        ),
                        const Divider(),
                        // Table Rows
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              children: visibleDuties.map((duty) {
                                return _buildTableRow(
                                  description: duty["description"],
                                  date: duty["date"],
                                  status: duty["status"],
                                  startTime: duty["startTime"],
                                  endTime: duty["endTime"],
                                  statusColor: duty["status"] == "Approved"
                                      ? Colors.green
                                      : Colors.orange,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        // Pagination
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Showing ${startIndex + 1} to "
                              "${endIndex > filteredDuties.length ? filteredDuties.length : endIndex} "
                              "of ${filteredDuties.length} entries",
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
            // Mobile layout
            return SingleChildScrollView(
              // Scroll vertically on smaller screens
              child: Column(
                children: [
                  // Sidebar (shown above the main content in mobile)
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFf8f9fa),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                          ),
                          onPressed: () {
                            // Add functionality for creating duty form
                          },
                          child: const Text("Create Duty Form"),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "ALL DUTY",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        _buildStatusItem("All", duties.length, Colors.teal),
                        const Divider(),
                        const Text(
                          "AS A CONCEPTOR / MAKER",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        _buildStatusItem("Draft", 0, Colors.grey),
                        _buildStatusItem(
                          "Waiting",
                          duties
                              .where((duty) => duty["status"] == "Waiting")
                              .length,
                          Colors.orange,
                        ),
                        _buildStatusItem("Returned", 0, Colors.blue),
                        _buildStatusItem(
                          "Approved",
                          duties
                              .where((duty) => duty["status"] == "Approved")
                              .length,
                          Colors.green,
                        ),
                        _buildStatusItem("Rejected", 0, Colors.red),
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
                  ),

                  // Main Content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        const Text(
                          "All Duty in 2024",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Header: records dropdown + search
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DropdownButton<String>(
                              value: recordsPerPage.toString(),
                              onChanged: (value) {
                                setState(() {
                                  recordsPerPage = int.parse(value!);
                                  currentPage = 1; // Reset to first page
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
                                onChanged: filterDuties,
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
                        // Table Headers (horizontal scroll if needed)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildSortableColumn("Keterangan", "description"),
                              _buildSortableColumn("Tanggal Tugas", "date"),
                              _buildSortableColumn("Status", "status"),
                              _buildSortableColumn("Jam Mulai", "startTime"),
                              _buildSortableColumn("Jam Selesai", "endTime"),
                            ],
                          ),
                        ),
                        const Divider(),
                        // Table Rows
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            children: visibleDuties.map((duty) {
                              return _buildTableRow(
                                description: duty["description"],
                                date: duty["date"],
                                status: duty["status"],
                                startTime: duty["startTime"],
                                endTime: duty["endTime"],
                                statusColor: duty["status"] == "Approved"
                                    ? Colors.green
                                    : Colors.orange,
                              );
                            }).toList(),
                          ),
                        ),
                        // Pagination
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Showing ${startIndex + 1} to "
                              "${endIndex > filteredDuties.length ? filteredDuties.length : endIndex} "
                              "of ${filteredDuties.length} entries",
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
              ),
            );
          }
        },
      ),
    );
  }

  /// Status item (Sidebar)
  Widget _buildStatusItem(String status, int count, Color color) {
    return Row(
      children: [
        Text(status),
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
    );
  }

  /// Table Row
  Widget _buildTableRow({
    required String description,
    required String date,
    required String status,
    required String startTime,
    required String endTime,
    required Color statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // wraps content horizontally
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

  /// Sortable Column Header
  Widget _buildSortableColumn(String title, String columnKey) {
    return SizedBox(
      width: 150,
      child: InkWell(
        onTap: () => sortDuties(columnKey),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            Icon(
              sortColumn == columnKey
                  ? (ascending ? Icons.arrow_upward : Icons.arrow_downward)
                  : Icons.arrow_downward,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}


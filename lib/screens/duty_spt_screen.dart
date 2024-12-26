// lib/screens/duty_spt_screen.dart
import 'package:flutter/material.dart';
import 'create_duty_form.dart';

class DutySPTScreen extends StatefulWidget {
  @override
  _DutySPTScreenState createState() => _DutySPTScreenState();
}

class _DutySPTScreenState extends State<DutySPTScreen> {
  // Dummy Data (15 items)
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
    filteredDuties = duties; // show all initially
  }

  void filterDuties(String query) {
    setState(() {
      searchQuery = query;
      filteredDuties = duties
          .where(
            (duty) => duty["description"]!
                .toLowerCase()
                .contains(query.toLowerCase()),
          )
          .toList();
      currentPage = 1; // reset to first page on filter
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
      filterDuties(searchQuery); // re-apply filter
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
                /// SIDEBAR - fixed width
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
                              // On Desktop, also navigate to CreateDutyForm
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateDutyForm(
                                    // Pass the entire list so we can add a new draft
                                    duties: duties,
                                  ),
                                ),
                              ).then((_) {
                                // After returning, refresh
                                setState(() {
                                  filteredDuties = duties;
                                });
                              });
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
                        // Combined Horizontal Scroll for Header and Table Rows
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              // min width to accommodate all columns
                              width: 800, 
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Table Headers
                                  Row(
                                    children: [
                                      _buildSortableColumn(
                                          "Keterangan", "description"),
                                      _buildSortableColumn("Tanggal Tugas", "date"),
                                      _buildSortableColumn("Status", "status"),
                                      _buildSortableColumn(
                                          "Jam Mulai", "startTime"),
                                      _buildSortableColumn(
                                          "Jam Selesai", "endTime"),
                                    ],
                                  ),
                                  const Divider(),
                                  // Table Rows
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: visibleDuties.length,
                                      itemBuilder: (context, index) {
                                        var duty = visibleDuties[index];
                                        return _buildTableRow(
                                          description: duty["description"],
                                          date: duty["date"],
                                          status: duty["status"],
                                          startTime: duty["startTime"],
                                          endTime: duty["endTime"],
                                          statusColor:
                                              duty["status"] == "Approved"
                                                  ? Colors.green
                                                  : (duty["status"] == "Waiting"
                                                      ? Colors.orange
                                                      : Colors.grey),
                                        );
                                      },
                                    ),
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
              child: Column(
                children: [
                  // Sidebar (above main content)
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
                              vertical: 10,
                              horizontal: 20,
                            ),
                          ),
                          onPressed: () {
                            // Go to CreateDutyForm on mobile
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateDutyForm(
                                  duties: duties, // pass entire list
                                ),
                              ),
                            ).then((_) {
                              // Refresh after returning
                              setState(() {
                                filteredDuties = duties;
                              });
                            });
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

                  // Main Content (table, etc.)
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
                                  currentPage = 1;
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
                        // Horizontal scroll for table
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: 800,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Table Headers
                                Row(
                                  children: [
                                    _buildSortableColumn(
                                        "Keterangan", "description"),
                                    _buildSortableColumn("Tanggal Tugas", "date"),
                                    _buildSortableColumn("Status", "status"),
                                    _buildSortableColumn(
                                        "Jam Mulai", "startTime"),
                                    _buildSortableColumn(
                                        "Jam Selesai", "endTime"),
                                  ],
                                ),
                                const Divider(),
                                // Table Rows
                                Column(
                                  children: visibleDuties.map((duty) {
                                    return _buildTableRow(
                                      description: duty["description"],
                                      date: duty["date"],
                                      status: duty["status"],
                                      startTime: duty["startTime"],
                                      endTime: duty["endTime"],
                                      statusColor: duty["status"] == "Approved"
                                          ? Colors.green
                                          : (duty["status"] == "Waiting"
                                              ? Colors.orange
                                              : Colors.grey),
                                    );
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
          children: [
            Text(title),
            const SizedBox(width: 4),
            Icon(
              sortColumn == columnKey
                  ? (ascending ? Icons.arrow_upward : Icons.arrow_downward)
                  : Icons.arrow_downward, // default
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

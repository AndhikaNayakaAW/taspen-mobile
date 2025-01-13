// lib/screens/duty_spt_screen.dart

import 'package:flutter/material.dart';
import 'package:mobileapp/dto/base_response.dart';
import 'package:mobileapp/dto/get_duty_list.dart';
import 'package:mobileapp/model/duty.dart';
import 'package:mobileapp/model/duty_status.dart';
import 'package:mobileapp/model/user.dart';
import 'package:mobileapp/services/auth_service.dart';
import '../widgets/custom_bottom_app_bar.dart'; // Import the CustomBottomAppBar
import 'create_duty_form.dart';
import 'duty_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:mobileapp/services/api_service_easy_taspen.dart'; // Import ApiService

class DutySPTScreen extends StatefulWidget {
  const DutySPTScreen({Key? key}) : super(key: key);

  @override
  _DutySPTScreenState createState() => _DutySPTScreenState();
}

class _DutySPTScreenState extends State<DutySPTScreen> {
  // Initialize duties as a list of Duty objects
  List<Duty> duties = [];
  List<Duty> filteredDuties = [];
  String sortColumn = "dutyDate"; // Updated to match Duty model
  bool ascending = true;
  String searchQuery = "";
  int recordsPerPage = 10;
  int currentPage = 1;

  // Filter state variables
  String selectedStatus = "All";
  DateTime? filterStartDate;
  DateTime? filterEndDate;

  // Role selection
  String? selectedRole; // 'conceptor/maker' or 'approval'

  // API Service and Secure Storage instances
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  // Loading and error states
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRoleSelectionDialog();
    });
  }

  /// Shows a dialog to select the user role
  void _showRoleSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("Select Role"),
        content: const Text("Please select your role to proceed."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                selectedRole = "conceptor/maker";
              });
              _fetchDuties();
            },
            child: const Text("As Conceptor/Maker"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                selectedRole = "approval";
              });
              _fetchDuties();
            },
            child: const Text("As Approval"),
          ),
        ],
      ),
    );
  }

  /// Fetches duties from the API
  Future<void> _fetchDuties() async {
    if (selectedRole == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      User user = await _authService.loadUserInfo();
      String nik = user.nik;
      String kodeJabatan = user.kodeJabatan;

      // Fetch duties from API
      BaseResponse<GetDutyList> getDutyListResponse =
          await _apiService.fetchDuties(nik, kodeJabatan);

      // Check metadata code
      if (getDutyListResponse.metadata.code == 200) {
        setState(() {
          duties = selectedRole == "conceptor/maker"
              ? getDutyListResponse.response.duty
              : getDutyListResponse.response.dutyApprove;
          filterDuties(); // Apply initial filters
        });
      } else {
        throw Exception(getDutyListResponse.metadata.message);
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'Failed to load duties.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Filters the duties based on search query, selected status, date range, and role
  void filterDuties() {
    setState(() {
      filteredDuties = duties.where((duty) {
        bool matchesRole = selectedRole == "conceptor/maker"
            ? _isConceptorMakerDuty(duty)
            : _isApprovalDuty(duty);

        bool matchesSearch = duty.description
                ?.toLowerCase()
                .contains(searchQuery.toLowerCase()) ??
            false;

        bool matchesStatus =
            selectedStatus == "All" ? true : duty.status.code == selectedStatus;

        bool matchesStartDate = filterStartDate == null
            ? true
            : duty.dutyDate
                .isAfter(filterStartDate!.subtract(const Duration(days: 1)));

        bool matchesEndDate = filterEndDate == null
            ? true
            : duty.dutyDate
                .isBefore(filterEndDate!.add(const Duration(days: 1)));

        return matchesRole &&
            matchesSearch &&
            matchesStatus &&
            matchesStartDate &&
            matchesEndDate;
      }).toList();

      currentPage = 1; // Reset to first page on filter
    });
  }

  /// Determines if a duty belongs to Conceptor/Maker role
  bool _isConceptorMakerDuty(Duty duty) {
    // Define logic to determine if duty is for Conceptor/Maker
    return duty.status == DutyStatus.draft ||
        duty.status == DutyStatus.waiting ||
        duty.status == DutyStatus.returned ||
        duty.status == DutyStatus.approved ||
        duty.status == DutyStatus.rejected;
  }

  /// Determines if a duty belongs to Approval role
  bool _isApprovalDuty(Duty duty) {
    // Define logic to determine if duty is for Approval
    return duty.status == DutyStatus.waiting ||
        duty.status == DutyStatus.returned ||
        duty.status == DutyStatus.approved ||
        duty.status == DutyStatus.rejected;
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
      filteredDuties.sort((a, b) {
        dynamic aValue;
        dynamic bValue;

        switch (columnKey) {
          case "keterangan":
            aValue = a.description ?? '';
            bValue = b.description ?? '';
            break;
          case "dutyDate":
            aValue = a.dutyDate;
            bValue = b.dutyDate;
            break;
          case "status":
            aValue = a.status;
            bValue = b.status;
            break;
          default:
            aValue = a.dutyDate;
            bValue = b.dutyDate;
        }

        if (aValue is DateTime && bValue is DateTime) {
          return ascending
              ? aValue.compareTo(bValue)
              : bValue.compareTo(aValue);
        } else if (aValue is DutyStatus && bValue is DutyStatus) {
          return ascending
              ? aValue.index.compareTo(bValue.index)
              : bValue.index.compareTo(aValue.index);
        } else {
          return ascending
              ? aValue.toString().compareTo(bValue.toString())
              : bValue.toString().compareTo(aValue.toString());
        }
      });
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.teal, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.teal, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
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

  String _getStatusText(DutyStatus status, String selectedRole) {
    if (selectedRole == "conceptor/maker") {
      return status.conceptorDesc;
    } else {
      return status.approverDesc;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selectedRole == null) {
      // Role not selected yet
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
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: const CustomBottomAppBar(),
      );
    }

    int totalPages = (filteredDuties.length / recordsPerPage).ceil();
    int startIndex = (currentPage - 1) * recordsPerPage;
    int endIndex = startIndex + recordsPerPage;
    List<Duty> visibleDuties = filteredDuties.sublist(
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
        actions: [
          IconButton(
            icon: const Icon(Icons.switch_account),
            onPressed: () {
              // Allow user to switch role
              _showRoleSelectionDialog();
            },
            tooltip: "Switch Role",
          ),
        ],
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
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Create Duty Form Button
                        ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CreateDutyForm(),
                              ),
                            );
                            _fetchDuties(); // Refresh duties after form submission
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Create Duty Form"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "ALL DUTY",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.teal),
                        ),
                        const SizedBox(height: 15),
                        _buildStatusItem(
                          status: null, // Represents "All"
                          label: "All",
                          count: filteredDuties.length,
                          color: Colors.teal,
                        ),
                        const Divider(),
                        if (selectedRole == "conceptor/maker") ...[
                          const Text(
                            "AS A CONCEPTOR / MAKER",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.teal),
                          ),
                          const SizedBox(height: 15),
                          _buildStatusItem(
                            status: DutyStatus.draft,
                            label: DutyStatus.draft.conceptorDesc,
                            count: duties.where((duty) => duty.status == DutyStatus.draft).length,
                            color: DutyStatus.draft.color,
                          ),
                          _buildStatusItem(
                            status: DutyStatus.waiting,
                            label: DutyStatus.waiting.conceptorDesc,
                            count: duties.where((duty) => duty.status == DutyStatus.waiting).length,
                            color: DutyStatus.waiting.color,
                          ),
                          _buildStatusItem(
                            status: DutyStatus.returned,
                            label: DutyStatus.returned.conceptorDesc,
                            count: duties.where((duty) => duty.status == DutyStatus.returned).length,
                            color: DutyStatus.returned.color,
                          ),
                          _buildStatusItem(
                            status: DutyStatus.approved,
                            label: DutyStatus.approved.conceptorDesc,
                            count: duties.where((duty) => duty.status == DutyStatus.approved).length,
                            color: DutyStatus.approved.color,
                          ),
                          _buildStatusItem(
                            status: DutyStatus.rejected,
                            label: DutyStatus.rejected.conceptorDesc,
                            count: duties.where((duty) => duty.status == DutyStatus.rejected).length,
                            color: DutyStatus.rejected.color,
                          ),
                        ] else if (selectedRole == "approval") ...[
                          const Text(
                            "AS AN APPROVAL",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.teal),
                          ),
                          const SizedBox(height: 15),
                          _buildStatusItem(
                            status: DutyStatus.waiting,
                            label: DutyStatus.waiting.approverDesc,
                            count: duties.where((duty) => duty.status == DutyStatus.waiting).length,
                            color: DutyStatus.waiting.color,
                          ),
                          _buildStatusItem(
                            status: DutyStatus.returned,
                            label: DutyStatus.returned.approverDesc,
                            count: duties.where((duty) => duty.status == DutyStatus.returned).length,
                            color: DutyStatus.returned.color,
                          ),
                          _buildStatusItem(
                            status: DutyStatus.approved,
                            label: DutyStatus.approved.approverDesc,
                            count: duties.where((duty) => duty.status == DutyStatus.approved).length,
                            color: DutyStatus.approved.color,
                          ),
                          _buildStatusItem(
                            status: DutyStatus.rejected,
                            label: DutyStatus.rejected.approverDesc,
                            count: duties.where((duty) => duty.status == DutyStatus.rejected).length,
                            color: DutyStatus.rejected.color,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                /// Main Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                "All Duty in ${DateTime.now().year}",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Filter Controls
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Status Filter
                                  Row(
                                    children: [
                                      const Text(
                                        "Status:",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
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
                                        items: _getStatusDropdownItems(),
                                        dropdownColor: Colors.white,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 16),
                                        iconEnabledColor: Colors.teal,
                                        underline: Container(
                                          height: 2,
                                          color: Colors.teal,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Date Range Filter
                                  Row(
                                    children: [
                                      // Start Date
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today,
                                              size: 20, color: Colors.teal),
                                          const SizedBox(width: 8),
                                          Text(
                                            filterStartDate == null
                                                ? "Start Date"
                                                : DateFormat('dd-MM-yyyy')
                                                    .format(filterStartDate!),
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                size: 20, color: Colors.teal),
                                            onPressed: () {
                                              _selectDate(context, true);
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 20),
                                      // End Date
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today,
                                              size: 20, color: Colors.teal),
                                          const SizedBox(width: 8),
                                          Text(
                                            filterEndDate == null
                                                ? "End Date"
                                                : DateFormat('dd-MM-yyyy')
                                                    .format(filterEndDate!),
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                size: 20, color: Colors.teal),
                                            onPressed: () {
                                              _selectDate(context, false);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  // Clear Filters Button
                                  ElevatedButton.icon(
                                    onPressed: _clearFilters,
                                    icon: const Icon(Icons.clear),
                                    label: const Text("Clear Filters"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 30),

                              // Header: records & search
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                        child: Text("10 per page"),
                                      ),
                                      DropdownMenuItem(
                                        value: "25",
                                        child: Text("25 per page"),
                                      ),
                                      DropdownMenuItem(
                                        value: "50",
                                        child: Text("50 per page"),
                                      ),
                                      DropdownMenuItem(
                                        value: "100",
                                        child: Text("100 per page"),
                                      ),
                                    ],
                                    dropdownColor: Colors.white,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16),
                                    iconEnabledColor: Colors.teal,
                                    underline: Container(
                                      height: 2,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 250,
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
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 0, horizontal: 16),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Table
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Container(
                                    // Make the table width responsive
                                    constraints: const BoxConstraints(
                                      minWidth:
                                          800, // Increased min width for better layout
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Headers
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.teal.shade50,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              _buildSortableColumn(
                                                  "Keterangan", "keterangan"),
                                              _buildSortableColumn(
                                                  "Tanggal Tugas", "dutyDate"),
                                              _buildSortableColumn(
                                                  "Status", "status"),
                                              // Removed "Jam Mulai" and "Jam Selesai" headers
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        // Rows
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: visibleDuties.length,
                                          itemBuilder: (context, index) {
                                            final duty = visibleDuties[index];
                                            return _buildTableRow(duty: duty);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Pagination
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Showing ${startIndex + 1} to "
                                    "${endIndex > filteredDuties.length ? filteredDuties.length : endIndex} "
                                    "of ${filteredDuties.length} entries",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.teal),
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
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.teal,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "Page $currentPage of $totalPages",
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.teal),
                                      ),
                                      const SizedBox(width: 10),
                                      TextButton(
                                        onPressed: currentPage < totalPages
                                            ? () {
                                                setState(() {
                                                  currentPage++;
                                                });
                                              }
                                            : null,
                                        child: const Text("Next"),
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.teal,
                                        ),
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
            return isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Create Duty Form Button
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CreateDutyForm(),
                                ),
                              );
                              _fetchDuties(); // Refresh duties after form submission
                            },
                            icon: const Icon(Icons.add),
                            label: const Text("Create Duty Form"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "ALL DUTY",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.teal),
                          ),
                          const SizedBox(height: 10),
                          const Divider(),
                          if (selectedRole == "conceptor/maker") ...[
                            const Text(
                              "AS A CONCEPTOR / MAKER",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.teal),
                            ),
                            const SizedBox(height: 15),
                            _buildStatusItem(
                              status: DutyStatus.draft,
                              label: DutyStatus.draft.conceptorDesc,
                              count: duties.where((duty) => duty.status == DutyStatus.draft).length,
                              color: DutyStatus.draft.color,
                            ),
                            _buildStatusItem(
                              status: DutyStatus.waiting,
                              label: DutyStatus.waiting.conceptorDesc,
                              count: duties.where((duty) => duty.status == DutyStatus.waiting).length,
                              color: DutyStatus.waiting.color,
                            ),
                            _buildStatusItem(
                              status: DutyStatus.returned,
                              label: DutyStatus.returned.conceptorDesc,
                              count: duties.where((duty) => duty.status == DutyStatus.returned).length,
                              color: DutyStatus.returned.color,
                            ),
                            _buildStatusItem(
                              status: DutyStatus.approved,
                              label: DutyStatus.approved.conceptorDesc,
                              count: duties.where((duty) => duty.status == DutyStatus.approved).length,
                              color: DutyStatus.approved.color,
                            ),
                            _buildStatusItem(
                              status: DutyStatus.rejected,
                              label: DutyStatus.rejected.conceptorDesc,
                              count: duties.where((duty) => duty.status == DutyStatus.rejected).length,
                              color: DutyStatus.rejected.color,
                            ),
                          ] else if (selectedRole == "approval") ...[
                            const Text(
                              "AS AN APPROVAL",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.teal),
                            ),
                            const SizedBox(height: 15),
                            _buildStatusItem(
                              status: DutyStatus.waiting,
                              label: DutyStatus.waiting.approverDesc,
                              count: duties.where((duty) => duty.status == DutyStatus.waiting).length,
                              color: DutyStatus.waiting.color,
                            ),
                            _buildStatusItem(
                              status: DutyStatus.returned,
                              label: DutyStatus.returned.approverDesc,
                              count: duties.where((duty) => duty.status == DutyStatus.returned).length,
                              color: DutyStatus.returned.color,
                            ),
                            _buildStatusItem(
                              status: DutyStatus.approved,
                              label: DutyStatus.approved.approverDesc,
                              count: duties.where((duty) => duty.status == DutyStatus.approved).length,
                              color: DutyStatus.approved.color,
                            ),
                            _buildStatusItem(
                              status: DutyStatus.rejected,
                              label: DutyStatus.rejected.approverDesc,
                              count: duties.where((duty) => duty.status == DutyStatus.rejected).length,
                              color: DutyStatus.rejected.color,
                            ),
                          ],
                          const SizedBox(height: 20),

                          // Title
                          Text(
                            "All Duty in ${DateTime.now().year}",
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal),
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
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
                                    dropdownColor: Colors.white,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16),
                                    iconEnabledColor: Colors.teal,
                                    underline: Container(
                                      height: 2,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
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
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 0, horizontal: 16),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: BorderSide.none,
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
                              return _buildMobileDutyCard(duty: duty);
                            }).toList(),
                          ),

                          const SizedBox(height: 10),

                          // Pagination
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Showing ${startIndex + 1} to "
                                "${endIndex > filteredDuties.length ? filteredDuties.length : endIndex} "
                                "of ${filteredDuties.length} entries",
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.teal),
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
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.teal,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Page $currentPage of $totalPages",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.teal),
                                  ),
                                  const SizedBox(width: 10),
                                  TextButton(
                                    onPressed: currentPage < totalPages
                                        ? () {
                                            setState(() {
                                              currentPage++;
                                            });
                                          }
                                        : null,
                                    child: const Text("Next"),
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                    ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                      items: _getStatusDropdownItems(),
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      iconEnabledColor: Colors.teal,
                      underline: Container(
                        height: 2,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Date Range Filter
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 20, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text(
                    filterStartDate == null
                        ? "Start Date"
                        : DateFormat('dd-MM-yyyy').format(filterStartDate!),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Colors.teal),
                    onPressed: () {
                      _selectDate(context, true);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 20, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text(
                    filterEndDate == null
                        ? "End Date"
                        : DateFormat('dd-MM-yyyy').format(filterEndDate!),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Colors.teal),
                    onPressed: () {
                      _selectDate(context, false);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Clear Filters Button
              ElevatedButton.icon(
                onPressed: () {
                  _clearFilters();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.clear),
                label: const Text("Clear Filters"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Get dropdown items based on selected role
  List<DropdownMenuItem<String>> _getStatusDropdownItems() {
    List<DropdownMenuItem<String>> items = [
      const DropdownMenuItem(
        value: "All",
        child: Text("All"),
      ),
    ];

    List<DutyStatus> statuses = [];

    if (selectedRole == "conceptor/maker") {
      statuses = [
        DutyStatus.draft,
        DutyStatus.waiting,
        DutyStatus.returned,
        DutyStatus.approved,
        DutyStatus.rejected,
      ];
    } else {
      statuses = [
        DutyStatus.waiting,
        DutyStatus.returned,
        DutyStatus.approved,
        DutyStatus.rejected,
      ];
    }

    items.addAll(statuses.map((status) {
      String description = selectedRole == "conceptor/maker"
          ? status.conceptorDesc
          : status.approverDesc;
      return DropdownMenuItem(
        value: status.code,
        child: Text(description),
      );
    }).toList());

    return items;
  }

  /// Show sidebar status item
  Widget _buildStatusItem({
    DutyStatus? status,
    required String label,
    required int count,
    required Color color,
  }) {
    bool isSelected;
    String statusCode = status?.code ?? "All";

    isSelected = selectedStatus == statusCode;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedStatus = statusCode;
            filterDuties();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: color),
                ),
              ),
              CircleAvatar(
                backgroundColor: color,
                radius: 12,
                child: Text(
                  count.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Table row for large screens
  Widget _buildTableRow({required Duty duty}) {
    Color statusColor = duty.status.color;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DutyDetailScreen(dutyId: duty.id),
          ),
        ).then((_) {
          _fetchDuties(); // Refresh duties after returning from detail screen
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        margin: const EdgeInsets.only(bottom: 10),
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
                    duty.description ?? "",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${_formatTime(duty.startTime)} - ${_formatTime(duty.endTime)}",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Tanggal Tugas
            Expanded(
              flex: 2,
              child: Text(
                _formatDate(duty.dutyDate.toIso8601String()),
                style: const TextStyle(fontSize: 16, color: Colors.teal),
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
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: Text(
                  _getStatusText(duty.status, selectedRole!),
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
      flex: columnKey == "keterangan" ? 3 : 2, // Adjust flex based on column
      child: InkWell(
        onTap: () => sortDuties(columnKey),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
            const SizedBox(width: 4),
            Icon(
              sortColumn == columnKey
                  ? (ascending ? Icons.arrow_upward : Icons.arrow_downward)
                  : Icons.unfold_more, // default icon
              size: 18,
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to format time from "HH:mm:ss" to "HH:mm"
  String _formatTime(String time) {
    try {
      // Ensure time has seconds
      if (!time.contains(':')) return time;
      List<String> parts = time.split(':');
      if (parts.length < 2) return time;
      return "${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}";
    } catch (e) {
      return time;
    }
  }

  /// Helper method to format date from ISO string to "dd-MM-yyyy"
  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  /// Card-like duty item for mobile screens
  Widget _buildMobileDutyCard({required Duty duty}) {
    Color statusColor = duty.status.color;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DutyDetailScreen(dutyId: duty.id),
            ),
          ).then((_) {
            _fetchDuties(); // Refresh duties after returning from detail screen
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              Text(
                duty.description ?? "",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              // Time Range
              Text(
                "${_formatTime(duty.startTime)} - ${_formatTime(duty.endTime)}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              // Date and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 18, color: Colors.teal),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(duty.dutyDate.toIso8601String()),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.teal),
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
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    child: Text(
                      _getStatusText(duty.status, selectedRole!),
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
}

// lib/screens/create_duty_form.dart
import 'package:flutter/material.dart';
import '../widgets/custom_bottom_app_bar.dart'; // Import the CustomBottomAppBar
import 'duty_detail_screen.dart'; // Ensure this is used elsewhere if needed
import 'package:intl/intl.dart'; // Import intl for date formatting

class CreateDutyForm extends StatefulWidget {
  /// We pass the entire duties list so we can add a new draft or waiting item
  final List<Map<String, dynamic>> duties;
  final Map<String, dynamic>? dutyToEdit; // Optional parameter for editing

  const CreateDutyForm({
    Key? key,
    required this.duties,
    this.dutyToEdit, // Initialize the optional parameter
  }) : super(key: key);

  @override
  _CreateDutyFormState createState() => _CreateDutyFormState();
}

class _CreateDutyFormState extends State<CreateDutyForm> {
  // ----- DUMMY DATA (for employees & approvers) -----
  final List<Map<String, String>> _employeeList = [
    {"id": "80019", "name": "HENRISA YUNAN LUBIS (IT DIVISION HEAD)"},
    {"id": "3941", "name": "MOHAMMAD RAMDAN (IT PLANNING & BUDGETING STAFF)"},
    {"id": "3942", "name": "NAUFAL AZHAR FAUZI (DATA CENTER INFRASTRUCTURE)"},
    {"id": "90051", "name": "OVITA SUSIANA ROSYA (DIREKTUR SDM & TI)"},
    {"id": "90050", "name": "ARIYANDI (DIREKTUR OPERASIONAL)"},
  ];

  final List<Map<String, String>> _approverList = [
    {"id": "60001", "name": "John Doe (CEO)"},
    {"id": "60002", "name": "Jane Smith (CFO)"},
    {"id": "60003", "name": "Robert Brown (COO)"},
  ];

  // Multiple "Name & Description" rows
  List<Map<String, String>> _namesAndDescriptions = [
    {
      "employeeId": "",
      "employeeName": "",
      "description": "",
    }
  ];

  // Single approver (id)
  String? _selectedApproverId;

  // Duty date/time
  DateTime? _selectedDutyDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Transport
  String? _selectedTransport;

  // Rejection Reason (only applicable if editing a Rejected duty)
  String? _rejectionReason;

  // Flag to determine if the duty is rejected
  bool isRejected = false;

  // Consistent TextStyle
  final TextStyle _labelStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  final TextStyle _inputStyle = const TextStyle(
    fontSize: 16,
  );

  // ========== PICKERS ==========
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDutyDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (result != null) {
      setState(() {
        _selectedDutyDate = result;
      });
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final now = TimeOfDay.now();
    final result = await showTimePicker(
      context: context,
      initialTime: isStart ? (_startTime ?? now) : (_endTime ?? now),
    );
    if (result != null) {
      setState(() {
        if (isStart) {
          _startTime = result;
        } else {
          _endTime = result;
        }
      });
    }
  }

  // ========== BUTTON HANDLERS ==========

  /// Reset the entire form
  void _resetForm() {
    setState(() {
      if (widget.dutyToEdit != null) {
        // Reset to existing duty data
        final duty = widget.dutyToEdit!;
        _namesAndDescriptions =
            List<Map<String, String>>.from(duty["namesAndDescriptions"]);
        _selectedApproverId = duty["approverId"];
        _selectedDutyDate =
            duty["dutyDate"] != "" ? DateTime.parse(duty["dutyDate"]) : null;
        _startTime =
            duty["startTime"] != "" ? _parseTime(duty["startTime"]) : null;
        _endTime =
            duty["endTime"] != "" ? _parseTime(duty["endTime"]) : null;
        _selectedTransport = duty["transport"] ?? null;
        isRejected = duty["status"].toString().toLowerCase() == "rejected";
        _rejectionReason = duty["rejectionReason"] ?? "";
      } else {
        // Reset to default
        _namesAndDescriptions = [
          {"employeeId": "", "employeeName": "", "description": ""}
        ];
        _selectedApproverId = null;
        _selectedDutyDate = null;
        _startTime = null;
        _endTime = null;
        _selectedTransport = null;
        isRejected = false;
        _rejectionReason = null;
      }
    });
  }

  /// Save as Draft
  void _saveForm() {
    // Validate form before saving
    if (_validateForm()) {
      Map<String, dynamic> dutyData = {
        // For demonstration, let's store "createdBy" as "andhika.nayaka"
        "createdBy": "andhika.nayaka",
        "namesAndDescriptions": _namesAndDescriptions,
        "approverId": _selectedApproverId,
        "dutyDate": _selectedDutyDate?.toIso8601String() ?? "",
        "startTime": _startTime == null
            ? ""
            : "${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}:00",
        "endTime": _endTime == null
            ? ""
            : "${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}:00",
        "transport": _selectedTransport ?? "",
        // Additional fields
        "description": _namesAndDescriptions.first["description"] ?? "Untitled",
        "date": _selectedDutyDate == null
            ? ""
            : "${_selectedDutyDate!.year}-${_selectedDutyDate!.month.toString().padLeft(2, '0')}-${_selectedDutyDate!.day.toString().padLeft(2, '0')}",
        "status": "Draft",
        "createdAt":
            widget.dutyToEdit?["createdAt"] ?? DateTime.now().toIso8601String(),
        "modifiedAt": DateTime.now().toIso8601String(),
        "id": widget.dutyToEdit?["id"] ??
            (widget.duties.isNotEmpty
                ? widget.duties
                    .map((d) => d["id"] as int)
                    .reduce((a, b) => a > b ? a : b) +
                    1
                : 1),
        "rejectionReason": widget.dutyToEdit?["rejectionReason"] ?? "",
      };

      if (widget.dutyToEdit != null) {
        // Editing mode: Update existing duty based on 'id'
        int index =
            widget.duties.indexWhere((d) => d["id"] == widget.dutyToEdit!["id"]);
        if (index != -1) {
          widget.duties[index] = dutyData;
        }
      } else {
        // Creating mode: Add new duty
        widget.duties.add(dutyData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(widget.dutyToEdit != null
                ? "Duty Updated! (Draft)"
                : "Duty Form Saved! (Draft)")),
      );

      Navigator.pop(context, widget.dutyToEdit != null ? 'updated' : 'saved');
    }
  }

  /// Send to Approver -> status=Waiting
  void _sendToApprover() {
    // Validate form before sending
    if (_validateForm()) {
      Map<String, dynamic> dutyData = {
        "createdBy": "andhika.nayaka",
        "namesAndDescriptions": _namesAndDescriptions,
        "approverId": _selectedApproverId,
        "dutyDate": _selectedDutyDate?.toIso8601String() ?? "",
        "startTime": _startTime == null
            ? ""
            : "${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}:00",
        "endTime": _endTime == null
            ? ""
            : "${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}:00",
        "transport": _selectedTransport ?? "",
        "description": _namesAndDescriptions.first["description"] ?? "Untitled",
        "date": _selectedDutyDate == null
            ? ""
            : "${_selectedDutyDate!.year}-${_selectedDutyDate!.month.toString().padLeft(2, '0')}-${_selectedDutyDate!.day.toString().padLeft(2, '0')}",
        "status": "Waiting",
        "createdAt":
            widget.dutyToEdit?["createdAt"] ?? DateTime.now().toIso8601String(),
        "modifiedAt": DateTime.now().toIso8601String(),
        "id": widget.dutyToEdit?["id"] ??
            (widget.duties.isNotEmpty
                ? widget.duties
                    .map((d) => d["id"] as int)
                    .reduce((a, b) => a > b ? a : b) +
                    1
                : 1),
        "rejectionReason": widget.dutyToEdit?["rejectionReason"] ?? "",
      };

      if (widget.dutyToEdit != null) {
        // Editing mode: Update existing duty based on 'id'
        int index =
            widget.duties.indexWhere((d) => d["id"] == widget.dutyToEdit!["id"]);
        if (index != -1) {
          widget.duties[index] = dutyData;
        }
      } else {
        // Creating mode: Add new duty
        widget.duties.add(dutyData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(widget.dutyToEdit != null
                ? "Duty Updated! (Waiting)"
                : "Duty Form Sent to Approver! (Waiting)")),
      );

      Navigator.pop(context, 'sent'); // Pass 'sent' as result
    }
  }

  /// Validate the form fields
  bool _validateForm() {
    // Check if at least one employee is selected and description is provided
    for (var entry in _namesAndDescriptions) {
      if (entry["employeeId"]!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an employee.")),
        );
        return false;
      }
      if (entry["description"]!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please provide a description.")),
        );
        return false;
      }
    }

    // Check if approver is selected
    if (_selectedApproverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an approver.")),
      );
      return false;
    }

    // Check if duty date is selected
    if (_selectedDutyDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a duty date.")),
      );
      return false;
    }

    // Check if start and end times are selected
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select start and end times.")),
      );
      return false;
    }

    // Check if transport is selected
    if (_selectedTransport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a transport option.")),
      );
      return false;
    }

    // Additional validations can be added here

    return true;
  }

  // ========== UI BUILD WITH BOTTOM APP BAR ==========
  @override
  void initState() {
    super.initState();
    if (widget.dutyToEdit != null) {
      final duty = widget.dutyToEdit!;
      isRejected = duty["status"].toString().toLowerCase() == "rejected";
      _rejectionReason = duty["rejectionReason"] ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.dutyToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Duty" : "Create Duty"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // =========== EMPLOYEE-DESCRIPTION FIELDS ===========
            // Dynamic list of name/description fields
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _namesAndDescriptions.length,
              itemBuilder: (context, index) {
                return _buildNameDescriptionRow(index);
              },
            ),
            const SizedBox(height: 10),
            // Centered "+" button to add new employee-description rows
            Align(
              alignment: Alignment.center,
              child: IconButton(
                icon:
                    const Icon(Icons.add_circle, color: Colors.teal, size: 30),
                onPressed: isRejected ? null : _addNameField,
                tooltip: "Add Employee",
              ),
            ),
            const SizedBox(height: 20),

            // =========== APPROVER SECTION ===========
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Approver:",
                style: _labelStyle,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedApproverId,
              items: _approverList.map((item) {
                return DropdownMenuItem<String>(
                  value: item["id"],
                  child: Text("${item["name"]}"),
                );
              }).toList(),
              onChanged: isRejected
                  ? null
                  : (value) {
                      setState(() {
                        _selectedApproverId = value;
                      });
                    },
              decoration: const InputDecoration(
                labelText: "Select Approver",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
              ),
            ),
            const SizedBox(height: 20),

            // =========== DUTY DATE SECTION ===========
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Duty Date:",
                style: _labelStyle,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: isRejected ? null : _pickDate,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _selectedDutyDate == null
                      ? "Select Date"
                      : DateFormat('dd-MM-yyyy').format(_selectedDutyDate!),
                  style: _inputStyle,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // =========== START & END TIME SECTION ===========
            Row(
              children: [
                // Start Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Start Time:",
                        style: _labelStyle,
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: isRejected ? null : () => _pickTime(isStart: true),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _startTime == null
                                ? "HH:MM"
                                : "${_formatTime(_startTime)}",
                            style: _inputStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // End Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "End Time:",
                        style: _labelStyle,
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: isRejected ? null : () => _pickTime(isStart: false),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _endTime == null
                                ? "HH:MM"
                                : "${_formatTime(_endTime)}",
                            style: _inputStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // =========== TRANSPORT SECTION ===========
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Transport:",
                style: _labelStyle,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedTransport,
              items: const [
                DropdownMenuItem(
                  value: "Personal",
                  child: Text("Personal"),
                ),
                DropdownMenuItem(
                  value: "Official Car/Motorcycle",
                  child: Text("Official Car/Motorcycle"),
                ),
              ],
              onChanged: isRejected
                  ? null
                  : (value) {
                      setState(() {
                        _selectedTransport = value;
                      });
                    },
              decoration: const InputDecoration(
                labelText: "Select Transport",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
              ),
            ),
            const SizedBox(height: 30),

            // =========== REJECTION REASON SECTION (ONLY FOR EDITING REJECTED DUTIES) ===========
            if (isRejected)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rejection Reason:",
                    style: _labelStyle,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _rejectionReason ?? "No reason provided.",
                      style: const TextStyle(
                          fontSize: 16, color: Colors.red, fontStyle: FontStyle.italic),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            // =========== BUTTONS ===========
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Reset Button
                ElevatedButton(
                  onPressed: isRejected ? null : _resetForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  child: const Text(
                    "Reset",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 20),
                // Save Button
                if (!isRejected)
                  ElevatedButton(
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    ),
                    child: Text(isEditing ? "Update" : "Save"),
                  ),
                if (!isRejected) const SizedBox(width: 20),
                // Send to Approver Button
                if (!isRejected)
                  ElevatedButton(
                    onPressed: _sendToApprover,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding:
                          const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    ),
                    child: const Text(
                      "Send to Approver",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomAppBar(),
    );
  }

  // Add multiple rows
  void _addNameField() {
    setState(() {
      _namesAndDescriptions.add({
        "employeeId": "",
        "employeeName": "",
        "description": "",
      });
    });
  }

  // Build each row for Name + Description
  Widget _buildNameDescriptionRow(int index) {
    final nameDesc = _namesAndDescriptions[index];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for "Employee" selection + remove
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: (nameDesc["employeeId"] ?? '').isEmpty
                        ? null
                        : nameDesc["employeeId"],
                    items: _employeeList.map((item) {
                      return DropdownMenuItem<String>(
                        value: item["id"],
                        child: Text("${item["name"]}"),
                      );
                    }).toList(),
                    onChanged: isRejected
                        ? null
                        : (value) {
                            setState(() {
                              final found = _employeeList.firstWhere(
                                (element) => element["id"] == value,
                                orElse: () => {"id": "", "name": ""},
                              );
                              _namesAndDescriptions[index]["employeeId"] =
                                  found["id"] ?? "";
                              _namesAndDescriptions[index]["employeeName"] =
                                  found["name"] ?? "";
                            });
                          },
                    decoration: const InputDecoration(
                      labelText: "Select Employee",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Remove button if more than 1 row
                if (_namesAndDescriptions.length > 1 && !isRejected)
                  IconButton(
                    icon:
                        const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _namesAndDescriptions.removeAt(index);
                      });
                    },
                    tooltip: "Remove Employee",
                  ),
              ],
            ),
            const SizedBox(height: 20),
            // Description Field
            TextFormField(
              initialValue: nameDesc["description"],
              onChanged: isRejected
                  ? null
                  : (val) {
                      _namesAndDescriptions[index]["description"] = val;
                    },
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              enabled: !isRejected,
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to format time from TimeOfDay to "hh:mm a"
  String _formatTime(TimeOfDay? time) {
    if (time == null) return "HH:MM";
    final now = DateTime.now();
    final dt =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  /// Helper method to format date from DateTime to "dd-MM-yyyy"
  String _formatDate(DateTime? date) {
    if (date == null) return "Select Date";
    return DateFormat('dd-MM-yyyy').format(date);
  }

  /// Helper method to parse time from "HH:mm:ss" to TimeOfDay
  TimeOfDay? _parseTime(String time) {
    try {
      final parts = time.split(":");
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return null;
    }
  }
}

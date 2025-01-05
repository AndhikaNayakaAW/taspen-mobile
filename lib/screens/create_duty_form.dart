// lib/screens/create_duty_form.dart

import 'package:flutter/material.dart';
import 'package:mobileapp/dto/base_response.dart';
import 'package:mobileapp/dto/create_duty_response.dart';
import 'package:mobileapp/model/duty.dart';
import 'package:mobileapp/model/employee_duty.dart';
import 'package:mobileapp/model/user.dart';
import 'package:mobileapp/services/api_service_easy_taspen.dart'; // Import ApiService
import 'package:mobileapp/services/auth_service.dart';
import '../widgets/custom_bottom_app_bar.dart'; // Import the CustomBottomAppBar
import 'package:intl/intl.dart'; // Import intl for date formatting
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import for Secure Storage
import 'dart:convert'; // Import for JSON decoding

// lib/screens/create_duty_form.dart

class CreateDutyForm extends StatefulWidget {
  /// We pass the entire duties list so we can add a new draft or waiting item
  final List<Duty> duties;
  final Duty? dutyToEdit; // Optional parameter for editing

  const CreateDutyForm({
    super.key,
    required this.duties,
    this.dutyToEdit, // Initialize the optional parameter
  });

  @override
  CreateDutyFormState createState() => CreateDutyFormState();
}

class CreateDutyFormState extends State<CreateDutyForm> {
  // ----- API and Secure Storage Imports -----
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ----- Fetched Data Variables -----
  Map<String, String> _employeeList = {};
  Map<String, String> _approverList = {};
  Map<String, String> _transportList = {};

  // Loading and error states
  bool isLoading = false;
  String? errorMessage;

  // ----- State Variables -----
  // List of EmployeeDuty objects
  List<EmployeeDuty> _employee = [
    EmployeeDuty(employeeId: "", employeeName: "", description: ""),
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

  // Form Key
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  /// Initializes the form by fetching data from the API
  Future<void> _initializeForm() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      User user = await _authService.loadUserInfo();

      // Fetch create duty form data from API
      BaseResponse<CreateDutyResponse> createDutyResponse = await _apiService
          .createDuty(nik: user.nik, orgeh: user.orgeh, ba: user.ba);

      if (createDutyResponse.metadata.code == 200) {
        setState(() {
          _employeeList = createDutyResponse.response.employee;
          _approverList = createDutyResponse.response.approver;
          _transportList = createDutyResponse.response.transport;

          // If editing an existing duty, populate the form with its data
          if (widget.dutyToEdit != null) {
            final duty = widget.dutyToEdit!;
            isRejected = duty.status.toLowerCase() == "rejected";
            _rejectionReason = duty.rejectionReason ?? "";
            _employee = List<EmployeeDuty>.from(
                duty.employee as Iterable<EmployeeDuty>);
            _selectedApproverId = duty.approverId;
            _selectedDutyDate = duty.dutyDate;
            _startTime = _parseTime(duty.startTime);
            _endTime = _parseTime(duty.endTime);
            _selectedTransport = duty.transport;
          }
        });
      } else {
        throw Exception(createDutyResponse.metadata.message);
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? 'Failed to load form data.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Validate the form fields
  bool _validateForm() {
    // Check if at least one employee is selected and description is provided
    for (var entry in _employee) {
      if (entry.employeeId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an employee.")),
        );
        return false;
      }
      if (entry.description!.isEmpty) {
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

  /// Save as Draft
  void _saveForm() {
    // Validate form before saving
    if (_validateForm()) {
      Duty dutyData = Duty(
        id: widget.dutyToEdit != null
            ? widget.dutyToEdit!.id
            : (widget.duties.isNotEmpty
                ? widget.duties
                        .map((d) => d.id)
                        .reduce((a, b) => a > b ? a : b) +
                    1
                : 1),
        description: _employee.first.description,
        dutyDate: _selectedDutyDate ?? DateTime.now(),
        status: "Draft",
        startTime: _startTime == null
            ? "09:00:00"
            : "${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}:00",
        endTime: _endTime == null
            ? "17:00:00"
            : "${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}:00",
        transport: _selectedTransport ?? "Personal",
        sptNumber: null, // Assign as needed
        sptLetterNumber: null, // Assign as needed
        dateCreated: widget.dutyToEdit?.dateCreated ?? DateTime.now(),
        createdAt: widget.dutyToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        sapStatus: null,
        sapError: null,
        rejectionReason: null,
        createdBy: "andhika.nayaka", // Replace with actual user
        approverId: _selectedApproverId,
        employee: _employee,
      );

      if (widget.dutyToEdit != null) {
        // Editing mode: Update existing duty based on 'id'
        int index = widget.duties
            .indexWhere((duty) => duty.id == widget.dutyToEdit!.id);
        if (index != -1) {
          setState(() {
            widget.duties[index] = dutyData;
          });
        }
      } else {
        // Creating mode: Add new duty
        setState(() {
          widget.duties.add(dutyData);
        });
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
      Duty dutyData = Duty(
        id: widget.dutyToEdit != null
            ? widget.dutyToEdit!.id
            : (widget.duties.isNotEmpty
                ? widget.duties
                        .map((d) => d.id)
                        .reduce((a, b) => a > b ? a : b) +
                    1
                : 1),
        description: _employee.first.description,
        dutyDate: _selectedDutyDate ?? DateTime.now(),
        status: "Waiting",
        startTime: _startTime == null
            ? "09:00:00"
            : "${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}:00",
        endTime: _endTime == null
            ? "17:00:00"
            : "${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}:00",
        transport: _selectedTransport ?? "Personal",
        sptNumber: null, // Assign as needed
        sptLetterNumber: null, // Assign as needed
        dateCreated: widget.dutyToEdit?.dateCreated ?? DateTime.now(),
        createdAt: widget.dutyToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        sapStatus: null,
        sapError: null,
        rejectionReason: null,
        createdBy: "andhika.nayaka", // Replace with actual user
        approverId: _selectedApproverId,
        employee: _employee,
      );

      if (widget.dutyToEdit != null) {
        // Editing mode: Update existing duty based on 'id'
        int index = widget.duties
            .indexWhere((duty) => duty?.id == widget.dutyToEdit!.id);
        if (index != -1) {
          setState(() {
            widget.duties[index] = dutyData;
          });
        }
      } else {
        // Creating mode: Add new duty
        setState(() {
          widget.duties.add(dutyData);
        });
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
        _employee =
            List<EmployeeDuty>.from(duty.employee as Iterable<EmployeeDuty>);
        _selectedApproverId = duty.approverId;
        _selectedDutyDate = duty.dutyDate;
        _startTime = _parseTime(duty.startTime);
        _endTime = _parseTime(duty.endTime);
        _selectedTransport = duty.transport;
        isRejected = duty.status.toLowerCase() == "rejected";
        _rejectionReason = duty.rejectionReason ?? "";
      } else {
        // Reset to default
        _employee = [
          EmployeeDuty(employeeId: "", employeeName: "", description: ""),
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

  // ========== UI BUILD WITH BOTTOM APP BAR ==========
  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.dutyToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Duty" : "Create Duty"),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // =========== EMPLOYEE-DESCRIPTION FIELDS ===========
                        // Dynamic list of name/description fields
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _employee.length,
                          itemBuilder: (context, index) {
                            return _buildNameDescriptionRow(index);
                          },
                        ),
                        const SizedBox(height: 10),
                        // Centered "+" button to add new employee-description rows
                        Align(
                          alignment: Alignment.center,
                          child: IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: Colors.teal, size: 30),
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
                          items: _approverList.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text("${entry.value}"),
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
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 8.0),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _selectedDutyDate == null
                                  ? "Select Date"
                                  : DateFormat('dd-MM-yyyy')
                                      .format(_selectedDutyDate!),
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
                                    onTap: isRejected
                                        ? null
                                        : () => _pickTime(isStart: true),
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
                                            : _formatTime(_startTime),
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
                                    onTap: isRejected
                                        ? null
                                        : () => _pickTime(isStart: false),
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
                                            : _formatTime(_endTime),
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
                          items: _transportList.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text("${entry.value}"),
                            );
                          }).toList(),
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
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 8.0),
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.red),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _rejectionReason ?? "No reason provided.",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                      fontStyle: FontStyle.italic),
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
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20),
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
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 20),
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
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 20),
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
                ),
      bottomNavigationBar: const CustomBottomAppBar(),
    );
  }

  // Add multiple rows
  void _addNameField() {
    setState(() {
      _employee
          .add(EmployeeDuty(employeeId: "", employeeName: "", description: ""));
    });
  }

  // Build each row for Name + Description
  Widget _buildNameDescriptionRow(int index) {
    final employeeDuty = _employee[index];

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
                    value: employeeDuty.employeeId.isEmpty
                        ? null
                        : employeeDuty.employeeId,
                    items: _employeeList.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text("${entry.value}"),
                      );
                    }).toList(),
                    onChanged: isRejected
                        ? null
                        : (value) {
                            setState(() {
                              final employeeName = _employeeList[value] ?? "";
                              _employee[index] = employeeDuty.copyWith(
                                employeeId: value ?? "",
                                employeeName: employeeName,
                              );
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
                if (_employee.length > 1 && !isRejected)
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _employee.removeAt(index);
                      });
                    },
                    tooltip: "Remove Employee",
                  ),
              ],
            ),
            const SizedBox(height: 20),
            // Description Field
            TextFormField(
              initialValue: employeeDuty.description,
              onChanged: isRejected
                  ? null
                  : (val) {
                      _employee[index] =
                          employeeDuty.copyWith(description: val);
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
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat('hh:mm a'); //"6:00 AM"
    return format.format(dt);
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

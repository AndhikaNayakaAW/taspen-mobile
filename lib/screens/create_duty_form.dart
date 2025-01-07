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
  // Description
  String _description = "";

  // List of EmployeeDuty objects for employee selections
  List<EmployeeDuty> _employeeDuties = [
    EmployeeDuty(employeeId: "", employeeName: ""),
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

  // Selected Action from Dropdown
  String? _selectedAction;

  // Original Data for Reset
  String _initialDescription = "";
  List<EmployeeDuty> _initialEmployeeDuties = [];
  String? _initialApproverId;
  DateTime? _initialDutyDate;
  TimeOfDay? _initialStartTime;
  TimeOfDay? _initialEndTime;
  String? _initialTransport;
  bool _initialIsRejected = false;
  String? _initialRejectionReason;

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

  /// Getter to determine if the form is in editing mode
  bool get isEditing => widget.dutyToEdit != null;

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
      BaseResponse<CreateDutyResponse> createDutyResponse =
          await _apiService.createDuty(nik: user.nik, orgeh: user.orgeh, ba: user.ba);

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
            _description = duty.description ?? "";
            _employeeDuties = (duty.employee?.isNotEmpty ?? false)
                ? duty.employee!
                    .map((e) => EmployeeDuty(
                          employeeId: e.employeeId,
                          employeeName: _employeeList[e.employeeId] ?? "",
                        ))
                    .toList()
                : [EmployeeDuty(employeeId: "", employeeName: "")];
            _selectedApproverId = duty.approverId;
            _selectedDutyDate = duty.dutyDate;
            _startTime = _parseTime(duty.startTime);
            _endTime = _parseTime(duty.endTime);
            _selectedTransport = duty.transport;

            // Store initial data for reset
            _initialDescription = _description;
            _initialEmployeeDuties = List<EmployeeDuty>.from(_employeeDuties);
            _initialApproverId = _selectedApproverId;
            _initialDutyDate = _selectedDutyDate;
            _initialStartTime = _startTime;
            _initialEndTime = _endTime;
            _initialTransport = _selectedTransport;
            _initialIsRejected = isRejected;
            _initialRejectionReason = _rejectionReason;
          } else {
            // Creating mode: Initialize initial data as empty
            _initialDescription = "";
            _initialEmployeeDuties = [
              EmployeeDuty(employeeId: "", employeeName: ""),
            ];
            _initialApproverId = null;
            _initialDutyDate = null;
            _initialStartTime = null;
            _initialEndTime = null;
            _initialTransport = null;
            _initialIsRejected = false;
            _initialRejectionReason = null;
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
    // Check if description is provided
    if (_description.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a description.")),
      );
      return false;
    }

    // Check if at least one employee is selected
    for (var entry in _employeeDuties) {
      if (entry.employeeId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an employee.")),
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

  /// Save as Draft or Update
  void _saveOrUpdateForm() {
    // Validate form before saving
    if (_validateForm()) {
      Duty dutyData = Duty(
        id: widget.dutyToEdit != null
            ? widget.dutyToEdit!.id
            : (widget.duties.isNotEmpty
                ? widget.duties.map((d) => d.id).reduce((a, b) => a > b ? a : b) + 1
                : 1),
        description: _description,
        dutyDate: _selectedDutyDate ?? DateTime.now(),
        status: widget.dutyToEdit != null ? widget.dutyToEdit!.status : "Draft",
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
        employee: _employeeDuties,
      );

      if (widget.dutyToEdit != null) {
        // Editing mode: Update existing duty based on 'id'
        int index = widget.duties.indexWhere((duty) => duty.id == widget.dutyToEdit!.id);
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
                ? widget.duties.map((d) => d.id).reduce((a, b) => a > b ? a : b) + 1
                : 1),
        description: _description,
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
        employee: _employeeDuties,
      );

      if (widget.dutyToEdit != null) {
        // Editing mode: Update existing duty based on 'id'
        int index = widget.duties.indexWhere((duty) => duty.id == widget.dutyToEdit!.id);
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
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
      _employeeDuties = List<EmployeeDuty>.from(_initialEmployeeDuties);
      _description = _initialDescription;
      _selectedApproverId = _initialApproverId;
      _selectedDutyDate = _initialDutyDate;
      _startTime = _initialStartTime;
      _endTime = _initialEndTime;
      _selectedTransport = _initialTransport;
      isRejected = _initialIsRejected;
      _rejectionReason = _initialRejectionReason;
      _selectedAction = null;
    });
  }

  /// Build each row for Employee selection with Remove button
  Widget _buildEmployeeRow(int index) {
    final employeeDuty = _employeeDuties[index];
    final initialEmployeeDuty = _initialEmployeeDuties.length > index
        ? _initialEmployeeDuties[index]
        : EmployeeDuty(employeeId: "", employeeName: "");

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee Selection Row
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
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: isRejected
                        ? null
                        : (value) {
                            setState(() {
                              final employeeName = _employeeList[value] ?? "";
                              _employeeDuties[index] = EmployeeDuty(
                                employeeId: value ?? "",
                                employeeName: employeeName,
                              );
                            });
                          },
                    decoration: const InputDecoration(
                      labelText: "Select Employee",
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Remove button if more than 1 row
                if (_employeeDuties.length > 1 && !isRejected)
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
                        _employeeDuties.removeAt(index);
                      });
                    },
                    tooltip: "Remove Employee",
                  ),
              ],
            ),
            const SizedBox(height: 20),
            // Display previous employee selection if editing and changed
            if (isEditing &&
                _initialEmployeeDuties.length > index &&
                (_initialEmployeeDuties[index].employeeId.isNotEmpty &&
                    _initialEmployeeDuties[index].employeeId !=
                        _employeeDuties[index].employeeId))
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Previous: ${_employeeList[_initialEmployeeDuties[index].employeeId] ?? "Not Set"}",
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic),
                  ),
                ),
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
      if (parts.length < 2) return null;
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return null;
    }
  }

  /// Capitalize the first letter of the status
  String capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1).toLowerCase() : s;

  /// Fetch approver's name based on approverId
  String _getApproverName(String? approverId) {
    if (approverId == null || approverId.isEmpty) return "N/A";

    // Define the approver list here or fetch from a data source
    final List<Map<String, String>> _approverListLocal = [
      {"id": "60001", "name": "John Doe (CEO)"},
      {"id": "60002", "name": "Jane Smith (CFO)"},
      {"id": "60003", "name": "Robert Brown (COO)"},
    ];

    final approver = _approverListLocal.firstWhere(
      (element) => element["id"] == approverId,
      orElse: () => {"id": "", "name": "Unknown Approver"},
    );

    return approver["name"]!;
  }

  /// Get dropdown items based on editing mode
  List<DropdownMenuItem<String>> _getActionDropdownItems(bool isEditing) {
    List<String> actions = ['Reset'];
    if (isEditing) {
      actions.addAll(['Update', 'Send to Approver']);
    } else {
      actions.addAll(['Save', 'Send to Approver']);
    }

    return actions
        .map((action) => DropdownMenuItem<String>(
              value: action,
              child: Text(action),
            ))
        .toList();
  }

  /// Get button color based on selected action
  Color _getButtonColor(String? action) {
    switch (action) {
      case 'Reset':
        return Colors.redAccent;
      case 'Save':
      case 'Update':
        return Colors.blue;
      case 'Send to Approver':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  /// Add multiple employee-selection rows
  void _addEmployeeField() {
    setState(() {
      _employeeDuties.add(EmployeeDuty(employeeId: "", employeeName: ""));
    });
  }

  /// Build the Rejection Reason section
  Widget _buildRejectionReason() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Rejection Reason:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            (_rejectionReason?.isNotEmpty ?? false)
                ? _rejectionReason!
                : "No reason provided.",
            style: const TextStyle(
              color: Colors.red,
              fontStyle: FontStyle.italic,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // =========== EMPLOYEE SELECTION FIELDS ===========
                        const Text(
                          "Employees:",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _employeeDuties.length,
                          itemBuilder: (context, index) {
                            return _buildEmployeeRow(index);
                          },
                        ),
                        const SizedBox(height: 10),
                        // Centered "+" button to add new employee-selection rows
                        Center(
                          child: IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: Colors.teal, size: 30),
                            onPressed: isRejected ? null : _addEmployeeField,
                            tooltip: "Add Employee",
                          ),
                        ),
                        const SizedBox(height: 20),

                        // =========== DESCRIPTION FIELD ===========
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Description:",
                            style: _labelStyle,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: _description,
                          onChanged: isRejected
                              ? null
                              : (val) {
                                  setState(() {
                                    _description = val;
                                  });
                                },
                          decoration: const InputDecoration(
                            labelText: "Enter Description",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 16.0),
                          ),
                          maxLines: 3,
                          enabled: !isRejected,
                        ),
                        // Display previous description if editing and changed
                        if (isEditing &&
                            _initialDescription.isNotEmpty &&
                            (_initialDescription != _description))
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Previous: $_initialDescription",
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic),
                              ),
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
                              child: Text(entry.value),
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
                                EdgeInsets.symmetric(horizontal: 12.0),
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
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.teal.shade50,
                            ),
                            child: Text(
                              _selectedDutyDate == null
                                  ? "Select Date"
                                  : DateFormat('dd-MM-yyyy')
                                      .format(_selectedDutyDate!),
                              style: _inputStyle.copyWith(
                                  color: Colors.teal.shade800),
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
                                        border:
                                            Border.all(color: Colors.grey.shade400),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.teal.shade50,
                                      ),
                                      child: Text(
                                        _startTime == null
                                            ? "HH:MM"
                                            : _formatTime(_startTime),
                                        style: _inputStyle.copyWith(
                                            color: Colors.teal.shade800),
                                      ),
                                    ),
                                  ),
                                  // Display previous start time if editing and changed
                                  if (isEditing &&
                                      _initialStartTime != null &&
                                      (_initialStartTime != _startTime))
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        "Previous: ${_formatTime(_initialStartTime)}",
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic),
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
                                        border:
                                            Border.all(color: Colors.grey.shade400),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.teal.shade50,
                                      ),
                                      child: Text(
                                        _endTime == null
                                            ? "HH:MM"
                                            : _formatTime(_endTime),
                                        style: _inputStyle.copyWith(
                                            color: Colors.teal.shade800),
                                      ),
                                    ),
                                  ),
                                  // Display previous end time if editing and changed
                                  if (isEditing &&
                                      _initialEndTime != null &&
                                      (_initialEndTime != _endTime))
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        "Previous: ${_formatTime(_initialEndTime)}",
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic),
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
                              child: Text(entry.value),
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
                                EdgeInsets.symmetric(horizontal: 12.0),
                          ),
                        ),
                        // Display previous transport if editing and changed
                        if (isEditing &&
                            _initialTransport != null &&
                            (_initialTransport != _selectedTransport))
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Previous: ${_transportList[_initialTransport] ?? "Not Set"}",
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                        const SizedBox(height: 30),

                        // =========== REJECTION REASON SECTION (ONLY FOR EDITING REJECTED DUTIES) ===========
                        if (isRejected)
                          _buildRejectionReason(),

                        // =========== ACTION DROPDOWN AND SUBMIT BUTTON ===========
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Action:",
                            style: _labelStyle,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Dropdown for Actions
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: _selectedAction,
                                hint: const Text("Select Action"),
                                items: _getActionDropdownItems(isEditing),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedAction = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 12.0),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Submit Button
                            ElevatedButton(
                              onPressed: _selectedAction == null
                                  ? null
                                  : () {
                                      switch (_selectedAction) {
                                        case 'Reset':
                                          _resetForm();
                                          break;
                                        case 'Save':
                                        case 'Update':
                                          _saveOrUpdateForm();
                                          break;
                                        case 'Send to Approver':
                                          _sendToApprover();
                                          break;
                                        default:
                                          break;
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _getButtonColor(_selectedAction),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(_selectedAction == 'Update'
                                  ? "Update"
                                  : _selectedAction == 'Send to Approver'
                                      ? "Send to Approver"
                                      : _selectedAction == 'Reset'
                                          ? "Reset"
                                          : "Submit"),
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
}

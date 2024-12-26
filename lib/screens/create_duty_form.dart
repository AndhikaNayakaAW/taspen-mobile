// lib/screens/create_duty_form.dart
import 'package:flutter/material.dart';
import 'saved_form_duty_screen.dart';
import 'send_form_duty_screen.dart';

class CreateDutyForm extends StatefulWidget {
  // Instead of onDutyCreated, we now pass the entire duties list
  final List<Map<String, dynamic>> duties;

  const CreateDutyForm({
    Key? key,
    required this.duties,
  }) : super(key: key);

  @override
  _CreateDutyFormState createState() => _CreateDutyFormState();
}

class _CreateDutyFormState extends State<CreateDutyForm> {
  // ----- DUMMY DATA (for names / employees & approvers) -----
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

  // We track multiple "Name & Description" rows in one list
  List<Map<String, String>> _namesAndDescriptions = [
    {"employeeId": "", "employeeName": "", "description": ""}
  ];

  // Single approver
  String? _selectedApproverId;

  // Duty date/time
  DateTime? _selectedDutyDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Transport
  String? _selectedTransport;

  // ========== PICKERS ==========
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: now,
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
      initialTime: now,
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
  void _resetForm() {
    setState(() {
      _namesAndDescriptions = [
        {"employeeId": "", "employeeName": "", "description": ""}
      ];
      _selectedApproverId = null;
      _selectedDutyDate = null;
      _startTime = null;
      _endTime = null;
      _selectedTransport = null;
    });
  }

  void _saveForm() {
    // Construct new duty data
    final dutyData = {
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
    };

    // Add to the shared list
    widget.duties.add(dutyData);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Duty Form Saved!")),
    );

    // Navigate to SavedFormDutyScreen with the entire updated list
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SavedFormDutyScreen(
          duties: widget.duties,
        ),
      ),
    );
  }

void _sendToApprover() {
  final dutyData = {
    // all your fields...
    "status": "Waiting",
  };
  widget.duties.add(dutyData);
  
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Duty Form Sent to Approver!")),
  );
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => SendFormDutyScreen(duties: widget.duties),
    ),
  );
}


  // ========== UI BUILD ==========
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Form Duty"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // =========== NAME(S) SECTION ===========
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: [
                const Text(
                  "Name(s):",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _addNameField,
                  icon: const Icon(Icons.add),
                  label: const Text("Add"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // dynamic list of name/description fields
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _namesAndDescriptions.length,
              itemBuilder: (context, index) {
                return _buildNameDescriptionRow(index);
              },
            ),
            const SizedBox(height: 20),

            // =========== APPROVER SECTION ===========
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: const [
                Text(
                  "Approver:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedApproverId,
              items: _approverList.map((item) {
                return DropdownMenuItem<String>(
                  value: item["id"],
                  child: Text(item["name"]!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedApproverId = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
              ),
            ),
            const SizedBox(height: 20),

            // =========== DUTY DATE SECTION ===========
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: [
                const Text(
                  "Duty Date:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: _pickDate,
                  child: Container(
                    width: 180,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _selectedDutyDate == null
                          ? "Select Date"
                          : "${_selectedDutyDate!.year}-${_selectedDutyDate!.month.toString().padLeft(2, '0')}-${_selectedDutyDate!.day.toString().padLeft(2, '0')}",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // =========== START & END TIME SECTION ===========
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 30,
              runSpacing: 8,
              children: [
                // Start Time
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: [
                    const Text(
                      "Start Time:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      onTap: () => _pickTime(isStart: true),
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _startTime == null
                              ? "HH:MM"
                              : "${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}:00",
                        ),
                      ),
                    ),
                  ],
                ),
                // End Time
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: [
                    const Text(
                      "End Time:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      onTap: () => _pickTime(isStart: false),
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _endTime == null
                              ? "HH:MM"
                              : "${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}:00",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // =========== TRANSPORT SECTION ===========
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              children: const [
                Text(
                  "Transport:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
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
              onChanged: (value) {
                setState(() {
                  _selectedTransport = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
              ),
            ),
            const SizedBox(height: 30),

            // =========== BUTTONS ===========
            Wrap(
              spacing: 20,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _resetForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text("Reset"),
                ),
                ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text("Save"),
                ),
                ElevatedButton(
                  onPressed: _sendToApprover,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Send to Approver"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addNameField() {
    setState(() {
      _namesAndDescriptions.add({
        "employeeId": "",
        "employeeName": "",
        "description": "",
      });
    });
  }

  Widget _buildNameDescriptionRow(int index) {
    final nameDesc = _namesAndDescriptions[index];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for "Name" selection + Remove Button
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
                        child: Text("${item["id"]} - ${item["name"]}"),
                      );
                    }).toList(),
                    onChanged: (value) {
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
                if (_namesAndDescriptions.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _namesAndDescriptions.removeAt(index);
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: nameDesc["description"],
              onChanged: (val) {
                _namesAndDescriptions[index]["description"] = val;
              },
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

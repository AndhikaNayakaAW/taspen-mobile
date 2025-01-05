// lib/model/employee_duty.dart
class EmployeeDuty {
  final String employeeId;
  final String employeeName;
  final String? description;

  EmployeeDuty({
    required this.employeeId,
    required this.employeeName,
    this.description,
  });

  factory EmployeeDuty.fromJson(Map<String, dynamic> json) {
    return EmployeeDuty(
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'employeeName': employeeName,
      'description': description,
    };
  }

  EmployeeDuty copyWith({
    String? employeeId,
    String? employeeName,
    String? description,
  }) {
    return EmployeeDuty(
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'EmployeeDuty(employeeId: $employeeId, employeeName: $employeeName, description: $description)';
  }
}

class CreateDutyResponse {
  final Map<String, String> employee;
  final Map<String, String> approver;
  final Map<String, String> transport;
  final PayrollInfo payroll;

  CreateDutyResponse({
    required this.employee,
    required this.approver,
    required this.transport,
    required this.payroll,
  });

  factory CreateDutyResponse.fromJson(Map<String, dynamic> json) {
    return CreateDutyResponse(
      employee: Map<String, String>.from(json['employee']),
      approver: Map<String, String>.from(json['approver']),
      transport: Map<String, String>.from(json['transport']),
      payroll: PayrollInfo.fromJson(json['payroll']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee': employee,
      'approver': approver,
      'transport': transport,
      'payroll': payroll.toJson(),
    };
  }
}

class PayrollInfo {
  final bool isPayroll;
  final String message;

  PayrollInfo({
    required this.isPayroll,
    required this.message,
  });

  factory PayrollInfo.fromJson(Map<String, dynamic> json) {
    return PayrollInfo(
      isPayroll: json['isPayroll'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isPayroll': isPayroll,
      'message': message,
    };
  }
}

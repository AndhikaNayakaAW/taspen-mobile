// lib/model/duty.dart
import 'employee_duty.dart';

class Duty {
  final int id;
  final String startTime;
  final String endTime;
  final DateTime dutyDate;
  final String? description;
  final String? transport;
  final String? sptNumber;
  final String? sptLetterNumber;
  final DateTime? dateCreated;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;
  final String? sapStatus;
  final String? sapError;
  final String? rejectionReason;

  // Added fields
  final String? createdBy;
  final String? approverId;

  // New field for employee-description pairs
  final List<EmployeeDuty>? employee;

  Duty({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.dutyDate,
    this.description,
    this.transport,
    this.sptNumber,
    this.sptLetterNumber,
    this.dateCreated,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    this.sapStatus,
    this.sapError,
    this.rejectionReason,
    this.createdBy,
    this.approverId,
    this.employee,
  });

  /// Creates a Duty instance from a JSON map.
  factory Duty.fromJson(Map<String, dynamic> json) {
    // Handle the 'employee' field which is a list of EmployeeDuty objects
    List<EmployeeDuty>? employeeList;
    if (json['employee'] != null) {
      var employeeFromJson = json['employee'] as List<dynamic>;
      employeeList = employeeFromJson
          .map((e) => EmployeeDuty.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      employeeList = null;
    }

    return Duty(
      id: json['id'] as int,
      startTime: _formatTime(json['wkt_mulai']),
      endTime: _formatTime(json['wkt_selesai']),
      dutyDate: DateTime.parse(json['tgl_tugas'] as String),
      description: json['keterangan'] as String?,
      transport: json['kendaraan'] as String?,
      sptNumber: json['no_spt'] as String?,
      sptLetterNumber: json['no_surat_spt'] as String?,
      dateCreated: json['date_created'] != null
          ? DateTime.parse(json['date_created'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      status: json['status'] as String,
      sapStatus: json['status_sap'] as String?,
      sapError: json['error_sap'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      createdBy: json['createdBy'] as String?,
      approverId: json['approverId'] as String?,
      employee: employeeList,
    );
  }

  /// Converts a Duty instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wkt_mulai': startTime,
      'wkt_selesai': endTime,
      'tgl_tugas': dutyDate.toIso8601String().split('T').first,
      'keterangan': description,
      'kendaraan': transport,
      'no_spt': sptNumber,
      'no_surat_spt': sptLetterNumber,
      'date_created': dateCreated?.toIso8601String().split('T').first,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status,
      'status_sap': sapStatus,
      'error_sap': sapError,
      'rejectionReason': rejectionReason,
      'createdBy': createdBy,
      'approverId': approverId,
      'employee': employee?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Duty(id: $id, startTime: $startTime, endTime: $endTime, dutyDate: $dutyDate, description: $description, transport: $transport, sptNumber: $sptNumber, sptLetterNumber: $sptLetterNumber, dateCreated: $dateCreated, createdAt: $createdAt, updatedAt: $updatedAt, status: $status, sapStatus: $sapStatus, sapError: $sapError, rejectionReason: $rejectionReason, createdBy: $createdBy, approverId: $approverId, employee: $employee)';
  }

  /// Creates a copy of the current Duty with optional new values.
  Duty copyWith({
    int? id,
    String? startTime,
    String? endTime,
    DateTime? dutyDate,
    String? description,
    String? transport,
    String? sptNumber,
    String? sptLetterNumber,
    DateTime? dateCreated,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    String? sapStatus,
    String? sapError,
    String? rejectionReason,
    String? createdBy,
    String? approverId,
    List<EmployeeDuty>? employee,
  }) {
    return Duty(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      dutyDate: dutyDate ?? this.dutyDate,
      description: description ?? this.description,
      transport: transport ?? this.transport,
      sptNumber: sptNumber ?? this.sptNumber,
      sptLetterNumber: sptLetterNumber ?? this.sptLetterNumber,
      dateCreated: dateCreated ?? this.dateCreated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      sapStatus: sapStatus ?? this.sapStatus,
      sapError: sapError ?? this.sapError,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdBy: createdBy ?? this.createdBy,
      approverId: approverId ?? this.approverId,
      employee: employee ?? this.employee,
    );
  }

  /// Helper method to ensure time is in HH:mm:ss format
  static String _formatTime(dynamic time) {
    if (time is String) {
      // Ensure time has seconds
      if (time.length == 5) {
        return '$time:00';
      } else if (time.length == 8) {
        return time;
      }
    }
    return '00:00:00'; // Default value if format is unexpected
  }
}
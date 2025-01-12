// lib/model/duty.dart
import 'employee_duty.dart';
import 'duty_status.dart'; // Import the DutyStatus enum

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
  final DutyStatus status;
  final String? sapStatus;
  final String? sapError;

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
  });

  /// Creates a Duty instance from a JSON map.
  factory Duty.fromJson(Map<String, dynamic> json) {
    var description = json.containsKey('duty_description') &&
            json['duty_description'] != null &&
            json['duty_description'].containsKey('keterangan')
        ? json['duty_description']['keterangan']
        : json['keterangan'];

    return Duty(
      id: json['id'] as int,
      startTime: _formatTime(json['wkt_mulai']),
      endTime: _formatTime(json['wkt_selesai']),
      dutyDate: DateTime.parse(json['tgl_tugas'] as String),
      description: description as String?,
      transport: json['kendaraan'] as String?,
      sptNumber: json['no_spt'] as String?,
      sptLetterNumber: json['no_surat_spt'] as String?,
      dateCreated: json['date_created'] != null
          ? DateTime.parse(json['date_created'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      status: DutyStatus.fromCode(json['status']), // Updated
      sapStatus: json['status_sap'] as String?,
      sapError: json['error_sap'] as String?,
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
      'status': status.code, // Serialize using the code
      'status_sap': sapStatus,
      'error_sap': sapError
    };
  }

  @override
  String toString() {
    return 'Duty(id: $id, startTime: $startTime, endTime: $endTime, dutyDate: $dutyDate, description: $description, transport: $transport, sptNumber: $sptNumber, sptLetterNumber: $sptLetterNumber, dateCreated: $dateCreated, createdAt: $createdAt, updatedAt: $updatedAt, status: ${status.conceptorDesc}, sapStatus: $sapStatus, sapError: $sapError)';
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
    DutyStatus? status, // Updated
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
      status: status ?? this.status, // Updated
      sapStatus: sapStatus ?? this.sapStatus,
      sapError: sapError ?? this.sapError,
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

  /// Getter to retrieve the status description
  String get statusDescription => status.conceptorDesc;
}

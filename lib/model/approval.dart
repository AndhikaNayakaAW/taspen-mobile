// lib/model/approval.dart

class Approval {
  final int id;

  final String? workflowRefId;

  final String? modulId;

  final String? nik;

  final String? kodejabatan;

  final String? urutan;

  final String? workflowRoleId;

  final String? isRead;

  final String? statusApproval;

  final DateTime createdAt;

  final DateTime updatedAt;

  final String? note;

  Approval({
    required this.id,
    this.workflowRefId,
    this.modulId,
    this.nik,
    this.kodejabatan,
    this.urutan,
    this.workflowRoleId,
    this.isRead,
    this.statusApproval,
    required this.createdAt,
    required this.updatedAt,
    this.note,
  });

  factory Approval.fromJson(Map<String, dynamic> json) {
    return Approval(
      id: json['id'] as int,
      workflowRefId: json['workflow_ref_id'] as String?,
      modulId: json['modul_id'] as String?,
      nik: json['nik'] as String?,
      kodejabatan: json['kodejabatan'] as String?,
      urutan: json['urutan'] as String?,
      workflowRoleId: json['workflow_role_id'] as String?,
      isRead: json['is_read'] as String?,
      statusApproval: json['status_approval'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workflow_ref_id': workflowRefId,
      'modul_id': modulId,
      'nik': nik,
      'kodejabatan': kodejabatan,
      'urutan': urutan,
      'workflow_role_id': workflowRoleId,
      'is_read': isRead,
      'status_approval': statusApproval,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'note': note,
    };
  }

  @override
  String toString() {
    return 'Approval(id: $id, workflowRefId: $workflowRefId, modulId: $modulId, nik: $nik, kodejabatan: $kodejabatan, urutan: $urutan, workflowRoleId: $workflowRoleId, isRead: $isRead, statusApproval: $statusApproval, createdAt: $createdAt, updatedAt: $updatedAt, note: $note)';
  }

  Approval copyWith({
    int? id,
    String? workflowRefId,
    String? modulId,
    String? nik,
    String? kodejabatan,
    String? urutan,
    String? workflowRoleId,
    String? isRead,
    String? statusApproval,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? note,
  }) {
    return Approval(
      id: id ?? this.id,
      workflowRefId: workflowRefId ?? this.workflowRefId,
      modulId: modulId ?? this.modulId,
      nik: nik ?? this.nik,
      kodejabatan: kodejabatan ?? this.kodejabatan,
      urutan: urutan ?? this.urutan,
      workflowRoleId: workflowRoleId ?? this.workflowRoleId,
      isRead: isRead ?? this.isRead,
      statusApproval: statusApproval ?? this.statusApproval,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      note: note ?? this.note,
    );
  }
}
